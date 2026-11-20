// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Me {

 String get id; String get name; String get mobile;@JsonKey(unknownEnumValue: Role.unknown) Role get role;@JsonKey(unknownEnumValue: Language.en) Language get language; String? get photoUrl;@JsonKey(unknownEnumValue: VerificationStatus.unknown) VerificationStatus get verificationStatus; int get profileCompletion; double get trustScore; int? get walletBalanceInr; int get pendingRatingsCount; int get unreadNotifications;
/// Create a copy of Me
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MeCopyWith<Me> get copyWith => _$MeCopyWithImpl<Me>(this as Me, _$identity);

  /// Serializes this Me to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Me;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Me&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.mobile, _this.mobile) || other.mobile == _this.mobile)&&(identical(other.role, _this.role) || other.role == _this.role)&&(identical(other.language, _this.language) || other.language == _this.language)&&(identical(other.photoUrl, _this.photoUrl) || other.photoUrl == _this.photoUrl)&&(identical(other.verificationStatus, _this.verificationStatus) || other.verificationStatus == _this.verificationStatus)&&(identical(other.profileCompletion, _this.profileCompletion) || other.profileCompletion == _this.profileCompletion)&&(identical(other.trustScore, _this.trustScore) || other.trustScore == _this.trustScore)&&(identical(other.walletBalanceInr, _this.walletBalanceInr) || other.walletBalanceInr == _this.walletBalanceInr)&&(identical(other.pendingRatingsCount, _this.pendingRatingsCount) || other.pendingRatingsCount == _this.pendingRatingsCount)&&(identical(other.unreadNotifications, _this.unreadNotifications) || other.unreadNotifications == _this.unreadNotifications));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Me;
  return Object.hash(runtimeType,_this.id,_this.name,_this.mobile,_this.role,_this.language,_this.photoUrl,_this.verificationStatus,_this.profileCompletion,_this.trustScore,_this.walletBalanceInr,_this.pendingRatingsCount,_this.unreadNotifications);
}

@override
String toString() {
  final _this = this as Me;
  return 'Me(id: ${_this.id}, name: ${_this.name}, mobile: ${_this.mobile}, role: ${_this.role}, language: ${_this.language}, photoUrl: ${_this.photoUrl}, verificationStatus: ${_this.verificationStatus}, profileCompletion: ${_this.profileCompletion}, trustScore: ${_this.trustScore}, walletBalanceInr: ${_this.walletBalanceInr}, pendingRatingsCount: ${_this.pendingRatingsCount}, unreadNotifications: ${_this.unreadNotifications})';
}


}

