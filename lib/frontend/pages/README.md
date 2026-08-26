# lib/frontend/pages/

Full-screen route pages registered in `providers/router_provider.dart`.

## Pages

| File | Route | Class | Role |
|------|-------|-------|------|
| `setup_page.dart` | `/` | `SetUpPage` | MQTT connection form; redirects to `/browserPage` when connected |
| `scaffhold_page.dart` | `/browserPage` | `ScaffoldPage` | Main browser UI: tab bar + tab views + sidebar drawer |
| `settings_page.dart` | `/settings` | `SettingsPage` | Theme color and dark-mode settings |
| `tree_view_page.dart` | (tab child) | `TreeViewPage` | Left-right split: topic tree + value panel |
| `test_graph_view_page.dart` | (dev only) | — | Test harness for chart views |

## Navigation Flow

```
App start
    └── SetUpPage (/)
           │ user fills host/port, clicks Connect
           │ mqttClientProvider state → connected
           └── ScaffoldPage (/browserPage)
                    │ settings icon
                    └── SettingsPage (/settings)
```

## ScaffoldPage State

`ScaffoldPage` owns a `TabController` that stays in sync with `tabListProvider`. Tabs are
`TreeNode` objects — the first tab is always the connection root, additional tabs open when
the user right-clicks a node and picks a view type.

## SetUpPage Responsibilities

1. Validate host/port input
2. Call `ref.read(mqttClientProvider.notifier).connect(host, port, clientId)`
3. After successful connection: initialise root tab, set up tree nodes
4. Display version number from `PackageInfo`
