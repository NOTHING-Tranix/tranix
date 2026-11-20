import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gm;
import 'package:material_ui/material_ui.dart';

import '../../shared/models/models.dart';
import '../l10n/generated/app_localizations.dart';
import '../widgets/widgets.dart';

/// Google Maps is used only when a key is configured (`--dart-define=MAPS_API_KEY=…`, founder action F-5).
const mapsApiKey = String.fromEnvironment('MAPS_API_KEY');
bool get mapsEnabled => mapsApiKey.isNotEmpty;

/// Pin + address picker for pickup/drop (LP-02). Without a Maps key it falls back to the device's location.
class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key, required this.title, this.initial});

  final String title;
  final Place? initial;

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late final _address = TextEditingController(text: widget.initial?.address ?? '');
  late final _landmark = TextEditingController(text: widget.initial?.landmark ?? '');
  GeoPoint? _point;
  bool _locating = false;
  String? _error;

  static const _india = GeoPoint(lat: 11.1271, lng: 78.6569);

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) _point = GeoPoint(lat: widget.initial!.lat, lng: widget.initial!.lng);
  }

  @override
  void dispose() {
    _address.dispose();
    _landmark.dispose();
    super.dispose();
  }

  Future<void> _useCurrent() async {
    setState(() {
      _locating = true;
      _error = null;
    });
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        throw Exception('permission');
      }
      final p = await Geolocator.getCurrentPosition();
      setState(() => _point = GeoPoint(lat: p.latitude, lng: p.longitude));
    } catch (_) {
      setState(() => _error = AppLocalizations.of(context).errorGeneric);
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _done() {
    final l = AppLocalizations.of(context);
    if (_point == null) {
      setState(() => _error = l.locationNotSet);
      return;
    }
    if (_address.text.trim().isEmpty) {
      setState(() => _error = '${l.addressLabel}: ${l.fieldRequired}');
      return;
    }
    Navigator.pop(
      context,
      Place(
        lat: _point!.lat,
        lng: _point!.lng,
        address: _address.text.trim(),
        landmark: _landmark.text.trim().isEmpty ? null : _landmark.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = _point ?? _india;
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          if (mapsEnabled)
            SizedBox(
              height: 280,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  gm.GoogleMap(
                    initialCameraPosition: gm.CameraPosition(target: gm.LatLng(p.lat, p.lng), zoom: _point == null ? 6 : 15),
                    myLocationButtonEnabled: false,
                    onCameraMove: (c) => _point = GeoPoint(lat: c.target.latitude, lng: c.target.longitude),
                    onCameraIdle: () => setState(() {}),
                  ),
                  const IgnorePointer(child: Padding(padding: EdgeInsets.only(bottom: 36), child: Icon(Icons.location_pin, size: 44))),
                ],
              ),
            ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                OutlinedButton.icon(
                  onPressed: _locating ? null : _useCurrent,
                  icon: const Icon(Icons.my_location),
                  label: Text(l.useCurrentLocation),
                ),
                const SizedBox(height: 8),
                Text(_point == null ? l.locationNotSet : '${_point!.lat.toStringAsFixed(5)}, ${_point!.lng.toStringAsFixed(5)}'),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('loc-address'),
                  controller: _address,
                  maxLines: 2,
                  decoration: InputDecoration(labelText: l.addressLabel),
                ),
                const SizedBox(height: 12),
                TextField(controller: _landmark, decoration: InputDecoration(labelText: l.landmarkOptional)),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ),
                const SizedBox(height: 24),
                PrimaryButton(label: l.save, onPressed: _done),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
