import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tranix_app/app.dart';
import 'package:tranix_app/core/router/app_router.dart';
import 'package:tranix_app/core/session/session_controller.dart';
import 'package:tranix_app/shared/models/models.dart';

import 'helpers.dart';

void main() {
  Future<void> openAsReceiver(WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(overrides: await mockAppOverrides(), child: const TranixApp()));
    await tester.pumpAndSettle();
    final button = find.text('Open as Receiver');
    await tester.scrollUntilVisible(button, 200);
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  testWidgets('A-901/A-902: incoming loads → detail with receipt form after delivery', (tester) async {
    await openAsReceiver(tester);
    expect(find.text('Incoming loads'), findsOneWidget);
    expect(find.text('TRX-000123'), findsOneWidget);
    expect(find.textContaining('Expected'), findsWidgets);
    await tester.tap(find.text('TRX-000123'));
    await tester.pumpAndSettle();
    expect(find.text('Delivery receipt'), findsOneWidget);
    expect(find.text('Received in full'), findsOneWidget);
    expect(find.text('Shortage or damage'), findsOneWidget);
  });

  test('A-903: a receiver opening a /loads/{id} deep link goes to the receiver load screen', () {
    const me = Me(id: 'u1', name: 'R', mobile: '9000000005', role: Role.receiver);
    expect(redirectFor(const SignedIn(me), '/loads/abc'), '/receiver/loads/abc');
    expect(redirectFor(const SignedIn(me), '/receiver/loads/abc'), isNull);
  });
}
