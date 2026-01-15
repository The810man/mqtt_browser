import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_browser/frontend/tree_node.dart';
import 'package:mqtt_browser/main.dart';

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

    return ListView.builder(
      itemCount: nodes.length,
      itemBuilder: (context, index) {
        final node = nodes[index];
        final indent = '  ' * (node.getDepth() - rootNode.getDepth());

        return ListTile(
          title: Text('$indent${node.label}'),
          subtitle: node.message != null ? Text(node.message!) : null,
          onTap: () {
            // Select the node
            ref.read(selectedItemProvider.notifier).state = {
              ...ref.read(selectedItemProvider),
              ref.watch(currentRootProvider).label!: node
            };
          },
          selected: ref.watch(selectedItemProvider)[
                  ref.watch(currentRootProvider).label!] ==
              node,
        );
      },
    );
  }
}
