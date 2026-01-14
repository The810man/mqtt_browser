import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/theme_service.dart';

final themeServiceProvider = FutureProvider<ThemeService>((ref) async {
  final themeService = ThemeService();
  await themeService.init();
  return themeService;
});

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeData>((ref) {
  return ThemeNotifier(ref);
});

class ThemeNotifier extends StateNotifier<ThemeData> {
  final Ref _ref;

  ThemeNotifier(this._ref) : super(ThemeData.dark()) {
    _init();
  }

  void _init() async {
    final themeService = await _ref.read(themeServiceProvider.future);
    state = themeService.buildTheme();
  }

  Future<void> setPrimaryColor(Color color) async {
    final themeService = await _ref.read(themeServiceProvider.future);
    await themeService.setPrimaryColor(color);
    state = themeService.buildTheme();
  }

  Future<void> setAccentColor(Color color) async {
    final themeService = await _ref.read(themeServiceProvider.future);
    await themeService.setAccentColor(color);
    state = themeService.buildTheme();
  }

  Future<void> setBackgroundColor(Color color) async {
    final themeService = await _ref.read(themeServiceProvider.future);
    await themeService.setBackgroundColor(color);
    state = themeService.buildTheme();
  }

  Future<void> setDarkMode(bool isDark) async {
    final themeService = await _ref.read(themeServiceProvider.future);
    await themeService.setDarkMode(isDark);
    state = themeService.buildTheme();
  }
}
