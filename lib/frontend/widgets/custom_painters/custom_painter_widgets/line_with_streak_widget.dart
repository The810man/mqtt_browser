import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mqtt_browser/frontend/widgets/custom_painters/line_with_streak_painter.dart';

class LineWithStreakWidget extends HookConsumerWidget {
  const LineWithStreakWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final tenController =
        useAnimationController(duration: const Duration(seconds: 3));
    final canAppere = useState(false);

    final controller =
        useAnimationController(duration: const Duration(seconds: 8))
          ..forward().then((v) {
            tenController.forward();
            canAppere.value = true;
          });

    final eightAnimation =
        CurvedAnimation(parent: controller, curve: Curves.easeInOut);

    final rotaionAnimation = Tween<double>(begin: 0, end: 0.25)
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    final sizeAnimation = Tween<double>(begin: 1, end: 0.3)
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    final textWidth = 400; // Approximate width of "1 0" at fontSize 80
    final textHeight = 400; // Approximate height at fontSize 80

    final rectAnimation = RelativeRectTween(
      begin: RelativeRect.fromLTRB(
        (width - textWidth) / 2,
        (height - textHeight) / 2,
        (width - textWidth) / 2,
        (height - textHeight) / 2,
      ),
      end: RelativeRect.fromLTRB(
        (width - textWidth) / 2 + 280, // Move 40 pixels to the right
        (height - textHeight) / 2,
        (width - textWidth) / 2 - 280, // Adjust right to keep width constant
        (height - textHeight) / 2,
      ),
    ).animate(CurvedAnimation(parent: tenController, curve: Curves.easeIn));

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PositionedTransition(
              rect: rectAnimation,
              child: Text("10",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 260,
                    fontWeight: FontWeight.w700,
                  ))),
          ScaleTransition(
            scale: sizeAnimation,
            child: RotationTransition(
              turns: rotaionAnimation,
              child: AnimatedContainer(
                duration: const Duration(seconds: 3),
                color: canAppere.value ? Colors.transparent : Colors.black,
                child: Stack(
                  children: [
                    CustomPaint(
                      size: Size(width, height), // Setze die Größe des Widgets
                      painter: LineWithStreakPainter(animation: eightAnimation),
                    ),
                    Transform.flip(
                      flipY: true,
                      child: CustomPaint(
                        size:
                            Size(width, height), // Setze die Größe des Widgets
                        painter:
                            LineWithStreakPainter(animation: eightAnimation),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
