import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
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
import '../../core/widgets/widgets.dart';
import '../../shared/labels.dart';
import '../../shared/models/models.dart';
import '../notifications/notifications_feature.dart';
import '../profile/application/profile_providers.dart';
import '../profile/presentation/labels.dart';
import '../shared_shell/tab_screens.dart' show ProfileAvatarButton;

/// Contract §8 (driver fleet parts).
class DriverApi {
  DriverApi(this._dio);

  final Dio _dio;

  Future<DriverHome> home() async =>
      DriverHome.fromJson((await guardApi(() => _dio.get<Map<String, dynamic>>('/driver/home'))).data!);

  /// Going on duty also sends the phone's position, so nearby loads are suggested before any trip.
  Future<void> setDuty(bool onDuty, {double? lat, double? lng}) =>
      guardApi(() => _dio.put<void>('/driver/duty', data: {'onDuty': onDuty, 'lat': ?lat, 'lng': ?lng}));

  Future<Truck?> truck() async {
    final res = await guardApi(() => _dio.get<dynamic>('/driver/truck'));
    return res.data is Map<String, dynamic> ? Truck.fromJson(res.data as Map<String, dynamic>) : null;
  }

  Future<Truck> saveTruck({required bool create, required String number, required VehicleType type, required num capacity}) async {
    final body = {'number': number, 'vehicleType': wireName(type), 'capacityTonnes': capacity};
    final res = await guardApi(() => create
        ? _dio.post<Map<String, dynamic>>('/driver/truck', data: body)
        : _dio.put<Map<String, dynamic>>('/driver/truck', data: body));
    return Truck.fromJson(res.data!);
  }

