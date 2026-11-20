// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wallet.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Wallet {

 int get balanceInr; int get postingChargeInr; int get tripChargeInr; bool get lowBalance;
/// Create a copy of Wallet
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WalletCopyWith<Wallet> get copyWith => _$WalletCopyWithImpl<Wallet>(this as Wallet, _$identity);

  /// Serializes this Wallet to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Wallet;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Wallet&&(identical(other.balanceInr, _this.balanceInr) || other.balanceInr == _this.balanceInr)&&(identical(other.postingChargeInr, _this.postingChargeInr) || other.postingChargeInr == _this.postingChargeInr)&&(identical(other.tripChargeInr, _this.tripChargeInr) || other.tripChargeInr == _this.tripChargeInr)&&(identical(other.lowBalance, _this.lowBalance) || other.lowBalance == _this.lowBalance));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Wallet;
  return Object.hash(runtimeType,_this.balanceInr,_this.postingChargeInr,_this.tripChargeInr,_this.lowBalance);
}

@override
String toString() {
  final _this = this as Wallet;
  return 'Wallet(balanceInr: ${_this.balanceInr}, postingChargeInr: ${_this.postingChargeInr}, tripChargeInr: ${_this.tripChargeInr}, lowBalance: ${_this.lowBalance})';
}


}

/// @nodoc
abstract mixin class $WalletCopyWith<$Res>  {
  factory $WalletCopyWith(Wallet value, $Res Function(Wallet) _then) = _$WalletCopyWithImpl;
@useResult
$Res call({
 int balanceInr, int postingChargeInr, int tripChargeInr, bool lowBalance
});




}
/// @nodoc
class _$WalletCopyWithImpl<$Res>
    implements $WalletCopyWith<$Res> {
  _$WalletCopyWithImpl(this._self, this._then);

  final Wallet _self;
  final $Res Function(Wallet) _then;

/// Create a copy of Wallet
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? balanceInr = null,Object? postingChargeInr = null,Object? tripChargeInr = null,Object? lowBalance = null,}) {
  return _then(Wallet(
balanceInr: null == balanceInr ? _self.balanceInr : balanceInr // ignore: cast_nullable_to_non_nullable
as int,postingChargeInr: null == postingChargeInr ? _self.postingChargeInr : postingChargeInr // ignore: cast_nullable_to_non_nullable
as int,tripChargeInr: null == tripChargeInr ? _self.tripChargeInr : tripChargeInr // ignore: cast_nullable_to_non_nullable
as int,lowBalance: null == lowBalance ? _self.lowBalance : lowBalance // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Wallet].
extension WalletPatterns on Wallet {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Wallet value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Wallet() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Wallet value)  $default,){
final _that = this;
switch (_that) {
case _Wallet():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Wallet value)?  $default,){
final _that = this;
switch (_that) {
case _Wallet() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int balanceInr,  int postingChargeInr,  int tripChargeInr,  bool lowBalance)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Wallet() when $default != null:
return $default(_that.balanceInr,_that.postingChargeInr,_that.tripChargeInr,_that.lowBalance);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int balanceInr,  int postingChargeInr,  int tripChargeInr,  bool lowBalance)  $default,) {final _that = this;
switch (_that) {
case _Wallet():
return $default(_that.balanceInr,_that.postingChargeInr,_that.tripChargeInr,_that.lowBalance);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int balanceInr,  int postingChargeInr,  int tripChargeInr,  bool lowBalance)?  $default,) {final _that = this;
switch (_that) {
case _Wallet() when $default != null:
return $default(_that.balanceInr,_that.postingChargeInr,_that.tripChargeInr,_that.lowBalance);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Wallet implements Wallet {
  const _Wallet({required this.balanceInr, required this.postingChargeInr, required this.tripChargeInr, this.lowBalance = false});
  factory _Wallet.fromJson(Map<String, dynamic> json) => _$WalletFromJson(json);

@override final  int balanceInr;
@override final  int postingChargeInr;
@override final  int tripChargeInr;
@override@JsonKey() final  bool lowBalance;

/// Create a copy of Wallet
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WalletCopyWith<_Wallet> get copyWith => __$WalletCopyWithImpl<_Wallet>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WalletToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Wallet&&(identical(other.balanceInr, balanceInr) || other.balanceInr == balanceInr)&&(identical(other.postingChargeInr, postingChargeInr) || other.postingChargeInr == postingChargeInr)&&(identical(other.tripChargeInr, tripChargeInr) || other.tripChargeInr == tripChargeInr)&&(identical(other.lowBalance, lowBalance) || other.lowBalance == lowBalance));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,balanceInr,postingChargeInr,tripChargeInr,lowBalance);
}

@override
String toString() {
    return 'Wallet(balanceInr: $balanceInr, postingChargeInr: $postingChargeInr, tripChargeInr: $tripChargeInr, lowBalance: $lowBalance)';
}


}

