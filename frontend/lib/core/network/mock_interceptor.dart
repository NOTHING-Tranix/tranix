import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Loads a fixture's text by file name (from `assets/mock/` in the app; from disk in tests).
typedef FixtureLoader = Future<String> Function(String fileName);

Future<String> assetFixtureLoader(String fileName) => rootBundle.loadString('assets/mock/$fileName');

class MockRoute {
  const MockRoute(this.method, this.pattern, {this.fixture, this.status = 200});

  final String method;
  final RegExp pattern;

  /// File in `assets/mock/`; null → empty body (e.g. 204).
  final String? fixture;
  final int status;
}

/// Answers API calls from JSON fixtures when the app runs with `--dart-define=USE_MOCK=true` (A-011).
/// Fixtures follow docs/api-contract.md exactly. Unknown routes return a `404 NOT_FOUND` problem.
/// [role] replaces `role` in `/me` and auth responses so the demo can open any role shell.
class MockInterceptor extends Interceptor {
  MockInterceptor({FixtureLoader? loader, this.latency = const Duration(milliseconds: 250)})
      : _load = loader ?? assetFixtureLoader;

  final FixtureLoader _load;
  final Duration latency;

  /// Role used by the mock `Me` (a contract `Role` value, e.g. `DRIVER`).
  static String role = 'LOAD_PROVIDER';

  static final routes = <MockRoute>[
    MockRoute('POST', RegExp(r'^/auth/otp/send$'), status: 204),
    MockRoute('POST', RegExp(r'^/auth/(sign-in|sign-up|refresh)$'), fixture: 'auth_tokens.json'),
    MockRoute('POST', RegExp(r'^/auth/sign-out$'), status: 204),
    MockRoute('GET', RegExp(r'^/me$'), fixture: 'me.json'),
    MockRoute('PUT', RegExp(r'^/me$'), fixture: 'me.json'),
    MockRoute('GET', RegExp(r'^/me/address$'), fixture: 'address.json'),
    MockRoute('GET', RegExp(r'^/me/role-profile$'), fixture: 'role_profile.json'),
    MockRoute('PUT', RegExp(r'^/me/role-profile$'), fixture: 'role_profile.json'),
    MockRoute('GET', RegExp(r'^/me/verification$'), fixture: 'verification.json'),
    MockRoute('POST', RegExp(r'^/me/verification/submit$'), fixture: 'verification.json'),
    MockRoute('POST', RegExp(r'^/me/documents$'), fixture: 'document.json'),
    MockRoute('PUT', RegExp(r'^/me/documents/[^/]+$'), fixture: 'document.json'),
    MockRoute('POST', RegExp(r'^/files$'), fixture: 'file.json'),
    MockRoute('POST', RegExp(r'^/me/mobile/change$'), status: 204),
    MockRoute('POST', RegExp(r'^/me/mobile/verify$'), fixture: 'me.json'),
    MockRoute('POST', RegExp(r'^/me/devices$'), status: 204),
    MockRoute('GET', RegExp(r'^/settings/public$'), fixture: 'settings_public.json'),
    MockRoute('GET', RegExp(r'^/wallet$'), fixture: 'wallet.json'),
    MockRoute('GET', RegExp(r'^/wallet/transactions$'), fixture: 'wallet_transactions.json'),
    MockRoute('GET', RegExp(r'^/loads$'), fixture: 'loads.json'),
    MockRoute('GET', RegExp(r'^/loads/[^/]+$'), fixture: 'load_detail.json'),
    MockRoute('GET', RegExp(r'^/driver/suggestions$'), fixture: 'driver_suggestions.json'),
    MockRoute('GET', RegExp(r'^/notifications/summary$'), fixture: 'notifications_summary.json'),
    MockRoute('GET', RegExp(r'^/notifications$'), fixture: 'notifications.json'),
    MockRoute('POST', RegExp(r'^/notifications/[^/]+/read$'), status: 204),
    MockRoute('POST', RegExp(r'^/notifications/read-all$'), status: 204),
    MockRoute('POST', RegExp(r'^/wallet/topup-link$'), fixture: 'topup_link.json'),
  ];

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);
    final path = Uri.parse(options.path).path;
    final route = routes.where((r) => r.method == options.method && r.pattern.hasMatch(path)).firstOrNull;

    if (route == null) {
      handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.badResponse,
          response: Response<dynamic>(
            requestOptions: options,
            statusCode: 404,
            data: {
              'type': 'about:blank',
              'title': 'Not found',
              'status': 404,
              'code': 'NOT_FOUND',
              'detail': 'No mock for ${options.method} $path',
              'fields': <dynamic>[],
            },
          ),
        ),
        true,
      );
      return;
    }

    dynamic data;
    if (route.fixture != null) {
      data = jsonDecode(await _load(route.fixture!));
      data = _applyRole(path, data);
    }
    handler.resolve(Response<dynamic>(requestOptions: options, statusCode: route.status, data: data), true);
  }

  static dynamic _applyRole(String path, dynamic data) {
    if (data is! Map<String, dynamic>) return data;
    if (path == '/me') return {...data, 'role': role};
    if (path.startsWith('/auth/') && data['user'] is Map<String, dynamic>) {
      return {
        ...data,
        'user': {...data['user'] as Map<String, dynamic>, 'role': role},
      };
    }
    return data;
  }
}
