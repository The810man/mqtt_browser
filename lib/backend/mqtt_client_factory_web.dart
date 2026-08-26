import 'package:mqtt5_client/mqtt5_browser_client.dart';
import 'package:mqtt5_client/mqtt5_client.dart' as mqtt;

mqtt.MqttClient createMqttClient(
  String server,
  String clientId, {
  bool useWebSocket = false,
}) {
  // Browser always uses WebSocket — TCP is not available. Ensure ws:// prefix.
  final hasScheme =
      server.startsWith('ws://') || server.startsWith('wss://');
  final wsServer = hasScheme ? server : 'ws://$server';
  return MqttBrowserClient(wsServer, clientId);
}