/// @nodoc
abstract mixin class _$WalletCopyWith<$Res> implements $WalletCopyWith<$Res> {
  factory _$WalletCopyWith(_Wallet value, $Res Function(_Wallet) _then) = __$WalletCopyWithImpl;
@override @useResult
$Res call({
 int balanceInr, int postingChargeInr, int tripChargeInr, bool lowBalance
});




}
/// @nodoc
class __$WalletCopyWithImpl<$Res>
    implements _$WalletCopyWith<$Res> {
  __$WalletCopyWithImpl(this._self, this._then);

  final _Wallet _self;
  final $Res Function(_Wallet) _then;

/// Create a copy of Wallet
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? balanceInr = null,Object? postingChargeInr = null,Object? tripChargeInr = null,Object? lowBalance = null,}) {
  return _then(_Wallet(
balanceInr: null == balanceInr ? _self.balanceInr : balanceInr // ignore: cast_nullable_to_non_nullable
as int,postingChargeInr: null == postingChargeInr ? _self.postingChargeInr : postingChargeInr // ignore: cast_nullable_to_non_nullable
as int,tripChargeInr: null == tripChargeInr ? _self.tripChargeInr : tripChargeInr // ignore: cast_nullable_to_non_nullable
as int,lowBalance: null == lowBalance ? _self.lowBalance : lowBalance // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$WalletTransaction {

 String get txnId; DateTime get at; int get amountInr;@JsonKey(unknownEnumValue: TxnDirection.unknown) TxnDirection get direction;@JsonKey(unknownEnumValue: TxnType.unknown) TxnType get type; String? get loadId; String? get note;
/// Create a copy of WalletTransaction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WalletTransactionCopyWith<WalletTransaction> get copyWith => _$WalletTransactionCopyWithImpl<WalletTransaction>(this as WalletTransaction, _$identity);

  /// Serializes this WalletTransaction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as WalletTransaction;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WalletTransaction&&(identical(other.txnId, _this.txnId) || other.txnId == _this.txnId)&&(identical(other.at, _this.at) || other.at == _this.at)&&(identical(other.amountInr, _this.amountInr) || other.amountInr == _this.amountInr)&&(identical(other.direction, _this.direction) || other.direction == _this.direction)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.loadId, _this.loadId) || other.loadId == _this.loadId)&&(identical(other.note, _this.note) || other.note == _this.note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as WalletTransaction;
  return Object.hash(runtimeType,_this.txnId,_this.at,_this.amountInr,_this.direction,_this.type,_this.loadId,_this.note);
}

@override
String toString() {
  final _this = this as WalletTransaction;
  return 'WalletTransaction(txnId: ${_this.txnId}, at: ${_this.at}, amountInr: ${_this.amountInr}, direction: ${_this.direction}, type: ${_this.type}, loadId: ${_this.loadId}, note: ${_this.note})';
}


}

/// @nodoc
abstract mixin class $WalletTransactionCopyWith<$Res>  {
  factory $WalletTransactionCopyWith(WalletTransaction value, $Res Function(WalletTransaction) _then) = _$WalletTransactionCopyWithImpl;
@useResult
$Res call({
 String txnId, DateTime at, int amountInr,@JsonKey(unknownEnumValue: TxnDirection.unknown) TxnDirection direction,@JsonKey(unknownEnumValue: TxnType.unknown) TxnType type, String? loadId, String? note
});




}
/// @nodoc
class _$WalletTransactionCopyWithImpl<$Res>
    implements $WalletTransactionCopyWith<$Res> {
  _$WalletTransactionCopyWithImpl(this._self, this._then);

  final WalletTransaction _self;
  final $Res Function(WalletTransaction) _then;

/// Create a copy of WalletTransaction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? txnId = null,Object? at = null,Object? amountInr = null,Object? direction = null,Object? type = null,Object? loadId = freezed,Object? note = freezed,}) {
  return _then(WalletTransaction(
txnId: null == txnId ? _self.txnId : txnId // ignore: cast_nullable_to_non_nullable
as String,at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime,amountInr: null == amountInr ? _self.amountInr : amountInr // ignore: cast_nullable_to_non_nullable
as int,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as TxnDirection,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TxnType,loadId: freezed == loadId ? _self.loadId : loadId // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [WalletTransaction].
extension WalletTransactionPatterns on WalletTransaction {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WalletTransaction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WalletTransaction() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WalletTransaction value)  $default,){
final _that = this;
switch (_that) {
case _WalletTransaction():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WalletTransaction value)?  $default,){
final _that = this;
switch (_that) {
case _WalletTransaction() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String txnId,  DateTime at,  int amountInr, @JsonKey(unknownEnumValue: TxnDirection.unknown)  TxnDirection direction, @JsonKey(unknownEnumValue: TxnType.unknown)  TxnType type,  String? loadId,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WalletTransaction() when $default != null:
return $default(_that.txnId,_that.at,_that.amountInr,_that.direction,_that.type,_that.loadId,_that.note);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String txnId,  DateTime at,  int amountInr, @JsonKey(unknownEnumValue: TxnDirection.unknown)  TxnDirection direction, @JsonKey(unknownEnumValue: TxnType.unknown)  TxnType type,  String? loadId,  String? note)  $default,) {final _that = this;
switch (_that) {
case _WalletTransaction():
return $default(_that.txnId,_that.at,_that.amountInr,_that.direction,_that.type,_that.loadId,_that.note);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String txnId,  DateTime at,  int amountInr, @JsonKey(unknownEnumValue: TxnDirection.unknown)  TxnDirection direction, @JsonKey(unknownEnumValue: TxnType.unknown)  TxnType type,  String? loadId,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _WalletTransaction() when $default != null:
return $default(_that.txnId,_that.at,_that.amountInr,_that.direction,_that.type,_that.loadId,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WalletTransaction implements WalletTransaction {
  const _WalletTransaction({required this.txnId, required this.at, required this.amountInr, @JsonKey(unknownEnumValue: TxnDirection.unknown) required this.direction, @JsonKey(unknownEnumValue: TxnType.unknown) required this.type, this.loadId, this.note});
  factory _WalletTransaction.fromJson(Map<String, dynamic> json) => _$WalletTransactionFromJson(json);

@override final  String txnId;
@override final  DateTime at;
@override final  int amountInr;
@override@JsonKey(unknownEnumValue: TxnDirection.unknown) final  TxnDirection direction;
@override@JsonKey(unknownEnumValue: TxnType.unknown) final  TxnType type;
@override final  String? loadId;
@override final  String? note;

/// Create a copy of WalletTransaction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WalletTransactionCopyWith<_WalletTransaction> get copyWith => __$WalletTransactionCopyWithImpl<_WalletTransaction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WalletTransactionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WalletTransaction&&(identical(other.txnId, txnId) || other.txnId == txnId)&&(identical(other.at, at) || other.at == at)&&(identical(other.amountInr, amountInr) || other.amountInr == amountInr)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.type, type) || other.type == type)&&(identical(other.loadId, loadId) || other.loadId == loadId)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,txnId,at,amountInr,direction,type,loadId,note);
}

@override
String toString() {
    return 'WalletTransaction(txnId: $txnId, at: $at, amountInr: $amountInr, direction: $direction, type: $type, loadId: $loadId, note: $note)';
}


}

/// @nodoc
abstract mixin class _$WalletTransactionCopyWith<$Res> implements $WalletTransactionCopyWith<$Res> {
  factory _$WalletTransactionCopyWith(_WalletTransaction value, $Res Function(_WalletTransaction) _then) = __$WalletTransactionCopyWithImpl;
@override @useResult
$Res call({
 String txnId, DateTime at, int amountInr,@JsonKey(unknownEnumValue: TxnDirection.unknown) TxnDirection direction,@JsonKey(unknownEnumValue: TxnType.unknown) TxnType type, String? loadId, String? note
});




}
/// @nodoc
class __$WalletTransactionCopyWithImpl<$Res>
    implements _$WalletTransactionCopyWith<$Res> {
  __$WalletTransactionCopyWithImpl(this._self, this._then);

  final _WalletTransaction _self;
  final $Res Function(_WalletTransaction) _then;

/// Create a copy of WalletTransaction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? txnId = null,Object? at = null,Object? amountInr = null,Object? direction = null,Object? type = null,Object? loadId = freezed,Object? note = freezed,}) {
  return _then(_WalletTransaction(
txnId: null == txnId ? _self.txnId : txnId // ignore: cast_nullable_to_non_nullable
as String,at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime,amountInr: null == amountInr ? _self.amountInr : amountInr // ignore: cast_nullable_to_non_nullable
as int,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as TxnDirection,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TxnType,loadId: freezed == loadId ? _self.loadId : loadId // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$TopupLink {

 String get url; DateTime get expiresAt;
/// Create a copy of TopupLink
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TopupLinkCopyWith<TopupLink> get copyWith => _$TopupLinkCopyWithImpl<TopupLink>(this as TopupLink, _$identity);

  /// Serializes this TopupLink to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TopupLink;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TopupLink&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TopupLink;
  return Object.hash(runtimeType,_this.url,_this.expiresAt);
}

@override
String toString() {
  final _this = this as TopupLink;
  return 'TopupLink(url: ${_this.url}, expiresAt: ${_this.expiresAt})';
}


}

/// @nodoc
abstract mixin class $TopupLinkCopyWith<$Res>  {
  factory $TopupLinkCopyWith(TopupLink value, $Res Function(TopupLink) _then) = _$TopupLinkCopyWithImpl;
@useResult
$Res call({
 String url, DateTime expiresAt
});




}
/// @nodoc
class _$TopupLinkCopyWithImpl<$Res>
    implements $TopupLinkCopyWith<$Res> {
  _$TopupLinkCopyWithImpl(this._self, this._then);

  final TopupLink _self;
  final $Res Function(TopupLink) _then;

/// Create a copy of TopupLink
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = null,Object? expiresAt = null,}) {
  return _then(TopupLink(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [TopupLink].
extension TopupLinkPatterns on TopupLink {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TopupLink value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TopupLink() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TopupLink value)  $default,){
final _that = this;
switch (_that) {
case _TopupLink():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TopupLink value)?  $default,){
final _that = this;
switch (_that) {
case _TopupLink() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String url,  DateTime expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TopupLink() when $default != null:
return $default(_that.url,_that.expiresAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String url,  DateTime expiresAt)  $default,) {final _that = this;
switch (_that) {
case _TopupLink():
return $default(_that.url,_that.expiresAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String url,  DateTime expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _TopupLink() when $default != null:
return $default(_that.url,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TopupLink implements TopupLink {
  const _TopupLink({required this.url, required this.expiresAt});
  factory _TopupLink.fromJson(Map<String, dynamic> json) => _$TopupLinkFromJson(json);

@override final  String url;
@override final  DateTime expiresAt;

/// Create a copy of TopupLink
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TopupLinkCopyWith<_TopupLink> get copyWith => __$TopupLinkCopyWithImpl<_TopupLink>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TopupLinkToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TopupLink&&(identical(other.url, url) || other.url == url)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,url,expiresAt);
}

@override
String toString() {
    return 'TopupLink(url: $url, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class _$TopupLinkCopyWith<$Res> implements $TopupLinkCopyWith<$Res> {
  factory _$TopupLinkCopyWith(_TopupLink value, $Res Function(_TopupLink) _then) = __$TopupLinkCopyWithImpl;
@override @useResult
$Res call({
 String url, DateTime expiresAt
});




}
/// @nodoc
class __$TopupLinkCopyWithImpl<$Res>
    implements _$TopupLinkCopyWith<$Res> {
  __$TopupLinkCopyWithImpl(this._self, this._then);

  final _TopupLink _self;
  final $Res Function(_TopupLink) _then;

/// Create a copy of TopupLink
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = null,Object? expiresAt = null,}) {
  return _then(_TopupLink(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
