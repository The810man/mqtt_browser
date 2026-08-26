import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'shared_preferences_provider.dart';
import '../models/theme_settings.dart';

part 'theme_provider.g.dart';

@riverpod
class ThemeService extends _$ThemeService {
  static const String _primaryColorKey = 'primary_color';
  static const String _accentColorKey = 'accent_color';
  static const String _backgroundColorKey = 'background_color';
  static const String _isDarkModeKey = 'is_dark_mode';

  static const Map<String, Color> presetColors = {
    'Cyan': Color(0xFF00BCD4),
    'Blue': Color(0xFF2196F3),
    'Indigo': Color(0xFF3F51B5),
    'Purple': Color(0xFF9C27B0),
    'Pink': Color(0xFFE91E63),
    'Red': Color(0xFFF44336),
    'Orange': Color(0xFFFF9800),
    'Lime': Color(0xFFCDDC39),
    'Green': Color(0xFF4CAF50),
    'Teal': Color(0xFF009688),
  };

  @override
  Future<ThemeSettings> build() async {
    final prefs = await ref.watch(sharedPreferencesProvider.future);
    return _getSettings(prefs);
  }

  Future<SharedPreferences> get _prefs async =>
      await ref.read(sharedPreferencesProvider.future);

  ThemeSettings _getSettings(SharedPreferences prefs) {
    return ThemeSettings(
      primaryColor: _getColor(prefs, _primaryColorKey, const Color(0xFF00BCD4)),
      accentColor: _getColor(prefs, _accentColorKey, const Color(0xFF00E5FF)),
      backgroundColor: _getColor(
        prefs,
        _backgroundColorKey,
        const Color(0xFF0A0E27),
      ),
      isDarkMode: prefs.getBool(_isDarkModeKey) ?? true,
    );
  }

  Color _getColor(SharedPreferences prefs, String key, Color defaultColor) {
    final colorValue = prefs.getInt(key);
    return colorValue != null ? Color(colorValue) : defaultColor;
  }

  Future<void> setPrimaryColor(Color color) async {
    final prefs = await _prefs;
    await prefs.setInt(_primaryColorKey, color.value);
    final current = await future;
    state = AsyncData(current.copyWith(primaryColor: color));
  }

  Future<void> setAccentColor(Color color) async {
    final prefs = await _prefs;
    await prefs.setInt(_accentColorKey, color.value);
    final current = await future;
    state = AsyncData(current.copyWith(accentColor: color));
  }

  Future<void> setBackgroundColor(Color color) async {
    final prefs = await _prefs;
    await prefs.setInt(_backgroundColorKey, color.value);
    final current = await future;
    state = AsyncData(current.copyWith(backgroundColor: color));
  }

  Future<void> setDarkMode(bool isDark) async {
    final prefs = await _prefs;
    await prefs.setBool(_isDarkModeKey, isDark);
    final current = await future;
    state = AsyncData(current.copyWith(isDarkMode: isDark));
  }

  ThemeData buildTheme(ThemeSettings settings) {
    return ThemeData(
      useMaterial3: true,
      brightness: settings.isDarkMode ? Brightness.dark : Brightness.light,
      primaryColor: settings.primaryColor,
      scaffoldBackgroundColor: settings.isDarkMode
          ? settings.backgroundColor
          : Colors.white,
      colorScheme: ColorScheme(
        brightness: settings.isDarkMode ? Brightness.dark : Brightness.light,
        primary: settings.primaryColor,
        secondary: settings.accentColor,
        surface: settings.isDarkMode
            ? settings.backgroundColor.withAlpha(240)
            : Colors.grey[50]!,
        error: Colors.red,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: settings.isDarkMode ? Colors.white : Colors.black,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: settings.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: settings.isDarkMode
            ? settings.backgroundColor.withAlpha(230)
            : Colors.grey[100],
        elevation: 2,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: settings.isDarkMode
            ? settings.backgroundColor.withAlpha(200)
            : Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: settings.primaryColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: settings.accentColor, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: settings.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}

@riverpod
ThemeData theme(Ref ref) {
  final themeSettings = ref.watch(themeServiceProvider);
  return themeSettings.maybeWhen(
    data: (settings) =>
        ref.watch(themeServiceProvider.notifier).buildTheme(settings),
    orElse: () => ThemeData.dark(),
  );
}
