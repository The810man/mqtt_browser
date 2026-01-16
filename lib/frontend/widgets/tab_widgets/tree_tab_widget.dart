import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_browser/frontend/tree_node.dart';
import 'package:mqtt_browser/providers/providers.dart';
import 'dart:math';
import 'package:mqtt_browser/frontend/widgets/tree_view_search_bar_widget.dart';

class Treetabwidget extends ConsumerWidget {
  const Treetabwidget({
    super.key,
    required this.tab,
    required this.unSelectedIcon,
    required this.selectedWidget,
    required this.text,
  });
  final Icon unSelectedIcon;
  final Widget selectedWidget;

  final String text;
  final TreeNode tab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<TreeNode> tabList = ref.watch(tabListProvider);
    final theme = Theme.of(context);
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(Icons.account_tree_rounded, size: 20),
          const SizedBox(width: 10),
          Text(text),
          const SizedBox(width: 10),
          PopupMenuButton(
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  onTap: () => ref
                      .watch(tabDataProvider)["${tab.label}"]!['controller']!
                      .expandAll(),
                  child: const Row(
                    children: [Icon(Icons.expand), Text("Expand All Nodes")],
                  ),
                ),
                PopupMenuItem(
                  onTap: () => ref
                      .watch(tabDataProvider)["${tab.label}"]!['controller']!
                      .collapseAll(),
                  child: const Row(
                    children: [
                      Icon(Icons.close_fullscreen_outlined),
                      Text("Collapse All Nodes"),
                    ],
                  ),
                ),
                PopupMenuItem(
                  child: DropdownButton<String>(
                    value:
                        ref.watch(tabDataProvider)["${tab.label}"]!['viewType']
                            as String,
                    items: const [
                      DropdownMenuItem(value: 'tree', child: Text('Tree View')),
                      DropdownMenuItem(value: 'list', child: Text('List View')),
                      DropdownMenuItem(
                        value: 'mindmap',
                        child: Text('Mindmap'),
                      ),
                      DropdownMenuItem(value: 'grid', child: Text('Grid View')),
                      DropdownMenuItem(
                        value: 'chart',
                        child: Text('Chart View'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null && tab.label != null) {
                        final tabData = ref.read(tabDataProvider);
                        final currentTabData =
                            tabData[tab.label!] ??
                            {'controller': null, 'viewType': 'tree'};
                        ref.read(tabDataProvider.notifier).state = {
                          ...tabData,
                          tab.label!: {...currentTabData, 'viewType': value},
                        };
                      }
                    },
                  ),
                ),
                PopupMenuItem(
                  child: Treeviewsearchbar(
                    rootNode: tab,
                    treeController: ref.watch(
                      tabDataProvider,
                    )["${tab.label}"]!['controller']!,
                  ),
                ),
              ];
            },
          ),
          Transform.rotate(
            angle: 90 * pi / 180,
            child: IconButton(
              constraints: tab.label == ref.watch(rootProvider).label
                  ? const BoxConstraints(maxHeight: 0, maxWidth: 0)
                  : const BoxConstraints(maxHeight: 50, maxWidth: 50),
              onPressed: () {
                final ownIndex = tabList.indexOf(tab);
                final lastIndex = tabList.indexOf(tabList.last);
                final newTabIndex = ownIndex == lastIndex
                    ? ownIndex - 1
                    : ownIndex + 1;
                List<TreeNode> newList = tabList;
                ref.read(currentRootProvider.notifier).state =
                    tabList[newTabIndex];
                ref.read(tabLengthProvider.notifier).state -= 1;
                newList.removeAt(newList.indexOf(tab));
                ref.read(tabIndexProvider.notifier).state = newTabIndex;
                ref.read(tabListProvider.notifier).state = newList;
              },
              icon: Icon(
                Icons.cancel_presentation_rounded,
                color: Colors.red,
                size: tab.label == ref.watch(rootProvider).label ? 0 : 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
