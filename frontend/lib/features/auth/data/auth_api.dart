import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/interceptors.dart';
import '../../../core/providers.dart';
import '../../../shared/models/models.dart';

/// Contract §3.
class AuthApi {
  AuthApi(this._dio);

  final Dio _dio;

  Future<void> sendOtp(String mobile, OtpPurpose purpose) => guardApi(
        () => _dio.post<void>('/auth/otp/send', data: {'mobile': mobile, 'purpose': _purpose(purpose)}),
      );

  Future<AuthTokens> signUp({
    required String mobile,
    required String otp,
    required String name,
    required Role role,
    required Language language,
    required String deviceId,
  }) async {
    final res = await guardApi(() => _dio.post<Map<String, dynamic>>('/auth/sign-up', data: {
          'mobile': mobile,
          'otp': otp,
          'name': name,
          'role': _role(role),
          'consent': true,
          'language': language.name,
          'deviceId': deviceId,
        }));
    return AuthTokens.fromJson(res.data!);
  }

  Future<AuthTokens> signIn({required String mobile, required String otp, required String deviceId}) async {
    final res = await guardApi(() => _dio.post<Map<String, dynamic>>(
          '/auth/sign-in',
          data: {'mobile': mobile, 'otp': otp, 'deviceId': deviceId},
        ));
    return AuthTokens.fromJson(res.data!);
  }

  static String _purpose(OtpPurpose p) => p == OtpPurpose.signUp ? 'SIGN_UP' : 'SIGN_IN';

  static String _role(Role r) => r.name.replaceAllMapped(RegExp('[A-Z]'), (m) => '_${m[0]}').toUpperCase();
}

final authApiProvider = Provider<AuthApi>((ref) => AuthApi(ref.watch(dioProvider)));
