import 'dart:async';

import 'package:flutter/widgets.dart' show Key;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart' show Scaffold;
import 'package:tranix_app/app.dart';

import 'helpers.dart';

void main() {
  Future<void> openSupport(WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(overrides: await mockAppOverrides(), child: const TranixApp()));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Open as Load Provider'), 200);
    await tester.tap(find.text('Open as Load Provider'));
    await tester.pumpAndSettle();
    unawaited(GoRouter.of(tester.element(find.byType(Scaffold).first)).push('/support'));
    await tester.pumpAndSettle();
  }

  testWidgets('A-305: support list with unread dot, thread, new request form', (tester) async {
    await openSupport(tester);
    expect(find.text('TKT-000012 · Wallet'), findsOneWidget);
    await tester.tap(find.text('TKT-000012 · Wallet'));
    await tester.pumpAndSettle();
    expect(find.text('Credited now, sorry for the delay.'), findsOneWidget);
    expect(find.text('Tranix support'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('t-message')), 'Thanks');
    await tester.tap(find.byTooltip('Send'));
    await tester.pumpAndSettle();

    GoRouter.of(tester.element(find.byType(Scaffold).first)).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('New request'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();
    expect(find.text('Required'), findsWidgets); // trip + description required for a complaint
  });
}
