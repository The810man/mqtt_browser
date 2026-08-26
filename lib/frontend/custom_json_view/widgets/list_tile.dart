import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter/material.dart';

import '../models/json_config_data.dart';
import 'json_config.dart';
import 'json_view.dart';
import 'simple_tiles.dart';

class IndexRange {
  final int start;
  final int end;
  IndexRange({required this.start, required this.end});

  int get length => end - start;
}

class ListTile extends HookWidget {
  final String keyName;
  final List items;
  final IndexRange range;
  final bool expanded;
  final int depth;

  const ListTile({
    super.key,
    required this.keyName,
    required this.items,
    required this.range,
    this.expanded = false,
    required this.depth,
  });

  String getValue(bool expanded) {
    if (items.isEmpty) return '[]';
    if (expanded) return '';
    if (items.length == 1) return '[0]';
    if (items.length == 2) return '[0,1]';
    return '[${range.start} ... ${range.end}]';
  }

  void changeState(ValueNotifier<bool> expanded) {
    if (items.isNotEmpty) {
      expanded.value = !expanded.value;
    }
  }

  int gap(BuildContext context) =>
      JsonConfig.of(context).gap ?? JsonConfigData.kGap;

  List<Widget> children(BuildContext context) {
    if (items.isEmpty) return [];
    if (range.length < gap(context)) {
      final result = <Widget>[];
      for (var i = 0; i <= range.length; i++) {
        result.add(
          getIndexedItem(
            index: i,
            value: items[i + range.start],
            depth: depth + 1,
          ),
        );
      }
      return result;
    }
    return gapChildren(context);
  }

  List<Widget> gapChildren(BuildContext context) {
    int currentGap = gap(context);
    while (range.length / currentGap > gap(context)) {
      currentGap *= gap(context);
    }
    int divide = range.length ~/ currentGap;
    int dividedLength = currentGap * divide;
    late int gapSize;
    if (dividedLength == items.length) {
      gapSize = divide;
    } else {
      gapSize = divide + 1;
    }
    final result = <Widget>[];
    for (var i = 0; i < gapSize; i++) {
      int startIndex = range.start + i * currentGap;
      int endIndex = range.end;
      if (i != gapSize - 1) {
        result.add(
          ListTile(
            keyName: '[$i]',
            items: items,
            range: IndexRange(
              start: startIndex,
              end: startIndex + currentGap - 1,
            ),
            expanded: expanded,
            depth: depth + 1,
          ),
        );
      } else {
        result.add(
          ListTile(
            keyName: '[$i]',
            items: items,
            range: IndexRange(start: startIndex, end: endIndex),
            expanded: expanded,
            depth: depth + 1,
          ),
        );
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final expanded = useState(false);
    final init = useState(false);

    useEffect(() {
      if (!init.value) {
        init.value = true;
        final jsonConfig = JsonConfig.of(context);
        expanded.value = jsonConfig.style?.openAtStart ?? false;
        final int depthVal = jsonConfig.style?.depth ?? 0;
        if (depthVal > 0) {
          expanded.value = depthVal > depth;
        }
      }
      return null;
    }, []);

    final jsonConfig = JsonConfig.of(context);

    Widget result = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MapListTile(
          keyName: keyName,
          value: getValue(expanded.value),
          onTap: () => changeState(expanded),
          expanded: expanded.value,
          showLeading: items.isNotEmpty,
        ),
        if (expanded.value)
          Padding(
            padding: jsonConfig.itemPadding ?? const EdgeInsets.only(left: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children(context),
            ),
          ),
      ],
    );

    if (jsonConfig.animation ?? JsonConfigData.kUseAnimation) {
      result = AnimatedSize(
        alignment: Alignment.topCenter,
        duration:
            jsonConfig.animationDuration ?? const Duration(milliseconds: 300),
        curve: jsonConfig.animationCurve ?? Curves.ease,
        child: result,
      );
    }

    return result;
  }
}
