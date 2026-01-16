import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mqtt_settings.dart';

part 'mqtt_settings_service.g.dart';

@Riverpod(keepAlive: true)
class MqttSettingsService extends _$MqttSettingsService {
  @override
  Future<MqttSettings> build() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('mqtt_settings');
    if (jsonString != null) {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return MqttSettings.fromJson(json);
    }
    return const MqttSettings(
      host: 'localhost',
      port: 1883,
      clientId: 'mqtt_browser',
    );
  }

  Future<void> saveSettings(MqttSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(settings.toJson());
    await prefs.setString('mqtt_settings', json);
    state = AsyncData(settings);
  }

  Future<void> updateOpenTabs(List<Map<String, dynamic>> tabs) async {
    final current = await future;
    final updated = current.copyWith(openTabs: tabs);
    await saveSettings(updated);
  }
}
