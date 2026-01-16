import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_browser/frontend/widgets/reactive_widgets/connections_widget.dart';
import 'package:mqtt_browser/frontend/widgets/reactive_widgets/settings_widget.dart';

class SetupWidget extends ConsumerWidget {
  const SetupWidget({super.key, required this.startClient});
  final ValueChanged<WidgetRef> startClient;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentWidth = MediaQuery.of(context).size.width;
    final currentHeight = MediaQuery.of(context).size.height;

    if (currentWidth > 900) {
      // Wide screen: side by side
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            // Left side - connections
            Expanded(
              child: ConnectionsWidget(
                height: currentHeight - 120,
                width: double.infinity,
              ),
            ),
            const SizedBox(width: 24),
            // Right side - settings
            Expanded(
              child: SetupSettings(
                startClient: startClient,
                width: double.infinity,
                height: currentHeight - 120,
              ),
            ),
          ],
        ),
      );
    } else {
      // Narrow screen: stacked
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Settings at top
            Expanded(
              child: SetupSettings(
                startClient: startClient,
                width: double.infinity,
                height: 300,
              ),
            ),
            const SizedBox(height: 16),
            // Connections at bottom
            Expanded(
              child: ConnectionsWidget(height: 300, width: double.infinity),
            ),
          ],
        ),
      );
    }
  }
}
