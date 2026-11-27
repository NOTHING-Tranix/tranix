import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/errors/app_exception.dart';
import '../../core/errors/error_messages.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/network/interceptors.dart';
import '../../core/providers.dart';
import '../../core/router/routes.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/field_limits.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/widgets.dart';
import '../../shared/labels.dart';
import '../../shared/models/models.dart';
import '../driver/driver_feature.dart' show truckStatusLabel;
import '../profile/presentation/labels.dart' show docTypeLabel, documentChip;
import '../notifications/notifications_feature.dart';
import '../shared_shell/tab_screens.dart';
import '../shipper/presentation/shipper_screens.dart' show LoadCard;

/// Contract §9 — Organization.
class OrgApi {
  OrgApi(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> dashboard() async => (await guardApi(() => _dio.get<Map<String, dynamic>>('/org/dashboard'))).data!;

  Future<List<Truck>> trucks() async =>
      [for (final e in (await guardApi(() => _dio.get<List<dynamic>>('/org/trucks'))).data!) Truck.fromJson(e as Map<String, dynamic>)];

  Future<Truck> saveTruck(String? id, String number, VehicleType type, num capacity) async {
    final body = {'number': number, 'vehicleType': wireName(type), 'capacityTonnes': capacity};
    return Truck.fromJson((await guardApi(() => id == null
            ? _dio.post<Map<String, dynamic>>('/org/trucks', data: body)
            : _dio.put<Map<String, dynamic>>('/org/trucks/$id', data: body)))
        .data!);
  }

  Future<void> deactivateTruck(String id) => guardApi(() => _dio.post<void>('/org/trucks/$id/deactivate'));

  Future<Map<String, dynamic>> truckLocation(String id) async =>
      (await guardApi(() => _dio.get<Map<String, dynamic>>('/org/trucks/$id/location'))).data!;

  Future<List<Map<String, dynamic>>> drivers() async =>
      [for (final e in (await guardApi(() => _dio.get<List<dynamic>>('/org/drivers'))).data!) e as Map<String, dynamic>];

  Future<void> invite(String name, String mobile) => guardApi(() => _dio.post<void>('/org/drivers', data: {'name': name, 'mobile': mobile}));

  Future<Map<String, dynamic>> performance(String driverId) async =>
      (await guardApi(() => _dio.get<Map<String, dynamic>>('/org/drivers/$driverId/performance'))).data!;

  Future<List<Map<String, dynamic>>> allocations() async =>
      [for (final e in (await guardApi(() => _dio.get<List<dynamic>>('/org/allocations'))).data!) e as Map<String, dynamic>];

  Future<void> allocate(String driverId, String truckId) =>
      guardApi(() => _dio.post<void>('/org/allocations', data: {'driverId': driverId, 'truckId': truckId}));

  Future<void> setAllocationStatus(String id, String status) => guardApi(() => _dio.put<void>('/org/allocations/$id', data: {'status': status}));

  Future<void> removeAllocation(String id) => guardApi(() => _dio.delete<void>('/org/allocations/$id'));

  Map<String, dynamic> _tripQuery(String? by, String? id) => {'by': ?by, 'id': ?id};

  Future<List<LoadSummary>> trips({String? by, String? id}) async => [
        for (final e in (await guardApi(() => _dio.get<List<dynamic>>('/org/trips', queryParameters: _tripQuery(by, id)))).data!)
          LoadSummary.fromJson(e as Map<String, dynamic>),
      ];

  Future<Uint8List> exportCsv({String? by, String? id}) async => Uint8List.fromList((await guardApi(() => _dio.get<List<int>>(
          '/org/trips/export',
          queryParameters: _tripQuery(by, id),
          options: Options(responseType: ResponseType.bytes))))
      .data!);
}

final orgApiProvider = Provider<OrgApi>((ref) => OrgApi(ref.watch(dioProvider)));
final orgDashboardProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) => ref.watch(orgApiProvider).dashboard());
final orgTrucksProvider = FutureProvider.autoDispose<List<Truck>>((ref) => ref.watch(orgApiProvider).trucks());
final orgDriversProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) => ref.watch(orgApiProvider).drivers());
final orgAllocationsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) => ref.watch(orgApiProvider).allocations());
final orgTripsProvider = FutureProvider.autoDispose.family<List<LoadSummary>, (String?, String?)>(
    (ref, k) => ref.watch(orgApiProvider).trips(by: k.$1, id: k.$2));

