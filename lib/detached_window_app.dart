import 'package:fl_nodes/fl_nodes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import 'frontend/tree_node.dart';
import 'frontend/widgets/tab_widgets/chart_view_widget.dart';
import 'frontend/widgets/tab_widgets/grid_view_widget.dart';
import 'frontend/widgets/tab_widgets/list_view_widget.dart';
import 'frontend/widgets/tab_widgets/mindmap_view_widget.dart';
import 'frontend/widgets/tab_widgets/node_executor_widget.dart';
import 'frontend/widgets/tree_nodes_widget.dart';
import 'models/mqtt_settings.dart';
import 'providers/providers.dart';

class DetachedWindowApp extends ConsumerWidget {
  final Map<String, dynamic> data;

  const DetachedWindowApp({super.key, required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topicPath = data['topicPath'] as String? ?? '';
    return MaterialApp(
      title: topicPath.isEmpty ? 'MQTT Browser' : 'MQTT — $topicPath',
      theme: ref.watch(themeProvider),
      localizationsDelegates: const [
        FlNodeEditorLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: DetachedWindowHome(data: data),
    );
  }
}

class DetachedWindowHome extends ConsumerStatefulWidget {
  final Map<String, dynamic> data;

  const DetachedWindowHome({super.key, required this.data});

  @override
  ConsumerState<DetachedWindowHome> createState() => _DetachedWindowHomeState();
}

class _DetachedWindowHomeState extends ConsumerState<DetachedWindowHome>
    with WindowListener {
  TreeController<TreeNode>? _treeCtrl;

  String get _topicPath => widget.data['topicPath'] as String? ?? '';
  String get _viewType => widget.data['viewType'] as String? ?? 'tree';

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _autoConnect());
  }

  @override
  void onWindowClose() async {
    // Destroy only this window — do not call g_application_quit().
    await windowManager.destroy();
  }

  Future<void> _autoConnect() async {
    try {
      final settingsJson =
          widget.data['mqttSettings'] as Map<String, dynamic>? ?? {};
      final MqttSettings settings;
      if (settingsJson.isEmpty) {
        settings = await ref.read(mqttSettingsServiceProvider.future);
      } else {
        settings = MqttSettings.fromJson(settingsJson);
      }
      final clientId =
          '${settings.clientId}_det_${DateTime.now().millisecondsSinceEpoch}';
      if (!mounted) return;
      await ref.read(mqttClientProvider.notifier).connect(
            settings.host,
            settings.port,
            clientId,
            settings,
          );
    } catch (e) {
      debugPrint('[DetachedWindow] auto-connect error: $e');
    }
  }

  TreeNode? _findNode(TreeNode root, String path) {
    if (path.isEmpty) return root;
    TreeNode? cur = root;
    for (final part in path.split('/')) {
      cur = cur?.children.cast<TreeNode?>().firstWhere(
            (c) => c?.label == part,
            orElse: () => null,
          );
      if (cur == null) return null;
    }
    return cur;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(treeNodesProvider, (_, __) {
      ref.read(changeIshappeningProvider.notifier).toggle();
    });

    ref.watch(treeNodesProvider);
    final root = ref.watch(rootProvider);
    final node = _findNode(root, _topicPath);

    if (node == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_topicPath.isEmpty ? 'MQTT Browser' : _topicPath),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Waiting for data on "${_topicPath.isEmpty ? 'root' : _topicPath}"...',
              ),
            ],
          ),
        ),
      );
    }

    Widget content;
    switch (_viewType) {
      case 'list':
        content = ListViewWidget(rootNode: node);
      case 'grid':
        content = GridViewWidget(rootNode: node);
      case 'chart':
        content = ChartViewWidget(rootNode: node);
      case 'executor':
        content = NodeExecutorWidget(rootNode: node);
      case 'mindmap':
        content = MindmapViewWidget(rootNode: node);
      case 'tree':
      default:
        _treeCtrl ??= TreeController<TreeNode>(
          roots: [node],
          childrenProvider: (n) => n.children,
        )..expandAll();
        content = FastTreeNodeView(
          treeController: _treeCtrl!,
          nodes: [node],
        );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_topicPath.isEmpty ? 'MQTT Browser' : _topicPath),
      ),
      body: content,
    );
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    _treeCtrl?.dispose();
    super.dispose();
  }
}
