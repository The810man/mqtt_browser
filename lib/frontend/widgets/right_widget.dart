import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_browser/frontend/tree_node.dart';
import 'package:mqtt_browser/frontend/widgets/publish_widget.dart';
import 'package:mqtt_browser/main.dart';
import 'package:json_view/json_view.dart';
import 'package:mqtt_browser/frontend/custom_json_view/custom_json_view.dart';
import 'dart:convert';
import 'package:expandable_widgets/expandable_widgets.dart';
import 'custom_expandable_widget.dart';
import 'package:flutter/services.dart';

class ValuesWidget extends ConsumerWidget {
  final TextSelectionControls TextSelectors = DesktopTextSelectionControls();
  ValuesWidget({super.key, required this.root});
  final TreeNode root;

  bool isJSON(str) {
    try {
      json.decode(str);
    } catch (e) {
      return false;
    }
    return true;
  }

  makeStringFromList(List TopicList, WidgetRef ref) {
    String OutputString = "";
    for (var topic in TopicList.reversed) {
      if (OutputString == "") {
        OutputString = "${topic.label}";
      } else {
        OutputString = "$OutputString/${topic.label}";
      }
    }
    return OutputString;
  }

  makeParentsList(
      TreeNode InputNode, List<TreeNode> OutputList, WidgetRef ref) {
    if (!OutputList.contains(InputNode)) {
      if (InputNode == ref.watch(currentRootProvider)) {
        return OutputList;
      }
      OutputList.add(InputNode);
    }
    if (InputNode.parent == null) {
      return OutputList;
    }
    if (InputNode.parent! == ref.watch(currentRootProvider)) {
      return OutputList;
    }

    List<TreeNode> newList = OutputList;
    newList.add(InputNode.parent!);
    return makeParentsList(InputNode.parent!, newList, ref);
  }

  void removeTopic(WidgetRef ref, List<TreeNode> nodes) {
    final newState = ref.read(treeNodesProvider.notifier).state;
    for (TreeNode node in nodes) {
      newState.remove(nodes);
    }
    ref.read(treeNodesProvider.notifier).state = newState;
    ref
        .read(tabDataProvider)["${ref.watch(currentRootProvider).label}"]!
        .rebuild();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(changeIshappeningProvider);
    ref.watch(selectedItemProvider);
    List<TreeNode> topicsList = makeParentsList(
        ref.watch(selectedItemProvider)[ref.watch(currentRootProvider).label]!,
        [],
        ref);
    String topicsString = makeStringFromList(topicsList, ref);
    final currentHistory = ref
        .watch(treeNodesProvider)[ref.watch(currentRootProvider).label]![ref
            .watch(treeNodesProvider)[ref.watch(currentRootProvider).label]!
            .indexOf(ref.watch(
                selectedItemProvider)[ref.watch(currentRootProvider).label]!)]
        .history;
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomExpandable(
              backgroundColor: Theme.of(context).colorScheme.background,
              boxShadow: [
                BoxShadow(
                    offset: const Offset(0, 4),
                    spreadRadius: 3,
                    blurRadius: 5,
                    color: Theme.of(context).colorScheme.shadow)
              ],
              initiallyExpanded: true,
              arrowLocation: ArrowLocation.right,
              centralizeFirstChild: false,
              firstChild: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Topic"),
                  ),
                  Transform.scale(
                    scale: 0.8,
                    child: IconButton(
                        onPressed: () async {
                          await Clipboard.setData(
                              ClipboardData(text: topicsString));
                        },
                        icon: const Icon(Icons.file_copy)),
                  ),
                  Transform.scale(
                    scale: 0.9,
                    child: IconButton(
                        onPressed: () {
                          removeTopic(ref, topicsList);
                        },
                        icon: const Icon(Icons.restore_from_trash_rounded)),
                  ),
                ],
              ),
              secondChild: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SelectableText(topicsString,
                        selectionControls: TextSelectors),
                    Wrap(
                      direction: Axis.horizontal,
                      alignment: WrapAlignment.start,
                      children: topicsList.reversed
                          .map((topic) => Container(
                                margin: const EdgeInsets.all(
                                    0), // Adjust the margin as needed

                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 3, 0,
                                      3), // Adjust the padding as needed
                                  child: Wrap(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(5)),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(topic.label!),
                                        ),
                                      ),
                                      Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: topicsList.first != topic
                                              ? const Text("/")
                                              : const Text(""))
                                    ],
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomExpandable(
              backgroundColor: Theme.of(context).colorScheme.background,
              boxShadow: [
                BoxShadow(
                    offset: const Offset(0, 4),
                    spreadRadius: 3,
                    blurRadius: 5,
                    color: Theme.of(context).colorScheme.shadow)
              ],
              initiallyExpanded: true,
              centralizeFirstChild: false,
              firstChild: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Value",
                    ),
                    Transform.scale(
                      scale: 0.8,
                      child: IconButton(
                          onPressed: () async {
                            await Clipboard.setData(ClipboardData(
                                text: ref
                                    .watch(selectedItemProvider)[
                                        ref.watch(currentRootProvider).label]!
                                    .history
                                    .last));
                          },
                          icon: const Icon(Icons.file_copy)),
                    ),
                  ],
                ),
              ),
              secondChild: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      child: Column(children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: 250,
                        child: TextField(
                          controller: TextEditingController(
                              text: ref
                                      .watch(selectedItemProvider)[
                                          ref.watch(currentRootProvider).label]!
                                      .history
                                      .isEmpty
                                  ? "---"
                                  : ref
                                      .watch(selectedItemProvider)[
                                          ref.watch(currentRootProvider).label]!
                                      .history
                                      .last),
                          minLines: null,
                          maxLines: null,
                          expands: true,
                          readOnly: true,
                        ),
                      ),
                    ),
                  ])),
                  JsonConfig(

                      /// your customize configuration
                      data: JsonConfigData(
                          animation: true,
                          animationDuration: const Duration(milliseconds: 300),
                          animationCurve: Curves.ease,
                          itemPadding: const EdgeInsets.only(left: 8),
                          style: const JsonStyleScheme(
                            arrow: Icon(Icons.arrow_right),
                          )),
                      child: SizedBox(
                        child: CustomJsonView(
                            arrow: const Icon(Icons.abc_rounded),
                            shrinkWrap: true,
                            json: isJSON(currentHistory.isEmpty ? {} : currentHistory.last)
                                ? json.decode(ref
                                    .watch(treeNodesProvider)[ref.watch(currentRootProvider).label]![ref
                                        .watch(treeNodesProvider)[ref
                                            .watch(currentRootProvider)
                                            .label]!
                                        .indexOf(
                                            ref.watch(selectedItemProvider)[ref
                                                .watch(currentRootProvider)
                                                .label]!)]
                                    .history
                                    .last)
                                : ref.watch(selectedItemProvider)[ref.watch(currentRootProvider).label]),
                      )),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomExpandable(
                backgroundColor: Theme.of(context).colorScheme.background,
                boxShadow: [
                  BoxShadow(
                      offset: const Offset(0, 4),
                      spreadRadius: 3,
                      blurRadius: 5,
                      color: Theme.of(context).colorScheme.shadow)
                ],
                initiallyExpanded: true,
                centralizeFirstChild: false,
                firstChild: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Publish"),
                ),
                secondChild: PublishWidget(
                  root: ref.watch(currentRootProvider),
                )),
          )
        ],
      ),
    );
  }
}
