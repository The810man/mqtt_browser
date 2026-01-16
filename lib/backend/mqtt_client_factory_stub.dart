import 'package:mqtt5_client/mqtt5_client.dart' as mqtt;
import 'package:mqtt5_client/mqtt5_server_client.dart';

mqtt.MqttClient createMqttClient(String clientName, String host) {
  return MqttServerClient(clientName, host);
}
