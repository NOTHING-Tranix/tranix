// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Wallet _$WalletFromJson(Map<String, dynamic> json) => _Wallet(
  balanceInr: (json['balanceInr'] as num).toInt(),
  postingChargeInr: (json['postingChargeInr'] as num).toInt(),
  tripChargeInr: (json['tripChargeInr'] as num).toInt(),
  lowBalance: json['lowBalance'] as bool? ?? false,
);

Map<String, dynamic> _$WalletToJson(_Wallet instance) => <String, dynamic>{
  'balanceInr': instance.balanceInr,
  'postingChargeInr': instance.postingChargeInr,
  'tripChargeInr': instance.tripChargeInr,
  'lowBalance': instance.lowBalance,
};

_WalletTransaction _$WalletTransactionFromJson(Map<String, dynamic> json) =>
    _WalletTransaction(
      txnId: json['txnId'] as String,
      at: DateTime.parse(json['at'] as String),
      amountInr: (json['amountInr'] as num).toInt(),
      direction: $enumDecode(
        _$TxnDirectionEnumMap,
        json['direction'],
        unknownValue: TxnDirection.unknown,
      ),
      type: $enumDecode(
        _$TxnTypeEnumMap,
        json['type'],
        unknownValue: TxnType.unknown,
      ),
      loadId: json['loadId'] as String?,
      note: json['note'] as String?,
    );

Map<String, dynamic> _$WalletTransactionToJson(_WalletTransaction instance) =>
    <String, dynamic>{
      'txnId': instance.txnId,
      'at': instance.at.toIso8601String(),
      'amountInr': instance.amountInr,
      'direction': _$TxnDirectionEnumMap[instance.direction]!,
      'type': _$TxnTypeEnumMap[instance.type]!,
      'loadId': ?instance.loadId,
      'note': ?instance.note,
    };

const _$TxnDirectionEnumMap = {
  TxnDirection.credit: 'CREDIT',
  TxnDirection.debit: 'DEBIT',
  TxnDirection.unknown: 'UNKNOWN',
};

const _$TxnTypeEnumMap = {
  TxnType.topup: 'TOPUP',
  TxnType.postingCharge: 'POSTING_CHARGE',
  TxnType.tripCharge: 'TRIP_CHARGE',
  TxnType.refund: 'REFUND',
  TxnType.adminCredit: 'ADMIN_CREDIT',
  TxnType.unknown: 'UNKNOWN',
};

_TopupLink _$TopupLinkFromJson(Map<String, dynamic> json) => _TopupLink(
  url: json['url'] as String,
  expiresAt: DateTime.parse(json['expiresAt'] as String),
);

Map<String, dynamic> _$TopupLinkToJson(_TopupLink instance) =>
    <String, dynamic>{
      'url': instance.url,
      'expiresAt': instance.expiresAt.toIso8601String(),
    };
