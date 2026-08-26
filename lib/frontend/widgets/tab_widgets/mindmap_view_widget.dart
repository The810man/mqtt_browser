import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphview/GraphView.dart';
import 'dart:math' as math;
import 'package:mqtt_browser/frontend/tree_node.dart';
import 'package:mqtt_browser/providers/providers.dart';

class MindmapViewWidget extends ConsumerWidget {
  final TreeNode rootNode;

  const MindmapViewWidget({super.key, required this.rootNode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(treeNodesProvider); // live updates
    final theme = Theme.of(context);
    final rootLabel = ref.watch(currentRootProvider).label;

    final graph = Graph()..isTree = true;
    final builder = BuchheimWalkerConfiguration()
      ..siblingSeparation = 40
      ..levelSeparation = 80
      ..subtreeSeparation = 40
      ..orientation = BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM;

    void buildGraph(TreeNode node, Node graphNode) {
      for (final child in node.children) {
        final childNode = Node.Id(child);
        graph.addNode(childNode);
        graph.addEdge(graphNode, childNode,
            paint: Paint()
              ..color = theme.colorScheme.primary.withValues(alpha: 0.4)
              ..strokeWidth = 1.5
              ..style = PaintingStyle.stroke);
        buildGraph(child, childNode);
      }
    }

    final rootGraphNode = Node.Id(rootNode);
    graph.addNode(rootGraphNode);
    buildGraph(rootNode, rootGraphNode);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              Icon(Icons.hub_rounded, color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                rootNode.label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${rootNode.topicCount} topics · ${rootNode.messageCount} messages',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final canvasWidth =
                  math.max(constraints.maxWidth, 1200).toDouble();
              final canvasHeight =
                  math.max(constraints.maxHeight, 800).toDouble();
              return ClipRect(
                child: InteractiveViewer(
                  minScale: 0.2,
                  maxScale: 3.0,
                  boundaryMargin: const EdgeInsets.all(80),
                  constrained: false,
                  child: SizedBox(
                    width: canvasWidth,
                    height: canvasHeight,
                    child: OverflowBox(
                      alignment: Alignment.topCenter,
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
                          ..color =
                              theme.colorScheme.primary.withValues(alpha: 0.4)
                          ..strokeWidth = 1.5
                          ..style = PaintingStyle.stroke,
                        builder: (Node node) {
                          final data = node.key?.value as TreeNode?;
                          if (data == null) return const SizedBox.shrink();
                          final isSelected =
                              ref.read(selectedItemProvider)[rootLabel] == data;
                          return _MindmapNodeCard(
                            node: data,
                            theme: theme,
                            isSelected: isSelected,
                            onTap: () {
                              ref.read(selectedItemProvider.notifier).set({
                                ...ref.read(selectedItemProvider),
                                rootLabel: data,
                              });
                            },
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
    );
  }
}

class _MindmapNodeCard extends StatelessWidget {
  final TreeNode node;
  final ThemeData theme;
  final bool isSelected;
  final VoidCallback onTap;

  const _MindmapNodeCard({
    required this.node,
    required this.theme,
    required this.isSelected,
    required this.onTap,
  });

  bool get _isLeaf => node.children.isEmpty;
  bool get _hasValue => node.history.isNotEmpty;
  bool get _isNumeric =>
      _hasValue && double.tryParse(node.message!.trim()) != null;

  @override
  Widget build(BuildContext context) {
    final Color borderColor = isSelected
        ? theme.colorScheme.primary
        : _isLeaf && _hasValue
            ? theme.colorScheme.primary.withValues(alpha: 0.45)
            : theme.colorScheme.outlineVariant.withValues(alpha: 0.4);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minWidth: 80, maxWidth: 160),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
              : theme.colorScheme.surface.withValues(alpha: 0.97),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.12),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              node.label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            if (_isLeaf && _hasValue) ...[
              const SizedBox(height: 3),
              Text(
                node.message!,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontFamily: 'monospace',
                  color: _isNumeric
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  fontWeight:
                      _isNumeric ? FontWeight.w700 : FontWeight.normal,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ] else if (!_isLeaf) ...[
              const SizedBox(height: 2),
              Text(
                '${node.children.length} sub-topics',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