void _refreshFleet(WidgetRef ref) {
  ref.invalidate(orgTrucksProvider);
  ref.invalidate(orgDriversProvider);
  ref.invalidate(orgAllocationsProvider);
  ref.invalidate(orgDashboardProvider);
}

Future<bool> _run(BuildContext context, Future<void> Function() action) async {
  final l = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  try {
    await action();
    return true;
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(errorMessage(l, e))));
    return false;
  }
}

AppBar _bar(String title) => AppBar(title: Text(title), actions: const [NotificationBell(), ProfileAvatarButton()]);

// ---------------------------------------------------------------- OR-01 dashboard (A-801)

class OrgDashboardScreen extends ConsumerWidget {
  const OrgDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: _bar(l.navDashboard),
      body: AsyncView(
        value: ref.watch(orgDashboardProvider),
        onRetry: () => ref.invalidate(orgDashboardProvider),
        data: (d) {
          final trucks = (d['trucks'] as Map?) ?? const {};
          final drivers = (d['drivers'] as Map?) ?? const {};
          int n(Object? v) => (v as num?)?.toInt() ?? 0;
          Widget stat(String label, Object? value, IconData icon) => Card(
                child: ListTile(leading: Icon(icon), title: Text(label), trailing: Text('${n(value)}', style: Theme.of(context).textTheme.titleLarge)),
              );
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(orgDashboardProvider),
            child: ListView(padding: const EdgeInsets.all(16), children: [
              const HomeNotificationCards(),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.account_balance_wallet_outlined),
                  title: Text(l.walletBalance),
                  subtitle: MoneyText(n(d['walletBalanceInr']), large: true),
                  trailing: TileAction(child: FilledButton.tonal(onPressed: () => context.push(Routes.wallet), child: Text(l.topUp))),
                ),
              ),
              stat(l.activeTrips, d['activeTrips'], Icons.route),
              stat(l.shippersPreferYou, d['preferredByShippersCount'], Icons.favorite),
              Text(l.navTrucks, style: Theme.of(context).textTheme.titleMedium),
              Wrap(spacing: 8, runSpacing: 8, children: [
                Chip(label: Text('${n(trucks['total'])} ${l.navTrucks}')),
                Chip(label: Text('${n(trucks['onTrip'])} ${l.truckOnTrip}')),
                Chip(label: Text('${n(trucks['idle'])} ${l.idleLabel}')),
                Chip(label: Text('${n(trucks['documentsPending'])} ${l.truckDocumentsPending}')),
                Chip(label: Text('${n(trucks['documentsExpiring'])} ${l.docsExpiringSoon}')),
              ]),
              const SizedBox(height: 12),
              Text(l.navDrivers, style: Theme.of(context).textTheme.titleMedium),
              Wrap(spacing: 8, runSpacing: 8, children: [
                Chip(label: Text('${n(drivers['total'])} ${l.navDrivers}')),
                Chip(label: Text('${n(drivers['onDuty'])} ${l.onDuty}')),
                Chip(label: Text('${n(drivers['onTrip'])} ${l.truckOnTrip}')),
                Chip(label: Text('${n(drivers['unallocated'])} ${l.notAllocated}')),
              ]),
            ]),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------- OR-02 trucks (A-802)

