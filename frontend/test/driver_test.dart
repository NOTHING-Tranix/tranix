import 'package:flutter/widgets.dart' show Key;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tranix_app/app.dart';

import 'helpers.dart';

void main() {
  Future<void> openAsDriver(WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(overrides: await mockAppOverrides(), child: const TranixApp()));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Open as Driver'), 200);
    await tester.tap(find.text('Open as Driver'));
    await tester.pumpAndSettle();
  }

  testWidgets('A-501: driver home shows invitation, duty switch, truck and expiring documents', (tester) async {
    await openAsDriver(tester);
    expect(find.text('Sri Transports invited you to drive for them'), findsOneWidget);
    expect(find.text('Accept'), findsOneWidget);
    expect(find.text('Off duty'), findsOneWidget);
    expect(find.text('Go on duty to get trip suggestions'), findsOneWidget);
    expect(find.text('1 trip suggestions'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('TN57AB1234'), 200);
    expect(find.text('Available'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Insurance'), 200);
    expect(find.text('Insurance'), findsOneWidget);
    await tester.scrollUntilVisible(find.byKey(const Key('duty')), -200);
    await tester.tap(find.byKey(const Key('duty')));
    await tester.pumpAndSettle();
  });

  testWidgets('A-502: own truck form is prefilled with documents; locker lists documents', (tester) async {
    await openAsDriver(tester);
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('My truck'));
    await tester.pumpAndSettle();
    expect(find.text('TN57AB1234'), findsOneWidget);
    expect(find.text('Truck documents'), findsOneWidget);
    expect(find.text('RC book'), findsOneWidget);
  });
}
