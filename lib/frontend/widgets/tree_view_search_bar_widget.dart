import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_browser/frontend/tree_node.dart';
import 'package:mqtt_browser/main.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

final class Treeviewsearchbar extends ConsumerWidget {
  Treeviewsearchbar(
      {super.key,
      required this.treeController,
      this.initialOpen,
      required this.rootNode});
  final bool? initialOpen;
  final TextEditingController textController = TextEditingController();
  final TreeController<TreeNode> treeController;
  final TreeNode rootNode;
  TreeSearchResult<TreeNode>? filter;
  Pattern? searchPattern;

  Iterable<TreeNode> getChildren(TreeNode node) {
    if (filter case TreeSearchResult<TreeNode> filter) {
      return node.children.where(filter.hasMatch);
    }
    return node.children;
  }

  void search(String query, WidgetRef ref) {
    // Needs to be reset before searching again, otherwise the tree controller
    // wouldn't reach some nodes because of the `getChildren()` impl above.
    filter = null;
    filter =
        treeController.search((TreeNode node) => node.label!.contains(query));

    var newRoots = getNodeList(filter!);
    if (newRoots == null) {
      treeController.roots = [];
    } else {
      treeController.roots = newRoots;
    }
    treeController.rebuild();
  }

  getNodeList(TreeSearchResult<TreeNode> filter) {
    List<TreeNode> outputList = [];
    for (var i in filter.matches.entries) {
      if (i.value.isDirectMatch == true) {
        outputList.add(i.key);
      }
    }
    return outputList;
  }

  void clearSearch(WidgetRef ref) {
    if (filter == null) return;
    filter = null;
    searchPattern = null;
    treeController.rebuild();
    textController.clear();
    treeController.roots = [ref.watch(treeNodesProvider)[rootNode.label]![0]];
  }

  Future<void> _exportTree(BuildContext context, WidgetRef ref) async {
    try {
      final treeData = _serializeTree(rootNode);
      final jsonString = jsonEncode(treeData);

      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'mqtt_tree_export_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(jsonString);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tree exported to ${file.path}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  Map<String, dynamic> _serializeTree(TreeNode node) {
    return {
      'label': node.label,
      'history': node.history,
      'totalMessages': node.totalMessages,
      'children': node.children.map(_serializeTree).toList(),
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(children: [
      IconButton(
        constraints: BoxConstraints(
            maxWidth: ref.watch(searchBarButtonProvider)!, minHeight: 30),
        icon: const Icon(
          Icons.manage_search_outlined,
          color: Colors.black,
        ),
        onPressed: () {
          ref.read(searchBarWidthProvider.notifier).state = 200;
          ref.read(searchBarButtonProvider.notifier).state = 0;
        },
      ),
      IconButton(
        constraints: const BoxConstraints(maxWidth: 50, minHeight: 30),
        icon: const Icon(
          Icons.download,
          color: Colors.black,
        ),
        onPressed: () => _exportTree(context, ref),
        tooltip: 'Export Tree to JSON',
      ),
      SearchBar(
        controller: textController,
        onChanged: (String value) {
          treeController.roots = [
            ref.watch(treeNodesProvider)[rootNode.label]![0]
          ];

          search(value, ref);
        },
        hintText: 'Type to Filter',
        leading: IconButton(
            onPressed: () {
              ref.read(searchBarWidthProvider.notifier).state = 0;
              ref.read(searchBarButtonProvider.notifier).state = 50;
              clearSearch(ref);
            },
            icon: const Icon(
              Icons.close,
              color: Colors.black,
            )),
        constraints: BoxConstraints(
            maxWidth: ref.watch(searchBarWidthProvider)!, minHeight: 50),
      ),
    ]);
  }
}
