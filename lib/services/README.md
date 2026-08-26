# lib/services/

Riverpod `keepAlive` service classes that manage persistent, long-lived state.

Services differ from plain providers in that they:
- Hold mutable state that survives navigation
- Persist to `SharedPreferences`
- Expose domain operations, not just raw state

## Services

| File | Class | Provider | Role |
|------|-------|----------|------|
| `tree_service.dart` | `TreeService` | `treeServiceProvider` | Builds and maintains the MQTT topic tree from incoming messages |
| `mqtt_settings_provider.dart` | (in providers/) | `mqttSettingsServiceProvider` | MQTT connection settings persistence |
| `theme_provider.dart` | (in providers/) | `themeServiceProvider` | Theme persistence and ThemeData construction |

## TreeService

The most complex service — it maintains a `Map<String, List<TreeNode>>` keyed by root label.
- `addMessage(topic, payload)` — parses topic path, creates/updates nodes, triggers rebuild
- `getRoot(label)` / `getNodesForRoot(label)` — read-only tree access

Topics are split on `/`:
```
home/living_room/temperature  →  home → living_room → temperature (payload stored here)
```

The first segment becomes the "root" key in the map, which maps to browser tabs.
