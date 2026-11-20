import 'package:freezed_annotation/freezed_annotation.dart';

import 'common.dart';
import 'enums.dart';

part 'loads.freezed.dart';
part 'loads.g.dart';

/// `LoadSummary` (contract §6).
@freezed
abstract class LoadSummary with _$LoadSummary {
  const factory LoadSummary({
    required String id,
    required String code,
    @JsonKey(unknownEnumValue: LoadStatus.unknown) required LoadStatus status,
    required String goodsType,
    String? description,
    required num quantity,
    @JsonKey(unknownEnumValue: QuantityUnit.unknown) required QuantityUnit quantityUnit,
    required String pickupArea,
    required String dropArea,
    required DateTime pickupWindowStart,
    required int agreedAmountInr,
    @JsonKey(unknownEnumValue: PaymentStatus.unknown) PaymentStatus? paymentStatus,
    String? postedForFarmerName,
  }) = _LoadSummary;

  factory LoadSummary.fromJson(Map<String, dynamic> json) => _$LoadSummaryFromJson(json);
}

@freezed
abstract class TimelineEntry with _$TimelineEntry {
  const factory TimelineEntry({
    @JsonKey(unknownEnumValue: LoadStatus.unknown) required LoadStatus status,
    required DateTime at,
  }) = _TimelineEntry;

  factory TimelineEntry.fromJson(Map<String, dynamic> json) => _$TimelineEntryFromJson(json);
}

/// Driver shown to the shipper after acceptance.
@freezed
abstract class LoadDriver with _$LoadDriver {
  const factory LoadDriver({
    required String id,
    required String name,
    String? photoUrl,
    required String mobile,
    required double trustScore,
    required String truckNumber,
    @JsonKey(unknownEnumValue: VehicleType.unknown) required VehicleType vehicleType,
  }) = _LoadDriver;

  factory LoadDriver.fromJson(Map<String, dynamic> json) => _$LoadDriverFromJson(json);
}

@freezed
abstract class AmountRevision with _$AmountRevision {
  const factory AmountRevision({
    required String id,
    required int requestedAmountInr,
    required String reason,
    @JsonKey(unknownEnumValue: RevisionStatus.unknown) required RevisionStatus status,
    required DateTime createdAt,
    required DateTime respondBy,
  }) = _AmountRevision;

  factory AmountRevision.fromJson(Map<String, dynamic> json) => _$AmountRevisionFromJson(json);
}

@freezed
abstract class LoadPayment with _$LoadPayment {
  const factory LoadPayment({
    @JsonKey(unknownEnumValue: PaymentStatus.unknown) required PaymentStatus status,
    int? amountInr,
    @JsonKey(unknownEnumValue: PaymentMode.unknown) PaymentMode? mode,
    String? reference,
    DateTime? paidAt,
    DateTime? confirmedAt,
    String? disputeReason,
  }) = _LoadPayment;

  factory LoadPayment.fromJson(Map<String, dynamic> json) => _$LoadPaymentFromJson(json);
}

/// `LoadDetail = LoadSummary + {...}` (contract §6). Exact pins, names and phones are present only when the
/// server returns them (after acceptance for drivers).
@freezed
abstract class LoadDetail with _$LoadDetail {
  const factory LoadDetail({
    required String id,
    required String code,
    @JsonKey(unknownEnumValue: LoadStatus.unknown) required LoadStatus status,
    required String goodsType,
    String? description,
    required num quantity,
    @JsonKey(unknownEnumValue: QuantityUnit.unknown) required QuantityUnit quantityUnit,
    required String pickupArea,
    required String dropArea,
    required DateTime pickupWindowStart,
    required int agreedAmountInr,
    @JsonKey(unknownEnumValue: PaymentStatus.unknown) PaymentStatus? paymentStatus,
    String? postedForFarmerName,
    required Place pickup,
    required Place drop,
    required String senderName,
    required String senderMobile,
    required String receiverName,
    required String receiverMobile,
    required num weightTonnes,
    @JsonKey(unknownEnumValue: VehicleType.unknown) required VehicleType vehicleType,
    @JsonKey(unknownEnumValue: FreightPayer.unknown) required FreightPayer freightPaidBy,
    required int postedAmountInr,
    DateTime? deliveryEta,
    @Default(<TimelineEntry>[]) List<TimelineEntry> timeline,
    LoadDriver? driver,
    @Default(<AmountRevision>[]) List<AmountRevision> revisions,
    @Default(0) int revisionsUsed,
    LoadPayment? payment,
    @Default(<Map<String, dynamic>>[]) List<Map<String, dynamic>> otpEvents,
    @Default(<Map<String, dynamic>>[]) List<Map<String, dynamic>> locationExceptions,
    @Default(false) bool canEdit,
    @Default(false) bool canCancel,
    Map<String, dynamic>? cancelInfo,
    @JsonKey(unknownEnumValue: LoadAudience.unknown) @Default(LoadAudience.everyone) LoadAudience audience,
    DateTime? wishlistUntil,
    DateTime? openedToEveryoneAt,
  }) = _LoadDetail;

