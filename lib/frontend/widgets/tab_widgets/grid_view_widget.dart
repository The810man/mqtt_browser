import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_browser/frontend/tree_node.dart';
import 'package:mqtt_browser/providers/providers.dart';

class GridViewWidget extends ConsumerWidget {
  final TreeNode rootNode;

  const GridViewWidget({super.key, required this.rootNode});

  List<TreeNode> _leafNodes(TreeNode node) {
    if (node.children.isEmpty) return node.history.isNotEmpty ? [node] : [];
    return node.children.expand(_leafNodes).toList();
  }

  String _topicPath(TreeNode node, TreeNode root) {
    final segments = <String>[];
    TreeNode? cur = node;
    while (cur != null && cur != root) {
      segments.add(cur.label);
      cur = cur.parent;
    }
    return segments.reversed.join('/');
  }

  bool _isNumeric(String? v) =>
      v != null && double.tryParse(v) != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(treeNodesProvider); // live updates
    final theme = Theme.of(context);
    final rootLabel = ref.watch(currentRootProvider).label;
    final selectedNode = ref.watch(selectedItemProvider)[rootLabel];
    final leaves = _leafNodes(rootNode);

    if (leaves.isEmpty) {
      return const Center(child: Text('No data yet. Waiting for messages.'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        mainAxisExtent: 110,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: leaves.length,
      itemBuilder: (context, index) {
        final node = leaves[index];
        final isSelected = selectedNode == node;
        final value = node.message ?? '—';
        final numeric = _isNumeric(node.message);
        final path = _topicPath(node, rootNode);

        return Card(
          elevation: isSelected ? 4 : 1,
          color: isSelected
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
              : theme.colorScheme.surface.withValues(alpha: 0.95),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected
                  ? theme.colorScheme.primary.withValues(alpha: 0.7)
                  : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              ref.read(selectedItemProvider.notifier).set({
                ...ref.read(selectedItemProvider),
                rootLabel: node,
              });
            },
            onLongPress: () =>
                Clipboard.setData(ClipboardData(text: value)),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        numeric
                            ? Icons.show_chart_rounded
                            : Icons.data_object_rounded,
                        size: 13,
                        color: theme.colorScheme.primary.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          path.isEmpty ? node.label : path,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    value,
                    style: numeric
                        ? theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          )
                        : theme.textTheme.bodyMedium?.copyWith(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w500,
                          ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${node.totalMessages} msg${node.totalMessages == 1 ? '' : 's'}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
