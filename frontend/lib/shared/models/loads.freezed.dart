// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'loads.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LoadSummary {

 String get id; String get code;@JsonKey(unknownEnumValue: LoadStatus.unknown) LoadStatus get status; String get goodsType; String? get description; num get quantity;@JsonKey(unknownEnumValue: QuantityUnit.unknown) QuantityUnit get quantityUnit; String get pickupArea; String get dropArea; DateTime get pickupWindowStart; int get agreedAmountInr;@JsonKey(unknownEnumValue: PaymentStatus.unknown) PaymentStatus? get paymentStatus; String? get postedForFarmerName;
/// Create a copy of LoadSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoadSummaryCopyWith<LoadSummary> get copyWith => _$LoadSummaryCopyWithImpl<LoadSummary>(this as LoadSummary, _$identity);

  /// Serializes this LoadSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LoadSummary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoadSummary&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.goodsType, _this.goodsType) || other.goodsType == _this.goodsType)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.quantity, _this.quantity) || other.quantity == _this.quantity)&&(identical(other.quantityUnit, _this.quantityUnit) || other.quantityUnit == _this.quantityUnit)&&(identical(other.pickupArea, _this.pickupArea) || other.pickupArea == _this.pickupArea)&&(identical(other.dropArea, _this.dropArea) || other.dropArea == _this.dropArea)&&(identical(other.pickupWindowStart, _this.pickupWindowStart) || other.pickupWindowStart == _this.pickupWindowStart)&&(identical(other.agreedAmountInr, _this.agreedAmountInr) || other.agreedAmountInr == _this.agreedAmountInr)&&(identical(other.paymentStatus, _this.paymentStatus) || other.paymentStatus == _this.paymentStatus)&&(identical(other.postedForFarmerName, _this.postedForFarmerName) || other.postedForFarmerName == _this.postedForFarmerName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LoadSummary;
  return Object.hash(runtimeType,_this.id,_this.code,_this.status,_this.goodsType,_this.description,_this.quantity,_this.quantityUnit,_this.pickupArea,_this.dropArea,_this.pickupWindowStart,_this.agreedAmountInr,_this.paymentStatus,_this.postedForFarmerName);
}

@override
String toString() {
  final _this = this as LoadSummary;
  return 'LoadSummary(id: ${_this.id}, code: ${_this.code}, status: ${_this.status}, goodsType: ${_this.goodsType}, description: ${_this.description}, quantity: ${_this.quantity}, quantityUnit: ${_this.quantityUnit}, pickupArea: ${_this.pickupArea}, dropArea: ${_this.dropArea}, pickupWindowStart: ${_this.pickupWindowStart}, agreedAmountInr: ${_this.agreedAmountInr}, paymentStatus: ${_this.paymentStatus}, postedForFarmerName: ${_this.postedForFarmerName})';
}


}

/// @nodoc
abstract mixin class $LoadSummaryCopyWith<$Res>  {
  factory $LoadSummaryCopyWith(LoadSummary value, $Res Function(LoadSummary) _then) = _$LoadSummaryCopyWithImpl;
@useResult
$Res call({
 String id, String code,@JsonKey(unknownEnumValue: LoadStatus.unknown) LoadStatus status, String goodsType, String? description, num quantity,@JsonKey(unknownEnumValue: QuantityUnit.unknown) QuantityUnit quantityUnit, String pickupArea, String dropArea, DateTime pickupWindowStart, int agreedAmountInr,@JsonKey(unknownEnumValue: PaymentStatus.unknown) PaymentStatus? paymentStatus, String? postedForFarmerName
});




}
/// @nodoc
class _$LoadSummaryCopyWithImpl<$Res>
    implements $LoadSummaryCopyWith<$Res> {
  _$LoadSummaryCopyWithImpl(this._self, this._then);

  final LoadSummary _self;
  final $Res Function(LoadSummary) _then;

/// Create a copy of LoadSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? code = null,Object? status = null,Object? goodsType = null,Object? description = freezed,Object? quantity = null,Object? quantityUnit = null,Object? pickupArea = null,Object? dropArea = null,Object? pickupWindowStart = null,Object? agreedAmountInr = null,Object? paymentStatus = freezed,Object? postedForFarmerName = freezed,}) {
  return _then(LoadSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LoadStatus,goodsType: null == goodsType ? _self.goodsType : goodsType // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as num,quantityUnit: null == quantityUnit ? _self.quantityUnit : quantityUnit // ignore: cast_nullable_to_non_nullable
as QuantityUnit,pickupArea: null == pickupArea ? _self.pickupArea : pickupArea // ignore: cast_nullable_to_non_nullable
as String,dropArea: null == dropArea ? _self.dropArea : dropArea // ignore: cast_nullable_to_non_nullable
as String,pickupWindowStart: null == pickupWindowStart ? _self.pickupWindowStart : pickupWindowStart // ignore: cast_nullable_to_non_nullable
as DateTime,agreedAmountInr: null == agreedAmountInr ? _self.agreedAmountInr : agreedAmountInr // ignore: cast_nullable_to_non_nullable
as int,paymentStatus: freezed == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as PaymentStatus?,postedForFarmerName: freezed == postedForFarmerName ? _self.postedForFarmerName : postedForFarmerName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [LoadSummary].
extension LoadSummaryPatterns on LoadSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoadSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoadSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoadSummary value)  $default,){
final _that = this;
switch (_that) {
case _LoadSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoadSummary value)?  $default,){
final _that = this;
switch (_that) {
case _LoadSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String code, @JsonKey(unknownEnumValue: LoadStatus.unknown)  LoadStatus status,  String goodsType,  String? description,  num quantity, @JsonKey(unknownEnumValue: QuantityUnit.unknown)  QuantityUnit quantityUnit,  String pickupArea,  String dropArea,  DateTime pickupWindowStart,  int agreedAmountInr, @JsonKey(unknownEnumValue: PaymentStatus.unknown)  PaymentStatus? paymentStatus,  String? postedForFarmerName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoadSummary() when $default != null:
return $default(_that.id,_that.code,_that.status,_that.goodsType,_that.description,_that.quantity,_that.quantityUnit,_that.pickupArea,_that.dropArea,_that.pickupWindowStart,_that.agreedAmountInr,_that.paymentStatus,_that.postedForFarmerName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String code, @JsonKey(unknownEnumValue: LoadStatus.unknown)  LoadStatus status,  String goodsType,  String? description,  num quantity, @JsonKey(unknownEnumValue: QuantityUnit.unknown)  QuantityUnit quantityUnit,  String pickupArea,  String dropArea,  DateTime pickupWindowStart,  int agreedAmountInr, @JsonKey(unknownEnumValue: PaymentStatus.unknown)  PaymentStatus? paymentStatus,  String? postedForFarmerName)  $default,) {final _that = this;
switch (_that) {
case _LoadSummary():
return $default(_that.id,_that.code,_that.status,_that.goodsType,_that.description,_that.quantity,_that.quantityUnit,_that.pickupArea,_that.dropArea,_that.pickupWindowStart,_that.agreedAmountInr,_that.paymentStatus,_that.postedForFarmerName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String code, @JsonKey(unknownEnumValue: LoadStatus.unknown)  LoadStatus status,  String goodsType,  String? description,  num quantity, @JsonKey(unknownEnumValue: QuantityUnit.unknown)  QuantityUnit quantityUnit,  String pickupArea,  String dropArea,  DateTime pickupWindowStart,  int agreedAmountInr, @JsonKey(unknownEnumValue: PaymentStatus.unknown)  PaymentStatus? paymentStatus,  String? postedForFarmerName)?  $default,) {final _that = this;
switch (_that) {
case _LoadSummary() when $default != null:
return $default(_that.id,_that.code,_that.status,_that.goodsType,_that.description,_that.quantity,_that.quantityUnit,_that.pickupArea,_that.dropArea,_that.pickupWindowStart,_that.agreedAmountInr,_that.paymentStatus,_that.postedForFarmerName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LoadSummary implements LoadSummary {
  const _LoadSummary({required this.id, required this.code, @JsonKey(unknownEnumValue: LoadStatus.unknown) required this.status, required this.goodsType, this.description, required this.quantity, @JsonKey(unknownEnumValue: QuantityUnit.unknown) required this.quantityUnit, required this.pickupArea, required this.dropArea, required this.pickupWindowStart, required this.agreedAmountInr, @JsonKey(unknownEnumValue: PaymentStatus.unknown) this.paymentStatus, this.postedForFarmerName});
  factory _LoadSummary.fromJson(Map<String, dynamic> json) => _$LoadSummaryFromJson(json);

@override final  String id;
@override final  String code;
@override@JsonKey(unknownEnumValue: LoadStatus.unknown) final  LoadStatus status;
@override final  String goodsType;
@override final  String? description;
@override final  num quantity;
@override@JsonKey(unknownEnumValue: QuantityUnit.unknown) final  QuantityUnit quantityUnit;
@override final  String pickupArea;
@override final  String dropArea;
@override final  DateTime pickupWindowStart;
@override final  int agreedAmountInr;
@override@JsonKey(unknownEnumValue: PaymentStatus.unknown) final  PaymentStatus? paymentStatus;
@override final  String? postedForFarmerName;

/// Create a copy of LoadSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoadSummaryCopyWith<_LoadSummary> get copyWith => __$LoadSummaryCopyWithImpl<_LoadSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LoadSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoadSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.status, status) || other.status == status)&&(identical(other.goodsType, goodsType) || other.goodsType == goodsType)&&(identical(other.description, description) || other.description == description)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.quantityUnit, quantityUnit) || other.quantityUnit == quantityUnit)&&(identical(other.pickupArea, pickupArea) || other.pickupArea == pickupArea)&&(identical(other.dropArea, dropArea) || other.dropArea == dropArea)&&(identical(other.pickupWindowStart, pickupWindowStart) || other.pickupWindowStart == pickupWindowStart)&&(identical(other.agreedAmountInr, agreedAmountInr) || other.agreedAmountInr == agreedAmountInr)&&(identical(other.paymentStatus, paymentStatus) || other.paymentStatus == paymentStatus)&&(identical(other.postedForFarmerName, postedForFarmerName) || other.postedForFarmerName == postedForFarmerName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,code,status,goodsType,description,quantity,quantityUnit,pickupArea,dropArea,pickupWindowStart,agreedAmountInr,paymentStatus,postedForFarmerName);
}

@override
String toString() {
    return 'LoadSummary(id: $id, code: $code, status: $status, goodsType: $goodsType, description: $description, quantity: $quantity, quantityUnit: $quantityUnit, pickupArea: $pickupArea, dropArea: $dropArea, pickupWindowStart: $pickupWindowStart, agreedAmountInr: $agreedAmountInr, paymentStatus: $paymentStatus, postedForFarmerName: $postedForFarmerName)';
}


}

/// @nodoc
abstract mixin class _$LoadSummaryCopyWith<$Res> implements $LoadSummaryCopyWith<$Res> {
  factory _$LoadSummaryCopyWith(_LoadSummary value, $Res Function(_LoadSummary) _then) = __$LoadSummaryCopyWithImpl;
@override @useResult
$Res call({
 String id, String code,@JsonKey(unknownEnumValue: LoadStatus.unknown) LoadStatus status, String goodsType, String? description, num quantity,@JsonKey(unknownEnumValue: QuantityUnit.unknown) QuantityUnit quantityUnit, String pickupArea, String dropArea, DateTime pickupWindowStart, int agreedAmountInr,@JsonKey(unknownEnumValue: PaymentStatus.unknown) PaymentStatus? paymentStatus, String? postedForFarmerName
});




}
/// @nodoc
class __$LoadSummaryCopyWithImpl<$Res>
    implements _$LoadSummaryCopyWith<$Res> {
  __$LoadSummaryCopyWithImpl(this._self, this._then);

  final _LoadSummary _self;
  final $Res Function(_LoadSummary) _then;

/// Create a copy of LoadSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? code = null,Object? status = null,Object? goodsType = null,Object? description = freezed,Object? quantity = null,Object? quantityUnit = null,Object? pickupArea = null,Object? dropArea = null,Object? pickupWindowStart = null,Object? agreedAmountInr = null,Object? paymentStatus = freezed,Object? postedForFarmerName = freezed,}) {
  return _then(_LoadSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LoadStatus,goodsType: null == goodsType ? _self.goodsType : goodsType // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as num,quantityUnit: null == quantityUnit ? _self.quantityUnit : quantityUnit // ignore: cast_nullable_to_non_nullable
as QuantityUnit,pickupArea: null == pickupArea ? _self.pickupArea : pickupArea // ignore: cast_nullable_to_non_nullable
as String,dropArea: null == dropArea ? _self.dropArea : dropArea // ignore: cast_nullable_to_non_nullable
as String,pickupWindowStart: null == pickupWindowStart ? _self.pickupWindowStart : pickupWindowStart // ignore: cast_nullable_to_non_nullable
as DateTime,agreedAmountInr: null == agreedAmountInr ? _self.agreedAmountInr : agreedAmountInr // ignore: cast_nullable_to_non_nullable
as int,paymentStatus: freezed == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as PaymentStatus?,postedForFarmerName: freezed == postedForFarmerName ? _self.postedForFarmerName : postedForFarmerName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$TimelineEntry {

@JsonKey(unknownEnumValue: LoadStatus.unknown) LoadStatus get status; DateTime get at;
/// Create a copy of TimelineEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimelineEntryCopyWith<TimelineEntry> get copyWith => _$TimelineEntryCopyWithImpl<TimelineEntry>(this as TimelineEntry, _$identity);

  /// Serializes this TimelineEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TimelineEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimelineEntry&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.at, _this.at) || other.at == _this.at));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TimelineEntry;
  return Object.hash(runtimeType,_this.status,_this.at);
}

@override
String toString() {
  final _this = this as TimelineEntry;
  return 'TimelineEntry(status: ${_this.status}, at: ${_this.at})';
}


}

/// @nodoc
abstract mixin class $TimelineEntryCopyWith<$Res>  {
  factory $TimelineEntryCopyWith(TimelineEntry value, $Res Function(TimelineEntry) _then) = _$TimelineEntryCopyWithImpl;
@useResult
$Res call({
@JsonKey(unknownEnumValue: LoadStatus.unknown) LoadStatus status, DateTime at
});




}
/// @nodoc
class _$TimelineEntryCopyWithImpl<$Res>
    implements $TimelineEntryCopyWith<$Res> {
  _$TimelineEntryCopyWithImpl(this._self, this._then);

  final TimelineEntry _self;
  final $Res Function(TimelineEntry) _then;

/// Create a copy of TimelineEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? at = null,}) {
  return _then(TimelineEntry(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LoadStatus,at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [TimelineEntry].
extension TimelineEntryPatterns on TimelineEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TimelineEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TimelineEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TimelineEntry value)  $default,){
final _that = this;
switch (_that) {
case _TimelineEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TimelineEntry value)?  $default,){
final _that = this;
switch (_that) {
case _TimelineEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: LoadStatus.unknown)  LoadStatus status,  DateTime at)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TimelineEntry() when $default != null:
return $default(_that.status,_that.at);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: LoadStatus.unknown)  LoadStatus status,  DateTime at)  $default,) {final _that = this;
switch (_that) {
case _TimelineEntry():
return $default(_that.status,_that.at);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(unknownEnumValue: LoadStatus.unknown)  LoadStatus status,  DateTime at)?  $default,) {final _that = this;
switch (_that) {
case _TimelineEntry() when $default != null:
return $default(_that.status,_that.at);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TimelineEntry implements TimelineEntry {
  const _TimelineEntry({@JsonKey(unknownEnumValue: LoadStatus.unknown) required this.status, required this.at});
  factory _TimelineEntry.fromJson(Map<String, dynamic> json) => _$TimelineEntryFromJson(json);

@override@JsonKey(unknownEnumValue: LoadStatus.unknown) final  LoadStatus status;
@override final  DateTime at;

/// Create a copy of TimelineEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TimelineEntryCopyWith<_TimelineEntry> get copyWith => __$TimelineEntryCopyWithImpl<_TimelineEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TimelineEntryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TimelineEntry&&(identical(other.status, status) || other.status == status)&&(identical(other.at, at) || other.at == at));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,status,at);
}

@override
String toString() {
    return 'TimelineEntry(status: $status, at: $at)';
}


}

/// @nodoc
abstract mixin class _$TimelineEntryCopyWith<$Res> implements $TimelineEntryCopyWith<$Res> {
  factory _$TimelineEntryCopyWith(_TimelineEntry value, $Res Function(_TimelineEntry) _then) = __$TimelineEntryCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(unknownEnumValue: LoadStatus.unknown) LoadStatus status, DateTime at
});




}
/// @nodoc
class __$TimelineEntryCopyWithImpl<$Res>
    implements _$TimelineEntryCopyWith<$Res> {
  __$TimelineEntryCopyWithImpl(this._self, this._then);

  final _TimelineEntry _self;
  final $Res Function(_TimelineEntry) _then;

/// Create a copy of TimelineEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? at = null,}) {
  return _then(_TimelineEntry(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LoadStatus,at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$LoadDriver {

 String get id; String get name; String? get photoUrl; String get mobile; double get trustScore; String get truckNumber;@JsonKey(unknownEnumValue: VehicleType.unknown) VehicleType get vehicleType;
/// Create a copy of LoadDriver
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoadDriverCopyWith<LoadDriver> get copyWith => _$LoadDriverCopyWithImpl<LoadDriver>(this as LoadDriver, _$identity);

  /// Serializes this LoadDriver to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LoadDriver;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoadDriver&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.photoUrl, _this.photoUrl) || other.photoUrl == _this.photoUrl)&&(identical(other.mobile, _this.mobile) || other.mobile == _this.mobile)&&(identical(other.trustScore, _this.trustScore) || other.trustScore == _this.trustScore)&&(identical(other.truckNumber, _this.truckNumber) || other.truckNumber == _this.truckNumber)&&(identical(other.vehicleType, _this.vehicleType) || other.vehicleType == _this.vehicleType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LoadDriver;
  return Object.hash(runtimeType,_this.id,_this.name,_this.photoUrl,_this.mobile,_this.trustScore,_this.truckNumber,_this.vehicleType);
}

@override
String toString() {
  final _this = this as LoadDriver;
  return 'LoadDriver(id: ${_this.id}, name: ${_this.name}, photoUrl: ${_this.photoUrl}, mobile: ${_this.mobile}, trustScore: ${_this.trustScore}, truckNumber: ${_this.truckNumber}, vehicleType: ${_this.vehicleType})';
}


}

/// @nodoc
abstract mixin class $LoadDriverCopyWith<$Res>  {
  factory $LoadDriverCopyWith(LoadDriver value, $Res Function(LoadDriver) _then) = _$LoadDriverCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? photoUrl, String mobile, double trustScore, String truckNumber,@JsonKey(unknownEnumValue: VehicleType.unknown) VehicleType vehicleType
});




}
/// @nodoc
class _$LoadDriverCopyWithImpl<$Res>
    implements $LoadDriverCopyWith<$Res> {
  _$LoadDriverCopyWithImpl(this._self, this._then);

  final LoadDriver _self;
  final $Res Function(LoadDriver) _then;

/// Create a copy of LoadDriver
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? photoUrl = freezed,Object? mobile = null,Object? trustScore = null,Object? truckNumber = null,Object? vehicleType = null,}) {
  return _then(LoadDriver(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,mobile: null == mobile ? _self.mobile : mobile // ignore: cast_nullable_to_non_nullable
as String,trustScore: null == trustScore ? _self.trustScore : trustScore // ignore: cast_nullable_to_non_nullable
as double,truckNumber: null == truckNumber ? _self.truckNumber : truckNumber // ignore: cast_nullable_to_non_nullable
as String,vehicleType: null == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as VehicleType,
  ));
}

}


