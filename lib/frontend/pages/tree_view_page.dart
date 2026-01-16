import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:mqtt_browser/frontend/tree_node.dart';
import 'package:mqtt_browser/providers/providers.dart';
import 'package:mqtt_browser/frontend/widgets/tiling.dart';
import 'package:mqtt_browser/frontend/widgets/tree_nodes_widget.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:mqtt_browser/frontend/widgets/right_widget.dart';

class TreeViewPage extends ConsumerWidget {
  TreeSearchResult<TreeNode>? filter;
  Pattern? searchPattern;
  final textEditingController = TextEditingController();
  final List selectedList = [];
  final TextEditingController valueTextController = TextEditingController();
  final TextEditingController searchBarTextController = TextEditingController();
  final SidebarXController sidebarController = SidebarXController(
    selectedIndex: 0,
    extended: true,
  );
  final sideBarScaffholdKey = GlobalKey<ScaffoldState>();
  TreeViewPage({super.key});

  void select(dynamic item, WidgetRef ref) {
    ref.read(selectedItemProvider.notifier).state = item;
    List nodeList = ref.read(treeNodesProvider)[ref.watch(rootProvider).label]!;
    for (var i in nodeList) {
      if (i.isSelected) {
        i.isSelected = false;
      }
    }
    item.isSelected = !item.isSelected;
  }

  Iterable<TreeNode> getChildren(TreeNode node) {
    if (filter case TreeSearchResult<TreeNode> filter) {
      return node.children.where(filter.hasMatch);
    }
    return node.children;
  }

  void search(String query, WidgetRef ref) {
    // Needs to be reset before searching again, otherwise the tree controller
    // wouldn't reach some nodes because of the `getChildren()` impl above.
    filter = null;

    Pattern pattern;
    try {
      pattern = RegExp(query);
    } on FormatException {
      pattern = query;
    }
    searchPattern = pattern;
    final controller =
        ref.watch(
              tabDataProvider,
            )["${ref.watch(rootProvider).label}"]?['controller']
            as TreeController<TreeNode>?;
    if (controller == null) {
      return;
    }
    filter = controller.search(
      (TreeNode node) => node.label!.contains(pattern),
    );
    controller.rebuild();
  }

  void clearSearch(WidgetRef ref) {
    if (filter == null) return;
    filter = null;
    searchPattern = null;
    final controller =
        ref.watch(
              tabDataProvider,
            )["${ref.watch(rootProvider).label}"]?['controller']
            as TreeController<TreeNode>?;
    controller?.rebuild();
    searchBarTextController.clear();
  }

  void onSearchQueryChanged(WidgetRef ref) {
    final String query = searchBarTextController.text.trim();

    if (query.isEmpty) {
      clearSearch(ref);
      return;
    }

    search(query, ref);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          child: ValuesWidget(root: ref.watch(rootProvider)),
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
                child: Builder(
                  builder: (context) {
                    final rootLabel = ref.watch(rootProvider).label;
                    final tabData = ref.watch(tabDataProvider);
                    final treeNodes = ref.watch(treeNodesProvider);
                    final controller =
                        tabData["$rootLabel"]?['controller']
                            as TreeController<TreeNode>?;
                    final nodes = treeNodes[rootLabel];
                    if (controller == null || nodes == null) {
                      return const Center(
                        child: Text(
                          'No tree data yet. Connect or wait for messages.',
                        ),
                      );
                    }
                    return FastTreeNodeView(
                      treeController: controller,
                      nodes: nodes,
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
