import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../backend/mqtt_service.dart' show MqttConnectionRefusedException, MqttService;
import '../frontend/tree_node.dart';
import '../models/mqtt_settings.dart';
import 'providers.dart';

part 'mqtt_client_provider.g.dart';

enum MqttConnectionState { disconnected, connecting, connected, faulted }

@Riverpod(keepAlive: true)
class MqttClientNotifier extends _$MqttClientNotifier {
  MqttService? _service;
  StreamSubscription<dynamic>? _subscription;
  String? _rootLabel;

  @override
  MqttConnectionState build() => MqttConnectionState.disconnected;

  MqttService? get service => _service;

  Future<bool> connect(
    String host,
    int port,
    String clientId,
    MqttSettings settings,
  ) async {
    assert(host.isNotEmpty, 'host must not be empty');
    assert(port > 0 && port <= 65535, 'port must be 1–65535');
    assert(clientId.isNotEmpty, 'clientId must not be empty');

    await disconnect();
    state = MqttConnectionState.connecting;

    final useWs = ref.read(useWebSocketProvider);
    _service = MqttService.create(
      host: host,
      port: port,
      clientId: clientId,
      username: settings.username,
      password: settings.password,
      useTls: settings.useTls,
      useWebSocket: useWs,
      keepAliveSeconds: settings.keepAliveSeconds,
    );

    _service!.rawClient.onDisconnected =
        () => state = MqttConnectionState.disconnected;

    try {
      await _service!.connect();
    } on MqttConnectionRefusedException {
      state = MqttConnectionState.faulted;
      return false;
    }

    debugPrint('[CONNECT] connected to $host:$port, calling _initRootTab');
    _subscribeInitialTopics(settings);
    _initRootTab(host, port);
    _setupMessageListener();

    debugPrint('[CONNECT] setting state=connected');
    state = MqttConnectionState.connected;
    return true;
  }

  void _initRootTab(String host, int port) {
    final rootNode = TreeNode(label: '$host:$port');
    _rootLabel = rootNode.label;
    debugPrint('[INIT] rootNode.label="${rootNode.label}"');

    final controller = TreeController<TreeNode>(
      roots: [rootNode],
      childrenProvider: (node) => node.children,
    );
    controller.expand(rootNode);

    ref.read(rootProvider.notifier).set(rootNode);
    debugPrint('[INIT] rootProvider set to "${ref.read(rootProvider).label}"');

    ref.read(tabListProvider.notifier).set([rootNode]);
    ref.read(tabLengthProvider.notifier).set(1);
    ref.read(currentRootProvider.notifier).set(rootNode);
    ref.read(treeNodesProvider.notifier).set({rootNode.label: [rootNode]});
    ref.read(tabDataProvider.notifier).set({
      rootNode.label: {'controller': controller, 'viewType': 'tree'},
    });

    debugPrint('[INIT] treeNodesProvider keys=${ref.read(treeNodesProvider).keys.toList()}');
    debugPrint('[INIT] tabDataProvider keys=${ref.read(tabDataProvider).keys.toList()}');
    debugPrint('[INIT] Root tab initialised: ${rootNode.label}');
  }

  void _setupMessageListener() {
    final updates = _service?.updates;
    if (updates == null) {
      log('updates stream is null — no messages will be received', name: 'MqttClientNotifier', level: 900);
      return;
    }
    log('Message listener attached', name: 'MqttClientNotifier');

    _subscription = updates.listen(
      (messages) {
        log('Received batch of ${messages.length} message(s)', name: 'MqttClientNotifier');
        for (final raw in messages) {
          final msg = MqttService.decodeMessage(raw);
          if (msg == null) {
            log('decodeMessage returned null for raw message', name: 'MqttClientNotifier', level: 900);
            continue;
          }
          log('Message: topic=${msg.topic}', name: 'MqttClientNotifier');
          try {
            _addMessageToTree(msg.topic, msg.payload);
          } on Exception catch (e) {
            log('Error routing message: $e', name: 'MqttClientNotifier');
          }
        }
      },
      onError: (Object e, StackTrace st) {
        log('Stream error: $e', name: 'MqttClientNotifier', level: 900, stackTrace: st);
      },
    );
  }

  /// Builds the MQTT topic as a child path under the connection root node
  /// in [treeNodesProvider], then triggers a state update so listeners rebuild.
  void _addMessageToTree(String topic, String payload) {
    final label = _rootLabel;
    if (label == null) {
      debugPrint('[TREE] _rootLabel is null, dropping topic=$topic');
      return;
    }

    final nodes = ref.read(treeNodesProvider);
    debugPrint('[TREE] treeNodesProvider keys=${nodes.keys.toList()}, looking up label="$label"');
    final rootNode = nodes[label]?.firstOrNull;
    if (rootNode == null) {
      debugPrint('[TREE] rootNode not found for label="$label", dropping topic=$topic');
      return;
    }

    var parent = rootNode;
    for (final segment in topic.split('/')) {
      parent = _findOrCreateChild(parent, segment);
    }
    parent.addMessage(payload);

    // Shallow-copy the map so Riverpod sees a new reference and notifies listeners.
    ref.read(treeNodesProvider.notifier).set({...nodes});
    debugPrint('[TREE] treeNodesProvider updated, rootNode.children=${rootNode.children.map((c) => c.label).toList()}');
  }

  TreeNode _findOrCreateChild(TreeNode parent, String label) {
    for (final child in parent.children) {
      if (child.label == label) return child;
    }
    final child = TreeNode(label: label, parent: parent);
    parent.children.add(child);
    return child;
  }

  void _subscribeInitialTopics(MqttSettings settings) {
    _service!.subscribe(r'$SYS/#', qos: 0);

    log(
      'autoSubscribeOnConnect=${settings.autoSubscribeOnConnect} '
      'subscriptions=${settings.subscriptions}',
      name: 'MqttClientNotifier',
    );

    if (settings.autoSubscribeOnConnect) {
      if (settings.subscriptions.isNotEmpty) {
        for (final sub in settings.subscriptions) {
          final topic = sub['topic']?.toString();
          if (topic == null || topic.isEmpty) continue;
          final qos = sub['qos'] is int
              ? sub['qos'] as int
              : int.tryParse(sub['qos']?.toString() ?? '0') ?? 0;
          _service!.subscribe(topic, qos: qos);
        }
      } else {
        _service!.subscribe('#');
      }
    }
  }

  Future<void> disconnect() async {
    await _subscription?.cancel();
    _subscription = null;
    _service?.disconnect();
    _service = null;
    _rootLabel = null;
    // Clear tab state so _initRootTab always reinitialises on reconnect,
    // even after an unexpected broker disconnect (where _resetProviders was
    // not called).
    ref.read(tabListProvider.notifier).set([]);
    ref.read(tabDataProvider.notifier).set({});
    ref.read(treeNodesProvider.notifier).set({});
    state = MqttConnectionState.disconnected;
  }

  void subscribe(String topic, {int qos = 0}) {
    if (_service == null || state != MqttConnectionState.connected) return;
    _service!.subscribe(topic, qos: qos);
  }

  void unsubscribe(String topic) {
    if (_service == null) return;
    _service!.unsubscribe(topic);
  }

  void publish(String topic, String payload, {int qos = 0, bool retain = false}) {
    if (_service == null || state != MqttConnectionState.connected) return;
    _service!.publish(topic, payload, qos: qos, retain: retain);
  }
}
