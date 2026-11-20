import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/session/session_controller.dart';
import '../../../shared/models/models.dart';
import '../data/auth_api.dart';

enum AuthMode { signUp, signIn }

/// What the user typed before the OTP page (kept while moving between pages).
class AuthDraft {
  const AuthDraft({required this.mode, required this.mobile, this.name, this.role});

  final AuthMode mode;
  final String mobile;
  final String? name;
  final Role? role;
}

/// Drives S-03 / S-04: send OTP → verify → session. Errors surface as [AppException] to the screens.
class AuthFlowController extends Notifier<AuthDraft?> {
  @override
  AuthDraft? build() => null;

  AuthApi get _api => ref.read(authApiProvider);

  Future<void> start(AuthDraft draft) async {
    await _api.sendOtp(draft.mobile, draft.mode == AuthMode.signUp ? OtpPurpose.signUp : OtpPurpose.signIn);
    state = draft;
  }

  Future<void> resend() async {
    final d = state;
    if (d == null) return;
    await _api.sendOtp(d.mobile, d.mode == AuthMode.signUp ? OtpPurpose.signUp : OtpPurpose.signIn);
  }

  Future<void> verify(String otp) async {
    final d = state;
    if (d == null) return;
    final session = ref.read(sessionProvider.notifier);
    final deviceId = await session.deviceId();
    final tokens = d.mode == AuthMode.signUp
        ? await _api.signUp(
            mobile: d.mobile,
            otp: otp,
            name: d.name!,
            role: d.role!,
            language: ref.read(languageProvider),
            deviceId: deviceId,
          )
        : await _api.signIn(mobile: d.mobile, otp: otp, deviceId: deviceId);
    await session.signedIn(tokens);
    state = null;
  }
}

final authFlowProvider = NotifierProvider<AuthFlowController, AuthDraft?>(AuthFlowController.new);
