import 'package:freezed_annotation/freezed_annotation.dart';

import 'documents.dart';
import 'enums.dart';

part 'fleet.freezed.dart';
part 'fleet.g.dart';

/// Truck view (contract §8/§9).
@freezed
abstract class Truck with _$Truck {
  const factory Truck({
    required String id,
    required String number,
    @JsonKey(unknownEnumValue: VehicleType.unknown) required VehicleType vehicleType,
    required num capacityTonnes,
    @JsonKey(unknownEnumValue: TruckStatus.unknown) required TruckStatus status,
    @Default(<Document>[]) List<Document> documents,
    Map<String, dynamic>? allocatedDriver,
    @Default(true) bool ownedByMe,
  }) = _Truck;

  factory Truck.fromJson(Map<String, dynamic> json) => _$TruckFromJson(json);
}

/// `GET /driver/home`.
@freezed
abstract class DriverHome with _$DriverHome {
  const factory DriverHome({
    @Default(false) bool onDuty,
    Truck? truck,
    int? walletBalanceInr,
    String? orgName,
    String? currentLoadId,
    @Default(0) int suggestionsCount,
    @Default(70) double trustScore,
    @Default(<Document>[]) List<Document> expiringDocuments,
  }) = _DriverHome;

  factory DriverHome.fromJson(Map<String, dynamic> json) => _$DriverHomeFromJson(json);
}

/// Organization invitation (`GET /driver/invitations`).
@freezed
abstract class Invitation with _$Invitation {
  const factory Invitation({
    required String id,
    required String orgId,
    required String orgName,
    required String status,
    required DateTime createdAt,
  }) = _Invitation;

  factory Invitation.fromJson(Map<String, dynamic> json) => _$InvitationFromJson(json);
}
