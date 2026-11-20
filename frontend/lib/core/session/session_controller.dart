import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../shared/models/auth.dart';
import '../errors/app_exception.dart';
import '../network/interceptors.dart';
import '../providers.dart';
import '../storage/token_store.dart';

/// Where the app is in the sign-in lifecycle. The router redirects on this.
sealed class SessionState {
  const SessionState();
}

/// App start: tokens not checked yet (splash).
class SessionUnknown extends SessionState {
  const SessionUnknown();
}

/// Start-up check failed for a reason other than "not signed in" (e.g. offline) — splash shows retry.
class SessionError extends SessionState {
  const SessionError(this.error);

  final AppException error;
}

class SignedOut extends SessionState {
  const SignedOut();
}

class SignedIn extends SessionState {
  const SignedIn(this.me);

  final Me me;
}

/// Holds `Me` + tokens (architecture.md "Auth and session"). Screens for sign-up/sign-in come in M1 (A-101…A-105).
class SessionController extends Notifier<SessionState> {
  @override
  SessionState build() => const SessionUnknown();

  TokenStore get _tokens => ref.read(tokenStoreProvider);

  /// Splash: tokens → `POST /auth/refresh` → `GET /me`.
  Future<void> bootstrap() async {
    final stored = await _tokens.read();
    if (stored == null) {
      state = const SignedOut();
      return;
    }
    try {
      final dio = ref.read(dioProvider);
      final res = await guardApi(
        () => dio.post<Map<String, dynamic>>('/auth/refresh', data: {'refreshToken': stored.refreshToken}),
      );
      await _save(AuthTokens.fromJson(res.data!));
      final me = await guardApi(() => dio.get<Map<String, dynamic>>('/me'));
      state = SignedIn(Me.fromJson(me.data!));
    } on AppException catch (e) {
      if (e.kind == AppErrorKind.server && (e.status == 401 || e.status == 403)) {
        await _tokens.clear();
        state = const SignedOut();
      } else {
        state = SessionError(e);
      }
    }
  }

  /// After `POST /auth/sign-in` or `/auth/sign-up`.
  Future<void> signedIn(AuthTokens tokens) async {
    await _save(tokens);
    state = SignedIn(tokens.user);
  }

  /// Updates the cached `Me` (e.g. after `GET /me`).
  void updateMe(Me me) {
    if (state is SignedIn) state = SignedIn(me);
  }

  Future<void> signOut() async {
    final stored = await _tokens.read();
    if (stored != null) {
      try {
        await ref.read(dioProvider).post<void>('/auth/sign-out', data: {'refreshToken': stored.refreshToken});
      } catch (_) {
        // Best effort; local sign-out always happens.
      }
    }
    await _tokens.clear();
    state = const SignedOut();
  }

  /// Called by the refresh interceptor when the refresh token is no longer valid.
  void onSessionExpired() {
    state = const SignedOut();
  }

  /// Install id sent at sign-in.
  Future<String> deviceId() async {
    final existing = await _tokens.readDeviceId();
    if (existing != null) return existing;
    final id = const Uuid().v4();
    await _tokens.writeDeviceId(id);
    return id;
  }

  Future<void> _save(AuthTokens t) =>
      _tokens.write(StoredTokens(accessToken: t.accessToken, refreshToken: t.refreshToken));
}

final sessionProvider = NotifierProvider<SessionController, SessionState>(SessionController.new);
