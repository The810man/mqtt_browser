import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_browser/frontend/widgets/reactive_widgets/setup_widget.dart';
import 'package:mqtt_browser/main.dart';

class ConnectionsWidget extends ConsumerWidget {
  const ConnectionsWidget(
      {super.key,
      required this.hostTextController,
      required this.portTextController,
      required this.height,
      required this.width});
  final TextEditingController hostTextController;
  final TextEditingController portTextController;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
            color: ref.watch(themeDataProvider).colorScheme.tertiary,
            shape: BoxShape.rectangle,
            border: Border.all(
                color: ref.watch(themeDataProvider).colorScheme.secondary,
                width: 2),
            borderRadius: const BorderRadius.all(Radius.circular(15)),
            boxShadow: [
              BoxShadow(
                  offset: const Offset(0, 4),
                  color: ref.watch(themeDataProvider).colorScheme.tertiary,
                  spreadRadius: 3,
                  blurRadius: 5)
            ]),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.add_circle_outline_rounded,
                      size: 35,
                    )),
                const Text(
                  "MQTT-Connections",
                  style: TextStyle(fontSize: 20),
                )
              ],
            ),
            SizedBox(
              height: height - 80,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (var connection in ref.watch(fileProvider))
                      Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: ref
                                    .watch(themeDataProvider)
                                    .colorScheme
                                    .tertiary,
                                shape: const BeveledRectangleBorder()),
                            onPressed: () {
                              hostTextController.text = connection["host"];
                              ref.read(hostProvider.notifier).state =
                                  connection["host"];
                              portTextController.text =
                                  connection["port"].toString();
                              ref.read(portProvider.notifier).state =
                                  connection["port"].toString();
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "${connection["host"]}:${connection["port"]}",
                                  style: const TextStyle(),
                                )
                              ],
                            )),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
