import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_browser/constants.dart';
import 'package:mqtt_browser/main.dart';
import 'dart:convert';

// FileNotifier with Riverpod annotation for codegen
class FileNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  FileNotifier(this.ref) : super([]);
  final Ref ref;

  void setConnections() async {
    await ref.read(sharedPreferencesProvider)!.setString(
          AppConstants.connectionsKey,
          jsonEncode(state),
        );
  }

  void getConnections() {
    final data = ref
        .read(sharedPreferencesProvider)!
        .getString(AppConstants.connectionsKey);
    if (data == null) {
      addEntry([
        {"host": AppConstants.defaultHost, "port": AppConstants.defaultPort}
      ]);
    } else {
      addEntry(List<Map<String, dynamic>>.from(jsonDecode(data)));
    }
    setConnections();
  }

  void addEntry(List<Map<String, dynamic>> entry) {
    state = [...state, ...entry];
  }
}

final fileProvider =
    StateNotifierProvider<FileNotifier, List<Map<String, dynamic>>>((ref) {
  return FileNotifier(ref)..getConnections();
});
