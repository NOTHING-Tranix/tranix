import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tranix_app/core/l10n/generated/app_localizations.dart';
import 'package:tranix_app/core/location/location_picker.dart';
import 'package:tranix_app/shared/models/models.dart';

import 'helpers.dart';

/// Free maps: OpenStreetMap picker with address search (Nominatim via `GET /map/geocode`) and the address filled
/// from the pin (`GET /map/reverse`).
void main() {
  testWidgets('location picker: search a place, pick it, address is filled, save returns the place', (tester) async {
    Place? picked;
    await tester.pumpWidget(ProviderScope(
      overrides: await mockAppOverrides(),
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () async => picked = await Navigator.of(context)
                    .push<Place>(MaterialPageRoute(builder: (_) => const LocationPickerScreen(title: 'Pickup'))),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('loc-search')), 'oddanchatram');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Oddanchatram Vegetable Market'));
    await tester.pump(const Duration(milliseconds: 700)); // reverse-geocode debounce
    await tester.pumpAndSettle();
    expect(find.text('Market Road, Oddanchatram, Dindigul, Tamil Nadu 624619'), findsOneWidget);
    expect(find.text('10.48700, 77.75000'), findsOneWidget);

    await tester.dragUntilVisible(find.text('Save'), find.byType(ListView), const Offset(0, -200));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(picked?.lat, 10.487);
    expect(picked?.address, startsWith('Market Road'));
  });
}
