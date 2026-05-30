// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_account_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AuthAccountState {

 bool get isSubmitting; bool get isSendingCode; String? get errorMessage; String? get successMessage; int? get lastCooldownSeconds;
/// Create a copy of AuthAccountState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthAccountStateCopyWith<AuthAccountState> get copyWith => _$AuthAccountStateCopyWithImpl<AuthAccountState>(this as AuthAccountState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthAccountState&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting)&&(identical(other.isSendingCode, isSendingCode) || other.isSendingCode == isSendingCode)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.successMessage, successMessage) || other.successMessage == successMessage)&&(identical(other.lastCooldownSeconds, lastCooldownSeconds) || other.lastCooldownSeconds == lastCooldownSeconds));
}


@override
int get hashCode => Object.hash(runtimeType,isSubmitting,isSendingCode,errorMessage,successMessage,lastCooldownSeconds);

@override
String toString() {
  return 'AuthAccountState(isSubmitting: $isSubmitting, isSendingCode: $isSendingCode, errorMessage: $errorMessage, successMessage: $successMessage, lastCooldownSeconds: $lastCooldownSeconds)';
}


}

/// @nodoc
abstract mixin class $AuthAccountStateCopyWith<$Res>  {
  factory $AuthAccountStateCopyWith(AuthAccountState value, $Res Function(AuthAccountState) _then) = _$AuthAccountStateCopyWithImpl;
@useResult
$Res call({
 bool isSubmitting, bool isSendingCode, String? errorMessage, String? successMessage, int? lastCooldownSeconds
});




}
/// @nodoc
class _$AuthAccountStateCopyWithImpl<$Res>
    implements $AuthAccountStateCopyWith<$Res> {
  _$AuthAccountStateCopyWithImpl(this._self, this._then);

  final AuthAccountState _self;
  final $Res Function(AuthAccountState) _then;

/// Create a copy of AuthAccountState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isSubmitting = null,Object? isSendingCode = null,Object? errorMessage = freezed,Object? successMessage = freezed,Object? lastCooldownSeconds = freezed,}) {
  return _then(_self.copyWith(
isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,isSendingCode: null == isSendingCode ? _self.isSendingCode : isSendingCode // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,successMessage: freezed == successMessage ? _self.successMessage : successMessage // ignore: cast_nullable_to_non_nullable
as String?,lastCooldownSeconds: freezed == lastCooldownSeconds ? _self.lastCooldownSeconds : lastCooldownSeconds // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [AuthAccountState].
extension AuthAccountStatePatterns on AuthAccountState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthAccountState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthAccountState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthAccountState value)  $default,){
final _that = this;
switch (_that) {
case _AuthAccountState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthAccountState value)?  $default,){
final _that = this;
switch (_that) {
case _AuthAccountState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isSubmitting,  bool isSendingCode,  String? errorMessage,  String? successMessage,  int? lastCooldownSeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthAccountState() when $default != null:
return $default(_that.isSubmitting,_that.isSendingCode,_that.errorMessage,_that.successMessage,_that.lastCooldownSeconds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isSubmitting,  bool isSendingCode,  String? errorMessage,  String? successMessage,  int? lastCooldownSeconds)  $default,) {final _that = this;
switch (_that) {
case _AuthAccountState():
return $default(_that.isSubmitting,_that.isSendingCode,_that.errorMessage,_that.successMessage,_that.lastCooldownSeconds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isSubmitting,  bool isSendingCode,  String? errorMessage,  String? successMessage,  int? lastCooldownSeconds)?  $default,) {final _that = this;
switch (_that) {
case _AuthAccountState() when $default != null:
return $default(_that.isSubmitting,_that.isSendingCode,_that.errorMessage,_that.successMessage,_that.lastCooldownSeconds);case _:
  return null;

}
}

}

/// @nodoc


class _AuthAccountState implements AuthAccountState {
  const _AuthAccountState({this.isSubmitting = false, this.isSendingCode = false, this.errorMessage, this.successMessage, this.lastCooldownSeconds});
  

@override@JsonKey() final  bool isSubmitting;
@override@JsonKey() final  bool isSendingCode;
@override final  String? errorMessage;
@override final  String? successMessage;
@override final  int? lastCooldownSeconds;

/// Create a copy of AuthAccountState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthAccountStateCopyWith<_AuthAccountState> get copyWith => __$AuthAccountStateCopyWithImpl<_AuthAccountState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthAccountState&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting)&&(identical(other.isSendingCode, isSendingCode) || other.isSendingCode == isSendingCode)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.successMessage, successMessage) || other.successMessage == successMessage)&&(identical(other.lastCooldownSeconds, lastCooldownSeconds) || other.lastCooldownSeconds == lastCooldownSeconds));
}


@override
int get hashCode => Object.hash(runtimeType,isSubmitting,isSendingCode,errorMessage,successMessage,lastCooldownSeconds);

@override
String toString() {
  return 'AuthAccountState(isSubmitting: $isSubmitting, isSendingCode: $isSendingCode, errorMessage: $errorMessage, successMessage: $successMessage, lastCooldownSeconds: $lastCooldownSeconds)';
}


}

/// @nodoc
abstract mixin class _$AuthAccountStateCopyWith<$Res> implements $AuthAccountStateCopyWith<$Res> {
  factory _$AuthAccountStateCopyWith(_AuthAccountState value, $Res Function(_AuthAccountState) _then) = __$AuthAccountStateCopyWithImpl;
@override @useResult
$Res call({
 bool isSubmitting, bool isSendingCode, String? errorMessage, String? successMessage, int? lastCooldownSeconds
});




}
/// @nodoc
class __$AuthAccountStateCopyWithImpl<$Res>
    implements _$AuthAccountStateCopyWith<$Res> {
  __$AuthAccountStateCopyWithImpl(this._self, this._then);

  final _AuthAccountState _self;
  final $Res Function(_AuthAccountState) _then;

/// Create a copy of AuthAccountState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isSubmitting = null,Object? isSendingCode = null,Object? errorMessage = freezed,Object? successMessage = freezed,Object? lastCooldownSeconds = freezed,}) {
  return _then(_AuthAccountState(
isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,isSendingCode: null == isSendingCode ? _self.isSendingCode : isSendingCode // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,successMessage: freezed == successMessage ? _self.successMessage : successMessage // ignore: cast_nullable_to_non_nullable
as String?,lastCooldownSeconds: freezed == lastCooldownSeconds ? _self.lastCooldownSeconds : lastCooldownSeconds // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
