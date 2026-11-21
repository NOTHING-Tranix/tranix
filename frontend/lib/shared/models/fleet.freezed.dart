// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fleet.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Truck {

 String get id; String get number;@JsonKey(unknownEnumValue: VehicleType.unknown) VehicleType get vehicleType; num get capacityTonnes;@JsonKey(unknownEnumValue: TruckStatus.unknown) TruckStatus get status; List<Document> get documents; Map<String, dynamic>? get allocatedDriver; bool get ownedByMe;
/// Create a copy of Truck
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TruckCopyWith<Truck> get copyWith => _$TruckCopyWithImpl<Truck>(this as Truck, _$identity);

  /// Serializes this Truck to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Truck;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Truck&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.number, _this.number) || other.number == _this.number)&&(identical(other.vehicleType, _this.vehicleType) || other.vehicleType == _this.vehicleType)&&(identical(other.capacityTonnes, _this.capacityTonnes) || other.capacityTonnes == _this.capacityTonnes)&&(identical(other.status, _this.status) || other.status == _this.status)&&const DeepCollectionEquality().equals(other.documents, _this.documents)&&const DeepCollectionEquality().equals(other.allocatedDriver, _this.allocatedDriver)&&(identical(other.ownedByMe, _this.ownedByMe) || other.ownedByMe == _this.ownedByMe));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Truck;
  return Object.hash(runtimeType,_this.id,_this.number,_this.vehicleType,_this.capacityTonnes,_this.status,const DeepCollectionEquality().hash(_this.documents),const DeepCollectionEquality().hash(_this.allocatedDriver),_this.ownedByMe);
}

@override
String toString() {
  final _this = this as Truck;
  return 'Truck(id: ${_this.id}, number: ${_this.number}, vehicleType: ${_this.vehicleType}, capacityTonnes: ${_this.capacityTonnes}, status: ${_this.status}, documents: ${_this.documents}, allocatedDriver: ${_this.allocatedDriver}, ownedByMe: ${_this.ownedByMe})';
}


}

