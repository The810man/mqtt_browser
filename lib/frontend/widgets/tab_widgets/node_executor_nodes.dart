import 'dart:io';

import 'package:fl_nodes/fl_nodes.dart';
import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Global MQTT value registry
// ---------------------------------------------------------------------------

typedef MqttPublishFn = Future<void> Function(
  String topic,
  String payload, {
  bool retain,
});

class MqttValueRegistry {
  MqttValueRegistry._();

  static final Map<String, String> _values = {};
  static MqttPublishFn? publishCallback;

  static void update(String topic, String value) => _values[topic] = value;
  static String get(String topic) => _values[topic] ?? '';

  static Future<void> publish(
    String topic,
    String payload, {
    bool retain = false,
  }) async {
    await publishCallback?.call(topic, payload, retain: retain);
  }
}

// ---------------------------------------------------------------------------
// Register all MQTT executor node prototypes
// ---------------------------------------------------------------------------

void registerExecutorNodes(FlNodeEditorController controller) {
  // ── MQTT: Topic Source ─────────────────────────────────────────────────
  controller.registerNodePrototype(
    FlNodePrototype(
      idName: 'mqtt.topic',
      displayName: (_) => 'MQTT Topic',
      description: (_) => 'Emits the current value of an MQTT topic.',
      headerStyleBuilder: _header(const Color(0xFF1565C0)),
      ports: [
        FlControlOutputPortPrototype(
          idName: 'changed',
          displayName: (_) => 'Changed',
          styleBuilder: _controlPort,
        ),
        FlDataOutputPortPrototype<String>(
          idName: 'value',
          displayName: (_) => 'Value (String)',
          styleBuilder: _dataPort(Colors.cyan),
        ),
        FlDataOutputPortPrototype<double>(
          idName: 'numericValue',
          displayName: (_) => 'Value (Num)',
          styleBuilder: _dataPort(Colors.orange),
        ),
      ],
      fields: [
        FlFieldPrototype(
          idName: 'topicPath',
          displayName: (_) => 'Topic path',
          dataType: String,
          defaultData: '',
          visualizerBuilder: (data) => Text(
            (data as String).isEmpty ? '(tap to set)' : data,
            style: TextStyle(
              color: (data as String).isEmpty ? Colors.white38 : Colors.cyanAccent,
              fontFamily: 'monospace',
              fontSize: 11,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          editorBuilder: (ctx, close, data, set) => ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 240),
            child: TextFormField(
              initialValue: data as String,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'MQTT topic path',
                isDense: true,
              ),
              onChanged: (v) => set(v, eventType: FlFieldEventType.submit),
              onFieldSubmitted: (v) {
                set(v, eventType: FlFieldEventType.submit);
                close();
              },
            ),
          ),
        ),
        FlFieldPrototype(
          idName: 'currentValue',
          displayName: (_) => 'Live value',
          dataType: String,
          defaultData: '—',
          visualizerBuilder: (data) => Text(
            data as String,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
            overflow: TextOverflow.ellipsis,
          ),
          onVisualizerTap: (_, __) {}, // read-only display
        ),
      ],
      onExecute: (ports, fields, state, forward, put) async {
        final topic = (fields['topicPath'] ?? '') as String;
        final value = MqttValueRegistry.get(topic);
        final numeric = double.tryParse(value.trim());
        put({('value', value)});
        if (numeric != null) put({('numericValue', numeric)});
        forward({'changed'});
      },
    ),
  );

  // ── MQTT: Publish ──────────────────────────────────────────────────────
  controller.registerNodePrototype(
    FlNodePrototype(
      idName: 'mqtt.publish',
      displayName: (_) => 'MQTT Publish',
      description: (_) => 'Publishes a payload to an MQTT topic.',
      headerStyleBuilder: _header(const Color(0xFF1B5E20)),
      ports: [
        FlControlInputPortPrototype(
          idName: 'exec',
          displayName: (_) => 'Exec',
          styleBuilder: _controlPort,
        ),
        FlDataInputPortPrototype<String>(
          idName: 'topic',
          displayName: (_) => 'Topic',
          styleBuilder: _dataPort(Colors.cyan),
        ),
        FlDataInputPortPrototype<String>(
          idName: 'payload',
          displayName: (_) => 'Payload',
          styleBuilder: _dataPort(Colors.greenAccent),
        ),
        FlControlOutputPortPrototype(
          idName: 'completed',
          displayName: (_) => 'Completed',
          styleBuilder: _controlPort,
        ),
      ],
      fields: [
        FlFieldPrototype(
          idName: 'defaultTopic',
          displayName: (_) => 'Default topic',
          dataType: String,
          defaultData: '',
          visualizerBuilder: (data) => Text(
            (data as String).isEmpty ? '(tap to set)' : data,
            style: TextStyle(
              color: (data as String).isEmpty ? Colors.white38 : Colors.cyanAccent,
              fontFamily: 'monospace',
              fontSize: 11,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          editorBuilder: (ctx, close, data, set) => ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 240),
            child: TextFormField(
              initialValue: data as String,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Topic (fallback)', isDense: true),
              onChanged: (v) => set(v, eventType: FlFieldEventType.submit),
              onFieldSubmitted: (v) {
                set(v, eventType: FlFieldEventType.submit);
                close();
              },
            ),
          ),
        ),
        FlFieldPrototype(
          idName: 'retain',
          displayName: (_) => 'Retain',
          dataType: bool,
          defaultData: false,
          visualizerBuilder: (data) => Icon(
            (data as bool) ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
            color: Colors.white70,
            size: 16,
          ),
          onVisualizerTap: (data, setData) => setData(!(data as bool)),
        ),
      ],
      onExecute: (ports, fields, state, forward, put) async {
        final topic = ((ports['topic'] ?? fields['defaultTopic'] ?? '') as String);
        final payload = (ports['payload'] ?? '').toString();
        final retain = (fields['retain'] ?? false) as bool;
        if (topic.isNotEmpty) {
          await MqttValueRegistry.publish(topic, payload, retain: retain);
        }
        forward({'completed'});
      },
    ),
  );

  // ── Exec: Python ───────────────────────────────────────────────────────
  controller.registerNodePrototype(
    FlNodePrototype(
      idName: 'exec.python',
      displayName: (_) => 'Python Script',
      description: (_) => r'Runs a Python3 script. The input value is available as $MQTT_VALUE.',
      headerStyleBuilder: _header(const Color(0xFF4A148C)),
      ports: [
        FlControlInputPortPrototype(
          idName: 'exec',
          displayName: (_) => 'Exec',
          styleBuilder: _controlPort,
        ),
        FlDataInputPortPrototype<String>(
          idName: 'input',
          displayName: (_) => 'Input',
          styleBuilder: _dataPort(Colors.cyan),
        ),
        FlControlOutputPortPrototype(
          idName: 'completed',
          displayName: (_) => 'Completed',
          styleBuilder: _controlPort,
        ),
        FlControlOutputPortPrototype(
          idName: 'error',
          displayName: (_) => 'Error',
          styleBuilder: _errorPort,
        ),
        FlDataOutputPortPrototype<String>(
          idName: 'stdout',
          displayName: (_) => 'Stdout',
          styleBuilder: _dataPort(Colors.greenAccent),
        ),
      ],
      fields: [
        FlFieldPrototype(
          idName: 'script',
          displayName: (_) => 'Script',
          dataType: String,
          defaultData: 'import os\nprint(os.environ.get("MQTT_VALUE", ""))',
          visualizerBuilder: (data) {
            final lines = (data as String).split('\n').length;
            return Text(
              '$lines line${lines == 1 ? '' : 's'}',
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            );
          },
          editorBuilder: (ctx, close, data, set) => ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340, maxHeight: 220),
            child: TextFormField(
              initialValue: data as String,
              maxLines: null,
              expands: true,
              autofocus: true,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              decoration: const InputDecoration(
                labelText: 'Python3 (use MQTT_VALUE env)',
                isDense: true,
                alignLabelWithHint: true,
              ),
              // Multi-line fields never fire onFieldSubmitted (Enter inserts a
              // newline instead), so onChanged is the only reliable save path.
              onChanged: (v) => set(v, eventType: FlFieldEventType.submit),
              onFieldSubmitted: (v) {
                set(v, eventType: FlFieldEventType.submit);
                close();
              },
            ),
          ),
        ),
      ],
      onExecute: (ports, fields, state, forward, put) async {
        final input = (ports['input'] ?? '').toString();
        final script = (fields['script'] ?? '').toString();
        try {
          final result = await Process.run(
            'python3',
            ['-c', script],
            environment: {...Platform.environment, 'MQTT_VALUE': input},
          );
          put({('stdout', result.stdout.toString().trim())});
          result.exitCode == 0 ? forward({'completed'}) : forward({'error'});
        } catch (_) {
          forward({'error'});
        }
      },
    ),
  );

  // ── Exec: Bash ─────────────────────────────────────────────────────────
  controller.registerNodePrototype(
    FlNodePrototype(
      idName: 'exec.bash',
      displayName: (_) => 'Bash Script',
      description: (_) => 'Runs a bash script. \$MQTT_VALUE holds the input.',
      headerStyleBuilder: _header(const Color(0xFF37474F)),
      ports: [
        FlControlInputPortPrototype(
          idName: 'exec',
          displayName: (_) => 'Exec',
          styleBuilder: _controlPort,
        ),
        FlDataInputPortPrototype<String>(
          idName: 'input',
          displayName: (_) => 'Input',
          styleBuilder: _dataPort(Colors.cyan),
        ),
        FlControlOutputPortPrototype(
          idName: 'completed',
          displayName: (_) => 'Completed',
          styleBuilder: _controlPort,
        ),
        FlControlOutputPortPrototype(
          idName: 'error',
          displayName: (_) => 'Error',
          styleBuilder: _errorPort,
        ),
        FlDataOutputPortPrototype<String>(
          idName: 'stdout',
          displayName: (_) => 'Stdout',
          styleBuilder: _dataPort(Colors.greenAccent),
        ),
      ],
      fields: [
        FlFieldPrototype(
          idName: 'script',
          displayName: (_) => 'Script',
          dataType: String,
          defaultData: 'echo "\$MQTT_VALUE"',
          visualizerBuilder: (data) {
            final lines = (data as String).split('\n').length;
            return Text(
              '$lines line${lines == 1 ? '' : 's'}',
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            );
          },
          editorBuilder: (ctx, close, data, set) => ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340, maxHeight: 220),
            child: TextFormField(
              initialValue: data as String,
              maxLines: null,
              expands: true,
              autofocus: true,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              decoration: const InputDecoration(
                labelText: 'Bash script (use \$MQTT_VALUE)',
                isDense: true,
                alignLabelWithHint: true,
              ),
              onChanged: (v) => set(v, eventType: FlFieldEventType.submit),
              onFieldSubmitted: (v) {
                set(v, eventType: FlFieldEventType.submit);
                close();
              },
            ),
          ),
        ),
      ],
      onExecute: (ports, fields, state, forward, put) async {
        final input = (ports['input'] ?? '').toString();
        final script = (fields['script'] ?? '').toString();
        try {
          final result = await Process.run(
            'bash',
            ['-c', script],
            environment: {...Platform.environment, 'MQTT_VALUE': input},
          );
          put({('stdout', result.stdout.toString().trim())});
          result.exitCode == 0 ? forward({'completed'}) : forward({'error'});
        } catch (_) {
          forward({'error'});
        }
      },
    ),
  );

  // ── Flow: If / Else ────────────────────────────────────────────────────
  controller.registerNodePrototype(
    FlNodePrototype(
      idName: 'flow.if',
      displayName: (_) => 'If / Else',
      description: (_) => 'Branches execution based on a boolean condition.',
      headerStyleBuilder: _header(const Color(0xFFE65100)),
      ports: [
        FlControlInputPortPrototype(
          idName: 'exec',
          displayName: (_) => 'Exec',
          styleBuilder: _controlPort,
        ),
        FlDataInputPortPrototype<bool>(
          idName: 'condition',
          displayName: (_) => 'Condition',
          styleBuilder: _dataPort(Colors.yellowAccent),
        ),
        FlControlOutputPortPrototype(
          idName: 'trueBranch',
          displayName: (_) => 'True',
          styleBuilder: _controlPort,
        ),
        FlControlOutputPortPrototype(
          idName: 'falseBranch',
          displayName: (_) => 'False',
          styleBuilder: _errorPort,
        ),
      ],
      onExecute: (ports, fields, state, forward, put) async {
        final condition = (ports['condition'] ?? false) as bool;
        condition ? forward({'trueBranch'}) : forward({'falseBranch'});
      },
    ),
  );

  // ── Logic: Compare ─────────────────────────────────────────────────────
  controller.registerNodePrototype(
    FlNodePrototype(
      idName: 'logic.compare',
      displayName: (_) => 'Compare',
      description: (_) => 'Compares two values with ==, !=, >, <, >=, <=.',
      headerStyleBuilder: _header(const Color(0xFF880E4F)),
      ports: [
        FlControlInputPortPrototype(
          idName: 'exec',
          displayName: (_) => 'Exec',
          styleBuilder: _controlPort,
        ),
        FlDataInputPortPrototype<dynamic>(
          idName: 'a',
          displayName: (_) => 'A',
          styleBuilder: _dataPort(Colors.cyan),
        ),
        FlDataInputPortPrototype<dynamic>(
          idName: 'b',
          displayName: (_) => 'B',
          styleBuilder: _dataPort(Colors.cyan),
        ),
        FlControlOutputPortPrototype(
          idName: 'completed',
          displayName: (_) => 'Completed',
          styleBuilder: _controlPort,
        ),
        FlDataOutputPortPrototype<bool>(
          idName: 'result',
          displayName: (_) => 'Result',
          styleBuilder: _dataPort(Colors.yellowAccent),
        ),
      ],
      fields: [
        FlFieldPrototype(
          idName: 'operator',
          displayName: (_) => 'Operator',
          dataType: String,
          defaultData: '==',
          visualizerBuilder: (data) => Text(
            data as String,
            style: const TextStyle(
              color: Colors.yellowAccent,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          editorBuilder: (ctx, close, data, set) => SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: '==', label: Text('==')),
              ButtonSegment(value: '!=', label: Text('!=')),
              ButtonSegment(value: '>', label: Text('>')),
              ButtonSegment(value: '<', label: Text('<')),
              ButtonSegment(value: '>=', label: Text('>=')),
              ButtonSegment(value: '<=', label: Text('<=')),
            ],
            selected: {data as String},
            onSelectionChanged: (s) {
              set(s.first, eventType: FlFieldEventType.submit);
              close();
            },
          ),
        ),
      ],
      onExecute: (ports, fields, state, forward, put) async {
        final a = ports['a'];
        final b = ports['b'];
        final op = (fields['operator'] ?? '==') as String;
        bool result;
        try {
          final an = double.tryParse(a.toString());
          final bn = double.tryParse(b.toString());
          if (an != null && bn != null) {
            result = switch (op) {
              '==' => an == bn,
              '!=' => an != bn,
              '>' => an > bn,
              '<' => an < bn,
              '>=' => an >= bn,
              '<=' => an <= bn,
              _ => false,
            };
          } else {
            result = switch (op) {
              '==' => a.toString() == b.toString(),
              '!=' => a.toString() != b.toString(),
              _ => false,
            };
          }
        } catch (_) {
          result = false;
        }
        put({('result', result)});
        forward({'completed'});
      },
    ),
  );

  // ── Logic: Threshold ───────────────────────────────────────────────────
  controller.registerNodePrototype(
    FlNodePrototype(
      idName: 'logic.threshold',
      displayName: (_) => 'Threshold',
      description: (_) => 'Triggers above/below branches from a numeric threshold.',
      headerStyleBuilder: _header(const Color(0xFF4E342E)),
      ports: [
        FlControlInputPortPrototype(
          idName: 'exec',
          displayName: (_) => 'Exec',
          styleBuilder: _controlPort,
        ),
        FlDataInputPortPrototype<double>(
          idName: 'value',
          displayName: (_) => 'Value',
          styleBuilder: _dataPort(Colors.orange),
        ),
        FlControlOutputPortPrototype(
          idName: 'above',
          displayName: (_) => 'Above',
          styleBuilder: _controlPort,
        ),
        FlControlOutputPortPrototype(
          idName: 'below',
          displayName: (_) => 'Below',
          styleBuilder: _errorPort,
        ),
        FlDataOutputPortPrototype<bool>(
          idName: 'isAbove',
          displayName: (_) => 'Is Above',
          styleBuilder: _dataPort(Colors.yellowAccent),
        ),
      ],
      fields: [
        FlFieldPrototype(
          idName: 'threshold',
          displayName: (_) => 'Threshold',
          dataType: double,
          defaultData: 0.0,
          visualizerBuilder: (data) => Text(
            (data as double).toStringAsFixed(2),
            style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
          ),
          editorBuilder: (ctx, close, data, set) => ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 130),
            child: TextFormField(
              initialValue: (data as double).toString(),
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Threshold', isDense: true),
              onChanged: (v) {
                final parsed = double.tryParse(v);
                if (parsed != null) set(parsed, eventType: FlFieldEventType.submit);
              },
              onFieldSubmitted: (v) {
                set(double.tryParse(v) ?? 0.0, eventType: FlFieldEventType.submit);
                close();
              },
            ),
          ),
        ),
      ],
      onExecute: (ports, fields, state, forward, put) async {
        final value = (ports['value'] ?? 0.0) as double;
        final threshold = (fields['threshold'] ?? 0.0) as double;
        final isAbove = value >= threshold;
        put({('isAbove', isAbove)});
        isAbove ? forward({'above'}) : forward({'below'});
      },
    ),
  );

  // ── Math: Operator ─────────────────────────────────────────────────────
  controller.registerNodePrototype(
    FlNodePrototype(
      idName: 'math.operator',
      displayName: (_) => 'Math',
      description: (_) => 'Arithmetic on two numeric values.',
      headerStyleBuilder: _header(const Color(0xFF1A237E)),
      ports: [
        FlControlInputPortPrototype(
          idName: 'exec',
          displayName: (_) => 'Exec',
          styleBuilder: _controlPort,
        ),
        FlDataInputPortPrototype<double>(
          idName: 'a',
          displayName: (_) => 'A',
          styleBuilder: _dataPort(Colors.orange),
        ),
        FlDataInputPortPrototype<double>(
          idName: 'b',
          displayName: (_) => 'B',
          styleBuilder: _dataPort(Colors.orange),
        ),
        FlControlOutputPortPrototype(
          idName: 'completed',
          displayName: (_) => 'Completed',
          styleBuilder: _controlPort,
        ),
        FlDataOutputPortPrototype<double>(
          idName: 'result',
          displayName: (_) => 'Result',
          styleBuilder: _dataPort(Colors.orange),
        ),
      ],
      fields: [
        FlFieldPrototype(
          idName: 'op',
          displayName: (_) => 'Op',
          dataType: String,
          defaultData: '+',
          visualizerBuilder: (data) => Text(
            data as String,
            style: const TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          editorBuilder: (ctx, close, data, set) => SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: '+', label: Text('+')),
              ButtonSegment(value: '-', label: Text('-')),
              ButtonSegment(value: '*', label: Text('×')),
              ButtonSegment(value: '/', label: Text('÷')),
            ],
            selected: {data as String},
            onSelectionChanged: (s) {
              set(s.first, eventType: FlFieldEventType.submit);
              close();
            },
          ),
        ),
      ],
      onExecute: (ports, fields, state, forward, put) async {
        final a = (ports['a'] ?? 0.0) as double;
        final b = (ports['b'] ?? 0.0) as double;
        final op = (fields['op'] ?? '+') as String;
        final result = switch (op) {
          '+' => a + b,
          '-' => a - b,
          '*' => a * b,
          '/' => b == 0 ? 0.0 : a / b,
          _ => 0.0,
        };
        put({('result', result)});
        forward({'completed'});
      },
    ),
  );

  // ── Data: String Format ────────────────────────────────────────────────
  controller.registerNodePrototype(
    FlNodePrototype(
      idName: 'data.format',
      displayName: (_) => 'String Format',
      description: (_) => 'Formats a value using a template. Use {value} as placeholder.',
      headerStyleBuilder: _header(const Color(0xFF006064)),
      ports: [
        FlControlInputPortPrototype(
          idName: 'exec',
          displayName: (_) => 'Exec',
          styleBuilder: _controlPort,
        ),
        FlDataInputPortPrototype<dynamic>(
          idName: 'value',
          displayName: (_) => 'Value',
          styleBuilder: _dataPort(Colors.cyan),
        ),
        FlControlOutputPortPrototype(
          idName: 'completed',
          displayName: (_) => 'Completed',
          styleBuilder: _controlPort,
        ),
        FlDataOutputPortPrototype<String>(
          idName: 'result',
          displayName: (_) => 'Result',
          styleBuilder: _dataPort(Colors.tealAccent),
        ),
      ],
      fields: [
        FlFieldPrototype(
          idName: 'template',
          displayName: (_) => 'Template',
          dataType: String,
          defaultData: 'Value: {value}',
          visualizerBuilder: (data) => Text(
            data as String,
            style: const TextStyle(
              color: Colors.tealAccent,
              fontFamily: 'monospace',
              fontSize: 11,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          editorBuilder: (ctx, close, data, set) => ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: TextFormField(
              initialValue: data as String,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Template — use {value}',
                isDense: true,
              ),
              onChanged: (v) => set(v, eventType: FlFieldEventType.submit),
              onFieldSubmitted: (v) {
                set(v, eventType: FlFieldEventType.submit);
                close();
              },
            ),
          ),
        ),
      ],
      onExecute: (ports, fields, state, forward, put) async {
        final value = ports['value']?.toString() ?? '';
        final template = (fields['template'] ?? '{value}') as String;
        put({('result', template.replaceAll('{value}', value))});
        forward({'completed'});
      },
    ),
  );

  // ── Data: Parse Number ─────────────────────────────────────────────────
  controller.registerNodePrototype(
    FlNodePrototype(
      idName: 'data.parseNum',
      displayName: (_) => 'Parse Number',
      description: (_) => 'Parses a string into a double.',
      headerStyleBuilder: _header(const Color(0xFF263238)),
      ports: [
        FlControlInputPortPrototype(
          idName: 'exec',
          displayName: (_) => 'Exec',
          styleBuilder: _controlPort,
        ),
        FlDataInputPortPrototype<String>(
          idName: 'value',
          displayName: (_) => 'String',
          styleBuilder: _dataPort(Colors.cyan),
        ),
        FlControlOutputPortPrototype(
          idName: 'completed',
          displayName: (_) => 'Completed',
          styleBuilder: _controlPort,
        ),
        FlControlOutputPortPrototype(
          idName: 'error',
          displayName: (_) => 'Parse Error',
          styleBuilder: _errorPort,
        ),
        FlDataOutputPortPrototype<double>(
          idName: 'number',
          displayName: (_) => 'Number',
          styleBuilder: _dataPort(Colors.orange),
        ),
      ],
      onExecute: (ports, fields, state, forward, put) async {
        final raw = (ports['value'] ?? '').toString().trim();
        final n = double.tryParse(raw);
        if (n != null) {
          put({('number', n)});
          forward({'completed'});
        } else {
          forward({'error'});
        }
      },
    ),
  );

  // ── IO: Log ────────────────────────────────────────────────────────────
  controller.registerNodePrototype(
    FlNodePrototype(
      idName: 'io.log',
      displayName: (_) => 'Log',
      description: (_) => 'Prints a value to the Flutter debug console.',
      headerStyleBuilder: _header(const Color(0xFF212121)),
      ports: [
        FlControlInputPortPrototype(
          idName: 'exec',
          displayName: (_) => 'Exec',
          styleBuilder: _controlPort,
        ),
        FlDataInputPortPrototype<dynamic>(
          idName: 'value',
          displayName: (_) => 'Value',
          styleBuilder: _dataPort(Colors.cyan),
        ),
        FlControlOutputPortPrototype(
          idName: 'completed',
          displayName: (_) => 'Completed',
          styleBuilder: _controlPort,
        ),
      ],
      fields: [
        FlFieldPrototype(
          idName: 'prefix',
          displayName: (_) => 'Prefix',
          dataType: String,
          defaultData: '[NODE]',
          visualizerBuilder: (data) => Text(
            data as String,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
          editorBuilder: (ctx, close, data, set) => ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 180),
            child: TextFormField(
              initialValue: data as String,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Prefix', isDense: true),
              onChanged: (v) => set(v, eventType: FlFieldEventType.submit),
              onFieldSubmitted: (v) {
                set(v, eventType: FlFieldEventType.submit);
                close();
              },
            ),
          ),
        ),
      ],
      onExecute: (ports, fields, state, forward, put) async {
        final prefix = (fields['prefix'] ?? '') as String;
        debugPrint('$prefix ${ports['value']}');
        forward({'completed'});
      },
    ),
  );

  // ── Logic: AND ─────────────────────────────────────────────────────────
  controller.registerNodePrototype(
    FlNodePrototype(
      idName: 'logic.and',
      displayName: (_) => 'AND',
      description: (_) => 'Logical AND of two boolean inputs.',
      headerStyleBuilder: _header(const Color(0xFF880E4F)),
      ports: [
        FlControlInputPortPrototype(
          idName: 'exec',
          displayName: (_) => 'Exec',
          styleBuilder: _controlPort,
        ),
        FlDataInputPortPrototype<dynamic>(
          idName: 'a',
          displayName: (_) => 'A',
          styleBuilder: _dataPort(Colors.yellowAccent),
        ),
        FlDataInputPortPrototype<dynamic>(
          idName: 'b',
          displayName: (_) => 'B',
          styleBuilder: _dataPort(Colors.yellowAccent),
        ),
        FlControlOutputPortPrototype(
          idName: 'completed',
          displayName: (_) => 'Completed',
          styleBuilder: _controlPort,
        ),
        FlDataOutputPortPrototype<bool>(
          idName: 'result',
          displayName: (_) => 'Result',
          styleBuilder: _dataPort(Colors.yellowAccent),
        ),
      ],
      onExecute: (ports, fields, state, forward, put) async {
        final result = _asBool(ports['a']) && _asBool(ports['b']);
        put({('result', result)});
        forward({'completed'});
      },
    ),
  );

  // ── Logic: OR ──────────────────────────────────────────────────────────
  controller.registerNodePrototype(
    FlNodePrototype(
      idName: 'logic.or',
      displayName: (_) => 'OR',
      description: (_) => 'Logical OR of two boolean inputs.',
      headerStyleBuilder: _header(const Color(0xFF880E4F)),
      ports: [
        FlControlInputPortPrototype(
          idName: 'exec',
          displayName: (_) => 'Exec',
          styleBuilder: _controlPort,
        ),
        FlDataInputPortPrototype<dynamic>(
          idName: 'a',
          displayName: (_) => 'A',
          styleBuilder: _dataPort(Colors.yellowAccent),
        ),
        FlDataInputPortPrototype<dynamic>(
          idName: 'b',
          displayName: (_) => 'B',
          styleBuilder: _dataPort(Colors.yellowAccent),
        ),
        FlControlOutputPortPrototype(
          idName: 'completed',
          displayName: (_) => 'Completed',
          styleBuilder: _controlPort,
        ),
        FlDataOutputPortPrototype<bool>(
          idName: 'result',
          displayName: (_) => 'Result',
          styleBuilder: _dataPort(Colors.yellowAccent),
        ),
      ],
      onExecute: (ports, fields, state, forward, put) async {
        final result = _asBool(ports['a']) || _asBool(ports['b']);
        put({('result', result)});
        forward({'completed'});
      },
    ),
  );

  // ── Logic: NOT ─────────────────────────────────────────────────────────
  controller.registerNodePrototype(
    FlNodePrototype(
      idName: 'logic.not',
      displayName: (_) => 'NOT',
      description: (_) => 'Inverts a boolean input.',
      headerStyleBuilder: _header(const Color(0xFF880E4F)),
      ports: [
        FlControlInputPortPrototype(
          idName: 'exec',
          displayName: (_) => 'Exec',
          styleBuilder: _controlPort,
        ),
        FlDataInputPortPrototype<dynamic>(
          idName: 'value',
          displayName: (_) => 'Value',
          styleBuilder: _dataPort(Colors.yellowAccent),
        ),
        FlControlOutputPortPrototype(
          idName: 'completed',
          displayName: (_) => 'Completed',
          styleBuilder: _controlPort,
        ),
        FlDataOutputPortPrototype<bool>(
          idName: 'result',
          displayName: (_) => 'Result',
          styleBuilder: _dataPort(Colors.yellowAccent),
        ),
      ],
      onExecute: (ports, fields, state, forward, put) async {
        put({('result', !_asBool(ports['value']))});
        forward({'completed'});
      },
    ),
  );

  // ── Data: Constant ─────────────────────────────────────────────────────
  controller.registerNodePrototype(
    FlNodePrototype(
      idName: 'data.constant',
      displayName: (_) => 'Constant',
      description: (_) => 'Emits a fixed, user-edited string value.',
      headerStyleBuilder: _header(const Color(0xFF006064)),
      ports: [
        FlControlOutputPortPrototype(
          idName: 'changed',
          displayName: (_) => 'Changed',
          styleBuilder: _controlPort,
        ),
        FlDataOutputPortPrototype<String>(
          idName: 'value',
          displayName: (_) => 'Value',
          styleBuilder: _dataPort(Colors.tealAccent),
        ),
      ],
      fields: [
        FlFieldPrototype(
          idName: 'value',
          displayName: (_) => 'Value',
          dataType: String,
          defaultData: '',
          visualizerBuilder: (data) => Text(
            (data as String).isEmpty ? '(tap to set)' : data,
            style: TextStyle(
              color: (data as String).isEmpty ? Colors.white38 : Colors.tealAccent,
              fontFamily: 'monospace',
              fontSize: 11,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          editorBuilder: (ctx, close, data, set) => ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 240),
            child: TextFormField(
              initialValue: data as String,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Constant value', isDense: true),
              onChanged: (v) => set(v, eventType: FlFieldEventType.submit),
              onFieldSubmitted: (v) {
                set(v, eventType: FlFieldEventType.submit);
                close();
              },
            ),
          ),
        ),
      ],
      onExecute: (ports, fields, state, forward, put) async {
        put({('value', (fields['value'] ?? '') as String)});
        forward({'changed'});
      },
    ),
  );

  // ── Data: Concat ───────────────────────────────────────────────────────
  controller.registerNodePrototype(
    FlNodePrototype(
      idName: 'data.concat',
      displayName: (_) => 'Concat',
      description: (_) => 'Joins two values into one string.',
      headerStyleBuilder: _header(const Color(0xFF006064)),
      ports: [
        FlControlInputPortPrototype(
          idName: 'exec',
          displayName: (_) => 'Exec',
          styleBuilder: _controlPort,
        ),
        FlDataInputPortPrototype<dynamic>(
          idName: 'a',
          displayName: (_) => 'A',
          styleBuilder: _dataPort(Colors.cyan),
        ),
        FlDataInputPortPrototype<dynamic>(
          idName: 'b',
          displayName: (_) => 'B',
          styleBuilder: _dataPort(Colors.cyan),
        ),
        FlControlOutputPortPrototype(
          idName: 'completed',
          displayName: (_) => 'Completed',
          styleBuilder: _controlPort,
        ),
        FlDataOutputPortPrototype<String>(
          idName: 'result',
          displayName: (_) => 'Result',
          styleBuilder: _dataPort(Colors.tealAccent),
        ),
      ],
      fields: [
        FlFieldPrototype(
          idName: 'separator',
          displayName: (_) => 'Separator',
          dataType: String,
          defaultData: '',
          visualizerBuilder: (data) => Text(
            (data as String).isEmpty ? '(none)' : data,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
          editorBuilder: (ctx, close, data, set) => ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 140),
            child: TextFormField(
              initialValue: data as String,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Separator', isDense: true),
              onChanged: (v) => set(v, eventType: FlFieldEventType.submit),
              onFieldSubmitted: (v) {
                set(v, eventType: FlFieldEventType.submit);
                close();
              },
            ),
          ),
        ),
      ],
      onExecute: (ports, fields, state, forward, put) async {
        final a = ports['a']?.toString() ?? '';
        final b = ports['b']?.toString() ?? '';
        final sep = (fields['separator'] ?? '') as String;
        put({('result', '$a$sep$b')});
        forward({'completed'});
      },
    ),
  );

  // ── Flow: Delay ────────────────────────────────────────────────────────
  controller.registerNodePrototype(
    FlNodePrototype(
      idName: 'flow.delay',
      displayName: (_) => 'Delay',
      description: (_) => 'Waits before forwarding execution.',
      headerStyleBuilder: _header(const Color(0xFFE65100)),
      ports: [
        FlControlInputPortPrototype(
          idName: 'exec',
          displayName: (_) => 'Exec',
          styleBuilder: _controlPort,
        ),
        FlControlOutputPortPrototype(
          idName: 'completed',
          displayName: (_) => 'Completed',
          styleBuilder: _controlPort,
        ),
      ],
      fields: [
        FlFieldPrototype(
          idName: 'delayMs',
          displayName: (_) => 'Delay (ms)',
          dataType: double,
          defaultData: 500.0,
          visualizerBuilder: (data) => Text(
            '${(data as double).toInt()} ms',
            style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
          ),
          editorBuilder: (ctx, close, data, set) => ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 130),
            child: TextFormField(
              initialValue: (data as double).toString(),
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Delay (ms)', isDense: true),
              onChanged: (v) {
                final parsed = double.tryParse(v);
                if (parsed != null) set(parsed, eventType: FlFieldEventType.submit);
              },
              onFieldSubmitted: (v) {
                set(double.tryParse(v) ?? 0.0, eventType: FlFieldEventType.submit);
                close();
              },
            ),
          ),
        ),
      ],
      onExecute: (ports, fields, state, forward, put) async {
        final delayMs = (fields['delayMs'] ?? 0.0) as double;
        if (delayMs > 0) {
          await Future.delayed(Duration(milliseconds: delayMs.toInt()));
        }
        forward({'completed'});
      },
    ),
  );

  // ── Time: Timestamp ────────────────────────────────────────────────────
  controller.registerNodePrototype(
    FlNodePrototype(
      idName: 'time.now',
      displayName: (_) => 'Timestamp',
      description: (_) => 'Emits the current time as an ISO-8601 string and epoch millis.',
      headerStyleBuilder: _header(const Color(0xFF37474F)),
      ports: [
        FlControlInputPortPrototype(
          idName: 'exec',
          displayName: (_) => 'Exec',
          styleBuilder: _controlPort,
        ),
        FlControlOutputPortPrototype(
          idName: 'completed',
          displayName: (_) => 'Completed',
          styleBuilder: _controlPort,
        ),
        FlDataOutputPortPrototype<String>(
          idName: 'iso',
          displayName: (_) => 'ISO-8601',
          styleBuilder: _dataPort(Colors.cyan),
        ),
        FlDataOutputPortPrototype<double>(
          idName: 'epochMs',
          displayName: (_) => 'Epoch (ms)',
          styleBuilder: _dataPort(Colors.orange),
        ),
      ],
      onExecute: (ports, fields, state, forward, put) async {
        final now = DateTime.now();
        put({('iso', now.toIso8601String())});
        put({('epochMs', now.millisecondsSinceEpoch.toDouble())});
        forward({'completed'});
      },
    ),
  );
}

bool _asBool(dynamic v) {
  if (v is bool) return v;
  if (v is num) return v != 0;
  if (v is String) return v.toLowerCase() == 'true' || v == '1';
  return false;
}

// ---------------------------------------------------------------------------
// Style helpers
// ---------------------------------------------------------------------------

FlNodeHeaderStyle Function(FlNodeState) _header(Color color) => (state) =>
    flDefaultNodeHeaderStyleBuilder(state).copyWith(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, Colors.transparent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
    );

FlPortStyle _controlPort(FlPortState _) =>
    const FlPortStyle.basic().copyWith(color: Colors.white70);

FlPortStyle Function(FlPortState) _dataPort(Color color) =>
    (_) => const FlPortStyle.basic().copyWith(color: color, shape: FlPortShape.triangle);

FlPortStyle _errorPort(FlPortState _) =>
    const FlPortStyle.basic().copyWith(color: Colors.redAccent);
