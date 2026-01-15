import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt5_client/mqtt5_client.dart';
import '../tree_node.dart';
import '../../main.dart';
import '../../backend/mqtt_sys.dart' as mqSys;

final publishQosProvider = StateProvider<MqttQos>((ref) => MqttQos.atMostOnce);
final publishRetainProvider = StateProvider<bool>((ref) => false);
final jsonValidationErrorProvider = StateProvider<String?>((ref) => null);
final publishFormatProvider = StateProvider<String>((ref) => 'json');

class EnhancedPublishWidget extends ConsumerWidget {
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
    final payload = ref.read(currentMessageProvider)[root] ?? '{}';
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

    try {
      // Subscribe first to receive our own message (if broker supports)
      mqSys.clientSubcribe(ref.read(clientProvider)!, topic, 0);

      // Prepare payload
      final builder = MqttPayloadBuilder();
      builder.addString(payload);

      // Publish with error handling
      ref.read(clientProvider)!.publishMessage(
            topic,
            qos,
            builder.payload!,
            retain: retain,
          );

      _showSuccess(context, 'Published to: $topic');
    } catch (e) {
      _showError(context, 'Publish failed: ${e.toString()}');
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
                child:
                    Text(message, style: const TextStyle(color: Colors.white))),
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
                child:
                    Text(message, style: const TextStyle(color: Colors.white))),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topic = ref.watch(publishTextControllerProvider).text;
    final qos = ref.watch(publishQosProvider);
    final retain = ref.watch(publishRetainProvider);
    final format = ref.watch(publishFormatProvider);
    final payload = ref.watch(currentMessageProvider)[root] ?? '{}';
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
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: ref.read(publishTextControllerProvider),
                decoration: InputDecoration(
                  hintText: 'e.g., home/temperature/sensor1',
                  prefixIcon: const Icon(Icons.topic),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                            ref.read(publishFormatProvider.notifier).state =
                                value;
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      if (payloadError != null)
                        Chip(
                          avatar: const Icon(Icons.warning,
                              size: 16, color: Colors.white),
                          label: Text(payloadError,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 11)),
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
                  controller: TextEditingController(text: payload),
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
                    ref.read(currentMessageProvider.notifier).state = {
                      root: value,
                    };
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
                        const Text('QoS Level',
                            style: TextStyle(
                                fontSize: 11, fontWeight: FontWeight.bold)),
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
                              ref.read(publishQosProvider.notifier).state =
                                  value;
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
                      const Text('Retain',
                          style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Switch(
                        value: retain,
                        onChanged: (value) {
                          ref.read(publishRetainProvider.notifier).state =
                              value;
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
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.send),
              label: const Text('Publish Message',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              onPressed: payloadError == null && topic.isNotEmpty
                  ? () => _publishMessage(context, ref)
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
