import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:json_view/json_view.dart';

class ArrowWidget extends StatelessWidget {
  final VoidCallback? onTap;
  final bool expanded;

  const ArrowWidget({
    super.key,
    this.onTap,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final JsonConfigData config = JsonConfig.of(context);
    final cs = config.color ?? JsonConfigData.defaultColor(context);
    Widget? arrow = const Icon(Icons.keyboard_arrow_right_rounded);
    arrow = IconTheme(
      data: IconThemeData(color: cs.normalColor, size: 16),
      child: arrow,
    );

    if (config.animation ?? JsonConfigData.kUseAnimation) {
      arrow = AnimatedRotation(
        turns: expanded ? .25 : 0,
        duration: config.animationDuration ?? JsonConfigData.kAnimationDuration,
        curve: config.animationCurve ?? JsonConfigData.kAnimationCurve,
        child: arrow,
      );
    } else {
      arrow = Transform.rotate(
        angle: expanded ? .25 * math.pi * 2.0 : 0,
        child: arrow,
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: arrow,
      ),
    );
  }
}
