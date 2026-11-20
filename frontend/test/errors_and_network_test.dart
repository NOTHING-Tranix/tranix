import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tranix_app/core/errors/app_exception.dart';
import 'package:tranix_app/core/errors/error_messages.dart';
import 'package:tranix_app/core/l10n/generated/app_localizations.dart';
import 'package:tranix_app/core/network/interceptors.dart';
import 'package:tranix_app/core/storage/token_store.dart';

/// Answers requests from a handler function.
class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.handler);

  final ResponseBody Function(RequestOptions o) handler;
  final calls = <String>[];

  @override
  Future<ResponseBody> fetch(RequestOptions o, Stream<Uint8List>? body, Future<void>? cancel) async {
    calls.add('${o.method} ${o.path}');
    await Future<void>.delayed(const Duration(milliseconds: 5));
    return handler(o);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody json(int status, Object body) => ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
    );

Map<String, Object> problem(int status, String code) =>
    {'type': 'about:blank', 'title': 't', 'status': status, 'code': code, 'detail': 'd', 'fields': <Object>[]};

void main() {
  test('A-009: every contract error code has a message in en, ta and hi', () {
    for (final locale in AppLocalizations.supportedLocales) {
      final l = lookupAppLocalizations(Locale(locale.languageCode));
      for (final code in ApiErrorCode.all) {
        expect(messageForCode(l, code), isNotNull, reason: '$code missing in ${locale.languageCode}');
      }
      expect(messageForCode(l, 'BRAND_NEW_CODE'), isNull);
      expect(errorMessage(l, const AppException(kind: AppErrorKind.network)), l.errorNetwork);
    }
  });

  test('ErrorInterceptor turns a problem body into AppException with fields', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://x'))..interceptors.add(ErrorInterceptor());
    dio.httpClientAdapter = FakeAdapter((_) => json(400, {
          ...problem(400, ApiErrorCode.validationFailed),
          'fields': [
            {'field': 'mobile', 'message': 'invalid'},
          ],
        }));
    final e = await guardApi(() => dio.get<void>('/x')).then<AppException?>((_) => null, onError: (Object e) => e as AppException);
    expect(e!.code, ApiErrorCode.validationFailed);
    expect(e.fieldError('mobile'), 'invalid');
  });

  test('RefreshInterceptor refreshes once for parallel 401 TOKEN_EXPIRED and retries', () async {
    final tokens = InMemoryTokenStore();
    await tokens.write(const StoredTokens(accessToken: 'old', refreshToken: 'r1'));
    var expired = 0;
    final dio = Dio(BaseOptions(baseUrl: 'http://x'));
    final refreshDio = Dio(BaseOptions(baseUrl: 'http://x'));
    final refreshAdapter = FakeAdapter((_) => json(200, {'accessToken': 'new', 'refreshToken': 'r2'}));
    refreshDio.httpClientAdapter = refreshAdapter;
    dio.httpClientAdapter = FakeAdapter((o) {
      if (o.headers['Authorization'] == 'Bearer new') return json(200, {'ok': true});
      expired++;
      return json(401, problem(401, ApiErrorCode.tokenExpired));
    });
    var sessionExpired = false;
    dio.interceptors.addAll([
      AuthInterceptor(tokens),
      RefreshInterceptor(dio: dio, refreshDio: refreshDio, tokens: tokens, onSessionExpired: () => sessionExpired = true),
      ErrorInterceptor(),
    ]);

    final results = await Future.wait([dio.get<dynamic>('/a'), dio.get<dynamic>('/b'), dio.get<dynamic>('/c')]);

    expect(results.every((r) => r.statusCode == 200), isTrue);
    expect(expired, 3);
    expect(refreshAdapter.calls, ['POST /auth/refresh'], reason: 'single flight');
    expect((await tokens.read())!.refreshToken, 'r2');
    expect(sessionExpired, isFalse);
  });

  test('RefreshInterceptor signs out when refresh fails', () async {
    final tokens = InMemoryTokenStore();
    await tokens.write(const StoredTokens(accessToken: 'old', refreshToken: 'r1'));
    final dio = Dio(BaseOptions(baseUrl: 'http://x'));
    final refreshDio = Dio(BaseOptions(baseUrl: 'http://x'))
      ..httpClientAdapter = FakeAdapter((_) => json(401, problem(401, ApiErrorCode.unauthenticated)));
    dio.httpClientAdapter = FakeAdapter((_) => json(401, problem(401, ApiErrorCode.tokenExpired)));
    var sessionExpired = false;
    dio.interceptors.addAll([
      RefreshInterceptor(dio: dio, refreshDio: refreshDio, tokens: tokens, onSessionExpired: () => sessionExpired = true),
      ErrorInterceptor(),
    ]);
    await expectLater(guardApi(() => dio.get<void>('/a')), throwsA(isA<AppException>()));
    expect(sessionExpired, isTrue);
    expect(await tokens.read(), isNull);
  });
}
