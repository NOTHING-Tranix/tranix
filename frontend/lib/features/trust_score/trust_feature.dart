import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/network/interceptors.dart';
import '../../core/providers.dart';
import '../../core/settings_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/field_limits.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';
import '../../shared/models/models.dart';
import '../profile/application/profile_providers.dart';

/// Contract §11 (ratings, Trust Score).
class TrustApi {
  TrustApi(this._dio);

  final Dio _dio;

  Future<TrustScore> score() async => TrustScore.fromJson((await guardApi(() => _dio.get<Map<String, dynamic>>('/trust-score'))).data!);

  Future<Paged<TrustEvent>> events({int page = 0}) async => Paged.fromJson(
    (await guardApi(() => _dio.get<Map<String, dynamic>>('/trust-score/events', queryParameters: {'page': page}))).data!,
    TrustEvent.fromJson,
  );

  Future<List<PendingRating>> pending() async {
    final res = await guardApi(() => _dio.get<List<dynamic>>('/ratings/pending'));
    return res.data!.map((e) => PendingRating.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> rate(PendingRating p, int stars, List<String> tags, String? comment) => guardApi(
    () => _dio.post<void>(
      '/ratings',
      data: {'loadId': p.loadId, 'rateeUserId': p.rateeUserId, 'stars': stars, 'tags': tags, 'comment': ?comment},
    ),
  );

  Future<void> later(String loadId) => guardApi(() => _dio.post<void>('/ratings/$loadId/later'));
}

final trustApiProvider = Provider<TrustApi>((ref) => TrustApi(ref.watch(dioProvider)));
final trustScoreProvider = FutureProvider.autoDispose<TrustScore>((ref) => ref.watch(trustApiProvider).score());
final trustEventsProvider = FutureProvider.autoDispose<Paged<TrustEvent>>((ref) => ref.watch(trustApiProvider).events());

String trustEventLabel(AppLocalizations l, String event) => switch (event) {
  'ON_TIME' => l.evOnTime,
  'LATE_DELIVERY' => l.evLateDelivery,
  'LATE_PICKUP' => l.evLatePickup,
  'CANCELLED_OWN_FAULT' => l.evCancelled,
  'RATING' => l.evRating,
  'PAYMENT_ON_TIME' => l.evPaymentOnTime,
  'DISPUTE_LOST' => l.evDisputeLost,
  'ADMIN_ADJUSTMENT' => l.evAdmin,
  'VERIFIED_COMPLAINT' => l.evComplaint,
  'DRIVER_CANCELLED' => l.evDriverCancelled,
  _ => event,
};

/// S-12 Trust Score: score, small trend, events, "How it works".
class TrustScoreScreen extends ConsumerWidget {
  const TrustScoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.statusColors;
    return Scaffold(
      appBar: AppBar(title: Text(l.trustScore)),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(trustScoreProvider);
          ref.invalidate(trustEventsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AsyncView(
              value: ref.watch(trustScoreProvider),
              onRetry: () => ref.invalidate(trustScoreProvider),
              data: (s) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        s.score.toStringAsFixed(s.score % 1 == 0 ? 0 : 1),
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (s.updatedAt != null) Text(Fmt.dateTime(s.updatedAt!)),
                      if (s.trend.length > 1) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 48,
                          child: CustomPaint(size: Size.infinite, painter: _TrendPainter(s.trend, Theme.of(context).colorScheme.primary)),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            ExpansionTile(
              title: Text(l.howItWorks),
              children: [Padding(padding: const EdgeInsets.all(16), child: Text(l.trustHowBody))],
            ),
            AsyncView(
              value: ref.watch(trustEventsProvider),
              onRetry: () => ref.invalidate(trustEventsProvider),
              data: (page) => page.items.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(child: Text(l.noEvents)),
                    )
                  : Column(
                      children: [
                        for (final e in page.items)
                          ListTile(
                            title: Text(trustEventLabel(l, e.event)),
                            subtitle: Text('${Fmt.dateTime(e.at)} · ${e.reason}'),
                            trailing: Text(
                              '${e.points > 0 ? '+' : ''}${e.points % 1 == 0 ? e.points.toInt() : e.points}',
                              style: TextStyle(fontWeight: FontWeight.bold, color: e.points >= 0 ? c.success : c.error),
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  _TrendPainter(this.values, this.color);

  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final minV = values.reduce((a, b) => a < b ? a : b) - 1;
    final maxV = values.reduce((a, b) => a > b ? a : b) + 1;
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = size.width * i / (values.length - 1);
      final y = size.height - (values[i] - minV) / (maxV - minV) * size.height;
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(_TrendPainter old) => old.values != values;
}

/// S-11 rating pop-up on app open: one dialog per pending rating; "Later" once.
Future<void> showPendingRatings(BuildContext context, WidgetRef ref) async {
  final api = ref.read(trustApiProvider);
  List<PendingRating> pending;
  try {
    pending = await api.pending();
  } catch (_) {
    return;
  }
  List<String> tags;
  try {
    tags = (await ref.read(publicSettingsProvider.future)).ratingTags;
  } catch (_) {
    tags = const [];
  }
  for (final p in pending) {
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _RatingDialog(pending: p, tags: tags),
    );
  }
  ref.invalidate(meProvider);
}


class _RatingDialog extends ConsumerStatefulWidget {
  const _RatingDialog({required this.pending, required this.tags});

  final PendingRating pending;
  final List<String> tags;

  @override
  ConsumerState<_RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends ConsumerState<_RatingDialog> {
  int _stars = 0;
  final _selected = <String>{};
  final _comment = TextEditingController();

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final api = ref.read(trustApiProvider);
    return AlertDialog(
      title: Text(l.rateTitle(widget.pending.rateeName)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.pending.loadCode != null) Text(widget.pending.loadCode!),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 1; i <= 5; i++)
                  IconButton(
                    key: Key('star-$i'),
                    tooltip: '$i',
                    icon: Icon(i <= _stars ? Icons.star : Icons.star_border, color: TranixColors.amber, size: 36),
                    onPressed: () => setState(() => _stars = i),
                  ),
              ],
            ),
            Wrap(
              spacing: 6,
              children: [
                for (final t in widget.tags)
                  FilterChip(
                    label: Text(t),
                    selected: _selected.contains(t),
                    onSelected: (on) => setState(() => on ? _selected.add(t) : _selected.remove(t)),
                  ),
              ],
            ),
            TextField(
              controller: _comment,
              inputFormatters: Inputs.text(FieldLimits.note),
              decoration: InputDecoration(labelText: l.commentOptional),
            ),
          ],
        ),
      ),
      actions: [
        if (!widget.pending.laterUsed)
          TextButton(
            onPressed: () async {
              try {
                await api.later(widget.pending.loadId);
              } catch (_) {}
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(l.rateLater),
          ),
        FilledButton(
          onPressed: _stars == 0
              ? null
              : () async {
                  try {
                    await api.rate(widget.pending, _stars, _selected.toList(), _comment.text.trim().isEmpty ? null : _comment.text.trim());
                  } catch (_) {}
                  if (context.mounted) Navigator.pop(context);
                },
          child: Text(l.submitAction),
        ),
      ],
    );
  }
}
