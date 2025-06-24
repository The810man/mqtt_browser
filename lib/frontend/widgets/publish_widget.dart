import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:json_editor/json_editor.dart';
import 'package:mqtt_browser/frontend/tree_node.dart';
import 'package:mqtt_browser/main.dart';
import 'package:mqtt_browser/backend/mqtt_sys.dart' as mqSys;
import 'package:mqtt_client/mqtt_client.dart';

class PublishWidget extends ConsumerWidget {
  PublishWidget({super.key, required this.root});
  final TreeNode root;

  void publish(String topic, WidgetRef ref) async {
    mqSys.clientSubcribe(ref.read(clientProvider)!, topic, 0);
    final builder = MqttClientPayloadBuilder();
    builder.addString(valueTextController.text);
    ref.read(clientProvider)!.publishMessage(
        topic, ref.watch(qos), builder.payload!,
        retain: ref.watch(retain));
  }

  final List selectedList = [];
  final TextEditingController valueTextController = TextEditingController();
  final TextEditingController searchBarTextController = TextEditingController();
  final sideBarScaffholdKey = GlobalKey<ScaffoldState>();
  final String newText = "";
  final retain = StateProvider<bool>((ref) => false);
  final qos = StateProvider<MqttQos>((ref) => MqttQos.atMostOnce);
  void initState(WidgetRef ref, context) {
    searchBarTextController.addListener(() {});
    valueTextController.addListener(() {});
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    initState(ref, context);
    ref.watch(changeIshappeningProvider);
    return Container(
      child: Consumer(
        builder: (context, ref, child) {
          return Column(
            // main collumn
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Topic",
                    style: TextStyle(fontSize: 11),
                  ),
                ],
              ),
              TextFormField(
                  //topic input
                  textAlign: TextAlign.left,
                  controller: ref.watch(publishTextControllerProvider)),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                //publish bar
                Container(
                  decoration: const BoxDecoration(
                      border: Border(),
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                  child: Column(children: [
                    const Text("json"),
                    IconButton(
                        // Json Button
                        onPressed: () {},
                        icon: const Icon(Icons.radio_button_checked)),
                  ]),
                ),

                /// Publish Button
                ElevatedButton(
                  onPressed: () {
                    final snackBar = SnackBar(
                        backgroundColor: const Color.fromARGB(69, 0, 255, 13),
                        showCloseIcon: true,
                        content: Center(
                          child: Text(
                            "Published : ${ref.watch(publishTextControllerProvider).text}",
                            style: const TextStyle(
                                color: Color.fromARGB(255, 2, 43, 0)),
                          ),
                        ));
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    if (ref.watch(publishTextControllerProvider).text == "") {
                      publish(" ", ref);
                    } else {
                      publish(
                          ref.watch(publishTextControllerProvider).text, ref);
                    }
                  },
                  style: ElevatedButton.styleFrom(),
                  child: const Text(
                    "Publish",
                  ),
                ),
              ]),
              Padding(
                  padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height / 4,
                    child: JsonEditor.string(
                      jsonString:
                          ref.watch(currentMessageProvider)[root] ?? "{}",
                      onValueChanged: (value) {
                        valueTextController.text = value.toString();
                      },
                    ),
                  )),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        const Text("QoS"),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DropdownButton(
                            value: ref.watch(qos),
                            hint: Text(ref.watch(qos) == MqttQos.atMostOnce
                                ? "0"
                                : ref.watch(qos) == MqttQos.atLeastOnce
                                    ? "1"
                                    : "2"),
                            items: const [
                              DropdownMenuItem(
                                value: MqttQos.atMostOnce,
                                child: Text("0"),
                              ),
                              DropdownMenuItem(
                                value: MqttQos.atLeastOnce,
                                child: Text("1"),
                              ),
                              DropdownMenuItem(
                                value: MqttQos.exactlyOnce,
                                child: Text("2"),
                              )
                            ],
                            onChanged: (value) {
                              ref.read(qos.notifier).state = value!;
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox.adaptive(
                            value: ref.watch(retain),
                            onChanged: (value) =>
                                ref.read(retain.notifier).state = value!),
                        const Text("Retain")
                      ],
                    ),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
