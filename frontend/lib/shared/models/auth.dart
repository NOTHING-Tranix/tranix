import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';

part 'auth.freezed.dart';
part 'auth.g.dart';

/// `GET /me` (contract §4).
@freezed
abstract class Me with _$Me {
  const factory Me({
    required String id,
    required String name,
    required String mobile,
    @JsonKey(unknownEnumValue: Role.unknown) required Role role,
    @JsonKey(unknownEnumValue: Language.en) @Default(Language.en) Language language,
    String? photoUrl,
    @JsonKey(unknownEnumValue: VerificationStatus.unknown)
    @Default(VerificationStatus.notSubmitted)
    VerificationStatus verificationStatus,
    @Default(0) int profileCompletion,
    @Default(70) double trustScore,
    int? walletBalanceInr,
    @Default(0) int pendingRatingsCount,
    @Default(0) int unreadNotifications,
  }) = _Me;

  factory Me.fromJson(Map<String, dynamic> json) => _$MeFromJson(json);
}

/// `AuthTokens = { accessToken, refreshToken, expiresIn, user: Me }`.
@freezed
abstract class AuthTokens with _$AuthTokens {
  const factory AuthTokens({
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
    required Me user,
  }) = _AuthTokens;

  factory AuthTokens.fromJson(Map<String, dynamic> json) => _$AuthTokensFromJson(json);
}
