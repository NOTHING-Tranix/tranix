import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tranix_app/app.dart';
import 'package:tranix_app/core/router/app_router.dart';
import 'package:tranix_app/core/router/routes.dart';
import 'package:tranix_app/core/session/session_controller.dart';
import 'package:tranix_app/shared/models/models.dart';

import 'helpers.dart';

Me _me(Role role) => Me(id: '1', name: 'N', mobile: '9876543210', role: role);

void main() {
  group('A-010 redirects', () {
    test('unknown session stays on splash', () {
      expect(redirectFor(const SessionUnknown(), Routes.lp), Routes.splash);
      expect(redirectFor(const SessionUnknown(), Routes.splash), isNull);
    });

    test('signed out goes to welcome, public pages allowed', () {
      expect(redirectFor(const SignedOut(), Routes.splash), Routes.welcome);
      expect(redirectFor(const SignedOut(), '/driver/trip'), Routes.welcome);
      expect(redirectFor(const SignedOut(), Routes.signIn), isNull);
    });

    test('signed in goes to own role shell and cannot enter another', () {
      final driver = SignedIn(_me(Role.driver));
      expect(redirectFor(driver, Routes.welcome), Routes.driver);
      expect(redirectFor(driver, '/lp/tracking'), Routes.driver);
      expect(redirectFor(driver, '/driver/suggestions'), isNull);
      expect(redirectFor(SignedIn(_me(Role.farmerNetwork)), Routes.splash), Routes.fn);
      expect(redirectFor(SignedIn(_me(Role.admin)), Routes.splash), Routes.unsupported);
    });
  });

  testWidgets('M0 demo: mock app opens, demo sign-in shows loads, sign out returns to welcome', (tester) async {
    final overrides = await mockAppOverrides();
    await tester.pumpWidget(ProviderScope(overrides: overrides, child: const TranixApp()));
    await tester.pumpAndSettle();

    expect(find.text('Sign up'), findsOneWidget);
    expect(find.text('Demo (mock data)'), findsOneWidget);

    await tester.tap(find.text('Open as Load Provider'));
    await tester.pumpAndSettle();

    expect(find.text('TRX-000123'), findsOneWidget);
    expect(find.text('Traveling'), findsOneWidget);
    expect(find.text('Wish list'), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Murugan Traders'), findsOneWidget);

    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    expect(find.text('Sign up'), findsOneWidget);
  });

  testWidgets('language switch to Tamil changes the UI', (tester) async {
    final overrides = await mockAppOverrides();
    await tester.pumpWidget(ProviderScope(overrides: overrides, child: const TranixApp()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('தமிழ்'));
    await tester.pumpAndSettle();
    expect(find.text('பதிவு செய்'), findsOneWidget);
  });
}
