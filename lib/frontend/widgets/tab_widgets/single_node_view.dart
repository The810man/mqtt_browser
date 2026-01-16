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

class Singlenodeview extends ConsumerWidget {
  final textEditingController = TextEditingController();
  final List selectedList = [];
  final TextEditingController valueTextController = TextEditingController();
  final String newText = "";
  Singlenodeview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(currentRootProvider);
    final tabKey = currentTab.label ?? 'default';
    final viewType = ref.watch(tabDataProvider)[tabKey]!['viewType'] as String;

    Widget leftContent;
    if (viewType == 'tree') {
      leftContent = Column(
        children: [
          Treeviewsearchbar(
            rootNode: currentTab,
            treeController: ref.watch(
              tabDataProvider,
            )[tabKey]!['controller']!,
          ),
          Expanded(
            child: FastTreeNodeView(
              treeController: ref.watch(
                tabDataProvider,
              )[tabKey]!['controller']!,
              nodes: ref.watch(treeNodesProvider)[tabKey]!,
            ),
          ),
        ],
      );
    } else if (viewType == 'list') {
      leftContent = ListViewWidget(rootNode: currentTab);
    } else if (viewType == 'mindmap') {
      leftContent = MindmapViewWidget(rootNode: currentTab);
    } else if (viewType == 'grid') {
      leftContent = GridViewWidget(rootNode: currentTab);
    } else if (viewType == 'chart') {
      leftContent = ChartViewWidget(rootNode: currentTab);
    } else {
      leftContent = const Center(child: Text('Unknown view type'));
    }

    return Tiling(
      rightWidget: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                offset: const Offset(0, 4),
                color: Theme.of(
                  context,
                ).colorScheme.shadow.withValues(alpha: 0.25),
                spreadRadius: 1,
                blurRadius: 12,
              ),
            ],
          ),
          child: ValuesWidget(root: currentTab),
        ),
      ),
      leftWidget: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Consumer(
          builder: (context, ref, child) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surface.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0, 4),
                    color: Theme.of(
                      context,
                    ).colorScheme.shadow.withValues(alpha: 0.25),
                    spreadRadius: 1,
                    blurRadius: 12,
                  ),
                ],
              ),
              width: MediaQuery.of(context).size.width,
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: leftContent,
              ),
            );
          },
        ),
      ),
    );
  }
}
