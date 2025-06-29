import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_browser/backend/mqtt_sys.dart' as mqSys;
import 'package:mqtt_browser/frontend/widgets/custom_painters/custom_painter_widgets/line_with_streak_widget.dart';
import 'package:mqtt_browser/frontend/widgets/mqtt_background_grid_icons.dart';
import 'package:mqtt_browser/frontend/widgets/reactive_widgets/setup_widget.dart';
import 'package:mqtt_browser/main.dart';
import 'package:mqtt_browser/backend/tree_updater.dart' as Tree_Updater;
import 'dart:math';
// import 'package:vitality/vitality.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:mqtt_browser/frontend/widgets/tiled_background.dart';

final versionProvider = StateProvider((ref) => "");

final versionSetter =
    StateProvider((ref) => PackageInfo.fromPlatform().then((value) {
          ref.read(versionProvider.notifier).state = value.data["version"];
        }));

class SetUpPage extends ConsumerWidget {
  final connectButtonProvider = StateProvider<bool>(((ref) => false));
  final hostTextController = TextEditingController(text: 'localhost');
  final portTextController = TextEditingController(text: '1883');
  int random(int min, int max) {
    return min + Random().nextInt(max - min);
  }

  SetUpPage({super.key});
  void _startClient(WidgetRef ref) {
    final client = mqSys.createClient(
        hostTextController.text, int.parse(portTextController.text));

    client.onConnected = () {
      ref.read(isConnectedProvider.notifier).state = true;
    };
    ref.read(clientProvider.notifier).state = client;

    mqSys.startClient(client, false, true);
    mqSys.setUpClient(client, 20, 2000);
    final time = DateTime.now();
    mqSys.setUpConnMess("mqtt-browser::${random(0, 9999999).toString()}",
        "Connected", "$time", client);
    mqSys.clientTryConnect(client);
    Tree_Updater.reciveStreams();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(versionSetter);
    ref.watch(routerProvider);

    return LineWithStreakWidget();
    //   Scaffold(
    //     backgroundColor: ref.watch(themeDataProvider).colorScheme.surface,
    //     appBar: AppBar(
    //       elevation: 4,
    //       centerTitle: false,
    //       automaticallyImplyLeading: false,
    //       shape: const RoundedRectangleBorder(
    //         borderRadius: BorderRadius.all(Radius.circular(2)),
    //       ),
    //       title: const Text(
    //         "Client Setup",
    //         style: TextStyle(
    //           fontWeight: FontWeight.w800,
    //           fontStyle: FontStyle.normal,
    //           fontSize: 20,
    //         ),
    //       ),
    //       leading: const Icon(
    //         Icons.menu,
    //         size: 24,
    //       ),
    //       actions: [
    //         Row(
    //           children: [
    //             const Text("Darkmode"),
    //             Switch.adaptive(
    //                 value: ref.watch(colorModeProvider),
    //                 onChanged: (outputBool) async {
    //                   await ref.read(sharedPreferencesProvider)!.setBool(
    //                       SharedPreferenceKey.darkMode.stringValue, outputBool);
    //                   ref.read(colorModeProvider.notifier).state = outputBool;
    //                 })
    //           ],
    //         ),
    //         const Padding(
    //           padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
    //           child: Icon(Icons.account_tree_outlined, size: 24),
    //         ),
    //       ],
    //     ),
    //     body: Stack(
    //       children: [
    //         const TiledBackground(
    //           tile: Icon(MqttBackgroundGrid.unbetitelt_2,
    //               size: 50, color: Colors.grey),
    //           spacing: 50,
    //           opacity: 0.5,
    //         ),
    //         Positioned(
    //             bottom: 0.0,
    //             right: 0.0,
    //             child: Padding(
    //               padding: const EdgeInsets.all(8.0),
    //               child: Text("v${ref.watch(versionProvider).toString()}"),
    //             )),
    //         SetupWidget(
    //             hostTextController: hostTextController,
    //             portTextController: portTextController,
    //             startClient: _startClient)
    //       ],
    //     ),
    //   );
  }
}
