// ignore_for_file: must_be_immutable

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_browser/main.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

final graphDataProvider = Provider((ref) => GraphData());

class GraphData {
  late List<DataPoint> data;

  void updateChart(
      String jsonData, List<String> historyList, String subValueKey) {
    data = [];

    // Function to extract sub-value from JSON object
    double extractSubValue(dynamic json) {
      try {
        if (json is Map<String, dynamic>) {
          return json[subValueKey];
        } else if (json is List<dynamic>) {
          // Handle list JSON structure, for example, take the first item
          if (json.isNotEmpty && json.first is Map<String, dynamic>) {
            return json.first[subValueKey];
          }
        }
      } catch (e) {
        // Handle error gracefully, return 0 or handle it as per requirement
        return 0;
      }
      return 0;
    }

    // Add current data to the graph
    dynamic parsedJson = jsonDecode(jsonData);
    extractSubValue(parsedJson);
    //data.add(DataPoint(0, input));
    if (historyList.contains("{}")) {
      historyList.remove(historyList[historyList.indexOf("{}")]);
    }

    // Add historical data to the graph
    for (int i = 0; i < historyList.length; i++) {
      try {
        dynamic history = jsonDecode(historyList[i]);
        double historyInput = extractSubValue(history);
        data.add(DataPoint(i + 1, historyInput));
      } catch (e) {
        continue;
      }

      //if (i >= 100) {
      //  data.removeAt(0);
      //}
    }
  }
}

class Testgraphviewpage extends ConsumerWidget {
  final String subValueKey;
  final String title;

  Testgraphviewpage(
      {super.key,
      required this.subValueKey,
      required this.title,
      required this.jsonData,
      required this.historyList});
  final jsonData;
  final historyList;
  late List<DataPoint> data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(changeIshappeningProvider);
    final graphData = ref.watch(graphDataProvider);
    graphData.updateChart(jsonData, historyList, subValueKey);

    return Scaffold(
      appBar: AppBar(
        title: Text('$title Graph View'),
      ),
      body: Center(
        child: SizedBox(
          height: 500,
          child: StatefulBuilder(builder: (context, setState) {
            return SfCartesianChart(
              zoomPanBehavior: ZoomPanBehavior(enableMouseWheelZooming: true),
              primaryXAxis: NumericAxis(),
              tooltipBehavior: TooltipBehavior(enable: true),
              series: <ChartSeries>[
                LineSeries<DataPoint, double>(
                  dataSource: graphData.data,
                  xValueMapper: (DataPoint point, _) => point.x,
                  yValueMapper: (DataPoint point, _) => point.y,
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class DataPoint {
  final double x;
  final double y;

  DataPoint(this.x, this.y);
}
