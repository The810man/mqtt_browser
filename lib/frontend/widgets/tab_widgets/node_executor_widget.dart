import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fl_nodes/fl_nodes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_browser/frontend/tree_node.dart';
import 'package:mqtt_browser/frontend/widgets/tab_widgets/node_executor_nodes.dart';
import 'package:mqtt_browser/providers/providers.dart';
import 'package:path_provider/path_provider.dart';

class NodeExecutorWidget extends ConsumerStatefulWidget {
  final TreeNode rootNode;

  const NodeExecutorWidget({super.key, required this.rootNode});

  @override
  ConsumerState<NodeExecutorWidget> createState() => _NodeExecutorWidgetState();
}

class _NodeExecutorWidgetState extends ConsumerState<NodeExecutorWidget>
    with TickerProviderStateMixin {
  late final FlNodeEditorController _ctrl;

  // topicPath → node id (so we can update live values)
  final Map<String, String> _topicNodeIds = {};

  bool _autoRun = false;
  bool _isRunning = false;
  Timer? _debounceTimer;

  // ── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    _ctrl = FlNodeEditorController(
      projectSaver: _saveProject,
      projectLoader: _loadProject,
      projectCreator: (_) async => true,
    );

    _ctrl.setTickerProvider(this);

    registerExecutorNodes(_ctrl);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // Bridge: MQTT publish from node execution
      MqttValueRegistry.publishCallback = (topic, payload, {retain = false}) async {
        ref.read(mqttClientProvider.notifier).publish(topic, payload, retain: retain);
      };

      _tryLoadOrInit();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  // ── Persistence ──────────────────────────────────────────────────────────

  Future<File> _graphFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final safe = widget.rootNode.label.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
    final folder = Directory('${dir.path}/mqtt_browser');
    await folder.create(recursive: true);
    return File('${folder.path}/executor_$safe.json');
  }

  Future<bool> _saveProject(Map<String, dynamic> data) async {
    try {
      final file = await _graphFile();
      await file.writeAsString(jsonEncode(data));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> _loadProject(bool isSaved) async {
    try {
      final file = await _graphFile();
      if (!await file.exists()) return null;
      return jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> _tryLoadOrInit() async {
    final file = await _graphFile();
    if (await file.exists()) {
      if (mounted) _ctrl.project.load(context: context);
    } else {
      _buildInitialTopicNodes();
    }
    // Guarantee all nodes are in the spatial hash grid after loading.
    // The selection event adds every node id to _childrenNotLaidOut and
    // calls markNeedsLayout(), which forces performLayout() to run and
    // update the grid even in cases where the initial layout passed an
    // empty _childrenNotLaidOut (e.g. secondary/detached windows).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final ids = Set<String>.from(_ctrl.nodes.keys);
      if (ids.isNotEmpty) {
        _ctrl.selectNodesById(ids);
        _ctrl.selectNodesById(const {});
      }
    });
  }

  // ── Initial graph ────────────────────────────────────────────────────────

  String _fullMqttPath(TreeNode node) {
    final segments = <String>[];
    TreeNode? cur = node;
    while (cur != null && cur.parent != null) {
      segments.add(cur.label);
      cur = cur.parent;
    }
    return segments.reversed.join('/');
  }

  void _buildInitialTopicNodes() {
    final valueNodes = <TreeNode>[];
    _collectValueNodes(widget.rootNode, valueNodes);
    if (valueNodes.isEmpty) valueNodes.add(widget.rootNode);

    double y = 60;
    for (final node in valueNodes) {
      final path = _fullMqttPath(node);
      final label = path.isEmpty ? node.label : path;
      final model = _ctrl.addNode('mqtt.topic', offset: Offset(60, y));
      _ctrl.setFieldData(model.id, 'topicPath',
          eventType: FlFieldEventType.submit, data: label);
      if (node.message != null) {
        _ctrl.setFieldData(model.id, 'currentValue',
            eventType: FlFieldEventType.submit, data: node.message!);
        MqttValueRegistry.update(label, node.message!);
      }
      _topicNodeIds[label] = model.id;
      y += 220;
    }
  }

  void _collectValueNodes(TreeNode node, List<TreeNode> out) {
    if (node.history.isNotEmpty) out.add(node);
    for (final child in node.children) {
      _collectValueNodes(child, out);
    }
  }

  // ── Live MQTT value sync ─────────────────────────────────────────────────

  void _syncMqttValues() {
    void walk(TreeNode node) {
      if (node.history.isNotEmpty) {
        final path = _fullMqttPath(node);
        final label = path.isEmpty ? node.label : path;
        MqttValueRegistry.update(label, node.message ?? '');
      }
      for (final child in node.children) {
        walk(child);
      }
    }

    walk(widget.rootNode);
  }

  // ── Graph execution ──────────────────────────────────────────────────────

  Future<void> _runGraph() async {
    if (_isRunning) return;
    setState(() => _isRunning = true);
    try {
      await _ctrl.runner.executeGraph(context: context);
    } finally {
      if (mounted) setState(() => _isRunning = false);
    }
  }

  void _scheduleAutoRun() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 600), () {
      if (mounted && _autoRun) _runGraph();
    });
  }

  // ── Add node ─────────────────────────────────────────────────────────────

  Future<void> _showAddNodeMenu() async {
    final categories = <String, List<MapEntry<String, String>>>{
      'MQTT': [
        MapEntry('mqtt.topic', 'MQTT Topic'),
        MapEntry('mqtt.publish', 'MQTT Publish'),
      ],
      'Execute': [
        MapEntry('exec.python', 'Python Script'),
        MapEntry('exec.bash', 'Bash Script'),
      ],
      'Flow': [
        MapEntry('flow.if', 'If / Else'),
        MapEntry('flow.delay', 'Delay'),
      ],
      'Logic': [
        MapEntry('logic.compare', 'Compare'),
        MapEntry('logic.threshold', 'Threshold'),
        MapEntry('logic.and', 'AND'),
        MapEntry('logic.or', 'OR'),
        MapEntry('logic.not', 'NOT'),
      ],
      'Math': [MapEntry('math.operator', 'Math')],
      'Data': [
        MapEntry('data.format', 'String Format'),
        MapEntry('data.parseNum', 'Parse Number'),
        MapEntry('data.constant', 'Constant'),
        MapEntry('data.concat', 'Concat'),
      ],
      'Time': [MapEntry('time.now', 'Timestamp')],
      'IO': [MapEntry('io.log', 'Log')],
    };

    final RenderBox box = context.findRenderObject()! as RenderBox;
    final center = box.size.center(box.localToGlobal(Offset.zero));

    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        center.dx - 100,
        center.dy - 100,
        center.dx + 100,
        center.dy + 100,
      ),
      items: [
        for (final cat in categories.entries) ...[
          PopupMenuItem<String>(
            enabled: false,
            height: 28,
            child: Text(
              cat.key,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white38,
              ),
            ),
          ),
          for (final entry in cat.value)
            PopupMenuItem<String>(
              value: entry.key,
              child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(entry.value),
              ),
            ),
        ],
      ],
    );

    if (selected != null && mounted) {
      // Place new node near the visible center of the canvas
      final offset = -_ctrl.viewportOffset / _ctrl.viewportZoom +
          Offset(box.size.width / 2, box.size.height / 2) / _ctrl.viewportZoom;
      _ctrl.addNode(selected, offset: offset);
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    ref.listen(treeNodesProvider, (_, __) {
      _syncMqttValues();
      if (_autoRun) _scheduleAutoRun();
    });

    return Stack(
      children: [
        FlNodeEditorShortcutsWidget(
          controller: _ctrl,
          child: FlNodeEditorWidget(
            controller: _ctrl,
            expandToParent: true,
            overlay: () => [],
          ),
        ),
        Positioned(
          top: 12,
          left: 12,
          right: 12,
          child: _Toolbar(
            isRunning: _isRunning,
            autoRun: _autoRun,
            snapEnabled: _ctrl.config.enableSnapToGrid,
            onRun: _runGraph,
            onAddNode: _showAddNodeMenu,
            onToggleAutoRun: () => setState(() => _autoRun = !_autoRun),
            onSave: () => _ctrl.project.save(context: context),
            onUndo: () => _ctrl.history.undo(),
            onRedo: () => _ctrl.history.redo(),
            onSnapToggle: () => setState(
              () => _ctrl.enableSnapToGrid(!_ctrl.config.enableSnapToGrid),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Toolbar ──────────────────────────────────────────────────────────────────

class _Toolbar extends StatelessWidget {
  final bool isRunning;
  final bool autoRun;
  final bool snapEnabled;
  final VoidCallback onRun;
  final VoidCallback onAddNode;
  final VoidCallback onToggleAutoRun;
  final VoidCallback onSave;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onSnapToggle;

  const _Toolbar({
    required this.isRunning,
    required this.autoRun,
    required this.snapEnabled,
    required this.onRun,
    required this.onAddNode,
    required this.onToggleAutoRun,
    required this.onSave,
    required this.onUndo,
    required this.onRedo,
    required this.onSnapToggle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        _panel(
          context,
          children: [
            _btn(
              icon: Icons.add_rounded,
              tooltip: 'Add node',
              onTap: onAddNode,
              color: cs.primary,
            ),
            _btn(
              icon: isRunning ? Icons.hourglass_empty_rounded : Icons.play_arrow_rounded,
              tooltip: 'Run graph',
              onTap: onRun,
              color: Colors.greenAccent,
            ),
            _btn(
              icon: autoRun ? Icons.sync_rounded : Icons.sync_disabled_rounded,
              tooltip: autoRun ? 'Auto-run: ON' : 'Auto-run: OFF',
              onTap: onToggleAutoRun,
              color: autoRun ? Colors.cyanAccent : cs.onSurface.withValues(alpha: 0.5),
            ),
          ],
        ),
        const SizedBox(width: 8),
        _panel(
          context,
          children: [
            _btn(icon: Icons.undo_rounded, tooltip: 'Undo', onTap: onUndo),
            _btn(icon: Icons.redo_rounded, tooltip: 'Redo', onTap: onRedo),
            _btn(
              icon: snapEnabled ? Icons.grid_on_rounded : Icons.grid_off_rounded,
              tooltip: 'Snap to grid',
              onTap: onSnapToggle,
            ),
            _btn(icon: Icons.save_rounded, tooltip: 'Save', onTap: onSave),
          ],
        ),
      ],
    );
  }

  Widget _panel(BuildContext context, {required List<Widget> children}) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: children),
    );
  }

  Widget _btn({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    Color? color,
  }) =>
      Tooltip(
        message: tooltip,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(icon, size: 18, color: color),
          ),
        ),
      );
}