/// Adds pattern-matching-related methods to [LoadDriver].
extension LoadDriverPatterns on LoadDriver {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoadDriver value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoadDriver() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoadDriver value)  $default,){
final _that = this;
switch (_that) {
case _LoadDriver():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoadDriver value)?  $default,){
final _that = this;
switch (_that) {
case _LoadDriver() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? photoUrl,  String mobile,  double trustScore,  String truckNumber, @JsonKey(unknownEnumValue: VehicleType.unknown)  VehicleType vehicleType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoadDriver() when $default != null:
return $default(_that.id,_that.name,_that.photoUrl,_that.mobile,_that.trustScore,_that.truckNumber,_that.vehicleType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? photoUrl,  String mobile,  double trustScore,  String truckNumber, @JsonKey(unknownEnumValue: VehicleType.unknown)  VehicleType vehicleType)  $default,) {final _that = this;
switch (_that) {
case _LoadDriver():
return $default(_that.id,_that.name,_that.photoUrl,_that.mobile,_that.trustScore,_that.truckNumber,_that.vehicleType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? photoUrl,  String mobile,  double trustScore,  String truckNumber, @JsonKey(unknownEnumValue: VehicleType.unknown)  VehicleType vehicleType)?  $default,) {final _that = this;
switch (_that) {
case _LoadDriver() when $default != null:
return $default(_that.id,_that.name,_that.photoUrl,_that.mobile,_that.trustScore,_that.truckNumber,_that.vehicleType);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LoadDriver implements LoadDriver {
  const _LoadDriver({required this.id, required this.name, this.photoUrl, required this.mobile, required this.trustScore, required this.truckNumber, @JsonKey(unknownEnumValue: VehicleType.unknown) required this.vehicleType});
  factory _LoadDriver.fromJson(Map<String, dynamic> json) => _$LoadDriverFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? photoUrl;
@override final  String mobile;
@override final  double trustScore;
@override final  String truckNumber;
@override@JsonKey(unknownEnumValue: VehicleType.unknown) final  VehicleType vehicleType;

/// Create a copy of LoadDriver
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoadDriverCopyWith<_LoadDriver> get copyWith => __$LoadDriverCopyWithImpl<_LoadDriver>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LoadDriverToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoadDriver&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.mobile, mobile) || other.mobile == mobile)&&(identical(other.trustScore, trustScore) || other.trustScore == trustScore)&&(identical(other.truckNumber, truckNumber) || other.truckNumber == truckNumber)&&(identical(other.vehicleType, vehicleType) || other.vehicleType == vehicleType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,photoUrl,mobile,trustScore,truckNumber,vehicleType);
}

@override
String toString() {
    return 'LoadDriver(id: $id, name: $name, photoUrl: $photoUrl, mobile: $mobile, trustScore: $trustScore, truckNumber: $truckNumber, vehicleType: $vehicleType)';
}


}

/// @nodoc
abstract mixin class _$LoadDriverCopyWith<$Res> implements $LoadDriverCopyWith<$Res> {
  factory _$LoadDriverCopyWith(_LoadDriver value, $Res Function(_LoadDriver) _then) = __$LoadDriverCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? photoUrl, String mobile, double trustScore, String truckNumber,@JsonKey(unknownEnumValue: VehicleType.unknown) VehicleType vehicleType
});




}
/// @nodoc
class __$LoadDriverCopyWithImpl<$Res>
    implements _$LoadDriverCopyWith<$Res> {
  __$LoadDriverCopyWithImpl(this._self, this._then);

  final _LoadDriver _self;
  final $Res Function(_LoadDriver) _then;

/// Create a copy of LoadDriver
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? photoUrl = freezed,Object? mobile = null,Object? trustScore = null,Object? truckNumber = null,Object? vehicleType = null,}) {
  return _then(_LoadDriver(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,mobile: null == mobile ? _self.mobile : mobile // ignore: cast_nullable_to_non_nullable
as String,trustScore: null == trustScore ? _self.trustScore : trustScore // ignore: cast_nullable_to_non_nullable
as double,truckNumber: null == truckNumber ? _self.truckNumber : truckNumber // ignore: cast_nullable_to_non_nullable
as String,vehicleType: null == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as VehicleType,
  ));
}


}


/// @nodoc
mixin _$AmountRevision {

 String get id; int get requestedAmountInr; String get reason;@JsonKey(unknownEnumValue: RevisionStatus.unknown) RevisionStatus get status; DateTime get createdAt; DateTime get respondBy;
/// Create a copy of AmountRevision
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AmountRevisionCopyWith<AmountRevision> get copyWith => _$AmountRevisionCopyWithImpl<AmountRevision>(this as AmountRevision, _$identity);

  /// Serializes this AmountRevision to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AmountRevision;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AmountRevision&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.requestedAmountInr, _this.requestedAmountInr) || other.requestedAmountInr == _this.requestedAmountInr)&&(identical(other.reason, _this.reason) || other.reason == _this.reason)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.respondBy, _this.respondBy) || other.respondBy == _this.respondBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AmountRevision;
  return Object.hash(runtimeType,_this.id,_this.requestedAmountInr,_this.reason,_this.status,_this.createdAt,_this.respondBy);
}

@override
String toString() {
  final _this = this as AmountRevision;
  return 'AmountRevision(id: ${_this.id}, requestedAmountInr: ${_this.requestedAmountInr}, reason: ${_this.reason}, status: ${_this.status}, createdAt: ${_this.createdAt}, respondBy: ${_this.respondBy})';
}


}

