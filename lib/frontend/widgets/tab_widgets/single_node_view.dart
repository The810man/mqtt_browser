import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_browser/main.dart';
import 'package:mqtt_browser/frontend/widgets/tiling.dart';
import 'package:mqtt_browser/frontend/widgets/tree_nodes_widget.dart';
import 'package:mqtt_browser/frontend/widgets/right_widget.dart';

class Singlenodeview extends ConsumerWidget {
  final textEditingController = TextEditingController();
  final List selectedList = [];
  final TextEditingController valueTextController = TextEditingController();
  final String newText = "";
  Singlenodeview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Tiling(
        rightWidget: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                  offset: const Offset(0, 4),
                  color: Theme.of(context).colorScheme.shadow,
                  spreadRadius: 3,
                  blurRadius: 5)
            ]),
            child: ValuesWidget(
              root: ref.watch(currentRootProvider),
            ),
          ),
        ),
        leftWidget: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Consumer(builder: (context, ref, child) {
              return Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                          offset: const Offset(0, 4),
                          color: Theme.of(context).colorScheme.shadow,
                          spreadRadius: 3,
                          blurRadius: 5)
                    ]),
                width: MediaQuery.of(context).size.width,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: FastTreeNodeView(
                      treeController: ref.watch(tabDataProvider)[
                          "${ref.watch(currentRootProvider).label}"]!,
                      nodes: ref.watch(treeNodesProvider)[
                          ref.watch(currentRootProvider).label]!),
                ),
              );
            })));
  }
}