/// @nodoc
abstract mixin class $MeCopyWith<$Res>  {
  factory $MeCopyWith(Me value, $Res Function(Me) _then) = _$MeCopyWithImpl;
@useResult
$Res call({
 String id, String name, String mobile,@JsonKey(unknownEnumValue: Role.unknown) Role role,@JsonKey(unknownEnumValue: Language.en) Language language, String? photoUrl,@JsonKey(unknownEnumValue: VerificationStatus.unknown) VerificationStatus verificationStatus, int profileCompletion, double trustScore, int? walletBalanceInr, int pendingRatingsCount, int unreadNotifications
});




}
/// @nodoc
class _$MeCopyWithImpl<$Res>
    implements $MeCopyWith<$Res> {
  _$MeCopyWithImpl(this._self, this._then);

  final Me _self;
  final $Res Function(Me) _then;

/// Create a copy of Me
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? mobile = null,Object? role = null,Object? language = null,Object? photoUrl = freezed,Object? verificationStatus = null,Object? profileCompletion = null,Object? trustScore = null,Object? walletBalanceInr = freezed,Object? pendingRatingsCount = null,Object? unreadNotifications = null,}) {
  return _then(Me(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,mobile: null == mobile ? _self.mobile : mobile // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as Role,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as Language,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,verificationStatus: null == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as VerificationStatus,profileCompletion: null == profileCompletion ? _self.profileCompletion : profileCompletion // ignore: cast_nullable_to_non_nullable
as int,trustScore: null == trustScore ? _self.trustScore : trustScore // ignore: cast_nullable_to_non_nullable
as double,walletBalanceInr: freezed == walletBalanceInr ? _self.walletBalanceInr : walletBalanceInr // ignore: cast_nullable_to_non_nullable
as int?,pendingRatingsCount: null == pendingRatingsCount ? _self.pendingRatingsCount : pendingRatingsCount // ignore: cast_nullable_to_non_nullable
as int,unreadNotifications: null == unreadNotifications ? _self.unreadNotifications : unreadNotifications // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Me].
extension MePatterns on Me {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Me value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Me() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Me value)  $default,){
final _that = this;
switch (_that) {
case _Me():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Me value)?  $default,){
final _that = this;
switch (_that) {
case _Me() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String mobile, @JsonKey(unknownEnumValue: Role.unknown)  Role role, @JsonKey(unknownEnumValue: Language.en)  Language language,  String? photoUrl, @JsonKey(unknownEnumValue: VerificationStatus.unknown)  VerificationStatus verificationStatus,  int profileCompletion,  double trustScore,  int? walletBalanceInr,  int pendingRatingsCount,  int unreadNotifications)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Me() when $default != null:
return $default(_that.id,_that.name,_that.mobile,_that.role,_that.language,_that.photoUrl,_that.verificationStatus,_that.profileCompletion,_that.trustScore,_that.walletBalanceInr,_that.pendingRatingsCount,_that.unreadNotifications);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String mobile, @JsonKey(unknownEnumValue: Role.unknown)  Role role, @JsonKey(unknownEnumValue: Language.en)  Language language,  String? photoUrl, @JsonKey(unknownEnumValue: VerificationStatus.unknown)  VerificationStatus verificationStatus,  int profileCompletion,  double trustScore,  int? walletBalanceInr,  int pendingRatingsCount,  int unreadNotifications)  $default,) {final _that = this;
switch (_that) {
case _Me():
return $default(_that.id,_that.name,_that.mobile,_that.role,_that.language,_that.photoUrl,_that.verificationStatus,_that.profileCompletion,_that.trustScore,_that.walletBalanceInr,_that.pendingRatingsCount,_that.unreadNotifications);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String mobile, @JsonKey(unknownEnumValue: Role.unknown)  Role role, @JsonKey(unknownEnumValue: Language.en)  Language language,  String? photoUrl, @JsonKey(unknownEnumValue: VerificationStatus.unknown)  VerificationStatus verificationStatus,  int profileCompletion,  double trustScore,  int? walletBalanceInr,  int pendingRatingsCount,  int unreadNotifications)?  $default,) {final _that = this;
switch (_that) {
case _Me() when $default != null:
return $default(_that.id,_that.name,_that.mobile,_that.role,_that.language,_that.photoUrl,_that.verificationStatus,_that.profileCompletion,_that.trustScore,_that.walletBalanceInr,_that.pendingRatingsCount,_that.unreadNotifications);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Me implements Me {
  const _Me({required this.id, required this.name, required this.mobile, @JsonKey(unknownEnumValue: Role.unknown) required this.role, @JsonKey(unknownEnumValue: Language.en) this.language = Language.en, this.photoUrl, @JsonKey(unknownEnumValue: VerificationStatus.unknown) this.verificationStatus = VerificationStatus.notSubmitted, this.profileCompletion = 0, this.trustScore = 70, this.walletBalanceInr, this.pendingRatingsCount = 0, this.unreadNotifications = 0});
  factory _Me.fromJson(Map<String, dynamic> json) => _$MeFromJson(json);

@override final  String id;
@override final  String name;
@override final  String mobile;
@override@JsonKey(unknownEnumValue: Role.unknown) final  Role role;
@override@JsonKey(unknownEnumValue: Language.en) final  Language language;
@override final  String? photoUrl;
@override@JsonKey(unknownEnumValue: VerificationStatus.unknown) final  VerificationStatus verificationStatus;
@override@JsonKey() final  int profileCompletion;
@override@JsonKey() final  double trustScore;
@override final  int? walletBalanceInr;
@override@JsonKey() final  int pendingRatingsCount;
@override@JsonKey() final  int unreadNotifications;

/// Create a copy of Me
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MeCopyWith<_Me> get copyWith => __$MeCopyWithImpl<_Me>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MeToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Me&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.mobile, mobile) || other.mobile == mobile)&&(identical(other.role, role) || other.role == role)&&(identical(other.language, language) || other.language == language)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus)&&(identical(other.profileCompletion, profileCompletion) || other.profileCompletion == profileCompletion)&&(identical(other.trustScore, trustScore) || other.trustScore == trustScore)&&(identical(other.walletBalanceInr, walletBalanceInr) || other.walletBalanceInr == walletBalanceInr)&&(identical(other.pendingRatingsCount, pendingRatingsCount) || other.pendingRatingsCount == pendingRatingsCount)&&(identical(other.unreadNotifications, unreadNotifications) || other.unreadNotifications == unreadNotifications));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,mobile,role,language,photoUrl,verificationStatus,profileCompletion,trustScore,walletBalanceInr,pendingRatingsCount,unreadNotifications);
}

