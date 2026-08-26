import 'dart:developer';

import 'package:mqtt5_client/mqtt5_client.dart' as mqtt;

import 'mqtt_client_factory.dart';

/// QoS level conversion helper.
mqtt.MqttQos _toMqttQos(int level) {
  switch (level) {
    case 1:
      return mqtt.MqttQos.atLeastOnce;
    case 2:
      return mqtt.MqttQos.exactlyOnce;
    default:
      return mqtt.MqttQos.atMostOnce;
  }
}

/// Incoming MQTT message.
class MqttMessage {
  const MqttMessage({required this.topic, required this.payload});
  final String topic;
  final String payload;
}

/// OOP wrapper around a single MQTT connection.
///
/// Created and owned by [MqttClientNotifier].  Has no Riverpod dependency.
class MqttService {
  MqttService._({
    required mqtt.MqttClient client,
    this.username,
    this.password,
  }) : _client = client;

  factory MqttService.create({
    required String host,
    required int port,
    required String clientId,
    String? username,
    String? password,
    bool useTls = false,
    bool useWebSocket = false,
    int keepAliveSeconds = 60,
    bool autoReconnect = true,
  }) {
    final client = createPlatformClient(host, clientId, useWebSocket: useWebSocket);
    client.port = port;
    client.keepAlivePeriod = keepAliveSeconds;
    client.autoReconnect = autoReconnect;
    client.logging(on: false);

    final connMess = mqtt.MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean();
    client.connectionMessage = connMess;

    log('MqttService created for $host:$port (clientId: $clientId)',
        name: 'MqttService');
    return MqttService._(client: client, username: username, password: password);
  }

  final mqtt.MqttClient _client;
  final String? username;
  final String? password;

  mqtt.MqttClient get rawClient => _client;

  /// Connects to the broker. Returns `true` on success.
  /// Throws [MqttConnectionRefusedException] when the broker refuses the
  /// connection (e.g. wrong credentials or unsupported protocol version).
  Future<bool> connect() async {
    try {
      log('Connecting…', name: 'MqttService');
      final user = (username?.isNotEmpty ?? false) ? username : null;
      final pass = (password?.isNotEmpty ?? false) ? password : null;
      await _client.connect(user, pass);
      final status = _client.connectionStatus;
      if (status?.state == mqtt.MqttConnectionState.connected) {
        log('Connected', name: 'MqttService');
        return true;
      }
      log('Connection not established — $status', name: 'MqttService', level: 900);
      _client.disconnect();
      throw MqttConnectionRefusedException('$status');
    } on MqttConnectionRefusedException {
      rethrow;
    } on Exception catch (e, st) {
      log('Connection exception: $e', name: 'MqttService', level: 900, stackTrace: st);
      _client.disconnect();
      rethrow;
    }
  }

  void disconnect() {
    try {
      _client.disconnect();
      log('Disconnected', name: 'MqttService');
    } on Exception catch (e) {
      log('Disconnect error: $e', name: 'MqttService', level: 900);
    }
  }

  void subscribe(String topic, {int qos = 0}) {
    try {
      _client.subscribe(topic, _toMqttQos(qos));
      log('Subscribed to $topic (QoS $qos)', name: 'MqttService');
    } on Exception catch (e) {
      log('Subscribe failed for $topic: $e', name: 'MqttService', level: 900);
    }
  }

  void unsubscribe(String topic) {
    try {
      _client.unsubscribeStringTopic(topic);
      log('Unsubscribed from $topic', name: 'MqttService');
    } on Exception catch (e) {
      log('Unsubscribe failed for $topic: $e', name: 'MqttService', level: 900);
      rethrow;
    }
  }

  void publish(String topic, String payload, {int qos = 0, bool retain = false}) {
    try {
      final builder = mqtt.MqttPayloadBuilder()..addString(payload);
      _client.publishMessage(
        topic,
        _toMqttQos(qos),
        builder.payload!,
        retain: retain,
      );
      log('Published to $topic (retain: $retain)', name: 'MqttService');
    } on Exception catch (e) {
      log('Publish failed for $topic: $e', name: 'MqttService', level: 900);
      rethrow;
    }
  }

  /// Decodes an incoming MQTT message from the raw updates stream.
  static MqttMessage? decodeMessage(
    mqtt.MqttReceivedMessage<mqtt.MqttMessage?> raw,
  ) {
    try {
      final recMess = raw.payload as mqtt.MqttPublishMessage;
      final payload = mqtt.MqttUtilities.bytesToStringAsString(
        recMess.payload.message!,
      );
      final topic = raw.topic;
      if (topic == null) return null;
      return MqttMessage(topic: topic, payload: payload);
    } on Exception catch (e) {
      log('Failed to decode message: $e', name: 'MqttService', level: 900);
      return null;
    }
  }

  Stream<List<mqtt.MqttReceivedMessage<mqtt.MqttMessage?>>>? get updates =>
      _client.updates;
}

class MqttConnectionRefusedException implements Exception {
  const MqttConnectionRefusedException(this.message);
  final String message;

  @override
  String toString() => 'Connection refused: $message';
}
