import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../shared/models/models.dart';

/// Free maps (dev/testing): OpenStreetMap tiles via flutter_map — no key, no billing (replaces Google Maps, F-5).
/// OSM's tile policy allows light use with attribution and a real User-Agent; for production traffic switch
/// [tileUrl] to a hosted tile service.
const tileUrl = String.fromEnvironment('MAP_TILE_URL', defaultValue: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png');

/// Widget tests turn tiles off (no network in tests).
bool mapTilesEnabled = true; // ignore: prefer_final_fields

LatLng ll(GeoPoint p) => LatLng(p.lat, p.lng);

/// A map with OSM tiles, optional markers and attribution. Children go above the tiles (markers, polylines).
class OsmMap extends StatelessWidget {
  const OsmMap({super.key, required this.center, this.zoom = 13, this.controller, this.onMoveEnd, this.children = const [], this.interactive = true});

  final GeoPoint center;
  final double zoom;
  final MapController? controller;
  final void Function(GeoPoint center)? onMoveEnd;
  final List<Widget> children;
  final bool interactive;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: controller,
      options: MapOptions(
        initialCenter: ll(center),
        initialZoom: zoom,
        interactionOptions: InteractionOptions(flags: interactive ? InteractiveFlag.all & ~InteractiveFlag.rotate : InteractiveFlag.none),
        onMapEvent: onMoveEnd == null
            ? null
            : (e) {
                if (e is MapEventMoveEnd || e is MapEventFlingAnimationEnd || e is MapEventDoubleTapZoomEnd || e is MapEventScrollWheelZoom) {
                  onMoveEnd!(GeoPoint(lat: e.camera.center.latitude, lng: e.camera.center.longitude));
                }
              },
      ),
      children: [
        if (mapTilesEnabled) TileLayer(urlTemplate: tileUrl, userAgentPackageName: 'in.tranix.app', maxNativeZoom: 19),
        ...children,
        RichAttributionWidget(attributions: [
          TextSourceAttribution('OpenStreetMap contributors', onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright'))),
        ]),
      ],
    );
  }
}

/// A coloured pin marker.
Marker pin(GeoPoint p, {Color color = Colors.red, IconData icon = Icons.location_pin, double size = 36, String? tooltip}) => Marker(
      point: ll(p),
      width: size,
      height: size,
      alignment: Alignment.topCenter,
      child: tooltip == null ? Icon(icon, color: color, size: size) : Tooltip(message: tooltip, child: Icon(icon, color: color, size: size)),
    );
