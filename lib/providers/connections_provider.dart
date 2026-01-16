import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/connection.dart';
import 'shared_preferences_provider.dart';

part 'connections_provider.g.dart';

@riverpod
class Connections extends _$Connections {
  static const String _connectionsKey = 'connections';

  @override
  List<Connection> build() {
    final prefs = ref
        .watch(sharedPreferencesProvider)
        .maybeWhen(data: (value) => value, orElse: () => null);
    if (prefs == null) return [];

    final data = prefs.getString(_connectionsKey);
    if (data == null) {
      return [const Connection(host: 'localhost', port: 1883)];
    }

    try {
      final list = jsonDecode(data) as List<dynamic>;
      return list
          .map((e) => Connection.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [const Connection(host: 'localhost', port: 1883)];
    }
  }

  Future<void> _saveConnections(List<Connection> connections) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setString(
      _connectionsKey,
      jsonEncode(connections.map((c) => c.toJson()).toList()),
    );
  }

  Future<void> addConnection(Connection connection) async {
    final updated = [...state, connection];
    await _saveConnections(updated);
    state = updated;
  }

  Future<void> removeConnection(Connection connection) async {
    final updated = state.where((c) => c != connection).toList();
    await _saveConnections(updated);
    state = updated;
  }

  Future<void> updateConnections(List<Connection> connections) async {
    await _saveConnections(connections);
    state = connections;
  }
}
