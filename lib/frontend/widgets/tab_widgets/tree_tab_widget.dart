import 'dart:convert';
import 'dart:math';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_browser/frontend/tree_node.dart';
import 'package:mqtt_browser/providers/providers.dart';
import 'package:mqtt_browser/frontend/widgets/tree_view_search_bar_widget.dart';

String _buildTopicPath(TreeNode node, TreeNode root) {
  final segments = <String>[];
  TreeNode? cur = node;
  while (cur != null && cur != root) {
    segments.add(cur.label);
    cur = cur.parent;
  }
  return segments.reversed.join('/');
}

Future<void> _detachToWindow(
  BuildContext context,
  WidgetRef ref,
  TreeNode tab,
) async {
  final tabList = ref.read(tabListProvider);
  final viewType =
      ref.read(tabDataProvider)['${tab.label}']?['viewType'] as String? ??
      'tree';
  final settings = await ref.read(mqttSettingsServiceProvider.future);
  final root = ref.read(rootProvider);
  final topicPath = _buildTopicPath(tab, root);

  // Spawn the secondary window (desktop only — no-op on mobile/web).
  try {
    await WindowController.create(
      WindowConfiguration(
        arguments: jsonEncode({
          'topicPath': topicPath,
          'viewType': viewType,
          'mqttSettings': settings.toJson(),
        }),
        hiddenAtLaunch: true,
      ),
    );
  } catch (_) {
    return;
  }

  // Close the tab in the main window (skip if it's the root/connection tab).
  final isRoot = tab.label == root.label;
  if (!isRoot) {
    final ownIndex = tabList.indexOf(tab);
    if (ownIndex >= 0) {
      final newList = tabList.toList()..removeAt(ownIndex);
      final newTabIndex =
          (ownIndex > 0 ? ownIndex - 1 : 0).clamp(0, newList.length - 1);

      final tabData = Map<String, Map<String, dynamic>>.from(
        ref.read(tabDataProvider).map(
          (k, v) => MapEntry(k, Map<String, dynamic>.from(v)),
        ),
      )..remove(tab.label);
      final treeNodes = Map<String, List<TreeNode>>.from(
        ref.read(treeNodesProvider),
      )..remove(tab.label);

      ref.read(currentRootProvider.notifier).set(newList[newTabIndex]);
      ref.read(tabIndexProvider.notifier).set(newTabIndex);
      ref.read(tabLengthProvider.notifier).set(newList.length);
      ref.read(tabDataProvider.notifier).set(tabData);
      ref.read(treeNodesProvider.notifier).set(treeNodes);
      ref.read(tabListProvider.notifier).set(newList);
    }
  }
}

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
                      DropdownMenuItem(
                        value: 'executor',
                        child: Text('Node Executor'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        final tabData = ref.read(tabDataProvider);
                        final currentTabData =
                            tabData[tab.label] ??
                            {'controller': null, 'viewType': 'tree'};
                        ref.read(tabDataProvider.notifier).set({
                          ...tabData,
                          tab.label: {...currentTabData, 'viewType': value},
                        });
                      }
                    },
                  ),
                ),
                PopupMenuItem(
                  onTap: () => _detachToWindow(context, ref, tab),
                  child: const Row(
                    children: [
                      Icon(Icons.open_in_new_rounded),
                      SizedBox(width: 8),
                      Text('Detach to window'),
                    ],
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
                final newList = tabList.toList()..removeAt(ownIndex);
                final newTabIndex = (ownIndex > 0 ? ownIndex - 1 : 0)
                    .clamp(0, newList.length - 1);

                // Clean up stale entries for the closed tab.
                final tabData = Map<String, Map<String, dynamic>>.from(
                  ref.read(tabDataProvider).map(
                    (k, v) => MapEntry(k, Map<String, dynamic>.from(v)),
                  ),
                )..remove(tab.label);
                final treeNodes = Map<String, List<TreeNode>>.from(
                  ref.read(treeNodesProvider),
                )..remove(tab.label);

                debugPrint('[CLOSE_TAB] closing "${tab.label}", newList=${newList.map((t) => t.label).toList()}, newTabIndex=$newTabIndex');

                ref.read(currentRootProvider.notifier).set(
                  newList[newTabIndex],
                );
                ref.read(tabIndexProvider.notifier).set(newTabIndex);
                ref.read(tabLengthProvider.notifier).set(newList.length);
                ref.read(tabDataProvider.notifier).set(tabData);
                ref.read(treeNodesProvider.notifier).set(treeNodes);
                ref.read(tabListProvider.notifier).set(newList);
                debugPrint('[CLOSE_TAB] done, tabDataKeys=${tabData.keys.toList()}');
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
