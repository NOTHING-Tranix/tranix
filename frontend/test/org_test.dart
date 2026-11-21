import 'package:flutter/widgets.dart' show Key;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tranix_app/app.dart';

import 'helpers.dart';

void main() {
  Future<void> openAsOrg(WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(overrides: await mockAppOverrides(), child: const TranixApp()));
    await tester.pumpAndSettle();
    final button = find.text('Open as Organization');
    await tester.scrollUntilVisible(button, 200);
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  testWidgets('A-801: Org dashboard shows counts and shippers who prefer you', (tester) async {
    await openAsOrg(tester);
    expect(find.text('Shippers who prefer you'), findsOneWidget);
    expect(find.text('3'), findsWidgets);
    expect(find.text('Active trips'), findsOneWidget);
  });

  testWidgets('A-802: trucks list, detail with documents and live location', (tester) async {
    await openAsOrg(tester);
    await tester.tap(find.text('Trucks').last);
    await tester.pumpAndSettle();
    expect(find.text('TN38CD5678'), findsOneWidget);
    expect(find.textContaining('Selvam R'), findsOneWidget);
    await tester.tap(find.text('TN38CD5678'));
    await tester.pumpAndSettle();
    expect(find.textContaining('TRX-000123'), findsOneWidget);
    expect(find.text('Add document'), findsOneWidget);
  });

  testWidgets('A-803/A-804: drivers with invite, performance and allocation', (tester) async {
    await openAsOrg(tester);
    await tester.tap(find.text('Drivers').last);
    await tester.pumpAndSettle();
    expect(find.text('Invited — waiting to join'), findsOneWidget);
    await tester.tap(find.text('Kumar V'));
    await tester.pumpAndSettle();
    expect(find.text('18 trips'), findsOneWidget);
    expect(find.text('89% on time'), findsOneWidget);
    await tester.tap(find.text('Allocate truck'));
    await tester.pumpAndSettle();
    expect(find.text('TN38EF9012'), findsOneWidget); // only free trucks
    expect(find.text('TN38CD5678'), findsOneWidget); // only in the list behind the sheet (allocated truck not offered)
    await tester.tap(find.text('TN38EF9012'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Invite driver'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('inv-name')), 'Ravi S');
    await tester.enterText(find.byKey(const Key('inv-mobile')), '9876500003');
    await tester.tap(find.text('Invite driver').last);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('inv-name')), findsNothing);
  });

  testWidgets('A-805: trips by driver/truck', (tester) async {
    await openAsOrg(tester);
    await tester.tap(find.text('Trips').last);
    await tester.pumpAndSettle();
    expect(find.text('TRX-000123'), findsOneWidget);
    await tester.tap(find.text('By truck'));
    await tester.pumpAndSettle();
    expect(find.text('Choose a truck'), findsOneWidget);
    expect(find.byTooltip('Export CSV'), findsOneWidget);
  });
}