/// @nodoc
abstract mixin class $TruckCopyWith<$Res>  {
  factory $TruckCopyWith(Truck value, $Res Function(Truck) _then) = _$TruckCopyWithImpl;
@useResult
$Res call({
 String id, String number,@JsonKey(unknownEnumValue: VehicleType.unknown) VehicleType vehicleType, num capacityTonnes,@JsonKey(unknownEnumValue: TruckStatus.unknown) TruckStatus status, List<Document> documents, Map<String, dynamic>? allocatedDriver, bool ownedByMe
});




}
/// @nodoc
class _$TruckCopyWithImpl<$Res>
    implements $TruckCopyWith<$Res> {
  _$TruckCopyWithImpl(this._self, this._then);

  final Truck _self;
  final $Res Function(Truck) _then;

/// Create a copy of Truck
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? number = null,Object? vehicleType = null,Object? capacityTonnes = null,Object? status = null,Object? documents = null,Object? allocatedDriver = freezed,Object? ownedByMe = null,}) {
  return _then(Truck(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String,vehicleType: null == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as VehicleType,capacityTonnes: null == capacityTonnes ? _self.capacityTonnes : capacityTonnes // ignore: cast_nullable_to_non_nullable
as num,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TruckStatus,documents: null == documents ? _self.documents : documents // ignore: cast_nullable_to_non_nullable
as List<Document>,allocatedDriver: freezed == allocatedDriver ? _self.allocatedDriver : allocatedDriver // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,ownedByMe: null == ownedByMe ? _self.ownedByMe : ownedByMe // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Truck].
extension TruckPatterns on Truck {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Truck value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Truck() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Truck value)  $default,){
final _that = this;
switch (_that) {
case _Truck():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Truck value)?  $default,){
final _that = this;
switch (_that) {
case _Truck() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String number, @JsonKey(unknownEnumValue: VehicleType.unknown)  VehicleType vehicleType,  num capacityTonnes, @JsonKey(unknownEnumValue: TruckStatus.unknown)  TruckStatus status,  List<Document> documents,  Map<String, dynamic>? allocatedDriver,  bool ownedByMe)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Truck() when $default != null:
return $default(_that.id,_that.number,_that.vehicleType,_that.capacityTonnes,_that.status,_that.documents,_that.allocatedDriver,_that.ownedByMe);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String number, @JsonKey(unknownEnumValue: VehicleType.unknown)  VehicleType vehicleType,  num capacityTonnes, @JsonKey(unknownEnumValue: TruckStatus.unknown)  TruckStatus status,  List<Document> documents,  Map<String, dynamic>? allocatedDriver,  bool ownedByMe)  $default,) {final _that = this;
switch (_that) {
case _Truck():
return $default(_that.id,_that.number,_that.vehicleType,_that.capacityTonnes,_that.status,_that.documents,_that.allocatedDriver,_that.ownedByMe);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String number, @JsonKey(unknownEnumValue: VehicleType.unknown)  VehicleType vehicleType,  num capacityTonnes, @JsonKey(unknownEnumValue: TruckStatus.unknown)  TruckStatus status,  List<Document> documents,  Map<String, dynamic>? allocatedDriver,  bool ownedByMe)?  $default,) {final _that = this;
switch (_that) {
case _Truck() when $default != null:
return $default(_that.id,_that.number,_that.vehicleType,_that.capacityTonnes,_that.status,_that.documents,_that.allocatedDriver,_that.ownedByMe);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Truck implements Truck {
  const _Truck({required this.id, required this.number, @JsonKey(unknownEnumValue: VehicleType.unknown) required this.vehicleType, required this.capacityTonnes, @JsonKey(unknownEnumValue: TruckStatus.unknown) required this.status,  List<Document> documents = const <Document>[],  Map<String, dynamic>? allocatedDriver, this.ownedByMe = true}): _documents = documents,_allocatedDriver = allocatedDriver;
  factory _Truck.fromJson(Map<String, dynamic> json) => _$TruckFromJson(json);

@override final  String id;
@override final  String number;
@override@JsonKey(unknownEnumValue: VehicleType.unknown) final  VehicleType vehicleType;
@override final  num capacityTonnes;
@override@JsonKey(unknownEnumValue: TruckStatus.unknown) final  TruckStatus status;
 final  List<Document> _documents;
@override@JsonKey() List<Document> get documents {
  if (_documents is EqualUnmodifiableListView) return _documents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_documents);
}

 final  Map<String, dynamic>? _allocatedDriver;
@override Map<String, dynamic>? get allocatedDriver {
  final value = _allocatedDriver;
  if (value == null) return null;
  if (_allocatedDriver is EqualUnmodifiableMapView) return _allocatedDriver;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@JsonKey() final  bool ownedByMe;

/// Create a copy of Truck
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TruckCopyWith<_Truck> get copyWith => __$TruckCopyWithImpl<_Truck>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TruckToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Truck&&(identical(other.id, id) || other.id == id)&&(identical(other.number, number) || other.number == number)&&(identical(other.vehicleType, vehicleType) || other.vehicleType == vehicleType)&&(identical(other.capacityTonnes, capacityTonnes) || other.capacityTonnes == capacityTonnes)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.documents, _documents)&&const DeepCollectionEquality().equals(other.allocatedDriver, _allocatedDriver)&&(identical(other.ownedByMe, ownedByMe) || other.ownedByMe == ownedByMe));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,number,vehicleType,capacityTonnes,status,const DeepCollectionEquality().hash(_documents),const DeepCollectionEquality().hash(_allocatedDriver),ownedByMe);
}

@override
String toString() {
    return 'Truck(id: $id, number: $number, vehicleType: $vehicleType, capacityTonnes: $capacityTonnes, status: $status, documents: $documents, allocatedDriver: $allocatedDriver, ownedByMe: $ownedByMe)';
}


}

