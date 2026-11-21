import 'package:flutter/foundation.dart' show FlutterError;
import 'package:flutter/widgets.dart' show Size;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' show NavigationDestination, Offset, Scrollable;
import 'package:tranix_app/app.dart';

import 'helpers.dart';

/// A-1005: every tab of every role in Tamil and Hindi at 1.3× text on a small phone (360×740 dp) — no overflow errors.
void main() {
  const roles = {
    'ta': ['சரக்கு அனுப்புநர்', 'ஓட்டுநர்', 'நிறுவனம்', 'பெறுநர்'],
    'hi': ['लोड प्रदाता', 'ड्राइवर', 'संगठन', 'प्राप्तकर्ता'],
  };

  for (final entry in roles.entries) {
    for (final role in entry.value) {
      testWidgets('A-1005: ${entry.key} · $role at 1.3× text has no layout overflow', (tester) async {
        tester.view.physicalSize = const Size(1080, 2220);
        tester.view.devicePixelRatio = 3;
        tester.platformDispatcher.textScaleFactorTestValue = 1.3;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await tester.pumpWidget(
            ProviderScope(overrides: await mockAppOverrides(initialPrefs: {'tranix.language': entry.key}), child: const TranixApp()));
        await tester.pumpAndSettle();
        await tester.drag(find.byType(Scrollable).first, const Offset(0, -3000));
        await tester.pumpAndSettle();
        final open = find.textContaining(role).last;
        await tester.ensureVisible(open);
        await tester.pumpAndSettle();
        await tester.tap(open);
        await tester.pumpAndSettle();
        final tabs = find.byType(NavigationDestination).evaluate().length;
        expect(tabs, greaterThan(2));
        for (var i = 0; i < tabs; i++) {
          await tester.tap(find.byType(NavigationDestination).at(i));
          await tester.pumpAndSettle();
          final ex = tester.takeException();
          final where = ex is FlutterError
              ? ex.diagnostics.map((d) => d.toString()).where((s) => s.contains('lib/')).take(3).join(' | ')
              : '$ex';
          expect(ex, isNull, reason: 'tab $i: $where');
        }
      });
    }
  }
}
