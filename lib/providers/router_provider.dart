import 'package:go_router/go_router.dart';
import 'package:mqtt_browser/frontend/pages/scaffhold_page.dart';
import 'package:mqtt_browser/frontend/pages/settings_page.dart';
import 'package:mqtt_browser/frontend/pages/setup_page.dart';
import 'package:mqtt_browser/providers/mqtt_client_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'router_provider.g.dart';

@riverpod
GoRouter router(Ref ref) {
  final connectionState = ref.watch(mqttClientProvider);

  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        name: 'setUpPage',
        path: '/',
        builder: (context, state) => SetUpPage(),
        redirect: (context, state) {
          if (connectionState == MqttConnectionState.connected) {
            return "/browserPage";
          }
          return "/";
        },
      ),
      GoRoute(
        name: 'browserPage',
        path: '/browserPage',
        builder: (context, state) => const ScaffoldPage(),
      ),
      GoRoute(
        name: 'settingsPage',
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
    ],
  );
}
