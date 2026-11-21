import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/errors/error_messages.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/network/interceptors.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';
import '../../shared/labels.dart';
import '../../shared/models/models.dart';
import '../notifications/notifications_feature.dart';
import '../shared_shell/tab_screens.dart';
import '../shipper/data/loads_api.dart';

/// Contract §6/§8 payments (record only — Tranix never holds the money).
class PaymentsApi {
  PaymentsApi(this._dio);

  final Dio _dio;

  Future<LoadPayment> markPaid(String loadId, int amountInr, PaymentMode mode, String? reference) async => LoadPayment.fromJson(
    (await guardApi(
      () => _dio.post<Map<String, dynamic>>(
        '/loads/$loadId/payment/mark-paid',
        data: {'amountInr': amountInr, 'mode': wireName(mode), 'reference': ?reference},
      ),
    )).data!,
  );

  Future<void> confirm(String loadId, int amountInr) =>
      guardApi(() => _dio.post<void>('/driver/trips/$loadId/payment/confirm', data: {'amountInr': amountInr}));

  Future<void> dispute(String loadId, String reason) =>
      guardApi(() => _dio.post<void>('/driver/trips/$loadId/payment/dispute', data: {'reason': reason}));

  Future<DriverHistory> driverHistory(String month) async => DriverHistory.fromJson(
    (await guardApi(() => _dio.get<Map<String, dynamic>>('/driver/history', queryParameters: {'month': month}))).data!,
  );
}

/// `GET /driver/history` (summary + LoadSummary items).
class DriverHistory {
  DriverHistory({
    required this.trips,
    required this.agreedTotalInr,
    required this.confirmedInr,
    required this.pendingInr,
    required this.items,
  });

  factory DriverHistory.fromJson(Map<String, dynamic> j) {
    final s = j['summary'] as Map<String, dynamic>;
    return DriverHistory(
      trips: (s['trips'] as num).toInt(),
      agreedTotalInr: (s['agreedTotalInr'] as num).toInt(),
      confirmedInr: (s['confirmedInr'] as num).toInt(),
      pendingInr: (s['pendingInr'] as num).toInt(),
      items: [for (final e in j['items'] as List<dynamic>) LoadSummary.fromJson(e as Map<String, dynamic>)],
    );
  }

  final int trips;
  final int agreedTotalInr;
  final int confirmedInr;
  final int pendingInr;
  final List<LoadSummary> items;
}

final paymentsApiProvider = Provider<PaymentsApi>((ref) => PaymentsApi(ref.watch(dioProvider)));

String monthKey(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}';

final driverHistoryProvider = FutureProvider.autoDispose.family<DriverHistory, String>(
  (ref, month) => ref.watch(paymentsApiProvider).driverHistory(month),
);

String paymentModeLabel(AppLocalizations l, PaymentMode? m) => switch (m) {
  PaymentMode.cash => l.modeCash,
  PaymentMode.upi => l.modeUpi,
  PaymentMode.bank => l.modeBank,
  _ => '',
};

/// A-407: payment section on the shipper's load detail (status, details, "Mark as paid").
class PaymentCard extends ConsumerWidget {
  const PaymentCard({super.key, required this.load});

  final LoadDetail load;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final p = load.payment!;
    final canMark =
        (p.status == PaymentStatus.pending || p.status == PaymentStatus.disputed) &&
        (load.status == LoadStatus.pickedUp ||
            load.status == LoadStatus.traveling ||
            load.status == LoadStatus.delivered ||
            load.status == LoadStatus.arrivedDestination);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(l.paymentSection, style: Theme.of(context).textTheme.titleMedium)),
                StatusChip.payment(context, p.status),
              ],
            ),
            if (p.amountInr != null && p.mode != null) Text(l.paidVia(Fmt.money(p.amountInr!), paymentModeLabel(l, p.mode))),
            if (p.reference != null) Text(p.reference!),
            if (p.paidAt != null) Text(Fmt.dateTime(p.paidAt!)),
            if (p.disputeReason != null) Text(p.disputeReason!, style: TextStyle(color: context.statusColors.error)),
            if (canMark) ...[const SizedBox(height: 8), PrimaryButton(label: l.markPaid, onPressed: () => _markPaid(context, ref))],
          ],
        ),
      ),
    );
  }

  Future<void> _markPaid(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    var amountText = '${load.agreedAmountInr}';
    var referenceText = '';
    var mode = PaymentMode.upi;
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (c) => StatefulBuilder(
        builder: (c, setState) => SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + MediaQuery.of(c).viewInsets.bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l.markPaid, style: Theme.of(c).textTheme.titleLarge),
                TextFormField(
                  key: const Key('pay-amount'),
                  initialValue: amountText,
                  onChanged: (v) => amountText = v,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: l.amountInr),
                ),
                const SizedBox(height: 8),
                Text(l.paymentMode),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final m in const [PaymentMode.cash, PaymentMode.upi, PaymentMode.bank])
                      ChoiceChip(label: Text(paymentModeLabel(l, m)), selected: mode == m, onSelected: (_) => setState(() => mode = m)),
                  ],
                ),
                TextFormField(
                  onChanged: (v) => referenceText = v,
                  decoration: InputDecoration(labelText: l.referenceOptional),
                ),
                const SizedBox(height: 16),
                PrimaryButton(label: l.markPaid, onPressed: () => Navigator.pop(c, true)),
              ],
            ),
          ),
        ),
      ),
    );
    final value = int.tryParse(amountText.trim());
    final ref0 = referenceText.trim();
    if (ok != true) return;
    try {
      if (value == null || value <= 0) throw StateError(l.amountInvalid);
      await ref.read(paymentsApiProvider).markPaid(load.id, value, mode, ref0.isEmpty ? null : ref0);
      ref.invalidate(loadDetailProvider(load.id));
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e is StateError ? e.message : errorMessage(l, e))));
      }
    }
  }
}

