import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'theme_settings.freezed.dart';
part 'theme_settings.g.dart';

class ColorConverter implements JsonConverter<Color, int> {
  const ColorConverter();

  @override
  Color fromJson(int json) => Color(json);

  @override
  int toJson(Color object) => object.value;
}

@freezed
abstract class ThemeSettings with _$ThemeSettings {
  const factory ThemeSettings({
    @ColorConverter() @Default(Color(0xFF00BCD4)) Color primaryColor,
    @ColorConverter() @Default(Color(0xFF00E5FF)) Color accentColor,
    @ColorConverter() @Default(Color(0xFF0A0E27)) Color backgroundColor,
    @Default(true) bool isDarkMode,
  }) = _ThemeSettings;

  factory ThemeSettings.fromJson(Map<String, dynamic> json) =>
      _$ThemeSettingsFromJson(json);
}
