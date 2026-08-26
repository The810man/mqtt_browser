import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mqtt_browser/frontend/tree_node.dart';
import 'package:mqtt_browser/providers/providers.dart';
import 'package:mqtt_browser/frontend/widgets/smooth_blinker/smooth_blink_widget.dart';

final Provider<TreeEntry<TreeNode>> currentNodeProvider =
    Provider<TreeEntry<TreeNode>>(
      (_) => throw StateError('No tree entry in scope'),
    );

class FastTreeNodeView extends ConsumerWidget {
  const FastTreeNodeView({
    super.key,
    required this.nodes,
    required this.treeController,
    this.filter,
  });

  final TreeController<TreeNode> treeController;
  final List<TreeNode> nodes;
  final TreeSearchResult<TreeNode>? filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(changeIshappeningProvider);
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: constraints.maxWidth > 0 ? constraints.maxWidth.clamp(300, 9000) : 600,
          height: constraints.maxHeight > 0 ? constraints.maxHeight : MediaQuery.of(context).size.height,
          child: TreeView<TreeNode>(
            shrinkWrap: true,
            treeController: treeController,
            nodeBuilder: (context, entry) => ProviderScope(
              overrides: [currentNodeProvider.overrideWithValue(entry)],
              child: _TreeTile(
                treeController: treeController,
                filter: filter,
                key: ValueKey(entry.node),
              ),
            ),
          ),
        ),
      ),
    ),
    );
  }
}

String _buildTopicPath(TreeNode node, TreeNode root) {
  final segments = <String>[];
  TreeNode? current = node;
  while (current != null && current != root) {
    segments.add(current.label);
    current = current.parent;
  }
  return segments.reversed.join('/');
}

void _openTab(TreeEntry<TreeNode> entry, WidgetRef ref, String viewType) {
  final node = entry.node;
  debugPrint('[OPEN_TAB] called: node="${node.label}" viewType=$viewType');

  if (node.label.isEmpty) {
    node.label = 'Tab ${ref.read(tabListProvider).length + 1}';
  }

  final tabKey = node.label;
  final tabList = ref.read(tabListProvider).toList();
  debugPrint(
    '[OPEN_TAB] tabList=${tabList.map((t) => t.label).toList()} tabKey=$tabKey',
  );

  if (tabList.any((t) => t.label == tabKey)) {
    debugPrint('[OPEN_TAB] DEDUP: tab "$tabKey" already open, returning early');
    return;
  }

  tabList.add(node);

  final controller = TreeController<TreeNode>(
    roots: [node],
    childrenProvider: (n) => n.children,
  );
  controller.expand(node);

  final tabData = Map<String, Map<String, dynamic>>.from(
    ref
        .read(tabDataProvider)
        .map((k, v) => MapEntry(k, Map<String, dynamic>.from(v))),
  );
  tabData[tabKey] = {'controller': controller, 'viewType': viewType};

  final treeNodes = Map<String, List<TreeNode>>.from(
    ref.read(treeNodesProvider),
  );
  treeNodes[tabKey] = [node];

  final newTabIndex = tabList.length - 1;
  debugPrint(
    '[OPEN_TAB] setting newTabIndex=$newTabIndex tabList=${tabList.map((t) => t.label).toList()}',
  );

  ref.read(tabListProvider.notifier).set(tabList);
  ref.read(tabLengthProvider.notifier).set(tabList.length);
  ref.read(tabDataProvider.notifier).set(tabData);
  ref.read(treeNodesProvider.notifier).set(treeNodes);
  ref.read(tabIndexProvider.notifier).set(newTabIndex);
  ref.read(currentRootProvider.notifier).set(node);
  debugPrint('[OPEN_TAB] done');
}

class _TreeTile extends ConsumerWidget {
  const _TreeTile({super.key, required this.treeController, this.filter});

  final TreeController<TreeNode> treeController;
  final TreeSearchResult<TreeNode>? filter;

  bool _isSelected(TreeEntry<TreeNode> entry, WidgetRef ref) {
    final rootLabel = ref.watch(currentRootProvider).label;
    return ref.read(selectedItemProvider)[rootLabel] == entry.node;
  }