/// @nodoc
abstract mixin class $AmountRevisionCopyWith<$Res>  {
  factory $AmountRevisionCopyWith(AmountRevision value, $Res Function(AmountRevision) _then) = _$AmountRevisionCopyWithImpl;
@useResult
$Res call({
 String id, int requestedAmountInr, String reason,@JsonKey(unknownEnumValue: RevisionStatus.unknown) RevisionStatus status, DateTime createdAt, DateTime respondBy
});




}
/// @nodoc
class _$AmountRevisionCopyWithImpl<$Res>
    implements $AmountRevisionCopyWith<$Res> {
  _$AmountRevisionCopyWithImpl(this._self, this._then);

  final AmountRevision _self;
  final $Res Function(AmountRevision) _then;

/// Create a copy of AmountRevision
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? requestedAmountInr = null,Object? reason = null,Object? status = null,Object? createdAt = null,Object? respondBy = null,}) {
  return _then(AmountRevision(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,requestedAmountInr: null == requestedAmountInr ? _self.requestedAmountInr : requestedAmountInr // ignore: cast_nullable_to_non_nullable
as int,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RevisionStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,respondBy: null == respondBy ? _self.respondBy : respondBy // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [AmountRevision].
extension AmountRevisionPatterns on AmountRevision {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AmountRevision value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AmountRevision() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AmountRevision value)  $default,){
final _that = this;
switch (_that) {
case _AmountRevision():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AmountRevision value)?  $default,){
final _that = this;
switch (_that) {
case _AmountRevision() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int requestedAmountInr,  String reason, @JsonKey(unknownEnumValue: RevisionStatus.unknown)  RevisionStatus status,  DateTime createdAt,  DateTime respondBy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AmountRevision() when $default != null:
return $default(_that.id,_that.requestedAmountInr,_that.reason,_that.status,_that.createdAt,_that.respondBy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int requestedAmountInr,  String reason, @JsonKey(unknownEnumValue: RevisionStatus.unknown)  RevisionStatus status,  DateTime createdAt,  DateTime respondBy)  $default,) {final _that = this;
switch (_that) {
case _AmountRevision():
return $default(_that.id,_that.requestedAmountInr,_that.reason,_that.status,_that.createdAt,_that.respondBy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int requestedAmountInr,  String reason, @JsonKey(unknownEnumValue: RevisionStatus.unknown)  RevisionStatus status,  DateTime createdAt,  DateTime respondBy)?  $default,) {final _that = this;
switch (_that) {
case _AmountRevision() when $default != null:
return $default(_that.id,_that.requestedAmountInr,_that.reason,_that.status,_that.createdAt,_that.respondBy);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AmountRevision implements AmountRevision {
  const _AmountRevision({required this.id, required this.requestedAmountInr, required this.reason, @JsonKey(unknownEnumValue: RevisionStatus.unknown) required this.status, required this.createdAt, required this.respondBy});
  factory _AmountRevision.fromJson(Map<String, dynamic> json) => _$AmountRevisionFromJson(json);

@override final  String id;
@override final  int requestedAmountInr;
@override final  String reason;
@override@JsonKey(unknownEnumValue: RevisionStatus.unknown) final  RevisionStatus status;
@override final  DateTime createdAt;
@override final  DateTime respondBy;

/// Create a copy of AmountRevision
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AmountRevisionCopyWith<_AmountRevision> get copyWith => __$AmountRevisionCopyWithImpl<_AmountRevision>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AmountRevisionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AmountRevision&&(identical(other.id, id) || other.id == id)&&(identical(other.requestedAmountInr, requestedAmountInr) || other.requestedAmountInr == requestedAmountInr)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.respondBy, respondBy) || other.respondBy == respondBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,requestedAmountInr,reason,status,createdAt,respondBy);
}

@override
String toString() {
    return 'AmountRevision(id: $id, requestedAmountInr: $requestedAmountInr, reason: $reason, status: $status, createdAt: $createdAt, respondBy: $respondBy)';
}


}

/// @nodoc
abstract mixin class _$AmountRevisionCopyWith<$Res> implements $AmountRevisionCopyWith<$Res> {
  factory _$AmountRevisionCopyWith(_AmountRevision value, $Res Function(_AmountRevision) _then) = __$AmountRevisionCopyWithImpl;
@override @useResult
$Res call({
 String id, int requestedAmountInr, String reason,@JsonKey(unknownEnumValue: RevisionStatus.unknown) RevisionStatus status, DateTime createdAt, DateTime respondBy
});




}
/// @nodoc
class __$AmountRevisionCopyWithImpl<$Res>
    implements _$AmountRevisionCopyWith<$Res> {
  __$AmountRevisionCopyWithImpl(this._self, this._then);

  final _AmountRevision _self;
  final $Res Function(_AmountRevision) _then;

/// Create a copy of AmountRevision
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? requestedAmountInr = null,Object? reason = null,Object? status = null,Object? createdAt = null,Object? respondBy = null,}) {
  return _then(_AmountRevision(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,requestedAmountInr: null == requestedAmountInr ? _self.requestedAmountInr : requestedAmountInr // ignore: cast_nullable_to_non_nullable
as int,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RevisionStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,respondBy: null == respondBy ? _self.respondBy : respondBy // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$LoadPayment {

@JsonKey(unknownEnumValue: PaymentStatus.unknown) PaymentStatus get status; int? get amountInr;@JsonKey(unknownEnumValue: PaymentMode.unknown) PaymentMode? get mode; String? get reference; DateTime? get paidAt; DateTime? get confirmedAt; String? get disputeReason;
/// Create a copy of LoadPayment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoadPaymentCopyWith<LoadPayment> get copyWith => _$LoadPaymentCopyWithImpl<LoadPayment>(this as LoadPayment, _$identity);

  /// Serializes this LoadPayment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LoadPayment;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoadPayment&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.amountInr, _this.amountInr) || other.amountInr == _this.amountInr)&&(identical(other.mode, _this.mode) || other.mode == _this.mode)&&(identical(other.reference, _this.reference) || other.reference == _this.reference)&&(identical(other.paidAt, _this.paidAt) || other.paidAt == _this.paidAt)&&(identical(other.confirmedAt, _this.confirmedAt) || other.confirmedAt == _this.confirmedAt)&&(identical(other.disputeReason, _this.disputeReason) || other.disputeReason == _this.disputeReason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LoadPayment;
  return Object.hash(runtimeType,_this.status,_this.amountInr,_this.mode,_this.reference,_this.paidAt,_this.confirmedAt,_this.disputeReason);
}

@override
String toString() {
  final _this = this as LoadPayment;
  return 'LoadPayment(status: ${_this.status}, amountInr: ${_this.amountInr}, mode: ${_this.mode}, reference: ${_this.reference}, paidAt: ${_this.paidAt}, confirmedAt: ${_this.confirmedAt}, disputeReason: ${_this.disputeReason})';
}


}

/// @nodoc
abstract mixin class $LoadPaymentCopyWith<$Res>  {
  factory $LoadPaymentCopyWith(LoadPayment value, $Res Function(LoadPayment) _then) = _$LoadPaymentCopyWithImpl;
@useResult
$Res call({
@JsonKey(unknownEnumValue: PaymentStatus.unknown) PaymentStatus status, int? amountInr,@JsonKey(unknownEnumValue: PaymentMode.unknown) PaymentMode? mode, String? reference, DateTime? paidAt, DateTime? confirmedAt, String? disputeReason
});




}
/// @nodoc
class _$LoadPaymentCopyWithImpl<$Res>
    implements $LoadPaymentCopyWith<$Res> {
  _$LoadPaymentCopyWithImpl(this._self, this._then);

  final LoadPayment _self;
  final $Res Function(LoadPayment) _then;

/// Create a copy of LoadPayment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? amountInr = freezed,Object? mode = freezed,Object? reference = freezed,Object? paidAt = freezed,Object? confirmedAt = freezed,Object? disputeReason = freezed,}) {
  return _then(LoadPayment(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PaymentStatus,amountInr: freezed == amountInr ? _self.amountInr : amountInr // ignore: cast_nullable_to_non_nullable
as int?,mode: freezed == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as PaymentMode?,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,paidAt: freezed == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime?,confirmedAt: freezed == confirmedAt ? _self.confirmedAt : confirmedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,disputeReason: freezed == disputeReason ? _self.disputeReason : disputeReason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [LoadPayment].
extension LoadPaymentPatterns on LoadPayment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoadPayment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoadPayment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoadPayment value)  $default,){
final _that = this;
switch (_that) {
case _LoadPayment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoadPayment value)?  $default,){
final _that = this;
switch (_that) {
case _LoadPayment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: PaymentStatus.unknown)  PaymentStatus status,  int? amountInr, @JsonKey(unknownEnumValue: PaymentMode.unknown)  PaymentMode? mode,  String? reference,  DateTime? paidAt,  DateTime? confirmedAt,  String? disputeReason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoadPayment() when $default != null:
return $default(_that.status,_that.amountInr,_that.mode,_that.reference,_that.paidAt,_that.confirmedAt,_that.disputeReason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: PaymentStatus.unknown)  PaymentStatus status,  int? amountInr, @JsonKey(unknownEnumValue: PaymentMode.unknown)  PaymentMode? mode,  String? reference,  DateTime? paidAt,  DateTime? confirmedAt,  String? disputeReason)  $default,) {final _that = this;
switch (_that) {
case _LoadPayment():
return $default(_that.status,_that.amountInr,_that.mode,_that.reference,_that.paidAt,_that.confirmedAt,_that.disputeReason);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(unknownEnumValue: PaymentStatus.unknown)  PaymentStatus status,  int? amountInr, @JsonKey(unknownEnumValue: PaymentMode.unknown)  PaymentMode? mode,  String? reference,  DateTime? paidAt,  DateTime? confirmedAt,  String? disputeReason)?  $default,) {final _that = this;
switch (_that) {
case _LoadPayment() when $default != null:
return $default(_that.status,_that.amountInr,_that.mode,_that.reference,_that.paidAt,_that.confirmedAt,_that.disputeReason);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LoadPayment implements LoadPayment {
  const _LoadPayment({@JsonKey(unknownEnumValue: PaymentStatus.unknown) required this.status, this.amountInr, @JsonKey(unknownEnumValue: PaymentMode.unknown) this.mode, this.reference, this.paidAt, this.confirmedAt, this.disputeReason});
  factory _LoadPayment.fromJson(Map<String, dynamic> json) => _$LoadPaymentFromJson(json);

@override@JsonKey(unknownEnumValue: PaymentStatus.unknown) final  PaymentStatus status;
@override final  int? amountInr;
@override@JsonKey(unknownEnumValue: PaymentMode.unknown) final  PaymentMode? mode;
@override final  String? reference;
@override final  DateTime? paidAt;
@override final  DateTime? confirmedAt;
@override final  String? disputeReason;

/// Create a copy of LoadPayment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoadPaymentCopyWith<_LoadPayment> get copyWith => __$LoadPaymentCopyWithImpl<_LoadPayment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LoadPaymentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoadPayment&&(identical(other.status, status) || other.status == status)&&(identical(other.amountInr, amountInr) || other.amountInr == amountInr)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt)&&(identical(other.confirmedAt, confirmedAt) || other.confirmedAt == confirmedAt)&&(identical(other.disputeReason, disputeReason) || other.disputeReason == disputeReason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,status,amountInr,mode,reference,paidAt,confirmedAt,disputeReason);
}

@override
String toString() {
    return 'LoadPayment(status: $status, amountInr: $amountInr, mode: $mode, reference: $reference, paidAt: $paidAt, confirmedAt: $confirmedAt, disputeReason: $disputeReason)';
}


}

/// @nodoc
abstract mixin class _$LoadPaymentCopyWith<$Res> implements $LoadPaymentCopyWith<$Res> {
  factory _$LoadPaymentCopyWith(_LoadPayment value, $Res Function(_LoadPayment) _then) = __$LoadPaymentCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(unknownEnumValue: PaymentStatus.unknown) PaymentStatus status, int? amountInr,@JsonKey(unknownEnumValue: PaymentMode.unknown) PaymentMode? mode, String? reference, DateTime? paidAt, DateTime? confirmedAt, String? disputeReason
});




}
/// @nodoc
class __$LoadPaymentCopyWithImpl<$Res>
    implements _$LoadPaymentCopyWith<$Res> {
  __$LoadPaymentCopyWithImpl(this._self, this._then);

  final _LoadPayment _self;
  final $Res Function(_LoadPayment) _then;

/// Create a copy of LoadPayment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? amountInr = freezed,Object? mode = freezed,Object? reference = freezed,Object? paidAt = freezed,Object? confirmedAt = freezed,Object? disputeReason = freezed,}) {
  return _then(_LoadPayment(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PaymentStatus,amountInr: freezed == amountInr ? _self.amountInr : amountInr // ignore: cast_nullable_to_non_nullable
as int?,mode: freezed == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as PaymentMode?,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,paidAt: freezed == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime?,confirmedAt: freezed == confirmedAt ? _self.confirmedAt : confirmedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,disputeReason: freezed == disputeReason ? _self.disputeReason : disputeReason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$LoadDetail {

 String get id; String get code;@JsonKey(unknownEnumValue: LoadStatus.unknown) LoadStatus get status; String get goodsType; String? get description; num get quantity;@JsonKey(unknownEnumValue: QuantityUnit.unknown) QuantityUnit get quantityUnit; String get pickupArea; String get dropArea; DateTime get pickupWindowStart; int get agreedAmountInr;@JsonKey(unknownEnumValue: PaymentStatus.unknown) PaymentStatus? get paymentStatus; String? get postedForFarmerName; Place get pickup; Place get drop; String get senderName; String get senderMobile; String get receiverName; String get receiverMobile; num get weightTonnes;@JsonKey(unknownEnumValue: VehicleType.unknown) VehicleType get vehicleType;@JsonKey(unknownEnumValue: FreightPayer.unknown) FreightPayer get freightPaidBy; int get postedAmountInr; DateTime? get deliveryEta; List<TimelineEntry> get timeline; LoadDriver? get driver; List<AmountRevision> get revisions; int get revisionsUsed; LoadPayment? get payment; List<Map<String, dynamic>> get otpEvents; List<Map<String, dynamic>> get locationExceptions; bool get canEdit; bool get canCancel; Map<String, dynamic>? get cancelInfo;@JsonKey(unknownEnumValue: LoadAudience.unknown) LoadAudience get audience; DateTime? get wishlistUntil; DateTime? get openedToEveryoneAt;
/// Create a copy of LoadDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoadDetailCopyWith<LoadDetail> get copyWith => _$LoadDetailCopyWithImpl<LoadDetail>(this as LoadDetail, _$identity);

  /// Serializes this LoadDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LoadDetail;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoadDetail&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.goodsType, _this.goodsType) || other.goodsType == _this.goodsType)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.quantity, _this.quantity) || other.quantity == _this.quantity)&&(identical(other.quantityUnit, _this.quantityUnit) || other.quantityUnit == _this.quantityUnit)&&(identical(other.pickupArea, _this.pickupArea) || other.pickupArea == _this.pickupArea)&&(identical(other.dropArea, _this.dropArea) || other.dropArea == _this.dropArea)&&(identical(other.pickupWindowStart, _this.pickupWindowStart) || other.pickupWindowStart == _this.pickupWindowStart)&&(identical(other.agreedAmountInr, _this.agreedAmountInr) || other.agreedAmountInr == _this.agreedAmountInr)&&(identical(other.paymentStatus, _this.paymentStatus) || other.paymentStatus == _this.paymentStatus)&&(identical(other.postedForFarmerName, _this.postedForFarmerName) || other.postedForFarmerName == _this.postedForFarmerName)&&(identical(other.pickup, _this.pickup) || other.pickup == _this.pickup)&&(identical(other.drop, _this.drop) || other.drop == _this.drop)&&(identical(other.senderName, _this.senderName) || other.senderName == _this.senderName)&&(identical(other.senderMobile, _this.senderMobile) || other.senderMobile == _this.senderMobile)&&(identical(other.receiverName, _this.receiverName) || other.receiverName == _this.receiverName)&&(identical(other.receiverMobile, _this.receiverMobile) || other.receiverMobile == _this.receiverMobile)&&(identical(other.weightTonnes, _this.weightTonnes) || other.weightTonnes == _this.weightTonnes)&&(identical(other.vehicleType, _this.vehicleType) || other.vehicleType == _this.vehicleType)&&(identical(other.freightPaidBy, _this.freightPaidBy) || other.freightPaidBy == _this.freightPaidBy)&&(identical(other.postedAmountInr, _this.postedAmountInr) || other.postedAmountInr == _this.postedAmountInr)&&(identical(other.deliveryEta, _this.deliveryEta) || other.deliveryEta == _this.deliveryEta)&&const DeepCollectionEquality().equals(other.timeline, _this.timeline)&&(identical(other.driver, _this.driver) || other.driver == _this.driver)&&const DeepCollectionEquality().equals(other.revisions, _this.revisions)&&(identical(other.revisionsUsed, _this.revisionsUsed) || other.revisionsUsed == _this.revisionsUsed)&&(identical(other.payment, _this.payment) || other.payment == _this.payment)&&const DeepCollectionEquality().equals(other.otpEvents, _this.otpEvents)&&const DeepCollectionEquality().equals(other.locationExceptions, _this.locationExceptions)&&(identical(other.canEdit, _this.canEdit) || other.canEdit == _this.canEdit)&&(identical(other.canCancel, _this.canCancel) || other.canCancel == _this.canCancel)&&const DeepCollectionEquality().equals(other.cancelInfo, _this.cancelInfo)&&(identical(other.audience, _this.audience) || other.audience == _this.audience)&&(identical(other.wishlistUntil, _this.wishlistUntil) || other.wishlistUntil == _this.wishlistUntil)&&(identical(other.openedToEveryoneAt, _this.openedToEveryoneAt) || other.openedToEveryoneAt == _this.openedToEveryoneAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LoadDetail;
  return Object.hashAll([runtimeType,_this.id,_this.code,_this.status,_this.goodsType,_this.description,_this.quantity,_this.quantityUnit,_this.pickupArea,_this.dropArea,_this.pickupWindowStart,_this.agreedAmountInr,_this.paymentStatus,_this.postedForFarmerName,_this.pickup,_this.drop,_this.senderName,_this.senderMobile,_this.receiverName,_this.receiverMobile,_this.weightTonnes,_this.vehicleType,_this.freightPaidBy,_this.postedAmountInr,_this.deliveryEta,const DeepCollectionEquality().hash(_this.timeline),_this.driver,const DeepCollectionEquality().hash(_this.revisions),_this.revisionsUsed,_this.payment,const DeepCollectionEquality().hash(_this.otpEvents),const DeepCollectionEquality().hash(_this.locationExceptions),_this.canEdit,_this.canCancel,const DeepCollectionEquality().hash(_this.cancelInfo),_this.audience,_this.wishlistUntil,_this.openedToEveryoneAt]);
}

@override
String toString() {
  final _this = this as LoadDetail;
  return 'LoadDetail(id: ${_this.id}, code: ${_this.code}, status: ${_this.status}, goodsType: ${_this.goodsType}, description: ${_this.description}, quantity: ${_this.quantity}, quantityUnit: ${_this.quantityUnit}, pickupArea: ${_this.pickupArea}, dropArea: ${_this.dropArea}, pickupWindowStart: ${_this.pickupWindowStart}, agreedAmountInr: ${_this.agreedAmountInr}, paymentStatus: ${_this.paymentStatus}, postedForFarmerName: ${_this.postedForFarmerName}, pickup: ${_this.pickup}, drop: ${_this.drop}, senderName: ${_this.senderName}, senderMobile: ${_this.senderMobile}, receiverName: ${_this.receiverName}, receiverMobile: ${_this.receiverMobile}, weightTonnes: ${_this.weightTonnes}, vehicleType: ${_this.vehicleType}, freightPaidBy: ${_this.freightPaidBy}, postedAmountInr: ${_this.postedAmountInr}, deliveryEta: ${_this.deliveryEta}, timeline: ${_this.timeline}, driver: ${_this.driver}, revisions: ${_this.revisions}, revisionsUsed: ${_this.revisionsUsed}, payment: ${_this.payment}, otpEvents: ${_this.otpEvents}, locationExceptions: ${_this.locationExceptions}, canEdit: ${_this.canEdit}, canCancel: ${_this.canCancel}, cancelInfo: ${_this.cancelInfo}, audience: ${_this.audience}, wishlistUntil: ${_this.wishlistUntil}, openedToEveryoneAt: ${_this.openedToEveryoneAt})';
}


}

/// @nodoc
abstract mixin class $LoadDetailCopyWith<$Res>  {
  factory $LoadDetailCopyWith(LoadDetail value, $Res Function(LoadDetail) _then) = _$LoadDetailCopyWithImpl;
@useResult
$Res call({
 String id, String code,@JsonKey(unknownEnumValue: LoadStatus.unknown) LoadStatus status, String goodsType, String? description, num quantity,@JsonKey(unknownEnumValue: QuantityUnit.unknown) QuantityUnit quantityUnit, String pickupArea, String dropArea, DateTime pickupWindowStart, int agreedAmountInr,@JsonKey(unknownEnumValue: PaymentStatus.unknown) PaymentStatus? paymentStatus, String? postedForFarmerName, Place pickup, Place drop, String senderName, String senderMobile, String receiverName, String receiverMobile, num weightTonnes,@JsonKey(unknownEnumValue: VehicleType.unknown) VehicleType vehicleType,@JsonKey(unknownEnumValue: FreightPayer.unknown) FreightPayer freightPaidBy, int postedAmountInr, DateTime? deliveryEta, List<TimelineEntry> timeline, LoadDriver? driver, List<AmountRevision> revisions, int revisionsUsed, LoadPayment? payment, List<Map<String, dynamic>> otpEvents, List<Map<String, dynamic>> locationExceptions, bool canEdit, bool canCancel, Map<String, dynamic>? cancelInfo,@JsonKey(unknownEnumValue: LoadAudience.unknown) LoadAudience audience, DateTime? wishlistUntil, DateTime? openedToEveryoneAt
});


$PlaceCopyWith<$Res> get pickup;$PlaceCopyWith<$Res> get drop;$LoadDriverCopyWith<$Res>? get driver;$LoadPaymentCopyWith<$Res>? get payment;

}
/// @nodoc
class _$LoadDetailCopyWithImpl<$Res>
    implements $LoadDetailCopyWith<$Res> {
  _$LoadDetailCopyWithImpl(this._self, this._then);

  final LoadDetail _self;
  final $Res Function(LoadDetail) _then;

/// Create a copy of LoadDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? code = null,Object? status = null,Object? goodsType = null,Object? description = freezed,Object? quantity = null,Object? quantityUnit = null,Object? pickupArea = null,Object? dropArea = null,Object? pickupWindowStart = null,Object? agreedAmountInr = null,Object? paymentStatus = freezed,Object? postedForFarmerName = freezed,Object? pickup = null,Object? drop = null,Object? senderName = null,Object? senderMobile = null,Object? receiverName = null,Object? receiverMobile = null,Object? weightTonnes = null,Object? vehicleType = null,Object? freightPaidBy = null,Object? postedAmountInr = null,Object? deliveryEta = freezed,Object? timeline = null,Object? driver = freezed,Object? revisions = null,Object? revisionsUsed = null,Object? payment = freezed,Object? otpEvents = null,Object? locationExceptions = null,Object? canEdit = null,Object? canCancel = null,Object? cancelInfo = freezed,Object? audience = null,Object? wishlistUntil = freezed,Object? openedToEveryoneAt = freezed,}) {
  return _then(LoadDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LoadStatus,goodsType: null == goodsType ? _self.goodsType : goodsType // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as num,quantityUnit: null == quantityUnit ? _self.quantityUnit : quantityUnit // ignore: cast_nullable_to_non_nullable
as QuantityUnit,pickupArea: null == pickupArea ? _self.pickupArea : pickupArea // ignore: cast_nullable_to_non_nullable
as String,dropArea: null == dropArea ? _self.dropArea : dropArea // ignore: cast_nullable_to_non_nullable
as String,pickupWindowStart: null == pickupWindowStart ? _self.pickupWindowStart : pickupWindowStart // ignore: cast_nullable_to_non_nullable
as DateTime,agreedAmountInr: null == agreedAmountInr ? _self.agreedAmountInr : agreedAmountInr // ignore: cast_nullable_to_non_nullable
as int,paymentStatus: freezed == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as PaymentStatus?,postedForFarmerName: freezed == postedForFarmerName ? _self.postedForFarmerName : postedForFarmerName // ignore: cast_nullable_to_non_nullable
as String?,pickup: null == pickup ? _self.pickup : pickup // ignore: cast_nullable_to_non_nullable
as Place,drop: null == drop ? _self.drop : drop // ignore: cast_nullable_to_non_nullable
as Place,senderName: null == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String,senderMobile: null == senderMobile ? _self.senderMobile : senderMobile // ignore: cast_nullable_to_non_nullable
as String,receiverName: null == receiverName ? _self.receiverName : receiverName // ignore: cast_nullable_to_non_nullable
as String,receiverMobile: null == receiverMobile ? _self.receiverMobile : receiverMobile // ignore: cast_nullable_to_non_nullable
as String,weightTonnes: null == weightTonnes ? _self.weightTonnes : weightTonnes // ignore: cast_nullable_to_non_nullable
as num,vehicleType: null == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as VehicleType,freightPaidBy: null == freightPaidBy ? _self.freightPaidBy : freightPaidBy // ignore: cast_nullable_to_non_nullable
as FreightPayer,postedAmountInr: null == postedAmountInr ? _self.postedAmountInr : postedAmountInr // ignore: cast_nullable_to_non_nullable
as int,deliveryEta: freezed == deliveryEta ? _self.deliveryEta : deliveryEta // ignore: cast_nullable_to_non_nullable
as DateTime?,timeline: null == timeline ? _self.timeline : timeline // ignore: cast_nullable_to_non_nullable
as List<TimelineEntry>,driver: freezed == driver ? _self.driver : driver // ignore: cast_nullable_to_non_nullable
as LoadDriver?,revisions: null == revisions ? _self.revisions : revisions // ignore: cast_nullable_to_non_nullable
as List<AmountRevision>,revisionsUsed: null == revisionsUsed ? _self.revisionsUsed : revisionsUsed // ignore: cast_nullable_to_non_nullable
as int,payment: freezed == payment ? _self.payment : payment // ignore: cast_nullable_to_non_nullable
as LoadPayment?,otpEvents: null == otpEvents ? _self.otpEvents : otpEvents // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,locationExceptions: null == locationExceptions ? _self.locationExceptions : locationExceptions // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,canEdit: null == canEdit ? _self.canEdit : canEdit // ignore: cast_nullable_to_non_nullable
as bool,canCancel: null == canCancel ? _self.canCancel : canCancel // ignore: cast_nullable_to_non_nullable
as bool,cancelInfo: freezed == cancelInfo ? _self.cancelInfo : cancelInfo // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,audience: null == audience ? _self.audience : audience // ignore: cast_nullable_to_non_nullable
as LoadAudience,wishlistUntil: freezed == wishlistUntil ? _self.wishlistUntil : wishlistUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,openedToEveryoneAt: freezed == openedToEveryoneAt ? _self.openedToEveryoneAt : openedToEveryoneAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of LoadDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlaceCopyWith<$Res> get pickup {
  
  return $PlaceCopyWith<$Res>(_self.pickup, (value) {
    return _then(_self.copyWith(pickup: value));
  });
}/// Create a copy of LoadDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlaceCopyWith<$Res> get drop {
  
  return $PlaceCopyWith<$Res>(_self.drop, (value) {
    return _then(_self.copyWith(drop: value));
  });
}/// Create a copy of LoadDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LoadDriverCopyWith<$Res>? get driver {
    if (_self.driver == null) {
    return null;
  }

  return $LoadDriverCopyWith<$Res>(_self.driver!, (value) {
    return _then(_self.copyWith(driver: value));
  });
}/// Create a copy of LoadDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LoadPaymentCopyWith<$Res>? get payment {
    if (_self.payment == null) {
    return null;
  }

  return $LoadPaymentCopyWith<$Res>(_self.payment!, (value) {
    return _then(_self.copyWith(payment: value));
  });
}
}


/// Adds pattern-matching-related methods to [LoadDetail].
extension LoadDetailPatterns on LoadDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoadDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoadDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoadDetail value)  $default,){
final _that = this;
switch (_that) {
case _LoadDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoadDetail value)?  $default,){
final _that = this;
switch (_that) {
case _LoadDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String code, @JsonKey(unknownEnumValue: LoadStatus.unknown)  LoadStatus status,  String goodsType,  String? description,  num quantity, @JsonKey(unknownEnumValue: QuantityUnit.unknown)  QuantityUnit quantityUnit,  String pickupArea,  String dropArea,  DateTime pickupWindowStart,  int agreedAmountInr, @JsonKey(unknownEnumValue: PaymentStatus.unknown)  PaymentStatus? paymentStatus,  String? postedForFarmerName,  Place pickup,  Place drop,  String senderName,  String senderMobile,  String receiverName,  String receiverMobile,  num weightTonnes, @JsonKey(unknownEnumValue: VehicleType.unknown)  VehicleType vehicleType, @JsonKey(unknownEnumValue: FreightPayer.unknown)  FreightPayer freightPaidBy,  int postedAmountInr,  DateTime? deliveryEta,  List<TimelineEntry> timeline,  LoadDriver? driver,  List<AmountRevision> revisions,  int revisionsUsed,  LoadPayment? payment,  List<Map<String, dynamic>> otpEvents,  List<Map<String, dynamic>> locationExceptions,  bool canEdit,  bool canCancel,  Map<String, dynamic>? cancelInfo, @JsonKey(unknownEnumValue: LoadAudience.unknown)  LoadAudience audience,  DateTime? wishlistUntil,  DateTime? openedToEveryoneAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoadDetail() when $default != null:
return $default(_that.id,_that.code,_that.status,_that.goodsType,_that.description,_that.quantity,_that.quantityUnit,_that.pickupArea,_that.dropArea,_that.pickupWindowStart,_that.agreedAmountInr,_that.paymentStatus,_that.postedForFarmerName,_that.pickup,_that.drop,_that.senderName,_that.senderMobile,_that.receiverName,_that.receiverMobile,_that.weightTonnes,_that.vehicleType,_that.freightPaidBy,_that.postedAmountInr,_that.deliveryEta,_that.timeline,_that.driver,_that.revisions,_that.revisionsUsed,_that.payment,_that.otpEvents,_that.locationExceptions,_that.canEdit,_that.canCancel,_that.cancelInfo,_that.audience,_that.wishlistUntil,_that.openedToEveryoneAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String code, @JsonKey(unknownEnumValue: LoadStatus.unknown)  LoadStatus status,  String goodsType,  String? description,  num quantity, @JsonKey(unknownEnumValue: QuantityUnit.unknown)  QuantityUnit quantityUnit,  String pickupArea,  String dropArea,  DateTime pickupWindowStart,  int agreedAmountInr, @JsonKey(unknownEnumValue: PaymentStatus.unknown)  PaymentStatus? paymentStatus,  String? postedForFarmerName,  Place pickup,  Place drop,  String senderName,  String senderMobile,  String receiverName,  String receiverMobile,  num weightTonnes, @JsonKey(unknownEnumValue: VehicleType.unknown)  VehicleType vehicleType, @JsonKey(unknownEnumValue: FreightPayer.unknown)  FreightPayer freightPaidBy,  int postedAmountInr,  DateTime? deliveryEta,  List<TimelineEntry> timeline,  LoadDriver? driver,  List<AmountRevision> revisions,  int revisionsUsed,  LoadPayment? payment,  List<Map<String, dynamic>> otpEvents,  List<Map<String, dynamic>> locationExceptions,  bool canEdit,  bool canCancel,  Map<String, dynamic>? cancelInfo, @JsonKey(unknownEnumValue: LoadAudience.unknown)  LoadAudience audience,  DateTime? wishlistUntil,  DateTime? openedToEveryoneAt)  $default,) {final _that = this;
switch (_that) {
case _LoadDetail():
return $default(_that.id,_that.code,_that.status,_that.goodsType,_that.description,_that.quantity,_that.quantityUnit,_that.pickupArea,_that.dropArea,_that.pickupWindowStart,_that.agreedAmountInr,_that.paymentStatus,_that.postedForFarmerName,_that.pickup,_that.drop,_that.senderName,_that.senderMobile,_that.receiverName,_that.receiverMobile,_that.weightTonnes,_that.vehicleType,_that.freightPaidBy,_that.postedAmountInr,_that.deliveryEta,_that.timeline,_that.driver,_that.revisions,_that.revisionsUsed,_that.payment,_that.otpEvents,_that.locationExceptions,_that.canEdit,_that.canCancel,_that.cancelInfo,_that.audience,_that.wishlistUntil,_that.openedToEveryoneAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String code, @JsonKey(unknownEnumValue: LoadStatus.unknown)  LoadStatus status,  String goodsType,  String? description,  num quantity, @JsonKey(unknownEnumValue: QuantityUnit.unknown)  QuantityUnit quantityUnit,  String pickupArea,  String dropArea,  DateTime pickupWindowStart,  int agreedAmountInr, @JsonKey(unknownEnumValue: PaymentStatus.unknown)  PaymentStatus? paymentStatus,  String? postedForFarmerName,  Place pickup,  Place drop,  String senderName,  String senderMobile,  String receiverName,  String receiverMobile,  num weightTonnes, @JsonKey(unknownEnumValue: VehicleType.unknown)  VehicleType vehicleType, @JsonKey(unknownEnumValue: FreightPayer.unknown)  FreightPayer freightPaidBy,  int postedAmountInr,  DateTime? deliveryEta,  List<TimelineEntry> timeline,  LoadDriver? driver,  List<AmountRevision> revisions,  int revisionsUsed,  LoadPayment? payment,  List<Map<String, dynamic>> otpEvents,  List<Map<String, dynamic>> locationExceptions,  bool canEdit,  bool canCancel,  Map<String, dynamic>? cancelInfo, @JsonKey(unknownEnumValue: LoadAudience.unknown)  LoadAudience audience,  DateTime? wishlistUntil,  DateTime? openedToEveryoneAt)?  $default,) {final _that = this;
switch (_that) {
case _LoadDetail() when $default != null:
return $default(_that.id,_that.code,_that.status,_that.goodsType,_that.description,_that.quantity,_that.quantityUnit,_that.pickupArea,_that.dropArea,_that.pickupWindowStart,_that.agreedAmountInr,_that.paymentStatus,_that.postedForFarmerName,_that.pickup,_that.drop,_that.senderName,_that.senderMobile,_that.receiverName,_that.receiverMobile,_that.weightTonnes,_that.vehicleType,_that.freightPaidBy,_that.postedAmountInr,_that.deliveryEta,_that.timeline,_that.driver,_that.revisions,_that.revisionsUsed,_that.payment,_that.otpEvents,_that.locationExceptions,_that.canEdit,_that.canCancel,_that.cancelInfo,_that.audience,_that.wishlistUntil,_that.openedToEveryoneAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LoadDetail implements LoadDetail {
  const _LoadDetail({required this.id, required this.code, @JsonKey(unknownEnumValue: LoadStatus.unknown) required this.status, required this.goodsType, this.description, required this.quantity, @JsonKey(unknownEnumValue: QuantityUnit.unknown) required this.quantityUnit, required this.pickupArea, required this.dropArea, required this.pickupWindowStart, required this.agreedAmountInr, @JsonKey(unknownEnumValue: PaymentStatus.unknown) this.paymentStatus, this.postedForFarmerName, required this.pickup, required this.drop, required this.senderName, required this.senderMobile, required this.receiverName, required this.receiverMobile, required this.weightTonnes, @JsonKey(unknownEnumValue: VehicleType.unknown) required this.vehicleType, @JsonKey(unknownEnumValue: FreightPayer.unknown) required this.freightPaidBy, required this.postedAmountInr, this.deliveryEta,  List<TimelineEntry> timeline = const <TimelineEntry>[], this.driver,  List<AmountRevision> revisions = const <AmountRevision>[], this.revisionsUsed = 0, this.payment,  List<Map<String, dynamic>> otpEvents = const <Map<String, dynamic>>[],  List<Map<String, dynamic>> locationExceptions = const <Map<String, dynamic>>[], this.canEdit = false, this.canCancel = false,  Map<String, dynamic>? cancelInfo, @JsonKey(unknownEnumValue: LoadAudience.unknown) this.audience = LoadAudience.everyone, this.wishlistUntil, this.openedToEveryoneAt}): _timeline = timeline,_revisions = revisions,_otpEvents = otpEvents,_locationExceptions = locationExceptions,_cancelInfo = cancelInfo;
  factory _LoadDetail.fromJson(Map<String, dynamic> json) => _$LoadDetailFromJson(json);

@override final  String id;
@override final  String code;
@override@JsonKey(unknownEnumValue: LoadStatus.unknown) final  LoadStatus status;
@override final  String goodsType;
@override final  String? description;
@override final  num quantity;
@override@JsonKey(unknownEnumValue: QuantityUnit.unknown) final  QuantityUnit quantityUnit;
@override final  String pickupArea;
@override final  String dropArea;
@override final  DateTime pickupWindowStart;
@override final  int agreedAmountInr;
@override@JsonKey(unknownEnumValue: PaymentStatus.unknown) final  PaymentStatus? paymentStatus;
@override final  String? postedForFarmerName;
@override final  Place pickup;
@override final  Place drop;
@override final  String senderName;
@override final  String senderMobile;
@override final  String receiverName;
@override final  String receiverMobile;
@override final  num weightTonnes;
@override@JsonKey(unknownEnumValue: VehicleType.unknown) final  VehicleType vehicleType;
@override@JsonKey(unknownEnumValue: FreightPayer.unknown) final  FreightPayer freightPaidBy;
@override final  int postedAmountInr;
@override final  DateTime? deliveryEta;
 final  List<TimelineEntry> _timeline;
@override@JsonKey() List<TimelineEntry> get timeline {
  if (_timeline is EqualUnmodifiableListView) return _timeline;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_timeline);
}

@override final  LoadDriver? driver;
 final  List<AmountRevision> _revisions;
@override@JsonKey() List<AmountRevision> get revisions {
  if (_revisions is EqualUnmodifiableListView) return _revisions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_revisions);
}

@override@JsonKey() final  int revisionsUsed;
@override final  LoadPayment? payment;
 final  List<Map<String, dynamic>> _otpEvents;
@override@JsonKey() List<Map<String, dynamic>> get otpEvents {
  if (_otpEvents is EqualUnmodifiableListView) return _otpEvents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_otpEvents);
}

 final  List<Map<String, dynamic>> _locationExceptions;
@override@JsonKey() List<Map<String, dynamic>> get locationExceptions {
  if (_locationExceptions is EqualUnmodifiableListView) return _locationExceptions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_locationExceptions);
}

@override@JsonKey() final  bool canEdit;
@override@JsonKey() final  bool canCancel;
 final  Map<String, dynamic>? _cancelInfo;
@override Map<String, dynamic>? get cancelInfo {
  final value = _cancelInfo;
  if (value == null) return null;
  if (_cancelInfo is EqualUnmodifiableMapView) return _cancelInfo;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@JsonKey(unknownEnumValue: LoadAudience.unknown) final  LoadAudience audience;
@override final  DateTime? wishlistUntil;
@override final  DateTime? openedToEveryoneAt;

/// Create a copy of LoadDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoadDetailCopyWith<_LoadDetail> get copyWith => __$LoadDetailCopyWithImpl<_LoadDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LoadDetailToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoadDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.status, status) || other.status == status)&&(identical(other.goodsType, goodsType) || other.goodsType == goodsType)&&(identical(other.description, description) || other.description == description)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.quantityUnit, quantityUnit) || other.quantityUnit == quantityUnit)&&(identical(other.pickupArea, pickupArea) || other.pickupArea == pickupArea)&&(identical(other.dropArea, dropArea) || other.dropArea == dropArea)&&(identical(other.pickupWindowStart, pickupWindowStart) || other.pickupWindowStart == pickupWindowStart)&&(identical(other.agreedAmountInr, agreedAmountInr) || other.agreedAmountInr == agreedAmountInr)&&(identical(other.paymentStatus, paymentStatus) || other.paymentStatus == paymentStatus)&&(identical(other.postedForFarmerName, postedForFarmerName) || other.postedForFarmerName == postedForFarmerName)&&(identical(other.pickup, pickup) || other.pickup == pickup)&&(identical(other.drop, drop) || other.drop == drop)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.senderMobile, senderMobile) || other.senderMobile == senderMobile)&&(identical(other.receiverName, receiverName) || other.receiverName == receiverName)&&(identical(other.receiverMobile, receiverMobile) || other.receiverMobile == receiverMobile)&&(identical(other.weightTonnes, weightTonnes) || other.weightTonnes == weightTonnes)&&(identical(other.vehicleType, vehicleType) || other.vehicleType == vehicleType)&&(identical(other.freightPaidBy, freightPaidBy) || other.freightPaidBy == freightPaidBy)&&(identical(other.postedAmountInr, postedAmountInr) || other.postedAmountInr == postedAmountInr)&&(identical(other.deliveryEta, deliveryEta) || other.deliveryEta == deliveryEta)&&const DeepCollectionEquality().equals(other.timeline, _timeline)&&(identical(other.driver, driver) || other.driver == driver)&&const DeepCollectionEquality().equals(other.revisions, _revisions)&&(identical(other.revisionsUsed, revisionsUsed) || other.revisionsUsed == revisionsUsed)&&(identical(other.payment, payment) || other.payment == payment)&&const DeepCollectionEquality().equals(other.otpEvents, _otpEvents)&&const DeepCollectionEquality().equals(other.locationExceptions, _locationExceptions)&&(identical(other.canEdit, canEdit) || other.canEdit == canEdit)&&(identical(other.canCancel, canCancel) || other.canCancel == canCancel)&&const DeepCollectionEquality().equals(other.cancelInfo, _cancelInfo)&&(identical(other.audience, audience) || other.audience == audience)&&(identical(other.wishlistUntil, wishlistUntil) || other.wishlistUntil == wishlistUntil)&&(identical(other.openedToEveryoneAt, openedToEveryoneAt) || other.openedToEveryoneAt == openedToEveryoneAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,id,code,status,goodsType,description,quantity,quantityUnit,pickupArea,dropArea,pickupWindowStart,agreedAmountInr,paymentStatus,postedForFarmerName,pickup,drop,senderName,senderMobile,receiverName,receiverMobile,weightTonnes,vehicleType,freightPaidBy,postedAmountInr,deliveryEta,const DeepCollectionEquality().hash(_timeline),driver,const DeepCollectionEquality().hash(_revisions),revisionsUsed,payment,const DeepCollectionEquality().hash(_otpEvents),const DeepCollectionEquality().hash(_locationExceptions),canEdit,canCancel,const DeepCollectionEquality().hash(_cancelInfo),audience,wishlistUntil,openedToEveryoneAt]);
}

@override
String toString() {
    return 'LoadDetail(id: $id, code: $code, status: $status, goodsType: $goodsType, description: $description, quantity: $quantity, quantityUnit: $quantityUnit, pickupArea: $pickupArea, dropArea: $dropArea, pickupWindowStart: $pickupWindowStart, agreedAmountInr: $agreedAmountInr, paymentStatus: $paymentStatus, postedForFarmerName: $postedForFarmerName, pickup: $pickup, drop: $drop, senderName: $senderName, senderMobile: $senderMobile, receiverName: $receiverName, receiverMobile: $receiverMobile, weightTonnes: $weightTonnes, vehicleType: $vehicleType, freightPaidBy: $freightPaidBy, postedAmountInr: $postedAmountInr, deliveryEta: $deliveryEta, timeline: $timeline, driver: $driver, revisions: $revisions, revisionsUsed: $revisionsUsed, payment: $payment, otpEvents: $otpEvents, locationExceptions: $locationExceptions, canEdit: $canEdit, canCancel: $canCancel, cancelInfo: $cancelInfo, audience: $audience, wishlistUntil: $wishlistUntil, openedToEveryoneAt: $openedToEveryoneAt)';
}


}

/// @nodoc
abstract mixin class _$LoadDetailCopyWith<$Res> implements $LoadDetailCopyWith<$Res> {
  factory _$LoadDetailCopyWith(_LoadDetail value, $Res Function(_LoadDetail) _then) = __$LoadDetailCopyWithImpl;
@override @useResult
$Res call({
 String id, String code,@JsonKey(unknownEnumValue: LoadStatus.unknown) LoadStatus status, String goodsType, String? description, num quantity,@JsonKey(unknownEnumValue: QuantityUnit.unknown) QuantityUnit quantityUnit, String pickupArea, String dropArea, DateTime pickupWindowStart, int agreedAmountInr,@JsonKey(unknownEnumValue: PaymentStatus.unknown) PaymentStatus? paymentStatus, String? postedForFarmerName, Place pickup, Place drop, String senderName, String senderMobile, String receiverName, String receiverMobile, num weightTonnes,@JsonKey(unknownEnumValue: VehicleType.unknown) VehicleType vehicleType,@JsonKey(unknownEnumValue: FreightPayer.unknown) FreightPayer freightPaidBy, int postedAmountInr, DateTime? deliveryEta, List<TimelineEntry> timeline, LoadDriver? driver, List<AmountRevision> revisions, int revisionsUsed, LoadPayment? payment, List<Map<String, dynamic>> otpEvents, List<Map<String, dynamic>> locationExceptions, bool canEdit, bool canCancel, Map<String, dynamic>? cancelInfo,@JsonKey(unknownEnumValue: LoadAudience.unknown) LoadAudience audience, DateTime? wishlistUntil, DateTime? openedToEveryoneAt
});


@override $PlaceCopyWith<$Res> get pickup;@override $PlaceCopyWith<$Res> get drop;@override $LoadDriverCopyWith<$Res>? get driver;@override $LoadPaymentCopyWith<$Res>? get payment;

}
/// @nodoc
class __$LoadDetailCopyWithImpl<$Res>
    implements _$LoadDetailCopyWith<$Res> {
  __$LoadDetailCopyWithImpl(this._self, this._then);

  final _LoadDetail _self;
  final $Res Function(_LoadDetail) _then;

/// Create a copy of LoadDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? code = null,Object? status = null,Object? goodsType = null,Object? description = freezed,Object? quantity = null,Object? quantityUnit = null,Object? pickupArea = null,Object? dropArea = null,Object? pickupWindowStart = null,Object? agreedAmountInr = null,Object? paymentStatus = freezed,Object? postedForFarmerName = freezed,Object? pickup = null,Object? drop = null,Object? senderName = null,Object? senderMobile = null,Object? receiverName = null,Object? receiverMobile = null,Object? weightTonnes = null,Object? vehicleType = null,Object? freightPaidBy = null,Object? postedAmountInr = null,Object? deliveryEta = freezed,Object? timeline = null,Object? driver = freezed,Object? revisions = null,Object? revisionsUsed = null,Object? payment = freezed,Object? otpEvents = null,Object? locationExceptions = null,Object? canEdit = null,Object? canCancel = null,Object? cancelInfo = freezed,Object? audience = null,Object? wishlistUntil = freezed,Object? openedToEveryoneAt = freezed,}) {
  return _then(_LoadDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LoadStatus,goodsType: null == goodsType ? _self.goodsType : goodsType // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as num,quantityUnit: null == quantityUnit ? _self.quantityUnit : quantityUnit // ignore: cast_nullable_to_non_nullable
as QuantityUnit,pickupArea: null == pickupArea ? _self.pickupArea : pickupArea // ignore: cast_nullable_to_non_nullable
as String,dropArea: null == dropArea ? _self.dropArea : dropArea // ignore: cast_nullable_to_non_nullable
as String,pickupWindowStart: null == pickupWindowStart ? _self.pickupWindowStart : pickupWindowStart // ignore: cast_nullable_to_non_nullable
as DateTime,agreedAmountInr: null == agreedAmountInr ? _self.agreedAmountInr : agreedAmountInr // ignore: cast_nullable_to_non_nullable
as int,paymentStatus: freezed == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as PaymentStatus?,postedForFarmerName: freezed == postedForFarmerName ? _self.postedForFarmerName : postedForFarmerName // ignore: cast_nullable_to_non_nullable
as String?,pickup: null == pickup ? _self.pickup : pickup // ignore: cast_nullable_to_non_nullable
as Place,drop: null == drop ? _self.drop : drop // ignore: cast_nullable_to_non_nullable
as Place,senderName: null == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String,senderMobile: null == senderMobile ? _self.senderMobile : senderMobile // ignore: cast_nullable_to_non_nullable
as String,receiverName: null == receiverName ? _self.receiverName : receiverName // ignore: cast_nullable_to_non_nullable
as String,receiverMobile: null == receiverMobile ? _self.receiverMobile : receiverMobile // ignore: cast_nullable_to_non_nullable
as String,weightTonnes: null == weightTonnes ? _self.weightTonnes : weightTonnes // ignore: cast_nullable_to_non_nullable
as num,vehicleType: null == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as VehicleType,freightPaidBy: null == freightPaidBy ? _self.freightPaidBy : freightPaidBy // ignore: cast_nullable_to_non_nullable
as FreightPayer,postedAmountInr: null == postedAmountInr ? _self.postedAmountInr : postedAmountInr // ignore: cast_nullable_to_non_nullable
as int,deliveryEta: freezed == deliveryEta ? _self.deliveryEta : deliveryEta // ignore: cast_nullable_to_non_nullable
as DateTime?,timeline: null == timeline ? _self._timeline : timeline // ignore: cast_nullable_to_non_nullable
as List<TimelineEntry>,driver: freezed == driver ? _self.driver : driver // ignore: cast_nullable_to_non_nullable
as LoadDriver?,revisions: null == revisions ? _self._revisions : revisions // ignore: cast_nullable_to_non_nullable
as List<AmountRevision>,revisionsUsed: null == revisionsUsed ? _self.revisionsUsed : revisionsUsed // ignore: cast_nullable_to_non_nullable
as int,payment: freezed == payment ? _self.payment : payment // ignore: cast_nullable_to_non_nullable
as LoadPayment?,otpEvents: null == otpEvents ? _self._otpEvents : otpEvents // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,locationExceptions: null == locationExceptions ? _self._locationExceptions : locationExceptions // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,canEdit: null == canEdit ? _self.canEdit : canEdit // ignore: cast_nullable_to_non_nullable
as bool,canCancel: null == canCancel ? _self.canCancel : canCancel // ignore: cast_nullable_to_non_nullable
as bool,cancelInfo: freezed == cancelInfo ? _self._cancelInfo : cancelInfo // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,audience: null == audience ? _self.audience : audience // ignore: cast_nullable_to_non_nullable
as LoadAudience,wishlistUntil: freezed == wishlistUntil ? _self.wishlistUntil : wishlistUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,openedToEveryoneAt: freezed == openedToEveryoneAt ? _self.openedToEveryoneAt : openedToEveryoneAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of LoadDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlaceCopyWith<$Res> get pickup {
  
  return $PlaceCopyWith<$Res>(_self.pickup, (value) {
    return _then(_self.copyWith(pickup: value));
  });
}/// Create a copy of LoadDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlaceCopyWith<$Res> get drop {
  
  return $PlaceCopyWith<$Res>(_self.drop, (value) {
    return _then(_self.copyWith(drop: value));
  });
}/// Create a copy of LoadDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LoadDriverCopyWith<$Res>? get driver {
    if (_self.driver == null) {
    return null;
  }

  return $LoadDriverCopyWith<$Res>(_self.driver!, (value) {
    return _then(_self.copyWith(driver: value));
  });
}/// Create a copy of LoadDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LoadPaymentCopyWith<$Res>? get payment {
    if (_self.payment == null) {
    return null;
  }

  return $LoadPaymentCopyWith<$Res>(_self.payment!, (value) {
    return _then(_self.copyWith(payment: value));
  });
}
}


