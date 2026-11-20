import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/interceptors.dart';
import '../providers.dart';

/// A-303: FCM token registration (`POST /me/devices`), foreground notifications and tap routing.
/// Firebase needs `android/app/google-services.json` (founder action F-4); without it this service stays off
/// and the app still works with the in-app inbox.
class PushService {
  PushService(this._ref);

  final Ref _ref;
  final _local = FlutterLocalNotificationsPlugin();
  bool _started = false;

  /// Called with the payload route when the user taps a notification.
  void Function(String route)? onOpenRoute;

  Future<void> start() async {
    if (_started || _ref.read(appConfigProvider).useMock || kIsWeb) return;
    try {
      await Firebase.initializeApp();
    } catch (_) {
      debugPrint('Push disabled: Firebase is not configured');
      return;
    }
    _started = true;
    await _local.initialize(
      settings: const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher')),
      onDidReceiveNotificationResponse: (r) {
        if (r.payload != null && r.payload!.isNotEmpty) onOpenRoute?.call(r.payload!);
      },
    );
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();
    // ignore: deprecated_member_use
    final token = await messaging.getToken();
    if (token != null) await _register(token);
    // ignore: deprecated_member_use
    messaging.onTokenRefresh.listen(_register);
    FirebaseMessaging.onMessage.listen((m) {
      final n = m.notification;
      if (n == null) return;
      _local.show(
        id: m.hashCode,
        title: n.title,
        body: n.body,
        payload: m.data['route'] as String?,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails('tranix', 'Tranix', importance: Importance.high, priority: Priority.high),
        ),
      );
    });
    FirebaseMessaging.onMessageOpenedApp.listen((m) {
      final route = m.data['route'] as String?;
      if (route != null) onOpenRoute?.call(route);
    });
  }

  Future<void> _register(String token) async {
    try {
      await guardApi(() => _ref.read(dioProvider).post<void>('/me/devices', data: {'fcmToken': token, 'platform': 'ANDROID'}));
    } catch (_) {
      // Retried on next start / token refresh.
    }
  }
}

final pushServiceProvider = Provider<PushService>((ref) => PushService(ref));
