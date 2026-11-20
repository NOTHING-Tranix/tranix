// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'engagement.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WishlistEntry {

 String get id;@JsonKey(unknownEnumValue: WishlistTargetType.unknown) WishlistTargetType get targetType; String? get truckNumber;@JsonKey(unknownEnumValue: VehicleType.unknown) VehicleType? get vehicleType; num? get capacityTonnes; String? get driverName; String? get orgId; String? get orgName; double get trustScore; int get tripsTogether; String? get note; bool get available;
/// Create a copy of WishlistEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WishlistEntryCopyWith<WishlistEntry> get copyWith => _$WishlistEntryCopyWithImpl<WishlistEntry>(this as WishlistEntry, _$identity);

  /// Serializes this WishlistEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as WishlistEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WishlistEntry&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.targetType, _this.targetType) || other.targetType == _this.targetType)&&(identical(other.truckNumber, _this.truckNumber) || other.truckNumber == _this.truckNumber)&&(identical(other.vehicleType, _this.vehicleType) || other.vehicleType == _this.vehicleType)&&(identical(other.capacityTonnes, _this.capacityTonnes) || other.capacityTonnes == _this.capacityTonnes)&&(identical(other.driverName, _this.driverName) || other.driverName == _this.driverName)&&(identical(other.orgId, _this.orgId) || other.orgId == _this.orgId)&&(identical(other.orgName, _this.orgName) || other.orgName == _this.orgName)&&(identical(other.trustScore, _this.trustScore) || other.trustScore == _this.trustScore)&&(identical(other.tripsTogether, _this.tripsTogether) || other.tripsTogether == _this.tripsTogether)&&(identical(other.note, _this.note) || other.note == _this.note)&&(identical(other.available, _this.available) || other.available == _this.available));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as WishlistEntry;
  return Object.hash(runtimeType,_this.id,_this.targetType,_this.truckNumber,_this.vehicleType,_this.capacityTonnes,_this.driverName,_this.orgId,_this.orgName,_this.trustScore,_this.tripsTogether,_this.note,_this.available);
}

@override
String toString() {
  final _this = this as WishlistEntry;
  return 'WishlistEntry(id: ${_this.id}, targetType: ${_this.targetType}, truckNumber: ${_this.truckNumber}, vehicleType: ${_this.vehicleType}, capacityTonnes: ${_this.capacityTonnes}, driverName: ${_this.driverName}, orgId: ${_this.orgId}, orgName: ${_this.orgName}, trustScore: ${_this.trustScore}, tripsTogether: ${_this.tripsTogether}, note: ${_this.note}, available: ${_this.available})';
}


}

