import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String _primaryColorKey = 'primary_color';
  static const String _accentColorKey = 'accent_color';
  static const String _backgroundColorKey = 'background_color';
  static const String _isDarkModeKey = 'is_dark_mode';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Preset colors
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

  Color _getPrimaryColor() {
    final colorValue = _prefs.getInt(_primaryColorKey);
    return colorValue != null
        ? Color(colorValue)
        : const Color(0xFF00BCD4); // Cyan
  }

  Color _getAccentColor() {
    final colorValue = _prefs.getInt(_accentColorKey);
    return colorValue != null
        ? Color(colorValue)
        : const Color(0xFF00E5FF); // Light Cyan
  }

  Color _getBackgroundColor() {
    final colorValue = _prefs.getInt(_backgroundColorKey);
    return colorValue != null
        ? Color(colorValue)
        : const Color(0xFF0A0E27); // Dark
  }

  bool _isDarkMode() {
    return _prefs.getBool(_isDarkModeKey) ?? true;
  }

  Future<void> setPrimaryColor(Color color) async {
    await _prefs.setInt(_primaryColorKey, color.value);
  }

  Future<void> setAccentColor(Color color) async {
    await _prefs.setInt(_accentColorKey, color.value);
  }

  Future<void> setBackgroundColor(Color color) async {
    await _prefs.setInt(_backgroundColorKey, color.value);
  }

  Future<void> setDarkMode(bool isDark) async {
    await _prefs.setBool(_isDarkModeKey, isDark);
  }

  ThemeData buildTheme() {
    final primaryColor = _getPrimaryColor();
    final accentColor = _getAccentColor();
    final backgroundColor = _getBackgroundColor();
    final isDark = _isDarkMode();

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: isDark ? backgroundColor : Colors.white,
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: primaryColor,
        secondary: accentColor,
        surface: isDark ? backgroundColor.withAlpha(240) : Colors.grey[50]!,
        error: Colors.red,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: isDark ? Colors.white : Colors.black,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: isDark ? backgroundColor.withAlpha(230) : Colors.grey[100],
        elevation: 2,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? backgroundColor.withAlpha(200) : Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: accentColor, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