/// @nodoc
mixin _$LoadCreate {

 DateTime get pickupWindowStart; DateTime get pickupWindowEnd; Place get pickup; String get senderName; String get senderMobile; String get goodsType; String? get description; num get quantity; QuantityUnit get quantityUnit; num get weightTonnes; VehicleType get vehicleType; Place get drop; String get receiverName; String get receiverMobile; FreightPayer get freightPaidBy; int get amountInr; String? get postedForFarmerId; LoadAudience get audience; List<String>? get wishlistEntryIds;
/// Create a copy of LoadCreate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoadCreateCopyWith<LoadCreate> get copyWith => _$LoadCreateCopyWithImpl<LoadCreate>(this as LoadCreate, _$identity);

  /// Serializes this LoadCreate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LoadCreate;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoadCreate&&(identical(other.pickupWindowStart, _this.pickupWindowStart) || other.pickupWindowStart == _this.pickupWindowStart)&&(identical(other.pickupWindowEnd, _this.pickupWindowEnd) || other.pickupWindowEnd == _this.pickupWindowEnd)&&(identical(other.pickup, _this.pickup) || other.pickup == _this.pickup)&&(identical(other.senderName, _this.senderName) || other.senderName == _this.senderName)&&(identical(other.senderMobile, _this.senderMobile) || other.senderMobile == _this.senderMobile)&&(identical(other.goodsType, _this.goodsType) || other.goodsType == _this.goodsType)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.quantity, _this.quantity) || other.quantity == _this.quantity)&&(identical(other.quantityUnit, _this.quantityUnit) || other.quantityUnit == _this.quantityUnit)&&(identical(other.weightTonnes, _this.weightTonnes) || other.weightTonnes == _this.weightTonnes)&&(identical(other.vehicleType, _this.vehicleType) || other.vehicleType == _this.vehicleType)&&(identical(other.drop, _this.drop) || other.drop == _this.drop)&&(identical(other.receiverName, _this.receiverName) || other.receiverName == _this.receiverName)&&(identical(other.receiverMobile, _this.receiverMobile) || other.receiverMobile == _this.receiverMobile)&&(identical(other.freightPaidBy, _this.freightPaidBy) || other.freightPaidBy == _this.freightPaidBy)&&(identical(other.amountInr, _this.amountInr) || other.amountInr == _this.amountInr)&&(identical(other.postedForFarmerId, _this.postedForFarmerId) || other.postedForFarmerId == _this.postedForFarmerId)&&(identical(other.audience, _this.audience) || other.audience == _this.audience)&&const DeepCollectionEquality().equals(other.wishlistEntryIds, _this.wishlistEntryIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LoadCreate;
  return Object.hashAll([runtimeType,_this.pickupWindowStart,_this.pickupWindowEnd,_this.pickup,_this.senderName,_this.senderMobile,_this.goodsType,_this.description,_this.quantity,_this.quantityUnit,_this.weightTonnes,_this.vehicleType,_this.drop,_this.receiverName,_this.receiverMobile,_this.freightPaidBy,_this.amountInr,_this.postedForFarmerId,_this.audience,const DeepCollectionEquality().hash(_this.wishlistEntryIds)]);
}