/// @nodoc
abstract mixin class $WishlistEntryCopyWith<$Res>  {
  factory $WishlistEntryCopyWith(WishlistEntry value, $Res Function(WishlistEntry) _then) = _$WishlistEntryCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(unknownEnumValue: WishlistTargetType.unknown) WishlistTargetType targetType, String? truckNumber,@JsonKey(unknownEnumValue: VehicleType.unknown) VehicleType? vehicleType, num? capacityTonnes, String? driverName, String? orgId, String? orgName, double trustScore, int tripsTogether, String? note, bool available
});




}
/// @nodoc
class _$WishlistEntryCopyWithImpl<$Res>
    implements $WishlistEntryCopyWith<$Res> {
  _$WishlistEntryCopyWithImpl(this._self, this._then);

  final WishlistEntry _self;
  final $Res Function(WishlistEntry) _then;

/// Create a copy of WishlistEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? targetType = null,Object? truckNumber = freezed,Object? vehicleType = freezed,Object? capacityTonnes = freezed,Object? driverName = freezed,Object? orgId = freezed,Object? orgName = freezed,Object? trustScore = null,Object? tripsTogether = null,Object? note = freezed,Object? available = null,}) {
  return _then(WishlistEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,targetType: null == targetType ? _self.targetType : targetType // ignore: cast_nullable_to_non_nullable
as WishlistTargetType,truckNumber: freezed == truckNumber ? _self.truckNumber : truckNumber // ignore: cast_nullable_to_non_nullable
as String?,vehicleType: freezed == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as VehicleType?,capacityTonnes: freezed == capacityTonnes ? _self.capacityTonnes : capacityTonnes // ignore: cast_nullable_to_non_nullable
as num?,driverName: freezed == driverName ? _self.driverName : driverName // ignore: cast_nullable_to_non_nullable
as String?,orgId: freezed == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as String?,orgName: freezed == orgName ? _self.orgName : orgName // ignore: cast_nullable_to_non_nullable
as String?,trustScore: null == trustScore ? _self.trustScore : trustScore // ignore: cast_nullable_to_non_nullable
as double,tripsTogether: null == tripsTogether ? _self.tripsTogether : tripsTogether // ignore: cast_nullable_to_non_nullable
as int,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [WishlistEntry].
extension WishlistEntryPatterns on WishlistEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WishlistEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WishlistEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WishlistEntry value)  $default,){
final _that = this;
switch (_that) {
case _WishlistEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WishlistEntry value)?  $default,){
final _that = this;
switch (_that) {
case _WishlistEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(unknownEnumValue: WishlistTargetType.unknown)  WishlistTargetType targetType,  String? truckNumber, @JsonKey(unknownEnumValue: VehicleType.unknown)  VehicleType? vehicleType,  num? capacityTonnes,  String? driverName,  String? orgId,  String? orgName,  double trustScore,  int tripsTogether,  String? note,  bool available)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WishlistEntry() when $default != null:
return $default(_that.id,_that.targetType,_that.truckNumber,_that.vehicleType,_that.capacityTonnes,_that.driverName,_that.orgId,_that.orgName,_that.trustScore,_that.tripsTogether,_that.note,_that.available);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(unknownEnumValue: WishlistTargetType.unknown)  WishlistTargetType targetType,  String? truckNumber, @JsonKey(unknownEnumValue: VehicleType.unknown)  VehicleType? vehicleType,  num? capacityTonnes,  String? driverName,  String? orgId,  String? orgName,  double trustScore,  int tripsTogether,  String? note,  bool available)  $default,) {final _that = this;
switch (_that) {
case _WishlistEntry():
return $default(_that.id,_that.targetType,_that.truckNumber,_that.vehicleType,_that.capacityTonnes,_that.driverName,_that.orgId,_that.orgName,_that.trustScore,_that.tripsTogether,_that.note,_that.available);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(unknownEnumValue: WishlistTargetType.unknown)  WishlistTargetType targetType,  String? truckNumber, @JsonKey(unknownEnumValue: VehicleType.unknown)  VehicleType? vehicleType,  num? capacityTonnes,  String? driverName,  String? orgId,  String? orgName,  double trustScore,  int tripsTogether,  String? note,  bool available)?  $default,) {final _that = this;
switch (_that) {
case _WishlistEntry() when $default != null:
return $default(_that.id,_that.targetType,_that.truckNumber,_that.vehicleType,_that.capacityTonnes,_that.driverName,_that.orgId,_that.orgName,_that.trustScore,_that.tripsTogether,_that.note,_that.available);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WishlistEntry implements WishlistEntry {
  const _WishlistEntry({required this.id, @JsonKey(unknownEnumValue: WishlistTargetType.unknown) required this.targetType, this.truckNumber, @JsonKey(unknownEnumValue: VehicleType.unknown) this.vehicleType, this.capacityTonnes, this.driverName, this.orgId, this.orgName, required this.trustScore, this.tripsTogether = 0, this.note, this.available = false});
  factory _WishlistEntry.fromJson(Map<String, dynamic> json) => _$WishlistEntryFromJson(json);

@override final  String id;
@override@JsonKey(unknownEnumValue: WishlistTargetType.unknown) final  WishlistTargetType targetType;
@override final  String? truckNumber;
@override@JsonKey(unknownEnumValue: VehicleType.unknown) final  VehicleType? vehicleType;
@override final  num? capacityTonnes;
@override final  String? driverName;
@override final  String? orgId;
@override final  String? orgName;
@override final  double trustScore;
@override@JsonKey() final  int tripsTogether;
@override final  String? note;
@override@JsonKey() final  bool available;

/// Create a copy of WishlistEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WishlistEntryCopyWith<_WishlistEntry> get copyWith => __$WishlistEntryCopyWithImpl<_WishlistEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WishlistEntryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WishlistEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.targetType, targetType) || other.targetType == targetType)&&(identical(other.truckNumber, truckNumber) || other.truckNumber == truckNumber)&&(identical(other.vehicleType, vehicleType) || other.vehicleType == vehicleType)&&(identical(other.capacityTonnes, capacityTonnes) || other.capacityTonnes == capacityTonnes)&&(identical(other.driverName, driverName) || other.driverName == driverName)&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.orgName, orgName) || other.orgName == orgName)&&(identical(other.trustScore, trustScore) || other.trustScore == trustScore)&&(identical(other.tripsTogether, tripsTogether) || other.tripsTogether == tripsTogether)&&(identical(other.note, note) || other.note == note)&&(identical(other.available, available) || other.available == available));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,targetType,truckNumber,vehicleType,capacityTonnes,driverName,orgId,orgName,trustScore,tripsTogether,note,available);
}

@override
String toString() {
    return 'WishlistEntry(id: $id, targetType: $targetType, truckNumber: $truckNumber, vehicleType: $vehicleType, capacityTonnes: $capacityTonnes, driverName: $driverName, orgId: $orgId, orgName: $orgName, trustScore: $trustScore, tripsTogether: $tripsTogether, note: $note, available: $available)';
}


}

/// @nodoc
abstract mixin class _$WishlistEntryCopyWith<$Res> implements $WishlistEntryCopyWith<$Res> {
  factory _$WishlistEntryCopyWith(_WishlistEntry value, $Res Function(_WishlistEntry) _then) = __$WishlistEntryCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(unknownEnumValue: WishlistTargetType.unknown) WishlistTargetType targetType, String? truckNumber,@JsonKey(unknownEnumValue: VehicleType.unknown) VehicleType? vehicleType, num? capacityTonnes, String? driverName, String? orgId, String? orgName, double trustScore, int tripsTogether, String? note, bool available
});




}
/// @nodoc
class __$WishlistEntryCopyWithImpl<$Res>
    implements _$WishlistEntryCopyWith<$Res> {
  __$WishlistEntryCopyWithImpl(this._self, this._then);

  final _WishlistEntry _self;
  final $Res Function(_WishlistEntry) _then;

/// Create a copy of WishlistEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? targetType = null,Object? truckNumber = freezed,Object? vehicleType = freezed,Object? capacityTonnes = freezed,Object? driverName = freezed,Object? orgId = freezed,Object? orgName = freezed,Object? trustScore = null,Object? tripsTogether = null,Object? note = freezed,Object? available = null,}) {
  return _then(_WishlistEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,targetType: null == targetType ? _self.targetType : targetType // ignore: cast_nullable_to_non_nullable
as WishlistTargetType,truckNumber: freezed == truckNumber ? _self.truckNumber : truckNumber // ignore: cast_nullable_to_non_nullable
as String?,vehicleType: freezed == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as VehicleType?,capacityTonnes: freezed == capacityTonnes ? _self.capacityTonnes : capacityTonnes // ignore: cast_nullable_to_non_nullable
as num?,driverName: freezed == driverName ? _self.driverName : driverName // ignore: cast_nullable_to_non_nullable
as String?,orgId: freezed == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as String?,orgName: freezed == orgName ? _self.orgName : orgName // ignore: cast_nullable_to_non_nullable
as String?,trustScore: null == trustScore ? _self.trustScore : trustScore // ignore: cast_nullable_to_non_nullable
as double,tripsTogether: null == tripsTogether ? _self.tripsTogether : tripsTogether // ignore: cast_nullable_to_non_nullable
as int,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$TrustScore {

 double get score; DateTime get updatedAt; List<double> get trend;
/// Create a copy of TrustScore
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrustScoreCopyWith<TrustScore> get copyWith => _$TrustScoreCopyWithImpl<TrustScore>(this as TrustScore, _$identity);

  /// Serializes this TrustScore to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TrustScore;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrustScore&&(identical(other.score, _this.score) || other.score == _this.score)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&const DeepCollectionEquality().equals(other.trend, _this.trend));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TrustScore;
  return Object.hash(runtimeType,_this.score,_this.updatedAt,const DeepCollectionEquality().hash(_this.trend));
}

@override
String toString() {
  final _this = this as TrustScore;
  return 'TrustScore(score: ${_this.score}, updatedAt: ${_this.updatedAt}, trend: ${_this.trend})';
}


}

/// @nodoc
abstract mixin class $TrustScoreCopyWith<$Res>  {
  factory $TrustScoreCopyWith(TrustScore value, $Res Function(TrustScore) _then) = _$TrustScoreCopyWithImpl;
@useResult
$Res call({
 double score, DateTime updatedAt, List<double> trend
});




}
/// @nodoc
class _$TrustScoreCopyWithImpl<$Res>
    implements $TrustScoreCopyWith<$Res> {
  _$TrustScoreCopyWithImpl(this._self, this._then);

  final TrustScore _self;
  final $Res Function(TrustScore) _then;

/// Create a copy of TrustScore
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? score = null,Object? updatedAt = null,Object? trend = null,}) {
  return _then(TrustScore(
score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as double,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,trend: null == trend ? _self.trend : trend // ignore: cast_nullable_to_non_nullable
as List<double>,
  ));
}

}