class OrgTrucksScreen extends ConsumerWidget {
  const OrgTrucksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: _bar(l.navTrucks),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showTruckForm(context, ref, null),
        icon: const Icon(Icons.add),
        label: Text(l.addOrgTruck),
      ),
      body: AsyncView(
        value: ref.watch(orgTrucksProvider),
        onRetry: () => ref.invalidate(orgTrucksProvider),
        data: (list) => list.isEmpty
            ? EmptyState(icon: Icons.local_shipping_outlined, message: l.noTrucksYet)
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(orgTrucksProvider),
                child: ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 88), children: [
                  for (final t in list)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.local_shipping_outlined),
                        title: Text(t.number),
                        subtitle: Text([
                          vehicleLabel(l, t.vehicleType),
                          Fmt.tonnes(t.capacityTonnes),
                          (t.allocatedDriver?['name'] as String?) ?? l.notAllocated,
                        ].join(' · ')),
                        trailing: TileAction(maxWidth: 120, child: Text(truckStatusLabel(l, t.status))),
                        onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => OrgTruckScreen(truckId: t.id))),
                      ),
                    ),
                ]),
              ),
      ),
    );
  }
}

Future<void> showTruckForm(BuildContext context, WidgetRef ref, Truck? truck) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _TruckForm(truck: truck),
    );

class _TruckForm extends ConsumerStatefulWidget {
  const _TruckForm({this.truck});

  final Truck? truck;

  @override
  ConsumerState<_TruckForm> createState() => _TruckFormState();
}

class _TruckFormState extends ConsumerState<_TruckForm> {
  final _form = GlobalKey<FormState>();
  late final _number = TextEditingController(text: widget.truck?.number);
  late final _capacity = TextEditingController(text: widget.truck == null ? '' : '${widget.truck!.capacityTonnes}');
  late VehicleType _type = widget.truck?.vehicleType ?? VehicleType.openBody;
  bool _busy = false;
  AppException? _error;

  @override
  void dispose() {
    _number.dispose();
    _capacity.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(orgApiProvider).saveTruck(widget.truck?.id, _number.text.trim().toUpperCase(), _type, num.parse(_capacity.text.trim()));
      _refreshFleet(ref);
      if (mounted) Navigator.pop(context);
    } on AppException catch (e) {
      setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + MediaQuery.of(context).viewInsets.bottom),
        child: Form(
          key: _form,
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(l.addOrgTruck, style: Theme.of(context).textTheme.titleLarge),
            TextFormField(
              key: const Key('ot-number'),
              controller: _number,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: Inputs.text(FieldLimits.truckNumber),
              decoration: InputDecoration(labelText: l.truckNumber, errorText: _error?.fieldError('number')),
              validator: (v) => v == null || v.trim().length < 6 ? l.fieldRequired : null,
            ),
            DropdownButtonFormField<VehicleType>(
              initialValue: _type,
              decoration: InputDecoration(labelText: l.vehicleType),
              items: [
                for (final v in VehicleType.values.where((v) => v != VehicleType.unknown && v != VehicleType.any))
                  DropdownMenuItem(value: v, child: Text(vehicleLabel(l, v))),
              ],
              onChanged: (v) => setState(() => _type = v ?? _type),
            ),
            TextFormField(
              key: const Key('ot-capacity'),
              controller: _capacity,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: Inputs.decimal(),
              decoration: InputDecoration(labelText: l.capacityTonnes, errorText: _error?.fieldError('capacityTonnes')),
              validator: (v) => (num.tryParse(v ?? '') ?? 0) > 0 ? null : l.fieldRequired,
            ),
            if (_error != null && _error!.fields.isEmpty)
              Text(errorMessage(l, _error!), style: TextStyle(color: Theme.of(context).colorScheme.error)),
            const SizedBox(height: 12),
            PrimaryButton(label: l.save, loading: _busy, onPressed: _save),
          ]),
        ),
      ),
    );
  }
}

/// Truck detail: documents, live location (when on a trip), edit, deactivate.
class OrgTruckScreen extends ConsumerWidget {
  const OrgTruckScreen({super.key, required this.truckId});

