import 'dart:async';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/errors/error_messages.dart';
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

/// Contract §5.
class WalletApi {
  WalletApi(this._dio);

  final Dio _dio;

  Future<Wallet> wallet() async => Wallet.fromJson((await guardApi(() => _dio.get<Map<String, dynamic>>('/wallet'))).data!);

  Future<Paged<WalletTransaction>> transactions({TxnType? type, String? month, int page = 0}) async {
    final res = await guardApi(() => _dio.get<Map<String, dynamic>>('/wallet/transactions', queryParameters: {
          'type': ?(type == null ? null : _wire(type.name)),
          'month': ?month,
          'page': page,
        }));
    return Paged.fromJson(res.data!, WalletTransaction.fromJson);
  }

  Future<TopupLink> topupLink(int amountInr) async => TopupLink.fromJson(
        (await guardApi(() => _dio.post<Map<String, dynamic>>('/wallet/topup-link', data: {'amountInr': amountInr}))).data!,
      );

  Future<Uint8List> statement(String month) async {
    final res = await guardApi(() => _dio.get<List<int>>(
          '/wallet/statement',
          queryParameters: {'month': month},
          options: Options(responseType: ResponseType.bytes),
        ));
    return Uint8List.fromList(res.data!);
  }

  static String _wire(String name) => name.replaceAllMapped(RegExp('[A-Z]'), (m) => '_${m[0]}').toUpperCase();
}

final walletApiProvider = Provider<WalletApi>((ref) => WalletApi(ref.watch(dioProvider)));

final walletProvider = FutureProvider.autoDispose<Wallet>((ref) => ref.watch(walletApiProvider).wallet());

class TxnFilter {
  const TxnFilter({this.type, this.month});

  final TxnType? type;
  final String? month;

  @override
  bool operator ==(Object other) => other is TxnFilter && other.type == type && other.month == month;

  @override
  int get hashCode => Object.hash(type, month);
}

class TxnFilterController extends Notifier<TxnFilter> {
  @override
  TxnFilter build() => const TxnFilter();

  void set(TxnFilter f) => state = f;
}

final txnFilterProvider = NotifierProvider.autoDispose<TxnFilterController, TxnFilter>(TxnFilterController.new);

final transactionsProvider = FutureProvider.autoDispose<Paged<WalletTransaction>>((ref) {
  final f = ref.watch(txnFilterProvider);
  return ref.watch(walletApiProvider).transactions(type: f.type, month: f.month);
});

String txnLabel(AppLocalizations l, TxnType t) => switch (t) {
      TxnType.topup => l.txnTopup,
      TxnType.postingCharge => l.txnPostingCharge,
      TxnType.tripCharge => l.txnTripCharge,
      TxnType.refund => l.txnRefund,
      TxnType.adminCredit => l.txnAdminCredit,
      TxnType.unknown => l.statusUnknown,
    };

