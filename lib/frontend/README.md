# lib/frontend/

All UI code. Purely reactive — reads providers, dispatches actions, renders state.

## Folder Structure

```bash
frontend/
├── pages/          Full-screen pages (routes)
│   └── README.md
├── widgets/        Reusable widgets
│   └── README.md
├── custom_json_view/  Self-contained JSON viewer component
└── tree_node.dart    TreeNode domain class (mutable, holds message history)
```

## tree_node.dart

`TreeNode` is the core domain object for the MQTT topic browser. It is intentionally mutable
(not freezed) because the tree accumulates messages incrementally from the MQTT stream.

```dart
class TreeNode {
  String label;       // Topic segment (non-nullable)
  TreeNode? parent;   // null for root nodes
  List<TreeNode> children;
  List<String> history;   // Last 100 messages for this topic
  int totalMessages;
}
```

Key computed properties:

- `message` — last received payload
- `messageCount` — recursive total across this subtree
- `topicCount` — count of leaf topics in subtree
- `getDepth()` — levels from root

## custom_json_view/

A standalone JSON viewer with custom color schemes, styling, and painters. Not intended to be
modified often — treat it as a package.

| Sub-folder | Contents |
|------------|----------|
| `models/` | `JsonColorScheme`, `JsonConfigData`, `JsonStyleScheme` |
| `painters/` | `ValueBackgroundPainter` |
| `widgets/` | View tiles: arrow, list, map, string, simple |
