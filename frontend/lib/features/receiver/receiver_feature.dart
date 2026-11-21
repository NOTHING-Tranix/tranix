import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/errors/error_messages.dart';
import '../../core/files/file_picking.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/network/interceptors.dart';
import '../../core/providers.dart';
import '../../core/router/routes.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';
import '../../shared/labels.dart';
import '../../shared/models/models.dart';
import '../notifications/notifications_feature.dart';
import '../payments/payments_feature.dart';
import '../shared_shell/tab_screens.dart';
import '../shipper/presentation/shipper_screens.dart' show DriverBlock, OtpCodeCard, StatusChipText, TrackingCard;

/// `GET /receiver/loads/{id}`: LoadDetail + receipt.
class ReceiverLoad {
  ReceiverLoad(this.detail, this.receipt, this.canSubmitReceipt);

  factory ReceiverLoad.fromJson(Map<String, dynamic> j) =>
      ReceiverLoad(LoadDetail.fromJson(j), j['receipt'] as Map<String, dynamic>?, j['canSubmitReceipt'] as bool? ?? false);

  final LoadDetail detail;
  final Map<String, dynamic>? receipt;
  final bool canSubmitReceipt;
}

/// Contract §10 (registered receiver).
class ReceiverApi {
  ReceiverApi(this._dio);

  final Dio _dio;

  Dio get dio => _dio;

  Future<List<Map<String, dynamic>>> loads({required bool ongoing}) async => [
        for (final e in (await guardApi(() => _dio.get<List<dynamic>>('/receiver/loads',
                queryParameters: {'scope': ongoing ? 'ONGOING' : 'HISTORY'})))
            .data!)
          e as Map<String, dynamic>,
      ];

  Future<ReceiverLoad> detail(String id) async =>
      ReceiverLoad.fromJson((await guardApi(() => _dio.get<Map<String, dynamic>>('/receiver/loads/$id'))).data!);

  Future<void> receipt(String id, List<String> fileIds, String condition, String? remarks) => guardApi(() => _dio.post<void>(
      '/receiver/loads/$id/receipt',
      data: {'fileIds': fileIds, 'condition': condition, 'remarks': ?remarks}));
}

final receiverApiProvider = Provider<ReceiverApi>((ref) => ReceiverApi(ref.watch(dioProvider)));
final receiverLoadsProvider =
    FutureProvider.autoDispose.family<List<Map<String, dynamic>>, bool>((ref, ongoing) => ref.watch(receiverApiProvider).loads(ongoing: ongoing));
final receiverLoadProvider = FutureProvider.autoDispose.family<ReceiverLoad, String>((ref, id) => ref.watch(receiverApiProvider).detail(id));

/// RC-01 incoming loads (ongoing) / history.
class ReceiverLoadsScreen extends ConsumerWidget {
  const ReceiverLoadsScreen({super.key, required this.ongoing});

  final bool ongoing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(ongoing ? l.incomingLoads : l.navHistory), actions: const [NotificationBell(), ProfileAvatarButton()]),
      body: AsyncView(
        value: ref.watch(receiverLoadsProvider(ongoing)),
        onRetry: () => ref.invalidate(receiverLoadsProvider(ongoing)),
        data: (list) => list.isEmpty
            ? EmptyState(icon: Icons.inventory_2_outlined, message: ongoing ? l.noIncomingLoads : l.noLoads)
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(receiverLoadsProvider(ongoing)),
                child: ListView(padding: const EdgeInsets.all(16), children: [
                  for (final m in list)
                    Builder(builder: (context) {
                      final s = LoadSummary.fromJson(m);
                      final eta = DateTime.tryParse('${m['deliveryEta']}');
                      return Card(
                        child: ListTile(
                          title: Text(s.code),
                          subtitle: Text([
                            '${s.goodsType} · ${s.quantity} ${unitLabel(l, s.quantityUnit)}',
                            '${s.pickupArea} → ${s.dropArea}',
                            if (eta != null && ongoing) l.expectedDelivery(Fmt.dateTime(eta)),
                          ].join('\n')),
                          isThreeLine: true,
                          trailing: StatusChip.load(context, s.status),
                          onTap: () => context.push(Routes.receiverLoad(s.id)),
                        ),
                      );
                    }),
                ]),
              ),
      ),
    );
  }
}