/// Adds pattern-matching-related methods to [TrustScore].
extension TrustScorePatterns on TrustScore {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrustScore value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrustScore() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrustScore value)  $default,){
final _that = this;
switch (_that) {
case _TrustScore():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrustScore value)?  $default,){
final _that = this;
switch (_that) {
case _TrustScore() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double score,  DateTime updatedAt,  List<double> trend)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrustScore() when $default != null:
return $default(_that.score,_that.updatedAt,_that.trend);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double score,  DateTime updatedAt,  List<double> trend)  $default,) {final _that = this;
switch (_that) {
case _TrustScore():
return $default(_that.score,_that.updatedAt,_that.trend);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double score,  DateTime updatedAt,  List<double> trend)?  $default,) {final _that = this;
switch (_that) {
case _TrustScore() when $default != null:
return $default(_that.score,_that.updatedAt,_that.trend);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrustScore implements TrustScore {
  const _TrustScore({required this.score, required this.updatedAt,  List<double> trend = const <double>[]}): _trend = trend;
  factory _TrustScore.fromJson(Map<String, dynamic> json) => _$TrustScoreFromJson(json);

@override final  double score;
@override final  DateTime updatedAt;
 final  List<double> _trend;
@override@JsonKey() List<double> get trend {
  if (_trend is EqualUnmodifiableListView) return _trend;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_trend);
}


/// Create a copy of TrustScore
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrustScoreCopyWith<_TrustScore> get copyWith => __$TrustScoreCopyWithImpl<_TrustScore>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrustScoreToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrustScore&&(identical(other.score, score) || other.score == score)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.trend, _trend));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,score,updatedAt,const DeepCollectionEquality().hash(_trend));
}

