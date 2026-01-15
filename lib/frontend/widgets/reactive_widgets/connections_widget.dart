import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_browser/frontend/widgets/reactive_widgets/setup_widget.dart';
import 'package:mqtt_browser/main.dart';
import 'package:mqtt_browser/services/mqtt_settings_service.dart';
import 'package:mqtt_browser/providers/theme_provider.dart';

class ConnectionsWidget extends ConsumerWidget {
  const ConnectionsWidget({
    super.key,
    required this.height,
    required this.width,
  });
  final double height;
  final double width;

  IconData _getIcon(String? iconName) {
    switch (iconName) {
      case 'router':
        return Icons.router;
      case 'settings':
        return Icons.settings;
      case 'cloud':
      default:
        return Icons.cloud;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final connections = ref.watch(fileProvider);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.router, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Text(
                      'Saved Connections',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                // Theme quick-link button
                IconButton(
                  icon: const Icon(Icons.palette),
                  tooltip: 'Theme settings',
                  onPressed: () {
                    ref.read(routerProvider).go('/settings');
                  },
                ),
              ],
            ),
          ),

          // List of connections
          Expanded(
            child: connections.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 48,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No saved connections',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: connections.length,
                    itemBuilder: (context, index) {
                      final connection = connections[index];
                      final host = connection['host'] ?? 'Unknown';
                      final port = connection['port'] ?? 1883;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Card(
                          elevation: 0,
                          color: theme.colorScheme.surfaceContainer,
                          child: ListTile(
                            leading: Icon(
                              _getIcon(connection['icon']),
                              size: 20,
                              color: theme.colorScheme.primary,
                            ),
                            title: Text(
                              connection['name'] ?? host,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Text(
                              '$host · $port',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.outline,
                              ),
                            ),
                            trailing: SizedBox(
                              width: 100,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 18),
                                    onPressed: () async {
                                      // open edit dialog
                                      final edited = await showDialog<
                                              Map<String, dynamic>>(
                                          context: context,
                                          builder: (ctx) {
                                            final nameController =
                                                TextEditingController(
                                                    text: connection['name']
                                                            ?.toString() ??
                                                        host);
                                            final hostController =
                                                TextEditingController(
                                                    text: host);
                                            final portController =
                                                TextEditingController(
                                                    text: port.toString());
                                            String selectedIcon =
                                                connection['icon'] ?? 'cloud';
                                            return StatefulBuilder(
                                              builder: (context, setState) =>
                                                  AlertDialog(
                                                title: const Text(
                                                    'Edit Connection'),
                                                content: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    TextField(
                                                        controller:
                                                            nameController,
                                                        decoration:
                                                            const InputDecoration(
                                                                labelText:
                                                                    'Name')),
                                                    TextField(
                                                        controller:
                                                            hostController,
                                                        decoration:
                                                            const InputDecoration(
                                                                labelText:
                                                                    'Host')),
                                                    TextField(
                                                        controller:
                                                            portController,
                                                        decoration:
                                                            const InputDecoration(
                                                                labelText:
                                                                    'Port'),
                                                        keyboardType:
                                                            TextInputType
                                                                .number),
                                                    DropdownButtonFormField<
                                                        String>(
                                                      value: selectedIcon,
                                                      decoration:
                                                          const InputDecoration(
                                                              labelText:
                                                                  'Icon'),
                                                      items: const [
                                                        DropdownMenuItem(
                                                            value: 'cloud',
                                                            child:
                                                                Text('Cloud')),
                                                        DropdownMenuItem(
                                                            value: 'router',
                                                            child:
                                                                Text('Router')),
                                                        DropdownMenuItem(
                                                            value: 'settings',
                                                            child: Text(
                                                                'Settings')),
                                                      ],
                                                      onChanged: (value) =>
                                                          setState(() =>
                                                              selectedIcon =
                                                                  value!),
                                                    ),
                                                  ],
                                                ),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () =>
                                                          Navigator.of(ctx)
                                                              .pop(),
                                                      child:
                                                          const Text('Cancel')),
                                                  FilledButton(
                                                      onPressed: () {
                                                        Navigator.of(ctx).pop({
                                                          'name': nameController
                                                              .text,
                                                          'host': hostController
                                                              .text,
                                                          'port': int.tryParse(
                                                                  portController
                                                                      .text) ??
                                                              port,
                                                          'icon': selectedIcon,
                                                          'settings': connection[
                                                                  'settings'] ??
                                                              {},
                                                        });
                                                      },
                                                      child:
                                                          const Text('Save')),
                                                ],
                                              ),
                                            );
                                          });
                                      if (edited != null) {
                                        ref
                                            .read(fileProvider.notifier)
                                            .updateEntryAt(index, edited);
                                        ref
                                            .read(fileProvider.notifier)
                                            .setConnections(ref);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Text(
                                                    'Connection updated')));
                                      }
                                    },
                                    constraints:
                                        const BoxConstraints(maxWidth: 40),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        size: 18, color: Colors.red),
                                    onPressed: () {
                                      // delete
                                      ref
                                          .read(fileProvider.notifier)
                                          .removeEntryAt(index);
                                      ref
                                          .read(fileProvider.notifier)
                                          .setConnections(ref);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content:
                                                  Text('Connection removed')));
                                    },
                                    constraints:
                                        const BoxConstraints(maxWidth: 40),
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {
                              // apply connection - also restore settings if exist
                              ref.read(hostProvider.notifier).state = host;
                              ref.read(portProvider.notifier).state =
                                  port.toString();
                              if (connection.containsKey('settings')) {
                                try {
                                  final settingsMap = Map<String, dynamic>.from(
                                      connection['settings']);
                                  ref
                                      .read(mqttSettingsProvider.notifier)
                                      .updateSettings(
                                          MqttSettings.fromJson(settingsMap));
                                } catch (e) {
                                  // ignore malformed settings
                                }
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
