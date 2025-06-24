import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqtt_browser/main.dart';

onDisconnected(currentClient) {
  print('OnDisconnected client callback - Client disconnection');
  if (currentClient.connectionStatus!.disconnectionOrigin ==
      MqttDisconnectionOrigin.solicited) {
    print('OnDisconnected callback is solicited, this is correct');
  } else {
    print(
        'OnDisconnected callback is unsolicited or none, this is incorrect - exiting');
  }
}

onSubscribed(String topic) {
  print('Subscription confirmed for topic $topic');
}

createClient(clientName, clientPort) {
  final client = kIsWeb
      ? MqttBrowserClient('$clientName', '')
      : MqttServerClient('$clientName', '');
  client.setProtocolV311();
  client.websocketProtocols = MqttClientConstants.protocolsSingleDefault;
  client.port = clientPort;
  return client;
}

onConnected(currentClient) {
  currentClient.subscribe("\$SYS/#", MqttQos.exactlyOnce);
  currentClient.subscribe("#", MqttQos.exactlyOnce);
  globalProviderContainer.read(isConnectedProvider.notifier).state = true;
}

startClient(currentClient, bool needLogging, bool needAutoReconnect) async {
  currentClient.logging(on: needLogging);
  currentClient.setProtocolV311();
  currentClient.autoReconnect = needAutoReconnect;
}

setUpClient(
    currentClient, int keepAlivePeriod, int connectTimeoutPeriod) async {
  currentClient.keepAlivePeriod = keepAlivePeriod;
  currentClient.connectTimeoutPeriod = connectTimeoutPeriod;
  currentClient.onDisconnected = onDisconnected(currentClient);
  currentClient.onSubscribed = onSubscribed;
}

setUpConnMess(String clientUniqueId, String willTopic, String willMessage,
    currentClient) {
  final connMess = MqttConnectMessage()
      .withClientIdentifier(clientUniqueId)
      .withWillTopic(willTopic) // If you set this you must set a will message
      .withWillMessage(willMessage)
      .startClean() // Non persistent session for testing
      .withWillQos(MqttQos.atLeastOnce);
  print('MQTT client connecting.... please wait');
  currentClient.connectionMessage = connMess;
}

clientTryConnect(currentClient) async {
  try {
    await currentClient.connect();
  } on NoConnectionException {
    // Raised by the client when connection fails.
    currentClient.disconnect();
  } on SocketException catch (e) {
    // Raised by the socket layer
    print('socket exception - $e');
    currentClient.disconnect();
  }

  /// Check we are connected
  if (currentClient.connectionStatus!.state == MqttConnectionState.connected) {
    print('Mosquitto client connected');
    onConnected(currentClient);
  } else {
    /// Use status here rather than state if you also want the broker return code.
    print(
        'ERROR Mosquitto client connection failed - disconnecting, status is ${currentClient.connectionStatus}');
    currentClient.disconnect();
  }
}

clientSubcribe(currentClient, String topic, int qosLevel) async {
  if (qosLevel == 0) {
    currentClient.subscribe(topic, MqttQos.atMostOnce);
  }
  if (qosLevel == 1) {
    currentClient.subscribe(topic, MqttQos.atLeastOnce);
  }
  if (qosLevel == 2) {
    currentClient.subscribe(topic, MqttQos.exactlyOnce);
  } else {
    return ErrorDescription(
        "qosLevels Need To be between 0 and 2, youre value was $qosLevel");
  }
}

publishToTopic(String pubTopic, currentClient) async {
  final builder = MqttClientPayloadBuilder();
  currentClient.publishMessage(pubTopic, MqttQos.exactlyOnce, builder.payload!);
  await MqttUtilities.asyncSleep(30);
}

unSubscribeTopic(currentClient, String topic) async {
  currentClient.unsubscribe(topic);
}

disconnectClient(currentClient) {
  currentClient.disconnect();
}
