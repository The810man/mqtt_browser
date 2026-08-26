# lib/frontend/widgets/

All reusable and page-level widgets.

## Folder Structure

```
widgets/
├── reactive_widgets/         Stateful widgets that own form fields and interact with providers
│   ├── setup_widget.dart     Responsive layout: ConnectionsWidget + SetupSettings side-by-side or stacked
│   ├── connections_widget.dart  Saved-connections list with edit/delete dialogs
│   └── settings_widget.dart  MQTT connection form (host, port, credentials, subscriptions)
│
├── tab_widgets/              Content views rendered inside each browser tab
│   ├── tab_widget.dart       Tab bar item widget
│   ├── tree_tab_widget.dart  Tab label chip widget
│   ├── single_node_view.dart View for a single selected topic node
│   ├── chart_view_widget.dart  Time-series chart for a topic
│   ├── grid_view_widget.dart   Grid layout view
│   ├── list_view_widget.dart   Flat list view
│   └── mindmap_view_widget.dart  Mind-map style view
│
├── smooth_blinker/           Blink animation for updated nodes
│   ├── smooth_blink_widget.dart
│   └── smooth_blink_widget.g.dart  (generated)
│
├── custom_painters/          Custom drawing widgets
│   ├── line_with_streak_painter.dart  CustomPainter for animated line
│   └── custom_painter_widgets/
│       └── line_with_streak_widget.dart
│
├── tree_nodes_widget.dart    FastTreeNodeView + MyTreeTile — the core tree rendering
├── right_widget.dart         ValuesWidget — topic details panel (topic path, value, publish)
├── sidebar_widget.dart       Drawer with tree-view appearance settings (sliders, toggles)
├── main_app_bar.dart         (unused/legacy)
├── modern_ui_components.dart  Shared styled components
├── mqtt_background_grid_icons.dart  Custom font icon class
├── publish_widget.dart       Simple publish form (legacy)
├── enhanced_publish_widget.dart  Full publish form with format/QoS/retain
├── simple_line_chart.dart    Thin wrapper around fl_chart
├── tiled_background.dart     Animated background grid for setup page
├── tiling.dart               Two-panel horizontal layout widget
└── tree_view_search_bar_widget.dart  Search bar for the topic tree
```

## Key Widgets

### tree_nodes_widget.dart
- `FastTreeNodeView` — renders the full tree using `flutter_fancy_tree_view`
- `MyTreeTile` — individual node row: expand arrow, label, value preview, context menu
- Context menu opens new tabs: Tree, List, Mindmap, Grid, Graph views

### sidebar_widget.dart
- `Sidebarwidget` — SidebarX drawer with tree appearance sliders and toggles
- Persists all values to SharedPreferences immediately on change

### right_widget.dart
- `ValuesWidget` — shows selected topic path, raw value (with JSON viewer), and publish form
