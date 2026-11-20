import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';

part 'engagement.freezed.dart';
part 'engagement.g.dart';

/// `WishlistEntry` (contract §6A).
@freezed
abstract class WishlistEntry with _$WishlistEntry {
  const factory WishlistEntry({
    required String id,
    @JsonKey(unknownEnumValue: WishlistTargetType.unknown) required WishlistTargetType targetType,
    String? truckNumber,
    @JsonKey(unknownEnumValue: VehicleType.unknown) VehicleType? vehicleType,
    num? capacityTonnes,
    String? driverName,
    String? orgId,
    String? orgName,
    required double trustScore,
    @Default(0) int tripsTogether,
    String? note,
    @Default(false) bool available,
  }) = _WishlistEntry;

  factory WishlistEntry.fromJson(Map<String, dynamic> json) => _$WishlistEntryFromJson(json);
}

/// `GET /trust-score`.
@freezed
abstract class TrustScore with _$TrustScore {
  const factory TrustScore({
    required double score,
    required DateTime updatedAt,
    @Default(<double>[]) List<double> trend,
  }) = _TrustScore;

  factory TrustScore.fromJson(Map<String, dynamic> json) => _$TrustScoreFromJson(json);
}

/// One row of `GET /trust-score/events`.
@freezed
abstract class TrustEvent with _$TrustEvent {
  const factory TrustEvent({
    required DateTime at,
    String? loadId,
    required String event,
    required double points,
    required String reason,
  }) = _TrustEvent;

  factory TrustEvent.fromJson(Map<String, dynamic> json) => _$TrustEventFromJson(json);
}

/// One row of `GET /ratings/pending`.
@freezed
abstract class PendingRating with _$PendingRating {
  const factory PendingRating({
    required String loadId,
    required String rateeName,
    @JsonKey(unknownEnumValue: Role.unknown) required Role rateeRole,
  }) = _PendingRating;

  factory PendingRating.fromJson(Map<String, dynamic> json) => _$PendingRatingFromJson(json);
}

/// `GET /notifications/summary`.
@freezed
abstract class NotificationSummary with _$NotificationSummary {
  const factory NotificationSummary({
    @Default(<String, int>{}) Map<String, int> unreadByTab,
    AppNotification? latestTranixMessage,
    AppNotification? latestTripUpdate,
  }) = _NotificationSummary;

  factory NotificationSummary.fromJson(Map<String, dynamic> json) => _$NotificationSummaryFromJson(json);
}

/// One inbox item (`GET /notifications`).
@freezed
abstract class AppNotification with _$AppNotification {
  const factory AppNotification({
    required String id,
    @JsonKey(unknownEnumValue: NotificationTab.unknown) required NotificationTab tab,
    required String type,
    required String title,
    required String body,
    String? route,
    @Default(false) bool read,
    required DateTime createdAt,
  }) = _AppNotification;

  factory AppNotification.fromJson(Map<String, dynamic> json) => _$AppNotificationFromJson(json);
}
