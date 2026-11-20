// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loads.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LoadSummary _$LoadSummaryFromJson(Map<String, dynamic> json) => _LoadSummary(
  id: json['id'] as String,
  code: json['code'] as String,
  status: $enumDecode(
    _$LoadStatusEnumMap,
    json['status'],
    unknownValue: LoadStatus.unknown,
  ),
  goodsType: json['goodsType'] as String,
  description: json['description'] as String?,
  quantity: json['quantity'] as num,
  quantityUnit: $enumDecode(
    _$QuantityUnitEnumMap,
    json['quantityUnit'],
    unknownValue: QuantityUnit.unknown,
  ),
  pickupArea: json['pickupArea'] as String,
  dropArea: json['dropArea'] as String,
  pickupWindowStart: DateTime.parse(json['pickupWindowStart'] as String),
  agreedAmountInr: (json['agreedAmountInr'] as num).toInt(),
  paymentStatus: $enumDecodeNullable(
    _$PaymentStatusEnumMap,
    json['paymentStatus'],
    unknownValue: PaymentStatus.unknown,
  ),
  postedForFarmerName: json['postedForFarmerName'] as String?,
);

Map<String, dynamic> _$LoadSummaryToJson(_LoadSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'status': _$LoadStatusEnumMap[instance.status]!,
      'goodsType': instance.goodsType,
      'description': ?instance.description,
      'quantity': instance.quantity,
      'quantityUnit': _$QuantityUnitEnumMap[instance.quantityUnit]!,
      'pickupArea': instance.pickupArea,
      'dropArea': instance.dropArea,
      'pickupWindowStart': instance.pickupWindowStart.toIso8601String(),
      'agreedAmountInr': instance.agreedAmountInr,
      'paymentStatus': ?_$PaymentStatusEnumMap[instance.paymentStatus],
      'postedForFarmerName': ?instance.postedForFarmerName,
    };

const _$LoadStatusEnumMap = {
  LoadStatus.notAccepted: 'NOT_ACCEPTED',
  LoadStatus.accepted: 'ACCEPTED',
  LoadStatus.amountNegotiation: 'AMOUNT_NEGOTIATION',
  LoadStatus.waitingForPickup: 'WAITING_FOR_PICKUP',
  LoadStatus.locationReached: 'LOCATION_REACHED',
  LoadStatus.pickedUp: 'PICKED_UP',
  LoadStatus.traveling: 'TRAVELING',
  LoadStatus.arrivedDestination: 'ARRIVED_DESTINATION',
  LoadStatus.delivered: 'DELIVERED',
  LoadStatus.cancelled: 'CANCELLED',
  LoadStatus.unknown: 'UNKNOWN',
};

const _$QuantityUnitEnumMap = {
  QuantityUnit.bags: 'BAGS',
  QuantityUnit.crates: 'CRATES',
  QuantityUnit.boxes: 'BOXES',
  QuantityUnit.tonnes: 'TONNES',
  QuantityUnit.litres: 'LITRES',
  QuantityUnit.unknown: 'UNKNOWN',
};

const _$PaymentStatusEnumMap = {
  PaymentStatus.pending: 'PENDING',
  PaymentStatus.paid: 'PAID',
  PaymentStatus.confirmed: 'CONFIRMED',
  PaymentStatus.disputed: 'DISPUTED',
  PaymentStatus.unknown: 'UNKNOWN',
};

_TimelineEntry _$TimelineEntryFromJson(Map<String, dynamic> json) =>
    _TimelineEntry(
      status: $enumDecode(
        _$LoadStatusEnumMap,
        json['status'],
        unknownValue: LoadStatus.unknown,
      ),
      at: DateTime.parse(json['at'] as String),
    );

Map<String, dynamic> _$TimelineEntryToJson(_TimelineEntry instance) =>
    <String, dynamic>{
      'status': _$LoadStatusEnumMap[instance.status]!,
      'at': instance.at.toIso8601String(),
    };

_LoadDriver _$LoadDriverFromJson(Map<String, dynamic> json) => _LoadDriver(
  id: json['id'] as String,
  name: json['name'] as String,
  photoUrl: json['photoUrl'] as String?,
  mobile: json['mobile'] as String,
  trustScore: (json['trustScore'] as num).toDouble(),
  truckNumber: json['truckNumber'] as String,
  vehicleType: $enumDecode(
    _$VehicleTypeEnumMap,
    json['vehicleType'],
    unknownValue: VehicleType.unknown,
  ),
);