@override
String toString() {
    return 'TrustScore(score: $score, updatedAt: $updatedAt, trend: $trend)';
}


}

/// @nodoc
abstract mixin class _$TrustScoreCopyWith<$Res> implements $TrustScoreCopyWith<$Res> {
  factory _$TrustScoreCopyWith(_TrustScore value, $Res Function(_TrustScore) _then) = __$TrustScoreCopyWithImpl;
@override @useResult
$Res call({
 double score, DateTime updatedAt, List<double> trend
});




}
/// @nodoc
class __$TrustScoreCopyWithImpl<$Res>
    implements _$TrustScoreCopyWith<$Res> {
  __$TrustScoreCopyWithImpl(this._self, this._then);

  final _TrustScore _self;
  final $Res Function(_TrustScore) _then;

/// Create a copy of TrustScore
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? score = null,Object? updatedAt = null,Object? trend = null,}) {
  return _then(_TrustScore(
score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as double,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,trend: null == trend ? _self._trend : trend // ignore: cast_nullable_to_non_nullable
as List<double>,
  ));
}


}


/// @nodoc
mixin _$TrustEvent {

 DateTime get at; String? get loadId; String get event; double get points; String get reason;
/// Create a copy of TrustEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrustEventCopyWith<TrustEvent> get copyWith => _$TrustEventCopyWithImpl<TrustEvent>(this as TrustEvent, _$identity);

  /// Serializes this TrustEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TrustEvent;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrustEvent&&(identical(other.at, _this.at) || other.at == _this.at)&&(identical(other.loadId, _this.loadId) || other.loadId == _this.loadId)&&(identical(other.event, _this.event) || other.event == _this.event)&&(identical(other.points, _this.points) || other.points == _this.points)&&(identical(other.reason, _this.reason) || other.reason == _this.reason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TrustEvent;
  return Object.hash(runtimeType,_this.at,_this.loadId,_this.event,_this.points,_this.reason);
}

@override
String toString() {
  final _this = this as TrustEvent;
  return 'TrustEvent(at: ${_this.at}, loadId: ${_this.loadId}, event: ${_this.event}, points: ${_this.points}, reason: ${_this.reason})';
}


}

