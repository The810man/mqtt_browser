// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_state_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppStateData {

 String get host; String get port; int get selectedTabIndex; String get publishMessage; String get codeBoxButtonState;
/// Create a copy of AppStateData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppStateDataCopyWith<AppStateData> get copyWith => _$AppStateDataCopyWithImpl<AppStateData>(this as AppStateData, _$identity);

  /// Serializes this AppStateData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppStateData&&(identical(other.host, host) || other.host == host)&&(identical(other.port, port) || other.port == port)&&(identical(other.selectedTabIndex, selectedTabIndex) || other.selectedTabIndex == selectedTabIndex)&&(identical(other.publishMessage, publishMessage) || other.publishMessage == publishMessage)&&(identical(other.codeBoxButtonState, codeBoxButtonState) || other.codeBoxButtonState == codeBoxButtonState));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,host,port,selectedTabIndex,publishMessage,codeBoxButtonState);

@override
String toString() {
  return 'AppStateData(host: $host, port: $port, selectedTabIndex: $selectedTabIndex, publishMessage: $publishMessage, codeBoxButtonState: $codeBoxButtonState)';
}


}

/// @nodoc
abstract mixin class $AppStateDataCopyWith<$Res>  {
  factory $AppStateDataCopyWith(AppStateData value, $Res Function(AppStateData) _then) = _$AppStateDataCopyWithImpl;
@useResult
$Res call({
 String host, String port, int selectedTabIndex, String publishMessage, String codeBoxButtonState
});




}
/// @nodoc
class _$AppStateDataCopyWithImpl<$Res>
    implements $AppStateDataCopyWith<$Res> {
  _$AppStateDataCopyWithImpl(this._self, this._then);

  final AppStateData _self;
  final $Res Function(AppStateData) _then;

/// Create a copy of AppStateData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? host = null,Object? port = null,Object? selectedTabIndex = null,Object? publishMessage = null,Object? codeBoxButtonState = null,}) {
  return _then(_self.copyWith(
host: null == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String,port: null == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as String,selectedTabIndex: null == selectedTabIndex ? _self.selectedTabIndex : selectedTabIndex // ignore: cast_nullable_to_non_nullable
as int,publishMessage: null == publishMessage ? _self.publishMessage : publishMessage // ignore: cast_nullable_to_non_nullable
as String,codeBoxButtonState: null == codeBoxButtonState ? _self.codeBoxButtonState : codeBoxButtonState // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AppStateData].
extension AppStateDataPatterns on AppStateData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppStateData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppStateData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppStateData value)  $default,){
final _that = this;
switch (_that) {
case _AppStateData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppStateData value)?  $default,){
final _that = this;
switch (_that) {
case _AppStateData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String host,  String port,  int selectedTabIndex,  String publishMessage,  String codeBoxButtonState)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppStateData() when $default != null:
return $default(_that.host,_that.port,_that.selectedTabIndex,_that.publishMessage,_that.codeBoxButtonState);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String host,  String port,  int selectedTabIndex,  String publishMessage,  String codeBoxButtonState)  $default,) {final _that = this;
switch (_that) {
case _AppStateData():
return $default(_that.host,_that.port,_that.selectedTabIndex,_that.publishMessage,_that.codeBoxButtonState);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String host,  String port,  int selectedTabIndex,  String publishMessage,  String codeBoxButtonState)?  $default,) {final _that = this;
switch (_that) {
case _AppStateData() when $default != null:
return $default(_that.host,_that.port,_that.selectedTabIndex,_that.publishMessage,_that.codeBoxButtonState);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppStateData implements AppStateData {
  const _AppStateData({this.host = 'localhost', this.port = '1883', this.selectedTabIndex = 0, this.publishMessage = '', this.codeBoxButtonState = 'raw'});
  factory _AppStateData.fromJson(Map<String, dynamic> json) => _$AppStateDataFromJson(json);

@override@JsonKey() final  String host;
@override@JsonKey() final  String port;
@override@JsonKey() final  int selectedTabIndex;
@override@JsonKey() final  String publishMessage;
@override@JsonKey() final  String codeBoxButtonState;

/// Create a copy of AppStateData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppStateDataCopyWith<_AppStateData> get copyWith => __$AppStateDataCopyWithImpl<_AppStateData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppStateDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppStateData&&(identical(other.host, host) || other.host == host)&&(identical(other.port, port) || other.port == port)&&(identical(other.selectedTabIndex, selectedTabIndex) || other.selectedTabIndex == selectedTabIndex)&&(identical(other.publishMessage, publishMessage) || other.publishMessage == publishMessage)&&(identical(other.codeBoxButtonState, codeBoxButtonState) || other.codeBoxButtonState == codeBoxButtonState));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,host,port,selectedTabIndex,publishMessage,codeBoxButtonState);

@override
String toString() {
  return 'AppStateData(host: $host, port: $port, selectedTabIndex: $selectedTabIndex, publishMessage: $publishMessage, codeBoxButtonState: $codeBoxButtonState)';
}


}

/// @nodoc
abstract mixin class _$AppStateDataCopyWith<$Res> implements $AppStateDataCopyWith<$Res> {
  factory _$AppStateDataCopyWith(_AppStateData value, $Res Function(_AppStateData) _then) = __$AppStateDataCopyWithImpl;
@override @useResult
$Res call({
 String host, String port, int selectedTabIndex, String publishMessage, String codeBoxButtonState
});




}
/// @nodoc
class __$AppStateDataCopyWithImpl<$Res>
    implements _$AppStateDataCopyWith<$Res> {
  __$AppStateDataCopyWithImpl(this._self, this._then);

  final _AppStateData _self;
  final $Res Function(_AppStateData) _then;

/// Create a copy of AppStateData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? host = null,Object? port = null,Object? selectedTabIndex = null,Object? publishMessage = null,Object? codeBoxButtonState = null,}) {
  return _then(_AppStateData(
host: null == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String,port: null == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as String,selectedTabIndex: null == selectedTabIndex ? _self.selectedTabIndex : selectedTabIndex // ignore: cast_nullable_to_non_nullable
as int,publishMessage: null == publishMessage ? _self.publishMessage : publishMessage // ignore: cast_nullable_to_non_nullable
as String,codeBoxButtonState: null == codeBoxButtonState ? _self.codeBoxButtonState : codeBoxButtonState // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
