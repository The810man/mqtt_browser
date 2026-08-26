# lib/

Root of all Dart source code for MQTT Browser.

## Folder Structure

```
lib/
├── main.dart               Entry point — ProviderContainer setup, window constraints, MyApp widget
├── constants.dart          App-wide constants and SharedPreferenceKey enum
├── theme.dart              (legacy, unused — theme lives in providers/theme_provider.dart)
│
├── backend/                MQTT client platform-conditional creation + low-level service class
│   └── README.md
│
├── models/                 Freezed data classes (immutable value types)
│   └── README.md
│
├── providers/              Riverpod providers (state management, business logic)
│   └── README.md
│
├── services/               Persistent services: tree state, settings persistence
│   └── README.md
│
└── frontend/               All UI code — pages, widgets, custom components
    └── README.md
```

## Architecture Overview

```
UI (frontend/) ──watches──> Providers (providers/)
                                  │
                          reads/writes
                                  │
              ┌───────────────────┼────────────────────┐
          Services/           Models/              Backend/
       (tree, settings)    (data classes)      (mqtt client)
```

- **Models** are pure data (`@freezed` + `@JsonSerializable`)
- **Services** are Riverpod `@Riverpod(keepAlive: true)` classes that manage persistent state
- **Providers** orchestrate services and expose state to the UI
- **Backend** contains platform-aware MQTT client creation and the `MqttService` class
- **Frontend** is purely reactive — it reads providers and dispatches actions

## Key Entry Points

| File | Role |
|------|------|
| `main.dart` | Bootstrap: window sizing, `ProviderContainer`, `MaterialApp.router` |
| `providers/router_provider.dart` | GoRouter config — routes depend on `mqttClientProvider` state |
| `providers/mqtt_client_provider.dart` | Core MQTT connection lifecycle (`MqttClientNotifier`) |
| `services/tree_service.dart` | MQTT topic tree (`TreeService`) |