@override
String toString() {
  final _this = this as LoadCreate;
  return 'LoadCreate(pickupWindowStart: ${_this.pickupWindowStart}, pickupWindowEnd: ${_this.pickupWindowEnd}, pickup: ${_this.pickup}, senderName: ${_this.senderName}, senderMobile: ${_this.senderMobile}, goodsType: ${_this.goodsType}, description: ${_this.description}, quantity: ${_this.quantity}, quantityUnit: ${_this.quantityUnit}, weightTonnes: ${_this.weightTonnes}, vehicleType: ${_this.vehicleType}, drop: ${_this.drop}, receiverName: ${_this.receiverName}, receiverMobile: ${_this.receiverMobile}, freightPaidBy: ${_this.freightPaidBy}, amountInr: ${_this.amountInr}, postedForFarmerId: ${_this.postedForFarmerId}, audience: ${_this.audience}, wishlistEntryIds: ${_this.wishlistEntryIds})';
}


}

/// @nodoc
abstract mixin class $LoadCreateCopyWith<$Res>  {
  factory $LoadCreateCopyWith(LoadCreate value, $Res Function(LoadCreate) _then) = _$LoadCreateCopyWithImpl;
@useResult
$Res call({
 DateTime pickupWindowStart, DateTime pickupWindowEnd, Place pickup, String senderName, String senderMobile, String goodsType, String? description, num quantity, QuantityUnit quantityUnit, num weightTonnes, VehicleType vehicleType, Place drop, String receiverName, String receiverMobile, FreightPayer freightPaidBy, int amountInr, String? postedForFarmerId, LoadAudience audience, List<String>? wishlistEntryIds
});


$PlaceCopyWith<$Res> get pickup;$PlaceCopyWith<$Res> get drop;

}
/// @nodoc
class _$LoadCreateCopyWithImpl<$Res>
    implements $LoadCreateCopyWith<$Res> {
  _$LoadCreateCopyWithImpl(this._self, this._then);

  final LoadCreate _self;
  final $Res Function(LoadCreate) _then;

/// Create a copy of LoadCreate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pickupWindowStart = null,Object? pickupWindowEnd = null,Object? pickup = null,Object? senderName = null,Object? senderMobile = null,Object? goodsType = null,Object? description = freezed,Object? quantity = null,Object? quantityUnit = null,Object? weightTonnes = null,Object? vehicleType = null,Object? drop = null,Object? receiverName = null,Object? receiverMobile = null,Object? freightPaidBy = null,Object? amountInr = null,Object? postedForFarmerId = freezed,Object? audience = null,Object? wishlistEntryIds = freezed,}) {
  return _then(LoadCreate(
pickupWindowStart: null == pickupWindowStart ? _self.pickupWindowStart : pickupWindowStart // ignore: cast_nullable_to_non_nullable
as DateTime,pickupWindowEnd: null == pickupWindowEnd ? _self.pickupWindowEnd : pickupWindowEnd // ignore: cast_nullable_to_non_nullable
as DateTime,pickup: null == pickup ? _self.pickup : pickup // ignore: cast_nullable_to_non_nullable
as Place,senderName: null == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String,senderMobile: null == senderMobile ? _self.senderMobile : senderMobile // ignore: cast_nullable_to_non_nullable
as String,goodsType: null == goodsType ? _self.goodsType : goodsType // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as num,quantityUnit: null == quantityUnit ? _self.quantityUnit : quantityUnit // ignore: cast_nullable_to_non_nullable
as QuantityUnit,weightTonnes: null == weightTonnes ? _self.weightTonnes : weightTonnes // ignore: cast_nullable_to_non_nullable
as num,vehicleType: null == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as VehicleType,drop: null == drop ? _self.drop : drop // ignore: cast_nullable_to_non_nullable
as Place,receiverName: null == receiverName ? _self.receiverName : receiverName // ignore: cast_nullable_to_non_nullable
as String,receiverMobile: null == receiverMobile ? _self.receiverMobile : receiverMobile // ignore: cast_nullable_to_non_nullable
as String,freightPaidBy: null == freightPaidBy ? _self.freightPaidBy : freightPaidBy // ignore: cast_nullable_to_non_nullable
as FreightPayer,amountInr: null == amountInr ? _self.amountInr : amountInr // ignore: cast_nullable_to_non_nullable
as int,postedForFarmerId: freezed == postedForFarmerId ? _self.postedForFarmerId : postedForFarmerId // ignore: cast_nullable_to_non_nullable
as String?,audience: null == audience ? _self.audience : audience // ignore: cast_nullable_to_non_nullable
as LoadAudience,wishlistEntryIds: freezed == wishlistEntryIds ? _self.wishlistEntryIds : wishlistEntryIds // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}
/// Create a copy of LoadCreate
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlaceCopyWith<$Res> get pickup {
  
  return $PlaceCopyWith<$Res>(_self.pickup, (value) {
    return _then(_self.copyWith(pickup: value));
  });
}/// Create a copy of LoadCreate
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlaceCopyWith<$Res> get drop {
  
  return $PlaceCopyWith<$Res>(_self.drop, (value) {
    return _then(_self.copyWith(drop: value));
  });
}
}


/// Adds pattern-matching-related methods to [LoadCreate].
extension LoadCreatePatterns on LoadCreate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoadCreate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoadCreate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoadCreate value)  $default,){
final _that = this;
switch (_that) {
case _LoadCreate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoadCreate value)?  $default,){
final _that = this;
switch (_that) {
case _LoadCreate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime pickupWindowStart,  DateTime pickupWindowEnd,  Place pickup,  String senderName,  String senderMobile,  String goodsType,  String? description,  num quantity,  QuantityUnit quantityUnit,  num weightTonnes,  VehicleType vehicleType,  Place drop,  String receiverName,  String receiverMobile,  FreightPayer freightPaidBy,  int amountInr,  String? postedForFarmerId,  LoadAudience audience,  List<String>? wishlistEntryIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoadCreate() when $default != null:
return $default(_that.pickupWindowStart,_that.pickupWindowEnd,_that.pickup,_that.senderName,_that.senderMobile,_that.goodsType,_that.description,_that.quantity,_that.quantityUnit,_that.weightTonnes,_that.vehicleType,_that.drop,_that.receiverName,_that.receiverMobile,_that.freightPaidBy,_that.amountInr,_that.postedForFarmerId,_that.audience,_that.wishlistEntryIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime pickupWindowStart,  DateTime pickupWindowEnd,  Place pickup,  String senderName,  String senderMobile,  String goodsType,  String? description,  num quantity,  QuantityUnit quantityUnit,  num weightTonnes,  VehicleType vehicleType,  Place drop,  String receiverName,  String receiverMobile,  FreightPayer freightPaidBy,  int amountInr,  String? postedForFarmerId,  LoadAudience audience,  List<String>? wishlistEntryIds)  $default,) {final _that = this;
switch (_that) {
case _LoadCreate():
return $default(_that.pickupWindowStart,_that.pickupWindowEnd,_that.pickup,_that.senderName,_that.senderMobile,_that.goodsType,_that.description,_that.quantity,_that.quantityUnit,_that.weightTonnes,_that.vehicleType,_that.drop,_that.receiverName,_that.receiverMobile,_that.freightPaidBy,_that.amountInr,_that.postedForFarmerId,_that.audience,_that.wishlistEntryIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime pickupWindowStart,  DateTime pickupWindowEnd,  Place pickup,  String senderName,  String senderMobile,  String goodsType,  String? description,  num quantity,  QuantityUnit quantityUnit,  num weightTonnes,  VehicleType vehicleType,  Place drop,  String receiverName,  String receiverMobile,  FreightPayer freightPaidBy,  int amountInr,  String? postedForFarmerId,  LoadAudience audience,  List<String>? wishlistEntryIds)?  $default,) {final _that = this;
switch (_that) {
case _LoadCreate() when $default != null:
return $default(_that.pickupWindowStart,_that.pickupWindowEnd,_that.pickup,_that.senderName,_that.senderMobile,_that.goodsType,_that.description,_that.quantity,_that.quantityUnit,_that.weightTonnes,_that.vehicleType,_that.drop,_that.receiverName,_that.receiverMobile,_that.freightPaidBy,_that.amountInr,_that.postedForFarmerId,_that.audience,_that.wishlistEntryIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LoadCreate implements LoadCreate {
  const _LoadCreate({required this.pickupWindowStart, required this.pickupWindowEnd, required this.pickup, required this.senderName, required this.senderMobile, required this.goodsType, this.description, required this.quantity, required this.quantityUnit, required this.weightTonnes, required this.vehicleType, required this.drop, required this.receiverName, required this.receiverMobile, required this.freightPaidBy, required this.amountInr, this.postedForFarmerId, this.audience = LoadAudience.everyone,  List<String>? wishlistEntryIds}): _wishlistEntryIds = wishlistEntryIds;
  factory _LoadCreate.fromJson(Map<String, dynamic> json) => _$LoadCreateFromJson(json);

@override final  DateTime pickupWindowStart;
@override final  DateTime pickupWindowEnd;
@override final  Place pickup;
@override final  String senderName;
@override final  String senderMobile;
@override final  String goodsType;
@override final  String? description;
@override final  num quantity;
@override final  QuantityUnit quantityUnit;
@override final  num weightTonnes;
@override final  VehicleType vehicleType;
@override final  Place drop;
@override final  String receiverName;
@override final  String receiverMobile;
@override final  FreightPayer freightPaidBy;
@override final  int amountInr;
@override final  String? postedForFarmerId;
@override@JsonKey() final  LoadAudience audience;
 final  List<String>? _wishlistEntryIds;
@override List<String>? get wishlistEntryIds {
  final value = _wishlistEntryIds;
  if (value == null) return null;
  if (_wishlistEntryIds is EqualUnmodifiableListView) return _wishlistEntryIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of LoadCreate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoadCreateCopyWith<_LoadCreate> get copyWith => __$LoadCreateCopyWithImpl<_LoadCreate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LoadCreateToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoadCreate&&(identical(other.pickupWindowStart, pickupWindowStart) || other.pickupWindowStart == pickupWindowStart)&&(identical(other.pickupWindowEnd, pickupWindowEnd) || other.pickupWindowEnd == pickupWindowEnd)&&(identical(other.pickup, pickup) || other.pickup == pickup)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.senderMobile, senderMobile) || other.senderMobile == senderMobile)&&(identical(other.goodsType, goodsType) || other.goodsType == goodsType)&&(identical(other.description, description) || other.description == description)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.quantityUnit, quantityUnit) || other.quantityUnit == quantityUnit)&&(identical(other.weightTonnes, weightTonnes) || other.weightTonnes == weightTonnes)&&(identical(other.vehicleType, vehicleType) || other.vehicleType == vehicleType)&&(identical(other.drop, drop) || other.drop == drop)&&(identical(other.receiverName, receiverName) || other.receiverName == receiverName)&&(identical(other.receiverMobile, receiverMobile) || other.receiverMobile == receiverMobile)&&(identical(other.freightPaidBy, freightPaidBy) || other.freightPaidBy == freightPaidBy)&&(identical(other.amountInr, amountInr) || other.amountInr == amountInr)&&(identical(other.postedForFarmerId, postedForFarmerId) || other.postedForFarmerId == postedForFarmerId)&&(identical(other.audience, audience) || other.audience == audience)&&const DeepCollectionEquality().equals(other.wishlistEntryIds, _wishlistEntryIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,pickupWindowStart,pickupWindowEnd,pickup,senderName,senderMobile,goodsType,description,quantity,quantityUnit,weightTonnes,vehicleType,drop,receiverName,receiverMobile,freightPaidBy,amountInr,postedForFarmerId,audience,const DeepCollectionEquality().hash(_wishlistEntryIds)]);
}

@override
String toString() {
    return 'LoadCreate(pickupWindowStart: $pickupWindowStart, pickupWindowEnd: $pickupWindowEnd, pickup: $pickup, senderName: $senderName, senderMobile: $senderMobile, goodsType: $goodsType, description: $description, quantity: $quantity, quantityUnit: $quantityUnit, weightTonnes: $weightTonnes, vehicleType: $vehicleType, drop: $drop, receiverName: $receiverName, receiverMobile: $receiverMobile, freightPaidBy: $freightPaidBy, amountInr: $amountInr, postedForFarmerId: $postedForFarmerId, audience: $audience, wishlistEntryIds: $wishlistEntryIds)';
}


}

