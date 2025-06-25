import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_browser/frontend/tree_node.dart';
import 'package:mqtt_browser/frontend/pages/scaffhold_page.dart';
import 'package:mqtt_browser/frontend/pages/test_graph_view_page.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:go_router/go_router.dart';
import 'package:mqtt_browser/frontend/pages/setup_page.dart';

import 'package:desktop_window/desktop_window.dart';
import 'package:shared_preferences/shared_preferences.dart';

// SearchBarWidhtProvider has the Searchbar width Index 0 and button size index 1
final searchBarWidthProvider = StateProvider<double?>((ref) => 0.0);
final searchBarButtonProvider = StateProvider<double?>((ref) => 50);
final ProviderContainer globalProviderContainer = ProviderContainer();
StateProvider tabDataProvider =
    StateProvider<Map<String, TreeController<TreeNode>>>((ref) => {
          ref.watch(rootProvider).label!: TreeController(
              roots: [ref.watch(rootProvider)],
              childrenProvider: (TreeNode node) => node.children)
        }); // \-> Should look  like Map<String:TreeController> {"localhost:1883":Treecontroller(...), etc}
final changeIshappeningProvider = StateProvider<bool>((ref) {
  return false;
});
StateProvider<TextEditingController> publishTextControllerProvider =
    StateProvider((ref) => TextEditingController());
final currentMessageProvider = StateProvider<Map<TreeNode, String>>((ref) =>
    {ref.watch(currentRootProvider): """{"select a node Please":123}"""});

/// |
/// \-> Should look like Map<Current Tab Node:Selected Messege> {rootNode:"""{"theDevilsPlant:420"}"""}
/// \-> Also The Value String should not be a provider Refrence because it is not suppost to auto Update
StateProvider<String?> selectedGraphProvider =
    StateProvider<String?>((ref) => null);

StateProvider<Map<String, TreeNode>> selectedItemProvider =
    StateProvider<Map<String, TreeNode>>(
        // {The Name of the Root of the Tree: The Selected Node}
        (ref) => {ref.watch(rootProvider).label!: ref.watch(rootProvider)});

StateProvider<List<TreeNode>> tabListProvider =
    StateProvider<List<TreeNode>>((ref) => [ref.watch(rootProvider)]);
const clientType = kIsWeb ? MqttServerClient : MqttBrowserClient;

StateProvider selectedTabProvider = StateProvider((ref) => null);

StateProvider clientProvider = kIsWeb
    ? StateProvider<MqttBrowserClient?>((ref) => null)
    : StateProvider<MqttServerClient?>((ref) => null);
// final treeControllerProvider = StateProvider<TreeController<FastTreeNode>>(
//     (ref) => TreeController<FastTreeNode>(
//           // Provide the root nodes that will be used as a starting point when
//           // traversing your hierarchical data.
//           roots: [ref.read(rootProvider)],
//           // Provide a callback for the controller to get the children of a
//           // given node when traversing your hierarchical data. Avoid doing
//           // heavy computations in this method, it should behave like a getter.
//           childrenProvider: (FastTreeNode node) => node.children,
//         ));
final tabLengthProvider =
    StateProvider<int>((ref) => ref.watch(tabListProvider).length);
final codeBoxButtonStatesProvider = StateProvider<String>((ref) => "raw");
StateProvider<TreeNode> rootProvider =
    StateProvider<TreeNode>((ref) => TreeNode(
          label: "${ref.read(hostProvider)}:${ref.read(portProvider)}",
        ));
final isBuildProvider = StateProvider<bool>((ref) => false);
final bookMarkedListProvider = StateProvider<List?>(((ref) => []));
StateProvider<TreeNode> currentRootProvider =
    StateProvider((ref) => ref.watch(rootProvider));
StateProvider tabControllerProvider =
    StateProvider((ref) => useTabController(initialLength: 1));
StateProvider<Map<String, List<TreeNode>>> treeNodesProvider =
    StateProvider<Map<String, List<TreeNode>>>((ref) => {
          ref.watch(rootProvider).label!: [ref.watch(rootProvider)]
        }); // {"name of tree Root": All Existing Roots (Doesn´t matter if they are not inside the Tree) }
final spaceSliderProvider = StateProvider<double>((ref) =>
    ref
        .watch(sharedPreferencesProvider)!
        .getDouble(SharedPreferenceKey.nodeDistance.stringValue) ??
    30);
final blinkDelayProvider = StateProvider<double>((ref) =>
    ref
        .watch(sharedPreferencesProvider)!
        .getDouble(SharedPreferenceKey.blinkDelay.stringValue) ??
    1500);
final blinkDurationProvider = StateProvider<double>((ref) =>
    ref
        .watch(sharedPreferencesProvider)!
        .getDouble(SharedPreferenceKey.blinkDuration.stringValue) ??
    500);

enum SharedPreferenceKey {
  darkMode,
  connections,
  nodeDistance,
  nodeThickness,
  nodeOrigin,
  nodeHeight,
  roundLines,
  connectNodes,
  blinkDelay,
  blinkDuration
}

extension getString on SharedPreferenceKey {
  String get stringValue {
    return toString().split(".").last;
  }
}

final roundedLineSwitchProvider = StateProvider<bool>((ref) =>
    ref
        .watch(sharedPreferencesProvider)!
        .getBool(SharedPreferenceKey.roundLines.stringValue) ??
    false);
final connectLinesSwitchProvider = StateProvider<bool>((ref) =>
    ref
        .watch(sharedPreferencesProvider)!
        .getBool(SharedPreferenceKey.connectNodes.stringValue) ??
    false);
final thicknessSliderProvider = StateProvider<double>((ref) =>
    ref
        .watch(sharedPreferencesProvider)!
        .getDouble(SharedPreferenceKey.nodeThickness.stringValue) ??
    2);
