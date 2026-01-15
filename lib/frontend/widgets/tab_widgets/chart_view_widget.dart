import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_browser/frontend/tree_node.dart';
import 'package:fl_chart/fl_chart.dart';

class ChartViewWidget extends ConsumerWidget {
  final TreeNode rootNode;

  const ChartViewWidget({super.key, required this.rootNode});

  List<FlSpot> _parseNumericHistory(List<String> history) {
    List<FlSpot> spots = [];
    for (int i = 0; i < history.length; i++) {
      try {
        double value = double.parse(history[i]);
        spots.add(FlSpot(i.toDouble(), value));
      } catch (e) {
        // Skip non-numeric values
      }
    }
    return spots;
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  node.label ?? 'Unknown Topic',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: true),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: Colors.blue,
                          barWidth: 2,
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.blue.withOpacity(0.1),
                          ),
                          dotData: FlDotData(show: false),
                        ),
                      ],
                    ),
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
