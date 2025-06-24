import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mqtt_browser/frontend/tree_node.dart';
import 'package:mqtt_browser/frontend/widgets/tree_nodes_widget.dart';
import 'package:mqtt_browser/main.dart';

final blinkTimeProvider = StateProvider<Map<TreeNode?, DateTime?>>((ref) {
  return {};
});

class SmoothHighlight extends HookConsumerWidget {
  const SmoothHighlight({
    super.key,
    required this.child,
    required this.color,
    required this.duration,
    this.useInitialHighLight = false,
    this.padding = EdgeInsets.zero,
  });

  /// Highlight target widget.
  ///
  /// If child has no size, it will be nothing happened.
  final Widget child;

  /// The highlight color.
  final Color color;

  /// Simple Duration for Blinking nodes
  ///
  /// Needs to be set by the Duration of the Duration Provider
  final Duration duration;

  /// Whether this highlight works also in initState phase.
  ///
  /// If true, the highlight will be applied to the child in initState phase. default to false.
  final bool useInitialHighLight;

  /// The padding of the highlight.
  final EdgeInsets padding;

  validateNode(WidgetRef ref) {
    TreeNode node = ref.watch(currentNodeProvider).node;
    Map<TreeNode?, DateTime?> nodeTimeMap = ref.watch(blinkTimeProvider);
    if (nodeTimeMap.isEmpty) {
      nodeTimeMap.addAll({node: DateTime.now()});
      ref.read(blinkTimeProvider.notifier).state = nodeTimeMap;
      return true;
    } else if (nodeTimeMap.containsKey(node) &&
        (DateTime.now().difference(nodeTimeMap[node]!).inMilliseconds >=
            ref.watch(blinkDelayProvider))) {
      nodeTimeMap[node] = DateTime.now();
      ref.read(blinkTimeProvider.notifier).state = nodeTimeMap;
      return true;
    } else if (nodeTimeMap.containsKey(node) == false) {
      nodeTimeMap.addAll({node: DateTime.now()});
      ref.read(blinkTimeProvider.notifier).state = nodeTimeMap;
      return true;
    }
    ref.read(blinkTimeProvider.notifier).state = nodeTimeMap;
    return false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animationController = useAnimationController(duration: duration);
    useEffect(() {
      if (animationController.status == AnimationStatus.completed) {
        Timer(Duration(milliseconds: ref.watch(blinkDelayProvider).toInt()),
            () {
          animationController.forward();
        });
      } else if (animationController.status == AnimationStatus.dismissed) {
        Timer(Duration(milliseconds: ref.watch(blinkDelayProvider).toInt()),
            () {
          animationController.forward();
        });
      }

      return null;
    }, [ref.watch(currentNodeProvider).node.messageCount]);
    final Animation<Decoration> startAnimation = animationController
        .drive(
          CurveTween(curve: Curves.easeInOut),
        )
        .drive(DecorationTween(
          begin: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.transparent,
                spreadRadius: 0,
                blurRadius: 3,
              ),
            ],
          ),
          end: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color,
            ),
            boxShadow: [
              BoxShadow(
                color: color,
                spreadRadius: 0,
                blurRadius: 3,
              ),
            ],
          ),
        ))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          animationController.reverse();
        }
      });

    return DecoratedBoxTransition(
      decoration: startAnimation,
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}
