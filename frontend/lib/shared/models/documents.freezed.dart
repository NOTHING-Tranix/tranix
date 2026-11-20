// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'documents.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Document {

 String get id;@JsonKey(unknownEnumValue: DocumentType.unknown) DocumentType get type; String? get numberMasked; String? get expiresOn;@JsonKey(unknownEnumValue: DocumentStatus.unknown) DocumentStatus get status; String? get rejectReason; String? get viewUrl;
/// Create a copy of Document
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DocumentCopyWith<Document> get copyWith => _$DocumentCopyWithImpl<Document>(this as Document, _$identity);

  /// Serializes this Document to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Document;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Document&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.numberMasked, _this.numberMasked) || other.numberMasked == _this.numberMasked)&&(identical(other.expiresOn, _this.expiresOn) || other.expiresOn == _this.expiresOn)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.rejectReason, _this.rejectReason) || other.rejectReason == _this.rejectReason)&&(identical(other.viewUrl, _this.viewUrl) || other.viewUrl == _this.viewUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Document;
  return Object.hash(runtimeType,_this.id,_this.type,_this.numberMasked,_this.expiresOn,_this.status,_this.rejectReason,_this.viewUrl);
}

@override
String toString() {
  final _this = this as Document;
  return 'Document(id: ${_this.id}, type: ${_this.type}, numberMasked: ${_this.numberMasked}, expiresOn: ${_this.expiresOn}, status: ${_this.status}, rejectReason: ${_this.rejectReason}, viewUrl: ${_this.viewUrl})';
}


}

