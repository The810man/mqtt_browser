import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../frontend/tree_node.dart';

part 'tree_service.g.dart';

@Riverpod(keepAlive: true)
class TreeService extends _$TreeService {
  @override
  Map<String, List<TreeNode>> build() {
    return {};
  }

  void addMessage(String topic, String payload) {
    List<String> topicList = topic.split("/");
    TreeNode? root = _findOrCreateRoot(topicList.first);

    TreeNode? parentNode = root;

    // Traverse the topic list to find or create the parent node
    for (int i = 0; i < topicList.length - 1; i++) {
      String label = topicList[i];
      TreeNode? existingChild = parentNode?.children.firstWhereOrNull((child) {
        return child.label != null && child.label == label;
      });
      // If the child does not exist, create it and add to parent
      if (existingChild == null && parentNode != null) {
        existingChild = TreeNode(label: label);
        parentNode.children.add(existingChild);
      }
      parentNode = existingChild;
    }

    // Add or update the new child node to the last parent node in the hierarchy
    String childLabel = topicList.last;
    TreeNode? existingChild = parentNode?.children.firstWhereOrNull((child) {
      return child.label != null && child.label == childLabel;
    });

    // If the child does not exist, create it and add to parent
    if (existingChild == null && parentNode != null) {
      existingChild = TreeNode(label: childLabel);
      parentNode.children.add(existingChild);
      existingChild.addMessage(payload);
    } else if (existingChild != null) {
      // If the child already exists, update it
      existingChild.label = childLabel;
      existingChild.addMessage(payload);
    }

    // Update state
    state = {...state};
  }

  TreeNode? _findOrCreateRoot(String rootLabel) {
    if (!state.containsKey(rootLabel) || state[rootLabel]!.isEmpty) {
      final root = TreeNode(label: rootLabel);
      state = {
        ...state,
        rootLabel: [root],
      };
      return root;
    }
    return state[rootLabel]!.first;
  }

  TreeNode? getRoot(String rootLabel) {
    return state[rootLabel]?.first;
  }

  List<TreeNode> getNodesForRoot(String rootLabel) {
    return state[rootLabel] ?? [];
  }
}
