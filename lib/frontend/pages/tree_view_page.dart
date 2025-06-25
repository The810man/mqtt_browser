import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:mqtt_browser/frontend/tree_node.dart';
import 'package:mqtt_browser/main.dart';
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
  final SidebarXController sidebarController =
      SidebarXController(selectedIndex: 0, extended: true);
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

    filter = ref
        .watch(tabDataProvider)["${ref.watch(rootProvider).label}"]!
        .search((TreeNode node) => node.label!.contains(pattern));
    ref.watch(tabDataProvider)["${ref.watch(rootProvider).label}"]!.rebuild();
  }

  void clearSearch(WidgetRef ref) {
    if (filter == null) return;
    filter = null;
    searchPattern = null;
    ref.watch(tabDataProvider)["${ref.watch(rootProvider).label}"]!.rebuild();
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
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                  offset: const Offset(0, 4),
                  color: Theme.of(context).colorScheme.shadow,
                  spreadRadius: 3,
                  blurRadius: 5)
            ]),
            child: ValuesWidget(
              root: ref.watch(rootProvider),
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
                  child: FastTreeNodeView(
                      treeController: ref.watch(
                          tabDataProvider)["${ref.watch(rootProvider).label}"]!,
                      nodes: ref.watch(
                          treeNodesProvider)[ref.watch(rootProvider).label]!),
                ),
              );
            })));
  }
}