/// A-510: driver history — month summary + trips with payment confirm/dispute.
class DriverHistoryScreen extends ConsumerStatefulWidget {
  const DriverHistoryScreen({super.key});

  @override
  ConsumerState<DriverHistoryScreen> createState() => _DriverHistoryScreenState();
}

class _DriverHistoryScreenState extends ConsumerState<DriverHistoryScreen> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final key = monthKey(_month);
    final now = DateTime.now();
    final isCurrent = _month.year == now.year && _month.month == now.month;
    return Scaffold(
      appBar: AppBar(title: Text(l.navHistory), actions: const [NotificationBell(), ProfileAvatarButton()]),
      body: AsyncView(
        value: ref.watch(driverHistoryProvider(key)),
        onRetry: () => ref.invalidate(driverHistoryProvider(key)),
        data: (h) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(driverHistoryProvider(key)),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    tooltip: '<',
                    onPressed: () => setState(() => _month = DateTime(_month.year, _month.month - 1)),
                  ),
                  Expanded(
                    child: Text(isCurrent ? l.thisMonth : key, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    tooltip: '>',
                    onPressed: isCurrent ? null : () => setState(() => _month = DateTime(_month.year, _month.month + 1)),
                  ),
                ],
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.tripsCount(h.trips), style: Theme.of(context).textTheme.titleMedium),
                      _row(l.agreedTotal, h.agreedTotalInr),
                      _row(l.receivedTotal, h.confirmedInr),
                      _row(l.pendingTotal, h.pendingInr),
                    ],
                  ),
                ),
              ),
              if (h.items.isEmpty) EmptyState(message: l.noLoads, icon: Icons.history),
              for (final t in h.items) _HistoryTile(trip: t, month: key),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, int amount) => Row(
    children: [
      Expanded(child: Text(label)),
      MoneyText(amount),
    ],
  );
}

class _HistoryTile extends ConsumerWidget {
  const _HistoryTile({required this.trip, required this.month});

  final LoadSummary trip;
  final String month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final paid = trip.paymentStatus == PaymentStatus.paid;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(trip.code, style: Theme.of(context).textTheme.titleSmall)),
                if (trip.paymentStatus != null) StatusChip.payment(context, trip.paymentStatus!) else StatusChip.load(context, trip.status),
              ],
            ),
            Text('${trip.pickupArea} → ${trip.dropArea}'),
            Row(
              children: [
                Expanded(child: Text(Fmt.dateOnly(trip.pickupWindowStart))),
                MoneyText(trip.agreedAmountInr),
              ],
            ),
            if (paid)
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                children: [
                  TextButton(onPressed: () => _dispute(context, ref), child: Text(l.disputePayment)),
                  FilledButton(onPressed: () => _confirm(context, ref), child: Text(l.confirmReceived)),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirm(BuildContext context, WidgetRef ref) =>
      _run(context, ref, () => ref.read(paymentsApiProvider).confirm(trip.id, trip.agreedAmountInr));

  Future<void> _dispute(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    var reasonText = '';
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l.disputePayment),
        content: TextField(
          key: const Key('dispute-reason'),
          onChanged: (v) => reasonText = v,
          decoration: InputDecoration(labelText: l.disputeReason),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(MaterialLocalizations.of(c).cancelButtonLabel)),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(l.submitAction)),
        ],
      ),
    );
    final text = reasonText.trim();
    if (ok != true || text.isEmpty || !context.mounted) return;
    await _run(context, ref, () => ref.read(paymentsApiProvider).dispute(trip.id, text));
  }

  Future<void> _run(BuildContext context, WidgetRef ref, Future<void> Function() action) async {
    final l = AppLocalizations.of(context);
    try {
      await action();
      ref.invalidate(driverHistoryProvider(month));
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage(l, e))));
    }
  }
}