@override
String toString() {
    return 'Me(id: $id, name: $name, mobile: $mobile, role: $role, language: $language, photoUrl: $photoUrl, verificationStatus: $verificationStatus, profileCompletion: $profileCompletion, trustScore: $trustScore, walletBalanceInr: $walletBalanceInr, pendingRatingsCount: $pendingRatingsCount, unreadNotifications: $unreadNotifications)';
}


}

/// @nodoc
abstract mixin class _$MeCopyWith<$Res> implements $MeCopyWith<$Res> {
  factory _$MeCopyWith(_Me value, $Res Function(_Me) _then) = __$MeCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String mobile,@JsonKey(unknownEnumValue: Role.unknown) Role role,@JsonKey(unknownEnumValue: Language.en) Language language, String? photoUrl,@JsonKey(unknownEnumValue: VerificationStatus.unknown) VerificationStatus verificationStatus, int profileCompletion, double trustScore, int? walletBalanceInr, int pendingRatingsCount, int unreadNotifications
});




}
/// @nodoc
class __$MeCopyWithImpl<$Res>
    implements _$MeCopyWith<$Res> {
  __$MeCopyWithImpl(this._self, this._then);

  final _Me _self;
  final $Res Function(_Me) _then;

/// Create a copy of Me
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? mobile = null,Object? role = null,Object? language = null,Object? photoUrl = freezed,Object? verificationStatus = null,Object? profileCompletion = null,Object? trustScore = null,Object? walletBalanceInr = freezed,Object? pendingRatingsCount = null,Object? unreadNotifications = null,}) {
  return _then(_Me(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,mobile: null == mobile ? _self.mobile : mobile // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as Role,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as Language,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,verificationStatus: null == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as VerificationStatus,profileCompletion: null == profileCompletion ? _self.profileCompletion : profileCompletion // ignore: cast_nullable_to_non_nullable
as int,trustScore: null == trustScore ? _self.trustScore : trustScore // ignore: cast_nullable_to_non_nullable
as double,walletBalanceInr: freezed == walletBalanceInr ? _self.walletBalanceInr : walletBalanceInr // ignore: cast_nullable_to_non_nullable
as int?,pendingRatingsCount: null == pendingRatingsCount ? _self.pendingRatingsCount : pendingRatingsCount // ignore: cast_nullable_to_non_nullable
as int,unreadNotifications: null == unreadNotifications ? _self.unreadNotifications : unreadNotifications // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$AuthTokens {

 String get accessToken; String get refreshToken; int get expiresIn; Me get user;
/// Create a copy of AuthTokens
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthTokensCopyWith<AuthTokens> get copyWith => _$AuthTokensCopyWithImpl<AuthTokens>(this as AuthTokens, _$identity);

  /// Serializes this AuthTokens to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AuthTokens;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthTokens&&(identical(other.accessToken, _this.accessToken) || other.accessToken == _this.accessToken)&&(identical(other.refreshToken, _this.refreshToken) || other.refreshToken == _this.refreshToken)&&(identical(other.expiresIn, _this.expiresIn) || other.expiresIn == _this.expiresIn)&&(identical(other.user, _this.user) || other.user == _this.user));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AuthTokens;
  return Object.hash(runtimeType,_this.accessToken,_this.refreshToken,_this.expiresIn,_this.user);
}

@override
String toString() {
  final _this = this as AuthTokens;
  return 'AuthTokens(accessToken: ${_this.accessToken}, refreshToken: ${_this.refreshToken}, expiresIn: ${_this.expiresIn}, user: ${_this.user})';
}


}

/// @nodoc
abstract mixin class $AuthTokensCopyWith<$Res>  {
  factory $AuthTokensCopyWith(AuthTokens value, $Res Function(AuthTokens) _then) = _$AuthTokensCopyWithImpl;
@useResult
$Res call({
 String accessToken, String refreshToken, int expiresIn, Me user
});


$MeCopyWith<$Res> get user;

}
/// @nodoc
class _$AuthTokensCopyWithImpl<$Res>
    implements $AuthTokensCopyWith<$Res> {
  _$AuthTokensCopyWithImpl(this._self, this._then);

  final AuthTokens _self;
  final $Res Function(AuthTokens) _then;

/// Create a copy of AuthTokens
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? accessToken = null,Object? refreshToken = null,Object? expiresIn = null,Object? user = null,}) {
  return _then(AuthTokens(
accessToken: null == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String,refreshToken: null == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String,expiresIn: null == expiresIn ? _self.expiresIn : expiresIn // ignore: cast_nullable_to_non_nullable
as int,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as Me,
  ));
}
/// Create a copy of AuthTokens
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MeCopyWith<$Res> get user {
  
  return $MeCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// Adds pattern-matching-related methods to [AuthTokens].
extension AuthTokensPatterns on AuthTokens {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthTokens value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthTokens() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthTokens value)  $default,){
final _that = this;
switch (_that) {
case _AuthTokens():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthTokens value)?  $default,){
final _that = this;
switch (_that) {
case _AuthTokens() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String accessToken,  String refreshToken,  int expiresIn,  Me user)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthTokens() when $default != null:
return $default(_that.accessToken,_that.refreshToken,_that.expiresIn,_that.user);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String accessToken,  String refreshToken,  int expiresIn,  Me user)  $default,) {final _that = this;
switch (_that) {
case _AuthTokens():
return $default(_that.accessToken,_that.refreshToken,_that.expiresIn,_that.user);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String accessToken,  String refreshToken,  int expiresIn,  Me user)?  $default,) {final _that = this;
switch (_that) {
case _AuthTokens() when $default != null:
return $default(_that.accessToken,_that.refreshToken,_that.expiresIn,_that.user);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuthTokens implements AuthTokens {
  const _AuthTokens({required this.accessToken, required this.refreshToken, required this.expiresIn, required this.user});
  factory _AuthTokens.fromJson(Map<String, dynamic> json) => _$AuthTokensFromJson(json);

@override final  String accessToken;
@override final  String refreshToken;
@override final  int expiresIn;
@override final  Me user;

/// Create a copy of AuthTokens
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthTokensCopyWith<_AuthTokens> get copyWith => __$AuthTokensCopyWithImpl<_AuthTokens>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuthTokensToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthTokens&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken)&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken)&&(identical(other.expiresIn, expiresIn) || other.expiresIn == expiresIn)&&(identical(other.user, user) || other.user == user));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,accessToken,refreshToken,expiresIn,user);
}

