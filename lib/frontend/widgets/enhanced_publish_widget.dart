import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mqtt5_client/mqtt5_client.dart' hide MqttConnectionState;
import '../tree_node.dart';
import 'package:mqtt_browser/providers/providers.dart';

class EnhancedPublishWidget extends HookConsumerWidget {
  final TreeNode root;

  const EnhancedPublishWidget({super.key, required this.root});

  String? _validateJson(String jsonString) {
    if (jsonString.trim().isEmpty) {
      return 'JSON cannot be empty';
    }
    try {
      jsonDecode(jsonString);
      return null;
    } catch (e) {
      return 'Invalid JSON: ${e.toString()}';
    }
  }

  String? _validateXml(String xmlString) {
    if (xmlString.trim().isEmpty) {
      return 'XML cannot be empty';
    }
    // Basic XML validation - check for opening and closing tags
    if (!xmlString.contains('<') || !xmlString.contains('>')) {
      return 'Invalid XML: Missing XML tags';
    }
    return null;
  }

  String? _validateText(String textString) {
    if (textString.trim().isEmpty) {
      return 'Text cannot be empty';
    }
    return null;
  }

  String? _validatePayload(String payload, String format) {
    // An empty payload is valid on its own — combined with Retain it clears
    // (deletes) the topic's retained message on the broker.
    if (payload.isEmpty) return null;
    switch (format) {
      case 'json':
        return _validateJson(payload);
      case 'xml':
        return _validateXml(payload);
      case 'text':
        return _validateText(payload);
      default:
        return 'Unknown format';
    }
  }

  String? _validateTopic(String topic) {
    if (topic.trim().isEmpty) {
      return 'Topic cannot be empty';
    }
    if (topic.contains('+') || topic.contains('#')) {
      return 'Topic cannot contain wildcards (+ or #)';
    }
    return null;
  }

  void _publishMessage(BuildContext context, WidgetRef ref) {
    final topicController = ref.read(publishTextControllerProvider);
    final topic = topicController.text;
    final payload = ref.read(currentMessageProvider)[root] ?? '';
    final format = ref.read(publishFormatProvider);
    final qos = ref.read(publishQosProvider);
    final retain = ref.read(publishRetainProvider);

    // Validate inputs
    final topicError = _validateTopic(topic);
    if (topicError != null) {
      _showError(context, topicError);
      return;
    }

    final payloadError = _validatePayload(payload, format);
    if (payloadError != null) {
      _showError(context, payloadError);
      return;
    }

    final notifier = ref.read(mqttClientProvider.notifier);
    if (ref.read(mqttClientProvider) != MqttConnectionState.connected) {
      _showError(context, 'Publish failed: not connected');
      return;
    }

    try {
      final qosInt = qos == MqttQos.atLeastOnce
          ? 1
          : qos == MqttQos.exactlyOnce
          ? 2
          : 0;
      notifier.publish(topic, payload, qos: qosInt, retain: retain);
      _showSuccess(
        context,
        payload.isEmpty ? 'Cleared retained message on: $topic' : 'Published to: $topic',
      );
    } catch (e) {
      _showError(context, 'Publish failed: $e');
    }
  }

  void _deleteRetained(BuildContext context, WidgetRef ref) {
    final topicController = ref.read(publishTextControllerProvider);
    final topic = topicController.text;

    final topicError = _validateTopic(topic);
    if (topicError != null) {
      _showError(context, topicError);
      return;
    }

    if (ref.read(mqttClientProvider) != MqttConnectionState.connected) {
      _showError(context, 'Delete failed: not connected');
      return;
    }

    try {
      ref.read(mqttClientProvider.notifier).publish(topic, '', retain: true);
      ref.read(currentMessageProvider.notifier).set(root, '');
      _showSuccess(context, 'Deleted retained message on: $topic');
    } catch (e) {
      _showError(context, 'Delete failed: $e');
    }
  }

