import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_browser/frontend/tree_node.dart';
import 'package:mqtt_browser/providers/providers.dart';

class ListViewWidget extends ConsumerWidget {
  final TreeNode rootNode;

  const ListViewWidget({super.key, required this.rootNode});

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
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: nodes.length,
      itemBuilder: (context, index) {
        final node = nodes[index];
        final indent = '  ' * (node.getDepth() - rootNode.getDepth());
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
          child: ListTile(
            leading: Icon(
              Icons.topic_outlined,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            title: Text(
              '$indent${node.label ?? 'Unnamed'}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            subtitle: node.message != null
                ? Text(
                    node.message!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  )
                : null,
            onTap: () {
              ref.read(selectedItemProvider.notifier).state = {
                ...ref.read(selectedItemProvider),
                ref.watch(currentRootProvider).label!: node,
              };
            },
            selected: isSelected,
          ),
        );
      },
    );
  }
}
