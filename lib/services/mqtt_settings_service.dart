import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MqttSettings {
  final String host;
  final int port;
  final String clientId;
  final bool cleanSession;
  final int keepAliveSeconds;
  final String? username;
  final String? password;
  final bool useTls;
  final int connectionTimeoutSeconds;
  final int? maxReconnectDelay; // milliseconds
  final bool autoSubscribeOnConnect;
  final List<Map<String, dynamic>> subscriptions;
  final List<Map<String, dynamic>> openTabs;

  MqttSettings({
    required this.host,
    required this.port,
    required this.clientId,
    this.cleanSession = true,
    this.keepAliveSeconds = 60,
    this.username,
    this.password,
    this.useTls = false,
    this.connectionTimeoutSeconds = 5,
    this.maxReconnectDelay,
    this.autoSubscribeOnConnect = true,
    this.subscriptions = const [],
    this.openTabs = const [],
  });

  Map<String, dynamic> toJson() => {
        'host': host,
        'port': port,
        'clientId': clientId,
        'cleanSession': cleanSession,
        'keepAliveSeconds': keepAliveSeconds,
        'username': username,
        'password': password,
        'useTls': useTls,
        'connectionTimeoutSeconds': connectionTimeoutSeconds,
        'maxReconnectDelay': maxReconnectDelay,
        'autoSubscribeOnConnect': autoSubscribeOnConnect,
        'subscriptions': subscriptions,
        'openTabs': openTabs,
      };

  factory MqttSettings.fromJson(Map<String, dynamic> json) => MqttSettings(
        host: json['host'] as String? ?? 'localhost',
        port: json['port'] as int? ?? 1883,
        clientId: json['clientId'] as String? ?? 'mqtt_browser_client',
        cleanSession: json['cleanSession'] as bool? ?? true,
        keepAliveSeconds: json['keepAliveSeconds'] as int? ?? 60,
        username: json['username'] as String?,
        password: json['password'] as String?,
        useTls: json['useTls'] as bool? ?? false,
        connectionTimeoutSeconds: json['connectionTimeoutSeconds'] as int? ?? 5,
        maxReconnectDelay: json['maxReconnectDelay'] as int?,
        autoSubscribeOnConnect: json['autoSubscribeOnConnect'] as bool? ?? true,
        subscriptions: (json['subscriptions'] as List<dynamic>?)
                ?.map((e) => Map<String, dynamic>.from(e as Map))
                .toList() ??
            [],
        openTabs: (json['openTabs'] as List<dynamic>?)
                ?.map((e) => Map<String, dynamic>.from(e as Map))
                .toList() ??
            [],
      );

  MqttSettings copyWith({
    String? host,
    int? port,
    String? clientId,
    bool? cleanSession,
    int? keepAliveSeconds,
    String? username,
    String? password,
    bool? useTls,
    int? connectionTimeoutSeconds,
    int? maxReconnectDelay,
    bool? autoSubscribeOnConnect,
    List<Map<String, dynamic>>? subscriptions,
    List<Map<String, dynamic>>? openTabs,
  }) =>
      MqttSettings(
        host: host ?? this.host,
        port: port ?? this.port,
        clientId: clientId ?? this.clientId,
        cleanSession: cleanSession ?? this.cleanSession,
        keepAliveSeconds: keepAliveSeconds ?? this.keepAliveSeconds,
        username: username ?? this.username,
        password: password ?? this.password,
        useTls: useTls ?? this.useTls,
        connectionTimeoutSeconds:
            connectionTimeoutSeconds ?? this.connectionTimeoutSeconds,
        maxReconnectDelay: maxReconnectDelay ?? this.maxReconnectDelay,
        autoSubscribeOnConnect:
            autoSubscribeOnConnect ?? this.autoSubscribeOnConnect,
        subscriptions: subscriptions ?? this.subscriptions,
        openTabs: openTabs ?? this.openTabs,
      );
}

class MqttSettingsService {
  static const String _storageKey = 'mqtt_settings';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveSettings(MqttSettings settings) async {
    await _prefs.setString(_storageKey, _encodeJson(settings.toJson()));
  }

  MqttSettings getSettings() {
    final jsonString = _prefs.getString(_storageKey);
    if (jsonString == null) {
      return MqttSettings(
        host: 'localhost',
        port: 1883,
        clientId: 'mqtt_browser_${DateTime.now().millisecondsSinceEpoch}',
      );
    }
    try {
      return MqttSettings.fromJson(_decodeJson(jsonString));
    } catch (e) {
      return MqttSettings(
        host: 'localhost',
        port: 1883,
        clientId: 'mqtt_browser_${DateTime.now().millisecondsSinceEpoch}',
      );
    }
  }

  Future<void> clearSettings() async {
    await _prefs.remove(_storageKey);
  }

  // Simple JSON encoding/decoding helpers
  String _encodeJson(Map<String, dynamic> json) {
    return json.entries
        .map((e) => '${e.key}:${_encodeValue(e.value)}')
        .join(',');
  }

  Map<String, dynamic> _decodeJson(String encoded) {
    final result = <String, dynamic>{};
    final pairs = encoded.split(',');
    for (final pair in pairs) {
      final [key, value] = pair.split(':');
      result[key] = _decodeValue(value);
    }
    return result;
  }

  String _encodeValue(dynamic value) {
    if (value == null) return 'null';
    if (value is bool) return value ? 'true' : 'false';
    if (value is int) return 'int:$value';
    return 'str:$value';
  }

  dynamic _decodeValue(String value) {
    if (value == 'null') return null;
    if (value == 'true') return true;
    if (value == 'false') return false;
    if (value.startsWith('int:')) return int.tryParse(value.substring(4));
    if (value.startsWith('str:')) return value.substring(4);
    return value;
  }
}

final mqttSettingsServiceProvider =
    FutureProvider<MqttSettingsService>((ref) async {
  final service = MqttSettingsService();
  await service.init();
  return service;
});

final mqttSettingsProvider =
    StateNotifierProvider<MqttSettingsNotifier, MqttSettings>((ref) {
  return MqttSettingsNotifier(ref);
});

class MqttSettingsNotifier extends StateNotifier<MqttSettings> {
  final Ref _ref;

  MqttSettingsNotifier(this._ref)
      : super(MqttSettings(
          host: 'localhost',
          port: 1883,
          clientId: 'mqtt_browser_client',
        )) {
    _init();
  }

  Future<void> _init() async {
    final service = await _ref.read(mqttSettingsServiceProvider.future);
    state = service.getSettings();
  }

  Future<void> updateSettings(MqttSettings settings) async {
    state = settings;
    final service = await _ref.read(mqttSettingsServiceProvider.future);
    await service.saveSettings(settings);
  }
}
