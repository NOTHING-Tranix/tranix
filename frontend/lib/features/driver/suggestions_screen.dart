import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/errors/app_exception.dart';
import '../../core/errors/error_messages.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/network/interceptors.dart';
import '../../core/providers.dart';
import '../../core/router/routes.dart';
import '../../core/settings_provider.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';
import '../../shared/labels.dart';
import '../../shared/models/models.dart';
import '../notifications/notifications_feature.dart';
import '../shared_shell/tab_screens.dart' show ProfileAvatarButton;
import 'driver_feature.dart';

/// Contract §8 (suggestions).
class SuggestionsApi {
  SuggestionsApi(this._dio);

  final Dio _dio;

  Future<List<Suggestion>> list(String sort) async {
    final res = await guardApi(() => _dio.get<List<dynamic>>('/driver/suggestions', queryParameters: {'sort': sort}));
    return res.data!.map((e) => Suggestion.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> accept(String loadId) => guardApi(() => _dio.post<dynamic>('/driver/suggestions/$loadId/accept'));

  Future<void> reject(String loadId, SuggestionRejectReason reason) =>
      guardApi(() => _dio.post<void>('/driver/suggestions/$loadId/reject', data: {'reason': wireName(reason)}));
}

final suggestionsApiProvider = Provider<SuggestionsApi>((ref) => SuggestionsApi(ref.watch(dioProvider)));

class SuggestionSort extends Notifier<String> {
  @override
  String build() => 'NEAREST';

  void set(String s) => state = s;
}

final suggestionSortProvider = NotifierProvider<SuggestionSort, String>(SuggestionSort.new);

final suggestionsProvider = FutureProvider.autoDispose<List<Suggestion>>(
  (ref) => ref.watch(suggestionsApiProvider).list(ref.watch(suggestionSortProvider)),
);

/// DR-03 Trip suggestions: area-only cards, sort, 30 s polling while visible (D-18), accept/reject.
class SuggestionsScreen extends ConsumerStatefulWidget {
  const SuggestionsScreen({super.key});

  @override
  ConsumerState<SuggestionsScreen> createState() => _SuggestionsScreenState();
}

class _SuggestionsScreenState extends ConsumerState<SuggestionsScreen> {
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    _poll = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) ref.invalidate(suggestionsProvider);
    });
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  Future<void> _accept(Suggestion s) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final charge = ref.read(publicSettingsProvider).value?.tripChargeInr ?? 0;
    final ok = await showConfirmSheet(
      context,
      title: l.acceptConfirmTitle,
      message: l.acceptConfirmBody(Fmt.money(s.amountInr), Fmt.money(charge)),
      confirmLabel: l.acceptTrip,
    );
    if (!ok) return;
    try {
      await ref.read(suggestionsApiProvider).accept(s.loadId);
      ref.invalidate(driverHomeProvider);
      messenger.showSnackBar(SnackBar(content: Text(l.tripAccepted)));
      if (mounted) context.go('${Routes.driver}/trip');
    } on AppException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(errorMessage(l, e))));
      ref.invalidate(suggestionsProvider); // LOAD_TAKEN → the card disappears
    }
  }

  Future<void> _reject(Suggestion s) async {
    final l = AppLocalizations.of(context);
    final reason = await showModalBottomSheet<SuggestionRejectReason>(
      context: context,
      showDragHandle: true,
      builder: (c) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l.rejectWhy, style: Theme.of(c).textTheme.titleLarge),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final r in const [SuggestionRejectReason.tooFar, SuggestionRejectReason.lowAmount,
                      SuggestionRejectReason.wrongTruck, SuggestionRejectReason.other])
                    ActionChip(label: Text(_reasonLabel(l, r)), onPressed: () => Navigator.pop(c, r)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (reason == null) return;
    try {
      await ref.read(suggestionsApiProvider).reject(s.loadId, reason);
    } catch (_) {
      // Already gone; refresh below.
    }
    ref.invalidate(suggestionsProvider);
  }

  static String _reasonLabel(AppLocalizations l, SuggestionRejectReason r) => switch (r) {
        SuggestionRejectReason.tooFar => l.rrTooFar,
        SuggestionRejectReason.lowAmount => l.rrLowAmount,
        SuggestionRejectReason.wrongTruck => l.rrWrongTruck,
        _ => l.crOther,
      };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final sort = ref.watch(suggestionSortProvider);
    final home = ref.watch(driverHomeProvider).value;
    final charge = ref.watch(publicSettingsProvider).value?.tripChargeInr;
    final lowBalance = home != null && home.orgName == null && charge != null && (home.walletBalanceInr ?? 0) < charge;
    return Scaffold(
      appBar: AppBar(title: Text(l.navSuggestions), actions: const [NotificationBell(), ProfileAvatarButton()]),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(suggestionsProvider),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (home != null && !home.onDuty)
              BlockingReasonCard(message: l.goOnDutyHint, actionLabel: l.navHome, onAction: () => context.go(Routes.driver)),
            if (lowBalance)
              BlockingReasonCard(
                icon: Icons.account_balance_wallet_outlined,
                message: l.topUpToSeeTrips,
                actionLabel: l.topUp,
                onAction: () => context.push(Routes.wallet),
              ),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'NEAREST', label: Text(l.sortNearest)),
                ButtonSegment(value: 'AMOUNT', label: Text(l.sortAmount)),
                ButtonSegment(value: 'EARLIEST', label: Text(l.sortEarliest)),
              ],
              selected: {sort},
              onSelectionChanged: (s) => ref.read(suggestionSortProvider.notifier).set(s.first),
            ),
            const SizedBox(height: 12),
            AsyncView(
              value: ref.watch(suggestionsProvider),
              onRetry: () => ref.invalidate(suggestionsProvider),
              data: (list) => list.isEmpty
                  ? Padding(padding: const EdgeInsets.all(24), child: Center(child: Text(l.noSuggestions, textAlign: TextAlign.center)))
                  : Column(children: [for (final s in list) _SuggestionCard(s: s, onAccept: () => _accept(s), onReject: () => _reject(s))]),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({required this.s, required this.onAccept, required this.onReject});

  final Suggestion s;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (s.preferredByShipper)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Chip(avatar: const Icon(Icons.favorite, size: 16), label: Text(l.preferredTag)),
              ),
            Row(children: [
              Expanded(child: Text('${s.pickupArea} → ${s.dropArea}', style: t.titleMedium)),
              MoneyText(s.amountInr, large: true),
            ]),
            const SizedBox(height: 4),
            Text('${s.goodsType}${s.description == null ? '' : ' · ${s.description}'}'),
            Text('${s.quantity} ${unitLabel(l, s.unit)} · ${Fmt.tonnes(s.weightTonnes)}'),
            Text('${l.pickupDate}: ${Fmt.dateTime(s.pickupWindowStart)}'),
            Text(l.toPickup(Fmt.km(s.distanceToPickupKm), s.minutesToPickup)),
            if (s.deliveryEta != null) Text('${l.deliveryEstimate}: ${Fmt.dateTime(s.deliveryEta!)}'),
            Row(children: [Text('${l.trustScore}: '), TrustScoreBadge(score: s.shipperTrustScore)]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: OutlinedButton(onPressed: onReject, child: Text(l.rejectTrip))),
              const SizedBox(width: 12),
              Expanded(child: FilledButton(onPressed: onAccept, child: Text(l.acceptTrip))),
            ]),
          ],
        ),
      ),
    );
  }
}