  void _showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green.shade600,
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red.shade600,
        duration: const Duration(seconds: 4),
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topic = ref.watch(publishTextControllerProvider).text;
    final format = ref.watch(publishFormatProvider);
    final qos = ref.watch(publishQosProvider);
    final retain = ref.watch(publishRetainProvider);
    // `selectionSignal` toggles only when the user picks a different topic in
    // the tree (see tree_nodes_widget.dart), not on every keystroke here.
    // Keying the sync effect off it — instead of off `payload` itself — is
    // what stops the cursor from jumping to the end after each character:
    // re-running this effect on every `payload` change would reset the
    // controller's selection on every keystroke, since `onChanged` below
    // writes each keystroke straight back into `payload`.
    final selectionSignal = ref.watch(changeIshappeningProvider);
    final payload = ref.watch(currentMessageProvider)[root] ?? '';
    final payloadController = useTextEditingController(text: payload);
    useEffect(() {
      payloadController.text = payload;
      payloadController.selection = TextSelection.fromPosition(
        TextPosition(offset: payloadController.text.length),
      );
      return null;
    }, [root, selectionSignal]);
    final payloadError = _validatePayload(payload, format);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Topic Input Section
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Topic',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: ref.read(publishTextControllerProvider),
                decoration: InputDecoration(
                  hintText: 'e.g., home/temperature/sensor1',
                  prefixIcon: const Icon(Icons.topic),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Payload Editor Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${format.toUpperCase()} Payload',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      DropdownButton<String>(
                        value: format,
                        items: const [
                          DropdownMenuItem(value: 'json', child: Text('JSON')),
                          DropdownMenuItem(value: 'xml', child: Text('XML')),
                          DropdownMenuItem(value: 'text', child: Text('Text')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            ref.read(publishFormatProvider.notifier).set(value);
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      if (payloadError != null)
                        Chip(
                          avatar: const Icon(
                            Icons.warning,
                            size: 16,
                            color: Colors.white,
                          ),
                          label: Text(
                            payloadError,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                          backgroundColor: Colors.red.shade600,
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: payloadError != null
                        ? Colors.red
                        : Colors.grey.shade400,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  maxLines: 5,
                  controller: payloadController,
                  decoration: InputDecoration(
                    hintText: format == 'json'
                        ? '{"key": "value"}'
                        : format == 'xml'
                        ? '<root><element>value</element></root>'
                        : 'Plain text message',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(8),
                    filled: true,
                    fillColor: payloadError != null
                        ? Colors.red.withOpacity(0.05)
                        : Colors.transparent,
                  ),
                  onChanged: (value) {
                    ref.read(currentMessageProvider.notifier).set(
                      root,
                      value,
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Options Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // QoS Dropdown
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        const Text(
                          'QoS Level',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        DropdownButton<MqttQos>(
                          value: qos,
                          isExpanded: true,
                          items: [
                            DropdownMenuItem(
                              value: MqttQos.atMostOnce,
                              child: const Text('0 - At Most Once'),
                            ),
                            DropdownMenuItem(
                              value: MqttQos.atLeastOnce,
                              child: const Text('1 - At Least Once'),
                            ),
                            DropdownMenuItem(
                              value: MqttQos.exactlyOnce,
                              child: const Text('2 - Exactly Once'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              ref.read(publishQosProvider.notifier).set(value);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Retain Toggle
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      const Text(
                        'Retain',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Switch(
                        value: retain,
                        onChanged: (value) {
                          ref.read(publishRetainProvider.notifier).set(value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Publish Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.send),
                    label: const Text(
                      'Publish Message',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    onPressed: payloadError == null && topic.isNotEmpty
                        ? () => _publishMessage(context, ref)
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade600,
                    side: BorderSide(color: Colors.red.shade300),
                  ),
                  onPressed: topic.isNotEmpty
                      ? () => _deleteRetained(context, ref)
                      : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
