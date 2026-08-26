# lib/backend/

Platform-aware MQTT client construction and the core MQTT service class.

## Files

| File | Role |
|------|------|
| `mqtt_service.dart` | `MqttService` — OOP wrapper for all MQTT operations (connect, subscribe, publish, disconnect) |
| `mqtt_client_factory.dart` | Conditional import: picks `_web.dart` or `_stub.dart` at compile time |
| `mqtt_client_factory_stub.dart` | Native/desktop: creates `MqttServerClient` |
| `mqtt_client_factory_web.dart` | Web: creates `MqttBrowserClient` |

## Design

`MqttService` is a pure Dart class (no Riverpod dependency). It is instantiated and owned by
`MqttClientNotifier` in `providers/mqtt_client_provider.dart`, which exposes its state to the UI.

```
MqttClientNotifier (Riverpod)
    └── MqttService (plain class)
            └── mqtt5_client (pub package)
```

The factory pattern via conditional imports keeps platform specifics isolated — the rest of the
codebase always imports `mqtt_client_factory.dart` and calls `createPlatformClient(...)`.
