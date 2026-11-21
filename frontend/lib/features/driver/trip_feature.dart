import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/errors/app_exception.dart';
import '../../core/errors/error_messages.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/location/trip_location.dart';
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

/// Contract §8 (trip execution).
class TripApi {
  TripApi(this._dio);

  final Dio _dio;

  Future<LoadDetail?> currentTrip() async {
    final res = await guardApi(() => _dio.get<dynamic>('/driver/current-trip'));
    return res.data is Map<String, dynamic> ? LoadDetail.fromJson(res.data as Map<String, dynamic>) : null;
  }

  Future<Map<String, dynamic>> reached(String id, OtpPurpose purpose, GeoPoint at, {String? reason}) async {
    final res = await guardApi(() => _dio.post<Map<String, dynamic>>('/driver/trips/$id/reached',
        data: {'purpose': wireName(purpose), 'lat': at.lat, 'lng': at.lng, 'reason': ?reason}));
    return res.data!;
  }

  Future<LoadDetail> verify(String id, OtpPurpose purpose, String code, GeoPoint at, {String? reason}) async {
    final res = await guardApi(() => _dio.post<Map<String, dynamic>>('/driver/trips/$id/otp/verify',
        data: {'purpose': wireName(purpose), 'code': code, 'lat': at.lat, 'lng': at.lng, 'reason': ?reason}));
    return LoadDetail.fromJson(res.data!);
  }

  Future<void> resend(String id, OtpPurpose purpose) =>
      guardApi(() => _dio.post<void>('/driver/trips/$id/otp/resend', data: {'purpose': wireName(purpose)}));

  Future<void> help(String id, OtpPurpose purpose, GeoPoint? at, String note) => guardApi(() => _dio.post<dynamic>(
      '/driver/trips/$id/otp/help', data: {'purpose': wireName(purpose), 'lat': ?at?.lat, 'lng': ?at?.lng, 'note': note}));

  Future<LoadDetail> requestAmount(String id, int amountInr, String reason) async => LoadDetail.fromJson((await guardApi(
          () => _dio.post<Map<String, dynamic>>('/driver/trips/$id/revisions', data: {'amountInr': amountInr, 'reason': reason})))
      .data!);

  Future<void> cancel(String id, String reason, String? note) =>
      guardApi(() => _dio.post<dynamic>('/driver/trips/$id/cancel', data: {'reason': reason, 'note': ?note}));

  Future<List<Map<String, dynamic>>> routeServices(String bbox, List<String> types) async {
    final res = await guardApi(() => _dio.get<List<dynamic>>('/map/route-services', queryParameters: {'bbox': bbox, 'types': types.join(',')}));
    return res.data!.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> restrictions(String bbox) async {
    final res = await guardApi(() => _dio.get<List<dynamic>>('/map/restrictions', queryParameters: {'bbox': bbox}));
    return res.data!.cast<Map<String, dynamic>>();
  }
}

final tripApiProvider = Provider<TripApi>((ref) => TripApi(ref.watch(dioProvider)));
final currentTripProvider = FutureProvider.autoDispose<LoadDetail?>((ref) => ref.watch(tripApiProvider).currentTrip());

/// Current device position, or the pin when location is unavailable (emulator/tests); the server checks distance.
Future<GeoPoint> _here(GeoPoint fallback) async {
  try {
    final p = await Geolocator.getCurrentPosition().timeout(const Duration(seconds: 10));
    return GeoPoint(lat: p.latitude, lng: p.longitude);
  } catch (_) {
    return fallback;
  }
}

/// Opens Google Maps turn-by-turn (architecture.md "Maps").
Future<void> openNavigation(Place to) async {
  final intent = Uri.parse('google.navigation:q=${to.lat},${to.lng}&mode=d');
  if (!await launchUrl(intent)) {
    await launchUrl(Uri.parse('https://www.google.com/maps/dir/?api=1&destination=${to.lat},${to.lng}'),
        mode: LaunchMode.externalApplication);
  }
}

/// DR-04 Current trip with one primary step button per status.
class CurrentTripScreen extends ConsumerStatefulWidget {
  const CurrentTripScreen({super.key});

