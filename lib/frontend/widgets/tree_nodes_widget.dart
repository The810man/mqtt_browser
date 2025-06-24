import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mqtt_browser/frontend/tree_node.dart';
import 'package:mqtt_browser/main.dart';
import 'package:mqtt_browser/frontend/widgets/smooth_blinker/smooth_blink_widget.dart';

Provider<TreeEntry<TreeNode>> currentNodeProvider =
    Provider<TreeEntry<TreeNode>>(
        (ref) => throw StateError("no node selected"));

/// checks Changes
final Provider<String?> isBlinkingProvider = Provider<String?>((ref) =>
    ref.watch(currentNodeProvider).node.history.isEmpty
        ? ""
        : ref.watch(currentNodeProvider).node.history.last);

class FastTreeNodeView extends ConsumerWidget {
  const FastTreeNodeView({
    super.key,
    required this.nodes,
    required this.treeController,
  });
  final TreeController<TreeNode> treeController;
  final List<TreeNode> nodes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(changeIshappeningProvider);
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 9000,
          height: MediaQuery.of(context).size.height,
          child: TreeView<TreeNode>(
            shrinkWrap: true,
            treeController: treeController,
            nodeBuilder: (BuildContext context, TreeEntry<TreeNode> entry) {
              return ProviderScope(
                overrides: [currentNodeProvider.overrideWithValue(entry)],
                child: MyTreeTile(
                  treeController: treeController,
                  key: ValueKey(entry.node),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

makeStringFromList(List TopicList) {
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

makeParentsList(TreeNode InputNode, List OutputList) {
  if (!OutputList.contains(InputNode)) {
    if (InputNode == globalProviderContainer.read(rootProvider)) {
      return OutputList;
    }
    OutputList.add(InputNode);
  }
  if (InputNode.parent == null) {
    return OutputList;
  }
  if (InputNode.parent! == globalProviderContainer.read(rootProvider)) {
    return OutputList;
  }

  List newList = OutputList;
  newList.add(InputNode.parent);
  return makeParentsList(InputNode.parent!, newList);
}

void openNewTreeTab(TreeEntry<TreeNode> entry, WidgetRef ref) {
  List<TreeNode> newList = ref.read(tabListProvider).toList();
  newList.add(entry.node);
  ref.read(tabListProvider.notifier).state = newList;
  final newController = TreeController(
      roots: [entry.node], childrenProvider: (TreeNode node) => node.children);
  ref
      .read(tabDataProvider.notifier)
      .state
      .addAll({entry.node.label.toString(): newController});
  ref.read(selectedItemProvider).addAll({entry.node.label!: entry.node});
  final newTopicList = makeNewNodeList(
      ref.watch(treeNodesProvider)[ref.watch(currentRootProvider).label]!);
  ref
      .read(treeNodesProvider.notifier)
      .state
      .addAll({entry.node.label!: newTopicList});
}

makeNewNodeList(List<TreeNode> list) {
  final List<TreeNode> outputList = [];
  for (var elm in list) {
    outputList.add(elm);
  }
  return outputList;
}

void openNewGraphTab(TreeEntry<TreeNode> entry, WidgetRef ref, context) {}

void openNewListTab(TreeEntry<TreeNode> entry, WidgetRef ref) {}

class MyTreeTile extends ConsumerWidget {
  const MyTreeTile({
    super.key,
    required this.treeController,
  });
  final TreeController treeController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entry = ref.watch(currentNodeProvider);
    final nodeHistory = entry.node.history;
    void onTap() {
      List TopicList = makeParentsList(
          ref.read(selectedItemProvider)[ref.watch(currentRootProvider).label]!,
          []);
      if (ref
          .read(currentMessageProvider)
          .containsKey(ref.watch(currentRootProvider))) {
        ref.read(currentMessageProvider.notifier).state.addAll({
          ref.watch(currentRootProvider):
              entry.node.history.isEmpty ? "" : entry.node.history.last
        });
      } else {
        ref
                .read(currentMessageProvider.notifier)
                .state[ref.watch(currentRootProvider)] =
            entry.node.history.isEmpty ? "" : entry.node.history.last;
      }

      final newText = makeStringFromList(TopicList);
      ref.read(publishTextControllerProvider.notifier).state.text = newText;
      ref.read(changeIshappeningProvider.notifier).state =
          !ref.read(changeIshappeningProvider);
      treeController.toggleExpansion(entry.node);
      ref
          .read(selectedItemProvider.notifier)
          .state[ref.watch(currentRootProvider).label!] = entry.node;
    }

    return InkWell(
      onTap: onTap,
      child: TreeIndentation(
        entry: entry,
        guide: IndentGuide.connectingLines(
            indent: ref.watch(spaceSliderProvider),
            roundCorners: ref.watch(roundedLineSwitchProvider),
            connectBranches: ref.watch(connectLinesSwitchProvider),
            thickness: ref.watch(thicknessSliderProvider),
            origin: ref.watch(originSliderProvider)),
        child: Align(
          heightFactor: ref.watch(nodeHeightProvider),
          child: Row(children: [
            const SizedBox(
              width: 5,
            ),
            Align(
              widthFactor: 0.25,
              child: FolderButton(
                icon: const Icon(
                  Icons.linear_scale_rounded,
                  color: Colors.black,
                  size: 0,
                ),
                closedIcon: const Icon(Icons.arrow_right_rounded),
                openedIcon: const Icon(Icons.arrow_drop_down_rounded),
                isOpen: entry.hasChildren ? entry.isExpanded : null,
                onPressed: entry.hasChildren ? onTap : null,
              ),
            ),
            SmoothHighlight(
              duration: Duration(
                  milliseconds: ref.watch(blinkDurationProvider).toInt()),
              color: ref.watch(themeDataProvider).colorScheme.shadow,
              child: Container(
                  constraints: BoxConstraints(
                      maxHeight: ref.watch(nodeHeightProvider) * 30),
                  decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      border: Border.all(
                          color: ref.watch(selectedItemProvider)[
                                      ref.watch(currentRootProvider).label] ==
                                  ref.watch(currentNodeProvider)
                              ? const Color.fromARGB(255, 145, 145, 145)
                              : const Color.fromARGB(0, 145, 145, 145),
                          width: 2),
                      borderRadius: const BorderRadius.all(Radius.circular(5))),
                  child: Row(children: [
                    const SizedBox(
                      width: 5,
                    ),
                    Text(entry.node.children.isNotEmpty
                        ? "${entry.node.label.toString()} ${entry.isExpanded ? "${nodeHistory.isEmpty ? " " : " = "} ${nodeHistory.isEmpty ? "" : nodeHistory.last}" : "(${entry.node.messageCount} Messages | ${entry.node.topicCount} Topics)"}"
                        : "${entry.node.label} ${entry.node.history.isEmpty ? "" : " =  ${entry.node.history.last}"}"),
                    const SizedBox(
                      width: 5,
                    ),
                    PopupMenuButton(
                      itemBuilder: (BuildContext context) {
                        return [
                          PopupMenuItem(
                              onTap: () {
                                ref.read(tabLengthProvider.notifier).state += 1;

                                openNewTreeTab(entry, ref);
                              },
                              child: const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Open in Tree-View"),
                                  Icon(Icons.exit_to_app_rounded)
                                ],
                              )),
                          PopupMenuItem(
                              onTap: () => openNewListTab(entry, ref),
                              child: const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Open in List-view"),
                                  Icon(Icons.list_alt_rounded)
                                ],
                              )),
                        ];
                      },
                      icon: const Icon(Icons.menu),
                      iconSize: entry.node ==
                              ref
                                  .read(selectedItemProvider.notifier)
                                  .state[ref.watch(currentRootProvider).label!]!
                          ? ref.watch(nodeHeightProvider) * 15
                          : 0,
                      enabled: entry.node ==
                          ref
                              .read(selectedItemProvider.notifier)
                              .state[ref.watch(currentRootProvider).label!]!,
                    )
                  ])),
            ),
          ]),
        ),
      ),
    );
  }
}
