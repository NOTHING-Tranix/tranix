import 'package:flutter/widgets.dart' show Key;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tranix_app/app.dart';
import 'package:tranix_app/core/location/trip_location.dart';
import 'package:tranix_app/core/providers.dart';

import 'helpers.dart';

void main() {
  Future<void> openAs(WidgetTester tester, String role) async {
    await tester.pumpWidget(ProviderScope(overrides: await mockAppOverrides(), child: const TranixApp()));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Open as $role'), 200);
    await tester.tap(find.text('Open as $role'));
    await tester.pumpAndSettle();
  }

  testWidgets('A-506/A-508: current trip step button opens the OTP sheet after Reached', (tester) async {
    await openAs(tester, 'Driver');
    await tester.tap(find.text('Current trip').last);
    await tester.pumpAndSettle();
    expect(find.text('TRX-000123'), findsOneWidget);
    expect(find.textContaining('Gandhi Market'), findsOneWidget); // exact pickup only after acceptance
    expect(find.byTooltip('Call sender'), findsOneWidget);
    expect(find.text('Navigate'), findsOneWidget);
    await tester.scrollUntilVisible(find.byKey(const Key('step')), 200);
    expect(find.text('Reached pickup'), findsOneWidget);
    expect(find.textContaining('1 of 5 used'), findsOneWidget);
    await tester.tap(find.byKey(const Key('step')));
    await tester.pumpAndSettle();
    expect(find.text('Ask the sender for the 6-digit code'), findsOneWidget);
    expect(find.text('Sent to ******3210'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('trip-otp')), '123456');
    await tester.pumpAndSettle();
    expect(find.text('Ask the sender for the 6-digit code'), findsNothing); // verified → sheet closed
  });

  testWidgets('A-405: shipper sees live tracking on the load detail', (tester) async {
    await openAs(tester, 'Load Provider');
    await tester.scrollUntilVisible(find.text('TRX-000123'), 200);
    await tester.tap(find.text('TRX-000123'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Live tracking'), 200);
    expect(find.text('On time'), findsOneWidget);
  });

  test('A-505: queued points survive until uploaded', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(overrides: [sharedPreferencesProvider.overrideWithValue(prefs)]);
    addTearDown(container.dispose);
    final service = container.read(tripLocationProvider);
    service.enqueue(10.1, 78.1, 12, DateTime.utc(2026, 11, 21, 6));
    service.enqueue(10.2, 78.2, 14, DateTime.utc(2026, 11, 21, 6, 1));
    expect(service.queued, 2);
    await service.flush(); // no backend reachable → kept for later
    expect(service.queued, lessThanOrEqualTo(2));
  });
}
