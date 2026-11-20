import 'dart:async';

import 'package:dio/dio.dart';

import '../errors/app_exception.dart';
import '../storage/token_store.dart';

/// Adds `Accept-Language: en|ta|hi`.
class LanguageInterceptor extends Interceptor {
  LanguageInterceptor(this.language);

  final String Function() language;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Accept-Language'] = language();
    handler.next(options);
  }
}

/// Adds the access token, except on `/auth/**` calls.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this.tokens);

  final TokenStore tokens;

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (!options.path.startsWith('/auth/')) {
      final stored = await tokens.read();
      if (stored != null) {
        options.headers['Authorization'] = 'Bearer ${stored.accessToken}';
      }
    }
    handler.next(options);
  }
}

/// On `401 TOKEN_EXPIRED`: one shared `POST /auth/refresh` for all waiting calls (single flight), then retry the
/// original request once. If refresh fails, clears tokens and calls [onSessionExpired].
class RefreshInterceptor extends Interceptor {
  RefreshInterceptor({
    required this.dio,
    required this.refreshDio,
    required this.tokens,
    required this.onSessionExpired,
  });

  /// The main client, used to retry the original request.
  final Dio dio;

  /// A client without this interceptor, used for `/auth/refresh`.
  final Dio refreshDio;
  final TokenStore tokens;
  final void Function() onSessionExpired;

  Future<bool>? _refreshing;

  static const _retriedKey = 'tranix.retried';

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final response = err.response;
    final isExpired = response?.statusCode == 401 &&
        response?.data is Map &&
        (response!.data as Map)['code'] == ApiErrorCode.tokenExpired;
    final alreadyRetried = err.requestOptions.extra[_retriedKey] == true;
    if (!isExpired || alreadyRetried || err.requestOptions.path.startsWith('/auth/')) {
      handler.next(err);
      return;
    }

    final refreshed = await (_refreshing ??= _refresh().whenComplete(() => _refreshing = null));
    if (!refreshed) {
      handler.next(err);
      return;
    }
    try {
      final stored = await tokens.read();
      final options = err.requestOptions
        ..extra[_retriedKey] = true
        ..headers['Authorization'] = 'Bearer ${stored?.accessToken}';
      handler.resolve(await dio.fetch<dynamic>(options));
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  Future<bool> _refresh() async {
    final stored = await tokens.read();
    if (stored == null) {
      onSessionExpired();
      return false;
    }
    try {
      final res = await refreshDio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': stored.refreshToken},
      );
      final data = res.data!;
      await tokens.write(StoredTokens(
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String,
      ));
      return true;
    } on DioException {
      await tokens.clear();
      onSessionExpired();
      return false;
    }
  }
}

/// Puts an [AppException] into every [DioException.error], so callers only handle one type.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(err.copyWith(error: toAppException(err)));
  }

  static AppException toAppException(DioException err) {
    if (err.error is AppException) return err.error! as AppException;
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const AppException(kind: AppErrorKind.timeout);
      case DioExceptionType.connectionError:
        return const AppException(kind: AppErrorKind.network);
      case DioExceptionType.badResponse:
        return AppException.fromProblem(err.response?.statusCode, err.response?.data);
      case DioExceptionType.unknown:
        // SocketException and similar arrive here on mobile.
        return const AppException(kind: AppErrorKind.network);
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
        return const AppException(kind: AppErrorKind.unknown);
    }
  }
}

/// Runs a dio call and rethrows failures as [AppException].
Future<T> guardApi<T>(Future<T> Function() call) async {
  try {
    return await call();
  } on DioException catch (e) {
    throw ErrorInterceptor.toAppException(e);
  }
}
