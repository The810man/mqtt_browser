import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_browser/frontend/widgets/reactive_widgets/connections_widget.dart';
import 'package:mqtt_browser/frontend/widgets/reactive_widgets/settings_widget.dart';
import 'package:mqtt_browser/main.dart';

class FileNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  FileNotifier() : super([]);

  void setConnections(ref) async {
    await ref.read(sharedPreferencesProvider)!.setString(
        SharedPreferenceKey.connections.stringValue,
        jsonEncode(state).toString());
  }

  void getConnections(ref) {
    final data = ref
        .read(sharedPreferencesProvider)!
        .getString(SharedPreferenceKey.connections.stringValue);
    if (data == null) {
      // default connection
      addEntry([
        {
          "name": "Localhost",
          "host": "localhost",
          "port": 1883,
          "icon": "cloud"
        }
      ]);
    } else {
      final decoded = jsonDecode(data) as List<dynamic>;
      // Normalize entries to ensure they have name/host/port
      final entries = decoded.map((e) {
        final m = Map<String, dynamic>.from(e as Map);
        m['name'] = m['name'] ?? '${m['host'] ?? 'conn'}:${m['port'] ?? ''}';
        return m;
      }).toList();
      addEntry(entries);
    }
    setConnections(ref);
  }

  void addEntry(entry) {
    if (entry is List) {
      state = [...state, ...entry.map((e) => Map<String, dynamic>.from(e))];
    } else if (entry is Map) {
      state = [...state, Map<String, dynamic>.from(entry)];
    }
  }

  void removeEntryAt(int index) {
    final newList = [...state];
    if (index >= 0 && index < newList.length) {
      newList.removeAt(index);
      state = newList;
    }
  }

  void updateEntryAt(int index, Map<String, dynamic> entry) {
    final newList = [...state];
    if (index >= 0 && index < newList.length) {
      newList[index] = Map<String, dynamic>.from(entry);
      state = newList;
    }
  }
}

final fileProvider =
    StateNotifierProvider<FileNotifier, List<Map<String, dynamic>>>((ref) {
  return FileNotifier()..getConnections(ref);
});

class SetupWidget extends ConsumerWidget {
  const SetupWidget({
    super.key,
    required this.startClient,
  });
  final ValueChanged<WidgetRef> startClient;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentWidth = MediaQuery.of(context).size.width;
    final currentHeight = MediaQuery.of(context).size.height;

    if (currentWidth > 900) {
      // Wide screen: side by side
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            // Left side - connections
            Expanded(
              child: ConnectionsWidget(
                height: currentHeight - 120,
                width: double.infinity,
              ),
            ),
            const SizedBox(width: 24),
            // Right side - settings
            Expanded(
              child: SetupSettings(
                startClient: startClient,
                width: double.infinity,
                height: currentHeight - 120,
              ),
            ),
          ],
        ),
      );
    } else {
      // Narrow screen: stacked
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Settings at top
            Expanded(
              child: SetupSettings(
                startClient: startClient,
                width: double.infinity,
                height: 300,
              ),
            ),
            const SizedBox(height: 16),
            // Connections at bottom
            Expanded(
              child: ConnectionsWidget(
                height: 300,
                width: double.infinity,
              ),
            ),
          ],
        ),
      );
    }
  }
}
