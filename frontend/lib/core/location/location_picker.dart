import 'dart:async';

import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:material_ui/material_ui.dart';

import '../../shared/models/models.dart';
import '../l10n/generated/app_localizations.dart';
import '../network/interceptors.dart';
import '../providers.dart';
import '../widgets/widgets.dart';
import 'osm_map.dart';

/// One place from `GET /map/geocode` (contract §8, OpenStreetMap Nominatim behind the server).
class GeoHit {
  GeoHit(this.name, this.lat, this.lng);

  final String name;
  final double lat;
  final double lng;
}

/// Pin + address picker for pickup/drop (LP-02): drag the map under the fixed pin, search an address, or use the
/// device's location; the address is filled from the pin (reverse geocoding) and stays editable.
class LocationPickerScreen extends ConsumerStatefulWidget {
  const LocationPickerScreen({super.key, required this.title, this.initial});

  final String title;
  final Place? initial;

  @override
  ConsumerState<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends ConsumerState<LocationPickerScreen> {
  late final _address = TextEditingController(text: widget.initial?.address ?? '');
  late final _landmark = TextEditingController(text: widget.initial?.landmark ?? '');
  final _search = TextEditingController();
  final _map = MapController();
  GeoPoint? _point;
  bool _locating = false;
  bool _addressTouched = false;
  String? _error;
  List<GeoHit> _hits = const [];
  Timer? _reverseDebounce;

  static const _tamilNadu = GeoPoint(lat: 11.1271, lng: 78.6569);

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      _point = GeoPoint(lat: widget.initial!.lat, lng: widget.initial!.lng);
      _addressTouched = true;
    }
  }

  @override
  void dispose() {
    _reverseDebounce?.cancel();
    _address.dispose();
    _landmark.dispose();
    _search.dispose();
    super.dispose();
  }

  void _moveTo(GeoPoint p, {double zoom = 16}) {
    setState(() => _point = p);
    try {
      _map.move(ll(p), zoom);
    } catch (_) {
      // map not laid out yet (first frame)
    }
    _reverse(p);
  }

  void _reverse(GeoPoint p) {
    if (_addressTouched) return;
    _reverseDebounce?.cancel();
    _reverseDebounce = Timer(const Duration(milliseconds: 600), () async {
      try {
        final res = await guardApi(() => ref.read(dioProvider).get<Map<String, dynamic>>('/map/reverse',
            queryParameters: {'lat': p.lat, 'lng': p.lng}));
        final address = res.data?['address'] as String?;
        if (mounted && !_addressTouched && address != null && address.isNotEmpty) _address.text = address;
      } catch (_) {
        // offline or service busy: the user types the address
      }
    });
  }

  Future<void> _find() async {
    final q = _search.text.trim();
    if (q.length < 3) return;
    try {
      final res = await guardApi(() => ref.read(dioProvider).get<List<dynamic>>('/map/geocode', queryParameters: {'q': q}));
      final hits = [
        for (final e in res.data ?? const [])
          GeoHit('${(e as Map)['name']}', (e['lat'] as num).toDouble(), (e['lng'] as num).toDouble()),
      ];
      if (mounted) setState(() => _hits = hits);
    } catch (_) {
      if (mounted) setState(() => _error = AppLocalizations.of(context).errorGeneric);
    }
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
      _moveTo(GeoPoint(lat: p.latitude, lng: p.longitude));
    } catch (_) {
      if (mounted) setState(() => _error = AppLocalizations.of(context).errorGeneric);
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
    final start = _point ?? _tamilNadu;
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          SizedBox(
            height: 260,
            child: Stack(
              alignment: Alignment.center,
              children: [
                OsmMap(
                  controller: _map,
                  center: start,
                  zoom: _point == null ? 7 : 16,
                  onMoveEnd: (c) {
                    setState(() => _point = c);
                    _reverse(c);
                  },
                ),
                // Fixed pin in the centre: the map moves under it.
                const IgnorePointer(child: Padding(padding: EdgeInsets.only(bottom: 36), child: Icon(Icons.location_pin, size: 44, color: Colors.red))),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextField(
                  key: const Key('loc-search'),
                  controller: _search,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _find(),
                  decoration: InputDecoration(
                    labelText: l.searchPlace,
                    suffixIcon: IconButton(tooltip: l.searchPlace, icon: const Icon(Icons.search), onPressed: _find),
                  ),
                ),
                for (final h in _hits)
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.place_outlined),
                    title: Text(h.name, maxLines: 2, overflow: TextOverflow.ellipsis),
                    onTap: () {
                      setState(() {
                        _hits = const [];
                        _addressTouched = false;
                      });
                      _moveTo(GeoPoint(lat: h.lat, lng: h.lng));
                    },
                  ),
                const SizedBox(height: 8),
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
                  onChanged: (_) => _addressTouched = true,
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
