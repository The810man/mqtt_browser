import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mqtt5_client/mqtt5_client.dart' show MqttQos;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../frontend/tree_node.dart';
import '../models/mqtt_settings.dart';
import 'shared_preferences_provider.dart';
import 'theme_provider.dart';
import 'mqtt_settings_provider.dart';

part 'ui_state_providers.g.dart';

@riverpod
class Host extends _$Host {
  @override
  String build() => 'localhost';

  void set(String value) => state = value;
}

@riverpod
class Port extends _$Port {
  @override
  String build() => '1883';

  void set(String value) => state = value;
}

@riverpod
class UseWebSocket extends _$UseWebSocket {
  @override
  bool build() => false;

  void set(bool value) => state = value;
  void toggle() => state = !state;
}

@riverpod
MqttSettings mqttSettings(Ref ref) {
  final asyncSettings = ref.watch(mqttSettingsServiceProvider);
  return asyncSettings.maybeWhen(
    data: (settings) => settings,
    orElse: () => MqttSettings(
      host: 'localhost',
      port: 1883,
      clientId: 'mqtt_browser_client',
    ),
  );
}

@Riverpod(keepAlive: true)
class TabList extends _$TabList {
  @override
  List<TreeNode> build() => [];

  void set(List<TreeNode> value) => state = value;
}

@Riverpod(keepAlive: true)
class TabLength extends _$TabLength {
  @override
  int build() => 1;

  void set(int value) => state = value;
}

@Riverpod(keepAlive: true)
class TabIndex extends _$TabIndex {
  @override
  int build() => 0;

  void set(int value) => state = value;
}

@Riverpod(keepAlive: true)
class Root extends _$Root {
  @override
  TreeNode build() => TreeNode(label: 'root');

  void set(TreeNode value) => state = value;
}

@Riverpod(keepAlive: true)
class CurrentRoot extends _$CurrentRoot {
  @override
  TreeNode build() => ref.watch(rootProvider);

  void set(TreeNode value) => state = value;
}

@Riverpod(keepAlive: true)
class TabData extends _$TabData {
  @override
  Map<String, Map<String, dynamic>> build() => {};

  void set(Map<String, Map<String, dynamic>> value) => state = value;
}

@Riverpod(keepAlive: true)
class TreeNodes extends _$TreeNodes {
  @override
  Map<String, List<TreeNode>> build() => {};

  void set(Map<String, List<TreeNode>> value) => state = value;
}

@Riverpod(keepAlive: true)
class SelectedItem extends _$SelectedItem {
  @override
  Map<String, TreeNode> build() => {};

  void set(Map<String, TreeNode> value) => state = value;
}

@riverpod
class ChangeIshappening extends _$ChangeIshappening {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

@riverpod
class CurrentMessage extends _$CurrentMessage {
  @override
  Map<TreeNode, String> build() => {};

  void set(TreeNode node, String value) {
    state = {...state, node: value};
  }
}

@riverpod
class PublishTextController extends _$PublishTextController {
  @override
  TextEditingController build() => TextEditingController();
}

@riverpod
class PublishFormat extends _$PublishFormat {
  @override
  String build() => 'json';

  void set(String value) => state = value;
}

@riverpod
class PublishQos extends _$PublishQos {
  @override
  MqttQos build() => MqttQos.atMostOnce;

  void set(MqttQos value) => state = value;
}

@riverpod
class PublishRetain extends _$PublishRetain {
  @override
  bool build() => false;

  void set(bool value) => state = value;
}

@riverpod
class SpaceSlider extends _$SpaceSlider {
  @override
  double build() => 16.0;

  void set(double value) => state = value;
}

@riverpod
class ThicknessSlider extends _$ThicknessSlider {
  @override
  double build() => 2.0;

  void set(double value) => state = value;
}

@riverpod
class OriginSlider extends _$OriginSlider {
  @override
  double build() => 0.5;

  void set(double value) => state = value;
}

@riverpod
class NodeHeight extends _$NodeHeight {
  @override
  double build() => 1.0;

  void set(double value) => state = value;
}

@riverpod
class RoundedLineSwitch extends _$RoundedLineSwitch {
  @override
  bool build() => true;

  void set(bool value) => state = value;
}

@riverpod
class ConnectLinesSwitch extends _$ConnectLinesSwitch {
  @override
  bool build() => true;

  void set(bool value) => state = value;
}

@riverpod
class ColorMode extends _$ColorMode {
  @override
  bool build() => true;

  void set(bool value) => state = value;
}

@riverpod
class BlinkDelay extends _$BlinkDelay {
  @override
  double build() => 200.0;

  void set(double value) => state = value;
}

@riverpod
class BlinkDuration extends _$BlinkDuration {
  @override
  double build() => 350.0;

  void set(double value) => state = value;
}

@riverpod
class SearchBarButton extends _$SearchBarButton {
  @override
  double build() => 50.0;

  void set(double value) => state = value;
}

@riverpod
class SearchBarWidth extends _$SearchBarWidth {
  @override
  double build() => 0.0;

  void set(double value) => state = value;
}

@riverpod
class ConnectionsEntries extends _$ConnectionsEntries {
  static const String _connectionsKey = 'connections';

  @override
  List<Map<String, dynamic>> build() {
    final prefs = ref
        .watch(sharedPreferencesProvider)
        .maybeWhen(data: (value) => value, orElse: () => null);
    if (prefs == null) {
      return [
        {
          'name': 'Localhost',
          'host': 'localhost',
          'port': 1883,
          'icon': 'cloud',
        },
      ];
    }

    final data = prefs.getString(_connectionsKey);
    if (data == null) {
      return [
        {
          'name': 'Localhost',
          'host': 'localhost',
          'port': 1883,
          'icon': 'cloud',
        },
      ];
    }

    try {
      final decoded = jsonDecode(data) as List<dynamic>;
      return decoded.map((entry) {
        final map = Map<String, dynamic>.from(entry as Map);
        map['name'] =
            map['name'] ?? '${map['host'] ?? 'conn'}:${map['port'] ?? ''}';
        return map;
      }).toList();
    } catch (_) {
      return [
        {
          'name': 'Localhost',
          'host': 'localhost',
          'port': 1883,
          'icon': 'cloud',
        },
      ];
    }
  }

  Future<void> _save(List<Map<String, dynamic>> entries) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setString(_connectionsKey, jsonEncode(entries));
  }

  Future<void> setConnections(List<Map<String, dynamic>> entries) async {
    await _save(entries);
    state = entries;
  }

  Future<void> addEntry(Map<String, dynamic> entry) async {
    final updated = [...state, Map<String, dynamic>.from(entry)];
    await _save(updated);
    state = updated;
  }

  Future<void> removeAt(int index) async {
    final updated = [...state];
    if (index >= 0 && index < updated.length) {
      updated.removeAt(index);
      await _save(updated);
      state = updated;
    }
  }

  Future<void> updateAt(int index, Map<String, dynamic> entry) async {
    final updated = [...state];
    if (index >= 0 && index < updated.length) {
      updated[index] = Map<String, dynamic>.from(entry);
      await _save(updated);
      state = updated;
    }
  }
}

@riverpod
ThemeData themeData(Ref ref) => ref.watch(themeProvider);
