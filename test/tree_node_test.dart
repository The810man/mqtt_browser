import 'package:mqtt_browser/frontend/tree_node.dart';
import 'package:test/test.dart';

void main() {
  group("FastTreeNode", () {
    test("Single root with message test", () {
      final TreeNode testNode = TreeNode(label: "root")..addMessage("123");
      expect(testNode.messageCount, 1);
      expect(testNode.topicCount, 1);
      expect(testNode.parent, null);
      expect(testNode.label, "root");
      expect(testNode.history, ["123"]);
      expect(testNode.totalMessages, 1);
      expect(testNode.children.isEmpty, true);
    });
    test("Single child with message test", () {
      final TreeNode child1 = TreeNode(label: "child 1")..addMessage("123");
      final TreeNode testNode = TreeNode(label: "root")..children.add(child1);
      expect(testNode.messageCount, 1);
      expect(testNode.topicCount, 1);
      expect(child1.history, ["123"]);
      expect(testNode.history.isEmpty, true);
    });
    test("Single child with message and root with message test", () {
      final TreeNode child1 = TreeNode(label: "child 1")..addMessage("123");
      final TreeNode testNode = TreeNode(label: "root")
        ..addMessage("456")
        ..children.add(child1);
      expect(testNode.messageCount, 2);
      expect(testNode.topicCount, 2);
      expect(child1.totalMessages, 1);
      expect(child1.history.length, 1);
      expect(child1.history, ["123"]);
      expect(testNode.totalMessages, 1);
      expect(testNode.history.length, 1);
      expect(testNode.history, ["456"]);
    });
    test("Two child test", () {
      final TreeNode child1 = TreeNode(label: "child 1")..addMessage("123");
      final TreeNode child2 = TreeNode(label: "child 2")..addMessage("123");
      final TreeNode testNode = TreeNode(label: "root")
        ..children.addAll([child1, child2]);
      expect(testNode.messageCount, 2);
      expect(testNode.topicCount, 2);
      expect(testNode.history, []);
      expect(testNode.children, [child1, child2]);
    });
    test("Two child with history test", () {
      final TreeNode child1 = TreeNode(label: "child 1")..addMessage("123");
      final TreeNode child2 = TreeNode(label: "child 2")
        ..addMessage("2")
        ..addMessage("3")
        ..addMessage("123");
      final TreeNode testNode = TreeNode(label: "root")
        ..children.addAll([child1, child2]);
      expect(testNode.messageCount, 4);
      expect(testNode.topicCount, 2);
      expect(child2.history, ["2", "3", "123"]);
      expect(child1.history, ["123"]);
    });
    test("Two child test one empty node", () {
      final TreeNode child1 = TreeNode(label: "child 1")..addMessage("123");
      final TreeNode child2 = TreeNode(label: "child 2")..children.add(child1);
      final TreeNode testNode = TreeNode(label: "root")..children.add(child2);
      expect(testNode.messageCount, 1);
      expect(testNode.topicCount, 1);
      expect(child1.history, ["123"]);
      expect(child1.label, "child 1");
      expect(child2.children, [child1]);
      expect(testNode.children, [child2]);
    });
    test("Two child test with history", () {
      final TreeNode child1 = TreeNode(label: "child 1")
        ..addMessage("1")
        ..addMessage("2")
        ..addMessage("123");
      final TreeNode child2 = TreeNode(label: "child 2")..children.add(child1);
      final TreeNode testNode = TreeNode(label: "root")..children.add(child2);
      expect(testNode.messageCount, 3);
      expect(testNode.topicCount, 1);
      expect(child1.history, ["1", "2", "123"]);
      expect(child2.children, [child1]);
      expect(child2.history, []);
      expect(testNode.children, [child2]);
    });

    group("multi child test", () {
      TreeNode? currentParent;
      TreeNode? currentChild;
      final rootNode = TreeNode(label: "root");
      currentParent = rootNode;
      final List<TreeNode> nodes = [];
      nodes.add(rootNode);
      for (var i = 0; i < 30; i++) {
        if (i == 29 || i == 20) {
          currentChild = TreeNode(label: "$i")..addMessage("foo");
        } else {
          currentChild = TreeNode(label: "$i");
        }
        nodes.add(currentChild);
        currentParent?.children.add(currentChild);
        currentParent = currentChild;
      }
      test("test node-List length", () => expect(nodes.length, 31));
      test("test multi-node msg count", () => expect(rootNode.messageCount, 2));
      test("test multi-node topic Count", () => expect(rootNode.topicCount, 2));
    });
  });
}
