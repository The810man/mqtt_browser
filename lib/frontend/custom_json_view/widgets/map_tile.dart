import 'package:flutter/material.dart';

import '../models/json_config_data.dart';
import 'json_config.dart';
import 'json_view.dart';
import 'simple_tiles.dart';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter/material.dart';

import '../models/json_config_data.dart';
import 'json_config.dart';
import 'json_view.dart';
import 'simple_tiles.dart';

class MapTile extends HookWidget {
  final String keyName;
  final List<MapEntry> items;
  final bool expanded;
  final int depth;

  const MapTile({
    super.key,
    required this.keyName,
    required this.items,
    this.expanded = false,
    required this.depth,
  });

  String getValue(bool expanded) {
    if (items.isEmpty) return '{}';
    if (expanded) return '';
    return '{ ... }';
  }

  @override
  Widget build(BuildContext context) {
    final expanded = useState(false);
    final init = useState(false);

    void changeState() {
      if (items.isNotEmpty) {
        expanded.value = !expanded.value;
      }
    }

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
          onTap: changeState,
          expanded: expanded.value,
          showLeading: items.isNotEmpty,
        ),
        if (expanded.value)
          Padding(
            padding: jsonConfig.itemPadding ?? const EdgeInsets.only(left: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items.map((item) {
                return getParsedItem(
                  key: item.key,
                  value: item.value,
                  depth: depth + 1,
                );
              }).toList(),
            ),
          ),
      ],
    );

    if (jsonConfig.animation ?? JsonConfigData.kUseAnimation) {
      result = AnimatedSize(
        alignment: Alignment.topCenter,
        duration:
            JsonConfig.of(context).animationDuration ??
            const Duration(milliseconds: 300),
        curve: JsonConfig.of(context).animationCurve ?? Curves.ease,
        child: result,
      );
    }

    return result;
  }
}
