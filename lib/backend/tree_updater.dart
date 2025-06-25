import 'package:collection/collection.dart';
import 'package:mqtt_browser/frontend/tree_node.dart';
import 'package:mqtt_browser/main.dart';
import 'package:mqtt_client/mqtt_client.dart';

int timeSinceLastCall = 0;
Map<TreeNode, DateTime> nodeTimeMap = {};

add(String topic, String payload) async {
  List<String> topicList = topic.split("/");
  TreeNode? root = globalProviderContainer.read(rootProvider);
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

  if (existingChild != null) {
    for (var currentNode
        in globalProviderContainer.read(treeNodesProvider).keys) {
      var newState =
          globalProviderContainer.read(treeNodesProvider)[currentNode];
      if (newState != null) {
        newState.add(existingChild);
        globalProviderContainer
            .read(treeNodesProvider.notifier)
            .state[currentNode] = newState;
      }
    }
    rebuildAllControllers();
  }
}

rebuildAllControllers() async {
  for (var controller in globalProviderContainer.read(tabDataProvider).values) {
    controller.rebuild();
  }
}

void reciveStreams() {
  globalProviderContainer
      .read(clientProvider)!
      .updates!
      .listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
    final recMess = c![0].payload as MqttPublishMessage;
    final pt =
        MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
    add(c[0].topic, pt);
  });
}
