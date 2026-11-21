import 'package:flutter/widgets.dart' show Key;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' show Scrollable, TextFormField;
import 'package:tranix_app/app.dart';
import 'package:tranix_app/core/utils/validators.dart';

import 'helpers.dart';

void main() {
  Future<void> openAsNetwork(WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(overrides: await mockAppOverrides(), child: const TranixApp()));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Open as Farmer Network'), 200);
    await tester.ensureVisible(find.text('Open as Farmer Network'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open as Farmer Network'));
    await tester.pumpAndSettle();
  }

  test('A-701: ID number is checked against the chosen ID type', () {
    expect(Validators.idNumber('PAN', 'ABCDE1234F'), isTrue);
    expect(Validators.idNumber('PAN', '27ABCDE1234F1Z5'), isFalse);
    expect(Validators.idNumber('GSTIN', '27ABCDE1234F1Z5'), isTrue);
    expect(Validators.idNumber('CIN', 'U01100TN2020PTC123456'), isTrue);
    expect(Validators.idNumber(null, 'ABCDE1234F'), isFalse);
  });

  testWidgets('A-702/A-704: Farmers tab lists farmers; add needs consent', (tester) async {
    await openAsNetwork(tester);
    await tester.tap(find.text('Farmers').last);
    await tester.pumpAndSettle();
    expect(find.text('Raman K'), findsOneWidget);
    expect(find.text('Selvi M'), findsOneWidget);
    await tester.tap(find.text('Add farmer'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('f-name')), 'Murthy P');
    await tester.enterText(find.byKey(const Key('f-mobile')), '9811100003');
    await tester.enterText(find.byKey(const Key('f-village')), 'Palani');
    await tester.enterText(find.byKey(const Key('f-aadhaar')), '123456');
    expect(tester.widget<TextFormField>(find.byKey(const Key('f-aadhaar'))).controller!.text, '1234'); // max 4 digits
    await tester.tap(find.byKey(const Key('f-consent')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('f-name')), findsNothing); // saved → sheet closed
  });

  testWidgets('A-703: post for a farmer locks the sender to the farmer', (tester) async {
    await openAsNetwork(tester);
    await tester.tap(find.byKey(const Key('post-for-farmer')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Raman K'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byKey(const Key('pl-senderName')), 200, scrollable: find.byType(Scrollable).first);
    expect(find.text('The farmer is the sender and gets the pickup OTP.'), findsOneWidget);
    final sender = tester.widget<TextFormField>(find.byKey(const Key('pl-senderName')));
    expect(sender.enabled, isFalse);
    expect(sender.initialValue, 'Raman K');
  });
}
