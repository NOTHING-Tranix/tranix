import 'package:freezed_annotation/freezed_annotation.dart';

part 'common.freezed.dart';
part 'common.g.dart';

/// `{ "lat": 10.95, "lng": 78.08 }`
@freezed
abstract class GeoPoint with _$GeoPoint {
  const factory GeoPoint({required double lat, required double lng}) = _GeoPoint;

  factory GeoPoint.fromJson(Map<String, dynamic> json) => _$GeoPointFromJson(json);
}

/// Pickup / drop location: `{lat, lng, address, landmark?}`.
@freezed
abstract class Place with _$Place {
  const factory Place({
    required double lat,
    required double lng,
    required String address,
    String? landmark,
  }) = _Place;

  factory Place.fromJson(Map<String, dynamic> json) => _$PlaceFromJson(json);
}

/// `address{line, village, district, state, pin}` in `PUT /me`.
@freezed
abstract class Address with _$Address {
  const factory Address({
    required String line,
    required String village,
    required String district,
    required String state,
    required String pin,
  }) = _Address;

  factory Address.fromJson(Map<String, dynamic> json) => _$AddressFromJson(json);
}

/// Paginated list `{items, page, size, total}` (contract §1).
class Paged<T> {
  const Paged({required this.items, required this.page, required this.size, required this.total});

  factory Paged.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromItem) {
    return Paged(
      items: (json['items'] as List<dynamic>? ?? const [])
          .map((e) => fromItem(e as Map<String, dynamic>))
          .toList(),
      page: json['page'] as int? ?? 0,
      size: json['size'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
    );
  }

  final List<T> items;
  final int page;
  final int size;
  final int total;

  bool get hasMore => (page + 1) * size < total;
}