/// S-08 Wallet: balance, charge, low-balance warning, top-up via the external browser (D-13), transactions.
class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  late final AppLifecycleListener _lifecycle;
  bool _awaitingPayment = false;

  @override
  void initState() {
    super.initState();
    // A-302: on return from the browser, refresh and poll GET /wallet 3× every 5 s.
    _lifecycle = AppLifecycleListener(onResume: () {
      if (!_awaitingPayment) return;
      _awaitingPayment = false;
      _refresh();
      for (var i = 1; i <= 3; i++) {
        Future<void>.delayed(Duration(seconds: 5 * i), () {
          if (mounted) _refresh();
        });
      }
    });
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  void _refresh() {
    ref.invalidate(walletProvider);
    ref.invalidate(transactionsProvider);
    ref.invalidate(meProvider);
  }

  Future<void> _topUp(int amount) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final link = await ref.read(walletApiProvider).topupLink(amount);
      _awaitingPayment = true;
      final ok = await launchUrl(Uri.parse(link.url), mode: LaunchMode.externalApplication);
      if (ok) messenger.showSnackBar(SnackBar(content: Text(l.openingPayment)));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(errorMessage(l, e))));
    }
  }

  Future<void> _customAmount() async {
    final l = AppLocalizations.of(context);
    final controller = TextEditingController();
    final amount = await showDialog<int>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l.topUp),
        content: TextField(
          key: const Key('custom-amount'),
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: Inputs.amount(),
          decoration: InputDecoration(labelText: l.otherAmount),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: Text(l.actionCancel)),
          FilledButton(onPressed: () => Navigator.pop(c, int.tryParse(controller.text)), child: Text(l.actionContinue)),
        ],
      ),
    );
    controller.dispose();
    if (amount != null && amount > 0) await _topUp(amount);
  }

  Future<void> _statement() async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final month = ref.read(txnFilterProvider).month ?? _monthKey(DateTime.now());
    try {
      final bytes = await ref.read(walletApiProvider).statement(month);
      final saved = await FilePicker.saveFile(fileName: 'tranix-statement-$month.pdf', bytes: bytes, mimeType: 'application/pdf');
      if (saved != null) messenger.showSnackBar(SnackBar(content: Text(l.statementSaved)));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(errorMessage(l, e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final wallet = ref.watch(walletProvider);
    final chips = ref.watch(publicSettingsProvider).value?.topupChips ?? const [500, 1000, 2000];
    return Scaffold(
      appBar: AppBar(
        title: Text(l.wallet),
        actions: [IconButton(tooltip: l.downloadStatement, icon: const Icon(Icons.download), onPressed: _statement)],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refresh(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AsyncView(
              value: wallet,
              onRetry: _refresh,
              data: (w) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.walletBalance),
                      MoneyText(w.balanceInr, large: true),
                      const SizedBox(height: 4),
                      Text('${l.postingChargeIs(w.postingChargeInr)} · ${l.tripChargeIs(w.tripChargeInr)}'),
                      if (w.lowBalance) ...[
                        const SizedBox(height: 8),
                        Row(children: [
                          Icon(Icons.warning_amber, color: context.statusColors.warning),
                          const SizedBox(width: 8),
                          Expanded(child: Text(l.lowBalanceWarning)),
                        ]),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(l.topUp, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final amount in chips)
                  ActionChip(key: Key('chip-$amount'), label: Text(Fmt.money(amount)), onPressed: () => _topUp(amount)),
                ActionChip(avatar: const Icon(Icons.edit, size: 18), label: Text(l.otherAmount), onPressed: _customAmount),
              ],
            ),
            const SizedBox(height: 24),
            Text(l.transactions, style: Theme.of(context).textTheme.titleMedium),
            const _Filters(),
            const _TransactionsList(),
          ],
        ),
      ),
    );
  }
}

String _monthKey(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}';

class _Filters extends ConsumerWidget {
  const _Filters();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(txnFilterProvider);
    final now = DateTime.now();
    final months = [for (var i = 0; i < 6; i++) _monthKey(DateTime(now.year, now.month - i))];
    return Row(
      children: [
        Expanded(
          child: DropdownButton<TxnType?>(
            isExpanded: true,
            value: f.type,
            items: [
              DropdownMenuItem(value: null, child: Text(l.allTypes)),
              for (final t in TxnType.values.where((t) => t != TxnType.unknown))
                DropdownMenuItem(value: t, child: Text(txnLabel(l, t))),
            ],
            onChanged: (t) => ref.read(txnFilterProvider.notifier).set(TxnFilter(type: t, month: f.month)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButton<String?>(
            isExpanded: true,
            value: f.month,
            hint: Text(l.month),
            items: [
              DropdownMenuItem(value: null, child: Text(l.allTypes)),
              for (final m in months) DropdownMenuItem(value: m, child: Text(m)),
            ],
            onChanged: (m) => ref.read(txnFilterProvider.notifier).set(TxnFilter(type: f.type, month: m)),
          ),
        ),
      ],
    );
  }
}

class _TransactionsList extends ConsumerWidget {
  const _TransactionsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final txns = ref.watch(transactionsProvider);
    final c = context.statusColors;
    return AsyncView(
      value: txns,
      onRetry: () => ref.invalidate(transactionsProvider),
      data: (page) => page.items.isEmpty
          ? Padding(padding: const EdgeInsets.all(24), child: Center(child: Text(l.noTransactions)))
          : Column(
              children: [
                for (final t in page.items)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(txnLabel(l, t.type)),
                    subtitle: Text('${t.txnId} · ${Fmt.dateTime(t.at)}'),
                    trailing: Text(
                      '${t.direction == TxnDirection.credit ? '+' : '−'}${Fmt.money(t.amountInr)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: t.direction == TxnDirection.credit ? c.success : c.error,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
