import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// A-1008 (D-13): top-up is web-only — no in-app purchase or Play Billing anywhere in the app.
void main() {
  test('no in-app purchase / billing code paths', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, isNot(contains('in_app_purchase')));
    expect(pubspec, isNot(contains('billing')));
    final manifest = File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    expect(manifest, isNot(contains('com.android.vending.BILLING')));
    final dartFiles = Directory('lib').listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
    for (final f in dartFiles) {
      final src = f.readAsStringSync();
      expect(src.contains('in_app_purchase') || src.contains('InAppPurchase'), isFalse, reason: f.path);
    }
  });

  test('A-1001: app name localised for the prod flavor', () {
    for (final (dir, name) in [('values', 'Tranix'), ('values-ta', 'டிரானிக்ஸ்'), ('values-hi', 'ट्रानिक्स')]) {
      expect(File('android/app/src/prod/res/$dir/strings.xml').readAsStringSync(), contains('<string name="app_name">$name</string>'));
    }
  });
}
