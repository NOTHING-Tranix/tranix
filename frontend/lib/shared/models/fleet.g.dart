// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fleet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Truck _$TruckFromJson(Map<String, dynamic> json) => _Truck(
  id: json['id'] as String,
  number: json['number'] as String,
  vehicleType: $enumDecode(
    _$VehicleTypeEnumMap,
    json['vehicleType'],
    unknownValue: VehicleType.unknown,
  ),
  capacityTonnes: json['capacityTonnes'] as num,
  status: $enumDecode(
    _$TruckStatusEnumMap,
    json['status'],
    unknownValue: TruckStatus.unknown,
  ),
  documents:
      (json['documents'] as List<dynamic>?)
          ?.map((e) => Document.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Document>[],
  allocatedDriver: json['allocatedDriver'] as Map<String, dynamic>?,
  ownedByMe: json['ownedByMe'] as bool? ?? true,
);

Map<String, dynamic> _$TruckToJson(_Truck instance) => <String, dynamic>{
  'id': instance.id,
  'number': instance.number,
  'vehicleType': _$VehicleTypeEnumMap[instance.vehicleType]!,
  'capacityTonnes': instance.capacityTonnes,
  'status': _$TruckStatusEnumMap[instance.status]!,
  'documents': instance.documents.map((e) => e.toJson()).toList(),
  'allocatedDriver': ?instance.allocatedDriver,
  'ownedByMe': instance.ownedByMe,
};

const _$VehicleTypeEnumMap = {
  VehicleType.openBody: 'OPEN_BODY',
  VehicleType.closedBody: 'CLOSED_BODY',
  VehicleType.container: 'CONTAINER',
  VehicleType.refrigerated: 'REFRIGERATED',
  VehicleType.tanker: 'TANKER',
  VehicleType.any: 'ANY',
  VehicleType.unknown: 'UNKNOWN',
};

const _$TruckStatusEnumMap = {
  TruckStatus.available: 'AVAILABLE',
  TruckStatus.allocated: 'ALLOCATED',
  TruckStatus.onTrip: 'ON_TRIP',
  TruckStatus.documentsPending: 'DOCUMENTS_PENDING',
  TruckStatus.inactive: 'INACTIVE',
  TruckStatus.unknown: 'UNKNOWN',
};

_DriverHome _$DriverHomeFromJson(Map<String, dynamic> json) => _DriverHome(
  onDuty: json['onDuty'] as bool? ?? false,
  truck: json['truck'] == null
      ? null
      : Truck.fromJson(json['truck'] as Map<String, dynamic>),
  walletBalanceInr: (json['walletBalanceInr'] as num?)?.toInt(),
  orgName: json['orgName'] as String?,
  currentLoadId: json['currentLoadId'] as String?,
  suggestionsCount: (json['suggestionsCount'] as num?)?.toInt() ?? 0,
  trustScore: (json['trustScore'] as num?)?.toDouble() ?? 70,
  expiringDocuments:
      (json['expiringDocuments'] as List<dynamic>?)
          ?.map((e) => Document.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Document>[],
);

Map<String, dynamic> _$DriverHomeToJson(_DriverHome instance) =>
    <String, dynamic>{
      'onDuty': instance.onDuty,
      'truck': ?instance.truck?.toJson(),
      'walletBalanceInr': ?instance.walletBalanceInr,
      'orgName': ?instance.orgName,
      'currentLoadId': ?instance.currentLoadId,
      'suggestionsCount': instance.suggestionsCount,
      'trustScore': instance.trustScore,
      'expiringDocuments': instance.expiringDocuments
          .map((e) => e.toJson())
          .toList(),
    };

_Invitation _$InvitationFromJson(Map<String, dynamic> json) => _Invitation(
  id: json['id'] as String,
  orgId: json['orgId'] as String,
  orgName: json['orgName'] as String,
  status: json['status'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$InvitationToJson(_Invitation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orgId': instance.orgId,
      'orgName': instance.orgName,
      'status': instance.status,
      'createdAt': instance.createdAt.toIso8601String(),
    };
