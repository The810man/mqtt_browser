import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_browser/main.dart';
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
    final viewType =
        ref.watch(tabDataProvider)[currentTab.label]!['viewType'] as String;

    Widget leftContent;
    if (viewType == 'tree') {
      leftContent = Column(
        children: [
          Treeviewsearchbar(
            rootNode: currentTab,
            treeController: ref
                .watch(tabDataProvider)["${currentTab.label}"]!['controller']!,
          ),
          Expanded(
            child: FastTreeNodeView(
              treeController: ref.watch(
                  tabDataProvider)["${currentTab.label}"]!['controller']!,
              nodes: ref.watch(treeNodesProvider)[currentTab.label]!,
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
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                  offset: const Offset(0, 4),
                  color: Theme.of(context).colorScheme.shadow,
                  spreadRadius: 3,
                  blurRadius: 5)
            ]),
            child: ValuesWidget(
              root: currentTab,
            ),
          ),
        ),
        leftWidget: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Consumer(builder: (context, ref, child) {
              return Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                          offset: const Offset(0, 4),
                          color: Theme.of(context).colorScheme.shadow,
                          spreadRadius: 3,
                          blurRadius: 5)
                    ]),
                width: MediaQuery.of(context).size.width,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: leftContent,
                ),
              );
            })));
  }
}
