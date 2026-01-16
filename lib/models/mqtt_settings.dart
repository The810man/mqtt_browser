import 'package:freezed_annotation/freezed_annotation.dart';

part 'mqtt_settings.freezed.dart';
part 'mqtt_settings.g.dart';

@freezed
abstract class MqttSettings with _$MqttSettings {
  const factory MqttSettings({
    required String host,
    required int port,
    required String clientId,
    @Default(true) bool cleanSession,
    @Default(60) int keepAliveSeconds,
    String? username,
    String? password,
    @Default(false) bool useTls,
    @Default(5) int connectionTimeoutSeconds,
    int? maxReconnectDelay,
    @Default(true) bool autoSubscribeOnConnect,
    @Default([]) List<Map<String, dynamic>> subscriptions,
    @Default([]) List<Map<String, dynamic>> openTabs,
  }) = _MqttSettings;

  factory MqttSettings.fromJson(Map<String, dynamic> json) =>
      _$MqttSettingsFromJson(json);
}
