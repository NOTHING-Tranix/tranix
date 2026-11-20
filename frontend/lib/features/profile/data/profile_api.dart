import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/interceptors.dart';
import '../../../core/providers.dart';
import '../../../shared/models/models.dart';

/// Contract §4.
class ProfileApi {
  ProfileApi(this._dio);

  final Dio _dio;

  Dio get dio => _dio;

  Future<Me> me() async => Me.fromJson((await guardApi(() => _dio.get<Map<String, dynamic>>('/me'))).data!);

  Future<Me> updateMe({required String name, String? email, required Language language, Address? address}) async {
    final res = await guardApi(() => _dio.put<Map<String, dynamic>>('/me', data: {
          'name': name,
          if (email != null && email.isNotEmpty) 'email': email,
          'language': language.name,
          if (address != null) 'address': address.toJson(),
        }));
    return Me.fromJson(res.data!);
  }

  Future<Address?> address() async {
    final res = await guardApi(() => _dio.get<dynamic>('/me/address'));
    return res.data is Map<String, dynamic> ? Address.fromJson(res.data as Map<String, dynamic>) : null;
  }

  Future<Map<String, dynamic>> roleProfile() async =>
      (await guardApi(() => _dio.get<Map<String, dynamic>>('/me/role-profile'))).data ?? {};

  Future<Map<String, dynamic>> saveRoleProfile(Map<String, dynamic> body) async =>
      (await guardApi(() => _dio.put<Map<String, dynamic>>('/me/role-profile', data: body))).data!;

  Future<VerificationInfo> verification() async =>
      VerificationInfo.fromJson((await guardApi(() => _dio.get<Map<String, dynamic>>('/me/verification'))).data!);

  Future<VerificationInfo> submit() async => VerificationInfo.fromJson(
        (await guardApi(() => _dio.post<Map<String, dynamic>>('/me/verification/submit'))).data!,
      );

  Future<Document> saveDocument({
    String? replaceId,
    required DocumentType type,
    required List<String> fileIds,
    String? number,
    DateTime? expiresOn,
  }) async {
    final body = {
      if (replaceId == null) 'type': _docType(type),
      'fileIds': fileIds,
      if (number != null && number.isNotEmpty) 'number': number,
      if (expiresOn != null) 'expiresOn': expiresOn.toIso8601String().substring(0, 10),
    };
    final res = await guardApi(() => replaceId == null
        ? _dio.post<Map<String, dynamic>>('/me/documents', data: body)
        : _dio.put<Map<String, dynamic>>('/me/documents/$replaceId', data: body));
    return Document.fromJson(res.data!);
  }

  Future<void> changeMobile(String mobile) =>
      guardApi(() => _dio.post<void>('/me/mobile/change', data: {'mobile': mobile}));

  Future<Me> verifyMobile(String mobile, String otp) async => Me.fromJson(
        (await guardApi(() => _dio.post<Map<String, dynamic>>('/me/mobile/verify', data: {'mobile': mobile, 'otp': otp})))
            .data!,
      );

  static String _docType(DocumentType t) =>
      t.name.replaceAllMapped(RegExp('[A-Z]'), (m) => '_${m[0]}').toUpperCase();
}

final profileApiProvider = Provider<ProfileApi>((ref) => ProfileApi(ref.watch(dioProvider)));