/// @nodoc
abstract mixin class $TrustEventCopyWith<$Res>  {
  factory $TrustEventCopyWith(TrustEvent value, $Res Function(TrustEvent) _then) = _$TrustEventCopyWithImpl;
@useResult
$Res call({
 DateTime at, String? loadId, String event, double points, String reason
});




}
/// @nodoc
class _$TrustEventCopyWithImpl<$Res>
    implements $TrustEventCopyWith<$Res> {
  _$TrustEventCopyWithImpl(this._self, this._then);

  final TrustEvent _self;
  final $Res Function(TrustEvent) _then;

/// Create a copy of TrustEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? at = null,Object? loadId = freezed,Object? event = null,Object? points = null,Object? reason = null,}) {
  return _then(TrustEvent(
at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime,loadId: freezed == loadId ? _self.loadId : loadId // ignore: cast_nullable_to_non_nullable
as String?,event: null == event ? _self.event : event // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as double,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TrustEvent].
extension TrustEventPatterns on TrustEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrustEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrustEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrustEvent value)  $default,){
final _that = this;
switch (_that) {
case _TrustEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrustEvent value)?  $default,){
final _that = this;
switch (_that) {
case _TrustEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime at,  String? loadId,  String event,  double points,  String reason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrustEvent() when $default != null:
return $default(_that.at,_that.loadId,_that.event,_that.points,_that.reason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime at,  String? loadId,  String event,  double points,  String reason)  $default,) {final _that = this;
switch (_that) {
case _TrustEvent():
return $default(_that.at,_that.loadId,_that.event,_that.points,_that.reason);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime at,  String? loadId,  String event,  double points,  String reason)?  $default,) {final _that = this;
switch (_that) {
case _TrustEvent() when $default != null:
return $default(_that.at,_that.loadId,_that.event,_that.points,_that.reason);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrustEvent implements TrustEvent {
  const _TrustEvent({required this.at, this.loadId, required this.event, required this.points, required this.reason});
  factory _TrustEvent.fromJson(Map<String, dynamic> json) => _$TrustEventFromJson(json);

@override final  DateTime at;
@override final  String? loadId;
@override final  String event;
@override final  double points;
@override final  String reason;

/// Create a copy of TrustEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrustEventCopyWith<_TrustEvent> get copyWith => __$TrustEventCopyWithImpl<_TrustEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrustEventToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrustEvent&&(identical(other.at, at) || other.at == at)&&(identical(other.loadId, loadId) || other.loadId == loadId)&&(identical(other.event, event) || other.event == event)&&(identical(other.points, points) || other.points == points)&&(identical(other.reason, reason) || other.reason == reason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,at,loadId,event,points,reason);
}

@override
String toString() {
    return 'TrustEvent(at: $at, loadId: $loadId, event: $event, points: $points, reason: $reason)';
}


}

/// @nodoc
abstract mixin class _$TrustEventCopyWith<$Res> implements $TrustEventCopyWith<$Res> {
  factory _$TrustEventCopyWith(_TrustEvent value, $Res Function(_TrustEvent) _then) = __$TrustEventCopyWithImpl;
@override @useResult
$Res call({
 DateTime at, String? loadId, String event, double points, String reason
});




}
/// @nodoc
class __$TrustEventCopyWithImpl<$Res>
    implements _$TrustEventCopyWith<$Res> {
  __$TrustEventCopyWithImpl(this._self, this._then);

  final _TrustEvent _self;
  final $Res Function(_TrustEvent) _then;

/// Create a copy of TrustEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? at = null,Object? loadId = freezed,Object? event = null,Object? points = null,Object? reason = null,}) {
  return _then(_TrustEvent(
at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime,loadId: freezed == loadId ? _self.loadId : loadId // ignore: cast_nullable_to_non_nullable
as String?,event: null == event ? _self.event : event // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as double,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$PendingRating {

 String get loadId; String get rateeName;@JsonKey(unknownEnumValue: Role.unknown) Role get rateeRole;
/// Create a copy of PendingRating
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PendingRatingCopyWith<PendingRating> get copyWith => _$PendingRatingCopyWithImpl<PendingRating>(this as PendingRating, _$identity);

  /// Serializes this PendingRating to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PendingRating;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PendingRating&&(identical(other.loadId, _this.loadId) || other.loadId == _this.loadId)&&(identical(other.rateeName, _this.rateeName) || other.rateeName == _this.rateeName)&&(identical(other.rateeRole, _this.rateeRole) || other.rateeRole == _this.rateeRole));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PendingRating;
  return Object.hash(runtimeType,_this.loadId,_this.rateeName,_this.rateeRole);
}

@override
String toString() {
  final _this = this as PendingRating;
  return 'PendingRating(loadId: ${_this.loadId}, rateeName: ${_this.rateeName}, rateeRole: ${_this.rateeRole})';
}


}

/// @nodoc
abstract mixin class $PendingRatingCopyWith<$Res>  {
  factory $PendingRatingCopyWith(PendingRating value, $Res Function(PendingRating) _then) = _$PendingRatingCopyWithImpl;
@useResult
$Res call({
 String loadId, String rateeName,@JsonKey(unknownEnumValue: Role.unknown) Role rateeRole
});




}
/// @nodoc
class _$PendingRatingCopyWithImpl<$Res>
    implements $PendingRatingCopyWith<$Res> {
  _$PendingRatingCopyWithImpl(this._self, this._then);

  final PendingRating _self;
  final $Res Function(PendingRating) _then;

/// Create a copy of PendingRating
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? loadId = null,Object? rateeName = null,Object? rateeRole = null,}) {
  return _then(PendingRating(
loadId: null == loadId ? _self.loadId : loadId // ignore: cast_nullable_to_non_nullable
as String,rateeName: null == rateeName ? _self.rateeName : rateeName // ignore: cast_nullable_to_non_nullable
as String,rateeRole: null == rateeRole ? _self.rateeRole : rateeRole // ignore: cast_nullable_to_non_nullable
as Role,
  ));
}

}


/// Adds pattern-matching-related methods to [PendingRating].
extension PendingRatingPatterns on PendingRating {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PendingRating value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PendingRating() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PendingRating value)  $default,){
final _that = this;
switch (_that) {
case _PendingRating():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PendingRating value)?  $default,){
final _that = this;
switch (_that) {
case _PendingRating() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String loadId,  String rateeName, @JsonKey(unknownEnumValue: Role.unknown)  Role rateeRole)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PendingRating() when $default != null:
return $default(_that.loadId,_that.rateeName,_that.rateeRole);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String loadId,  String rateeName, @JsonKey(unknownEnumValue: Role.unknown)  Role rateeRole)  $default,) {final _that = this;
switch (_that) {
case _PendingRating():
return $default(_that.loadId,_that.rateeName,_that.rateeRole);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String loadId,  String rateeName, @JsonKey(unknownEnumValue: Role.unknown)  Role rateeRole)?  $default,) {final _that = this;
switch (_that) {
case _PendingRating() when $default != null:
return $default(_that.loadId,_that.rateeName,_that.rateeRole);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PendingRating implements PendingRating {
  const _PendingRating({required this.loadId, required this.rateeName, @JsonKey(unknownEnumValue: Role.unknown) required this.rateeRole});
  factory _PendingRating.fromJson(Map<String, dynamic> json) => _$PendingRatingFromJson(json);

@override final  String loadId;
@override final  String rateeName;
@override@JsonKey(unknownEnumValue: Role.unknown) final  Role rateeRole;

/// Create a copy of PendingRating
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PendingRatingCopyWith<_PendingRating> get copyWith => __$PendingRatingCopyWithImpl<_PendingRating>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PendingRatingToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PendingRating&&(identical(other.loadId, loadId) || other.loadId == loadId)&&(identical(other.rateeName, rateeName) || other.rateeName == rateeName)&&(identical(other.rateeRole, rateeRole) || other.rateeRole == rateeRole));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,loadId,rateeName,rateeRole);
}