  final String truckId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final trucks = ref.watch(orgTrucksProvider);
    final t = trucks.value?.where((x) => x.id == truckId).firstOrNull;
    return Scaffold(
      appBar: AppBar(title: Text(t?.number ?? '')),
      body: t == null
          ? AsyncView(value: trucks, onRetry: () => ref.invalidate(orgTrucksProvider), data: (_) => EmptyState(message: l.noTrucksYet))
          : ListView(padding: const EdgeInsets.all(16), children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('${vehicleLabel(l, t.vehicleType)} · ${Fmt.tonnes(t.capacityTonnes)}'),
                subtitle: Text((t.allocatedDriver?['name'] as String?) ?? l.notAllocated),
                trailing: TileAction(maxWidth: 120, child: Text(truckStatusLabel(l, t.status))),
              ),
              _TruckLocation(truckId: t.id),
              const Divider(),
              Text(l.documents, style: Theme.of(context).textTheme.titleMedium),
              for (final d in t.documents)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.description_outlined),
                  title: Text(docTypeLabel(l, d.type)),
                  subtitle: d.expiresOn == null ? null : Text(d.expiresOn!),
                  trailing: documentChip(context, d.status),
                ),
              TextButton.icon(
                onPressed: () async {
                  await context.push('${Routes.profileDocument}?orgTruck=${t.id}');
                  ref.invalidate(orgTrucksProvider);
                },
                icon: const Icon(Icons.upload_file),
                label: Text(l.addDocument),
              ),
              const Divider(),
              OutlinedButton.icon(onPressed: () => showTruckForm(context, ref, t), icon: const Icon(Icons.edit), label: Text(l.save)),
              OutlinedButton.icon(
                onPressed: () async {
                  if (await _run(context, () => ref.read(orgApiProvider).deactivateTruck(t.id))) {
                    _refreshFleet(ref);
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.block),
                label: Text(l.deactivateTruck),
              ),
            ]),
    );
  }
}

class _TruckLocation extends ConsumerWidget {
  const _TruckLocation({required this.truckId});

  final String truckId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return FutureBuilder<Map<String, dynamic>>(
      future: ref.read(orgApiProvider).truckLocation(truckId),
      builder: (context, snap) {
        final m = snap.data;
        if (m == null || m['lat'] == null) {
          return ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.location_off_outlined), title: Text(l.noLiveLocation));
        }
        final at = DateTime.tryParse('${m['at']}');
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.my_location),
          title: Text('${m['loadCode'] ?? ''} · ${(m['lat'] as num).toStringAsFixed(4)}, ${(m['lng'] as num).toStringAsFixed(4)}'),
          subtitle: at == null ? null : Text(l.lastSeenAt(Fmt.dateTime(at))),
        );
      },
    );
  }
}

// ---------------------------------------------------------------- OR-03/OR-04 drivers + allocation (A-803, A-804)

