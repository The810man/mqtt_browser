// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mqtt_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MqttSettings _$MqttSettingsFromJson(Map<String, dynamic> json) =>
    _MqttSettings(
      host: json['host'] as String,
      port: (json['port'] as num).toInt(),
      clientId: json['clientId'] as String,
      cleanSession: json['cleanSession'] as bool? ?? true,
      keepAliveSeconds: (json['keepAliveSeconds'] as num?)?.toInt() ?? 60,
      username: json['username'] as String?,
      password: json['password'] as String?,
      useTls: json['useTls'] as bool? ?? false,
      connectionTimeoutSeconds:
          (json['connectionTimeoutSeconds'] as num?)?.toInt() ?? 5,
      maxReconnectDelay: (json['maxReconnectDelay'] as num?)?.toInt(),
      autoSubscribeOnConnect: json['autoSubscribeOnConnect'] as bool? ?? true,
      subscriptions:
          (json['subscriptions'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
      openTabs:
          (json['openTabs'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$MqttSettingsToJson(_MqttSettings instance) =>
    <String, dynamic>{
      'host': instance.host,
      'port': instance.port,
      'clientId': instance.clientId,
      'cleanSession': instance.cleanSession,
      'keepAliveSeconds': instance.keepAliveSeconds,
      'username': instance.username,
      'password': instance.password,
      'useTls': instance.useTls,
      'connectionTimeoutSeconds': instance.connectionTimeoutSeconds,
      'maxReconnectDelay': instance.maxReconnectDelay,
      'autoSubscribeOnConnect': instance.autoSubscribeOnConnect,
      'subscriptions': instance.subscriptions,
      'openTabs': instance.openTabs,
    };
