import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/interceptors.dart';
import '../providers.dart';

/// A-504/A-505: driver location only during an active trip (CLAUDE.md rule 9).
/// Android foreground service with the "Tranix trip … in progress" notification; points every 30 s or 200 m are
/// queued in shared_preferences and uploaded in batches (≤ 100), so nothing is lost while offline.
class TripLocationService {
  TripLocationService(this._ref);

  final Ref _ref;
  StreamSubscription<Position>? _positions;
  StreamSubscription<List<ConnectivityResult>>? _connectivity;
  Timer? _flushTimer;
  String? _loadId;
  bool _flushing = false;

  static const _queueKey = 'tranix.locationQueue';
  static const _batch = 100;

  SharedPreferences get _prefs => _ref.read(sharedPreferencesProvider);

  bool get running => _loadId != null;

  /// Checks/asks permission. Returns false if the driver refused.
  static Future<bool> ensurePermission() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return false;
      var p = await Geolocator.checkPermission();
      if (p == LocationPermission.denied) p = await Geolocator.requestPermission();
      return p == LocationPermission.always || p == LocationPermission.whileInUse;
    } catch (_) {
      return false;
    }
  }

  Future<void> start(String loadId, {required String notificationTitle}) async {
    if (_loadId == loadId || _ref.read(appConfigProvider).useMock || kIsWeb) return;
    await stop();
    _loadId = loadId;
    try {
      final settings = defaultTargetPlatform == TargetPlatform.android
          ? AndroidSettings(
              distanceFilter: 200,
              intervalDuration: const Duration(seconds: 30),
              foregroundNotificationConfig: ForegroundNotificationConfig(
                notificationTitle: notificationTitle,
                notificationText: notificationTitle,
                enableWakeLock: true,
              ),
            )
          : const LocationSettings(distanceFilter: 200);
      _positions = Geolocator.getPositionStream(locationSettings: settings).listen(_onPosition, onError: (_) {});
    } catch (_) {
      // Location unavailable — the trip still works; tracking just has no points.
    }
    _flushTimer = Timer.periodic(const Duration(seconds: 30), (_) => flush());
    _connectivity = Connectivity().onConnectivityChanged.listen((r) {
      if (r.any((c) => c != ConnectivityResult.none)) unawaited(flush());
    }, onError: (_) {});
  }

  Future<void> stop() async {
    await flush();
    await _positions?.cancel();
    await _connectivity?.cancel();
    _flushTimer?.cancel();
    _positions = null;
    _connectivity = null;
    _flushTimer = null;
    _loadId = null;
  }

  /// Cancels streams and timers without touching providers (safe inside provider disposal).
  void dispose() {
    _positions?.cancel();
    _connectivity?.cancel();
    _flushTimer?.cancel();
    _loadId = null;
  }

  void _onPosition(Position p) => enqueue(p.latitude, p.longitude, p.speed, p.timestamp);

  /// Adds one point to the offline queue (public for tests).
  void enqueue(double lat, double lng, double? speed, DateTime at) {
    final queue = _prefs.getStringList(_queueKey) ?? <String>[];
    queue.add(jsonEncode({'loadId': _loadId, 'lat': lat, 'lng': lng, 'speed': speed, 'at': at.toUtc().toIso8601String()}));
    // keep the newest 2,000 points at most
    unawaited(_prefs.setStringList(_queueKey, queue.length > 2000 ? queue.sublist(queue.length - 2000) : queue));
  }

  int get queued => (_prefs.getStringList(_queueKey) ?? const []).length;

  /// Uploads queued points per load in batches; keeps them when the upload fails.
  Future<void> flush() async {
    if (_flushing) return;
    _flushing = true;
    try {
      final queue = _prefs.getStringList(_queueKey) ?? <String>[];
      if (queue.isEmpty) return;
      final points = queue.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
      final byLoad = <String, List<Map<String, dynamic>>>{};
      for (final p in points) {
        final id = p['loadId'] as String?;
        if (id != null) byLoad.putIfAbsent(id, () => []).add(p);
      }
      final sent = <Map<String, dynamic>>{};
      final dio = _ref.read(dioProvider);
      for (final entry in byLoad.entries) {
        for (var i = 0; i < entry.value.length; i += _batch) {
          final chunk = entry.value.sublist(i, (i + _batch).clamp(0, entry.value.length));
          try {
            await guardApi(() => dio.post<void>('/driver/trips/${entry.key}/locations', data: [
                  for (final p in chunk) {'lat': p['lat'], 'lng': p['lng'], 'speed': p['speed'], 'at': p['at']},
                ]));
            sent.addAll(chunk);
          } catch (_) {
            break; // retry later
          }
        }
      }
      final rest = [for (final p in points) if (!sent.contains(p) && p['loadId'] != null) jsonEncode(p)];
      await _prefs.setStringList(_queueKey, rest);
    } finally {
      _flushing = false;
    }
  }
}

final tripLocationProvider = Provider<TripLocationService>((ref) {
  final s = TripLocationService(ref);
  ref.onDispose(s.dispose);
  return s;
});