/// @nodoc
abstract mixin class _$LoadCreateCopyWith<$Res> implements $LoadCreateCopyWith<$Res> {
  factory _$LoadCreateCopyWith(_LoadCreate value, $Res Function(_LoadCreate) _then) = __$LoadCreateCopyWithImpl;
@override @useResult
$Res call({
 DateTime pickupWindowStart, DateTime pickupWindowEnd, Place pickup, String senderName, String senderMobile, String goodsType, String? description, num quantity, QuantityUnit quantityUnit, num weightTonnes, VehicleType vehicleType, Place drop, String receiverName, String receiverMobile, FreightPayer freightPaidBy, int amountInr, String? postedForFarmerId, LoadAudience audience, List<String>? wishlistEntryIds
});


@override $PlaceCopyWith<$Res> get pickup;@override $PlaceCopyWith<$Res> get drop;

}
/// @nodoc
class __$LoadCreateCopyWithImpl<$Res>
    implements _$LoadCreateCopyWith<$Res> {
  __$LoadCreateCopyWithImpl(this._self, this._then);

  final _LoadCreate _self;
  final $Res Function(_LoadCreate) _then;

/// Create a copy of LoadCreate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pickupWindowStart = null,Object? pickupWindowEnd = null,Object? pickup = null,Object? senderName = null,Object? senderMobile = null,Object? goodsType = null,Object? description = freezed,Object? quantity = null,Object? quantityUnit = null,Object? weightTonnes = null,Object? vehicleType = null,Object? drop = null,Object? receiverName = null,Object? receiverMobile = null,Object? freightPaidBy = null,Object? amountInr = null,Object? postedForFarmerId = freezed,Object? audience = null,Object? wishlistEntryIds = freezed,}) {
  return _then(_LoadCreate(
pickupWindowStart: null == pickupWindowStart ? _self.pickupWindowStart : pickupWindowStart // ignore: cast_nullable_to_non_nullable
as DateTime,pickupWindowEnd: null == pickupWindowEnd ? _self.pickupWindowEnd : pickupWindowEnd // ignore: cast_nullable_to_non_nullable
as DateTime,pickup: null == pickup ? _self.pickup : pickup // ignore: cast_nullable_to_non_nullable
as Place,senderName: null == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String,senderMobile: null == senderMobile ? _self.senderMobile : senderMobile // ignore: cast_nullable_to_non_nullable
as String,goodsType: null == goodsType ? _self.goodsType : goodsType // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as num,quantityUnit: null == quantityUnit ? _self.quantityUnit : quantityUnit // ignore: cast_nullable_to_non_nullable
as QuantityUnit,weightTonnes: null == weightTonnes ? _self.weightTonnes : weightTonnes // ignore: cast_nullable_to_non_nullable
as num,vehicleType: null == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as VehicleType,drop: null == drop ? _self.drop : drop // ignore: cast_nullable_to_non_nullable
as Place,receiverName: null == receiverName ? _self.receiverName : receiverName // ignore: cast_nullable_to_non_nullable
as String,receiverMobile: null == receiverMobile ? _self.receiverMobile : receiverMobile // ignore: cast_nullable_to_non_nullable
as String,freightPaidBy: null == freightPaidBy ? _self.freightPaidBy : freightPaidBy // ignore: cast_nullable_to_non_nullable
as FreightPayer,amountInr: null == amountInr ? _self.amountInr : amountInr // ignore: cast_nullable_to_non_nullable
as int,postedForFarmerId: freezed == postedForFarmerId ? _self.postedForFarmerId : postedForFarmerId // ignore: cast_nullable_to_non_nullable
as String?,audience: null == audience ? _self.audience : audience // ignore: cast_nullable_to_non_nullable
as LoadAudience,wishlistEntryIds: freezed == wishlistEntryIds ? _self._wishlistEntryIds : wishlistEntryIds // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

/// Create a copy of LoadCreate
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlaceCopyWith<$Res> get pickup {
  
  return $PlaceCopyWith<$Res>(_self.pickup, (value) {
    return _then(_self.copyWith(pickup: value));
  });
}/// Create a copy of LoadCreate
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlaceCopyWith<$Res> get drop {
  
  return $PlaceCopyWith<$Res>(_self.drop, (value) {
    return _then(_self.copyWith(drop: value));
  });
}
}


/// @nodoc
mixin _$LoadEstimate {

 double get distanceKm; int get driveMinutes; DateTime get deliveryEta; Map<String, dynamic>? get suggestedAmountRange;
/// Create a copy of LoadEstimate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoadEstimateCopyWith<LoadEstimate> get copyWith => _$LoadEstimateCopyWithImpl<LoadEstimate>(this as LoadEstimate, _$identity);

  /// Serializes this LoadEstimate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LoadEstimate;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoadEstimate&&(identical(other.distanceKm, _this.distanceKm) || other.distanceKm == _this.distanceKm)&&(identical(other.driveMinutes, _this.driveMinutes) || other.driveMinutes == _this.driveMinutes)&&(identical(other.deliveryEta, _this.deliveryEta) || other.deliveryEta == _this.deliveryEta)&&const DeepCollectionEquality().equals(other.suggestedAmountRange, _this.suggestedAmountRange));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LoadEstimate;
  return Object.hash(runtimeType,_this.distanceKm,_this.driveMinutes,_this.deliveryEta,const DeepCollectionEquality().hash(_this.suggestedAmountRange));
}

@override
String toString() {
  final _this = this as LoadEstimate;
  return 'LoadEstimate(distanceKm: ${_this.distanceKm}, driveMinutes: ${_this.driveMinutes}, deliveryEta: ${_this.deliveryEta}, suggestedAmountRange: ${_this.suggestedAmountRange})';
}


}

/// @nodoc
abstract mixin class $LoadEstimateCopyWith<$Res>  {
  factory $LoadEstimateCopyWith(LoadEstimate value, $Res Function(LoadEstimate) _then) = _$LoadEstimateCopyWithImpl;
@useResult
$Res call({
 double distanceKm, int driveMinutes, DateTime deliveryEta, Map<String, dynamic>? suggestedAmountRange
});




}
/// @nodoc
class _$LoadEstimateCopyWithImpl<$Res>
    implements $LoadEstimateCopyWith<$Res> {
  _$LoadEstimateCopyWithImpl(this._self, this._then);

  final LoadEstimate _self;
  final $Res Function(LoadEstimate) _then;

/// Create a copy of LoadEstimate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? distanceKm = null,Object? driveMinutes = null,Object? deliveryEta = null,Object? suggestedAmountRange = freezed,}) {
  return _then(LoadEstimate(
distanceKm: null == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double,driveMinutes: null == driveMinutes ? _self.driveMinutes : driveMinutes // ignore: cast_nullable_to_non_nullable
as int,deliveryEta: null == deliveryEta ? _self.deliveryEta : deliveryEta // ignore: cast_nullable_to_non_nullable
as DateTime,suggestedAmountRange: freezed == suggestedAmountRange ? _self.suggestedAmountRange : suggestedAmountRange // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [LoadEstimate].
extension LoadEstimatePatterns on LoadEstimate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoadEstimate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoadEstimate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoadEstimate value)  $default,){
final _that = this;
switch (_that) {
case _LoadEstimate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoadEstimate value)?  $default,){
final _that = this;
switch (_that) {
case _LoadEstimate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double distanceKm,  int driveMinutes,  DateTime deliveryEta,  Map<String, dynamic>? suggestedAmountRange)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoadEstimate() when $default != null:
return $default(_that.distanceKm,_that.driveMinutes,_that.deliveryEta,_that.suggestedAmountRange);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double distanceKm,  int driveMinutes,  DateTime deliveryEta,  Map<String, dynamic>? suggestedAmountRange)  $default,) {final _that = this;
switch (_that) {
case _LoadEstimate():
return $default(_that.distanceKm,_that.driveMinutes,_that.deliveryEta,_that.suggestedAmountRange);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double distanceKm,  int driveMinutes,  DateTime deliveryEta,  Map<String, dynamic>? suggestedAmountRange)?  $default,) {final _that = this;
switch (_that) {
case _LoadEstimate() when $default != null:
return $default(_that.distanceKm,_that.driveMinutes,_that.deliveryEta,_that.suggestedAmountRange);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LoadEstimate implements LoadEstimate {
  const _LoadEstimate({required this.distanceKm, required this.driveMinutes, required this.deliveryEta,  Map<String, dynamic>? suggestedAmountRange}): _suggestedAmountRange = suggestedAmountRange;
  factory _LoadEstimate.fromJson(Map<String, dynamic> json) => _$LoadEstimateFromJson(json);

@override final  double distanceKm;
@override final  int driveMinutes;
@override final  DateTime deliveryEta;
 final  Map<String, dynamic>? _suggestedAmountRange;
@override Map<String, dynamic>? get suggestedAmountRange {
  final value = _suggestedAmountRange;
  if (value == null) return null;
  if (_suggestedAmountRange is EqualUnmodifiableMapView) return _suggestedAmountRange;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of LoadEstimate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoadEstimateCopyWith<_LoadEstimate> get copyWith => __$LoadEstimateCopyWithImpl<_LoadEstimate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LoadEstimateToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoadEstimate&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&(identical(other.driveMinutes, driveMinutes) || other.driveMinutes == driveMinutes)&&(identical(other.deliveryEta, deliveryEta) || other.deliveryEta == deliveryEta)&&const DeepCollectionEquality().equals(other.suggestedAmountRange, _suggestedAmountRange));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,distanceKm,driveMinutes,deliveryEta,const DeepCollectionEquality().hash(_suggestedAmountRange));
}

@override
String toString() {
    return 'LoadEstimate(distanceKm: $distanceKm, driveMinutes: $driveMinutes, deliveryEta: $deliveryEta, suggestedAmountRange: $suggestedAmountRange)';
}


}

/// @nodoc
abstract mixin class _$LoadEstimateCopyWith<$Res> implements $LoadEstimateCopyWith<$Res> {
  factory _$LoadEstimateCopyWith(_LoadEstimate value, $Res Function(_LoadEstimate) _then) = __$LoadEstimateCopyWithImpl;
@override @useResult
$Res call({
 double distanceKm, int driveMinutes, DateTime deliveryEta, Map<String, dynamic>? suggestedAmountRange
});




}
/// @nodoc
class __$LoadEstimateCopyWithImpl<$Res>
    implements _$LoadEstimateCopyWith<$Res> {
  __$LoadEstimateCopyWithImpl(this._self, this._then);

  final _LoadEstimate _self;
  final $Res Function(_LoadEstimate) _then;

/// Create a copy of LoadEstimate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? distanceKm = null,Object? driveMinutes = null,Object? deliveryEta = null,Object? suggestedAmountRange = freezed,}) {
  return _then(_LoadEstimate(
distanceKm: null == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double,driveMinutes: null == driveMinutes ? _self.driveMinutes : driveMinutes // ignore: cast_nullable_to_non_nullable
as int,deliveryEta: null == deliveryEta ? _self.deliveryEta : deliveryEta // ignore: cast_nullable_to_non_nullable
as DateTime,suggestedAmountRange: freezed == suggestedAmountRange ? _self._suggestedAmountRange : suggestedAmountRange // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}


/// @nodoc
mixin _$LoadTracking {

 DriverLocation? get driverLocation; DateTime? get etaAt;@JsonKey(unknownEnumValue: RouteStatus.unknown) RouteStatus? get routeStatus;
/// Create a copy of LoadTracking
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoadTrackingCopyWith<LoadTracking> get copyWith => _$LoadTrackingCopyWithImpl<LoadTracking>(this as LoadTracking, _$identity);

  /// Serializes this LoadTracking to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LoadTracking;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoadTracking&&(identical(other.driverLocation, _this.driverLocation) || other.driverLocation == _this.driverLocation)&&(identical(other.etaAt, _this.etaAt) || other.etaAt == _this.etaAt)&&(identical(other.routeStatus, _this.routeStatus) || other.routeStatus == _this.routeStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LoadTracking;
  return Object.hash(runtimeType,_this.driverLocation,_this.etaAt,_this.routeStatus);
}

@override
String toString() {
  final _this = this as LoadTracking;
  return 'LoadTracking(driverLocation: ${_this.driverLocation}, etaAt: ${_this.etaAt}, routeStatus: ${_this.routeStatus})';
}


}

/// @nodoc
abstract mixin class $LoadTrackingCopyWith<$Res>  {
  factory $LoadTrackingCopyWith(LoadTracking value, $Res Function(LoadTracking) _then) = _$LoadTrackingCopyWithImpl;
@useResult
$Res call({
 DriverLocation? driverLocation, DateTime? etaAt,@JsonKey(unknownEnumValue: RouteStatus.unknown) RouteStatus? routeStatus
});


$DriverLocationCopyWith<$Res>? get driverLocation;

}
/// @nodoc
class _$LoadTrackingCopyWithImpl<$Res>
    implements $LoadTrackingCopyWith<$Res> {
  _$LoadTrackingCopyWithImpl(this._self, this._then);

  final LoadTracking _self;
  final $Res Function(LoadTracking) _then;

/// Create a copy of LoadTracking
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? driverLocation = freezed,Object? etaAt = freezed,Object? routeStatus = freezed,}) {
  return _then(LoadTracking(
driverLocation: freezed == driverLocation ? _self.driverLocation : driverLocation // ignore: cast_nullable_to_non_nullable
as DriverLocation?,etaAt: freezed == etaAt ? _self.etaAt : etaAt // ignore: cast_nullable_to_non_nullable
as DateTime?,routeStatus: freezed == routeStatus ? _self.routeStatus : routeStatus // ignore: cast_nullable_to_non_nullable
as RouteStatus?,
  ));
}
/// Create a copy of LoadTracking
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DriverLocationCopyWith<$Res>? get driverLocation {
    if (_self.driverLocation == null) {
    return null;
  }

  return $DriverLocationCopyWith<$Res>(_self.driverLocation!, (value) {
    return _then(_self.copyWith(driverLocation: value));
  });
}
}


/// Adds pattern-matching-related methods to [LoadTracking].
extension LoadTrackingPatterns on LoadTracking {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoadTracking value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoadTracking() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoadTracking value)  $default,){
final _that = this;
switch (_that) {
case _LoadTracking():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoadTracking value)?  $default,){
final _that = this;
switch (_that) {
case _LoadTracking() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DriverLocation? driverLocation,  DateTime? etaAt, @JsonKey(unknownEnumValue: RouteStatus.unknown)  RouteStatus? routeStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoadTracking() when $default != null:
return $default(_that.driverLocation,_that.etaAt,_that.routeStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DriverLocation? driverLocation,  DateTime? etaAt, @JsonKey(unknownEnumValue: RouteStatus.unknown)  RouteStatus? routeStatus)  $default,) {final _that = this;
switch (_that) {
case _LoadTracking():
return $default(_that.driverLocation,_that.etaAt,_that.routeStatus);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DriverLocation? driverLocation,  DateTime? etaAt, @JsonKey(unknownEnumValue: RouteStatus.unknown)  RouteStatus? routeStatus)?  $default,) {final _that = this;
switch (_that) {
case _LoadTracking() when $default != null:
return $default(_that.driverLocation,_that.etaAt,_that.routeStatus);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LoadTracking implements LoadTracking {
  const _LoadTracking({this.driverLocation, this.etaAt, @JsonKey(unknownEnumValue: RouteStatus.unknown) this.routeStatus});
  factory _LoadTracking.fromJson(Map<String, dynamic> json) => _$LoadTrackingFromJson(json);

@override final  DriverLocation? driverLocation;
@override final  DateTime? etaAt;
@override@JsonKey(unknownEnumValue: RouteStatus.unknown) final  RouteStatus? routeStatus;

/// Create a copy of LoadTracking
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoadTrackingCopyWith<_LoadTracking> get copyWith => __$LoadTrackingCopyWithImpl<_LoadTracking>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LoadTrackingToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoadTracking&&(identical(other.driverLocation, driverLocation) || other.driverLocation == driverLocation)&&(identical(other.etaAt, etaAt) || other.etaAt == etaAt)&&(identical(other.routeStatus, routeStatus) || other.routeStatus == routeStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,driverLocation,etaAt,routeStatus);
}

@override
String toString() {
    return 'LoadTracking(driverLocation: $driverLocation, etaAt: $etaAt, routeStatus: $routeStatus)';
}


}

/// @nodoc
abstract mixin class _$LoadTrackingCopyWith<$Res> implements $LoadTrackingCopyWith<$Res> {
  factory _$LoadTrackingCopyWith(_LoadTracking value, $Res Function(_LoadTracking) _then) = __$LoadTrackingCopyWithImpl;
@override @useResult
$Res call({
 DriverLocation? driverLocation, DateTime? etaAt,@JsonKey(unknownEnumValue: RouteStatus.unknown) RouteStatus? routeStatus
});


@override $DriverLocationCopyWith<$Res>? get driverLocation;

}
/// @nodoc
class __$LoadTrackingCopyWithImpl<$Res>
    implements _$LoadTrackingCopyWith<$Res> {
  __$LoadTrackingCopyWithImpl(this._self, this._then);

  final _LoadTracking _self;
  final $Res Function(_LoadTracking) _then;

/// Create a copy of LoadTracking
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? driverLocation = freezed,Object? etaAt = freezed,Object? routeStatus = freezed,}) {
  return _then(_LoadTracking(
driverLocation: freezed == driverLocation ? _self.driverLocation : driverLocation // ignore: cast_nullable_to_non_nullable
as DriverLocation?,etaAt: freezed == etaAt ? _self.etaAt : etaAt // ignore: cast_nullable_to_non_nullable
as DateTime?,routeStatus: freezed == routeStatus ? _self.routeStatus : routeStatus // ignore: cast_nullable_to_non_nullable
as RouteStatus?,
  ));
}

/// Create a copy of LoadTracking
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DriverLocationCopyWith<$Res>? get driverLocation {
    if (_self.driverLocation == null) {
    return null;
  }

  return $DriverLocationCopyWith<$Res>(_self.driverLocation!, (value) {
    return _then(_self.copyWith(driverLocation: value));
  });
}
}


