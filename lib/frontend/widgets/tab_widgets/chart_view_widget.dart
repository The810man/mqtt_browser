import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mqtt_browser/frontend/tree_node.dart';
import 'package:mqtt_browser/providers/providers.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

const _timeRanges = <String, Duration?>{
  'All time': null,
  'Last 1 min': Duration(minutes: 1),
  'Last 5 min': Duration(minutes: 5),
  'Last 15 min': Duration(minutes: 15),
  'Last 1 hour': Duration(hours: 1),
};

class ChartViewWidget extends HookConsumerWidget {
  final TreeNode rootNode;

  const ChartViewWidget({super.key, required this.rootNode});

  /// Recursively collects all leaf nodes that have at least one numeric value.
  List<_ChartSeries> _buildSeries(TreeNode node, TreeNode root) {
    final result = <_ChartSeries>[];
    if (node.children.isEmpty) {
      final points = _extractPoints(node);
      if (points.isNotEmpty) {
        result.add(_ChartSeries(
          label: _topicPath(node, root),
          points: points,
        ));
      }
    } else {
      for (final child in node.children) {
        result.addAll(_buildSeries(child, root));
      }
    }
    return result;
  }

  /// Tries to parse each history entry as a number, paired with the time it
  /// was received.
  /// For JSON payloads, extracts all top-level numeric fields.
  List<_Point> _extractPoints(TreeNode node) {
    final points = <_Point>[];
    final history = node.history;
    final timestamps = node.historyTimestamps;
    for (int i = 0; i < history.length; i++) {
      final raw = history[i].trim();
      final time = i < timestamps.length ? timestamps[i] : DateTime.now();

      // Plain number
      final d = double.tryParse(raw);
      if (d != null) {
        points.add(_Point(time, d));
        continue;
      }

      // JSON object — extract first numeric field value
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          for (final v in decoded.values) {
            final n = (v is num) ? v.toDouble() : double.tryParse('$v');
            if (n != null) {
              points.add(_Point(time, n));
              break;
            }
          }
        } else if (decoded is num) {
          points.add(_Point(time, decoded.toDouble()));
        }
      } catch (_) {}
    }
    return points;
  }

  String _topicPath(TreeNode node, TreeNode root) {
    final segments = <String>[];
    TreeNode? cur = node;
    while (cur != null && cur != root) {
      segments.add(cur.label);
      cur = cur.parent;
    }
    final path = segments.reversed.join('/');
    return path.isEmpty ? node.label : path;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final live = useState(true);
    final frozen = useState<List<_ChartSeries>?>(null);
    final rangeLabel = useState('All time');

    // Only track live MQTT updates while in live mode — pausing freezes the
    // widget on whatever was last captured instead of continuing to rebuild.
    if (live.value) {
      ref.watch(treeNodesProvider);
    }

    final liveSeries = _buildSeries(rootNode, rootNode);
    final series = live.value ? liveSeries : (frozen.value ?? liveSeries);

    final cutoff = _timeRanges[rangeLabel.value] == null
        ? null
        : DateTime.now().subtract(_timeRanges[rangeLabel.value]!);

    final visibleSeries = [
      for (final s in series)
        _ChartSeries(
          label: s.label,
          points: cutoff == null
              ? s.points
              : s.points.where((p) => p.time.isAfter(cutoff)).toList(),
        ),
    ].where((s) => s.points.isNotEmpty).toList();

    final theme = Theme.of(context);

    return Column(
      children: [
        _ControlBar(
          live: live.value,
          rangeLabel: rangeLabel.value,
          onRangeChanged: (v) => rangeLabel.value = v,
          onLiveChanged: (v) {
            frozen.value = v ? null : _buildSeries(rootNode, rootNode);
            live.value = v;
          },
        ),
        Expanded(
          child: visibleSeries.isEmpty
              ? _emptyState(theme)
              : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: visibleSeries.length,
                  itemBuilder: (context, index) =>
                      _SeriesCard(series: visibleSeries[index], theme: theme),
                ),
        ),
      ],
    );
  }

  Widget _emptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.show_chart_rounded,
            size: 48,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 12),
          Text(
            'No numeric data yet.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Charts appear when topics receive numeric values.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlBar extends StatelessWidget {
  final bool live;
  final String rangeLabel;
  final ValueChanged<String> onRangeChanged;
  final ValueChanged<bool> onLiveChanged;

  const _ControlBar({
    required this.live,
    required this.rangeLabel,
    required this.onRangeChanged,
    required this.onLiveChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      child: Row(
        children: [
          Icon(Icons.show_chart_rounded, size: 18, color: cs.primary),
          const SizedBox(width: 6),
          Text(
            'Graphs',
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          DropdownButton<String>(
            value: rangeLabel,
            underline: const SizedBox(),
            items: [
              for (final label in _timeRanges.keys)
                DropdownMenuItem(value: label, child: Text(label)),
            ],
            onChanged: (v) {
              if (v != null) onRangeChanged(v);
            },
          ),
          const SizedBox(width: 12),
          Icon(
            live ? Icons.podcasts_rounded : Icons.pause_circle_outline_rounded,
            size: 16,
            color: live ? Colors.greenAccent.shade700 : cs.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 4),
          Text(
            live ? 'Live' : 'Paused',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          Switch(value: live, onChanged: onLiveChanged),
        ],
      ),
    );
  }
}

class _SeriesCard extends StatelessWidget {
  final _ChartSeries series;
  final ThemeData theme;

  const _SeriesCard({required this.series, required this.theme});

  @override
  Widget build(BuildContext context) {
    final latestValue = series.points.last.y;
    final minY = series.points.map((p) => p.y).reduce((a, b) => a < b ? a : b);
    final maxY = series.points.map((p) => p.y).reduce((a, b) => a > b ? a : b);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: theme.colorScheme.surface.withValues(alpha: 0.95),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    series.label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  latestValue.toStringAsFixed(
                    latestValue == latestValue.roundToDouble() ? 0 : 2,
                  ),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  '${series.points.length} samples',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                  ),
                ),
                const Spacer(),
                Text(
                  'min ${minY.toStringAsFixed(2)}  max ${maxY.toStringAsFixed(2)}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 180,
              child: SfCartesianChart(
                backgroundColor: Colors.transparent,
                plotAreaBorderWidth: 0,
                margin: EdgeInsets.zero,
                primaryXAxis: DateTimeAxis(
                  majorGridLines: const MajorGridLines(width: 0),
                  labelStyle: theme.textTheme.labelSmall,
                ),
                primaryYAxis: NumericAxis(
                  majorGridLines: MajorGridLines(
                    width: 0.5,
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
                  ),
                  labelStyle: theme.textTheme.labelSmall,
                ),
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                  header: series.label,
                  format: 'point.x : point.y',
                ),
                zoomPanBehavior: ZoomPanBehavior(
                  enablePanning: true,
                  enablePinching: true,
                  zoomMode: ZoomMode.x,
                ),
                series: <CartesianSeries<_Point, DateTime>>[
                  SplineAreaSeries<_Point, DateTime>(
                    dataSource: series.points,
                    xValueMapper: (p, _) => p.time,
                    yValueMapper: (p, _) => p.y,
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    borderColor: theme.colorScheme.primary,
                    borderWidth: 2,
                    splineType: SplineType.monotonic,
                    markerSettings: MarkerSettings(
                      isVisible: series.points.length <= 30,
                      color: theme.colorScheme.primary,
                      borderWidth: 0,
                      height: 5,
                      width: 5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartSeries {
  final String label;
  final List<_Point> points;
  const _ChartSeries({required this.label, required this.points});
}

class _Point {
  final DateTime time;
  final double y;
  const _Point(this.time, this.y);
}
