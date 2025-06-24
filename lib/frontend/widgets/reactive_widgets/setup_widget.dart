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
      addEntry([
        {"host": "localhost", "port": 1883}
      ]);
    } else {
      addEntry(jsonDecode(data));
    }
    setConnections(ref);
  }

  void addEntry(entry) {
    state = [...state, ...entry];
  }
}

final fileProvider =
    StateNotifierProvider<FileNotifier, List<Map<String, dynamic>>>((ref) {
  return FileNotifier()..getConnections(ref);
});

class SetupWidget extends ConsumerWidget {
  const SetupWidget(
      {super.key,
      required this.hostTextController,
      required this.portTextController,
      required this.startClient});
  final TextEditingController hostTextController;
  final TextEditingController portTextController;
  final Function startClient;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentWidth = MediaQuery.of(context).size.width;
    ref.watch(fileProvider);
    return Center(
        child: currentWidth > 750
            ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                ConnectionsWidget(
                  hostTextController: hostTextController,
                  portTextController: portTextController,
                  height: 380,
                  width: 250,
                ),
                SetupSettings(
                  hostTextController: hostTextController,
                  portTextController: portTextController,
                  startClient: startClient(ref),
                  width: 380,
                  height: 380,
                )
              ])
            : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                SetupSettings(
                  hostTextController: hostTextController,
                  portTextController: portTextController,
                  startClient: startClient(ref),
                  width: 380,
                  height: 380,
                ),
                ConnectionsWidget(
                  hostTextController: hostTextController,
                  portTextController: portTextController,
                  height: 250,
                  width: 380,
                )
              ]));
  }
}