  @override
  ConsumerState<CurrentTripScreen> createState() => _CurrentTripScreenState();
}

class _CurrentTripScreenState extends ConsumerState<CurrentTripScreen> {
  Timer? _poll;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _poll = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) ref.invalidate(currentTripProvider);
    });
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  void _refresh() {
    ref.invalidate(currentTripProvider);
    ref.invalidate(driverHomeProvider);
  }

  void _toast(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  /// Starts background location from acceptance to delivery (after the explainer the first time).
  Future<void> _ensureTracking(LoadDetail t) async {
    final location = ref.read(tripLocationProvider);
    final l = AppLocalizations.of(context);
    if (location.running || ref.read(appConfigProvider).useMock) return;
    final prefs = ref.read(sharedPreferencesProvider);
    if (!(prefs.getBool('tranix.locationExplained') ?? false)) {
      final ok = await showConfirmSheet(context, title: l.locationExplainTitle, message: l.locationExplainBody, confirmLabel: l.allow);
      if (!ok) return;
      await prefs.setBool('tranix.locationExplained', true);
    }
    if (await TripLocationService.ensurePermission()) {
      await location.start(t.id, notificationTitle: l.tripInProgress(t.code));
    }
  }

  Future<void> _step(LoadDetail t) async {
    final l = AppLocalizations.of(context);
    final api = ref.read(tripApiProvider);
    switch (t.status) {
      case LoadStatus.waitingForPickup || LoadStatus.amountNegotiation || LoadStatus.traveling:
        final pickup = t.status != LoadStatus.traveling;
        final purpose = pickup ? OtpPurpose.pickup : OtpPurpose.delivery;
        final pin = pickup ? t.pickup : t.drop;
        setState(() => _busy = true);
        try {
          final at = await _here(GeoPoint(lat: pin.lat, lng: pin.lng));
          var res = await api.reached(t.id, purpose, at);
          if (res['outsideRadius'] == true && res['otpSentTo'] == null && mounted) {
            final reason = await _askText(l.outsideRadiusTitle(res['distanceM'] as int), l.outsideRadiusBody);
            if (reason == null) return;
            res = await api.reached(t.id, purpose, at, reason: reason);
          }
          _refresh();
          if (mounted) setState(() => _busy = false);
          if (mounted) await _otpSheet(t, purpose, res['otpSentTo'] as String?);
        } on AppException catch (e) {
          _toast(errorMessage(l, e));
        } finally {
          if (mounted && _busy) setState(() => _busy = false);
        }
      case LoadStatus.locationReached:
        await _otpSheet(t, OtpPurpose.pickup, null);
      case LoadStatus.arrivedDestination:
        await _otpSheet(t, OtpPurpose.delivery, null);
      default:
        break;
    }
  }

  Future<String?> _askText(String title, String body, {String? label}) async {
    final c = TextEditingController();
    final l = AppLocalizations.of(context);
    final text = await showDialog<String>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(title),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(body),
          TextField(key: const Key('ask-text'), controller: c, decoration: InputDecoration(labelText: label ?? l.reasonLabel)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d), child: Text(l.actionCancel)),
          FilledButton(onPressed: () => Navigator.pop(d, c.text.trim().isEmpty ? null : c.text.trim()), child: Text(l.sendAction)),
        ],
      ),
    );
    c.dispose();
    return text;
  }

  /// DR-05 OTP sheet: 6 boxes, resend, "Can't get OTP?".
  Future<void> _otpSheet(LoadDetail t, OtpPurpose purpose, String? sentTo) async {
    final l = AppLocalizations.of(context);
    final api = ref.read(tripApiProvider);
    final pin = purpose == OtpPurpose.pickup ? t.pickup : t.drop;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (c) => _OtpSheet(
        title: purpose == OtpPurpose.pickup ? l.otpAskSender : l.otpAskReceiver,
        sentTo: sentTo,
        onVerify: (code) async {
          final at = await _here(GeoPoint(lat: pin.lat, lng: pin.lng));
          try {
            await api.verify(t.id, purpose, code, at);
          } on AppException catch (e) {
            if (e.fieldError('reason') != null && c.mounted) {
              final reason = await _askText(l.outsideRadiusBody, e.fieldError('reason')!);
              if (reason == null) rethrow;
              await api.verify(t.id, purpose, code, at, reason: reason);
            } else {
              rethrow;
            }
          }
          if (purpose == OtpPurpose.delivery) await ref.read(tripLocationProvider).stop();
          _refresh();
        },
        onResend: () => api.resend(t.id, purpose),
        onHelp: () async {
          final note = await _askText(l.cantGetOtp, '', label: l.helpNote);
          if (note == null) return;
          await api.help(t.id, purpose, await _here(GeoPoint(lat: pin.lat, lng: pin.lng)), note);
          _toast(l.helpSent);
        },
      ),
    );
  }

  Future<void> _requestAmount(LoadDetail t) async {
    final l = AppLocalizations.of(context);
    final amount = TextEditingController();
    final reason = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(l.requestAmount),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
            key: const Key('rev-amount'),
            controller: amount,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(labelText: l.newAmount),
          ),
          TextField(key: const Key('rev-reason'), controller: reason, decoration: InputDecoration(labelText: l.reasonLabel)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d, false), child: Text(l.actionCancel)),
          FilledButton(onPressed: () => Navigator.pop(d, true), child: Text(l.sendAction)),
        ],
      ),
    );
    final a = int.tryParse(amount.text);
    final r = reason.text.trim();
    amount.dispose();
    reason.dispose();
    if (ok != true || a == null || r.isEmpty) return;
    try {
      await ref.read(tripApiProvider).requestAmount(t.id, a, r);
      _refresh();
    } on AppException catch (e) {
      _toast(errorMessage(l, e));
    }
  }

  Future<void> _cancel(LoadDetail t) async {
    final l = AppLocalizations.of(context);
    const reasons = ['TRUCK_BREAKDOWN', 'EMERGENCY', 'SHIPPER_CHANGED_DETAILS', 'AMOUNT_NOT_AGREED', 'TOO_FAR', 'OTHER'];
    final reason = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (c) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(l.cancelTrip, style: Theme.of(c).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(l.cancelOutcomeKept('-5')),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final r in reasons) ActionChip(label: Text(cancelReasonLabel(l, r)), onPressed: () => Navigator.pop(c, r)),
            ]),
          ]),
        ),
      ),
    );
    if (reason == null) return;
    String? note;
    if (reason == 'OTHER') {
      note = await _askText(l.cancelTrip, '', label: l.noteLabel);
      if (note == null) return;
    }
    try {
      await ref.read(tripApiProvider).cancel(t.id, reason, note);
      await ref.read(tripLocationProvider).stop();
      _refresh();
    } on AppException catch (e) {
      _toast(errorMessage(l, e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final trip = ref.watch(currentTripProvider);
    final limit = ref.watch(publicSettingsProvider).value?.revisionLimit ?? 5;
    return Scaffold(
      appBar: AppBar(title: Text(l.navCurrentTrip), actions: const [NotificationBell(), ProfileAvatarButton()]),
      body: RefreshIndicator(
        onRefresh: () async => _refresh(),
        child: AsyncView(
          value: trip,
          onRetry: _refresh,
          data: (t) {
            if (t == null) return ListView(children: [EmptyState(icon: Icons.route_outlined, message: l.noActiveTrip)]);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _ensureTracking(t);
            });
            final beforePickup = t.status == LoadStatus.waitingForPickup || t.status == LoadStatus.amountNegotiation;
            final pending = t.revisions.any((r) => r.status == RevisionStatus.pending);
            final stepLabel = switch (t.status) {
              LoadStatus.waitingForPickup || LoadStatus.amountNegotiation => l.stepReachedPickup,
              LoadStatus.locationReached => l.stepEnterPickupOtp,
              LoadStatus.traveling => l.stepReachedDrop,
              LoadStatus.arrivedDestination => l.stepEnterDeliveryOtp,
              _ => null,
            };
            final next = t.status == LoadStatus.traveling || t.status == LoadStatus.arrivedDestination ? t.drop : t.pickup;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(children: [
                  Expanded(child: Text(t.code, style: Theme.of(context).textTheme.headlineSmall)),
                  StatusChip.load(context, t.status),
                ]),
                MoneyText(t.agreedAmountInr, large: true),
                Text('${t.goodsType} · ${t.quantity} ${unitLabel(l, t.quantityUnit)} · ${Fmt.tonnes(t.weightTonnes)}'),
                if (t.deliveryEta != null) Text('${l.deliveryEstimate}: ${Fmt.dateTime(t.deliveryEta!)}'),
                const SizedBox(height: 8),
                _PlaceTile(icon: Icons.trip_origin, title: l.pickupAt, place: t.pickup, person: t.senderName,
                    mobile: t.senderMobile, callLabel: l.callSender, when: Fmt.dateTime(t.pickupWindowStart)),
                _PlaceTile(icon: Icons.location_on, title: l.dropAt, place: t.drop, person: t.receiverName,
                    mobile: t.receiverMobile, callLabel: l.callReceiver),
                const SizedBox(height: 8),
                OutlinedButton.icon(onPressed: () => openNavigation(next), icon: const Icon(Icons.navigation), label: Text(l.navigate)),
                MapLayers(center: GeoPoint(lat: next.lat, lng: next.lng)),
                const SizedBox(height: 16),
                if (stepLabel != null)
                  SizedBox(
                    height: 64,
                    child: PrimaryButton(key: const Key('step'), label: stepLabel, loading: _busy, onPressed: () => _step(t)),
                  ),
                if (beforePickup) ...[
                  const SizedBox(height: 12),
                  OutlinedButton(
                    key: const Key('request-amount'),
                    onPressed: pending || t.revisionsUsed >= limit ? null : () => _requestAmount(t),
                    child: Text(pending ? l.amountPendingWait : '${l.requestAmount} (${l.amountUsed(t.revisionsUsed, limit)})'),
                  ),
                  TextButton(onPressed: () => _cancel(t), child: Text(l.cancelTrip)),
                ],
                if (!beforePickup && t.status != LoadStatus.delivered)
                  TextButton(onPressed: () => context.push(Routes.support), child: Text(l.support)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PlaceTile extends StatelessWidget {
  const _PlaceTile({required this.icon, required this.title, required this.place, required this.person,
      required this.mobile, required this.callLabel, this.when});

  final IconData icon;
  final String title;
  final Place place;
  final String person;
  final String mobile;
  final String callLabel;
  final String? when;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text('$title: ${place.address}'),
        subtitle: Text([?place.landmark, person, ?when].join(' · ')),
        trailing: IconButton(tooltip: callLabel, icon: const Icon(Icons.call), onPressed: () => launchUrl(Uri(scheme: 'tel', path: mobile))),
      ),
    );
  }
}

class _OtpSheet extends StatefulWidget {
  const _OtpSheet({required this.title, required this.sentTo, required this.onVerify, required this.onResend, required this.onHelp});

  final String title;
  final String? sentTo;
  final Future<void> Function(String code) onVerify;
  final Future<void> Function() onResend;
  final Future<void> Function() onHelp;

  @override
  State<_OtpSheet> createState() => _OtpSheetState();
}

class _OtpSheetState extends State<_OtpSheet> {
  String? _error;
  bool _busy = false;

  Future<void> _run(Future<void> Function() action, {bool close = false}) async {
    final l = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
      if (close && mounted) Navigator.pop(context);
    } on AppException catch (e) {
      if (mounted) setState(() => _error = errorMessage(l, e));
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
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
          if (widget.sentTo != null) Text(l.otpSentToMobile(widget.sentTo!)),
          const SizedBox(height: 16),
          OtpInput(key: const Key('trip-otp'), errorText: _error, onCompleted: (code) => _run(() => widget.onVerify(code), close: true)),
          if (_busy) const LinearProgressIndicator(),
          const SizedBox(height: 8),
          Row(children: [
            TextButton(onPressed: _busy ? null : () => _run(widget.onResend), child: Text(l.resendOtp)),
            const Spacer(),
            TextButton(onPressed: _busy ? null : () => _run(widget.onHelp), child: Text(l.cantGetOtp)),
          ]),
        ]),
      ),
    );
  }
}