@override
String toString() {
    return 'PendingRating(loadId: $loadId, rateeName: $rateeName, rateeRole: $rateeRole)';
}


}

/// @nodoc
abstract mixin class _$PendingRatingCopyWith<$Res> implements $PendingRatingCopyWith<$Res> {
  factory _$PendingRatingCopyWith(_PendingRating value, $Res Function(_PendingRating) _then) = __$PendingRatingCopyWithImpl;
@override @useResult
$Res call({
 String loadId, String rateeName,@JsonKey(unknownEnumValue: Role.unknown) Role rateeRole
});




}
/// @nodoc
class __$PendingRatingCopyWithImpl<$Res>
    implements _$PendingRatingCopyWith<$Res> {
  __$PendingRatingCopyWithImpl(this._self, this._then);

  final _PendingRating _self;
  final $Res Function(_PendingRating) _then;

/// Create a copy of PendingRating
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? loadId = null,Object? rateeName = null,Object? rateeRole = null,}) {
  return _then(_PendingRating(
loadId: null == loadId ? _self.loadId : loadId // ignore: cast_nullable_to_non_nullable
as String,rateeName: null == rateeName ? _self.rateeName : rateeName // ignore: cast_nullable_to_non_nullable
as String,rateeRole: null == rateeRole ? _self.rateeRole : rateeRole // ignore: cast_nullable_to_non_nullable
as Role,
  ));
}


}


/// @nodoc
mixin _$NotificationSummary {

 Map<String, int> get unreadByTab; AppNotification? get latestTranixMessage; AppNotification? get latestTripUpdate;
/// Create a copy of NotificationSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationSummaryCopyWith<NotificationSummary> get copyWith => _$NotificationSummaryCopyWithImpl<NotificationSummary>(this as NotificationSummary, _$identity);

  /// Serializes this NotificationSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as NotificationSummary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationSummary&&const DeepCollectionEquality().equals(other.unreadByTab, _this.unreadByTab)&&(identical(other.latestTranixMessage, _this.latestTranixMessage) || other.latestTranixMessage == _this.latestTranixMessage)&&(identical(other.latestTripUpdate, _this.latestTripUpdate) || other.latestTripUpdate == _this.latestTripUpdate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as NotificationSummary;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.unreadByTab),_this.latestTranixMessage,_this.latestTripUpdate);
}

@override
String toString() {
  final _this = this as NotificationSummary;
  return 'NotificationSummary(unreadByTab: ${_this.unreadByTab}, latestTranixMessage: ${_this.latestTranixMessage}, latestTripUpdate: ${_this.latestTripUpdate})';
}


}

/// @nodoc
abstract mixin class $NotificationSummaryCopyWith<$Res>  {
  factory $NotificationSummaryCopyWith(NotificationSummary value, $Res Function(NotificationSummary) _then) = _$NotificationSummaryCopyWithImpl;
@useResult
$Res call({
 Map<String, int> unreadByTab, AppNotification? latestTranixMessage, AppNotification? latestTripUpdate
});


$AppNotificationCopyWith<$Res>? get latestTranixMessage;$AppNotificationCopyWith<$Res>? get latestTripUpdate;

}
/// @nodoc
class _$NotificationSummaryCopyWithImpl<$Res>
    implements $NotificationSummaryCopyWith<$Res> {
  _$NotificationSummaryCopyWithImpl(this._self, this._then);

  final NotificationSummary _self;
  final $Res Function(NotificationSummary) _then;

/// Create a copy of NotificationSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? unreadByTab = null,Object? latestTranixMessage = freezed,Object? latestTripUpdate = freezed,}) {
  return _then(NotificationSummary(
unreadByTab: null == unreadByTab ? _self.unreadByTab : unreadByTab // ignore: cast_nullable_to_non_nullable
as Map<String, int>,latestTranixMessage: freezed == latestTranixMessage ? _self.latestTranixMessage : latestTranixMessage // ignore: cast_nullable_to_non_nullable
as AppNotification?,latestTripUpdate: freezed == latestTripUpdate ? _self.latestTripUpdate : latestTripUpdate // ignore: cast_nullable_to_non_nullable
as AppNotification?,
  ));
}
/// Create a copy of NotificationSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppNotificationCopyWith<$Res>? get latestTranixMessage {
    if (_self.latestTranixMessage == null) {
    return null;
  }

  return $AppNotificationCopyWith<$Res>(_self.latestTranixMessage!, (value) {
    return _then(_self.copyWith(latestTranixMessage: value));
  });
}/// Create a copy of NotificationSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppNotificationCopyWith<$Res>? get latestTripUpdate {
    if (_self.latestTripUpdate == null) {
    return null;
  }

  return $AppNotificationCopyWith<$Res>(_self.latestTripUpdate!, (value) {
    return _then(_self.copyWith(latestTripUpdate: value));
  });
}
}