  Future<List<Invitation>> invitations() async {
    final res = await guardApi(() => _dio.get<List<dynamic>>('/driver/invitations'));
    return res.data!.map((e) => Invitation.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> respond(String id, bool accept) =>
      guardApi(() => _dio.post<void>('/driver/invitations/$id/${accept ? 'accept' : 'reject'}'));
}

final driverApiProvider = Provider<DriverApi>((ref) => DriverApi(ref.watch(dioProvider)));
final driverHomeProvider = FutureProvider.autoDispose<DriverHome>((ref) => ref.watch(driverApiProvider).home());
final invitationsProvider = FutureProvider.autoDispose<List<Invitation>>((ref) => ref.watch(driverApiProvider).invitations());
final driverTruckProvider = FutureProvider.autoDispose<Truck?>((ref) => ref.watch(driverApiProvider).truck());

String truckStatusLabel(AppLocalizations l, TruckStatus s) => switch (s) {
      TruckStatus.available => l.truckAvailable,
      TruckStatus.allocated => l.truckAllocated,
      TruckStatus.onTrip => l.truckOnTrip,
      TruckStatus.documentsPending => l.truckDocumentsPending,
      TruckStatus.inactive => l.truckInactive,
      TruckStatus.unknown => l.statusUnknown,
    };

Widget truckStatusChip(BuildContext context, TruckStatus s) {
  final c = context.statusColors;
  final color = switch (s) {
    TruckStatus.available => c.success,
    TruckStatus.allocated || TruckStatus.onTrip => c.info,
    TruckStatus.documentsPending => c.warning,
    _ => c.neutral,
  };
  return StatusChip(label: truckStatusLabel(AppLocalizations.of(context), s), color: color);
}

void _refreshDriver(WidgetRef ref) {
  ref.invalidate(driverHomeProvider);
  ref.invalidate(invitationsProvider);
  ref.invalidate(driverTruckProvider);
  ref.invalidate(meProvider);
}

/// DR-01 Driver home: duty switch, truck, wallet or Org, current trip, suggestions count, expiring documents,
/// invitation banner.
class DriverHomeScreen extends ConsumerWidget {
  const DriverHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final home = ref.watch(driverHomeProvider);
    final invitations = ref.watch(invitationsProvider).value ?? const <Invitation>[];
    return Scaffold(
      appBar: AppBar(title: Text(l.navHome), actions: const [NotificationBell(), ProfileAvatarButton()]),
      body: RefreshIndicator(
        onRefresh: () async => _refreshDriver(ref),
        child: AsyncView(
          value: home,
          onRetry: () => _refreshDriver(ref),
          data: (h) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final inv in invitations) InvitationCard(invitation: inv),
              const HomeNotificationCards(),
              Card(
                child: SwitchListTile(
                  key: const Key('duty'),
                  value: h.onDuty,
                  title: Text(h.onDuty ? l.onDuty : l.offDuty, style: Theme.of(context).textTheme.titleLarge),
                  subtitle: h.onDuty ? null : Text(l.goOnDutyHint),
                  activeThumbColor: TranixColors.amber,
                  onChanged: (v) async {
                    try {
                      Position? here;
                      if (v) {
                        try {
                          var p = await Geolocator.checkPermission();
                          if (p == LocationPermission.denied) p = await Geolocator.requestPermission();
                          if (p == LocationPermission.always || p == LocationPermission.whileInUse) {
                            here = await Geolocator.getCurrentPosition().timeout(const Duration(seconds: 10));
                          }
                        } catch (_) {
                          // no location: still go on duty; the last known position is used
                        }
                      }
                      await ref.read(driverApiProvider).setDuty(v, lat: here?.latitude, lng: here?.longitude);
                      ref.invalidate(driverHomeProvider);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage(l, e))));
                      }
                    }
                  },
                ),
              ),
              if (h.currentLoadId != null)
                Card(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: ListTile(
                    leading: const Icon(Icons.route),
                    title: Text(l.openTrip),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.go('${Routes.driver}/trip'),
                  ),
                ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.list_alt),
                  title: Text(l.suggestionsAvailable(h.suggestionsCount)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('${Routes.driver}/suggestions'),
                ),
              ),
              _TruckCard(truck: h.truck, orgName: h.orgName),
              Card(
                child: ListTile(
                  title: Text(h.orgName == null ? l.walletBalance : l.roleOrganization),
                  subtitle: h.orgName == null ? MoneyText(h.walletBalanceInr ?? 0, large: true) : Text(h.orgName!),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    TrustScoreBadge(score: h.trustScore),
                    if (h.orgName == null) ...[
                      const SizedBox(width: 8),
                      FilledButton.tonal(onPressed: () => context.push(Routes.wallet), child: Text(l.topUp)),
                    ],
                  ]),
                ),
              ),
              if (h.expiringDocuments.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(l.expiringDocs, style: Theme.of(context).textTheme.titleMedium),
                for (final d in h.expiringDocuments)
                  ListTile(
                    leading: Icon(Icons.warning_amber, color: context.statusColors.warning),
                    title: Text(docTypeLabel(l, d.type)),
                    subtitle: d.expiresOn == null ? null : Text(l.expiresOnDate(d.expiresOn!)),
                    onTap: () => context.push(Routes.driverLocker),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TruckCard extends StatelessWidget {
  const _TruckCard({required this.truck, required this.orgName});

  final Truck? truck;
  final String? orgName;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = truck;
    return Card(
      child: ListTile(
        leading: const Icon(Icons.local_shipping_outlined),
        title: Text(t == null ? l.noTruckYet : t.number),
        subtitle: t == null
            ? null
            : Text('${vehicleLabel(l, t.vehicleType)} · ${t.capacityTonnes} t'
                '${t.ownedByMe || orgName == null ? '' : '\n${l.truckAssignedBy(orgName!)}'}'),
        trailing: t == null
            ? (orgName == null ? TextButton(onPressed: () => context.push(Routes.driverTruckForm), child: Text(l.addTruck)) : null)
            : truckStatusChip(context, t.status),
        onTap: t != null && t.ownedByMe ? () => context.push(Routes.driverTruckForm) : null,
      ),
    );
  }
}

/// Organization invitation: Accept or Reject only (§16).
class InvitationCard extends ConsumerWidget {
  const InvitationCard({super.key, required this.invitation});

  final Invitation invitation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    Future<void> respond(bool accept) async {
      try {
        await ref.read(driverApiProvider).respond(invitation.id, accept);
        _refreshDriver(ref);
      } catch (e) {
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage(l, e))));
      }
    }

    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.invitationFrom(invitation.orgName), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: OutlinedButton(onPressed: () => respond(false), child: Text(l.reject))),
              const SizedBox(width: 12),
              Expanded(child: FilledButton(onPressed: () => respond(true), child: Text(l.accept))),
            ]),
          ],
        ),
      ),
    );
  }
}

/// DR-02 own truck form (owner-drivers only) + truck documents.
class TruckFormScreen extends ConsumerStatefulWidget {
  const TruckFormScreen({super.key});

  @override
  ConsumerState<TruckFormScreen> createState() => _TruckFormScreenState();
}

class _TruckFormScreenState extends ConsumerState<TruckFormScreen> {
  final _form = GlobalKey<FormState>();
  final _number = TextEditingController();
  final _capacity = TextEditingController();
  VehicleType _type = VehicleType.openBody;
  bool _loaded = false;
  bool _exists = false;
  bool _busy = false;
  AppException? _error;

