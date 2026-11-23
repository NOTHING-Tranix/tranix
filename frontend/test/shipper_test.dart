import 'dart:async';

import 'package:flutter/widgets.dart' show Form, Scrollable;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tranix_app/app.dart';
import 'package:tranix_app/core/router/app_router.dart';
import 'package:tranix_app/core/router/routes.dart';
import 'package:tranix_app/features/shipper/application/post_load_draft.dart';
import 'package:tranix_app/shared/models/models.dart';

import 'helpers.dart';

void main() {
  Future<ProviderContainer> openAsLoadProvider(WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(overrides: await mockAppOverrides(), child: const TranixApp()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open as Load Provider'));
    await tester.pumpAndSettle();
    return ProviderScope.containerOf(tester.element(find.byType(TranixApp)));
  }

  testWidgets('A-401: home shows wallet, post button and ongoing loads', (tester) async {
    await openAsLoadProvider(tester);
    expect(find.text('₹1,250'), findsOneWidget);
    expect(find.text('Post a load'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('TRX-000123'), 200);
    expect(find.text('TRX-000123'), findsOneWidget);
  });

  testWidgets('A-402: post form requires date, places and goods', (tester) async {
    final container = await openAsLoadProvider(tester);
    await tester.tap(find.text('Post a load'));
    await tester.pumpAndSettle();
    expect(container.read(loadDraftProvider).senderName, 'Murugan Traders'); // sender prefilled from Me
    await tester.scrollUntilVisible(find.text('Continue'), 300,
        scrollable: find.descendant(of: find.byType(Form), matching: find.byType(Scrollable)).first);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Required'), findsWidgets);
  });

  testWidgets('A-403: review posts the draft and opens the load', (tester) async {
    final container = await openAsLoadProvider(tester);
    container.read(loadDraftProvider.notifier).replace(LoadDraft(
          date: DateTime.now().add(const Duration(days: 1)),
          pickup: const Place(lat: 10.48, lng: 77.74, address: 'Gandhi Market, Oddanchatram'),
          drop: const Place(lat: 13.06, lng: 80.19, address: 'Koyambedu Market, Chennai'),
          senderName: 'Murugan',
          senderMobile: '9876543210',
          goodsType: 'Vegetables',
          quantity: '120',
          unit: QuantityUnit.crates,
          weight: '3.6',
          receiverName: 'Selvi',
          receiverMobile: '9123456780',
          amount: '18000',
        ));
    unawaited(container.read(routerProvider).push(Routes.postLoadReview));
    await tester.pumpAndSettle();
    expect(find.textContaining('Posting charge ₹50'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Post load'), 200);
    await tester.tap(find.text('Post load'));
    await tester.pumpAndSettle();
    expect(find.text('TRX-000123'), findsWidgets);
    expect(find.text('Ravi Kumar'), findsOneWidget); // A-404 driver block
    expect(find.byTooltip('Call'), findsOneWidget);
    expect(container.read(loadDraftProvider).pickup, isNull); // draft cleared after posting
  });

  test('draft builds the contract body', () {
    final d = LoadDraft(
      date: DateTime(2030, 1, 2),
      fromMinutes: 9 * 60,
      toMinutes: 12 * 60,
      pickup: const Place(lat: 1, lng: 2, address: 'A'),
      drop: const Place(lat: 3, lng: 4, address: 'B'),
      senderName: ' S ',
      senderMobile: '9876543210',
      goodsType: 'Fruits',
      quantity: '10',
      weight: '1.5',
      receiverName: 'R',
      receiverMobile: '9123456780',
      payer: FreightPayer.receiver,
      amount: '9000',
    );
    final json = d.toCreate().toJson();
    expect(json['senderName'], 'S');
    expect(json['freightPaidBy'], 'RECEIVER');
    expect(json['vehicleType'], 'ANY');
    expect(DateTime.parse(json['pickupWindowEnd'] as String).difference(DateTime.parse(json['pickupWindowStart'] as String)),
        const Duration(hours: 3));
  });
}
