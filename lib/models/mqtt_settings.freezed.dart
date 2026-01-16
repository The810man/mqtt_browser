// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mqtt_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MqttSettings {

 String get host; int get port; String get clientId; bool get cleanSession; int get keepAliveSeconds; String? get username; String? get password; bool get useTls; int get connectionTimeoutSeconds; int? get maxReconnectDelay; bool get autoSubscribeOnConnect; List<Map<String, dynamic>> get subscriptions; List<Map<String, dynamic>> get openTabs;
/// Create a copy of MqttSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MqttSettingsCopyWith<MqttSettings> get copyWith => _$MqttSettingsCopyWithImpl<MqttSettings>(this as MqttSettings, _$identity);

  /// Serializes this MqttSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MqttSettings&&(identical(other.host, host) || other.host == host)&&(identical(other.port, port) || other.port == port)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.cleanSession, cleanSession) || other.cleanSession == cleanSession)&&(identical(other.keepAliveSeconds, keepAliveSeconds) || other.keepAliveSeconds == keepAliveSeconds)&&(identical(other.username, username) || other.username == username)&&(identical(other.password, password) || other.password == password)&&(identical(other.useTls, useTls) || other.useTls == useTls)&&(identical(other.connectionTimeoutSeconds, connectionTimeoutSeconds) || other.connectionTimeoutSeconds == connectionTimeoutSeconds)&&(identical(other.maxReconnectDelay, maxReconnectDelay) || other.maxReconnectDelay == maxReconnectDelay)&&(identical(other.autoSubscribeOnConnect, autoSubscribeOnConnect) || other.autoSubscribeOnConnect == autoSubscribeOnConnect)&&const DeepCollectionEquality().equals(other.subscriptions, subscriptions)&&const DeepCollectionEquality().equals(other.openTabs, openTabs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,host,port,clientId,cleanSession,keepAliveSeconds,username,password,useTls,connectionTimeoutSeconds,maxReconnectDelay,autoSubscribeOnConnect,const DeepCollectionEquality().hash(subscriptions),const DeepCollectionEquality().hash(openTabs));

@override
String toString() {
  return 'MqttSettings(host: $host, port: $port, clientId: $clientId, cleanSession: $cleanSession, keepAliveSeconds: $keepAliveSeconds, username: $username, password: $password, useTls: $useTls, connectionTimeoutSeconds: $connectionTimeoutSeconds, maxReconnectDelay: $maxReconnectDelay, autoSubscribeOnConnect: $autoSubscribeOnConnect, subscriptions: $subscriptions, openTabs: $openTabs)';
}


}

/// @nodoc
abstract mixin class $MqttSettingsCopyWith<$Res>  {
  factory $MqttSettingsCopyWith(MqttSettings value, $Res Function(MqttSettings) _then) = _$MqttSettingsCopyWithImpl;
@useResult
$Res call({
 String host, int port, String clientId, bool cleanSession, int keepAliveSeconds, String? username, String? password, bool useTls, int connectionTimeoutSeconds, int? maxReconnectDelay, bool autoSubscribeOnConnect, List<Map<String, dynamic>> subscriptions, List<Map<String, dynamic>> openTabs
});




}
/// @nodoc
class _$MqttSettingsCopyWithImpl<$Res>
    implements $MqttSettingsCopyWith<$Res> {
  _$MqttSettingsCopyWithImpl(this._self, this._then);

  final MqttSettings _self;
  final $Res Function(MqttSettings) _then;

/// Create a copy of MqttSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? host = null,Object? port = null,Object? clientId = null,Object? cleanSession = null,Object? keepAliveSeconds = null,Object? username = freezed,Object? password = freezed,Object? useTls = null,Object? connectionTimeoutSeconds = null,Object? maxReconnectDelay = freezed,Object? autoSubscribeOnConnect = null,Object? subscriptions = null,Object? openTabs = null,}) {
  return _then(_self.copyWith(
host: null == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String,port: null == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int,clientId: null == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String,cleanSession: null == cleanSession ? _self.cleanSession : cleanSession // ignore: cast_nullable_to_non_nullable
as bool,keepAliveSeconds: null == keepAliveSeconds ? _self.keepAliveSeconds : keepAliveSeconds // ignore: cast_nullable_to_non_nullable
as int,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,password: freezed == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String?,useTls: null == useTls ? _self.useTls : useTls // ignore: cast_nullable_to_non_nullable
as bool,connectionTimeoutSeconds: null == connectionTimeoutSeconds ? _self.connectionTimeoutSeconds : connectionTimeoutSeconds // ignore: cast_nullable_to_non_nullable
as int,maxReconnectDelay: freezed == maxReconnectDelay ? _self.maxReconnectDelay : maxReconnectDelay // ignore: cast_nullable_to_non_nullable
as int?,autoSubscribeOnConnect: null == autoSubscribeOnConnect ? _self.autoSubscribeOnConnect : autoSubscribeOnConnect // ignore: cast_nullable_to_non_nullable
as bool,subscriptions: null == subscriptions ? _self.subscriptions : subscriptions // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,openTabs: null == openTabs ? _self.openTabs : openTabs // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,
  ));
}

}