class OrgDriversScreen extends ConsumerWidget {
  const OrgDriversScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final allocations = ref.watch(orgAllocationsProvider).value ?? const [];
    return Scaffold(
      appBar: _bar(l.navDrivers),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _invite(context, ref),
        icon: const Icon(Icons.person_add_alt),
        label: Text(l.inviteDriver),
      ),
      body: AsyncView(
        value: ref.watch(orgDriversProvider),
        onRetry: () => ref.invalidate(orgDriversProvider),
        data: (list) => list.isEmpty
            ? EmptyState(icon: Icons.people_outline, message: l.noDriversYet)
            : RefreshIndicator(
                onRefresh: () async => _refreshFleet(ref),
                child: ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 88), children: [
                  for (final d in list)
                    if (d['allocationStatus'] == 'INVITED')
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.hourglass_empty),
                          title: Text('${d['name']}'),
                          subtitle: Text(l.invitedLabel),
                        ),
                      )
                    else
                      Card(
                        child: ListTile(
                          leading: Icon(d['onTrip'] == true ? Icons.route : (d['onDuty'] == true ? Icons.circle : Icons.circle_outlined),
                              color: d['onDuty'] == true ? context.statusColors.success : null),
                          title: Text('${d['name']}'),
                          subtitle: Text([
                            (d['truckNumber'] as String?) ?? l.notAllocated,
                            if (_allocationOf(allocations, d['id'])?['status'] == 'PAUSED') l.pausedLabel,
                          ].join(' · ')),
                          trailing: TrustScoreBadge(score: (d['trustScore'] as num?)?.toDouble() ?? 70),
                          onTap: () => _driverSheet(context, ref, d, _allocationOf(allocations, d['id'])),
                        ),
                      ),
                ]),
              ),
      ),
    );
  }

  static Map<String, dynamic>? _allocationOf(List<Map<String, dynamic>> allocations, Object? driverId) => allocations
      .where((a) => (a['driver'] as Map?)?['id'] == driverId && a['status'] != 'REMOVED')
      .firstOrNull;

  Future<void> _invite(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    var name = '';
    var mobile = '';
    final form = GlobalKey<FormState>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l.inviteDriver),
        content: Form(
          key: form,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(
              key: const Key('inv-name'),
              inputFormatters: Inputs.text(FieldLimits.name),
              decoration: InputDecoration(labelText: l.nameLabel),
              onChanged: (v) => name = v,
              validator: (v) => Validators.name(v) ? null : l.nameInvalid,
            ),
            TextFormField(
              key: const Key('inv-mobile'),
              keyboardType: TextInputType.phone,
              maxLength: 10,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(labelText: l.mobileLabel, prefixText: '+91 ', counterText: ''),
              onChanged: (v) => mobile = v,
              validator: (v) => Validators.mobile(v) ? null : l.mobileInvalid,
            ),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(MaterialLocalizations.of(c).cancelButtonLabel)),
          FilledButton(onPressed: () => Navigator.pop(c, form.currentState!.validate()), child: Text(l.inviteDriver)),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    if (await _run(context, () => ref.read(orgApiProvider).invite(name.trim(), mobile.trim()))) _refreshFleet(ref);
  }

  Future<void> _driverSheet(BuildContext context, WidgetRef ref, Map<String, dynamic> d, Map<String, dynamic>? allocation) {
    final l = AppLocalizations.of(context);
    final api = ref.read(orgApiProvider);
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (c) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('${d['name']}', style: Theme.of(c).textTheme.titleLarge),
            Text('+91 ${d['mobile']}'),
            const SizedBox(height: 8),
            Text(l.performanceTitle, style: Theme.of(c).textTheme.titleMedium),
            FutureBuilder<Map<String, dynamic>>(
              future: api.performance('${d['id']}'),
              builder: (c, snap) {
                final p = snap.data;
                if (p == null) return const LinearProgressIndicator();
                return Wrap(spacing: 8, runSpacing: 8, children: [
                  Chip(label: Text(l.tripsCount((p['trips'] as num?)?.toInt() ?? 0))),
                  if (p['onTimePct'] != null) Chip(label: Text(l.onTimePct((p['onTimePct'] as num).toInt()))),
                  Chip(label: Text('${l.earnedLabel}: ${Fmt.money((p['earnedInr'] as num?) ?? 0)}')),
                  Chip(label: Text('${l.cancellationsLabel}: ${p['cancellations'] ?? 0}')),
                ]);
              },
            ),
            const Divider(),
            if (allocation == null)
              PrimaryButton(
                label: l.allocateAction,
                icon: Icons.link,
                onPressed: () async {
                  Navigator.pop(c);
                  await _allocate(context, ref, '${d['id']}');
                },
              )
            else ...[
              ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.local_shipping_outlined),
                  title: Text('${(allocation['truck'] as Map?)?['number'] ?? ''}'),
                  subtitle: allocation['status'] == 'PAUSED' ? Text(l.pausedLabel) : null),
              OutlinedButton(
                onPressed: () async {
                  Navigator.pop(c);
                  if (await _run(context, () => api.setAllocationStatus('${allocation['id']}', allocation['status'] == 'PAUSED' ? 'ACTIVE' : 'PAUSED'))) {
                    _refreshFleet(ref);
                  }
                },
                child: Text(allocation['status'] == 'PAUSED' ? l.resumeAction : l.pauseAction),
              ),
              OutlinedButton(
                onPressed: () async {
                  Navigator.pop(c);
                  if (await _run(context, () => api.removeAllocation('${allocation['id']}'))) _refreshFleet(ref);
                },
                child: Text(l.removeAllocation),
              ),
            ],
          ]),
        ),
      ),
    );
  }

  Future<void> _allocate(BuildContext context, WidgetRef ref, String driverId) async {
    final l = AppLocalizations.of(context);
    final trucks = (await ref.read(orgTrucksProvider.future))
        .where((t) => t.allocatedDriver == null && t.status != TruckStatus.inactive)
        .toList();
    if (!context.mounted) return;
    final truck = await showModalBottomSheet<Truck>(
      context: context,
      showDragHandle: true,
      builder: (c) => SafeArea(
        child: ListView(shrinkWrap: true, children: [
          Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Text(l.chooseTruck, style: Theme.of(c).textTheme.titleLarge)),
          if (trucks.isEmpty) EmptyState(icon: Icons.local_shipping_outlined, message: l.noTrucksYet),
          for (final t in trucks)
            ListTile(title: Text(t.number), subtitle: Text(vehicleLabel(l, t.vehicleType)), onTap: () => Navigator.pop(c, t)),
        ]),
      ),
    );
    if (truck == null || !context.mounted) return;
    if (await _run(context, () => ref.read(orgApiProvider).allocate(driverId, truck.id))) _refreshFleet(ref);
  }
}

