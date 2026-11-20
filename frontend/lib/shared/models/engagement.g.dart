// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'engagement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WishlistEntry _$WishlistEntryFromJson(Map<String, dynamic> json) =>
    _WishlistEntry(
      id: json['id'] as String,
      targetType: $enumDecode(
        _$WishlistTargetTypeEnumMap,
        json['targetType'],
        unknownValue: WishlistTargetType.unknown,
      ),
      truckNumber: json['truckNumber'] as String?,
      vehicleType: $enumDecodeNullable(
        _$VehicleTypeEnumMap,
        json['vehicleType'],
        unknownValue: VehicleType.unknown,
      ),
      capacityTonnes: json['capacityTonnes'] as num?,
      driverName: json['driverName'] as String?,
      orgId: json['orgId'] as String?,
      orgName: json['orgName'] as String?,
      trustScore: (json['trustScore'] as num).toDouble(),
      tripsTogether: (json['tripsTogether'] as num?)?.toInt() ?? 0,
      note: json['note'] as String?,
      available: json['available'] as bool? ?? false,
    );

Map<String, dynamic> _$WishlistEntryToJson(_WishlistEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'targetType': _$WishlistTargetTypeEnumMap[instance.targetType]!,
      'truckNumber': ?instance.truckNumber,
      'vehicleType': ?_$VehicleTypeEnumMap[instance.vehicleType],
      'capacityTonnes': ?instance.capacityTonnes,
      'driverName': ?instance.driverName,
      'orgId': ?instance.orgId,
      'orgName': ?instance.orgName,
      'trustScore': instance.trustScore,
      'tripsTogether': instance.tripsTogether,
      'note': ?instance.note,
      'available': instance.available,
    };

const _$WishlistTargetTypeEnumMap = {
  WishlistTargetType.truck: 'TRUCK',
  WishlistTargetType.organization: 'ORGANIZATION',
  WishlistTargetType.unknown: 'UNKNOWN',
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

_TrustScore _$TrustScoreFromJson(Map<String, dynamic> json) => _TrustScore(
  score: (json['score'] as num).toDouble(),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  trend:
      (json['trend'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList() ??
      const <double>[],
);

Map<String, dynamic> _$TrustScoreToJson(_TrustScore instance) =>
    <String, dynamic>{
      'score': instance.score,
      'updatedAt': instance.updatedAt.toIso8601String(),
      'trend': instance.trend,
    };

_TrustEvent _$TrustEventFromJson(Map<String, dynamic> json) => _TrustEvent(
  at: DateTime.parse(json['at'] as String),
  loadId: json['loadId'] as String?,
  event: json['event'] as String,
  points: (json['points'] as num).toDouble(),
  reason: json['reason'] as String,
);

Map<String, dynamic> _$TrustEventToJson(_TrustEvent instance) =>
    <String, dynamic>{
      'at': instance.at.toIso8601String(),
      'loadId': ?instance.loadId,
      'event': instance.event,
      'points': instance.points,
      'reason': instance.reason,
    };

_PendingRating _$PendingRatingFromJson(Map<String, dynamic> json) =>
    _PendingRating(
      loadId: json['loadId'] as String,
      rateeName: json['rateeName'] as String,
      rateeRole: $enumDecode(
        _$RoleEnumMap,
        json['rateeRole'],
        unknownValue: Role.unknown,
      ),
    );

Map<String, dynamic> _$PendingRatingToJson(_PendingRating instance) =>
    <String, dynamic>{
      'loadId': instance.loadId,
      'rateeName': instance.rateeName,
      'rateeRole': _$RoleEnumMap[instance.rateeRole]!,
    };

const _$RoleEnumMap = {
  Role.loadProvider: 'LOAD_PROVIDER',
  Role.farmerNetwork: 'FARMER_NETWORK',
  Role.driver: 'DRIVER',
  Role.organization: 'ORGANIZATION',
  Role.receiver: 'RECEIVER',
  Role.admin: 'ADMIN',
  Role.unknown: 'UNKNOWN',
};

_NotificationSummary _$NotificationSummaryFromJson(Map<String, dynamic> json) =>
    _NotificationSummary(
      unreadByTab:
          (json['unreadByTab'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const <String, int>{},
      latestTranixMessage: json['latestTranixMessage'] == null
          ? null
          : AppNotification.fromJson(
              json['latestTranixMessage'] as Map<String, dynamic>,
            ),
      latestTripUpdate: json['latestTripUpdate'] == null
          ? null
          : AppNotification.fromJson(
              json['latestTripUpdate'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$NotificationSummaryToJson(
  _NotificationSummary instance,
) => <String, dynamic>{
  'unreadByTab': instance.unreadByTab,
  'latestTranixMessage': ?instance.latestTranixMessage?.toJson(),
  'latestTripUpdate': ?instance.latestTripUpdate?.toJson(),
};

_AppNotification _$AppNotificationFromJson(Map<String, dynamic> json) =>
    _AppNotification(
      id: json['id'] as String,
      tab: $enumDecode(
        _$NotificationTabEnumMap,
        json['tab'],
        unknownValue: NotificationTab.unknown,
      ),
      type: json['type'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      route: json['route'] as String?,
      read: json['read'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$AppNotificationToJson(_AppNotification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tab': _$NotificationTabEnumMap[instance.tab]!,
      'type': instance.type,
      'title': instance.title,
      'body': instance.body,
      'route': ?instance.route,
      'read': instance.read,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$NotificationTabEnumMap = {
  NotificationTab.trips: 'TRIPS',
  NotificationTab.wallet: 'WALLET',
  NotificationTab.tranix: 'TRANIX',
  NotificationTab.account: 'ACCOUNT',
  NotificationTab.unknown: 'UNKNOWN',
};
