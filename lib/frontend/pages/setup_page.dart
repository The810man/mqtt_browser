import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_browser/backend/mqtt_sys.dart' as mqSys;
import 'package:mqtt_browser/frontend/widgets/reactive_widgets/setup_widget.dart';
import 'package:mqtt_browser/main.dart';
import 'package:mqtt_browser/backend/tree_updater.dart' as Tree_Updater;
import 'package:mqtt_browser/providers/providers.dart';
import 'dart:math';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:mqtt_browser/frontend/widgets/tiled_background.dart';
import 'package:mqtt_browser/frontend/tree_node.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'setup_page.g.dart';

@Riverpod(keepAlive: true)
class Version extends _$Version {
  @override
  String build() => "";
}

final versionSetter = FutureProvider<void>((ref) async {
  final info = await PackageInfo.fromPlatform();
  ref.read(versionProvider.notifier).state = info.data["version"];
});

@Riverpod(keepAlive: true)
class ConnectButton extends _$ConnectButton {
  @override
  bool build() => false;
}

class SetUpPage extends ConsumerWidget {
  int random(int min, int max) {
    return min + Random().nextInt(max - min);
  }

  const SetUpPage({super.key});

  void _startClient(WidgetRef ref) {
    try {
      // Read host and port from Riverpod providers
      final host = ref.read(hostProvider);
      final portStr = ref.read(portProvider);

      print('🔌 Attempting connection to $host:$portStr');

      // Validate inputs
      if (host.isEmpty) {
        _showError(ref, 'Host cannot be empty');
        return;
      }

      int port;
      try {
        port = int.parse(portStr);
      } catch (e) {
        _showError(ref, 'Invalid port: $portStr - must be a number');
        return;
      }

      if (port < 1 || port > 65535) {
        _showError(ref, 'Port must be between 1 and 65535');
        return;
      }

      print('✓ Validation passed: $host:$port');

      // Create and configure client
      final client = mqSys.createClient(host, port);
      print('✓ MQTT client created');

      // Set up callbacks
      client.onConnected = () {
        print('✅ Connected callback fired');
        ref.read(isConnectedProvider.notifier).state = true;
        ref.read(mqttClientProvider.notifier).state =
            MqttConnectionState.connected;
      };

      client.onDisconnected = () {
        print('⚠️ Disconnected callback fired');
        ref.read(isConnectedProvider.notifier).state = false;
        ref.read(mqttClientProvider.notifier).state =
            MqttConnectionState.disconnected;
      };

      ref.read(clientProvider.notifier).state = client;

      // Configure client
      try {
        mqSys.startClient(client, true, true);
        mqSys.setUpClient(client, 60, 5000);
        print('✓ Client configured');
      } catch (e) {
        _showError(ref, 'Failed to configure client: $e');
        return;
      }

      // Set up connection message
      final clientId = "mqtt-browser-${random(100000, 999999)}";
      try {
        mqSys.setUpConnMess(clientId, "will/topic", "Device offline", client);
        print('✓ Connection message setup: $clientId');
      } catch (e) {
        _showError(ref, 'Failed to set up connection message: $e');
        return;
      }

      // Attempt connection with async handling
      print('📡 Starting connection attempt...');
      mqSys
          .clientTryConnect(client)
          .then((success) {
            if (success) {
              ref.read(mqttClientProvider.notifier).state =
                  MqttConnectionState.connected;
              try {
                final rootNode = ref.read(rootProvider);
                rootNode.label = '$host:$port';
                final existingTabs = ref.read(tabListProvider);
                if (existingTabs.isEmpty) {
                  ref.read(tabListProvider.notifier).state = [rootNode];
                  ref.read(tabLengthProvider.notifier).state = 1;
                  ref.read(currentRootProvider.notifier).state = rootNode;
                  ref.read(treeNodesProvider.notifier).state = {
                    ...ref.read(treeNodesProvider),
                    rootNode.label!: [rootNode],
                  };
                  final controller = TreeController<TreeNode>(
                    roots: [rootNode],
                    childrenProvider: (TreeNode node) => node.children,
                  );
                  ref.read(tabDataProvider.notifier).state = {
                    ...ref.read(tabDataProvider),
                    rootNode.label!: {
                      'controller': controller,
                      'viewType': 'tree',
                    },
                  };
                }
                Tree_Updater.reciveStreams(client);
                // Open saved tabs
                final settings = ref.read(mqttSettingsServiceProvider).value;
                if (settings != null) {
                  for (final tab in settings.openTabs) {
                    final topic = tab['topic'] as String?;
                    if (topic != null) {
                      // Find the node by topic
                      final treeNodes = globalProviderContainer.read(
                        treeNodesProvider,
                      );
                      final root = treeNodes[topic];
                      if (root != null && root.isNotEmpty) {
                        final node = root.first;
                        // Add to tabList
                        final currentTabs = globalProviderContainer.read(
                          tabListProvider,
                        );
                        if (!currentTabs.contains(node)) {
                          globalProviderContainer
                              .read(tabListProvider.notifier)
                              .state = [
                            ...currentTabs,
                            node,
                          ];
                          // Create tree controller
                          final controller = TreeController<TreeNode>(
                            roots: [node],
                            childrenProvider: (TreeNode node) => node.children,
                          );
                          final tabData = globalProviderContainer.read(
                            tabDataProvider,
                          );
                          globalProviderContainer
                              .read(tabDataProvider.notifier)
                              .state = {
                            ...tabData,
                            topic: {
                              'controller': controller,
                              'viewType': tab['viewType'] ?? 'tree',
                            },
                          };
                        }
                      }
                    }
                  }
                }
              } catch (e) {
                print('⚠️ Error during tab restoration: $e');
              }
            } else {
              ref.read(mqttClientProvider.notifier).state =
                  MqttConnectionState.faulted;
              print('❌ Connection failed');
              _showError(ref, 'Connection failed - check host and port');
            }
          })
          .catchError((error) {
            ref.read(mqttClientProvider.notifier).state =
                MqttConnectionState.faulted;
            print('❌ Connection error: $error');
            _showError(ref, 'Connection error: $error');
          });
    } catch (e) {
      print('❌ Setup error: $e');
      _showError(ref, 'Setup error: $e');
    }
  }

  void _showError(WidgetRef ref, String message) {
    print('❌ Setup Error: $message');
    // Show snackbar to user
    // Note: Cannot use ScaffoldMessenger here without BuildContext
    // Will use a callback approach instead
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(versionSetter);
    ref.watch(routerProvider);

    final theme = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        elevation: 4,
        centerTitle: false,
        automaticallyImplyLeading: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(2)),
        ),
        title: const Text(
          "Client Setup",
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontStyle: FontStyle.normal,
            fontSize: 20,
          ),
        ),
        leading: const Icon(Icons.menu, size: 24),
        actions: [
          Row(
            children: [
              const Text("Theme"),
              Switch.adaptive(
                value: theme.brightness == Brightness.dark,
                onChanged: (isDark) {
                  ref.read(themeServiceProvider.notifier).setDarkMode(isDark);
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 20, 0),
            child: IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                // Navigate to settings page
                ref.read(routerProvider).push('/settings');
              },
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          InfiniteGridBackground(
            gridSize: 30.0,
            lineOpacity: 0.8,
            lineWidth: 2,
          ),
          Positioned(
            bottom: 0.0,
            right: 0.0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("v${ref.watch(versionProvider).toString()}"),
            ),
          ),
          SetupWidget(startClient: _startClient),
        ],
      ),
    );
  }
}
