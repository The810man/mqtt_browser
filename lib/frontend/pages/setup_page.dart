import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_browser/backend/mqtt_sys.dart' as mqSys;
import 'package:mqtt_browser/frontend/widgets/reactive_widgets/setup_widget.dart';
import 'package:mqtt_browser/main.dart';
import 'package:mqtt_browser/backend/tree_updater.dart' as Tree_Updater;
import 'dart:math';
import 'package:vitality/vitality.dart';
import 'package:package_info_plus/package_info_plus.dart';

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

    return Scaffold(
      backgroundColor: ref.watch(themeDataProvider).colorScheme.background,
      appBar: AppBar(
        elevation: 4,
        centerTitle: false,
        automaticallyImplyLeading: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(2)),
        ),
        title: const Text(
          "Client Setup",
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontStyle: FontStyle.normal,
            fontSize: 20,
          ),
        ),
        leading: const Icon(
          Icons.menu,
          size: 24,
        ),
        actions: [
          Row(
            children: [
              const Text("Darkmode"),
              Switch.adaptive(
                  value: ref.watch(colorModeProvider),
                  onChanged: (outputBool) async {
                    await ref.read(sharedPreferencesProvider)!.setBool(
                        SharedPreferenceKey.darkMode.stringValue, outputBool);
                    ref.read(colorModeProvider.notifier).state = outputBool;
                  })
            ],
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
            child: Icon(Icons.account_tree_outlined, size: 24),
          ),
        ],
      ),
      body: Stack(
        children: [
          Vitality.randomly(
            background: ref.watch(themeDataProvider).colorScheme.background,
            maxOpacity: 0.8,
            minOpacity: 0.1,
            itemsCount: 30,
            enableXMovements: true,
            whenOutOfScreenMode: WhenOutOfScreenMode.Reflect,
            maxSpeed: 1,
            maxSize: 30,
            minSpeed: 0.3,
            randomItemsColors: [
              ref.watch(themeDataProvider).colorScheme.secondary,
              ref.watch(themeDataProvider).colorScheme.shadow
            ],
            randomItemsBehaviours: [
              ItemBehaviour(
                  shape: ShapeType.Icon, icon: Icons.check_box_outline_blank),
              ItemBehaviour(shape: ShapeType.Icon, icon: Icons.cloud_outlined),
              ItemBehaviour(shape: ShapeType.Icon, icon: Icons.circle_outlined),
              ItemBehaviour(shape: ShapeType.Icon, icon: Icons.email_outlined),
            ],
          ),
          Positioned(
              bottom: 0.0,
              right: 0.0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("v${ref.watch(versionProvider).toString()}"),
              )),
          SetupWidget(
              hostTextController: hostTextController,
              portTextController: portTextController,
              startClient: _startClient)
        ],
      ),
    );
  }
}
