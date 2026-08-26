import 'package:mqtt_browser/constants.dart';

class TreeNode {
  TreeNode({required this.label, this.parent});

  String label;
  TreeNode? parent;
  List<TreeNode> children = [];
  List<String> history = [];
  List<DateTime> historyTimestamps = [];
  int totalMessages = 0;

  String? get message => history.isNotEmpty ? history.last : null;

  /// Full MQTT topic path from the connection root (exclusive) to this node.
  String get fullTopicPath {
    final segments = <String>[];
    TreeNode? cur = this;
    while (cur != null && cur.parent != null) {
      segments.add(cur.label);
      cur = cur.parent;
    }
    return segments.reversed.join('/');
  }

  int get messageCount {
    var count = totalMessages;
    for (final child in children) {
      count += child.messageCount;
    }
    return count;
  }

  int get topicCount {
    var count = history.isNotEmpty ? 1 : 0;
    for (final child in children) {
      count += child.topicCount;
    }
    return count;
  }

  int get depth {
    var d = 0;
    var current = parent;
    while (current != null) {
      d++;
      current = current.parent;
    }
    return d;
  }

  void addMessage(String payload) {
    if (history.length >= AppConstants.maxMessageHistory) {
      history.removeAt(0);
      if (historyTimestamps.isNotEmpty) historyTimestamps.removeAt(0);
    }
    history.add(payload);
    historyTimestamps.add(DateTime.now());
    totalMessages++;
  }

  @override
  String toString() => 'TreeNode($label)';
}
