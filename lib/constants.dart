class AppConstants {
  static const String defaultHost = 'localhost';
  static const int defaultPort = 1883;
  static const String connectionsKey = 'connections';
  static const String mqttSettingsKey = 'mqtt_settings';
  static const int maxMessageHistory = 100;
}

enum SharedPreferenceKey {
  connections('connections'),
  nodeDistance('node_distance'),
  nodeThickness('node_thickness'),
  nodeOrigin('node_origin'),
  nodeHeight('node_height'),
  roundLines('round_lines'),
  connectNodes('connect_nodes'),
  darkMode('dark_mode'),
  blinkDelay('blink_delay'),
  blinkDuration('blink_duration');

  const SharedPreferenceKey(this.stringValue);
  final String stringValue;
}
