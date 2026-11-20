// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Me _$MeFromJson(Map<String, dynamic> json) => _Me(
  id: json['id'] as String,
  name: json['name'] as String,
  mobile: json['mobile'] as String,
  role: $enumDecode(_$RoleEnumMap, json['role'], unknownValue: Role.unknown),
  language:
      $enumDecodeNullable(
        _$LanguageEnumMap,
        json['language'],
        unknownValue: Language.en,
      ) ??
      Language.en,
  photoUrl: json['photoUrl'] as String?,
  verificationStatus:
      $enumDecodeNullable(
        _$VerificationStatusEnumMap,
        json['verificationStatus'],
        unknownValue: VerificationStatus.unknown,
      ) ??
      VerificationStatus.notSubmitted,
  profileCompletion: (json['profileCompletion'] as num?)?.toInt() ?? 0,
  trustScore: (json['trustScore'] as num?)?.toDouble() ?? 70,
  walletBalanceInr: (json['walletBalanceInr'] as num?)?.toInt(),
  pendingRatingsCount: (json['pendingRatingsCount'] as num?)?.toInt() ?? 0,
  unreadNotifications: (json['unreadNotifications'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$MeToJson(_Me instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'mobile': instance.mobile,
  'role': _$RoleEnumMap[instance.role]!,
  'language': _$LanguageEnumMap[instance.language]!,
  'photoUrl': ?instance.photoUrl,
  'verificationStatus':
      _$VerificationStatusEnumMap[instance.verificationStatus]!,
  'profileCompletion': instance.profileCompletion,
  'trustScore': instance.trustScore,
  'walletBalanceInr': ?instance.walletBalanceInr,
  'pendingRatingsCount': instance.pendingRatingsCount,
  'unreadNotifications': instance.unreadNotifications,
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

const _$LanguageEnumMap = {
  Language.en: 'en',
  Language.ta: 'ta',
  Language.hi: 'hi',
};

const _$VerificationStatusEnumMap = {
  VerificationStatus.notSubmitted: 'NOT_SUBMITTED',
  VerificationStatus.underReview: 'UNDER_REVIEW',
  VerificationStatus.verified: 'VERIFIED',
  VerificationStatus.notVerified: 'NOT_VERIFIED',
  VerificationStatus.unknown: 'UNKNOWN',
};

_AuthTokens _$AuthTokensFromJson(Map<String, dynamic> json) => _AuthTokens(
  accessToken: json['accessToken'] as String,
  refreshToken: json['refreshToken'] as String,
  expiresIn: (json['expiresIn'] as num).toInt(),
  user: Me.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AuthTokensToJson(_AuthTokens instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'expiresIn': instance.expiresIn,
      'user': instance.user.toJson(),
    };
