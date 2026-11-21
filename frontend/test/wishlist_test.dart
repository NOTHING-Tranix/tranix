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

  testWidgets('A-408: wish list tabs — my list, from my trips, find organization', (tester) async {
    await openAs(tester, 'Load Provider');
    await tester.tap(find.text('Wish list').last);
    await tester.pumpAndSettle();
    expect(find.text('2 of 20'), findsOneWidget);
    expect(find.text('TN57AB1234'), findsOneWidget);
    expect(find.text('Kaveri Logistics'), findsOneWidget);

    await tester.tap(find.text('From my trips'));
    await tester.pumpAndSettle();
    expect(find.text('TN38CD5678'), findsOneWidget);
    await tester.tap(find.byTooltip('Add to wish list'));
    await tester.pumpAndSettle();
    expect(find.text('Added to your wish list'), findsOneWidget);

    await tester.tap(find.text('Find organization'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('org-search')), 'pal');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(find.text('Palani Roadways'), findsOneWidget);
    expect(find.textContaining('12 trucks'), findsOneWidget);
  });

  testWidgets('A-410: wish-list banner with Open to everyone on a load not accepted yet', (tester) async {
    final detail = File('assets/mock/load_detail.json')
        .readAsStringSync()
        .replaceFirst('"status": "TRAVELING",', '"status": "NOT_ACCEPTED",')
        .replaceFirst('"audience": "EVERYONE"', '"audience": "WISHLIST_ONLY"');
    await openAs(tester, 'Load Provider', patch: {'load_detail.json': detail});
    await tester.scrollUntilVisible(find.text('TRX-000123'), 200);
    await tester.tap(find.text('TRX-000123').first);
    await tester.pumpAndSettle();
    expect(find.text('Offered only to your wish list.'), findsOneWidget);
    await tester.tap(find.text('Open to everyone'));
    await tester.pumpAndSettle();
  });
}
