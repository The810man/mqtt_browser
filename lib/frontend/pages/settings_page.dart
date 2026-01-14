import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/theme_service.dart';
import '../../providers/theme_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme Section Header
            Text(
              'Theme Settings',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            // Dark Mode Toggle
            Card(
              child: SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Enable/disable dark theme'),
                value: theme.brightness == Brightness.dark,
                onChanged: (value) {
                  ref.read(themeProvider.notifier).setDarkMode(value);
                },
              ),
            ),
            const SizedBox(height: 16),

            // Primary Color Picker
            Text(
              'Primary Color',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ThemeService.presetColors.entries.map((entry) {
                return GestureDetector(
                  onTap: () {
                    ref
                        .read(themeProvider.notifier)
                        .setPrimaryColor(entry.value);
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: entry.value,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.primaryColor == entry.value
                            ? Colors.white
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: theme.primaryColor == entry.value
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Accent Color Picker
            Text(
              'Accent Color',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ThemeService.presetColors.entries.map((entry) {
                final lighterColor = entry.value.withValues(alpha: 0.7);
                return GestureDetector(
                  onTap: () {
                    ref
                        .read(themeProvider.notifier)
                        .setAccentColor(lighterColor);
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: lighterColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.colorScheme.secondary == lighterColor
                            ? Colors.white
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Reset to Defaults
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Reset to Defaults'),
                onPressed: () async {
                  final service = ThemeService();
                  await service.init();
                  ref
                      .read(themeProvider.notifier)
                      .setPrimaryColor(const Color(0xFF00BCD4));
                  ref.read(themeProvider.notifier).setDarkMode(true);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
