import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/foundation.dart';

import 'providers/providers.dart';

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

Future<void> setWindowConstraints() async {
  if (!kIsWeb) {
    const double minWidth = 400;
    const double minHeight = 650;
    await DesktopWindow.setMinWindowSize(const Size(minWidth, minHeight));
  }
}

late ProviderContainer globalProviderContainer;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await setWindowConstraints();
  }

  final container = ProviderContainer();
  globalProviderContainer = container;

  runApp(UncontrolledProviderScope(container: container, child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'MQTT-Browser',
      theme: ref.watch(themeProvider),
      routerConfig: router,
    );
  }
}
