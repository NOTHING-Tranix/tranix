import 'dart:async';

import 'package:flutter/widgets.dart' show Key;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart' show Scaffold;
import 'package:tranix_app/app.dart';
import 'package:tranix_app/core/router/app_router.dart';
import 'package:tranix_app/core/session/session_controller.dart';
import 'package:tranix_app/features/shared_shell/tab_screens.dart' show ProfileAvatarButton;

import 'helpers.dart';

void main() {
  test('A-1101: legal pages are reachable signed out', () {
    expect(redirectFor(const SignedOut(), '/legal/privacy'), isNull);
    expect(redirectFor(const SignedOut(), '/loads/x'), isNot(isNull));
  });

  testWidgets('A-1101: privacy policy shows the draft notice; delete account opens a request', (tester) async {
    await tester.pumpWidget(ProviderScope(overrides: await mockAppOverrides(), child: const TranixApp()));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Open as Load Provider'), 200);
    await tester.tap(find.text('Open as Load Provider'));
    await tester.pumpAndSettle();
    unawaited(GoRouter.of(tester.element(find.byType(Scaffold).first)).push('/legal/privacy'));
    await tester.pumpAndSettle();
    expect(find.text('Draft — pending legal review'), findsOneWidget);
    expect(find.textContaining('draft pending legal review'), findsOneWidget);

    GoRouter.of(tester.element(find.byType(Scaffold).first)).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ProfileAvatarButton).first);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('menu-delete')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('menu-delete')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('delete-reason')), 'Closing the business');
    await tester.tap(find.text('Delete account').last);
    await tester.pumpAndSettle();
    expect(find.text('TKT-000012'), findsOneWidget); // the request opened as a support ticket
  });
}
