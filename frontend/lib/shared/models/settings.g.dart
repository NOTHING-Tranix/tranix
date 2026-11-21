// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PublicSettings _$PublicSettingsFromJson(Map<String, dynamic> json) =>
    _PublicSettings(
      postingChargeInr: (json['postingChargeInr'] as num).toInt(),
      tripChargeInr: (json['tripChargeInr'] as num).toInt(),
      topupChips:
          (json['topupChips'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const <int>[],
      otpTtlSeconds: (json['otpTtlSeconds'] as num).toInt(),
      otpResendSeconds: (json['otpResendSeconds'] as num).toInt(),
      revisionLimit: (json['revisionLimit'] as num).toInt(),
      revisionResponseMinutes: (json['revisionResponseMinutes'] as num).toInt(),
      geofenceMeters: (json['geofenceMeters'] as num).toInt(),
      wishlistMax: (json['wishlistMax'] as num).toInt(),
      wishlistFirstMinutes: (json['wishlistFirstMinutes'] as num).toInt(),
      wishlistOnlyNotifyMinutes: (json['wishlistOnlyNotifyMinutes'] as num)
          .toInt(),
      goodsTypes:
          (json['goodsTypes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      ratingTags:
          (json['ratingTags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      vehicleTypes:
          (json['vehicleTypes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      ticketTypes:
          (json['ticketTypes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      rejectReasons:
          (json['rejectReasons'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      supportedLanguages:
          (json['supportedLanguages'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      aadhaarEnabled: json['aadhaarEnabled'] as bool? ?? false,
    );

Map<String, dynamic> _$PublicSettingsToJson(_PublicSettings instance) =>
    <String, dynamic>{
      'postingChargeInr': instance.postingChargeInr,
      'tripChargeInr': instance.tripChargeInr,
      'topupChips': instance.topupChips,
      'otpTtlSeconds': instance.otpTtlSeconds,
      'otpResendSeconds': instance.otpResendSeconds,
      'revisionLimit': instance.revisionLimit,
      'revisionResponseMinutes': instance.revisionResponseMinutes,
      'geofenceMeters': instance.geofenceMeters,
      'wishlistMax': instance.wishlistMax,
      'wishlistFirstMinutes': instance.wishlistFirstMinutes,
      'wishlistOnlyNotifyMinutes': instance.wishlistOnlyNotifyMinutes,
      'goodsTypes': instance.goodsTypes,
      'ratingTags': instance.ratingTags,
      'vehicleTypes': instance.vehicleTypes,
      'ticketTypes': instance.ticketTypes,
      'rejectReasons': instance.rejectReasons,
      'supportedLanguages': instance.supportedLanguages,
      'aadhaarEnabled': instance.aadhaarEnabled,
    };
