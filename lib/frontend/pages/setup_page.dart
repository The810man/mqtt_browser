import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_browser/backend/mqtt_sys.dart' as mqSys;
import 'package:mqtt_browser/frontend/widgets/custom_painters/custom_painter_widgets/line_with_streak_widget.dart';
import 'package:mqtt_browser/frontend/widgets/mqtt_background_grid_icons.dart';
import 'package:mqtt_browser/frontend/widgets/reactive_widgets/setup_widget.dart';
import 'package:mqtt_browser/main.dart';
import 'package:mqtt_browser/backend/tree_updater.dart' as Tree_Updater;
import 'package:mqtt_browser/providers/theme_provider.dart';
import 'dart:math';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:mqtt_browser/frontend/widgets/tiled_background.dart';

final versionProvider = StateProvider((ref) => "");

final versionSetter =
    StateProvider((ref) => PackageInfo.fromPlatform().then((value) {
          ref.read(versionProvider.notifier).state = value.data["version"];
        }));

class SetUpPage extends ConsumerWidget {
  final connectButtonProvider = StateProvider<bool>(((ref) => false));

  int random(int min, int max) {
    return min + Random().nextInt(max - min);
  }

  SetUpPage({super.key});

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
      };

      client.onDisconnected = () {
        print('⚠️ Disconnected callback fired');
        ref.read(isConnectedProvider.notifier).state = false;
      };

      ref.read(clientProvider.notifier).state = client;

      // Configure client
      mqSys.startClient(client, true, true);
      mqSys.setUpClient(client, 60, 5000);
      print('✓ Client configured');

      // Set up connection message
      final clientId = "mqtt-browser-${random(100000, 999999)}";
      mqSys.setUpConnMess(clientId, "will/topic", "Device offline", client);
      print('✓ Connection message setup: $clientId');

      // Attempt connection with async handling
      print('📡 Starting connection attempt...');
      mqSys.clientTryConnect(client).then((success) {
        if (success) {
          print('✅ Connection successful!');
          Tree_Updater.reciveStreams();
        } else {
          print('❌ Connection failed');
          _showError(ref, 'Connection failed - check host and port');
        }
      }).catchError((error) {
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
        leading: const Icon(
          Icons.menu,
          size: 24,
        ),
        actions: [
          Row(
            children: [
              const Text("Theme"),
              Switch.adaptive(
                  value: theme.brightness == Brightness.dark,
                  onChanged: (isDark) {
                    ref.read(themeProvider.notifier).setDarkMode(isDark);
                  })
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 20, 0),
            child: IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                // Navigate to settings page
                ref.read(routerProvider).go('/settings');
              },
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          const TiledBackground(
            tile: Icon(MqttBackgroundGrid.unbetitelt_2,
                size: 50, color: Colors.grey),
            spacing: 50,
            opacity: 0.5,
          ),
          Positioned(
              bottom: 0.0,
              right: 0.0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("v${ref.watch(versionProvider).toString()}"),
              )),
          SetupWidget(startClient: _startClient)
        ],
      ),
    );
  }
}
