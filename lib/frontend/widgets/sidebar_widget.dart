import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_browser/constants.dart';
import 'package:mqtt_browser/frontend/responsive.dart';
import 'package:mqtt_browser/providers/providers.dart';

class Sidebarwidget extends ConsumerWidget {
  const Sidebarwidget({super.key, required this.controller});
  final SidebarXController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mobile = isMobile(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final drawerWidth = mobile ? screenWidth * 0.85 : screenWidth / 3;
    final sliderWidth = mobile ? screenWidth * 0.6 : screenWidth / 4;

    Color canvasColor = ref.watch(themeProvider).colorScheme.primary;

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
          color: ref.watch(themeProvider).colorScheme.secondary,
        ),
        selectedTextStyle: TextStyle(
          color: ref.watch(themeProvider).colorScheme.secondary,
        ),
        itemTextPadding: const EdgeInsets.only(left: 5),
        selectedItemTextPadding: const EdgeInsets.only(left: 5),
        itemDecoration: BoxDecoration(border: Border.all(color: canvasColor)),
        selectedItemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color.fromARGB(80, 0, 0, 0)),
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(0, 0, 0, 0),
              ref.watch(themeProvider).colorScheme.secondary,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(64, 0, 0, 0).withValues(alpha: 0.28),
              blurRadius: 30,
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white, size: 20),
      ),
      extendedTheme: SidebarXTheme(
        width: drawerWidth,
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
                border: Border.all(color: Colors.black),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Text(
                        'Tree View Settings',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(Icons.settings, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      items: [
        SidebarXItem(
          iconBuilder: (selected, hovered) => SizedBox(
            width: sliderWidth,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: _SettingsContent(sliderWidth: sliderWidth),
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsContent extends ConsumerWidget {
  const _SettingsContent({required this.sliderWidth});
  final double sliderWidth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const _SectionHeader('Node Settings'),
        _SliderRow(
          icon: Icons.swap_horiz_rounded,
          label: 'Node Distance',
          value: ref.watch(spaceSliderProvider),
          min: 0,
          max: 100,
          onChanged: (value) {
            ref.read(spaceSliderProvider.notifier).set(value);
            ref.read(sharedPreferencesProvider.future).then(
              (prefs) => prefs.setDouble(
                SharedPreferenceKey.nodeDistance.stringValue,
                value,
              ),
            );
          },
        ),
        _SliderRow(
          icon: Icons.swap_horiz_rounded,
          label: 'Node Thickness',
          value: ref.watch(thicknessSliderProvider),
          min: 0,
          max: 25,
          onChanged: (value) {
            ref.read(thicknessSliderProvider.notifier).set(value);
            ref.read(sharedPreferencesProvider.future).then(
              (prefs) => prefs.setDouble(
                SharedPreferenceKey.nodeThickness.stringValue,
                value,
              ),
            );
          },
        ),
        _SliderRow(
          icon: Icons.swap_horiz_rounded,
          label: 'Node Origin',
          value: ref.watch(originSliderProvider),
          min: 0,
          max: 1,
          onChanged: (value) {
            ref.read(originSliderProvider.notifier).set(value);
            ref.read(sharedPreferencesProvider.future).then(
              (prefs) => prefs.setDouble(
                SharedPreferenceKey.nodeOrigin.stringValue,
                value,
              ),
            );
          },
        ),
        _SliderRow(
          icon: Icons.swap_horiz_rounded,
          label: 'Node Height',
          value: ref.watch(nodeHeightProvider),
          min: 0,
          max: 2,
          onChanged: (value) {
            ref.read(nodeHeightProvider.notifier).set(value);
            ref.read(sharedPreferencesProvider.future).then(
              (prefs) => prefs.setDouble(
                SharedPreferenceKey.nodeHeight.stringValue,
                value,
              ),
            );
          },
        ),
        const _Divider(),
        const _SectionHeader('Line Settings'),
        _SwitchRow(
          icon: Icons.question_mark_rounded,
          label: 'Rounded Connections',
          value: ref.watch(roundedLineSwitchProvider),
          onChanged: (value) {
            ref.read(sharedPreferencesProvider.future).then(
              (prefs) => prefs.setBool(
                SharedPreferenceKey.roundLines.stringValue,
                value,
              ),
            );
            ref.read(roundedLineSwitchProvider.notifier).set(value);
          },
        ),
        _SwitchRow(
          icon: Icons.question_mark_rounded,
          label: 'Connect Nodes',
          value: ref.watch(connectLinesSwitchProvider),
          onChanged: (value) {
            ref.read(sharedPreferencesProvider.future).then(
              (prefs) => prefs.setBool(
                SharedPreferenceKey.connectNodes.stringValue,
                value,
              ),
            );
            ref.read(connectLinesSwitchProvider.notifier).set(value);
          },
        ),
        const _Divider(),
        const _SectionHeader('Display'),
        _SwitchRow(
          icon: Icons.dark_mode,
          label: 'Dark Mode',
          value: ref.watch(colorModeProvider),
          onChanged: (value) {
            ref.read(sharedPreferencesProvider.future).then(
              (prefs) => prefs.setBool(
                SharedPreferenceKey.darkMode.stringValue,
                value,
              ),
            );
            ref.read(colorModeProvider.notifier).set(value);
          },
        ),
        _SliderRow(
          icon: Icons.timer_outlined,
          label: 'Blink Delay (ms)',
          value: ref.watch(blinkDelayProvider),
          min: 0,
          max: 1500,
          onChanged: (value) {
            ref.read(sharedPreferencesProvider.future).then(
              (prefs) => prefs.setDouble(
                SharedPreferenceKey.blinkDelay.stringValue,
                value,
              ),
            );
            ref.read(blinkDelayProvider.notifier).set(value);
          },
        ),
        _SliderRow(
          icon: Icons.timer,
          label: 'Blink Duration (ms)',
          value: ref.watch(blinkDurationProvider),
          min: 0,
          max: 1500,
          onChanged: (value) {
            ref.read(sharedPreferencesProvider.future).then(
              (prefs) => prefs.setDouble(
                SharedPreferenceKey.blinkDuration.stringValue,
                value,
              ),
            );
            ref.read(blinkDurationProvider.notifier).set(value);
          },
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(color: Colors.white30, height: 16, thickness: 0.5);
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Slider(
            min: min,
            max: max,
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Switch.adaptive(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
