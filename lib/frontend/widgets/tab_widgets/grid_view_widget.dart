import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_browser/frontend/tree_node.dart';
import 'package:mqtt_browser/providers/providers.dart';

class GridViewWidget extends ConsumerWidget {
  final TreeNode rootNode;

  const GridViewWidget({super.key, required this.rootNode});

  List<TreeNode> _flattenTree(TreeNode node) {
    List<TreeNode> nodes = [node];
    for (var child in node.children) {
      nodes.addAll(_flattenTree(child));
    }
    return nodes;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nodes = _flattenTree(rootNode);
    final theme = Theme.of(context);

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      padding: const EdgeInsets.all(8),
      itemCount: nodes.length,
      itemBuilder: (context, index) {
        final node = nodes[index];
        final isSelected =
            ref.watch(selectedItemProvider)[ref
                .watch(currentRootProvider)
                .label!] ==
            node;

        return Card(
          elevation: isSelected ? 4 : 2,
          color: theme.colorScheme.surface.withValues(alpha: 0.9),
          shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected
                  ? theme.colorScheme.primary.withValues(alpha: 0.6)
                  : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: InkWell(
            onTap: () {
              ref.read(selectedItemProvider.notifier).state = {
                ...ref.read(selectedItemProvider),
                ref.watch(currentRootProvider).label!: node,
              };
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.grid_view_rounded,
                        size: 14,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          node.label ?? 'Unknown',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (node.message != null)
                    Expanded(
                      child: Text(
                        node.message!,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
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
