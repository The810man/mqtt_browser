class TreeNode {
  TreeNode({this.label});

  TreeNode? parent;
  String? label;
  List<String> history = [];
  int totalMessages = 0;
  List<TreeNode> children = [];

  int get messageCount {
    int count = totalMessages;
    for (var child in children) {
      count += child.messageCount;
    }
    return count;
  }

  void addMessage(String payload) {
    if (history.length >= 100) {
      history.removeAt(0);
    }
    history.add(payload);
    totalMessages++;
  }

  int get topicCount {
    int count = history.isNotEmpty ? 1 : 0;
    for (var child in children) {
      count += child.topicCount;
    }
    return count;
  }
}
