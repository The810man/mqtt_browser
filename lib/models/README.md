# lib/models/

Immutable data classes using `package:freezed_annotation` + `package:json_annotation`.

Every model has three files: the definition (`.dart`), the generated freezed code (`.freezed.dart`),
and the generated JSON code (`.g.dart`). Never edit generated files.

## Models

| Model | Purpose |
|-------|---------|
| `Connection` | A saved broker connection: `host` + `port` |
| `AppStateData` | Ephemeral UI state (current host/port, selected tab, publish field) |
| `MqttSettings` | Full MQTT connection config: credentials, TLS, keep-alive, subscriptions, open tabs |
| `ThemeSettings` | Theme configuration: primary/accent/background color, dark mode flag |

## Conventions

- All models use `const factory` constructors and `@Default(...)` for optional fields.
- JSON round-trip via `fromJson` / `toJson` for SharedPreferences persistence.
- Colors are stored as `int` via `ColorConverter` implements `JsonConverter<Color, int>`.
- Use `.copyWith(...)` for any mutation — never mutate instances directly.

## Regenerating

```bash
dart run build_runner build --delete-conflicting-outputs
```
