import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

import 'package:mqtt_browser/frontend/tree_node.dart';
import 'package:mqtt_browser/frontend/widgets/tab_widgets/chart_view_widget.dart';
import 'package:mqtt_browser/frontend/widgets/tiling.dart';
import 'package:mqtt_browser/frontend/widgets/tree_nodes_widget.dart';
import 'package:mqtt_browser/frontend/widgets/right_widget.dart';
import 'package:mqtt_browser/providers/providers.dart';

class TreeViewPage extends ConsumerStatefulWidget {
  const TreeViewPage({super.key});

  @override
  ConsumerState<TreeViewPage> createState() => _TreeViewPageState();
}

/// Right-hand panel of the main screen: topic Details plus a live Graphs
/// view (time range + timestamp x-axis + live/pause toggle) for every
/// numeric topic under the current connection.
class _DetailsAndGraphsPanel extends HookConsumerWidget {
  const _DetailsAndGraphsPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = useTabController(initialLength: 2);
    final cs = Theme.of(context).colorScheme;
    final root = ref.watch(rootProvider);

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: TabBar(
            controller: tab,
            labelColor: cs.primary,
            indicatorColor: cs.primary,
            tabs: const [
              Tab(icon: Icon(Icons.info_outline), text: 'Details'),
              Tab(icon: Icon(Icons.show_chart_rounded), text: 'Graphs'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: tab,
            children: [
              ValuesWidget(root: root),
              ChartViewWidget(rootNode: root),
            ],
          ),
        ),
      ],
    );
  }
}

class _TreeViewPageState extends ConsumerState<TreeViewPage> {
  TreeSearchResult<TreeNode>? _filter;

  TreeController<TreeNode>? _controller() {
    final rootLabel = ref.read(rootProvider).label;
    return ref.read(tabDataProvider)[rootLabel]?['controller']
        as TreeController<TreeNode>?;
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild tree controllers whenever new messages arrive
    ref.listen(treeNodesProvider, (_, next) {
      debugPrint('[PAGE] treeNodesProvider changed, keys=${next.keys.toList()}');
      _controller()?.rebuild();
    });

    return Tiling(
      leftLabel: 'Tree',
      rightLabel: 'Details',
      rightWidget: Padding(
        padding: const EdgeInsets.all(8),
        child: _panel(child: const _DetailsAndGraphsPanel()),
      ),
      leftWidget: Padding(
        padding: const EdgeInsets.all(8),
        child: _panel(child: _treeContent()),
      ),
    );
  }

  Widget _treeContent() {
    final rootLabel = ref.watch(rootProvider).label;
    final tabData = ref.watch(tabDataProvider);
    final treeNodes = ref.watch(treeNodesProvider);
    final controller =
        tabData[rootLabel]?['controller'] as TreeController<TreeNode>?;
    final nodes = treeNodes[rootLabel];

    debugPrint('[PAGE] rootLabel="$rootLabel" tabDataKeys=${tabData.keys.toList()} treeNodesKeys=${treeNodes.keys.toList()} controller=${controller != null} nodes=${nodes?.length}');

    if (controller == null || nodes == null) {
      return const Center(
        child: Text('No tree data yet. Connect or wait for messages.'),
      );
    }

    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: FastTreeNodeView(
        treeController: controller,
        nodes: nodes,
        filter: _filter,
      ),
    );
  }

  Widget _panel({required Widget child}) {
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
}