/// @nodoc
abstract mixin class _$TruckCopyWith<$Res> implements $TruckCopyWith<$Res> {
  factory _$TruckCopyWith(_Truck value, $Res Function(_Truck) _then) = __$TruckCopyWithImpl;
@override @useResult
$Res call({
 String id, String number,@JsonKey(unknownEnumValue: VehicleType.unknown) VehicleType vehicleType, num capacityTonnes,@JsonKey(unknownEnumValue: TruckStatus.unknown) TruckStatus status, List<Document> documents, Map<String, dynamic>? allocatedDriver, bool ownedByMe
});




}
/// @nodoc
class __$TruckCopyWithImpl<$Res>
    implements _$TruckCopyWith<$Res> {
  __$TruckCopyWithImpl(this._self, this._then);

  final _Truck _self;
  final $Res Function(_Truck) _then;

/// Create a copy of Truck
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? number = null,Object? vehicleType = null,Object? capacityTonnes = null,Object? status = null,Object? documents = null,Object? allocatedDriver = freezed,Object? ownedByMe = null,}) {
  return _then(_Truck(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String,vehicleType: null == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as VehicleType,capacityTonnes: null == capacityTonnes ? _self.capacityTonnes : capacityTonnes // ignore: cast_nullable_to_non_nullable
as num,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TruckStatus,documents: null == documents ? _self._documents : documents // ignore: cast_nullable_to_non_nullable
as List<Document>,allocatedDriver: freezed == allocatedDriver ? _self._allocatedDriver : allocatedDriver // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,ownedByMe: null == ownedByMe ? _self.ownedByMe : ownedByMe // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$DriverHome {

 bool get onDuty; Truck? get truck; int? get walletBalanceInr; String? get orgName; String? get currentLoadId; int get suggestionsCount; double get trustScore; List<Document> get expiringDocuments;
/// Create a copy of DriverHome
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DriverHomeCopyWith<DriverHome> get copyWith => _$DriverHomeCopyWithImpl<DriverHome>(this as DriverHome, _$identity);

  /// Serializes this DriverHome to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DriverHome;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriverHome&&(identical(other.onDuty, _this.onDuty) || other.onDuty == _this.onDuty)&&(identical(other.truck, _this.truck) || other.truck == _this.truck)&&(identical(other.walletBalanceInr, _this.walletBalanceInr) || other.walletBalanceInr == _this.walletBalanceInr)&&(identical(other.orgName, _this.orgName) || other.orgName == _this.orgName)&&(identical(other.currentLoadId, _this.currentLoadId) || other.currentLoadId == _this.currentLoadId)&&(identical(other.suggestionsCount, _this.suggestionsCount) || other.suggestionsCount == _this.suggestionsCount)&&(identical(other.trustScore, _this.trustScore) || other.trustScore == _this.trustScore)&&const DeepCollectionEquality().equals(other.expiringDocuments, _this.expiringDocuments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DriverHome;
  return Object.hash(runtimeType,_this.onDuty,_this.truck,_this.walletBalanceInr,_this.orgName,_this.currentLoadId,_this.suggestionsCount,_this.trustScore,const DeepCollectionEquality().hash(_this.expiringDocuments));
}

@override
String toString() {
  final _this = this as DriverHome;
  return 'DriverHome(onDuty: ${_this.onDuty}, truck: ${_this.truck}, walletBalanceInr: ${_this.walletBalanceInr}, orgName: ${_this.orgName}, currentLoadId: ${_this.currentLoadId}, suggestionsCount: ${_this.suggestionsCount}, trustScore: ${_this.trustScore}, expiringDocuments: ${_this.expiringDocuments})';
}


}

/// @nodoc
abstract mixin class $DriverHomeCopyWith<$Res>  {
  factory $DriverHomeCopyWith(DriverHome value, $Res Function(DriverHome) _then) = _$DriverHomeCopyWithImpl;
@useResult
$Res call({
 bool onDuty, Truck? truck, int? walletBalanceInr, String? orgName, String? currentLoadId, int suggestionsCount, double trustScore, List<Document> expiringDocuments
});


$TruckCopyWith<$Res>? get truck;

}
/// @nodoc
class _$DriverHomeCopyWithImpl<$Res>
    implements $DriverHomeCopyWith<$Res> {
  _$DriverHomeCopyWithImpl(this._self, this._then);

  final DriverHome _self;
  final $Res Function(DriverHome) _then;

/// Create a copy of DriverHome
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? onDuty = null,Object? truck = freezed,Object? walletBalanceInr = freezed,Object? orgName = freezed,Object? currentLoadId = freezed,Object? suggestionsCount = null,Object? trustScore = null,Object? expiringDocuments = null,}) {
  return _then(DriverHome(
onDuty: null == onDuty ? _self.onDuty : onDuty // ignore: cast_nullable_to_non_nullable
as bool,truck: freezed == truck ? _self.truck : truck // ignore: cast_nullable_to_non_nullable
as Truck?,walletBalanceInr: freezed == walletBalanceInr ? _self.walletBalanceInr : walletBalanceInr // ignore: cast_nullable_to_non_nullable
as int?,orgName: freezed == orgName ? _self.orgName : orgName // ignore: cast_nullable_to_non_nullable
as String?,currentLoadId: freezed == currentLoadId ? _self.currentLoadId : currentLoadId // ignore: cast_nullable_to_non_nullable
as String?,suggestionsCount: null == suggestionsCount ? _self.suggestionsCount : suggestionsCount // ignore: cast_nullable_to_non_nullable
as int,trustScore: null == trustScore ? _self.trustScore : trustScore // ignore: cast_nullable_to_non_nullable
as double,expiringDocuments: null == expiringDocuments ? _self.expiringDocuments : expiringDocuments // ignore: cast_nullable_to_non_nullable
as List<Document>,
  ));
}
/// Create a copy of DriverHome
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TruckCopyWith<$Res>? get truck {
    if (_self.truck == null) {
    return null;
  }

  return $TruckCopyWith<$Res>(_self.truck!, (value) {
    return _then(_self.copyWith(truck: value));
  });
}
}