/// Adds pattern-matching-related methods to [NotificationSummary].
extension NotificationSummaryPatterns on NotificationSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationSummary value)  $default,){
final _that = this;
switch (_that) {
case _NotificationSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationSummary value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, int> unreadByTab,  AppNotification? latestTranixMessage,  AppNotification? latestTripUpdate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationSummary() when $default != null:
return $default(_that.unreadByTab,_that.latestTranixMessage,_that.latestTripUpdate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, int> unreadByTab,  AppNotification? latestTranixMessage,  AppNotification? latestTripUpdate)  $default,) {final _that = this;
switch (_that) {
case _NotificationSummary():
return $default(_that.unreadByTab,_that.latestTranixMessage,_that.latestTripUpdate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, int> unreadByTab,  AppNotification? latestTranixMessage,  AppNotification? latestTripUpdate)?  $default,) {final _that = this;
switch (_that) {
case _NotificationSummary() when $default != null:
return $default(_that.unreadByTab,_that.latestTranixMessage,_that.latestTripUpdate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotificationSummary implements NotificationSummary {
  const _NotificationSummary({ Map<String, int> unreadByTab = const <String, int>{}, this.latestTranixMessage, this.latestTripUpdate}): _unreadByTab = unreadByTab;
  factory _NotificationSummary.fromJson(Map<String, dynamic> json) => _$NotificationSummaryFromJson(json);

 final  Map<String, int> _unreadByTab;
@override@JsonKey() Map<String, int> get unreadByTab {
  if (_unreadByTab is EqualUnmodifiableMapView) return _unreadByTab;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_unreadByTab);
}

@override final  AppNotification? latestTranixMessage;
@override final  AppNotification? latestTripUpdate;

/// Create a copy of NotificationSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationSummaryCopyWith<_NotificationSummary> get copyWith => __$NotificationSummaryCopyWithImpl<_NotificationSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationSummary&&const DeepCollectionEquality().equals(other.unreadByTab, _unreadByTab)&&(identical(other.latestTranixMessage, latestTranixMessage) || other.latestTranixMessage == latestTranixMessage)&&(identical(other.latestTripUpdate, latestTripUpdate) || other.latestTripUpdate == latestTripUpdate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_unreadByTab),latestTranixMessage,latestTripUpdate);
}

@override
String toString() {
    return 'NotificationSummary(unreadByTab: $unreadByTab, latestTranixMessage: $latestTranixMessage, latestTripUpdate: $latestTripUpdate)';
}


}

/// @nodoc
abstract mixin class _$NotificationSummaryCopyWith<$Res> implements $NotificationSummaryCopyWith<$Res> {
  factory _$NotificationSummaryCopyWith(_NotificationSummary value, $Res Function(_NotificationSummary) _then) = __$NotificationSummaryCopyWithImpl;
@override @useResult
$Res call({
 Map<String, int> unreadByTab, AppNotification? latestTranixMessage, AppNotification? latestTripUpdate
});


@override $AppNotificationCopyWith<$Res>? get latestTranixMessage;@override $AppNotificationCopyWith<$Res>? get latestTripUpdate;

}
/// @nodoc
class __$NotificationSummaryCopyWithImpl<$Res>
    implements _$NotificationSummaryCopyWith<$Res> {
  __$NotificationSummaryCopyWithImpl(this._self, this._then);

  final _NotificationSummary _self;
  final $Res Function(_NotificationSummary) _then;

/// Create a copy of NotificationSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? unreadByTab = null,Object? latestTranixMessage = freezed,Object? latestTripUpdate = freezed,}) {
  return _then(_NotificationSummary(
unreadByTab: null == unreadByTab ? _self._unreadByTab : unreadByTab // ignore: cast_nullable_to_non_nullable
as Map<String, int>,latestTranixMessage: freezed == latestTranixMessage ? _self.latestTranixMessage : latestTranixMessage // ignore: cast_nullable_to_non_nullable
as AppNotification?,latestTripUpdate: freezed == latestTripUpdate ? _self.latestTripUpdate : latestTripUpdate // ignore: cast_nullable_to_non_nullable
as AppNotification?,
  ));
}

/// Create a copy of NotificationSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppNotificationCopyWith<$Res>? get latestTranixMessage {
    if (_self.latestTranixMessage == null) {
    return null;
  }

  return $AppNotificationCopyWith<$Res>(_self.latestTranixMessage!, (value) {
    return _then(_self.copyWith(latestTranixMessage: value));
  });
}/// Create a copy of NotificationSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppNotificationCopyWith<$Res>? get latestTripUpdate {
    if (_self.latestTripUpdate == null) {
    return null;
  }

  return $AppNotificationCopyWith<$Res>(_self.latestTripUpdate!, (value) {
    return _then(_self.copyWith(latestTripUpdate: value));
  });
}
}


/// @nodoc
mixin _$AppNotification {

 String get id;@JsonKey(unknownEnumValue: NotificationTab.unknown) NotificationTab get tab; String get type; String get title; String get body; String? get route; bool get read; DateTime get createdAt;
/// Create a copy of AppNotification
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppNotificationCopyWith<AppNotification> get copyWith => _$AppNotificationCopyWithImpl<AppNotification>(this as AppNotification, _$identity);

  /// Serializes this AppNotification to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AppNotification;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppNotification&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.tab, _this.tab) || other.tab == _this.tab)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.body, _this.body) || other.body == _this.body)&&(identical(other.route, _this.route) || other.route == _this.route)&&(identical(other.read, _this.read) || other.read == _this.read)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AppNotification;
  return Object.hash(runtimeType,_this.id,_this.tab,_this.type,_this.title,_this.body,_this.route,_this.read,_this.createdAt);
}

