import 'package:flutter/widgets.dart' show Key;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tranix_app/app.dart';

import 'helpers.dart';

void main() {
  Future<void> openAsLoadProvider(WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(overrides: await mockAppOverrides(), child: const TranixApp()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open as Load Provider'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
  }

  testWidgets('A-201: profile shows completion, status and sections', (tester) async {
    await openAsLoadProvider(tester);
    expect(find.text('100%'), findsOneWidget);
    expect(find.text('Murugan Traders'), findsOneWidget);
    expect(find.text('Verified'), findsWidgets);
    expect(find.text('Name, email and address'), findsOneWidget);
    expect(find.text('Account details'), findsOneWidget);
  });

  testWidgets('A-204: verification screen lists items and a rejected document to upload again', (tester) async {
    await openAsLoadProvider(tester);
    await tester.tap(find.text('Verification'));
    await tester.pumpAndSettle();
    expect(find.text('Under review'), findsOneWidget);
    expect(find.textContaining('about 24 hours'), findsOneWidget);
    expect(find.text('PAN card'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Reason: Face not clear'), 200);
    expect(find.text('Reason: Face not clear'), findsOneWidget);
    expect(find.text('Upload again'), findsOneWidget);
  });

  testWidgets('edit basics validates PIN and prefills the address', (tester) async {
    await openAsLoadProvider(tester);
    await tester.tap(find.text('Name, email and address'));
    await tester.pumpAndSettle();
    expect(find.text('Oddanchatram'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('f-pin')), '012');
    await tester.ensureVisible(find.text('Save'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a 6-digit PIN code'), findsOneWidget);
  });

  testWidgets('role profile form for a Load Provider is prefilled', (tester) async {
    await openAsLoadProvider(tester);
    await tester.tap(find.text('Account details'));
    await tester.pumpAndSettle();
    expect(find.text('Business'), findsOneWidget);
    expect(find.text('Murugan Traders'), findsOneWidget);
  });
}