/// Adds pattern-matching-related methods to [DriverHome].
extension DriverHomePatterns on DriverHome {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DriverHome value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DriverHome() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DriverHome value)  $default,){
final _that = this;
switch (_that) {
case _DriverHome():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DriverHome value)?  $default,){
final _that = this;
switch (_that) {
case _DriverHome() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool onDuty,  Truck? truck,  int? walletBalanceInr,  String? orgName,  String? currentLoadId,  int suggestionsCount,  double trustScore,  List<Document> expiringDocuments)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DriverHome() when $default != null:
return $default(_that.onDuty,_that.truck,_that.walletBalanceInr,_that.orgName,_that.currentLoadId,_that.suggestionsCount,_that.trustScore,_that.expiringDocuments);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool onDuty,  Truck? truck,  int? walletBalanceInr,  String? orgName,  String? currentLoadId,  int suggestionsCount,  double trustScore,  List<Document> expiringDocuments)  $default,) {final _that = this;
switch (_that) {
case _DriverHome():
return $default(_that.onDuty,_that.truck,_that.walletBalanceInr,_that.orgName,_that.currentLoadId,_that.suggestionsCount,_that.trustScore,_that.expiringDocuments);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool onDuty,  Truck? truck,  int? walletBalanceInr,  String? orgName,  String? currentLoadId,  int suggestionsCount,  double trustScore,  List<Document> expiringDocuments)?  $default,) {final _that = this;
switch (_that) {
case _DriverHome() when $default != null:
return $default(_that.onDuty,_that.truck,_that.walletBalanceInr,_that.orgName,_that.currentLoadId,_that.suggestionsCount,_that.trustScore,_that.expiringDocuments);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DriverHome implements DriverHome {
  const _DriverHome({this.onDuty = false, this.truck, this.walletBalanceInr, this.orgName, this.currentLoadId, this.suggestionsCount = 0, this.trustScore = 70,  List<Document> expiringDocuments = const <Document>[]}): _expiringDocuments = expiringDocuments;
  factory _DriverHome.fromJson(Map<String, dynamic> json) => _$DriverHomeFromJson(json);

@override@JsonKey() final  bool onDuty;
@override final  Truck? truck;
@override final  int? walletBalanceInr;
@override final  String? orgName;
@override final  String? currentLoadId;
@override@JsonKey() final  int suggestionsCount;
@override@JsonKey() final  double trustScore;
 final  List<Document> _expiringDocuments;
@override@JsonKey() List<Document> get expiringDocuments {
  if (_expiringDocuments is EqualUnmodifiableListView) return _expiringDocuments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_expiringDocuments);
}


/// Create a copy of DriverHome
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DriverHomeCopyWith<_DriverHome> get copyWith => __$DriverHomeCopyWithImpl<_DriverHome>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DriverHomeToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DriverHome&&(identical(other.onDuty, onDuty) || other.onDuty == onDuty)&&(identical(other.truck, truck) || other.truck == truck)&&(identical(other.walletBalanceInr, walletBalanceInr) || other.walletBalanceInr == walletBalanceInr)&&(identical(other.orgName, orgName) || other.orgName == orgName)&&(identical(other.currentLoadId, currentLoadId) || other.currentLoadId == currentLoadId)&&(identical(other.suggestionsCount, suggestionsCount) || other.suggestionsCount == suggestionsCount)&&(identical(other.trustScore, trustScore) || other.trustScore == trustScore)&&const DeepCollectionEquality().equals(other.expiringDocuments, _expiringDocuments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,onDuty,truck,walletBalanceInr,orgName,currentLoadId,suggestionsCount,trustScore,const DeepCollectionEquality().hash(_expiringDocuments));
}

@override
String toString() {
    return 'DriverHome(onDuty: $onDuty, truck: $truck, walletBalanceInr: $walletBalanceInr, orgName: $orgName, currentLoadId: $currentLoadId, suggestionsCount: $suggestionsCount, trustScore: $trustScore, expiringDocuments: $expiringDocuments)';
}


}

