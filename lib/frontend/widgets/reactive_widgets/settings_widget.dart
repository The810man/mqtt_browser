import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_browser/frontend/widgets/reactive_widgets/setup_widget.dart';
import 'package:mqtt_browser/main.dart';
import 'package:mqtt_browser/services/mqtt_settings_service.dart';
import 'package:mqtt_browser/backend/mqtt_sys.dart' as mqSys;
import 'package:mqtt_browser/providers/theme_provider.dart';

class SetupSettings extends ConsumerStatefulWidget {
  const SetupSettings({
    super.key,
    required this.startClient,
    required this.height,
    required this.width,
  });

  final ValueChanged<WidgetRef> startClient;
  final double height;
  final double width;

  @override
  ConsumerState<SetupSettings> createState() => _SetupSettingsState();
}

class _SetupSettingsState extends ConsumerState<SetupSettings> {
  late final TextEditingController _hostController;
  late final TextEditingController _portController;

  @override
  void initState() {
    super.initState();
    _hostController = TextEditingController(text: ref.read(hostProvider));
    _portController = TextEditingController(text: ref.read(portProvider));
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final host = ref.watch(hostProvider);
    final port = ref.watch(portProvider);
    final theme = ref.watch(themeProvider);

    // Update controllers if provider changes externally (e.g., loading connection)
    if (_hostController.text != host) {
      _hostController.text = host;
    }
    if (_portController.text != port) {
      _portController.text = port;
    }

    return Container(
      width: widget.width,
      height: widget.height,
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.settings_input_hdmi,
                    color: theme.colorScheme.primary),
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
                  TextField(
                    controller: _hostController,
                    onChanged: (value) {
                      ref.read(hostProvider.notifier).state = value;
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
                  const SizedBox(height: 16),
                  // Port field
                  Text(
                    'Port',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _portController,
                    onChanged: (value) {
                      ref.read(portProvider.notifier).state = value;
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
                  Text('Client ID',
                      style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: ref.watch(mqttSettingsProvider).clientId,
                    onChanged: (v) => ref
                        .read(mqttSettingsProvider.notifier)
                        .updateSettings(ref
                            .read(mqttSettingsProvider)
                            .copyWith(clientId: v)),
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Username',
                                style: Theme.of(context).textTheme.labelLarge),
                            const SizedBox(height: 8),
                            TextFormField(
                              initialValue:
                                  ref.watch(mqttSettingsProvider).username ??
                                      '',
                              onChanged: (v) => ref
                                  .read(mqttSettingsProvider.notifier)
                                  .updateSettings(ref
                                      .read(mqttSettingsProvider)
                                      .copyWith(username: v)),
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10)),
                            ),
                          ]),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Password',
                                style: Theme.of(context).textTheme.labelLarge),
                            const SizedBox(height: 8),
                            TextFormField(
                              initialValue:
                                  ref.watch(mqttSettingsProvider).password ??
                                      '',
                              obscureText: true,
                              onChanged: (v) => ref
                                  .read(mqttSettingsProvider.notifier)
                                  .updateSettings(ref
                                      .read(mqttSettingsProvider)
                                      .copyWith(password: v)),
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10)),
                            ),
                          ]),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                        child: SwitchListTile.adaptive(
                            value: ref.watch(mqttSettingsProvider).cleanSession,
                            onChanged: (v) => ref
                                .read(mqttSettingsProvider.notifier)
                                .updateSettings(ref
                                    .read(mqttSettingsProvider)
                                    .copyWith(cleanSession: v)),
                            title: const Text('Clean Session'))),
                    const SizedBox(width: 8),
                    Expanded(
                        child: SwitchListTile.adaptive(
                            value: ref.watch(mqttSettingsProvider).useTls,
                            onChanged: (v) => ref
                                .read(mqttSettingsProvider.notifier)
                                .updateSettings(ref
                                    .read(mqttSettingsProvider)
                                    .copyWith(useTls: v)),
                            title: const Text('Use TLS'))),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text('KeepAlive',
                              style: Theme.of(context).textTheme.labelLarge),
                          SizedBox(height: 8),
                          TextFormField(
                            initialValue: ref
                                .watch(mqttSettingsProvider)
                                .keepAliveSeconds
                                .toString(),
                            keyboardType: TextInputType.number,
                            onChanged: (v) {
                              final val = int.tryParse(v) ??
                                  ref
                                      .read(mqttSettingsProvider)
                                      .keepAliveSeconds;
                              ref
                                  .read(mqttSettingsProvider.notifier)
                                  .updateSettings(ref
                                      .read(mqttSettingsProvider)
                                      .copyWith(keepAliveSeconds: val));
                            },
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10)),
                          )
                        ])),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text('Timeout (s)',
                              style: Theme.of(context).textTheme.labelLarge),
                          SizedBox(height: 8),
                          TextFormField(
                            initialValue: ref
                                .watch(mqttSettingsProvider)
                                .connectionTimeoutSeconds
                                .toString(),
                            keyboardType: TextInputType.number,
                            onChanged: (v) {
                              final val = int.tryParse(v) ??
                                  ref
                                      .read(mqttSettingsProvider)
                                      .connectionTimeoutSeconds;
                              ref
                                  .read(mqttSettingsProvider.notifier)
                                  .updateSettings(ref
                                      .read(mqttSettingsProvider)
                                      .copyWith(connectionTimeoutSeconds: val));
                            },
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10)),
                          )
                        ])),
                  ]),

                  const SizedBox(height: 16),

                  // Subscriptions
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Subscriptions',
                              style: Theme.of(context).textTheme.titleSmall),
                          Row(children: [
                            Text('Auto on connect'),
                            const SizedBox(width: 8),
                            Switch.adaptive(
                              value: ref
                                  .watch(mqttSettingsProvider)
                                  .autoSubscribeOnConnect,
                              onChanged: (v) => ref
                                  .read(mqttSettingsProvider.notifier)
                                  .updateSettings(ref
                                      .read(mqttSettingsProvider)
                                      .copyWith(autoSubscribeOnConnect: v)),
                            ),
                          ])
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
                              : int.tryParse(s['qos']?.toString() ?? '0') ?? 0;
                          return ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text(topic,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            subtitle: Text('QoS: $qos',
                                style: TextStyle(
                                    color: theme.colorScheme.outline)),
                            trailing:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              FilledButton.tonal(
                                  onPressed: () {
                                    final client = ref.read(clientProvider);
                                    if (client == null) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text('Not connected')));
                                      return;
                                    }
                                    try {
                                      // perform subscribe now
                                      mqSys.clientSubcribe(client, topic, qos);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text('Subscribed')));
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text(
                                                  'Subscribe failed: $e')));
                                    }
                                  },
                                  child: const Text('Subscribe')),
                              const SizedBox(width: 8),
                              IconButton(
                                  onPressed: () {
                                    // remove
                                    final current =
                                        List<Map<String, dynamic>>.from(ref
                                            .read(mqttSettingsProvider)
                                            .subscriptions);
                                    current.removeWhere((it) =>
                                        it['topic'] == topic &&
                                        (it['qos'] == qos ||
                                            it['qos'].toString() ==
                                                qos.toString()));
                                    ref
                                        .read(mqttSettingsProvider.notifier)
                                        .updateSettings(ref
                                            .read(mqttSettingsProvider)
                                            .copyWith(subscriptions: current));
                                  },
                                  icon: const Icon(Icons.delete,
                                      size: 18, color: Colors.red)),
                            ]),
                          );
                        }).toList(),
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
                          ref.read(hostProvider.notifier).state = 'localhost';
                          ref.read(portProvider.notifier).state = '1883';
                          ref
                              .read(mqttSettingsProvider.notifier)
                              .updateSettings(MqttSettings(
                                  host: 'localhost',
                                  port: 1883,
                                  clientId: 'mqtt_browser_client'));
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
                                      text: '$host:$port');
                                  return AlertDialog(
                                    title: const Text('Save Connection'),
                                    content: TextField(
                                        controller: ctrl,
                                        decoration: const InputDecoration(
                                            labelText: 'Name')),
                                    actions: [
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.of(ctx).pop(),
                                          child: const Text('Cancel')),
                                      FilledButton(
                                          onPressed: () =>
                                              Navigator.of(ctx).pop(ctrl.text),
                                          child: const Text('Save')),
                                    ],
                                  );
                                });

                            if (name != null && name.isNotEmpty) {
                              final settings = ref.read(mqttSettingsProvider);
                              // Update openTabs with current tabs
                              final tabList = ref.read(tabListProvider);
                              final openTabs = tabList
                                  .map((node) =>
                                      {'topic': node.label, 'viewType': 'tree'})
                                  .toList();
                              final updatedSettings =
                                  settings.copyWith(openTabs: openTabs);
                              ref
                                  .read(mqttSettingsProvider.notifier)
                                  .updateSettings(updatedSettings);
                              ref.read(fileProvider.notifier).addEntry([
                                {
                                  "name": name,
                                  "host": host,
                                  "port": portNum,
                                  'settings': updatedSettings.toJson()
                                }
                              ]);
                              ref
                                  .read(fileProvider.notifier)
                                  .setConnections(ref);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Saved: $name')));
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
                        widget.startClient(ref);
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

class _SubscriptionEditor extends StatefulWidget {
  const _SubscriptionEditor({super.key});

  @override
  State<_SubscriptionEditor> createState() => _SubscriptionEditorState();
}

class _SubscriptionEditorState extends State<_SubscriptionEditor> {
  final TextEditingController _topicController =
      TextEditingController(text: '#');
  int _qos = 0;

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _topicController,
            decoration: const InputDecoration(hintText: 'Topic (e.g. #)'),
          ),
        ),
        const SizedBox(width: 8),
        DropdownButton<int>(
          value: _qos,
          items: const [
            DropdownMenuItem(value: 0, child: Text('QoS 0')),
            DropdownMenuItem(value: 1, child: Text('QoS 1')),
            DropdownMenuItem(value: 2, child: Text('QoS 2')),
          ],
          onChanged: (v) => setState(() => _qos = v ?? 0),
        ),
        const SizedBox(width: 8),
        FilledButton(
            onPressed: () {
              final topic = _topicController.text.trim();
              if (topic.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Topic cannot be empty'),
                    backgroundColor: Colors.red));
                return;
              }
              final container = globalProviderContainer;
              final currentSettings = container.read(mqttSettingsProvider);
              final currentSubs = List<Map<String, dynamic>>.from(
                  currentSettings.subscriptions);
              currentSubs.add({'topic': topic, 'qos': _qos});
              container.read(mqttSettingsProvider.notifier).updateSettings(
                  currentSettings.copyWith(subscriptions: currentSubs));
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Subscription added')));
            },
            child: const Text('Add')),
      ],
    );
  }
}
