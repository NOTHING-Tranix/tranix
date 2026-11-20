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
  }

  testWidgets('A-304: home shows notification cards; bell opens tabs', (tester) async {
    await openAsLoadProvider(tester);
    expect(find.text('Latest trip update'), findsOneWidget);
    expect(find.textContaining('TRX-000123 picked up'), findsOneWidget);
    await tester.tap(find.byTooltip('Notifications'));
    await tester.pumpAndSettle();
    expect(find.text('Trips'), findsWidgets);
    expect(find.text('Mark all read'), findsOneWidget);
    expect(find.text('TRX-000123 picked up'), findsOneWidget);
  });

  testWidgets('A-301: wallet shows balance, charges, chips and transactions', (tester) async {
    await openAsLoadProvider(tester);
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Wallet'));
    await tester.pumpAndSettle();
    expect(find.text('₹1,250'), findsOneWidget);
    expect(find.text('Posting charge ₹50 · Trip charge ₹50'), findsOneWidget);
    expect(find.text('₹500'), findsOneWidget);
    expect(find.text('₹2,000'), findsOneWidget);
    await tester.scrollUntilVisible(find.textContaining('TXN-000045'), 200);
    expect(find.textContaining('TXN-000045'), findsOneWidget);
  });
}