  factory LoadDetail.fromJson(Map<String, dynamic> json) => _$LoadDetailFromJson(json);
}

/// `POST /loads` body (contract §6).
@freezed
abstract class LoadCreate with _$LoadCreate {
  const factory LoadCreate({
    required DateTime pickupWindowStart,
    required DateTime pickupWindowEnd,
    required Place pickup,
    required String senderName,
    required String senderMobile,
    required String goodsType,
    String? description,
    required num quantity,
    required QuantityUnit quantityUnit,
    required num weightTonnes,
    required VehicleType vehicleType,
    required Place drop,
    required String receiverName,
    required String receiverMobile,
    required FreightPayer freightPaidBy,
    required int amountInr,
    String? postedForFarmerId,
    @Default(LoadAudience.everyone) LoadAudience audience,
    List<String>? wishlistEntryIds,
  }) = _LoadCreate;

  factory LoadCreate.fromJson(Map<String, dynamic> json) => _$LoadCreateFromJson(json);
}

/// `POST /loads/estimate` response.
@freezed
abstract class LoadEstimate with _$LoadEstimate {
  const factory LoadEstimate({
    required double distanceKm,
    required int driveMinutes,
    required DateTime deliveryEta,
    Map<String, dynamic>? suggestedAmountRange,
  }) = _LoadEstimate;

  factory LoadEstimate.fromJson(Map<String, dynamic> json) => _$LoadEstimateFromJson(json);
}

/// `GET /loads/{id}/tracking`.
@freezed
abstract class LoadTracking with _$LoadTracking {
  const factory LoadTracking({
    DriverLocation? driverLocation,
    DateTime? etaAt,
    @JsonKey(unknownEnumValue: RouteStatus.unknown) RouteStatus? routeStatus,
  }) = _LoadTracking;

  factory LoadTracking.fromJson(Map<String, dynamic> json) => _$LoadTrackingFromJson(json);
}

@freezed
abstract class DriverLocation with _$DriverLocation {
  const factory DriverLocation({required double lat, required double lng, required DateTime at}) =
      _DriverLocation;

  factory DriverLocation.fromJson(Map<String, dynamic> json) => _$DriverLocationFromJson(json);
}

/// `GET /loads/{id}/otp`.
@freezed
abstract class OtpView with _$OtpView {
  const factory OtpView({
    @JsonKey(unknownEnumValue: OtpPurpose.unknown) required OtpPurpose purpose,
    required String code,
    required DateTime expiresAt,
  }) = _OtpView;

  factory OtpView.fromJson(Map<String, dynamic> json) => _$OtpViewFromJson(json);
}

/// Area-only suggestion card for drivers (contract §8) — never exact pins or phones.
@freezed
abstract class Suggestion with _$Suggestion {
  const factory Suggestion({
    required String loadId,
    required String goodsType,
    String? description,
    required num quantity,
    @JsonKey(unknownEnumValue: QuantityUnit.unknown) required QuantityUnit unit,
    required num weightTonnes,
    required String pickupArea,
    required String dropArea,
    required DateTime pickupWindowStart,
    required double distanceToPickupKm,
    required int minutesToPickup,
    DateTime? deliveryEta,
    required int amountInr,
    required double shipperTrustScore,
    @Default(false) bool preferredByShipper,
  }) = _Suggestion;

  factory Suggestion.fromJson(Map<String, dynamic> json) => _$SuggestionFromJson(json);
}