Map<String, dynamic> _$LoadDriverToJson(_LoadDriver instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'photoUrl': ?instance.photoUrl,
      'mobile': instance.mobile,
      'trustScore': instance.trustScore,
      'truckNumber': instance.truckNumber,
      'vehicleType': _$VehicleTypeEnumMap[instance.vehicleType]!,
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

_AmountRevision _$AmountRevisionFromJson(Map<String, dynamic> json) =>
    _AmountRevision(
      id: json['id'] as String,
      requestedAmountInr: (json['requestedAmountInr'] as num).toInt(),
      reason: json['reason'] as String,
      status: $enumDecode(
        _$RevisionStatusEnumMap,
        json['status'],
        unknownValue: RevisionStatus.unknown,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      respondBy: DateTime.parse(json['respondBy'] as String),
    );

Map<String, dynamic> _$AmountRevisionToJson(_AmountRevision instance) =>
    <String, dynamic>{
      'id': instance.id,
      'requestedAmountInr': instance.requestedAmountInr,
      'reason': instance.reason,
      'status': _$RevisionStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'respondBy': instance.respondBy.toIso8601String(),
    };

const _$RevisionStatusEnumMap = {
  RevisionStatus.pending: 'PENDING',
  RevisionStatus.confirmed: 'CONFIRMED',
  RevisionStatus.rejected: 'REJECTED',
  RevisionStatus.expired: 'EXPIRED',
  RevisionStatus.unknown: 'UNKNOWN',
};

_LoadPayment _$LoadPaymentFromJson(Map<String, dynamic> json) => _LoadPayment(
  status: $enumDecode(
    _$PaymentStatusEnumMap,
    json['status'],
    unknownValue: PaymentStatus.unknown,
  ),
  amountInr: (json['amountInr'] as num?)?.toInt(),
  mode: $enumDecodeNullable(
    _$PaymentModeEnumMap,
    json['mode'],
    unknownValue: PaymentMode.unknown,
  ),
  reference: json['reference'] as String?,
  paidAt: json['paidAt'] == null
      ? null
      : DateTime.parse(json['paidAt'] as String),
  confirmedAt: json['confirmedAt'] == null
      ? null
      : DateTime.parse(json['confirmedAt'] as String),
  disputeReason: json['disputeReason'] as String?,
);

Map<String, dynamic> _$LoadPaymentToJson(_LoadPayment instance) =>
    <String, dynamic>{
      'status': _$PaymentStatusEnumMap[instance.status]!,
      'amountInr': ?instance.amountInr,
      'mode': ?_$PaymentModeEnumMap[instance.mode],
      'reference': ?instance.reference,
      'paidAt': ?instance.paidAt?.toIso8601String(),
      'confirmedAt': ?instance.confirmedAt?.toIso8601String(),
      'disputeReason': ?instance.disputeReason,
    };

const _$PaymentModeEnumMap = {
  PaymentMode.cash: 'CASH',
  PaymentMode.upi: 'UPI',
  PaymentMode.bank: 'BANK',
  PaymentMode.unknown: 'UNKNOWN',
};

_LoadDetail _$LoadDetailFromJson(Map<String, dynamic> json) => _LoadDetail(
  id: json['id'] as String,
  code: json['code'] as String,
  status: $enumDecode(
    _$LoadStatusEnumMap,
    json['status'],
    unknownValue: LoadStatus.unknown,
  ),
  goodsType: json['goodsType'] as String,
  description: json['description'] as String?,
  quantity: json['quantity'] as num,
  quantityUnit: $enumDecode(
    _$QuantityUnitEnumMap,
    json['quantityUnit'],
    unknownValue: QuantityUnit.unknown,
  ),
  pickupArea: json['pickupArea'] as String,
  dropArea: json['dropArea'] as String,
  pickupWindowStart: DateTime.parse(json['pickupWindowStart'] as String),
  agreedAmountInr: (json['agreedAmountInr'] as num).toInt(),
  paymentStatus: $enumDecodeNullable(
    _$PaymentStatusEnumMap,
    json['paymentStatus'],
    unknownValue: PaymentStatus.unknown,
  ),
  postedForFarmerName: json['postedForFarmerName'] as String?,
  pickup: Place.fromJson(json['pickup'] as Map<String, dynamic>),
  drop: Place.fromJson(json['drop'] as Map<String, dynamic>),
  senderName: json['senderName'] as String,
  senderMobile: json['senderMobile'] as String,
  receiverName: json['receiverName'] as String,
  receiverMobile: json['receiverMobile'] as String,
  weightTonnes: json['weightTonnes'] as num,
  vehicleType: $enumDecode(
    _$VehicleTypeEnumMap,
    json['vehicleType'],
    unknownValue: VehicleType.unknown,
  ),
  freightPaidBy: $enumDecode(
    _$FreightPayerEnumMap,
    json['freightPaidBy'],
    unknownValue: FreightPayer.unknown,
  ),
  postedAmountInr: (json['postedAmountInr'] as num).toInt(),
  deliveryEta: json['deliveryEta'] == null
      ? null
      : DateTime.parse(json['deliveryEta'] as String),
  timeline:
      (json['timeline'] as List<dynamic>?)
          ?.map((e) => TimelineEntry.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <TimelineEntry>[],
  driver: json['driver'] == null
      ? null
      : LoadDriver.fromJson(json['driver'] as Map<String, dynamic>),
  revisions:
      (json['revisions'] as List<dynamic>?)
          ?.map((e) => AmountRevision.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <AmountRevision>[],
  revisionsUsed: (json['revisionsUsed'] as num?)?.toInt() ?? 0,
  payment: json['payment'] == null
      ? null
      : LoadPayment.fromJson(json['payment'] as Map<String, dynamic>),
  otpEvents:
      (json['otpEvents'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const <Map<String, dynamic>>[],
  locationExceptions:
      (json['locationExceptions'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const <Map<String, dynamic>>[],
  canEdit: json['canEdit'] as bool? ?? false,
  canCancel: json['canCancel'] as bool? ?? false,
  cancelInfo: json['cancelInfo'] as Map<String, dynamic>?,
  audience:
      $enumDecodeNullable(
        _$LoadAudienceEnumMap,
        json['audience'],
        unknownValue: LoadAudience.unknown,
      ) ??
      LoadAudience.everyone,
  wishlistUntil: json['wishlistUntil'] == null
      ? null
      : DateTime.parse(json['wishlistUntil'] as String),
  openedToEveryoneAt: json['openedToEveryoneAt'] == null
      ? null
      : DateTime.parse(json['openedToEveryoneAt'] as String),
);

Map<String, dynamic> _$LoadDetailToJson(_LoadDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'status': _$LoadStatusEnumMap[instance.status]!,
      'goodsType': instance.goodsType,
      'description': ?instance.description,
      'quantity': instance.quantity,
      'quantityUnit': _$QuantityUnitEnumMap[instance.quantityUnit]!,
      'pickupArea': instance.pickupArea,
      'dropArea': instance.dropArea,
      'pickupWindowStart': instance.pickupWindowStart.toIso8601String(),
      'agreedAmountInr': instance.agreedAmountInr,
      'paymentStatus': ?_$PaymentStatusEnumMap[instance.paymentStatus],
      'postedForFarmerName': ?instance.postedForFarmerName,
      'pickup': instance.pickup.toJson(),
      'drop': instance.drop.toJson(),
      'senderName': instance.senderName,
      'senderMobile': instance.senderMobile,
      'receiverName': instance.receiverName,
      'receiverMobile': instance.receiverMobile,
      'weightTonnes': instance.weightTonnes,
      'vehicleType': _$VehicleTypeEnumMap[instance.vehicleType]!,
      'freightPaidBy': _$FreightPayerEnumMap[instance.freightPaidBy]!,
      'postedAmountInr': instance.postedAmountInr,
      'deliveryEta': ?instance.deliveryEta?.toIso8601String(),
      'timeline': instance.timeline.map((e) => e.toJson()).toList(),
      'driver': ?instance.driver?.toJson(),
      'revisions': instance.revisions.map((e) => e.toJson()).toList(),
      'revisionsUsed': instance.revisionsUsed,
      'payment': ?instance.payment?.toJson(),
      'otpEvents': instance.otpEvents,
      'locationExceptions': instance.locationExceptions,
      'canEdit': instance.canEdit,
      'canCancel': instance.canCancel,
      'cancelInfo': ?instance.cancelInfo,
      'audience': _$LoadAudienceEnumMap[instance.audience]!,
      'wishlistUntil': ?instance.wishlistUntil?.toIso8601String(),
      'openedToEveryoneAt': ?instance.openedToEveryoneAt?.toIso8601String(),
    };

const _$FreightPayerEnumMap = {
  FreightPayer.shipper: 'SHIPPER',
  FreightPayer.receiver: 'RECEIVER',
  FreightPayer.unknown: 'UNKNOWN',
};

const _$LoadAudienceEnumMap = {
  LoadAudience.everyone: 'EVERYONE',
  LoadAudience.wishlistFirst: 'WISHLIST_FIRST',
  LoadAudience.wishlistOnly: 'WISHLIST_ONLY',
  LoadAudience.unknown: 'UNKNOWN',
};

_LoadCreate _$LoadCreateFromJson(Map<String, dynamic> json) => _LoadCreate(
  pickupWindowStart: DateTime.parse(json['pickupWindowStart'] as String),
  pickupWindowEnd: DateTime.parse(json['pickupWindowEnd'] as String),
  pickup: Place.fromJson(json['pickup'] as Map<String, dynamic>),
  senderName: json['senderName'] as String,
  senderMobile: json['senderMobile'] as String,
  goodsType: json['goodsType'] as String,
  description: json['description'] as String?,
  quantity: json['quantity'] as num,
  quantityUnit: $enumDecode(_$QuantityUnitEnumMap, json['quantityUnit']),
  weightTonnes: json['weightTonnes'] as num,
  vehicleType: $enumDecode(_$VehicleTypeEnumMap, json['vehicleType']),
  drop: Place.fromJson(json['drop'] as Map<String, dynamic>),
  receiverName: json['receiverName'] as String,
  receiverMobile: json['receiverMobile'] as String,
  freightPaidBy: $enumDecode(_$FreightPayerEnumMap, json['freightPaidBy']),
  amountInr: (json['amountInr'] as num).toInt(),
  postedForFarmerId: json['postedForFarmerId'] as String?,
  audience:
      $enumDecodeNullable(_$LoadAudienceEnumMap, json['audience']) ??
      LoadAudience.everyone,
  wishlistEntryIds: (json['wishlistEntryIds'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$LoadCreateToJson(_LoadCreate instance) =>
    <String, dynamic>{
      'pickupWindowStart': instance.pickupWindowStart.toIso8601String(),
      'pickupWindowEnd': instance.pickupWindowEnd.toIso8601String(),
      'pickup': instance.pickup.toJson(),
      'senderName': instance.senderName,
      'senderMobile': instance.senderMobile,
      'goodsType': instance.goodsType,
      'description': ?instance.description,
      'quantity': instance.quantity,
      'quantityUnit': _$QuantityUnitEnumMap[instance.quantityUnit]!,
      'weightTonnes': instance.weightTonnes,
      'vehicleType': _$VehicleTypeEnumMap[instance.vehicleType]!,
      'drop': instance.drop.toJson(),
      'receiverName': instance.receiverName,
      'receiverMobile': instance.receiverMobile,
      'freightPaidBy': _$FreightPayerEnumMap[instance.freightPaidBy]!,
      'amountInr': instance.amountInr,
      'postedForFarmerId': ?instance.postedForFarmerId,
      'audience': _$LoadAudienceEnumMap[instance.audience]!,
      'wishlistEntryIds': ?instance.wishlistEntryIds,
    };

_LoadEstimate _$LoadEstimateFromJson(Map<String, dynamic> json) =>
    _LoadEstimate(
      distanceKm: (json['distanceKm'] as num).toDouble(),
      driveMinutes: (json['driveMinutes'] as num).toInt(),
      deliveryEta: DateTime.parse(json['deliveryEta'] as String),
      suggestedAmountRange:
          json['suggestedAmountRange'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$LoadEstimateToJson(_LoadEstimate instance) =>
    <String, dynamic>{
      'distanceKm': instance.distanceKm,
      'driveMinutes': instance.driveMinutes,
      'deliveryEta': instance.deliveryEta.toIso8601String(),
      'suggestedAmountRange': ?instance.suggestedAmountRange,
    };

_LoadTracking _$LoadTrackingFromJson(
  Map<String, dynamic> json,
) => _LoadTracking(
  driverLocation: json['driverLocation'] == null
      ? null
      : DriverLocation.fromJson(json['driverLocation'] as Map<String, dynamic>),
  etaAt: json['etaAt'] == null ? null : DateTime.parse(json['etaAt'] as String),
  routeStatus: $enumDecodeNullable(
    _$RouteStatusEnumMap,
    json['routeStatus'],
    unknownValue: RouteStatus.unknown,
  ),
);

Map<String, dynamic> _$LoadTrackingToJson(_LoadTracking instance) =>
    <String, dynamic>{
      'driverLocation': ?instance.driverLocation?.toJson(),
      'etaAt': ?instance.etaAt?.toIso8601String(),
      'routeStatus': ?_$RouteStatusEnumMap[instance.routeStatus],
    };

const _$RouteStatusEnumMap = {
  RouteStatus.normal: 'NORMAL',
  RouteStatus.slow: 'SLOW',
  RouteStatus.fast: 'FAST',
  RouteStatus.unknown: 'UNKNOWN',
};

_DriverLocation _$DriverLocationFromJson(Map<String, dynamic> json) =>
    _DriverLocation(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      at: DateTime.parse(json['at'] as String),
    );

Map<String, dynamic> _$DriverLocationToJson(_DriverLocation instance) =>
    <String, dynamic>{
      'lat': instance.lat,
      'lng': instance.lng,
      'at': instance.at.toIso8601String(),
    };

_OtpView _$OtpViewFromJson(Map<String, dynamic> json) => _OtpView(
  purpose: $enumDecode(
    _$OtpPurposeEnumMap,
    json['purpose'],
    unknownValue: OtpPurpose.unknown,
  ),
  code: json['code'] as String,
  expiresAt: DateTime.parse(json['expiresAt'] as String),
);

Map<String, dynamic> _$OtpViewToJson(_OtpView instance) => <String, dynamic>{
  'purpose': _$OtpPurposeEnumMap[instance.purpose]!,
  'code': instance.code,
  'expiresAt': instance.expiresAt.toIso8601String(),
};

const _$OtpPurposeEnumMap = {
  OtpPurpose.signUp: 'SIGN_UP',
  OtpPurpose.signIn: 'SIGN_IN',
  OtpPurpose.changeMobile: 'CHANGE_MOBILE',
  OtpPurpose.pickup: 'PICKUP',
  OtpPurpose.delivery: 'DELIVERY',
  OtpPurpose.unknown: 'UNKNOWN',
};

_Suggestion _$SuggestionFromJson(Map<String, dynamic> json) => _Suggestion(
  loadId: json['loadId'] as String,
  goodsType: json['goodsType'] as String,
  description: json['description'] as String?,
  quantity: json['quantity'] as num,
  unit: $enumDecode(
    _$QuantityUnitEnumMap,
    json['unit'],
    unknownValue: QuantityUnit.unknown,
  ),
  weightTonnes: json['weightTonnes'] as num,
  pickupArea: json['pickupArea'] as String,
  dropArea: json['dropArea'] as String,
  pickupWindowStart: DateTime.parse(json['pickupWindowStart'] as String),
  distanceToPickupKm: (json['distanceToPickupKm'] as num).toDouble(),
  minutesToPickup: (json['minutesToPickup'] as num).toInt(),
  deliveryEta: json['deliveryEta'] == null
      ? null
      : DateTime.parse(json['deliveryEta'] as String),
  amountInr: (json['amountInr'] as num).toInt(),
  shipperTrustScore: (json['shipperTrustScore'] as num).toDouble(),
  preferredByShipper: json['preferredByShipper'] as bool? ?? false,
);

Map<String, dynamic> _$SuggestionToJson(_Suggestion instance) =>
    <String, dynamic>{
      'loadId': instance.loadId,
      'goodsType': instance.goodsType,
      'description': ?instance.description,
      'quantity': instance.quantity,
      'unit': _$QuantityUnitEnumMap[instance.unit]!,
      'weightTonnes': instance.weightTonnes,
      'pickupArea': instance.pickupArea,
      'dropArea': instance.dropArea,
      'pickupWindowStart': instance.pickupWindowStart.toIso8601String(),
      'distanceToPickupKm': instance.distanceToPickupKm,
      'minutesToPickup': instance.minutesToPickup,
      'deliveryEta': ?instance.deliveryEta?.toIso8601String(),
      'amountInr': instance.amountInr,
      'shipperTrustScore': instance.shipperTrustScore,
      'preferredByShipper': instance.preferredByShipper,
    };