/// @nodoc
abstract mixin class $DocumentCopyWith<$Res>  {
  factory $DocumentCopyWith(Document value, $Res Function(Document) _then) = _$DocumentCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(unknownEnumValue: DocumentType.unknown) DocumentType type, String? numberMasked, String? expiresOn,@JsonKey(unknownEnumValue: DocumentStatus.unknown) DocumentStatus status, String? rejectReason, String? viewUrl
});




}
/// @nodoc
class _$DocumentCopyWithImpl<$Res>
    implements $DocumentCopyWith<$Res> {
  _$DocumentCopyWithImpl(this._self, this._then);

  final Document _self;
  final $Res Function(Document) _then;

/// Create a copy of Document
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? numberMasked = freezed,Object? expiresOn = freezed,Object? status = null,Object? rejectReason = freezed,Object? viewUrl = freezed,}) {
  return _then(Document(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as DocumentType,numberMasked: freezed == numberMasked ? _self.numberMasked : numberMasked // ignore: cast_nullable_to_non_nullable
as String?,expiresOn: freezed == expiresOn ? _self.expiresOn : expiresOn // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DocumentStatus,rejectReason: freezed == rejectReason ? _self.rejectReason : rejectReason // ignore: cast_nullable_to_non_nullable
as String?,viewUrl: freezed == viewUrl ? _self.viewUrl : viewUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Document].
extension DocumentPatterns on Document {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Document value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Document() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Document value)  $default,){
final _that = this;
switch (_that) {
case _Document():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Document value)?  $default,){
final _that = this;
switch (_that) {
case _Document() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(unknownEnumValue: DocumentType.unknown)  DocumentType type,  String? numberMasked,  String? expiresOn, @JsonKey(unknownEnumValue: DocumentStatus.unknown)  DocumentStatus status,  String? rejectReason,  String? viewUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Document() when $default != null:
return $default(_that.id,_that.type,_that.numberMasked,_that.expiresOn,_that.status,_that.rejectReason,_that.viewUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(unknownEnumValue: DocumentType.unknown)  DocumentType type,  String? numberMasked,  String? expiresOn, @JsonKey(unknownEnumValue: DocumentStatus.unknown)  DocumentStatus status,  String? rejectReason,  String? viewUrl)  $default,) {final _that = this;
switch (_that) {
case _Document():
return $default(_that.id,_that.type,_that.numberMasked,_that.expiresOn,_that.status,_that.rejectReason,_that.viewUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(unknownEnumValue: DocumentType.unknown)  DocumentType type,  String? numberMasked,  String? expiresOn, @JsonKey(unknownEnumValue: DocumentStatus.unknown)  DocumentStatus status,  String? rejectReason,  String? viewUrl)?  $default,) {final _that = this;
switch (_that) {
case _Document() when $default != null:
return $default(_that.id,_that.type,_that.numberMasked,_that.expiresOn,_that.status,_that.rejectReason,_that.viewUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Document implements Document {
  const _Document({required this.id, @JsonKey(unknownEnumValue: DocumentType.unknown) required this.type, this.numberMasked, this.expiresOn, @JsonKey(unknownEnumValue: DocumentStatus.unknown) required this.status, this.rejectReason, this.viewUrl});
  factory _Document.fromJson(Map<String, dynamic> json) => _$DocumentFromJson(json);

@override final  String id;
@override@JsonKey(unknownEnumValue: DocumentType.unknown) final  DocumentType type;
@override final  String? numberMasked;
@override final  String? expiresOn;
@override@JsonKey(unknownEnumValue: DocumentStatus.unknown) final  DocumentStatus status;
@override final  String? rejectReason;
@override final  String? viewUrl;

/// Create a copy of Document
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DocumentCopyWith<_Document> get copyWith => __$DocumentCopyWithImpl<_Document>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DocumentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Document&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.numberMasked, numberMasked) || other.numberMasked == numberMasked)&&(identical(other.expiresOn, expiresOn) || other.expiresOn == expiresOn)&&(identical(other.status, status) || other.status == status)&&(identical(other.rejectReason, rejectReason) || other.rejectReason == rejectReason)&&(identical(other.viewUrl, viewUrl) || other.viewUrl == viewUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,type,numberMasked,expiresOn,status,rejectReason,viewUrl);
}

@override
String toString() {
    return 'Document(id: $id, type: $type, numberMasked: $numberMasked, expiresOn: $expiresOn, status: $status, rejectReason: $rejectReason, viewUrl: $viewUrl)';
}


}

/// @nodoc
abstract mixin class _$DocumentCopyWith<$Res> implements $DocumentCopyWith<$Res> {
  factory _$DocumentCopyWith(_Document value, $Res Function(_Document) _then) = __$DocumentCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(unknownEnumValue: DocumentType.unknown) DocumentType type, String? numberMasked, String? expiresOn,@JsonKey(unknownEnumValue: DocumentStatus.unknown) DocumentStatus status, String? rejectReason, String? viewUrl
});




}
/// @nodoc
class __$DocumentCopyWithImpl<$Res>
    implements _$DocumentCopyWith<$Res> {
  __$DocumentCopyWithImpl(this._self, this._then);

  final _Document _self;
  final $Res Function(_Document) _then;

/// Create a copy of Document
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? numberMasked = freezed,Object? expiresOn = freezed,Object? status = null,Object? rejectReason = freezed,Object? viewUrl = freezed,}) {
  return _then(_Document(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as DocumentType,numberMasked: freezed == numberMasked ? _self.numberMasked : numberMasked // ignore: cast_nullable_to_non_nullable
as String?,expiresOn: freezed == expiresOn ? _self.expiresOn : expiresOn // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DocumentStatus,rejectReason: freezed == rejectReason ? _self.rejectReason : rejectReason // ignore: cast_nullable_to_non_nullable
as String?,viewUrl: freezed == viewUrl ? _self.viewUrl : viewUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$VerificationItem {

 String get key; String get label; bool get done; int get weight;
/// Create a copy of VerificationItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VerificationItemCopyWith<VerificationItem> get copyWith => _$VerificationItemCopyWithImpl<VerificationItem>(this as VerificationItem, _$identity);

  /// Serializes this VerificationItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as VerificationItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VerificationItem&&(identical(other.key, _this.key) || other.key == _this.key)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.done, _this.done) || other.done == _this.done)&&(identical(other.weight, _this.weight) || other.weight == _this.weight));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as VerificationItem;
  return Object.hash(runtimeType,_this.key,_this.label,_this.done,_this.weight);
}

@override
String toString() {
  final _this = this as VerificationItem;
  return 'VerificationItem(key: ${_this.key}, label: ${_this.label}, done: ${_this.done}, weight: ${_this.weight})';
}


}

/// @nodoc
abstract mixin class $VerificationItemCopyWith<$Res>  {
  factory $VerificationItemCopyWith(VerificationItem value, $Res Function(VerificationItem) _then) = _$VerificationItemCopyWithImpl;
@useResult
$Res call({
 String key, String label, bool done, int weight
});




}
/// @nodoc
class _$VerificationItemCopyWithImpl<$Res>
    implements $VerificationItemCopyWith<$Res> {
  _$VerificationItemCopyWithImpl(this._self, this._then);

  final VerificationItem _self;
  final $Res Function(VerificationItem) _then;

/// Create a copy of VerificationItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,Object? label = null,Object? done = null,Object? weight = null,}) {
  return _then(VerificationItem(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,done: null == done ? _self.done : done // ignore: cast_nullable_to_non_nullable
as bool,weight: null == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [VerificationItem].
extension VerificationItemPatterns on VerificationItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VerificationItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VerificationItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VerificationItem value)  $default,){
final _that = this;
switch (_that) {
case _VerificationItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VerificationItem value)?  $default,){
final _that = this;
switch (_that) {
case _VerificationItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String key,  String label,  bool done,  int weight)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VerificationItem() when $default != null:
return $default(_that.key,_that.label,_that.done,_that.weight);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String key,  String label,  bool done,  int weight)  $default,) {final _that = this;
switch (_that) {
case _VerificationItem():
return $default(_that.key,_that.label,_that.done,_that.weight);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String key,  String label,  bool done,  int weight)?  $default,) {final _that = this;
switch (_that) {
case _VerificationItem() when $default != null:
return $default(_that.key,_that.label,_that.done,_that.weight);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VerificationItem implements VerificationItem {
  const _VerificationItem({required this.key, required this.label, required this.done, required this.weight});
  factory _VerificationItem.fromJson(Map<String, dynamic> json) => _$VerificationItemFromJson(json);

@override final  String key;
@override final  String label;
@override final  bool done;
@override final  int weight;

/// Create a copy of VerificationItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VerificationItemCopyWith<_VerificationItem> get copyWith => __$VerificationItemCopyWithImpl<_VerificationItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VerificationItemToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VerificationItem&&(identical(other.key, key) || other.key == key)&&(identical(other.label, label) || other.label == label)&&(identical(other.done, done) || other.done == done)&&(identical(other.weight, weight) || other.weight == weight));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,key,label,done,weight);
}

@override
String toString() {
    return 'VerificationItem(key: $key, label: $label, done: $done, weight: $weight)';
}


}

/// @nodoc
abstract mixin class _$VerificationItemCopyWith<$Res> implements $VerificationItemCopyWith<$Res> {
  factory _$VerificationItemCopyWith(_VerificationItem value, $Res Function(_VerificationItem) _then) = __$VerificationItemCopyWithImpl;
@override @useResult
$Res call({
 String key, String label, bool done, int weight
});




}
/// @nodoc
class __$VerificationItemCopyWithImpl<$Res>
    implements _$VerificationItemCopyWith<$Res> {
  __$VerificationItemCopyWithImpl(this._self, this._then);

  final _VerificationItem _self;
  final $Res Function(_VerificationItem) _then;

/// Create a copy of VerificationItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,Object? label = null,Object? done = null,Object? weight = null,}) {
  return _then(_VerificationItem(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,done: null == done ? _self.done : done // ignore: cast_nullable_to_non_nullable
as bool,weight: null == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$VerificationInfo {

@JsonKey(unknownEnumValue: VerificationStatus.unknown) VerificationStatus get status; List<VerificationItem> get items; List<Document> get documents; int? get estimatedReviewHours;
/// Create a copy of VerificationInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VerificationInfoCopyWith<VerificationInfo> get copyWith => _$VerificationInfoCopyWithImpl<VerificationInfo>(this as VerificationInfo, _$identity);

  /// Serializes this VerificationInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as VerificationInfo;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VerificationInfo&&(identical(other.status, _this.status) || other.status == _this.status)&&const DeepCollectionEquality().equals(other.items, _this.items)&&const DeepCollectionEquality().equals(other.documents, _this.documents)&&(identical(other.estimatedReviewHours, _this.estimatedReviewHours) || other.estimatedReviewHours == _this.estimatedReviewHours));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as VerificationInfo;
  return Object.hash(runtimeType,_this.status,const DeepCollectionEquality().hash(_this.items),const DeepCollectionEquality().hash(_this.documents),_this.estimatedReviewHours);
}

@override
String toString() {
  final _this = this as VerificationInfo;
  return 'VerificationInfo(status: ${_this.status}, items: ${_this.items}, documents: ${_this.documents}, estimatedReviewHours: ${_this.estimatedReviewHours})';
}


}

/// @nodoc
abstract mixin class $VerificationInfoCopyWith<$Res>  {
  factory $VerificationInfoCopyWith(VerificationInfo value, $Res Function(VerificationInfo) _then) = _$VerificationInfoCopyWithImpl;
@useResult
$Res call({
@JsonKey(unknownEnumValue: VerificationStatus.unknown) VerificationStatus status, List<VerificationItem> items, List<Document> documents, int? estimatedReviewHours
});




}
/// @nodoc
class _$VerificationInfoCopyWithImpl<$Res>
    implements $VerificationInfoCopyWith<$Res> {
  _$VerificationInfoCopyWithImpl(this._self, this._then);

  final VerificationInfo _self;
  final $Res Function(VerificationInfo) _then;

/// Create a copy of VerificationInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? items = null,Object? documents = null,Object? estimatedReviewHours = freezed,}) {
  return _then(VerificationInfo(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as VerificationStatus,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<VerificationItem>,documents: null == documents ? _self.documents : documents // ignore: cast_nullable_to_non_nullable
as List<Document>,estimatedReviewHours: freezed == estimatedReviewHours ? _self.estimatedReviewHours : estimatedReviewHours // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [VerificationInfo].
extension VerificationInfoPatterns on VerificationInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VerificationInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VerificationInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VerificationInfo value)  $default,){
final _that = this;
switch (_that) {
case _VerificationInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VerificationInfo value)?  $default,){
final _that = this;
switch (_that) {
case _VerificationInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: VerificationStatus.unknown)  VerificationStatus status,  List<VerificationItem> items,  List<Document> documents,  int? estimatedReviewHours)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VerificationInfo() when $default != null:
return $default(_that.status,_that.items,_that.documents,_that.estimatedReviewHours);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: VerificationStatus.unknown)  VerificationStatus status,  List<VerificationItem> items,  List<Document> documents,  int? estimatedReviewHours)  $default,) {final _that = this;
switch (_that) {
case _VerificationInfo():
return $default(_that.status,_that.items,_that.documents,_that.estimatedReviewHours);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(unknownEnumValue: VerificationStatus.unknown)  VerificationStatus status,  List<VerificationItem> items,  List<Document> documents,  int? estimatedReviewHours)?  $default,) {final _that = this;
switch (_that) {
case _VerificationInfo() when $default != null:
return $default(_that.status,_that.items,_that.documents,_that.estimatedReviewHours);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VerificationInfo implements VerificationInfo {
  const _VerificationInfo({@JsonKey(unknownEnumValue: VerificationStatus.unknown) required this.status,  List<VerificationItem> items = const <VerificationItem>[],  List<Document> documents = const <Document>[], this.estimatedReviewHours}): _items = items,_documents = documents;
  factory _VerificationInfo.fromJson(Map<String, dynamic> json) => _$VerificationInfoFromJson(json);

@override@JsonKey(unknownEnumValue: VerificationStatus.unknown) final  VerificationStatus status;
 final  List<VerificationItem> _items;
@override@JsonKey() List<VerificationItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

 final  List<Document> _documents;
@override@JsonKey() List<Document> get documents {
  if (_documents is EqualUnmodifiableListView) return _documents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_documents);
}

@override final  int? estimatedReviewHours;

/// Create a copy of VerificationInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VerificationInfoCopyWith<_VerificationInfo> get copyWith => __$VerificationInfoCopyWithImpl<_VerificationInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VerificationInfoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VerificationInfo&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.items, _items)&&const DeepCollectionEquality().equals(other.documents, _documents)&&(identical(other.estimatedReviewHours, estimatedReviewHours) || other.estimatedReviewHours == estimatedReviewHours));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,status,const DeepCollectionEquality().hash(_items),const DeepCollectionEquality().hash(_documents),estimatedReviewHours);
}

@override
String toString() {
    return 'VerificationInfo(status: $status, items: $items, documents: $documents, estimatedReviewHours: $estimatedReviewHours)';
}


}

/// @nodoc
abstract mixin class _$VerificationInfoCopyWith<$Res> implements $VerificationInfoCopyWith<$Res> {
  factory _$VerificationInfoCopyWith(_VerificationInfo value, $Res Function(_VerificationInfo) _then) = __$VerificationInfoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(unknownEnumValue: VerificationStatus.unknown) VerificationStatus status, List<VerificationItem> items, List<Document> documents, int? estimatedReviewHours
});




}
/// @nodoc
class __$VerificationInfoCopyWithImpl<$Res>
    implements _$VerificationInfoCopyWith<$Res> {
  __$VerificationInfoCopyWithImpl(this._self, this._then);

  final _VerificationInfo _self;
  final $Res Function(_VerificationInfo) _then;

/// Create a copy of VerificationInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? items = null,Object? documents = null,Object? estimatedReviewHours = freezed,}) {
  return _then(_VerificationInfo(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as VerificationStatus,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<VerificationItem>,documents: null == documents ? _self._documents : documents // ignore: cast_nullable_to_non_nullable
as List<Document>,estimatedReviewHours: freezed == estimatedReviewHours ? _self.estimatedReviewHours : estimatedReviewHours // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