@override
String toString() {
    return 'AuthTokens(accessToken: $accessToken, refreshToken: $refreshToken, expiresIn: $expiresIn, user: $user)';
}


}

/// @nodoc
abstract mixin class _$AuthTokensCopyWith<$Res> implements $AuthTokensCopyWith<$Res> {
  factory _$AuthTokensCopyWith(_AuthTokens value, $Res Function(_AuthTokens) _then) = __$AuthTokensCopyWithImpl;
@override @useResult
$Res call({
 String accessToken, String refreshToken, int expiresIn, Me user
});


@override $MeCopyWith<$Res> get user;

}
/// @nodoc
class __$AuthTokensCopyWithImpl<$Res>
    implements _$AuthTokensCopyWith<$Res> {
  __$AuthTokensCopyWithImpl(this._self, this._then);

  final _AuthTokens _self;
  final $Res Function(_AuthTokens) _then;

/// Create a copy of AuthTokens
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? accessToken = null,Object? refreshToken = null,Object? expiresIn = null,Object? user = null,}) {
  return _then(_AuthTokens(
accessToken: null == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String,refreshToken: null == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String,expiresIn: null == expiresIn ? _self.expiresIn : expiresIn // ignore: cast_nullable_to_non_nullable
as int,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as Me,
  ));
}

/// Create a copy of AuthTokens
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MeCopyWith<$Res> get user {
  
  return $MeCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}

// dart format on
