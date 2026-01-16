import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_browser/frontend/tree_node.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartViewWidget extends ConsumerWidget {
  final TreeNode rootNode;

  const ChartViewWidget({super.key, required this.rootNode});

  List<_ChartPoint> _parseNumericHistory(List<String> history) {
    List<_ChartPoint> points = [];
    for (int i = 0; i < history.length; i++) {
      try {
        double value = double.parse(history[i]);
        points.add(_ChartPoint(i, value));
      } catch (e) {
        // Skip non-numeric values
      }
    }
    return points;
  }

  List<TreeNode> _getLeafNodes(TreeNode node) {
    List<TreeNode> leaves = [];
    if (node.children.isEmpty && node.history.isNotEmpty) {
      leaves.add(node);
    } else {
      for (var child in node.children) {
        leaves.addAll(_getLeafNodes(child));
      }
    }
    return leaves;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leafNodes = _getLeafNodes(rootNode);
    final theme = Theme.of(context);

    if (leafNodes.isEmpty) {
      return const Center(
        child: Text('No numeric data available for charting'),
      );
    }

    return ListView.builder(
      itemCount: leafNodes.length,
      itemBuilder: (context, index) {
        final node = leafNodes[index];
        final spots = _parseNumericHistory(node.history);

        if (spots.isEmpty) {
          return ListTile(
            title: Text(node.label ?? 'Unknown'),
            subtitle: const Text('No numeric data'),
          );
        }

        return Card(
          margin: const EdgeInsets.all(8),
          elevation: 2,
          color: theme.colorScheme.surface.withValues(alpha: 0.9),
          shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  node.label ?? 'Unknown Topic',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 220,
                  child: SfCartesianChart(
                    backgroundColor: Colors.transparent,
                    plotAreaBorderWidth: 0,
                    primaryXAxis: NumericAxis(
                      majorGridLines: const MajorGridLines(width: 0),
                      labelStyle: theme.textTheme.labelSmall,
                    ),
                    primaryYAxis: NumericAxis(
                      majorGridLines: MajorGridLines(
                        width: 0.5,
                        color: theme.colorScheme.outlineVariant.withValues(
                          alpha: 0.4,
                        ),
                      ),
                      labelStyle: theme.textTheme.labelSmall,
                    ),
                    tooltipBehavior: TooltipBehavior(enable: true),
                    zoomPanBehavior: ZoomPanBehavior(
                      enablePanning: true,
                      enablePinching: true,
                      zoomMode: ZoomMode.x,
                    ),
                    series: <CartesianSeries<_ChartPoint, num>>[
                      SplineAreaSeries<_ChartPoint, num>(
                        dataSource: spots,
                        xValueMapper: (_ChartPoint point, _) => point.x,
                        yValueMapper: (_ChartPoint point, _) => point.y,
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                        borderColor: theme.colorScheme.primary,
                        borderWidth: 2,
                        markerSettings: const MarkerSettings(isVisible: false),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ChartPoint {
  final int x;
  final double y;

  const _ChartPoint(this.x, this.y);
}
