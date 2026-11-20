import 'package:flutter/widgets.dart' show Key;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tranix_app/app.dart';
import 'package:tranix_app/core/utils/validators.dart';

import 'helpers.dart';

void main() {
  test('validators', () {
    expect(Validators.mobile('9876543210'), isTrue);
    expect(Validators.mobile('5876543210'), isFalse);
    expect(Validators.mobile('98765'), isFalse);
    expect(Validators.name('A'), isFalse);
    expect(Validators.name('Ravi'), isTrue);
    expect(Validators.otp('12345'), isFalse);
    expect(Validators.otp('123456'), isTrue);
    expect(Validators.pin('625106'), isTrue);
    expect(Validators.pin('025106'), isFalse);
  });

  Future<void> openApp(WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(overrides: await mockAppOverrides(), child: const TranixApp()));
    await tester.pumpAndSettle();
  }

  testWidgets('A-106: sign-up shows every validation message', (tester) async {
    await openApp(tester);
    await tester.tap(find.text('Sign up'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Send OTP'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid 10-digit mobile number'), findsOneWidget);
    expect(find.text('Name must be 2 to 60 characters'), findsOneWidget);
    expect(find.text('Choose who you are'), findsOneWidget);
    expect(find.text('Please accept to continue'), findsOneWidget);
  });

  testWidgets('A-103: sign-up with OTP lands in the role shell', (tester) async {
    await openApp(tester);
    await tester.tap(find.text('Sign up'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('mobile')), '9876543210');
    await tester.enterText(find.byKey(const Key('name')), 'Murugan');
    await tester.tap(find.byKey(const Key('role-loadProvider')));
    await tester.tap(find.byKey(const Key('consent')));
    await tester.tap(find.text('Send OTP'));
    await tester.pumpAndSettle();
    expect(find.text('We sent a 6-digit code to +91 9876543210'), findsOneWidget);
    expect(find.textContaining('Resend OTP in'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('otp')), '123456');
    await tester.pumpAndSettle();
    expect(find.text('TRX-000123'), findsOneWidget);
  });

  testWidgets('A-104: sign-in rejects a bad mobile, then signs in', (tester) async {
    await openApp(tester);
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('mobile')), '12345');
    await tester.tap(find.text('Send OTP'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid 10-digit mobile number'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('mobile')), '9876543210');
    await tester.tap(find.text('Send OTP'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('otp')), '123456');
    await tester.pumpAndSettle();
    expect(find.text('Wish list'), findsOneWidget);
  });
}
