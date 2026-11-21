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
    MockRoute('POST', RegExp(r'^/loads/estimate$'), fixture: 'estimate.json'),
    MockRoute('POST', RegExp(r'^/loads$'), fixture: 'load_detail.json'),
    MockRoute('PUT', RegExp(r'^/loads/[^/]+$'), fixture: 'load_detail.json'),
    MockRoute('POST', RegExp(r'^/loads/[^/]+/(cancel|repost)$'), fixture: 'load_detail.json'),
    MockRoute('GET', RegExp(r'^/driver/suggestions$'), fixture: 'driver_suggestions.json'),
    MockRoute('GET', RegExp(r'^/driver/home$'), fixture: 'driver_home.json'),
    MockRoute('GET', RegExp(r'^/driver/current-trip$'), fixture: 'current_trip.json'),
    MockRoute('POST', RegExp(r'^/driver/trips/[^/]+/reached$'), fixture: 'reached.json'),
    MockRoute('POST', RegExp(r'^/driver/trips/[^/]+/otp/verify$'), fixture: 'load_detail.json'),
    MockRoute('POST', RegExp(r'^/driver/trips/[^/]+/otp/(resend|help)$'), status: 204),
    MockRoute('POST', RegExp(r'^/driver/trips/[^/]+/(revisions|cancel)$'), fixture: 'current_trip.json'),
    MockRoute('POST', RegExp(r'^/driver/trips/[^/]+/locations$'), status: 204),
    MockRoute('GET', RegExp(r'^/map/route-services$'), fixture: 'route_services.json'),
    MockRoute('GET', RegExp(r'^/map/restrictions$'), fixture: 'route_services.json'),
    MockRoute('GET', RegExp(r'^/loads/[^/]+/tracking$'), fixture: 'tracking.json'),
    MockRoute('GET', RegExp(r'^/loads/[^/]+/otp$'), fixture: 'otp.json'),
    MockRoute('POST', RegExp(r'^/loads/[^/]+/revisions/[^/]+/(confirm|reject)$'), fixture: 'load_detail.json'),
    MockRoute('POST', RegExp(r'^/driver/suggestions/[^/]+/accept$'), fixture: 'load_detail.json'),
    MockRoute('POST', RegExp(r'^/driver/suggestions/[^/]+/reject$'), status: 204),
    MockRoute('PUT', RegExp(r'^/driver/duty$'), status: 204),
    MockRoute('GET', RegExp(r'^/driver/truck$'), fixture: 'driver_truck.json'),
    MockRoute('POST', RegExp(r'^/driver/truck$'), fixture: 'driver_truck.json'),
    MockRoute('PUT', RegExp(r'^/driver/truck$'), fixture: 'driver_truck.json'),
    MockRoute('POST', RegExp(r'^/driver/truck/documents$'), fixture: 'document.json'),
    MockRoute('GET', RegExp(r'^/driver/invitations$'), fixture: 'invitations.json'),
    MockRoute('POST', RegExp(r'^/driver/invitations/[^/]+/(accept|reject)$'), status: 204),
    MockRoute('GET', RegExp(r'^/notifications/summary$'), fixture: 'notifications_summary.json'),
    MockRoute('GET', RegExp(r'^/notifications$'), fixture: 'notifications.json'),
    MockRoute('POST', RegExp(r'^/notifications/[^/]+/read$'), status: 204),
    MockRoute('POST', RegExp(r'^/notifications/read-all$'), status: 204),
    MockRoute('POST', RegExp(r'^/wallet/topup-link$'), fixture: 'topup_link.json'),
    MockRoute('POST', RegExp(r'^/loads/[^/]+/payment/mark-paid$'), fixture: 'payment.json'),
    MockRoute('POST', RegExp(r'^/driver/trips/[^/]+/payment/(confirm|dispute)$'), fixture: 'payment.json'),
    MockRoute('GET', RegExp(r'^/driver/history$'), fixture: 'driver_history.json'),
    MockRoute('GET', RegExp(r'^/ratings/pending$'), fixture: 'pending_ratings.json'),
    MockRoute('POST', RegExp(r'^/ratings$'), status: 204),
    MockRoute('POST', RegExp(r'^/ratings/[^/]+/later$'), status: 204),
    MockRoute('GET', RegExp(r'^/trust-score$'), fixture: 'trust_score.json'),
    MockRoute('GET', RegExp(r'^/trust-score/events$'), fixture: 'trust_events.json'),
    MockRoute('GET', RegExp(r'^/wishlist$'), fixture: 'wishlist.json'),
    MockRoute('POST', RegExp(r'^/wishlist$'), fixture: 'wishlist_entry.json'),
    MockRoute('PUT', RegExp(r'^/wishlist/[^/]+$'), fixture: 'wishlist_entry.json'),
    MockRoute('DELETE', RegExp(r'^/wishlist/[^/]+$'), status: 204),
    MockRoute('GET', RegExp(r'^/wishlist/org-search$'), fixture: 'org_search.json'),
    MockRoute('GET', RegExp(r'^/wishlist/candidates$'), fixture: 'wishlist_candidates.json'),
    MockRoute('POST', RegExp(r'^/loads/[^/]+/open-to-everyone$'), fixture: 'load_detail.json'),
    MockRoute('GET', RegExp(r'^/farmers$'), fixture: 'farmers.json'),
    MockRoute('POST', RegExp(r'^/farmers$'), fixture: 'farmer.json'),
    MockRoute('PUT', RegExp(r'^/farmers/[^/]+$'), fixture: 'farmer.json'),
    MockRoute('POST', RegExp(r'^/farmers/[^/]+/deactivate$'), fixture: 'farmer.json'),
    MockRoute('GET', RegExp(r'^/org/dashboard$'), fixture: 'org_dashboard.json'),
    MockRoute('GET', RegExp(r'^/org/trucks$'), fixture: 'org_trucks.json'),
    MockRoute('POST', RegExp(r'^/org/trucks$'), fixture: 'driver_truck.json'),
    MockRoute('PUT', RegExp(r'^/org/trucks/[^/]+$'), fixture: 'driver_truck.json'),
    MockRoute('POST', RegExp(r'^/org/trucks/[^/]+/deactivate$'), fixture: 'driver_truck.json'),
    MockRoute('POST', RegExp(r'^/org/trucks/[^/]+/documents$'), fixture: 'document.json'),
    MockRoute('GET', RegExp(r'^/org/trucks/[^/]+/location$'), fixture: 'org_location.json'),
    MockRoute('GET', RegExp(r'^/org/drivers$'), fixture: 'org_drivers.json'),
    MockRoute('POST', RegExp(r'^/org/drivers$'), status: 204),
    MockRoute('GET', RegExp(r'^/org/drivers/[^/]+/performance$'), fixture: 'org_performance.json'),
    MockRoute('GET', RegExp(r'^/org/allocations$'), fixture: 'org_allocations.json'),
    MockRoute('POST', RegExp(r'^/org/allocations$'), status: 204),
    MockRoute('PUT', RegExp(r'^/org/allocations/[^/]+$'), status: 204),
    MockRoute('DELETE', RegExp(r'^/org/allocations/[^/]+$'), status: 204),
    MockRoute('GET', RegExp(r'^/org/trips$'), fixture: 'org_trips.json'),
    MockRoute('GET', RegExp(r'^/receiver/loads$'), fixture: 'receiver_loads.json'),
    MockRoute('GET', RegExp(r'^/receiver/loads/[^/]+$'), fixture: 'receiver_load.json'),
    MockRoute('POST', RegExp(r'^/receiver/loads/[^/]+/receipt$'), status: 204),
    MockRoute('GET', RegExp(r'^/tickets$'), fixture: 'tickets.json'),
    MockRoute('POST', RegExp(r'^/tickets$'), fixture: 'ticket.json'),
    MockRoute('GET', RegExp(r'^/tickets/[^/]+$'), fixture: 'ticket.json'),
    MockRoute('POST', RegExp(r'^/tickets/[^/]+/(messages|reopen)$'), fixture: 'ticket.json'),
    MockRoute('GET', RegExp(r'^/legal/(privacy|terms)$'), fixture: 'legal.json'),
    MockRoute('POST', RegExp(r'^/me/deletion-request$'), fixture: 'ticket.json'),
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