// ---------------------------------------------------------------- OR-05 trips (A-805)

class OrgTripsScreen extends ConsumerStatefulWidget {
  const OrgTripsScreen({super.key});

  @override
  ConsumerState<OrgTripsScreen> createState() => _OrgTripsScreenState();
}

class _OrgTripsScreenState extends ConsumerState<OrgTripsScreen> {
  String _by = 'DRIVER';
  String? _id;

  Future<void> _export() async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final bytes = await ref.read(orgApiProvider).exportCsv(by: _id == null ? null : _by, id: _id);
      final saved = await FilePicker.saveFile(fileName: 'tranix-trips.csv', bytes: bytes, mimeType: 'text/csv');
      if (saved != null) messenger.showSnackBar(SnackBar(content: Text(l.csvSaved)));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(errorMessage(l, e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final key = (_id == null ? null : _by, _id);
    final drivers = (ref.watch(orgDriversProvider).value ?? const []).where((d) => d['id'] != null).toList();
    final trucks = ref.watch(orgTrucksProvider).value ?? const <Truck>[];
    final options = _by == 'DRIVER'
        ? [for (final d in drivers) DropdownMenuItem<String?>(value: '${d['id']}', child: Text('${d['name']}'))]
        : [for (final t in trucks) DropdownMenuItem<String?>(value: t.id, child: Text(t.number))];
    return Scaffold(
      appBar: AppBar(title: Text(l.navTrips), actions: [
        IconButton(tooltip: l.exportCsv, icon: const Icon(Icons.download), onPressed: _export),
        const NotificationBell(),
        const ProfileAvatarButton(),
      ]),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: SegmentedButton<String>(
            segments: [ButtonSegment(value: 'DRIVER', label: Text(l.byDriver)), ButtonSegment(value: 'TRUCK', label: Text(l.byTruck))],
            selected: {_by},
            onSelectionChanged: (s) => setState(() {
              _by = s.first;
              _id = null;
            }),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: DropdownButtonFormField<String?>(
            key: ValueKey('trip-filter-$_by'),
            initialValue: _id,
            decoration: InputDecoration(labelText: _by == 'DRIVER' ? l.chooseDriver : l.chooseTruck),
            items: [DropdownMenuItem<String?>(value: null, child: Text(l.allItems)), ...options],
            onChanged: (v) => setState(() => _id = v),
          ),
        ),
        Expanded(
          child: AsyncView(
            value: ref.watch(orgTripsProvider(key)),
            onRetry: () => ref.invalidate(orgTripsProvider(key)),
            data: (list) => list.isEmpty
                ? EmptyState(icon: Icons.route, message: l.noTrips)
                : RefreshIndicator(
                    onRefresh: () async => ref.invalidate(orgTripsProvider(key)),
                    child: ListView(padding: const EdgeInsets.all(16), children: [for (final t in list) LoadCard(load: t, openDetail: false)]),
                  ),
          ),
        ),
      ]),
    );
  }
}
