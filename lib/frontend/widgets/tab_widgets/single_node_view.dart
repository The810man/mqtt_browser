import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_browser/providers/providers.dart';
import 'package:mqtt_browser/frontend/widgets/tiling.dart';
import 'package:mqtt_browser/frontend/widgets/tree_nodes_widget.dart';
import 'package:mqtt_browser/frontend/widgets/right_widget.dart';
import 'package:mqtt_browser/frontend/widgets/tree_view_search_bar_widget.dart';
import 'package:mqtt_browser/frontend/widgets/tab_widgets/list_view_widget.dart';
import 'package:mqtt_browser/frontend/widgets/tab_widgets/mindmap_view_widget.dart';
import 'package:mqtt_browser/frontend/widgets/tab_widgets/grid_view_widget.dart';
import 'package:mqtt_browser/frontend/widgets/tab_widgets/chart_view_widget.dart';
import 'package:mqtt_browser/frontend/widgets/tab_widgets/node_executor_widget.dart';

class Singlenodeview extends ConsumerWidget {
  final textEditingController = TextEditingController();
  final List selectedList = [];
  final TextEditingController valueTextController = TextEditingController();
  final String newText = "";
  Singlenodeview({super.key});

  Widget _panel(BuildContext context, Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 4),
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.25),
            spreadRadius: 1,
            blurRadius: 12,
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(treeNodesProvider); // rebuild whenever MQTT data arrives
    final currentTab = ref.watch(currentRootProvider);
    final tabKey = currentTab.label;
    final tabEntry = ref.watch(tabDataProvider)[tabKey];
    if (tabEntry == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final viewType = tabEntry['viewType'] as String;

    Widget leftContent;
    if (viewType == 'tree') {
      final controller = tabEntry['controller'];
      final nodes = ref.watch(treeNodesProvider)[tabKey];
      if (controller == null || nodes == null) {
        leftContent = const Center(child: CircularProgressIndicator());
      } else {
        leftContent = Column(
          children: [
            Treeviewsearchbar(rootNode: currentTab, treeController: controller),
            Expanded(
              child: FastTreeNodeView(
                treeController: controller,
                nodes: nodes,
              ),
            ),
          ],
        );
      }
    } else if (viewType == 'list') {
      leftContent = ListViewWidget(rootNode: currentTab);
    } else if (viewType == 'mindmap') {
      leftContent = MindmapViewWidget(rootNode: currentTab);
    } else if (viewType == 'grid') {
      leftContent = GridViewWidget(rootNode: currentTab);
    } else if (viewType == 'chart') {
      leftContent = ChartViewWidget(rootNode: currentTab);
    } else if (viewType == 'executor') {
      return NodeExecutorWidget(rootNode: currentTab);
    } else {
      leftContent = const Center(child: Text('Unknown view type'));
    }

    return Tiling(
      leftLabel: 'View',
      rightLabel: 'Details',
      rightWidget: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _panel(context, ValuesWidget(root: currentTab)),
      ),
      leftWidget: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _panel(
          context,
          SizedBox.expand(child: leftContent),
        ),
      ),
    );
  }
}
