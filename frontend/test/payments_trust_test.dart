import 'dart:io';

import 'package:flutter/widgets.dart' show Key;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tranix_app/app.dart';

import 'helpers.dart';

void main() {
  Future<void> openAs(WidgetTester tester, String role, {Map<String, String> patch = const {}}) async {
    await tester.pumpWidget(ProviderScope(overrides: await mockAppOverrides(patch: patch), child: const TranixApp()));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Open as $role'), 200);
    await tester.tap(find.text('Open as $role'));
    await tester.pumpAndSettle();
  }

  testWidgets('A-407: shipper marks a payment as paid from the load detail', (tester) async {
    await openAs(tester, 'Load Provider');
    await tester.scrollUntilVisible(find.text('TRX-000123'), 200);
    await tester.tap(find.text('TRX-000123'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Mark as paid'), 200);
    expect(find.text('Payment pending'), findsOneWidget);
    await tester.tap(find.text('Mark as paid'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('pay-amount')), findsOneWidget);
    await tester.tap(find.text('Mark as paid').last);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('pay-amount')), findsNothing);
  });

  testWidgets('A-510: driver history shows the month summary and confirm/dispute', (tester) async {
    await openAs(tester, 'Driver');
    await tester.tap(find.text('History').last);
    await tester.pumpAndSettle();
    expect(find.text('This month'), findsOneWidget);
    expect(find.text('2 trips'), findsOneWidget);
    expect(find.text('TRX-000123'), findsOneWidget);
    expect(find.text('Confirm received'), findsOneWidget); // only the PAID trip
    await tester.tap(find.text('Dispute'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('dispute-reason')), 'Got less');
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm received'));
    await tester.pumpAndSettle();
    expect(find.text('This month'), findsOneWidget);
  });

  testWidgets('A-601: rating pop-up on open, with Later', (tester) async {
    String bump(String f) => File('assets/mock/$f').readAsStringSync().replaceFirst('"pendingRatingsCount": 0', '"pendingRatingsCount": 1');
    await openAs(tester, 'Load Provider', patch: {'me.json': bump('me.json'), 'auth_tokens.json': bump('auth_tokens.json')});
    expect(find.text('Rate Murugan K'), findsOneWidget);
    expect(find.text('Submit'), findsOneWidget);
    await tester.tap(find.byKey(const Key('star-5')));
    await tester.pump();
    await tester.tap(find.text('Later'));
    await tester.pumpAndSettle();
    expect(find.text('Rate Murugan K'), findsNothing);
  });

  testWidgets('A-602: Trust Score screen shows score, events and how it works', (tester) async {
    await openAs(tester, 'Load Provider');
    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('trust-badge')));
    await tester.pumpAndSettle();
    expect(find.text('74.5'), findsOneWidget);
    expect(find.text('Trip on time'), findsOneWidget);
    expect(find.text('+2'), findsOneWidget);
    expect(find.text('-1'), findsOneWidget);
    await tester.tap(find.text('How it works'));
    await tester.pumpAndSettle();
    expect(find.textContaining('starts at 70'), findsOneWidget);
  });
}
