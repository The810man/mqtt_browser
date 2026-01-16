import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mqtt5_client/mqtt5_client.dart'
    show
        MqttClient,
        MqttConnectMessage,
        MqttQos,
        MqttPayloadBuilder,
        MqttReceivedMessage,
        MqttMessage,
        MqttPublishMessage,
        MqttUtilities;
import 'package:mqtt5_client/mqtt5_server_client.dart';
import 'package:mqtt_browser/providers/providers.dart';

part 'mqtt_client_provider.g.dart';

enum MqttConnectionState { disconnected, connecting, connected, faulted }

@Riverpod(keepAlive: true)
class MqttClientNotifier extends _$MqttClientNotifier {
  @override
  MqttConnectionState build() {
    return MqttConnectionState.disconnected;
  }

  MqttClient? _client;
  StreamSubscription<List<MqttReceivedMessage<MqttMessage?>>>? _subscription;

  MqttClient? get client => _client;

  Future<void> connect(String host, int port, String clientId) async {
    state = MqttConnectionState.connecting;

    try {
      _client = MqttServerClient(host, '');

      _client!.port = port;
      _client!.onDisconnected = () => state = MqttConnectionState.disconnected;
      _client!.onConnected = () => state = MqttConnectionState.connected;

      final connMess = MqttConnectMessage()
          .withClientIdentifier(clientId)
          .startClean();

      _client!.connectionMessage = connMess;

      await _client!.connect();

      // Set up message listener
      _setupMessageListener();
    } catch (e) {
      state = MqttConnectionState.faulted;
      rethrow;
    }
  }

  void _setupMessageListener() {
    if (_client == null) return;

    _subscription = _client!.updates.listen((
      List<MqttReceivedMessage<MqttMessage?>>? messages,
    ) {
      if (messages == null || messages.isEmpty) return;

      try {
        for (final message in messages) {
          final recMess = message.payload as MqttPublishMessage;
          final payload = MqttUtilities.bytesToStringAsString(
            recMess.payload.message!,
          );
          final topic = message.topic;

          if (topic != null) {
            // Update tree via service
            ref.read(treeServiceProvider).addMessage(topic, payload);
          }
        }
      } catch (e) {
        print('Error processing MQTT message: $e');
      }
    });
  }

  Future<void> disconnect() async {
    await _subscription?.cancel();
    _subscription = null;
    _client?.disconnect();
    _client = null;
    state = MqttConnectionState.disconnected;
  }

  Future<void> subscribe(String topic, MqttQos qos) async {
    if (_client == null || state != MqttConnectionState.connected) return;

    _client!.subscribe(topic, qos);
  }

  Future<void> unsubscribe(String topic) async {
    if (_client == null) return;

    _client!.unsubscribeStringTopic(topic);
  }

  Future<void> publish(String topic, String payload, MqttQos qos) async {
    if (_client == null || state != MqttConnectionState.connected) return;

    final builder = MqttPayloadBuilder();
    builder.addString(payload);
    _client!.publishMessage(topic, qos, builder.payload!);
  }
}