/// @nodoc
abstract mixin class _$DriverHomeCopyWith<$Res> implements $DriverHomeCopyWith<$Res> {
  factory _$DriverHomeCopyWith(_DriverHome value, $Res Function(_DriverHome) _then) = __$DriverHomeCopyWithImpl;
@override @useResult
$Res call({
 bool onDuty, Truck? truck, int? walletBalanceInr, String? orgName, String? currentLoadId, int suggestionsCount, double trustScore, List<Document> expiringDocuments
});


@override $TruckCopyWith<$Res>? get truck;

}
/// @nodoc
class __$DriverHomeCopyWithImpl<$Res>
    implements _$DriverHomeCopyWith<$Res> {
  __$DriverHomeCopyWithImpl(this._self, this._then);

  final _DriverHome _self;
  final $Res Function(_DriverHome) _then;

/// Create a copy of DriverHome
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? onDuty = null,Object? truck = freezed,Object? walletBalanceInr = freezed,Object? orgName = freezed,Object? currentLoadId = freezed,Object? suggestionsCount = null,Object? trustScore = null,Object? expiringDocuments = null,}) {
  return _then(_DriverHome(
onDuty: null == onDuty ? _self.onDuty : onDuty // ignore: cast_nullable_to_non_nullable
as bool,truck: freezed == truck ? _self.truck : truck // ignore: cast_nullable_to_non_nullable
as Truck?,walletBalanceInr: freezed == walletBalanceInr ? _self.walletBalanceInr : walletBalanceInr // ignore: cast_nullable_to_non_nullable
as int?,orgName: freezed == orgName ? _self.orgName : orgName // ignore: cast_nullable_to_non_nullable
as String?,currentLoadId: freezed == currentLoadId ? _self.currentLoadId : currentLoadId // ignore: cast_nullable_to_non_nullable
as String?,suggestionsCount: null == suggestionsCount ? _self.suggestionsCount : suggestionsCount // ignore: cast_nullable_to_non_nullable
as int,trustScore: null == trustScore ? _self.trustScore : trustScore // ignore: cast_nullable_to_non_nullable
as double,expiringDocuments: null == expiringDocuments ? _self._expiringDocuments : expiringDocuments // ignore: cast_nullable_to_non_nullable
as List<Document>,
  ));
}

