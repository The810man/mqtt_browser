import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_browser/frontend/tree_node.dart';
import 'package:mqtt_browser/providers/providers.dart';

class ListViewWidget extends ConsumerWidget {
  final TreeNode rootNode;

  const ListViewWidget({super.key, required this.rootNode});

  List<_FlatNode> _flatten(TreeNode node, int depth) {
    final result = <_FlatNode>[];
    result.add(_FlatNode(node: node, depth: depth));
    for (final child in node.children) {
      result.addAll(_flatten(child, depth + 1));
    }
    return result;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(treeNodesProvider); // live updates
    final theme = Theme.of(context);
    final rootLabel = ref.watch(currentRootProvider).label;
    final selectedNode = ref.watch(selectedItemProvider)[rootLabel];
    final items = _flatten(rootNode, 0);

    if (items.isEmpty) {
      return const Center(child: Text('No topics yet.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final node = item.node;
        final isSelected = selectedNode == node;
        final isLeaf = node.children.isEmpty;
        final hasValue = node.history.isNotEmpty;

        return Padding(
          padding: EdgeInsets.only(
            left: item.depth * 16.0,
            bottom: 4,
          ),
          child: Card(
            elevation: isSelected ? 3 : 1,
            color: isSelected
                ? theme.colorScheme.primaryContainer.withValues(alpha: 0.4)
                : theme.colorScheme.surface.withValues(alpha: 0.9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: isSelected
                    ? theme.colorScheme.primary.withValues(alpha: 0.6)
                    : theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                ref.read(selectedItemProvider.notifier).set({
                  ...ref.read(selectedItemProvider),
                  rootLabel: node,
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      isLeaf ? Icons.circle : Icons.folder_outlined,
                      size: isLeaf ? 8 : 16,
                      color: isLeaf && hasValue
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            node.label,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                          if (hasValue)
                            Text(
                              node.message!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.65),
                                fontFamily: 'monospace',
                              ),
                            ),
                          if (!isLeaf)
                            Text(
                              '${node.topicCount} topics · ${node.messageCount} messages',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.45),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (hasValue)
                      IconButton(
                        icon: const Icon(Icons.copy, size: 14),
                        tooltip: 'Copy value',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 28,
                          minHeight: 28,
                        ),
                        onPressed: () =>
                            Clipboard.setData(ClipboardData(text: node.message!)),
                      ),
                    if (!isLeaf)
                      Text(
                        '${node.children.length}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FlatNode {
  final TreeNode node;
  final int depth;
  const _FlatNode({required this.node, required this.depth});
}
