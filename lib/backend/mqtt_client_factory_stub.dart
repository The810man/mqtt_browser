import 'package:mqtt5_client/mqtt5_client.dart' as mqtt;
import 'package:mqtt5_client/mqtt5_server_client.dart';

mqtt.MqttClient createMqttClient(
  String server,
  String clientId, {
  bool useWebSocket = false,
}) {
  if (useWebSocket) {
    final scheme = server.startsWith('ws://') || server.startsWith('wss://')
        ? ''
        : 'ws://';
    final client = MqttServerClient('$scheme$server', clientId);
    client.useWebSocket = true;
    client.useAlternateWebSocketImplementation = false;
    return client;
  }
  return MqttServerClient(server, clientId);
}
