import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:loading_icon_button/loading_icon_button.dart';
import 'package:mqtt_browser/frontend/widgets/reactive_widgets/setup_widget.dart';
import 'package:mqtt_browser/main.dart';

class SetupSettings extends ConsumerWidget {
  const SetupSettings({
    super.key,
    required this.hostTextController,
    required this.portTextController,
    required this.startClient,
    required this.height,
    required this.width,
  });
  final TextEditingController hostTextController;
  final TextEditingController portTextController;
  final void Function(WidgetRef) startClient;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      //border as round spacer
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
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            const Align(
              alignment: Alignment(-0.95, 0),
              child: Text(
                "Input Host",
                textAlign: TextAlign.start,
                overflow: TextOverflow.clip,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontStyle: FontStyle.normal,
                  fontSize: 16,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  TextField(
                    controller: hostTextController,
                    obscureText: false,
                    textAlign: TextAlign.start,
                    maxLines: 1,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4.0),
                        borderSide: BorderSide(
                            color: ref
                                .watch(themeDataProvider)
                                .colorScheme
                                .secondary,
                            width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4.0),
                        borderSide: BorderSide(
                            color: ref
                                .watch(themeDataProvider)
                                .colorScheme
                                .secondary,
                            width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4.0),
                        borderSide: BorderSide(
                            color: ref
                                .watch(themeDataProvider)
                                .colorScheme
                                .secondary,
                            width: 1),
                      ),
                      hintText: "e.g: localhost",
                      hintStyle: const TextStyle(
                        fontWeight: FontWeight.w300,
                        fontStyle: FontStyle.normal,
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor:
                          ref.watch(themeDataProvider).colorScheme.tertiary,
                      isDense: false,
                      contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                    ),
                    onChanged: (String text) {
                      ref.read(hostProvider.notifier).state = text;
                    },
                  ),
                  Divider(
                    color: ref.watch(themeDataProvider).colorScheme.secondary,
                    height: 16,
                    thickness: 0,
                    indent: 0,
                    endIndent: 0,
                  ),
                  const Text(
                    "Input Port",
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontStyle: FontStyle.normal,
                      fontSize: 16,
                    ),
                  ),
                  TextField(
                    controller: portTextController,
                    obscureText: false,
                    textAlign: TextAlign.start,
                    maxLines: 1,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4.0),
                        borderSide: BorderSide(
                            color: ref
                                .watch(themeDataProvider)
                                .colorScheme
                                .secondary,
                            width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4.0),
                        borderSide: BorderSide(
                            color: ref
                                .watch(themeDataProvider)
                                .colorScheme
                                .secondary,
                            width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4.0),
                        borderSide: BorderSide(
                            color: ref
                                .watch(themeDataProvider)
                                .colorScheme
                                .secondary,
                            width: 1),
                      ),
                      hintText: "e.g.: 1883",
                      hintStyle: const TextStyle(
                        fontWeight: FontWeight.w300,
                        fontStyle: FontStyle.normal,
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor:
                          ref.watch(themeDataProvider).colorScheme.tertiary,
                      isDense: false,
                      contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                    ),
                    onChanged: (String text) {
                      ref.read(portProvider.notifier).state = text;
                    },
                  ),
                  Divider(
                    color: ref.watch(themeDataProvider).colorScheme.secondary,
                    height: 16,
                    thickness: 0,
                    indent: 0,
                    endIndent: 0,
                  ),

                  /// Lower Button bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /// Delete Button
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              surfaceTintColor: ref
                                  .watch(themeDataProvider)
                                  .colorScheme
                                  .tertiary,
                              backgroundColor: ref
                                  .watch(themeDataProvider)
                                  .colorScheme
                                  .tertiary,
                              shadowColor: ref
                                  .watch(themeDataProvider)
                                  .colorScheme
                                  .tertiary,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  color: ref
                                      .watch(themeDataProvider)
                                      .colorScheme
                                      .secondary,
                                ),
                                borderRadius: BorderRadius.circular(5.0),
                              )),
                          onPressed: () {},
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.delete_forever_rounded),
                              Text("Delete"),
                            ],
                          )),

                      /// Save Button
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              surfaceTintColor: ref
                                  .watch(themeDataProvider)
                                  .colorScheme
                                  .tertiary,
                              backgroundColor: ref
                                  .watch(themeDataProvider)
                                  .colorScheme
                                  .tertiary,
                              shadowColor: ref
                                  .watch(themeDataProvider)
                                  .colorScheme
                                  .tertiary,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  color: ref
                                      .watch(themeDataProvider)
                                      .colorScheme
                                      .secondary,
                                ),
                                borderRadius: BorderRadius.circular(5.0),
                              )),
                          onPressed: () {
                            final oldState = ref.read(fileProvider);
                            ref.read(fileProvider.notifier).addEntry([
                              {
                                "host": hostTextController.text,
                                "port": int.parse(portTextController.text)
                              }
                            ]);
                            ref.read(fileProvider.notifier).setConnections(ref);
                          },
                          child: const Row(
                            children: [
                              Icon(Icons.save),
                              Text("Save"),
                            ],
                          )),

                      /// Connect Button
                      ArgonButton(
                          color:
                              ref.watch(themeDataProvider).colorScheme.tertiary,
                          height: 32,
                          width: 90,
                          borderRadius: 5.0,
                          loader: Container(
                            padding: const EdgeInsets.all(10),
                            child: SpinKitDualRing(
                              size: 10,
                              color: ref
                                  .watch(themeDataProvider)
                                  .colorScheme
                                  .primary,
                            ),
                          ),
                          onTap: ((startLoading, stopLoading, btnState) {
                            startClient(ref);
                            if (btnState == ArgonButtonState.idle) {
                              startLoading();
                            }
                          }),
                          child: Container(
                            decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                      offset: const Offset(0, 0),
                                      color: ref
                                          .watch(themeDataProvider)
                                          .colorScheme
                                          .tertiary,
                                      spreadRadius: 1,
                                      blurRadius: 1)
                                ],
                                color: ref
                                    .watch(themeDataProvider)
                                    .colorScheme
                                    .tertiary,
                                shape: BoxShape.rectangle,
                                border: Border.all(
                                    color: ref
                                        .watch(themeDataProvider)
                                        .colorScheme
                                        .secondary,
                                    width: 1),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(5))),
                            child: const Row(
                              children: [
                                Icon(Icons.offline_bolt_rounded),
                                SizedBox(
                                  width: 5,
                                  height: 50,
                                ),
                                Text("Connect"),
                              ],
                            ),
                          )),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
