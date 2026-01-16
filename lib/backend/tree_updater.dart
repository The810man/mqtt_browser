import 'package:collection/collection.dart';
import 'package:mqtt5_client/mqtt5_client.dart';
import 'package:mqtt_browser/frontend/tree_node.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:mqtt_browser/main.dart';
import 'package:mqtt_browser/providers/providers.dart';

int timeSinceLastCall = 0;
Map<TreeNode, DateTime> nodeTimeMap = {};

void _ensureRootTabInitialized() {
  final rootNode = globalProviderContainer.read(rootProvider);
  final tabList = globalProviderContainer.read(tabListProvider);
  if (tabList.isEmpty) {
    globalProviderContainer.read(tabListProvider.notifier).state = [rootNode];
    globalProviderContainer.read(tabLengthProvider.notifier).state = 1;
    globalProviderContainer.read(currentRootProvider.notifier).state = rootNode;
  }

  final treeNodes = globalProviderContainer.read(treeNodesProvider);
  if (rootNode.label != null && !treeNodes.containsKey(rootNode.label)) {
    globalProviderContainer.read(treeNodesProvider.notifier).state = {
      ...treeNodes,
      rootNode.label!: [rootNode],
    };
  }

  final tabData = globalProviderContainer.read(tabDataProvider);
  if (rootNode.label != null && !tabData.containsKey(rootNode.label)) {
    final controller = TreeController<TreeNode>(
      roots: [rootNode],
      childrenProvider: (TreeNode node) => node.children,
    );
    globalProviderContainer.read(tabDataProvider.notifier).state = {
      ...tabData,
      rootNode.label!: {'controller': controller, 'viewType': 'tree'},
    };
  }
}

Future<void> add(String topic, String payload) async {
  try {
    _ensureRootTabInitialized();
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
        existingChild.parent = parentNode;
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
      existingChild.parent = parentNode;
      parentNode.children.add(existingChild);
      existingChild.addMessage(payload);
    } else if (existingChild != null) {
      // If the child already exists, update it
      existingChild.label = childLabel;
      existingChild.addMessage(payload);
    }

    if (existingChild != null) {
      final treeNodes = globalProviderContainer.read(treeNodesProvider);
      final updatedTreeNodes = <String, List<TreeNode>>{
        for (final entry in treeNodes.entries)
          entry.key: List<TreeNode>.from(entry.value),
      };
      for (final currentNode in updatedTreeNodes.keys) {
        updatedTreeNodes[currentNode]?.add(existingChild);
      }
      globalProviderContainer.read(treeNodesProvider.notifier).state =
          updatedTreeNodes;
      rebuildAllControllers();
    }
  } catch (e) {
    print('Error updating tree: $e');
  }
}

Future<void> rebuildAllControllers() async {
  for (var entry in globalProviderContainer.read(tabDataProvider).entries) {
    entry.value['controller']?.rebuild();
  }
}

void reciveStreams(MqttClient client, {int attempt = 0}) {
  try {
    final updates = client.updates;

    updates.listen((List<MqttReceivedMessage<MqttMessage?>>? messages) {
      if (messages == null || messages.isEmpty) {
        return;
      }
      try {
        for (final message in messages) {
          final recMess = message.payload as MqttPublishMessage;
          final pt = MqttUtilities.bytesToStringAsString(
            recMess.payload.message!,
          );
          final topic = message.topic;
          if (topic != null) {
            add(topic, pt);
          }
        }
      } catch (e) {
        print('Error processing MQTT message: $e');
      }
    });
  } catch (e) {
    print('Error setting up MQTT stream listener: $e');
  }
}
