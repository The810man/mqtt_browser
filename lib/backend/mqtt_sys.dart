import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mqtt5_client/mqtt5_browser_client.dart';
import 'package:mqtt5_client/mqtt5_client.dart';
import 'package:mqtt5_client/mqtt5_server_client.dart';
import 'package:mqtt_browser/main.dart';
import 'package:mqtt_browser/services/mqtt_settings_service.dart';

// Error handling and logging configuration
class MqttConnectionConfig {
  final int maxReconnectAttempts;
  final int initialBackoffMs;
  final int maxBackoffMs;
  final bool enableLogging;
  final Function(String)? onError;
  final Function(String)? onLog;

  MqttConnectionConfig({
    this.maxReconnectAttempts = 10,
    this.initialBackoffMs = 1000,
    this.maxBackoffMs = 30000,
    this.enableLogging = true,
    this.onError,
    this.onLog,
  });
}

MqttConnectionConfig _config = MqttConnectionConfig();

void setMqttConfig(MqttConnectionConfig config) {
  _config = config;
}

void _log(String message, {bool isError = false}) {
  if (_config.enableLogging) {
    if (isError) {
      print('❌ MQTT Error: $message');
      _config.onError?.call(message);
    } else {
      print('✓ MQTT: $message');
      _config.onLog?.call(message);
    }
  }
}

onDisconnected(currentClient) {
  _log('Client disconnected', isError: false);
  if (currentClient.connectionStatus!.disconnectionOrigin ==
      MqttDisconnectionOrigin.solicited) {
    _log('Disconnection was solicited');
  } else {
    _log('Unexpected disconnection - will attempt reconnect');
  }
}

onSubscribed(String topic) {
  _log('Successfully subscribed to: $topic');
}

createClient(clientName, clientPort) {
  try {
    final client = kIsWeb
        ? MqttBrowserClient('$clientName', '')
        : MqttServerClient('$clientName', '');
    client.port = clientPort;
    _log('MQTT client created: $clientName:$clientPort');
    return client;
  } catch (e) {
    _log('Failed to create MQTT client: $e', isError: true);
    rethrow;
  }
}

onConnected(currentClient) {
  try {
    // Keep default system subscriptions
    currentClient.subscribe("\$SYS/#", MqttQos.exactlyOnce);
    // Respect settings: subscribe to '#' only if configured
    final settings = globalProviderContainer.read(mqttSettingsProvider);
    if (settings.autoSubscribeOnConnect) {
      // If the saved settings include subscriptions, subscribe to them; otherwise default to '#'
      if (settings.subscriptions.isNotEmpty) {
        for (final sub in settings.subscriptions) {
          try {
            final topic = sub['topic']?.toString() ?? '#';
            final qos = sub['qos'] is int
                ? sub['qos'] as int
                : int.tryParse(sub['qos']?.toString() ?? '0') ?? 0;
            clientSubcribe(currentClient, topic, qos);
          } catch (e) {
            _log('Failed subscribing to saved topic: $e', isError: true);
          }
        }
      } else {
        // fallback
        currentClient.subscribe("#", MqttQos.exactlyOnce);
      }
    }

    globalProviderContainer.read(isConnectedProvider.notifier).state = true;
    _log('Successfully connected and subscribed to system topics');
  } catch (e) {
    _log('Failed during onConnected callback: $e', isError: true);
  }
}

startClient(currentClient, bool needLogging, bool needAutoReconnect) async {
  try {
    currentClient.logging(on: needLogging);
    currentClient.autoReconnect = needAutoReconnect;
    _log(
        'Client started - logging: $needLogging, autoReconnect: $needAutoReconnect');
  } catch (e) {
    _log('Failed to start client: $e', isError: true);
  }
}

setUpClient(
    currentClient, int keepAlivePeriod, int connectTimeoutPeriod) async {
  try {
    currentClient.onDisconnected = () => onDisconnected(currentClient);
    currentClient.onSubscribed = (String topic) => onSubscribed(topic);
    _log(
        'Client setup complete - keepAlive: $keepAlivePeriod, timeout: $connectTimeoutPeriod');
  } catch (e) {
    _log('Failed to set up client: $e', isError: true);
  }
}

setUpConnMess(String clientUniqueId, String willTopic, String willMessage,
    currentClient) {
  try {
    final connMess =
        MqttConnectMessage().withClientIdentifier(clientUniqueId).startClean();
    _log('Connecting with client ID: $clientUniqueId');
    currentClient.connectionMessage = connMess;
  } catch (e) {
    _log('Failed to set up connection message: $e', isError: true);
  }
}

Future<bool> clientTryConnect(currentClient, {int attemptNumber = 1}) async {
  try {
    _log('Connection attempt $attemptNumber...');
    await currentClient.connect();

    if (currentClient.connectionStatus!.state ==
        MqttConnectionState.connected) {
      _log('Successfully connected to broker');
      onConnected(currentClient);
      return true;
    } else {
      _log('Connection failed: ${currentClient.connectionStatus}',
          isError: true);
      currentClient.disconnect();
      return false;
    }
  } catch (e) {
    _log('Connection exception: $e', isError: true);

    // Calculate backoff with exponential strategy
    if (attemptNumber < _config.maxReconnectAttempts) {
      final backoffMs = _calculateBackoff(attemptNumber);
      _log(
          'Retrying in ${backoffMs}ms (attempt ${attemptNumber + 1}/${_config.maxReconnectAttempts})');
      await Future.delayed(Duration(milliseconds: backoffMs));
      return clientTryConnect(currentClient, attemptNumber: attemptNumber + 1);
    } else {
      _log('Max reconnection attempts exceeded', isError: true);
      currentClient.disconnect();
      return false;
    }
  }
}

int _calculateBackoff(int attemptNumber) {
  final backoff =
      _config.initialBackoffMs * (1 << (attemptNumber - 1)); // Exponential
  return backoff.clamp(0, _config.maxBackoffMs);
}

clientSubcribe(currentClient, String topic, int qosLevel) {
  try {
    final MqttQos? qos = qosLevel == 0
        ? MqttQos.atMostOnce
        : qosLevel == 1
            ? MqttQos.atLeastOnce
            : qosLevel == 2
                ? MqttQos.exactlyOnce
                : null;
    if (qos == null) {
      throw ArgumentError(
          "qosLevels need to be between 0 and 2; your value was $qosLevel");
    }
    currentClient.subscribe(topic, qos);
    _log('Subscribed to: $topic with QoS $qosLevel');
  } catch (e) {
    _log('Failed to subscribe to $topic: $e', isError: true);
    rethrow;
  }
}

publishToTopic(String pubTopic, currentClient) async {
  try {
    final builder = MqttPayloadBuilder();
    currentClient.publishMessage(
        pubTopic, MqttQos.exactlyOnce, builder.payload!);
    _log('Published to: $pubTopic');
    await Future.delayed(const Duration(seconds: 30));
  } catch (e) {
    _log('Failed to publish to $pubTopic: $e', isError: true);
    rethrow;
  }
}

unSubscribeTopic(currentClient, String topic) async {
  try {
    currentClient.unsubscribe(topic);
    _log('Unsubscribed from: $topic');
  } catch (e) {
    _log('Failed to unsubscribe from $topic: $e', isError: true);
    rethrow;
  }
}

disconnectClient(currentClient) {
  try {
    currentClient.disconnect();
    _log('Client disconnected');
  } catch (e) {
    _log('Error during disconnect: $e', isError: true);
  }
}
