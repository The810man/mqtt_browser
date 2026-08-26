import 'package:mqtt5_client/mqtt5_client.dart' as mqtt;

import 'mqtt_client_factory_stub.dart'
    if (dart.library.html) 'mqtt_client_factory_web.dart';

mqtt.MqttClient createPlatformClient(
  String server,
  String clientId, {
  bool useWebSocket = false,
}) {
  return createMqttClient(server, clientId, useWebSocket: useWebSocket);
}