@override
String toString() {
  final _this = this as AppNotification;
  return 'AppNotification(id: ${_this.id}, tab: ${_this.tab}, type: ${_this.type}, title: ${_this.title}, body: ${_this.body}, route: ${_this.route}, read: ${_this.read}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $AppNotificationCopyWith<$Res>  {
  factory $AppNotificationCopyWith(AppNotification value, $Res Function(AppNotification) _then) = _$AppNotificationCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(unknownEnumValue: NotificationTab.unknown) NotificationTab tab, String type, String title, String body, String? route, bool read, DateTime createdAt
});




}
/// @nodoc
class _$AppNotificationCopyWithImpl<$Res>
    implements $AppNotificationCopyWith<$Res> {
  _$AppNotificationCopyWithImpl(this._self, this._then);

  final AppNotification _self;
  final $Res Function(AppNotification) _then;

/// Create a copy of AppNotification
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? tab = null,Object? type = null,Object? title = null,Object? body = null,Object? route = freezed,Object? read = null,Object? createdAt = null,}) {
  return _then(AppNotification(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tab: null == tab ? _self.tab : tab // ignore: cast_nullable_to_non_nullable
as NotificationTab,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,route: freezed == route ? _self.route : route // ignore: cast_nullable_to_non_nullable
as String?,read: null == read ? _self.read : read // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [AppNotification].
extension AppNotificationPatterns on AppNotification {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppNotification value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppNotification() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppNotification value)  $default,){
final _that = this;
switch (_that) {
case _AppNotification():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppNotification value)?  $default,){
final _that = this;
switch (_that) {
case _AppNotification() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(unknownEnumValue: NotificationTab.unknown)  NotificationTab tab,  String type,  String title,  String body,  String? route,  bool read,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppNotification() when $default != null:
return $default(_that.id,_that.tab,_that.type,_that.title,_that.body,_that.route,_that.read,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(unknownEnumValue: NotificationTab.unknown)  NotificationTab tab,  String type,  String title,  String body,  String? route,  bool read,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _AppNotification():
return $default(_that.id,_that.tab,_that.type,_that.title,_that.body,_that.route,_that.read,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(unknownEnumValue: NotificationTab.unknown)  NotificationTab tab,  String type,  String title,  String body,  String? route,  bool read,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _AppNotification() when $default != null:
return $default(_that.id,_that.tab,_that.type,_that.title,_that.body,_that.route,_that.read,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppNotification implements AppNotification {
  const _AppNotification({required this.id, @JsonKey(unknownEnumValue: NotificationTab.unknown) required this.tab, required this.type, required this.title, required this.body, this.route, this.read = false, required this.createdAt});
  factory _AppNotification.fromJson(Map<String, dynamic> json) => _$AppNotificationFromJson(json);

@override final  String id;
@override@JsonKey(unknownEnumValue: NotificationTab.unknown) final  NotificationTab tab;
@override final  String type;
@override final  String title;
@override final  String body;
@override final  String? route;
@override@JsonKey() final  bool read;
@override final  DateTime createdAt;

/// Create a copy of AppNotification
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppNotificationCopyWith<_AppNotification> get copyWith => __$AppNotificationCopyWithImpl<_AppNotification>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppNotificationToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppNotification&&(identical(other.id, id) || other.id == id)&&(identical(other.tab, tab) || other.tab == tab)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.route, route) || other.route == route)&&(identical(other.read, read) || other.read == read)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,tab,type,title,body,route,read,createdAt);
}

@override
String toString() {
    return 'AppNotification(id: $id, tab: $tab, type: $type, title: $title, body: $body, route: $route, read: $read, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$AppNotificationCopyWith<$Res> implements $AppNotificationCopyWith<$Res> {
  factory _$AppNotificationCopyWith(_AppNotification value, $Res Function(_AppNotification) _then) = __$AppNotificationCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(unknownEnumValue: NotificationTab.unknown) NotificationTab tab, String type, String title, String body, String? route, bool read, DateTime createdAt
});




}
/// @nodoc
class __$AppNotificationCopyWithImpl<$Res>
    implements _$AppNotificationCopyWith<$Res> {
  __$AppNotificationCopyWithImpl(this._self, this._then);

  final _AppNotification _self;
  final $Res Function(_AppNotification) _then;

/// Create a copy of AppNotification
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? tab = null,Object? type = null,Object? title = null,Object? body = null,Object? route = freezed,Object? read = null,Object? createdAt = null,}) {
  return _then(_AppNotification(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tab: null == tab ? _self.tab : tab // ignore: cast_nullable_to_non_nullable
as NotificationTab,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,route: freezed == route ? _self.route : route // ignore: cast_nullable_to_non_nullable
as String?,read: null == read ? _self.read : read // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