/// A-507 map layers as chips + nearby list (works without a Maps key; markers come with the key, F-5).
class MapLayers extends ConsumerStatefulWidget {
  const MapLayers({super.key, required this.center});

  final GeoPoint center;

  @override
  ConsumerState<MapLayers> createState() => _MapLayersState();
}

class _MapLayersState extends ConsumerState<MapLayers> {
  String? _layer;
  List<Map<String, dynamic>> _items = const [];

  Future<void> _load(String layer) async {
    final c = widget.center;
    final bbox = '${c.lng - 0.5},${c.lat - 0.5},${c.lng + 0.5},${c.lat + 0.5}';
    final api = ref.read(tripApiProvider);
    try {
      final items = layer == 'RESTRICTIONS' ? await api.restrictions(bbox) : await api.routeServices(bbox, [layer]);
      if (mounted) setState(() => _items = items);
    } catch (_) {
      if (mounted) setState(() => _items = const []);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final layers = {
      'PETROL': l.layerPetrol,
      'WEIGHBRIDGE': l.layerWeighbridge,
      'PUNCTURE': l.layerPuncture,
      'TOLL': l.layerToll,
      'RESTRICTIONS': l.layerRestrictions,
    };
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 4, children: [
        for (final e in layers.entries)
          FilterChip(
            label: Text(e.value),
            selected: _layer == e.key,
            onSelected: (on) {
              setState(() {
                _layer = on ? e.key : null;
                _items = const [];
              });
              if (on) _load(e.key);
            },
          ),
      ]),
      for (final item in _items)
        ListTile(
          dense: true,
          leading: Icon(_layer == 'RESTRICTIONS' ? Icons.block : Icons.place_outlined),
          title: Text('${item['name']}'),
          subtitle: _layer == 'RESTRICTIONS' && item['noEntryFrom'] != null
              ? Text(l.noEntryHours('${item['noEntryFrom']}', '${item['noEntryTo']}'))
              : null,
          onTap: () => openNavigation(Place(lat: (item['lat'] as num).toDouble(), lng: (item['lng'] as num).toDouble(), address: '${item['name']}')),
        ),
    ]);
  }
}
