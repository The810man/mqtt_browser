# lib/providers/

All Riverpod providers. Generated via `riverpod_annotation` — every `@riverpod`/`@Riverpod`
annotated class or function has a corresponding `.g.dart` file.

## Provider Map

| File | Provider(s) | Role |
|------|-------------|------|
| `shared_preferences_provider.dart` | `sharedPreferencesProvider` | Async `SharedPreferences` singleton |
| `theme_provider.dart` | `themeServiceProvider`, `themeProvider` | Theme settings CRUD + current `ThemeData` |
| `mqtt_settings_provider.dart` | `mqttSettingsServiceProvider` | MQTT settings persistence |
| `mqtt_client_provider.dart` | `mqttClientProvider` (`MqttClientNotifier`) | MQTT connection lifecycle |
| `tree_provider.dart` | (delegates to `services/tree_service.dart`) | — |
| `connections_provider.dart` | `connectionsProvider` | Typed saved connections list |
| `app_state_provider.dart` | `appStateProvider` | Ephemeral connection-form state |
| `router_provider.dart` | `routerProvider` | GoRouter — redirects on connection state |
| `ui_state_providers.dart` | Many small providers | Per-widget UI state |
| `providers.dart` | barrel export | Import this file everywhere in UI code |

## Naming Convention (riverpod_generator)

The generator strips the "Notifier" suffix from class names:
- `class FooNotifier extends _$FooNotifier` → provider is `fooProvider`
- `class Foo extends _$Foo` → provider is `fooProvider`
- `FooData foo(Ref ref) { ... }` → provider is `fooProvider`

## State Lifetime

| Provider | keepAlive | Reason |
|----------|-----------|--------|
| `sharedPreferencesProvider` | ✅ | Single platform instance |
| `mqttClientProvider` | ✅ | Must survive navigation |
| `mqttSettingsServiceProvider` | ✅ | Persistent settings |
| `themeServiceProvider` | ✅ | Theme persists across routes |
| `treeServiceProvider` | ✅ | Topic tree accumulates data |
| Most UI providers | ❌ | Rebuilt per-screen |

## Adding a New Provider

1. Create `lib/providers/my_feature_provider.dart` with `@riverpod` annotation
2. Run `dart run build_runner build --delete-conflicting-outputs`
3. Export from `providers.dart`
