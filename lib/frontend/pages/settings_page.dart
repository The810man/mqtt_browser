import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../responsive.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final mobile = isMobile(context);
    final pad = screenPadding(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: pad,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Theme Settings',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),

              Card(
                child: SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Enable/disable dark theme'),
                  value: theme.brightness == Brightness.dark,
                  onChanged: (value) {
                    ref.read(themeServiceProvider.notifier).setDarkMode(value);
                  },
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Primary Color',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: mobile ? 10 : 8,
                runSpacing: mobile ? 10 : 8,
                children: ThemeService.presetColors.entries.map((entry) {
                  final isSelected = theme.primaryColor == entry.value;
                  return GestureDetector(
                    onTap: () => ref
                        .read(themeServiceProvider.notifier)
                        .setPrimaryColor(entry.value),
                    child: Container(
                      width: mobile ? 52 : 60,
                      height: mobile ? 52 : 60,
                      decoration: BoxDecoration(
                        color: entry.value,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: entry.value.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                )
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              Text(
                'Accent Color',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: mobile ? 10 : 8,
                runSpacing: mobile ? 10 : 8,
                children: ThemeService.presetColors.entries.map((entry) {
                  final lighter = entry.value.withValues(alpha: 0.7);
                  final isSelected = theme.colorScheme.secondary == lighter;
                  return GestureDetector(
                    onTap: () => ref
                        .read(themeServiceProvider.notifier)
                        .setAccentColor(lighter),
                    child: Container(
                      width: mobile ? 52 : 60,
                      height: mobile ? 52 : 60,
                      decoration: BoxDecoration(
                        color: lighter,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: mobile ? 52 : 48,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset to Defaults'),
                  onPressed: () async {
                    ref
                        .read(themeServiceProvider.notifier)
                        .setPrimaryColor(const Color(0xFF00BCD4));
                    ref.read(themeServiceProvider.notifier).setDarkMode(true);
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
