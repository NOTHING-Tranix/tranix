// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'common.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GeoPoint _$GeoPointFromJson(Map<String, dynamic> json) => _GeoPoint(
  lat: (json['lat'] as num).toDouble(),
  lng: (json['lng'] as num).toDouble(),
);

Map<String, dynamic> _$GeoPointToJson(_GeoPoint instance) => <String, dynamic>{
  'lat': instance.lat,
  'lng': instance.lng,
};

_Place _$PlaceFromJson(Map<String, dynamic> json) => _Place(
  lat: (json['lat'] as num).toDouble(),
  lng: (json['lng'] as num).toDouble(),
  address: json['address'] as String,
  landmark: json['landmark'] as String?,
);

Map<String, dynamic> _$PlaceToJson(_Place instance) => <String, dynamic>{
  'lat': instance.lat,
  'lng': instance.lng,
  'address': instance.address,
  'landmark': ?instance.landmark,
};

_Address _$AddressFromJson(Map<String, dynamic> json) => _Address(
  line: json['line'] as String,
  village: json['village'] as String,
  district: json['district'] as String,
  state: json['state'] as String,
  pin: json['pin'] as String,
);

Map<String, dynamic> _$AddressToJson(_Address instance) => <String, dynamic>{
  'line': instance.line,
  'village': instance.village,
  'district': instance.district,
  'state': instance.state,
  'pin': instance.pin,
};
