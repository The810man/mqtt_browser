import 'package:mqtt5_client/mqtt5_browser_client.dart';
import 'package:mqtt5_client/mqtt5_client.dart' as mqtt;

mqtt.MqttClient createMqttClient(String clientName, String host) {
  return MqttBrowserClient(clientName, host);
}
