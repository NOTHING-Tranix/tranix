import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';

part 'wallet.freezed.dart';
part 'wallet.g.dart';

/// `GET /wallet` (contract §5).
@freezed
abstract class Wallet with _$Wallet {
  const factory Wallet({
    required int balanceInr,
    required int postingChargeInr,
    required int tripChargeInr,
    @Default(false) bool lowBalance,
  }) = _Wallet;

  factory Wallet.fromJson(Map<String, dynamic> json) => _$WalletFromJson(json);
}

/// One row of `GET /wallet/transactions`.
@freezed
abstract class WalletTransaction with _$WalletTransaction {
  const factory WalletTransaction({
    required String txnId,
    required DateTime at,
    required int amountInr,
    @JsonKey(unknownEnumValue: TxnDirection.unknown) required TxnDirection direction,
    @JsonKey(unknownEnumValue: TxnType.unknown) required TxnType type,
    String? loadId,
    String? note,
  }) = _WalletTransaction;

  factory WalletTransaction.fromJson(Map<String, dynamic> json) => _$WalletTransactionFromJson(json);
}

/// `POST /wallet/topup-link` → open `url` in the external browser (D-13).
@freezed
abstract class TopupLink with _$TopupLink {
  const factory TopupLink({required String url, required DateTime expiresAt}) = _TopupLink;

  factory TopupLink.fromJson(Map<String, dynamic> json) => _$TopupLinkFromJson(json);
}