final nodeHeightProvider = StateProvider<double>((ref) =>
    ref
        .watch(sharedPreferencesProvider)!
        .getDouble(SharedPreferenceKey.nodeHeight.stringValue) ??
    1);
final sharedPreferencesProvider =
    StateProvider<SharedPreferences?>(((ref) => null));
final originSliderProvider = StateProvider<double>((ref) =>
    ref
        .watch(sharedPreferencesProvider)!
        .getDouble(SharedPreferenceKey.nodeOrigin.stringValue) ??
    0.5);
final publishMessageProvider = StateProvider<String>((ref) => "");
StateProvider<bool> isConnectedProvider = StateProvider<bool>((ref) {
  final client = ref.watch(clientProvider);
  if (client == null) {
    return false;
  }
  if (client.connectionStatus == null) {
    return false;
  }

  return client.connectionStatus!.state == MqttConnectionState.connected;
});
Provider<GoRouter> routerProvider = Provider((ref) => GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          name: 'setUpPage',
          path: '/',
          builder: (context, state) => SetUpPage(),
          redirect: (context, state) {
            if (ref.watch(isConnectedProvider) == true) {
              print("now connected ... switching screen . . .");
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
      ],
    ));
StateProvider<String> hostProvider =
    StateProvider<String>((ref) => "localhost");
StateProvider<String> portProvider = StateProvider<String>((ref) => "1883");
final graphDataProvider = Provider((ref) => GraphData());
final tabIndexProvider = StateProvider((ref) => 0);
final colorModeProvider = StateProvider<bool>((ref) {
  const themeStatus = "THEMESTATUS";
  if (ref.watch(sharedPreferencesProvider)!.getBool(themeStatus) == null) {
    final darkMode =
        SchedulerBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark;
    ref.watch(sharedPreferencesProvider)!.setBool(themeStatus, darkMode);
    return darkMode;
  } else {
    return ref.watch(sharedPreferencesProvider)!.getBool(themeStatus)!;
  }
});
final themeDataProvider = StateProvider<ThemeData>((ref) {
  return !ref.watch(colorModeProvider)
      ? ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          colorScheme: const ColorScheme.light(
              shadow: Color.fromARGB(69, 141, 141, 141),
              surface: Color.fromARGB(255, 247, 247, 247),
              primary: Color.fromARGB(255, 0, 0, 0),
              secondary: Color.fromARGB(255, 78, 78, 78),
              tertiary: Color.fromARGB(96, 255, 255, 255),
              scrim: Color.fromARGB(0, 255, 255, 255)))
      : ThemeData(
          elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(0, 255, 0, 0),
                  surfaceTintColor: const Color.fromARGB(0, 255, 255, 255))),
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: const ColorScheme.dark(
              shadow: Color.fromARGB(255, 117, 117, 126),
              surface: Color.fromARGB(255, 29, 27, 41),
              primary: Color.fromARGB(255, 221, 221, 221),
              secondary: Color.fromARGB(255, 145, 145, 145),
              tertiary: Color.fromARGB(61, 0, 0, 0),
              scrim: Color.fromARGB(0, 255, 255, 255)));
});

void resetProviders() {
  hostProvider = StateProvider<String>((ref) => "localhost");
  portProvider = StateProvider<String>((ref) => "1883");
  isConnectedProvider = StateProvider<bool>((ref) {
    final client = ref.watch(clientProvider);
    if (client == null) {
      return false;
    }
    if (client.connectionStatus == null) {
      return false;
    }

    return client.connectionStatus!.state == MqttConnectionState.connected;
  });
  tabDataProvider =
      StateProvider<Map<String, TreeController<TreeNode>>>((ref) => {
            ref.watch(rootProvider).label!: TreeController(
                roots: [ref.watch(rootProvider)],
                childrenProvider: (TreeNode node) => node.children)
          });
  selectedTabProvider = StateProvider((ref) => null);
  publishTextControllerProvider =
      StateProvider((ref) => TextEditingController());
  selectedItemProvider = StateProvider<Map<String, TreeNode>>(
      // {The Name of the Root of the Tree: The Selected Node}
      (ref) => {ref.watch(rootProvider).label!: ref.watch(rootProvider)});
  tabListProvider =
      StateProvider<List<TreeNode>>((ref) => [ref.watch(rootProvider)]);
  clientProvider = kIsWeb
      ? StateProvider<MqttBrowserClient?>((ref) => null)
      : StateProvider<MqttServerClient?>((ref) => null);
  rootProvider = StateProvider<TreeNode>((ref) => TreeNode(
        label: "${ref.read(hostProvider)}:${ref.read(portProvider)}",
      ));
  tabControllerProvider =
      StateProvider((ref) => useTabController(initialLength: 1));
  currentRootProvider = StateProvider((ref) => ref.watch(rootProvider));
  treeNodesProvider = StateProvider<Map<String, List<TreeNode>>>((ref) => {
        ref.watch(rootProvider).label!: [ref.watch(rootProvider)]
      });
}

Future<void> setWindowConstraints() async {
  if (!kIsWeb) {
    const double minWidth = 400;
    const double minHeight = 650;

    await DesktopWindow.setMinWindowSize(const Size(minWidth, minHeight));
  }
}

void main() async {
  await SharedPreferences.getInstance().then((value) => globalProviderContainer
      .read(sharedPreferencesProvider.notifier)
      .state = value);

  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await setWindowConstraints();
  }
  runApp(UncontrolledProviderScope(
      container: globalProviderContainer, child: MyApp()));
}

class MyApp extends ConsumerWidget {
  final textEditingController = TextEditingController();

  MyApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeDataProvider);
    return MaterialApp.router(
      title: 'MQTT-Browser',
      theme: currentTheme,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
