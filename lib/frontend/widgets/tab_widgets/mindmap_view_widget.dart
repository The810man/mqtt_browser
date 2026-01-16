import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphview/GraphView.dart';
import 'dart:math' as math;
import 'package:mqtt_browser/frontend/tree_node.dart';

class MindmapViewWidget extends ConsumerWidget {
  final TreeNode rootNode;

  const MindmapViewWidget({super.key, required this.rootNode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final graph = Graph()..isTree = true;
    final builder = BuchheimWalkerConfiguration()
      ..siblingSeparation = 30
      ..levelSeparation = 60
      ..subtreeSeparation = 30
      ..orientation = BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM;

    void buildGraph(TreeNode node, Node graphNode) {
      for (final child in node.children) {
        final childNode = Node.Id(child);
        graph.addNode(childNode);
        graph.addEdge(graphNode, childNode);
        buildGraph(child, childNode);
      }
    }

    final rootGraphNode = Node.Id(rootNode);
    graph.addNode(rootGraphNode);
    buildGraph(rootNode, rootGraphNode);

    return Container(
      color: theme.colorScheme.surface.withValues(alpha: 0.9),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Icon(Icons.hub_rounded, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Mindmap View',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final canvasWidth = math
                    .max(constraints.maxWidth, 1200)
                    .toDouble();
                final canvasHeight = math
                    .max(constraints.maxHeight, 800)
                    .toDouble();
                return ClipRect(
                  child: InteractiveViewer(
                    minScale: 0.3,
                    maxScale: 2.5,
                    boundaryMargin: const EdgeInsets.all(64),
                    constrained: false,
                    child: SizedBox(
                      width: canvasWidth,
                      height: canvasHeight,
                      child: OverflowBox(
                        alignment: Alignment.topLeft,
                        minWidth: 0,
                        minHeight: 0,
                        maxWidth: double.infinity,
                        maxHeight: double.infinity,
                        child: GraphView(
                          graph: graph,
                          algorithm: BuchheimWalkerAlgorithm(
                            builder,
                            TreeEdgeRenderer(builder),
                          ),
                          paint: Paint()
                            ..color = theme.colorScheme.primary.withValues(
                              alpha: 0.6,
                            )
                            ..strokeWidth = 1.5
                            ..style = PaintingStyle.stroke,
                          builder: (Node node) {
                            final data = node.key?.value as TreeNode?;
                            return _MindmapNodeCard(
                              label: data?.label ?? 'Node',
                              theme: theme,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MindmapNodeCard extends StatelessWidget {
  final String label;
  final ThemeData theme;

  const _MindmapNodeCard({required this.label, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      color: theme.colorScheme.surface.withValues(alpha: 0.95),
      shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.primary.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