/// @nodoc
mixin _$DriverLocation {

 double get lat; double get lng; DateTime get at;
/// Create a copy of DriverLocation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DriverLocationCopyWith<DriverLocation> get copyWith => _$DriverLocationCopyWithImpl<DriverLocation>(this as DriverLocation, _$identity);

  /// Serializes this DriverLocation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DriverLocation;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriverLocation&&(identical(other.lat, _this.lat) || other.lat == _this.lat)&&(identical(other.lng, _this.lng) || other.lng == _this.lng)&&(identical(other.at, _this.at) || other.at == _this.at));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DriverLocation;
  return Object.hash(runtimeType,_this.lat,_this.lng,_this.at);
}

@override
String toString() {
  final _this = this as DriverLocation;
  return 'DriverLocation(lat: ${_this.lat}, lng: ${_this.lng}, at: ${_this.at})';
}


}

/// @nodoc
abstract mixin class $DriverLocationCopyWith<$Res>  {
  factory $DriverLocationCopyWith(DriverLocation value, $Res Function(DriverLocation) _then) = _$DriverLocationCopyWithImpl;
@useResult
$Res call({
 double lat, double lng, DateTime at
});




}
/// @nodoc
class _$DriverLocationCopyWithImpl<$Res>
    implements $DriverLocationCopyWith<$Res> {
  _$DriverLocationCopyWithImpl(this._self, this._then);

  final DriverLocation _self;
  final $Res Function(DriverLocation) _then;

/// Create a copy of DriverLocation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lat = null,Object? lng = null,Object? at = null,}) {
  return _then(DriverLocation(
lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double,lng: null == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double,at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [DriverLocation].
extension DriverLocationPatterns on DriverLocation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DriverLocation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DriverLocation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DriverLocation value)  $default,){
final _that = this;
switch (_that) {
case _DriverLocation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DriverLocation value)?  $default,){
final _that = this;
switch (_that) {
case _DriverLocation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double lat,  double lng,  DateTime at)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DriverLocation() when $default != null:
return $default(_that.lat,_that.lng,_that.at);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double lat,  double lng,  DateTime at)  $default,) {final _that = this;
switch (_that) {
case _DriverLocation():
return $default(_that.lat,_that.lng,_that.at);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double lat,  double lng,  DateTime at)?  $default,) {final _that = this;
switch (_that) {
case _DriverLocation() when $default != null:
return $default(_that.lat,_that.lng,_that.at);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DriverLocation implements DriverLocation {
  const _DriverLocation({required this.lat, required this.lng, required this.at});
  factory _DriverLocation.fromJson(Map<String, dynamic> json) => _$DriverLocationFromJson(json);

@override final  double lat;
@override final  double lng;
@override final  DateTime at;

/// Create a copy of DriverLocation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DriverLocationCopyWith<_DriverLocation> get copyWith => __$DriverLocationCopyWithImpl<_DriverLocation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DriverLocationToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DriverLocation&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng)&&(identical(other.at, at) || other.at == at));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,lat,lng,at);
}

@override
String toString() {
    return 'DriverLocation(lat: $lat, lng: $lng, at: $at)';
}


}

/// @nodoc
abstract mixin class _$DriverLocationCopyWith<$Res> implements $DriverLocationCopyWith<$Res> {
  factory _$DriverLocationCopyWith(_DriverLocation value, $Res Function(_DriverLocation) _then) = __$DriverLocationCopyWithImpl;
@override @useResult
$Res call({
 double lat, double lng, DateTime at
});




}
/// @nodoc
class __$DriverLocationCopyWithImpl<$Res>
    implements _$DriverLocationCopyWith<$Res> {
  __$DriverLocationCopyWithImpl(this._self, this._then);

  final _DriverLocation _self;
  final $Res Function(_DriverLocation) _then;

/// Create a copy of DriverLocation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lat = null,Object? lng = null,Object? at = null,}) {
  return _then(_DriverLocation(
lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double,lng: null == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double,at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$OtpView {

@JsonKey(unknownEnumValue: OtpPurpose.unknown) OtpPurpose get purpose; String get code; DateTime get expiresAt;
/// Create a copy of OtpView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OtpViewCopyWith<OtpView> get copyWith => _$OtpViewCopyWithImpl<OtpView>(this as OtpView, _$identity);

  /// Serializes this OtpView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as OtpView;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OtpView&&(identical(other.purpose, _this.purpose) || other.purpose == _this.purpose)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as OtpView;
  return Object.hash(runtimeType,_this.purpose,_this.code,_this.expiresAt);
}

@override
String toString() {
  final _this = this as OtpView;
  return 'OtpView(purpose: ${_this.purpose}, code: ${_this.code}, expiresAt: ${_this.expiresAt})';
}


}

/// @nodoc
abstract mixin class $OtpViewCopyWith<$Res>  {
  factory $OtpViewCopyWith(OtpView value, $Res Function(OtpView) _then) = _$OtpViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(unknownEnumValue: OtpPurpose.unknown) OtpPurpose purpose, String code, DateTime expiresAt
});




}
/// @nodoc
class _$OtpViewCopyWithImpl<$Res>
    implements $OtpViewCopyWith<$Res> {
  _$OtpViewCopyWithImpl(this._self, this._then);

  final OtpView _self;
  final $Res Function(OtpView) _then;

/// Create a copy of OtpView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? purpose = null,Object? code = null,Object? expiresAt = null,}) {
  return _then(OtpView(
purpose: null == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as OtpPurpose,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [OtpView].
extension OtpViewPatterns on OtpView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OtpView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OtpView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OtpView value)  $default,){
final _that = this;
switch (_that) {
case _OtpView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OtpView value)?  $default,){
final _that = this;
switch (_that) {
case _OtpView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: OtpPurpose.unknown)  OtpPurpose purpose,  String code,  DateTime expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OtpView() when $default != null:
return $default(_that.purpose,_that.code,_that.expiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: OtpPurpose.unknown)  OtpPurpose purpose,  String code,  DateTime expiresAt)  $default,) {final _that = this;
switch (_that) {
case _OtpView():
return $default(_that.purpose,_that.code,_that.expiresAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(unknownEnumValue: OtpPurpose.unknown)  OtpPurpose purpose,  String code,  DateTime expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _OtpView() when $default != null:
return $default(_that.purpose,_that.code,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OtpView implements OtpView {
  const _OtpView({@JsonKey(unknownEnumValue: OtpPurpose.unknown) required this.purpose, required this.code, required this.expiresAt});
  factory _OtpView.fromJson(Map<String, dynamic> json) => _$OtpViewFromJson(json);

@override@JsonKey(unknownEnumValue: OtpPurpose.unknown) final  OtpPurpose purpose;
@override final  String code;
@override final  DateTime expiresAt;

/// Create a copy of OtpView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OtpViewCopyWith<_OtpView> get copyWith => __$OtpViewCopyWithImpl<_OtpView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OtpViewToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OtpView&&(identical(other.purpose, purpose) || other.purpose == purpose)&&(identical(other.code, code) || other.code == code)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,purpose,code,expiresAt);
}

@override
String toString() {
    return 'OtpView(purpose: $purpose, code: $code, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class _$OtpViewCopyWith<$Res> implements $OtpViewCopyWith<$Res> {
  factory _$OtpViewCopyWith(_OtpView value, $Res Function(_OtpView) _then) = __$OtpViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(unknownEnumValue: OtpPurpose.unknown) OtpPurpose purpose, String code, DateTime expiresAt
});




}
/// @nodoc
class __$OtpViewCopyWithImpl<$Res>
    implements _$OtpViewCopyWith<$Res> {
  __$OtpViewCopyWithImpl(this._self, this._then);

  final _OtpView _self;
  final $Res Function(_OtpView) _then;

/// Create a copy of OtpView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? purpose = null,Object? code = null,Object? expiresAt = null,}) {
  return _then(_OtpView(
purpose: null == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as OtpPurpose,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$Suggestion {

 String get loadId; String get goodsType; String? get description; num get quantity;@JsonKey(unknownEnumValue: QuantityUnit.unknown) QuantityUnit get unit; num get weightTonnes; String get pickupArea; String get dropArea; DateTime get pickupWindowStart; double get distanceToPickupKm; int get minutesToPickup; DateTime? get deliveryEta; int get amountInr; double get shipperTrustScore; bool get preferredByShipper;
/// Create a copy of Suggestion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SuggestionCopyWith<Suggestion> get copyWith => _$SuggestionCopyWithImpl<Suggestion>(this as Suggestion, _$identity);

  /// Serializes this Suggestion to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Suggestion;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Suggestion&&(identical(other.loadId, _this.loadId) || other.loadId == _this.loadId)&&(identical(other.goodsType, _this.goodsType) || other.goodsType == _this.goodsType)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.quantity, _this.quantity) || other.quantity == _this.quantity)&&(identical(other.unit, _this.unit) || other.unit == _this.unit)&&(identical(other.weightTonnes, _this.weightTonnes) || other.weightTonnes == _this.weightTonnes)&&(identical(other.pickupArea, _this.pickupArea) || other.pickupArea == _this.pickupArea)&&(identical(other.dropArea, _this.dropArea) || other.dropArea == _this.dropArea)&&(identical(other.pickupWindowStart, _this.pickupWindowStart) || other.pickupWindowStart == _this.pickupWindowStart)&&(identical(other.distanceToPickupKm, _this.distanceToPickupKm) || other.distanceToPickupKm == _this.distanceToPickupKm)&&(identical(other.minutesToPickup, _this.minutesToPickup) || other.minutesToPickup == _this.minutesToPickup)&&(identical(other.deliveryEta, _this.deliveryEta) || other.deliveryEta == _this.deliveryEta)&&(identical(other.amountInr, _this.amountInr) || other.amountInr == _this.amountInr)&&(identical(other.shipperTrustScore, _this.shipperTrustScore) || other.shipperTrustScore == _this.shipperTrustScore)&&(identical(other.preferredByShipper, _this.preferredByShipper) || other.preferredByShipper == _this.preferredByShipper));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Suggestion;
  return Object.hash(runtimeType,_this.loadId,_this.goodsType,_this.description,_this.quantity,_this.unit,_this.weightTonnes,_this.pickupArea,_this.dropArea,_this.pickupWindowStart,_this.distanceToPickupKm,_this.minutesToPickup,_this.deliveryEta,_this.amountInr,_this.shipperTrustScore,_this.preferredByShipper);
}

@override
String toString() {
  final _this = this as Suggestion;
  return 'Suggestion(loadId: ${_this.loadId}, goodsType: ${_this.goodsType}, description: ${_this.description}, quantity: ${_this.quantity}, unit: ${_this.unit}, weightTonnes: ${_this.weightTonnes}, pickupArea: ${_this.pickupArea}, dropArea: ${_this.dropArea}, pickupWindowStart: ${_this.pickupWindowStart}, distanceToPickupKm: ${_this.distanceToPickupKm}, minutesToPickup: ${_this.minutesToPickup}, deliveryEta: ${_this.deliveryEta}, amountInr: ${_this.amountInr}, shipperTrustScore: ${_this.shipperTrustScore}, preferredByShipper: ${_this.preferredByShipper})';
}


}

/// @nodoc
abstract mixin class $SuggestionCopyWith<$Res>  {
  factory $SuggestionCopyWith(Suggestion value, $Res Function(Suggestion) _then) = _$SuggestionCopyWithImpl;
@useResult
$Res call({
 String loadId, String goodsType, String? description, num quantity,@JsonKey(unknownEnumValue: QuantityUnit.unknown) QuantityUnit unit, num weightTonnes, String pickupArea, String dropArea, DateTime pickupWindowStart, double distanceToPickupKm, int minutesToPickup, DateTime? deliveryEta, int amountInr, double shipperTrustScore, bool preferredByShipper
});




}
/// @nodoc
class _$SuggestionCopyWithImpl<$Res>
    implements $SuggestionCopyWith<$Res> {
  _$SuggestionCopyWithImpl(this._self, this._then);

  final Suggestion _self;
  final $Res Function(Suggestion) _then;

/// Create a copy of Suggestion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? loadId = null,Object? goodsType = null,Object? description = freezed,Object? quantity = null,Object? unit = null,Object? weightTonnes = null,Object? pickupArea = null,Object? dropArea = null,Object? pickupWindowStart = null,Object? distanceToPickupKm = null,Object? minutesToPickup = null,Object? deliveryEta = freezed,Object? amountInr = null,Object? shipperTrustScore = null,Object? preferredByShipper = null,}) {
  return _then(Suggestion(
loadId: null == loadId ? _self.loadId : loadId // ignore: cast_nullable_to_non_nullable
as String,goodsType: null == goodsType ? _self.goodsType : goodsType // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as num,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as QuantityUnit,weightTonnes: null == weightTonnes ? _self.weightTonnes : weightTonnes // ignore: cast_nullable_to_non_nullable
as num,pickupArea: null == pickupArea ? _self.pickupArea : pickupArea // ignore: cast_nullable_to_non_nullable
as String,dropArea: null == dropArea ? _self.dropArea : dropArea // ignore: cast_nullable_to_non_nullable
as String,pickupWindowStart: null == pickupWindowStart ? _self.pickupWindowStart : pickupWindowStart // ignore: cast_nullable_to_non_nullable
as DateTime,distanceToPickupKm: null == distanceToPickupKm ? _self.distanceToPickupKm : distanceToPickupKm // ignore: cast_nullable_to_non_nullable
as double,minutesToPickup: null == minutesToPickup ? _self.minutesToPickup : minutesToPickup // ignore: cast_nullable_to_non_nullable
as int,deliveryEta: freezed == deliveryEta ? _self.deliveryEta : deliveryEta // ignore: cast_nullable_to_non_nullable
as DateTime?,amountInr: null == amountInr ? _self.amountInr : amountInr // ignore: cast_nullable_to_non_nullable
as int,shipperTrustScore: null == shipperTrustScore ? _self.shipperTrustScore : shipperTrustScore // ignore: cast_nullable_to_non_nullable
as double,preferredByShipper: null == preferredByShipper ? _self.preferredByShipper : preferredByShipper // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Suggestion].
extension SuggestionPatterns on Suggestion {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Suggestion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Suggestion() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Suggestion value)  $default,){
final _that = this;
switch (_that) {
case _Suggestion():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Suggestion value)?  $default,){
final _that = this;
switch (_that) {
case _Suggestion() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String loadId,  String goodsType,  String? description,  num quantity, @JsonKey(unknownEnumValue: QuantityUnit.unknown)  QuantityUnit unit,  num weightTonnes,  String pickupArea,  String dropArea,  DateTime pickupWindowStart,  double distanceToPickupKm,  int minutesToPickup,  DateTime? deliveryEta,  int amountInr,  double shipperTrustScore,  bool preferredByShipper)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Suggestion() when $default != null:
return $default(_that.loadId,_that.goodsType,_that.description,_that.quantity,_that.unit,_that.weightTonnes,_that.pickupArea,_that.dropArea,_that.pickupWindowStart,_that.distanceToPickupKm,_that.minutesToPickup,_that.deliveryEta,_that.amountInr,_that.shipperTrustScore,_that.preferredByShipper);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String loadId,  String goodsType,  String? description,  num quantity, @JsonKey(unknownEnumValue: QuantityUnit.unknown)  QuantityUnit unit,  num weightTonnes,  String pickupArea,  String dropArea,  DateTime pickupWindowStart,  double distanceToPickupKm,  int minutesToPickup,  DateTime? deliveryEta,  int amountInr,  double shipperTrustScore,  bool preferredByShipper)  $default,) {final _that = this;
switch (_that) {
case _Suggestion():
return $default(_that.loadId,_that.goodsType,_that.description,_that.quantity,_that.unit,_that.weightTonnes,_that.pickupArea,_that.dropArea,_that.pickupWindowStart,_that.distanceToPickupKm,_that.minutesToPickup,_that.deliveryEta,_that.amountInr,_that.shipperTrustScore,_that.preferredByShipper);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String loadId,  String goodsType,  String? description,  num quantity, @JsonKey(unknownEnumValue: QuantityUnit.unknown)  QuantityUnit unit,  num weightTonnes,  String pickupArea,  String dropArea,  DateTime pickupWindowStart,  double distanceToPickupKm,  int minutesToPickup,  DateTime? deliveryEta,  int amountInr,  double shipperTrustScore,  bool preferredByShipper)?  $default,) {final _that = this;
switch (_that) {
case _Suggestion() when $default != null:
return $default(_that.loadId,_that.goodsType,_that.description,_that.quantity,_that.unit,_that.weightTonnes,_that.pickupArea,_that.dropArea,_that.pickupWindowStart,_that.distanceToPickupKm,_that.minutesToPickup,_that.deliveryEta,_that.amountInr,_that.shipperTrustScore,_that.preferredByShipper);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Suggestion implements Suggestion {
  const _Suggestion({required this.loadId, required this.goodsType, this.description, required this.quantity, @JsonKey(unknownEnumValue: QuantityUnit.unknown) required this.unit, required this.weightTonnes, required this.pickupArea, required this.dropArea, required this.pickupWindowStart, required this.distanceToPickupKm, required this.minutesToPickup, this.deliveryEta, required this.amountInr, required this.shipperTrustScore, this.preferredByShipper = false});
  factory _Suggestion.fromJson(Map<String, dynamic> json) => _$SuggestionFromJson(json);

@override final  String loadId;
@override final  String goodsType;
@override final  String? description;
@override final  num quantity;
@override@JsonKey(unknownEnumValue: QuantityUnit.unknown) final  QuantityUnit unit;
@override final  num weightTonnes;
@override final  String pickupArea;
@override final  String dropArea;
@override final  DateTime pickupWindowStart;
@override final  double distanceToPickupKm;
@override final  int minutesToPickup;
@override final  DateTime? deliveryEta;
@override final  int amountInr;
@override final  double shipperTrustScore;
@override@JsonKey() final  bool preferredByShipper;

/// Create a copy of Suggestion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SuggestionCopyWith<_Suggestion> get copyWith => __$SuggestionCopyWithImpl<_Suggestion>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SuggestionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Suggestion&&(identical(other.loadId, loadId) || other.loadId == loadId)&&(identical(other.goodsType, goodsType) || other.goodsType == goodsType)&&(identical(other.description, description) || other.description == description)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.weightTonnes, weightTonnes) || other.weightTonnes == weightTonnes)&&(identical(other.pickupArea, pickupArea) || other.pickupArea == pickupArea)&&(identical(other.dropArea, dropArea) || other.dropArea == dropArea)&&(identical(other.pickupWindowStart, pickupWindowStart) || other.pickupWindowStart == pickupWindowStart)&&(identical(other.distanceToPickupKm, distanceToPickupKm) || other.distanceToPickupKm == distanceToPickupKm)&&(identical(other.minutesToPickup, minutesToPickup) || other.minutesToPickup == minutesToPickup)&&(identical(other.deliveryEta, deliveryEta) || other.deliveryEta == deliveryEta)&&(identical(other.amountInr, amountInr) || other.amountInr == amountInr)&&(identical(other.shipperTrustScore, shipperTrustScore) || other.shipperTrustScore == shipperTrustScore)&&(identical(other.preferredByShipper, preferredByShipper) || other.preferredByShipper == preferredByShipper));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,loadId,goodsType,description,quantity,unit,weightTonnes,pickupArea,dropArea,pickupWindowStart,distanceToPickupKm,minutesToPickup,deliveryEta,amountInr,shipperTrustScore,preferredByShipper);
}

@override
String toString() {
    return 'Suggestion(loadId: $loadId, goodsType: $goodsType, description: $description, quantity: $quantity, unit: $unit, weightTonnes: $weightTonnes, pickupArea: $pickupArea, dropArea: $dropArea, pickupWindowStart: $pickupWindowStart, distanceToPickupKm: $distanceToPickupKm, minutesToPickup: $minutesToPickup, deliveryEta: $deliveryEta, amountInr: $amountInr, shipperTrustScore: $shipperTrustScore, preferredByShipper: $preferredByShipper)';
}


}

/// @nodoc
abstract mixin class _$SuggestionCopyWith<$Res> implements $SuggestionCopyWith<$Res> {
  factory _$SuggestionCopyWith(_Suggestion value, $Res Function(_Suggestion) _then) = __$SuggestionCopyWithImpl;
@override @useResult
$Res call({
 String loadId, String goodsType, String? description, num quantity,@JsonKey(unknownEnumValue: QuantityUnit.unknown) QuantityUnit unit, num weightTonnes, String pickupArea, String dropArea, DateTime pickupWindowStart, double distanceToPickupKm, int minutesToPickup, DateTime? deliveryEta, int amountInr, double shipperTrustScore, bool preferredByShipper
});




}
/// @nodoc
class __$SuggestionCopyWithImpl<$Res>
    implements _$SuggestionCopyWith<$Res> {
  __$SuggestionCopyWithImpl(this._self, this._then);

  final _Suggestion _self;
  final $Res Function(_Suggestion) _then;

/// Create a copy of Suggestion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? loadId = null,Object? goodsType = null,Object? description = freezed,Object? quantity = null,Object? unit = null,Object? weightTonnes = null,Object? pickupArea = null,Object? dropArea = null,Object? pickupWindowStart = null,Object? distanceToPickupKm = null,Object? minutesToPickup = null,Object? deliveryEta = freezed,Object? amountInr = null,Object? shipperTrustScore = null,Object? preferredByShipper = null,}) {
  return _then(_Suggestion(
loadId: null == loadId ? _self.loadId : loadId // ignore: cast_nullable_to_non_nullable
as String,goodsType: null == goodsType ? _self.goodsType : goodsType // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as num,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as QuantityUnit,weightTonnes: null == weightTonnes ? _self.weightTonnes : weightTonnes // ignore: cast_nullable_to_non_nullable
as num,pickupArea: null == pickupArea ? _self.pickupArea : pickupArea // ignore: cast_nullable_to_non_nullable
as String,dropArea: null == dropArea ? _self.dropArea : dropArea // ignore: cast_nullable_to_non_nullable
as String,pickupWindowStart: null == pickupWindowStart ? _self.pickupWindowStart : pickupWindowStart // ignore: cast_nullable_to_non_nullable
as DateTime,distanceToPickupKm: null == distanceToPickupKm ? _self.distanceToPickupKm : distanceToPickupKm // ignore: cast_nullable_to_non_nullable
as double,minutesToPickup: null == minutesToPickup ? _self.minutesToPickup : minutesToPickup // ignore: cast_nullable_to_non_nullable
as int,deliveryEta: freezed == deliveryEta ? _self.deliveryEta : deliveryEta // ignore: cast_nullable_to_non_nullable
as DateTime?,amountInr: null == amountInr ? _self.amountInr : amountInr // ignore: cast_nullable_to_non_nullable
as int,shipperTrustScore: null == shipperTrustScore ? _self.shipperTrustScore : shipperTrustScore // ignore: cast_nullable_to_non_nullable
as double,preferredByShipper: null == preferredByShipper ? _self.preferredByShipper : preferredByShipper // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
