// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'baustelle_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Baustelle {

 String get id;@JsonKey(name: 'company_id') String get companyId; String get name;@JsonKey(name: 'client_name') String get clientName; String get address; String get status; double get budget;@JsonKey(name: 'created_at') DateTime get createdAt;
/// Create a copy of Baustelle
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BaustelleCopyWith<Baustelle> get copyWith => _$BaustelleCopyWithImpl<Baustelle>(this as Baustelle, _$identity);

  /// Serializes this Baustelle to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Baustelle&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.name, name) || other.name == name)&&(identical(other.clientName, clientName) || other.clientName == clientName)&&(identical(other.address, address) || other.address == address)&&(identical(other.status, status) || other.status == status)&&(identical(other.budget, budget) || other.budget == budget)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,companyId,name,clientName,address,status,budget,createdAt);

@override
String toString() {
  return 'Baustelle(id: $id, companyId: $companyId, name: $name, clientName: $clientName, address: $address, status: $status, budget: $budget, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $BaustelleCopyWith<$Res>  {
  factory $BaustelleCopyWith(Baustelle value, $Res Function(Baustelle) _then) = _$BaustelleCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'company_id') String companyId, String name,@JsonKey(name: 'client_name') String clientName, String address, String status, double budget,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class _$BaustelleCopyWithImpl<$Res>
    implements $BaustelleCopyWith<$Res> {
  _$BaustelleCopyWithImpl(this._self, this._then);

  final Baustelle _self;
  final $Res Function(Baustelle) _then;

/// Create a copy of Baustelle
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? companyId = null,Object? name = null,Object? clientName = null,Object? address = null,Object? status = null,Object? budget = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,clientName: null == clientName ? _self.clientName : clientName // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,budget: null == budget ? _self.budget : budget // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Baustelle].
extension BaustellePatterns on Baustelle {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Baustelle value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Baustelle() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Baustelle value)  $default,){
final _that = this;
switch (_that) {
case _Baustelle():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Baustelle value)?  $default,){
final _that = this;
switch (_that) {
case _Baustelle() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'company_id')  String companyId,  String name, @JsonKey(name: 'client_name')  String clientName,  String address,  String status,  double budget, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Baustelle() when $default != null:
return $default(_that.id,_that.companyId,_that.name,_that.clientName,_that.address,_that.status,_that.budget,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'company_id')  String companyId,  String name, @JsonKey(name: 'client_name')  String clientName,  String address,  String status,  double budget, @JsonKey(name: 'created_at')  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Baustelle():
return $default(_that.id,_that.companyId,_that.name,_that.clientName,_that.address,_that.status,_that.budget,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'company_id')  String companyId,  String name, @JsonKey(name: 'client_name')  String clientName,  String address,  String status,  double budget, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Baustelle() when $default != null:
return $default(_that.id,_that.companyId,_that.name,_that.clientName,_that.address,_that.status,_that.budget,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Baustelle implements Baustelle {
  const _Baustelle({required this.id, @JsonKey(name: 'company_id') required this.companyId, required this.name, @JsonKey(name: 'client_name') required this.clientName, required this.address, required this.status, required this.budget, @JsonKey(name: 'created_at') required this.createdAt});
  factory _Baustelle.fromJson(Map<String, dynamic> json) => _$BaustelleFromJson(json);

@override final  String id;
@override@JsonKey(name: 'company_id') final  String companyId;
@override final  String name;
@override@JsonKey(name: 'client_name') final  String clientName;
@override final  String address;
@override final  String status;
@override final  double budget;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;

/// Create a copy of Baustelle
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BaustelleCopyWith<_Baustelle> get copyWith => __$BaustelleCopyWithImpl<_Baustelle>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BaustelleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Baustelle&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.name, name) || other.name == name)&&(identical(other.clientName, clientName) || other.clientName == clientName)&&(identical(other.address, address) || other.address == address)&&(identical(other.status, status) || other.status == status)&&(identical(other.budget, budget) || other.budget == budget)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,companyId,name,clientName,address,status,budget,createdAt);

@override
String toString() {
  return 'Baustelle(id: $id, companyId: $companyId, name: $name, clientName: $clientName, address: $address, status: $status, budget: $budget, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$BaustelleCopyWith<$Res> implements $BaustelleCopyWith<$Res> {
  factory _$BaustelleCopyWith(_Baustelle value, $Res Function(_Baustelle) _then) = __$BaustelleCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'company_id') String companyId, String name,@JsonKey(name: 'client_name') String clientName, String address, String status, double budget,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class __$BaustelleCopyWithImpl<$Res>
    implements _$BaustelleCopyWith<$Res> {
  __$BaustelleCopyWithImpl(this._self, this._then);

  final _Baustelle _self;
  final $Res Function(_Baustelle) _then;

/// Create a copy of Baustelle
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? companyId = null,Object? name = null,Object? clientName = null,Object? address = null,Object? status = null,Object? budget = null,Object? createdAt = null,}) {
  return _then(_Baustelle(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,clientName: null == clientName ? _self.clientName : clientName // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,budget: null == budget ? _self.budget : budget // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