  @override
  void initState() {
    super.initState();
    ref.read(driverApiProvider).truck().then((t) {
      if (t != null) {
        _number.text = t.number;
        _capacity.text = '${t.capacityTonnes}';
        _type = t.vehicleType;
        _exists = true;
      }
      if (mounted) setState(() => _loaded = true);
    }).catchError((Object _) {
      if (mounted) setState(() => _loaded = true);
    });
  }

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
      await ref.read(driverApiProvider).saveTruck(
          create: !_exists, number: _number.text.trim(), type: _type, capacity: num.parse(_capacity.text));
      _refreshDriver(ref);
      if (mounted) setState(() => _exists = true);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).saved)));
    } on AppException catch (e) {
      setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final truck = ref.watch(driverTruckProvider).value;
    return Scaffold(
      appBar: AppBar(title: Text(l.myTruck)),
      body: !_loaded
          ? const LoadingView()
          : Form(
              key: _form,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextFormField(
                    key: const Key('truck-number'),
                    controller: _number,
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: Inputs.text(FieldLimits.truckNumber),
                    decoration: InputDecoration(labelText: l.truckNumber, errorText: _error?.fieldError('number')),
                    validator: (v) => v == null || v.trim().length < 6 ? l.fieldRequired : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<VehicleType>(
                    initialValue: _type,
                    decoration: InputDecoration(labelText: l.vehicleType, errorText: _error?.fieldError('vehicleType')),
                    items: [
                      for (final v in VehicleType.values.where((v) => v != VehicleType.unknown && v != VehicleType.any))
                        DropdownMenuItem(value: v, child: Text(vehicleLabel(l, v))),
                    ],
                    onChanged: (v) => setState(() => _type = v ?? _type),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('truck-capacity'),
                    controller: _capacity,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: Inputs.decimal(),
                    decoration: InputDecoration(labelText: l.capacityTonnes, errorText: _error?.fieldError('capacityTonnes')),
                    validator: (v) => (num.tryParse(v ?? '') ?? 0) > 0 ? null : l.fieldRequired,
                  ),
                  if (_error != null && _error!.fields.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(errorMessage(l, _error!), style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    ),
                  const SizedBox(height: 16),
                  PrimaryButton(label: l.save, loading: _busy, onPressed: _save),
                  if (_exists) ...[
                    const Divider(height: 32),
                    Row(children: [
                      Expanded(child: Text(l.truckDocuments, style: Theme.of(context).textTheme.titleMedium)),
                      if (truck != null) truckStatusChip(context, truck.status),
                    ]),
                    for (final d in truck?.documents ?? const <Document>[])
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(docTypeLabel(l, d.type)),
                        subtitle: d.expiresOn == null ? null : Text(l.expiresOnDate(d.expiresOn!)),
                        trailing: documentChip(context, d.status),
                      ),
                    TextButton.icon(
                      onPressed: () => context.push('${Routes.profileDocument}?truck=1'),
                      icon: const Icon(Icons.add),
                      label: Text(l.addDocument),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}

/// DR-02 Locker: all my documents (personal + truck) with status/expiry and replace.
class LockerScreen extends ConsumerWidget {
  const LockerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final mine = ref.watch(verificationProvider);
    final truck = ref.watch(driverTruckProvider).value;
    Widget tile(Document d, {bool truckDoc = false}) => ListTile(
          title: Text(docTypeLabel(l, d.type)),
          subtitle: Text([if (d.numberMasked != null) d.numberMasked!, if (d.expiresOn != null) l.expiresOnDate(d.expiresOn!)].join(' · ')),
          trailing: documentChip(context, d.status),
          onTap: () => context.push(truckDoc
              ? '${Routes.profileDocument}?truck=1&type=${wireName(d.type)}'
              : '${Routes.profileDocument}?type=${wireName(d.type)}&replace=${d.id}'),
        );
    return Scaffold(
      appBar: AppBar(title: Text(l.locker)),
      body: AsyncView(
        value: mine,
        onRetry: () => ref.invalidate(verificationProvider),
        data: (v) => ListView(
          children: [
            for (final d in v.documents) tile(d),
            if (truck != null && truck.ownedByMe) ...[
              const Divider(),
              ListTile(title: Text(l.truckDocuments, style: Theme.of(context).textTheme.titleMedium)),
              for (final d in truck.documents) tile(d, truckDoc: true),
            ],
          ],
        ),
      ),
    );
  }
}
