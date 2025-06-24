import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_browser/main.dart';

class Sidebarwidget extends ConsumerWidget {
  const Sidebarwidget({
    super.key,
    required this.controller,
  });
  final SidebarXController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Color canvasColor = ref.watch(themeDataProvider).colorScheme.primary;
    return SidebarX(
        showToggleButton: false,
        controller: controller,
        theme: SidebarXTheme(
          margin: const EdgeInsets.all(0),
          decoration: BoxDecoration(
            color: canvasColor,
            borderRadius: BorderRadius.circular(1),
          ),
          textStyle: TextStyle(
              color: ref.watch(themeDataProvider).colorScheme.secondary),
          selectedTextStyle: TextStyle(
              color: ref.watch(themeDataProvider).colorScheme.secondary),
          itemTextPadding: const EdgeInsets.only(left: 5),
          selectedItemTextPadding: const EdgeInsets.only(left: 5),
          itemDecoration: BoxDecoration(
            border: Border.all(color: canvasColor),
          ),
          selectedItemDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color.fromARGB(80, 0, 0, 0),
            ),
            gradient: LinearGradient(
              colors: [
                const Color.fromARGB(0, 0, 0, 0),
                ref.watch(themeDataProvider).colorScheme.secondary
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(64, 0, 0, 0).withOpacity(0.28),
                blurRadius: 30,
              )
            ],
          ),
          iconTheme: const IconThemeData(
            color: Colors.white,
            size: 20,
          ),
        ),
        extendedTheme: SidebarXTheme(
          width: MediaQuery.of(context).size.width / 3,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 3),
            color: const Color.fromARGB(104, 128, 128, 128),
          ),
        ),
        headerBuilder: (context, extended) {
          return SafeArea(
            child: SizedBox(
              height: 50,
              child: Container(
                decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 0, 0, 0),
                    border: Border.all(
                      color: Colors.black,
                    )),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Tree View Settings",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w800),
                    ),
                    Icon(
                      Icons.settings,
                      color: Colors.white,
                    )
                  ],
                ),
              ),
            ),
          );
        },
        items: [
          SidebarXItem(
            iconWidget: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width / 4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Line Settings",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(
                        Icons.swap_horiz_rounded,
                        color: Colors.white,
                      ),
                      const Text(
                        "Node Distance",
                        style: TextStyle(color: Colors.white),
                      ),
                      Slider(
                        min: 0,
                        max: 100,
                        value: ref.watch(spaceSliderProvider),
                        onChanged: (value) {
                          ref.watch(sharedPreferencesProvider)!.setDouble(
                              SharedPreferenceKey.nodeDistance.stringValue,
                              value);
                          ref.read(spaceSliderProvider.notifier).state = value;
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(
                        Icons.swap_horiz_rounded,
                        color: Colors.white,
                      ),
                      const Text(
                        "Node Tickness",
                        style: TextStyle(color: Colors.white),
                      ),
                      Slider(
                        min: 0,
                        max: 25,
                        value: ref.watch(thicknessSliderProvider),
                        onChanged: (value) {
                          ref.watch(sharedPreferencesProvider)!.setDouble(
                              SharedPreferenceKey.nodeThickness.stringValue,
                              value);
                          ref.read(thicknessSliderProvider.notifier).state =
                              value;
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(
                        Icons.swap_horiz_rounded,
                        color: Colors.white,
                      ),
                      const Text(
                        "Node Origin",
                        style: TextStyle(color: Colors.white),
                      ),
                      Slider(
                        min: 0,
                        max: 1,
                        value: ref.watch(originSliderProvider),
                        onChanged: (value) {
                          ref.watch(sharedPreferencesProvider)!.setDouble(
                              SharedPreferenceKey.nodeOrigin.stringValue,
                              value);
                          ref.read(originSliderProvider.notifier).state = value;
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(
                        Icons.swap_horiz_rounded,
                        color: Colors.white,
                      ),
                      const Text(
                        "Node Height",
                        style: TextStyle(color: Colors.white),
                      ),
                      Slider(
                        min: 0,
                        max: 2,
                        value: ref.watch(nodeHeightProvider),
                        onChanged: (value) {
                          ref.watch(sharedPreferencesProvider)!.setDouble(
                              SharedPreferenceKey.nodeHeight.stringValue,
                              value);
                          ref.read(nodeHeightProvider.notifier).state = value;
                        },
                      ),
                    ],
                  ),

                  /// Spacer Line
                  Container(
                    width: MediaQuery.of(context).size.width / 4,
                    decoration: BoxDecoration(
                        border: Border.all(
                            width: 1,
                            color: const Color.fromARGB(255, 255, 255, 255))),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Line Settings",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(
                        Icons.question_mark_rounded,
                        color: Colors.white,
                      ),
                      const Text(
                        "Rounded Line Connections",
                        style: TextStyle(color: Colors.white),
                      ),
                      Switch.adaptive(
                          value: ref.watch(roundedLineSwitchProvider),
                          onChanged: (bool value) {
                            ref.watch(sharedPreferencesProvider)!.setBool(
                                SharedPreferenceKey.roundLines.stringValue,
                                value);
                            ref.read(roundedLineSwitchProvider.notifier).state =
                                value;
                          })
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(
                        Icons.question_mark_rounded,
                        color: Colors.white,
                      ),
                      const Text(
                        "Connect Nodes",
                        style: TextStyle(color: Colors.white),
                      ),
                      Switch.adaptive(
                          value: ref.watch(connectLinesSwitchProvider),
                          onChanged: (bool value) {
                            ref.watch(sharedPreferencesProvider)!.setBool(
                                SharedPreferenceKey.connectNodes.stringValue,
                                value);
                            ref
                                .read(connectLinesSwitchProvider.notifier)
                                .state = value;
                          }),
                    ],
                  ),

                  /// Spacer Line
                  Container(
                    width: MediaQuery.of(context).size.width / 4,
                    decoration: BoxDecoration(
                        border: Border.all(
                            width: 1,
                            color: const Color.fromARGB(255, 255, 255, 255))),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(
                        Icons.question_mark_rounded,
                        color: Colors.white,
                      ),
                      const Text(
                        "Dark Mode",
                        style: TextStyle(color: Colors.white),
                      ),
                      Switch.adaptive(
                          value: ref.watch(colorModeProvider.notifier).state,
                          onChanged: (bool) {
                            ref.watch(sharedPreferencesProvider)!.setBool(
                                SharedPreferenceKey.darkMode.stringValue, bool);
                            ref.watch(colorModeProvider.notifier).state =
                                !ref.watch(colorModeProvider);
                          }),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(
                        Icons.swap_horiz_rounded,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        "Node Blink delay in ms",
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(width: 1),
                      Slider(
                        min: 0,
                        max: 1500,
                        value: ref.watch(blinkDelayProvider),
                        onChanged: (value) {
                          ref.watch(sharedPreferencesProvider)!.setDouble(
                              SharedPreferenceKey.blinkDelay.stringValue,
                              value);
                          ref.read(blinkDelayProvider.notifier).state = value;
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(
                        Icons.swap_horiz_rounded,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        "Node Blink duration in ms",
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(width: 1),
                      Slider(
                        min: 0,
                        max: 1500,
                        value: ref.watch(blinkDurationProvider),
                        onChanged: (value) {
                          ref.watch(sharedPreferencesProvider)!.setDouble(
                              SharedPreferenceKey.blinkDuration.stringValue,
                              value);
                          ref.read(blinkDurationProvider.notifier).state =
                              value;
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ]);
  }
}
