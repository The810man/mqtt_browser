import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/mqtt_settings.dart';
import 'shared_preferences_provider.dart';

part 'mqtt_settings_provider.g.dart';

@riverpod
class MqttSettingsService extends _$MqttSettingsService {
  static const String _storageKey = 'mqtt_settings';

  @override
  Future<MqttSettings> build() async {
    final prefs = await ref.watch(sharedPreferencesProvider.future);
    return _getSettings(prefs);
  }

  Future<SharedPreferences> get _prefs async =>
      await ref.read(sharedPreferencesProvider.future);

  MqttSettings _getSettings(SharedPreferences prefs) {
    final jsonString = prefs.getString(_storageKey);
    if (jsonString == null) {
      return MqttSettings(
        host: 'localhost',
        port: 1883,
        clientId: 'mqtt_browser_${DateTime.now().millisecondsSinceEpoch}',
      );
    }
    try {
      return MqttSettings.fromJson(jsonDecode(jsonString));
    } catch (e) {
      return MqttSettings(
        host: 'localhost',
        port: 1883,
        clientId: 'mqtt_browser_${DateTime.now().millisecondsSinceEpoch}',
      );
    }
  }

  Future<void> updateSettings(MqttSettings settings) async {
    final prefs = await _prefs;
    await prefs.setString(_storageKey, jsonEncode(settings.toJson()));
    state = AsyncData(settings);
  }

  Future<void> clearSettings() async {
    final prefs = await _prefs;
    await prefs.remove(_storageKey);
    state = AsyncData(
      MqttSettings(
        host: 'localhost',
        port: 1883,
        clientId: 'mqtt_browser_${DateTime.now().millisecondsSinceEpoch}',
      ),
    );
  }
}