/// RC-02 load detail: timeline, driver, live tracking, delivery OTP card, receipt, payment (if the receiver pays).
class ReceiverLoadScreen extends ConsumerWidget {
  const ReceiverLoadScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final value = ref.watch(receiverLoadProvider(id));
    return Scaffold(
      appBar: AppBar(title: Text(value.value?.detail.code ?? l.loadDetails)),
      body: AsyncView(
        value: value,
        onRetry: () => ref.invalidate(receiverLoadProvider(id)),
        data: (r) {
          final d = r.detail;
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(receiverLoadProvider(id)),
            child: ListView(padding: const EdgeInsets.all(16), children: [
              Row(children: [Expanded(child: Text(d.code, style: Theme.of(context).textTheme.titleLarge)), StatusChip.load(context, d.status)]),
              Text('${d.goodsType} · ${d.quantity} ${unitLabel(l, d.quantityUnit)}'),
              Text('${l.sender}: ${d.senderName}'),
              if (d.driver != null) DriverBlock(driver: d.driver!),
              if (d.status == LoadStatus.arrivedDestination)
                OtpCodeCard(loadId: d.id, title: l.deliveryOtpTitle, hint: l.shareAfterChecking),
              if (d.driver != null && d.status != LoadStatus.delivered && d.status != LoadStatus.cancelled) TrackingCard(loadId: d.id),
              if (d.payment != null) PaymentCard(load: d),
              if (r.receipt != null)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.receipt_long),
                    title: Text(l.receiptTitle),
                    subtitle: Text([
                      r.receipt!['condition'] == 'FULL' ? l.conditionFull : l.conditionDamage,
                      if (r.receipt!['remarks'] != null) '${r.receipt!['remarks']}',
                    ].join(' · ')),
                  ),
                ),
              if (r.canSubmitReceipt) _ReceiptForm(loadId: d.id),
              const Divider(),
              Text(l.timeline, style: Theme.of(context).textTheme.titleMedium),
              for (final t in d.timeline)
                ListTile(dense: true, contentPadding: EdgeInsets.zero, leading: const Icon(Icons.circle, size: 10),
                    title: StatusChipText(status: t.status), trailing: Text(Fmt.dateTime(t.at))),
            ]),
          );
        },
      ),
    );
  }
}

class _ReceiptForm extends ConsumerStatefulWidget {
  const _ReceiptForm({required this.loadId});

  final String loadId;

  @override
  ConsumerState<_ReceiptForm> createState() => _ReceiptFormState();
}

class _ReceiptFormState extends ConsumerState<_ReceiptForm> {
  final _photos = <PickedUpload>[];
  String _condition = 'FULL';
  final _remarks = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _remarks.dispose();
    super.dispose();
  }

  Future<void> _add(PickSource source) async {
    final f = await const FilePicking().pick(source);
    if (f != null && mounted) setState(() => _photos.add(f));
  }

  Future<void> _submit() async {
    final l = AppLocalizations.of(context);
    if (_condition == 'SHORTAGE_DAMAGE' && _remarks.text.trim().isEmpty) {
      setState(() => _error = l.remarksRequired);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final messenger = ScaffoldMessenger.of(context);
    try {
      final api = ref.read(receiverApiProvider);
      final ids = <String>[for (final p in _photos) await uploadFile(api.dio, p)];
      await api.receipt(widget.loadId, ids, _condition, _remarks.text.trim().isEmpty ? null : _remarks.text.trim());
      ref.invalidate(receiverLoadProvider(widget.loadId));
      messenger.showSnackBar(SnackBar(content: Text(l.receiptSent)));
    } catch (e) {
      if (mounted) setState(() => _error = errorMessage(l, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(l.receiptTitle, style: Theme.of(context).textTheme.titleMedium),
          Text(l.receiptPhotos),
          Wrap(spacing: 8, children: [
            for (var i = 0; i < _photos.length; i++)
              InputChip(label: Text(_photos[i].name), onDeleted: () => setState(() => _photos.removeAt(i))),
          ]),
          if (_photos.length < 5)
            Row(children: [
              Expanded(child: OutlinedButton.icon(onPressed: () => _add(PickSource.camera), icon: const Icon(Icons.photo_camera), label: Text(l.camera))),
              const SizedBox(width: 8),
              Expanded(child: OutlinedButton.icon(onPressed: () => _add(PickSource.gallery), icon: const Icon(Icons.photo), label: Text(l.gallery))),
            ]),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'FULL', label: Text(l.conditionFull)),
              ButtonSegment(value: 'SHORTAGE_DAMAGE', label: Text(l.conditionDamage)),
            ],
            selected: {_condition},
            onSelectionChanged: (s) => setState(() => _condition = s.first),
          ),
          TextField(key: const Key('receipt-remarks'), controller: _remarks, maxLength: 500, decoration: InputDecoration(labelText: l.remarksLabel)),
          if (_error != null) Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          PrimaryButton(label: l.submitAction, loading: _busy, onPressed: _photos.isEmpty ? null : _submit),
        ]),
      ),
    );
  }
}
