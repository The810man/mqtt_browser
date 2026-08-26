import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_browser/models/mqtt_settings.dart';
import 'package:mqtt_browser/providers/providers.dart';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SetupSettings extends HookConsumerWidget {
  const SetupSettings({
    Key? key,
    required this.startClient,
    required this.height,
    required this.width,
  }) : super(key: key);

  final ValueChanged<WidgetRef> startClient;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hostController = useTextEditingController(
      text: ref.watch(hostProvider),
    );
    final portController = useTextEditingController(
      text: ref.watch(portProvider),
    );
    final host = ref.watch(hostProvider);
    final port = ref.watch(portProvider);
    final theme = ref.watch(themeProvider);

    // Sync controllers text with provider values
    useEffect(() {
      if (hostController.text != host) {
        hostController.text = host;
      }
      if (portController.text != port) {
        portController.text = port;
      }
      return null;
    }, [host, port]);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.8),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.settings_input_hdmi,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Connection Settings',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Input fields
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Host field
                  Text(
                    'Host / Broker Address',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _ProtocolToggle(),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: hostController,
                          onChanged: (value) {
                            ref.read(hostProvider.notifier).set(value);
                          },
                          decoration: InputDecoration(
                            hintText: 'e.g., localhost, mqtt.example.com',
                            prefixIcon: const Icon(Icons.cloud),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Port field
                  Text('Port', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  TextField(
                    controller: portController,
                    onChanged: (value) {
                      ref.read(portProvider.notifier).set(value);
                    },
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: '1883',
                      prefixIcon: const Icon(Icons.pin),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Additional connection options
                  const SizedBox(height: 8),
                  Text(
                    'Client ID',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: ref.watch(mqttSettingsProvider).clientId,
                    onChanged: (v) => ref
                        .read(mqttSettingsServiceProvider.notifier)
                        .updateSettings(
                          ref.read(mqttSettingsProvider).copyWith(clientId: v),
                        ),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Username',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              initialValue:
                                  ref.watch(mqttSettingsProvider).username ??
                                  '',
                              onChanged: (v) => ref
                                  .read(mqttSettingsServiceProvider.notifier)
                                  .updateSettings(
                                    ref
                                        .read(mqttSettingsProvider)
                                        .copyWith(username: v),
                                  ),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Password',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              initialValue:
                                  ref.watch(mqttSettingsProvider).password ??
                                  '',
                              obscureText: true,
                              onChanged: (v) => ref
                                  .read(mqttSettingsServiceProvider.notifier)
                                  .updateSettings(
                                    ref
                                        .read(mqttSettingsProvider)
                                        .copyWith(password: v),
                                  ),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: SwitchListTile.adaptive(
                          value: ref.watch(mqttSettingsProvider).cleanSession,
                          onChanged: (v) => ref
                              .read(mqttSettingsServiceProvider.notifier)
                              .updateSettings(
                                ref
                                    .read(mqttSettingsProvider)
                                    .copyWith(cleanSession: v),
                              ),
                          title: const Text('Clean Session'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SwitchListTile.adaptive(
                          value: ref.watch(mqttSettingsProvider).useTls,
                          onChanged: (v) => ref
                              .read(mqttSettingsServiceProvider.notifier)
                              .updateSettings(
                                ref
                                    .read(mqttSettingsProvider)
                                    .copyWith(useTls: v),
                              ),
                          title: const Text('Use TLS'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'KeepAlive',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            SizedBox(height: 8),
                            TextFormField(
                              initialValue: ref
                                  .watch(mqttSettingsProvider)
                                  .keepAliveSeconds
                                  .toString(),
                              keyboardType: TextInputType.number,
                              onChanged: (v) {
                                final val =
                                    int.tryParse(v) ??
                                    ref
                                        .read(mqttSettingsProvider)
                                        .keepAliveSeconds;
                                ref
                                    .read(mqttSettingsServiceProvider.notifier)
                                    .updateSettings(
                                      ref
                                          .read(mqttSettingsProvider)
                                          .copyWith(keepAliveSeconds: val),
                                    );
                              },
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Timeout (s)',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            SizedBox(height: 8),
                            TextFormField(
                              initialValue: ref
                                  .watch(mqttSettingsProvider)
                                  .connectionTimeoutSeconds
                                  .toString(),
                              keyboardType: TextInputType.number,
                              onChanged: (v) {
                                final val =
                                    int.tryParse(v) ??
                                    ref
                                        .read(mqttSettingsProvider)
                                        .connectionTimeoutSeconds;
                                ref
                                    .read(mqttSettingsServiceProvider.notifier)
                                    .updateSettings(
                                      ref
                                          .read(mqttSettingsProvider)
                                          .copyWith(
                                            connectionTimeoutSeconds: val,
                                          ),
                                    );
                              },
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Subscriptions
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Subscriptions',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          Row(
                            children: [
                              Text('Auto on connect'),
                              const SizedBox(width: 8),
                              Switch.adaptive(
                                value: ref
                                    .watch(mqttSettingsProvider)
                                    .autoSubscribeOnConnect,
                                onChanged: (v) => ref
                                    .read(mqttSettingsServiceProvider.notifier)
                                    .updateSettings(
                                      ref
                                          .read(mqttSettingsProvider)
                                          .copyWith(autoSubscribeOnConnect: v),
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Subscription editor (topic + qos)
                      _SubscriptionEditor(),

                      const SizedBox(height: 8),
                      // Current subscriptions list
                      Column(
                        children: ref
                            .watch(mqttSettingsProvider)
                            .subscriptions
                            .map((s) {
                              final topic = s['topic']?.toString() ?? '#';
                              final qos = s['qos'] is int
                                  ? s['qos'] as int
                                  : int.tryParse(s['qos']?.toString() ?? '0') ??
                                        0;
                              return ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  topic,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  'QoS: $qos',
                                  style: TextStyle(
                                    color: theme.colorScheme.outline,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    FilledButton.tonal(
                                      onPressed: () {
                                        try {
                                          ref
                                              .read(mqttClientProvider.notifier)
                                              .subscribe(topic, qos: qos);
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text('Subscribed'),
                                            ),
                                          );
                                        } catch (e) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Subscribe failed: $e',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      child: const Text('Subscribe'),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      onPressed: () {
                                        // remove
                                        final current =
                                            List<Map<String, dynamic>>.from(
                                              ref
                                                  .read(mqttSettingsProvider)
                                                  .subscriptions,
                                            );
                                        current.removeWhere(
                                          (it) =>
                                              it['topic'] == topic &&
                                              (it['qos'] == qos ||
                                                  it['qos'].toString() ==
                                                      qos.toString()),
                                        );
                                        ref
                                            .read(
                                              mqttSettingsServiceProvider
                                                  .notifier,
                                            )
                                            .updateSettings(
                                              ref
                                                  .read(mqttSettingsProvider)
                                                  .copyWith(
                                                    subscriptions: current,
                                                  ),
                                            );
                                      },
                                      icon: const Icon(
                                        Icons.delete,
                                        size: 18,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            })
                            .toList(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Reset button
                      OutlinedButton.icon(
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Reset'),
                        onPressed: () {
                          ref.read(hostProvider.notifier).set('localhost');
                          ref.read(portProvider.notifier).set('1883');
                          ref
                              .read(mqttSettingsServiceProvider.notifier)
                              .updateSettings(
                                MqttSettings(
                                  host: 'localhost',
                                  port: 1883,
                                  clientId: 'mqtt_browser_client',
                                ),
                              );
                        },
                      ),
                      // Save button
                      OutlinedButton.icon(
                        icon: const Icon(Icons.bookmark_add, size: 18),
                        label: const Text('Save'),
                        onPressed: () async {
                          try {
                            final portNum = int.parse(port);
                            if (host.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Host cannot be empty'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            // Ask for name
                            final name = await showDialog<String>(
                              context: context,
                              builder: (ctx) {
                                final ctrl = TextEditingController(
                                  text: '$host:$port',
                                );
                                return AlertDialog(
                                  title: const Text('Save Connection'),
                                  content: TextField(
                                    controller: ctrl,
                                    decoration: const InputDecoration(
                                      labelText: 'Name',
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(),
                                      child: const Text('Cancel'),
                                    ),
                                    FilledButton(
                                      onPressed: () =>
                                          Navigator.of(ctx).pop(ctrl.text),
                                      child: const Text('Save'),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (name != null && name.isNotEmpty) {
                              final settings = ref.read(mqttSettingsProvider);
                              // Update openTabs with current tabs
                              final tabList = ref.read(tabListProvider);
                              final openTabs = tabList
                                  .map(
                                    (node) => {
                                      'topic': node.label,
                                      'viewType': 'tree',
                                    },
                                  )
                                  .toList();
                              final updatedSettings = settings.copyWith(
                                openTabs: openTabs,
                              );
                              ref
                                  .read(mqttSettingsServiceProvider.notifier)
                                  .updateSettings(updatedSettings);
                              ref
                                  .read(connectionsEntriesProvider.notifier)
                                  .addEntry({
                                    "name": name,
                                    "host": host,
                                    "port": portNum,
                                    'settings': updatedSettings.toJson(),
                                    'icon': 'cloud',
                                  });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Saved: $name')),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Invalid port: $port'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Connect button (full width)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton.icon(
                      icon: const Icon(Icons.power_settings_new),
                      label: const Text('Connect'),
                      onPressed: () {
                        startClient(ref);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubscriptionEditor extends HookWidget {
  const _SubscriptionEditor({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final topicController = useTextEditingController(text: '#');
    final qos = useState<int>(0);

    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: topicController,
            decoration: const InputDecoration(hintText: 'Topic (e.g. #)'),
          ),
        ),
        const SizedBox(width: 8),
        DropdownButton<int>(
          value: qos.value,
          items: const [
            DropdownMenuItem(value: 0, child: Text('QoS 0')),
            DropdownMenuItem(value: 1, child: Text('QoS 1')),
            DropdownMenuItem(value: 2, child: Text('QoS 2')),
          ],
          onChanged: (v) => qos.value = v ?? 0,
        ),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: () {
            final topic = topicController.text.trim();
            if (topic.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Topic cannot be empty'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }
            final container = ProviderScope.containerOf(context, listen: false);
            final currentSettings = container.read(mqttSettingsProvider);
            final currentSubs = List<Map<String, dynamic>>.from(
              currentSettings.subscriptions,
            );
            currentSubs.add({'topic': topic, 'qos': qos.value});
            container
                .read(mqttSettingsServiceProvider.notifier)
                .updateSettings(
                  currentSettings.copyWith(subscriptions: currentSubs),
                );
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Subscription added')));
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class _ProtocolToggle extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // On web the browser always uses WebSocket — TCP is not available.
    final useWs = kIsWeb ? true : ref.watch(useWebSocketProvider);
    final theme = Theme.of(context);

    return Tooltip(
      message: kIsWeb
          ? 'Browser always uses WebSocket'
          : useWs
          ? 'WebSocket — click for MQTT/TCP'
          : 'MQTT/TCP — click for WebSocket',
      child: InkWell(
        onTap: kIsWeb
            ? null
            : () => ref.read(useWebSocketProvider.notifier).toggle(),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: useWs
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outlineVariant,
            ),
            borderRadius: BorderRadius.circular(8),
            color: useWs
                ? theme.colorScheme.primaryContainer.withValues(alpha: 0.4)
                : Colors.transparent,
          ),
          child: Text(
            useWs ? 'WS' : 'MQTT',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: useWs
                  ? theme.colorScheme.primary
                  : kIsWeb
                  ? theme.colorScheme.primary.withValues(alpha: 0.6)
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
