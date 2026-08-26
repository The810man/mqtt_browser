import 'dart:convert';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:fl_nodes/fl_nodes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io' show Platform;

import 'detached_window_app.dart';
import 'providers/providers.dart';

bool get _isDesktopPlatform =>
    !kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS);

Future<void> _setWindowConstraints() async {
  if (_isDesktopPlatform) {
    await DesktopWindow.setMinWindowSize(const Size(400, 650));
  }
}

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  if (_isDesktopPlatform) {
    WindowController? windowController;
    try {
      windowController = await WindowController.fromCurrentEngine();
    } catch (_) {}

    final argument = windowController?.arguments ?? '';

    if (argument.isNotEmpty) {
      final data = jsonDecode(argument) as Map<String, dynamic>;
      final topicPath = data['topicPath'] as String? ?? '';

      await windowManager.ensureInitialized();
      windowManager.waitUntilReadyToShow(
        WindowOptions(
          size: const Size(1280, 720),
          center: true,
          title: topicPath.isEmpty ? 'MQTT Browser' : 'MQTT Browser — $topicPath',
          backgroundColor: Colors.transparent,
          skipTaskbar: false,
        ),
        () async {
          await windowManager.show();
          await windowManager.focus();
        },
      );

      runApp(ProviderScope(child: DetachedWindowApp(data: data)));
      return;
    }
  }

  await _setWindowConstraints();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'MQTT-Browser',
      theme: ref.watch(themeProvider),
      routerConfig: ref.watch(routerProvider),
      localizationsDelegates: const [
        FlNodeEditorLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
    );
  }
}
