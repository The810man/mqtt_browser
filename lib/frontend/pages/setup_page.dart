import 'dart:developer' show log;
import 'dart:math' hide log;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mqtt_browser/frontend/responsive.dart';
import 'package:mqtt_browser/frontend/widgets/tiled_background.dart';
import 'package:mqtt_browser/frontend/widgets/reactive_widgets/setup_widget.dart';
import 'package:mqtt_browser/backend/mqtt_service.dart' show MqttConnectionRefusedException;
import 'package:mqtt_browser/providers/providers.dart';

part 'setup_page.g.dart';

@Riverpod(keepAlive: true)
class Version extends _$Version {
  @override
  String build() => '';

  Future<void> loadFromPlatform() async {
    final info = await PackageInfo.fromPlatform();
    state = info.version;
  }
}

class SetUpPage extends ConsumerWidget {
  const SetUpPage({super.key});

  String _randomClientId() {
    final rand = Random().nextInt(900000) + 100000;
    return 'mqtt-browser-$rand';
  }

  Future<void> _startClient(WidgetRef ref, BuildContext context) async {
    final host = ref.read(hostProvider);
    final portStr = ref.read(portProvider);
    final settings = ref.read(mqttSettingsProvider);

    if (host.isEmpty) {
      _showError(context, 'Host cannot be empty');
      return;
    }

    final port = int.tryParse(portStr);
    if (port == null || port < 1 || port > 65535) {
      _showError(context, 'Port must be a number between 1 and 65535');
      return;
    }

    final clientId = settings.clientId.isNotEmpty
        ? settings.clientId
        : _randomClientId();

    log('Connecting to $host:$port as $clientId', name: 'SetUpPage');

    try {
      final connected = await ref
          .read(mqttClientProvider.notifier)
          .connect(host, port, clientId, settings);

      if (!connected && context.mounted) {
        _showError(
          context,
          'Connection refused by $host:$port — check credentials and that '
          'the broker supports MQTT 5',
        );
      }
    } on MqttConnectionRefusedException catch (e) {
      log('Broker refused connection: $e', name: 'SetUpPage');
      if (context.mounted) _showError(context, '$e');
    } on Exception catch (e, st) {
      log('Connection error: $e', name: 'SetUpPage', stackTrace: st);
      if (context.mounted) _showError(context, 'Connection error: $e');
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(versionProvider.notifier).loadFromPlatform();

    final theme = ref.watch(themeProvider);
    final mobile = isMobile(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        elevation: 4,
        centerTitle: false,
        automaticallyImplyLeading: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(2)),
        ),
        title: Row(
          children: [
            Image.asset(
              'assets/mqtt-browser.png',
              width: mobile ? 28 : 36,
              height: mobile ? 28 : 36,
              errorBuilder: (context2, e, stackTrace) =>
                  const Icon(Icons.hub, size: 28),
            ),
            const SizedBox(width: 10),
            Text(
              'MQTT Browser',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: mobile ? 17 : 20,
              ),
            ),
          ],
        ),
        actions: [
          if (!mobile) ...[
            const Text('Theme'),
            Switch.adaptive(
              value: theme.brightness == Brightness.dark,
              onChanged: (isDark) =>
                  ref.read(themeServiceProvider.notifier).setDarkMode(isDark),
            ),
          ],
          if (mobile)
            IconButton(
              icon: Icon(
                theme.brightness == Brightness.dark
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
              tooltip: 'Toggle theme',
              onPressed: () => ref
                  .read(themeServiceProvider.notifier)
                  .setDarkMode(theme.brightness != Brightness.dark),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(8, 0, mobile ? 8 : 20, 0),
            child: IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'Settings',
              onPressed: () => ref.read(routerProvider).push('/settings'),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          InfiniteGridBackground(gridSize: 30, lineOpacity: 0.8, lineWidth: 2),
          Positioned(
            bottom: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                'v${ref.watch(versionProvider)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
          SafeArea(
            child: SetupWidget(
              startClient: (ref) => _startClient(ref, context),
            ),
          ),
        ],
      ),
    );
  }
}
