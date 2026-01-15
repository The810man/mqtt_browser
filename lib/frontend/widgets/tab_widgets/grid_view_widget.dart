import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_browser/frontend/tree_node.dart';
import 'package:mqtt_browser/main.dart';

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

        return Card(
          child: InkWell(
            onTap: () {
              ref.read(selectedItemProvider.notifier).state = {
                ...ref.read(selectedItemProvider),
                ref.watch(currentRootProvider).label!: node
              };
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    node.label ?? 'Unknown',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (node.message != null)
                    Expanded(
                      child: Text(
                        node.message!,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
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