/// Create a copy of DriverHome
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TruckCopyWith<$Res>? get truck {
    if (_self.truck == null) {
    return null;
  }

  return $TruckCopyWith<$Res>(_self.truck!, (value) {
    return _then(_self.copyWith(truck: value));
  });
}
}


/// @nodoc
mixin _$Invitation {

 String get id; String get orgId; String get orgName; String get status; DateTime get createdAt;
/// Create a copy of Invitation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvitationCopyWith<Invitation> get copyWith => _$InvitationCopyWithImpl<Invitation>(this as Invitation, _$identity);

  /// Serializes this Invitation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Invitation;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Invitation&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.orgId, _this.orgId) || other.orgId == _this.orgId)&&(identical(other.orgName, _this.orgName) || other.orgName == _this.orgName)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Invitation;
  return Object.hash(runtimeType,_this.id,_this.orgId,_this.orgName,_this.status,_this.createdAt);
}

@override
String toString() {
  final _this = this as Invitation;
  return 'Invitation(id: ${_this.id}, orgId: ${_this.orgId}, orgName: ${_this.orgName}, status: ${_this.status}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $InvitationCopyWith<$Res>  {
  factory $InvitationCopyWith(Invitation value, $Res Function(Invitation) _then) = _$InvitationCopyWithImpl;
@useResult
$Res call({
 String id, String orgId, String orgName, String status, DateTime createdAt
});




}
/// @nodoc
class _$InvitationCopyWithImpl<$Res>
    implements $InvitationCopyWith<$Res> {
  _$InvitationCopyWithImpl(this._self, this._then);

  final Invitation _self;
  final $Res Function(Invitation) _then;

/// Create a copy of Invitation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? orgId = null,Object? orgName = null,Object? status = null,Object? createdAt = null,}) {
  return _then(Invitation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orgId: null == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as String,orgName: null == orgName ? _self.orgName : orgName // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Invitation].
extension InvitationPatterns on Invitation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Invitation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Invitation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Invitation value)  $default,){
final _that = this;
switch (_that) {
case _Invitation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Invitation value)?  $default,){
final _that = this;
switch (_that) {
case _Invitation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String orgId,  String orgName,  String status,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Invitation() when $default != null:
return $default(_that.id,_that.orgId,_that.orgName,_that.status,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String orgId,  String orgName,  String status,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Invitation():
return $default(_that.id,_that.orgId,_that.orgName,_that.status,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String orgId,  String orgName,  String status,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Invitation() when $default != null:
return $default(_that.id,_that.orgId,_that.orgName,_that.status,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Invitation implements Invitation {
  const _Invitation({required this.id, required this.orgId, required this.orgName, required this.status, required this.createdAt});
  factory _Invitation.fromJson(Map<String, dynamic> json) => _$InvitationFromJson(json);

@override final  String id;
@override final  String orgId;
@override final  String orgName;
@override final  String status;
@override final  DateTime createdAt;

/// Create a copy of Invitation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvitationCopyWith<_Invitation> get copyWith => __$InvitationCopyWithImpl<_Invitation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InvitationToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Invitation&&(identical(other.id, id) || other.id == id)&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.orgName, orgName) || other.orgName == orgName)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,orgId,orgName,status,createdAt);
}

@override
String toString() {
    return 'Invitation(id: $id, orgId: $orgId, orgName: $orgName, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$InvitationCopyWith<$Res> implements $InvitationCopyWith<$Res> {
  factory _$InvitationCopyWith(_Invitation value, $Res Function(_Invitation) _then) = __$InvitationCopyWithImpl;
@override @useResult
$Res call({
 String id, String orgId, String orgName, String status, DateTime createdAt
});




}
/// @nodoc
class __$InvitationCopyWithImpl<$Res>
    implements _$InvitationCopyWith<$Res> {
  __$InvitationCopyWithImpl(this._self, this._then);

  final _Invitation _self;
  final $Res Function(_Invitation) _then;

/// Create a copy of Invitation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? orgId = null,Object? orgName = null,Object? status = null,Object? createdAt = null,}) {
  return _then(_Invitation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orgId: null == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as String,orgName: null == orgName ? _self.orgName : orgName // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