  void _onTap(TreeEntry<TreeNode> entry, WidgetRef ref) {
    final rootLabel = ref.watch(currentRootProvider).label;

    ref.read(selectedItemProvider.notifier).set({
      ...ref.read(selectedItemProvider),
      rootLabel: entry.node,
    });

    final topic = _buildTopicPath(entry.node, ref.read(rootProvider));
    ref.read(publishTextControllerProvider).text = topic;

    final lastMessage = entry.node.history.isEmpty
        ? ''
        : entry.node.history.last;
    ref
        .read(currentMessageProvider.notifier)
        .set(ref.watch(currentRootProvider), lastMessage);

    ref.read(changeIshappeningProvider.notifier).toggle();
    treeController.toggleExpansion(entry.node);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entry = ref.watch(currentNodeProvider);
    final isSelected = _isSelected(entry, ref);

    // Hide node when a search filter is active and node doesn't match
    if (filter != null && !filter!.hasMatch(entry.node)) {
      return const SizedBox.shrink();
    }

    return InkWell(
      onTap: () => _onTap(entry, ref),
      child: TreeIndentation(
        entry: entry,
        guide: IndentGuide.connectingLines(
          indent: ref.watch(spaceSliderProvider),
          roundCorners: ref.watch(roundedLineSwitchProvider),
          connectBranches: ref.watch(connectLinesSwitchProvider),
          thickness: ref.watch(thicknessSliderProvider),
          origin: ref.watch(originSliderProvider),
        ),
        child: Align(
          heightFactor: ref.watch(nodeHeightProvider),
          child: Row(
            children: [
              const SizedBox(width: 5),
              Align(
                widthFactor: 0.25,
                child: FolderButton(
                  icon: const Icon(Icons.linear_scale_rounded, size: 0),
                  closedIcon: const Icon(Icons.arrow_right_rounded),
                  openedIcon: const Icon(Icons.arrow_drop_down_rounded),
                  isOpen: entry.hasChildren ? entry.isExpanded : null,
                  onPressed: entry.hasChildren
                      ? () => _onTap(entry, ref)
                      : null,
                ),
              ),
              SmoothHighlight(
                duration: Duration(
                  milliseconds: ref.watch(blinkDurationProvider).toInt(),
                ),
                color: ref
                    .watch(themeDataProvider)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.5),
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: ref.watch(nodeHeightProvider) * 30,
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    border: Border.all(
                      color: isSelected
                          ? const Color.fromARGB(255, 145, 145, 145)
                          : const Color.fromARGB(0, 145, 145, 145),
                      width: 2,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 5),
                      Text(_nodeLabel(entry)),
                      const SizedBox(width: 5),
                      if (isSelected)
                        PopupMenuButton<String>(
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: 'tree',
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Open in Tree-View'),
                                  Icon(Icons.account_tree_rounded),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'list',
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Open in List-view'),
                                  Icon(Icons.list_alt_rounded),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'mindmap',
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Open in Mindmap-view'),
                                  Icon(Icons.hub_rounded),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'grid',
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Open in Grid-view'),
                                  Icon(Icons.grid_view_rounded),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'chart',
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Open in Graph-view'),
                                  Icon(Icons.show_chart_rounded),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'executor',
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Open in Node Executor'),
                                  Icon(Icons.account_tree_rounded),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (viewType) {
                            _openTab(entry, ref, viewType);
                          },
                          icon: const Icon(Icons.menu),
                          iconSize: ref.watch(nodeHeightProvider) * 15,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _nodeLabel(TreeEntry<TreeNode> entry) {
    final node = entry.node;
    final last = node.history.isEmpty ? '' : node.history.last;
    if (node.children.isNotEmpty) {
      return entry.isExpanded
          ? '${node.label}${last.isEmpty ? '' : ' = $last'}'
          : '${node.label} (${node.messageCount} Messages | ${node.topicCount} Topics)';
    }
    return '${node.label}${last.isEmpty ? '' : ' = $last'}';
  }
}
