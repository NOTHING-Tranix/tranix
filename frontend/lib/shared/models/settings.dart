import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings.freezed.dart';
part 'settings.g.dart';

/// `GET /settings/public` (contract §12). The app never hard-codes these values (CLAUDE.md rule 10).
/// List values stay strings so a new server value never breaks parsing.
@freezed
abstract class PublicSettings with _$PublicSettings {
  const factory PublicSettings({
    required int postingChargeInr,
    required int tripChargeInr,
    @Default(<int>[]) List<int> topupChips,
    required int otpTtlSeconds,
    required int otpResendSeconds,
    required int revisionLimit,
    required int revisionResponseMinutes,
    required int geofenceMeters,
    required int wishlistMax,
    required int wishlistFirstMinutes,
    required int wishlistOnlyNotifyMinutes,
    @Default(<String>[]) List<String> goodsTypes,
    @Default(<String>[]) List<String> ratingTags,
    @Default(<String>[]) List<String> vehicleTypes,
    @Default(<String>[]) List<String> ticketTypes,
    @Default(<String>[]) List<String> rejectReasons,
    @Default(<String>[]) List<String> supportedLanguages,
    @Default(false) bool aadhaarEnabled,
  }) = _PublicSettings;

  factory PublicSettings.fromJson(Map<String, dynamic> json) => _$PublicSettingsFromJson(json);
}