/// Adds pattern-matching-related methods to [MqttSettings].
extension MqttSettingsPatterns on MqttSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MqttSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MqttSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MqttSettings value)  $default,){
final _that = this;
switch (_that) {
case _MqttSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MqttSettings value)?  $default,){
final _that = this;
switch (_that) {
case _MqttSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String host,  int port,  String clientId,  bool cleanSession,  int keepAliveSeconds,  String? username,  String? password,  bool useTls,  int connectionTimeoutSeconds,  int? maxReconnectDelay,  bool autoSubscribeOnConnect,  List<Map<String, dynamic>> subscriptions,  List<Map<String, dynamic>> openTabs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MqttSettings() when $default != null:
return $default(_that.host,_that.port,_that.clientId,_that.cleanSession,_that.keepAliveSeconds,_that.username,_that.password,_that.useTls,_that.connectionTimeoutSeconds,_that.maxReconnectDelay,_that.autoSubscribeOnConnect,_that.subscriptions,_that.openTabs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String host,  int port,  String clientId,  bool cleanSession,  int keepAliveSeconds,  String? username,  String? password,  bool useTls,  int connectionTimeoutSeconds,  int? maxReconnectDelay,  bool autoSubscribeOnConnect,  List<Map<String, dynamic>> subscriptions,  List<Map<String, dynamic>> openTabs)  $default,) {final _that = this;
switch (_that) {
case _MqttSettings():
return $default(_that.host,_that.port,_that.clientId,_that.cleanSession,_that.keepAliveSeconds,_that.username,_that.password,_that.useTls,_that.connectionTimeoutSeconds,_that.maxReconnectDelay,_that.autoSubscribeOnConnect,_that.subscriptions,_that.openTabs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String host,  int port,  String clientId,  bool cleanSession,  int keepAliveSeconds,  String? username,  String? password,  bool useTls,  int connectionTimeoutSeconds,  int? maxReconnectDelay,  bool autoSubscribeOnConnect,  List<Map<String, dynamic>> subscriptions,  List<Map<String, dynamic>> openTabs)?  $default,) {final _that = this;
switch (_that) {
case _MqttSettings() when $default != null:
return $default(_that.host,_that.port,_that.clientId,_that.cleanSession,_that.keepAliveSeconds,_that.username,_that.password,_that.useTls,_that.connectionTimeoutSeconds,_that.maxReconnectDelay,_that.autoSubscribeOnConnect,_that.subscriptions,_that.openTabs);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MqttSettings implements MqttSettings {
  const _MqttSettings({required this.host, required this.port, required this.clientId, this.cleanSession = true, this.keepAliveSeconds = 60, this.username, this.password, this.useTls = false, this.connectionTimeoutSeconds = 5, this.maxReconnectDelay, this.autoSubscribeOnConnect = true, final  List<Map<String, dynamic>> subscriptions = const [], final  List<Map<String, dynamic>> openTabs = const []}): _subscriptions = subscriptions,_openTabs = openTabs;
  factory _MqttSettings.fromJson(Map<String, dynamic> json) => _$MqttSettingsFromJson(json);

@override final  String host;
@override final  int port;
@override final  String clientId;
@override@JsonKey() final  bool cleanSession;
@override@JsonKey() final  int keepAliveSeconds;
@override final  String? username;
@override final  String? password;
@override@JsonKey() final  bool useTls;
@override@JsonKey() final  int connectionTimeoutSeconds;
@override final  int? maxReconnectDelay;
@override@JsonKey() final  bool autoSubscribeOnConnect;
 final  List<Map<String, dynamic>> _subscriptions;
@override@JsonKey() List<Map<String, dynamic>> get subscriptions {
  if (_subscriptions is EqualUnmodifiableListView) return _subscriptions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_subscriptions);
}

 final  List<Map<String, dynamic>> _openTabs;
@override@JsonKey() List<Map<String, dynamic>> get openTabs {
  if (_openTabs is EqualUnmodifiableListView) return _openTabs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_openTabs);
}


/// Create a copy of MqttSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MqttSettingsCopyWith<_MqttSettings> get copyWith => __$MqttSettingsCopyWithImpl<_MqttSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MqttSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MqttSettings&&(identical(other.host, host) || other.host == host)&&(identical(other.port, port) || other.port == port)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.cleanSession, cleanSession) || other.cleanSession == cleanSession)&&(identical(other.keepAliveSeconds, keepAliveSeconds) || other.keepAliveSeconds == keepAliveSeconds)&&(identical(other.username, username) || other.username == username)&&(identical(other.password, password) || other.password == password)&&(identical(other.useTls, useTls) || other.useTls == useTls)&&(identical(other.connectionTimeoutSeconds, connectionTimeoutSeconds) || other.connectionTimeoutSeconds == connectionTimeoutSeconds)&&(identical(other.maxReconnectDelay, maxReconnectDelay) || other.maxReconnectDelay == maxReconnectDelay)&&(identical(other.autoSubscribeOnConnect, autoSubscribeOnConnect) || other.autoSubscribeOnConnect == autoSubscribeOnConnect)&&const DeepCollectionEquality().equals(other._subscriptions, _subscriptions)&&const DeepCollectionEquality().equals(other._openTabs, _openTabs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,host,port,clientId,cleanSession,keepAliveSeconds,username,password,useTls,connectionTimeoutSeconds,maxReconnectDelay,autoSubscribeOnConnect,const DeepCollectionEquality().hash(_subscriptions),const DeepCollectionEquality().hash(_openTabs));

@override
String toString() {
  return 'MqttSettings(host: $host, port: $port, clientId: $clientId, cleanSession: $cleanSession, keepAliveSeconds: $keepAliveSeconds, username: $username, password: $password, useTls: $useTls, connectionTimeoutSeconds: $connectionTimeoutSeconds, maxReconnectDelay: $maxReconnectDelay, autoSubscribeOnConnect: $autoSubscribeOnConnect, subscriptions: $subscriptions, openTabs: $openTabs)';
}


}

/// @nodoc
abstract mixin class _$MqttSettingsCopyWith<$Res> implements $MqttSettingsCopyWith<$Res> {
  factory _$MqttSettingsCopyWith(_MqttSettings value, $Res Function(_MqttSettings) _then) = __$MqttSettingsCopyWithImpl;
@override @useResult
$Res call({
 String host, int port, String clientId, bool cleanSession, int keepAliveSeconds, String? username, String? password, bool useTls, int connectionTimeoutSeconds, int? maxReconnectDelay, bool autoSubscribeOnConnect, List<Map<String, dynamic>> subscriptions, List<Map<String, dynamic>> openTabs
});




}
/// @nodoc
class __$MqttSettingsCopyWithImpl<$Res>
    implements _$MqttSettingsCopyWith<$Res> {
  __$MqttSettingsCopyWithImpl(this._self, this._then);

  final _MqttSettings _self;
  final $Res Function(_MqttSettings) _then;

/// Create a copy of MqttSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? host = null,Object? port = null,Object? clientId = null,Object? cleanSession = null,Object? keepAliveSeconds = null,Object? username = freezed,Object? password = freezed,Object? useTls = null,Object? connectionTimeoutSeconds = null,Object? maxReconnectDelay = freezed,Object? autoSubscribeOnConnect = null,Object? subscriptions = null,Object? openTabs = null,}) {
  return _then(_MqttSettings(
host: null == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String,port: null == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int,clientId: null == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String,cleanSession: null == cleanSession ? _self.cleanSession : cleanSession // ignore: cast_nullable_to_non_nullable
as bool,keepAliveSeconds: null == keepAliveSeconds ? _self.keepAliveSeconds : keepAliveSeconds // ignore: cast_nullable_to_non_nullable
as int,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,password: freezed == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String?,useTls: null == useTls ? _self.useTls : useTls // ignore: cast_nullable_to_non_nullable
as bool,connectionTimeoutSeconds: null == connectionTimeoutSeconds ? _self.connectionTimeoutSeconds : connectionTimeoutSeconds // ignore: cast_nullable_to_non_nullable
as int,maxReconnectDelay: freezed == maxReconnectDelay ? _self.maxReconnectDelay : maxReconnectDelay // ignore: cast_nullable_to_non_nullable
as int?,autoSubscribeOnConnect: null == autoSubscribeOnConnect ? _self.autoSubscribeOnConnect : autoSubscribeOnConnect // ignore: cast_nullable_to_non_nullable
as bool,subscriptions: null == subscriptions ? _self._subscriptions : subscriptions // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,openTabs: null == openTabs ? _self._openTabs : openTabs // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,
  ));
}


}

// dart format on
