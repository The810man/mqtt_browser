// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ThemeSettings _$ThemeSettingsFromJson(
  Map<String, dynamic> json,
) => _ThemeSettings(
  primaryColor: json['primaryColor'] == null
      ? const Color(0xFF00BCD4)
      : const ColorConverter().fromJson((json['primaryColor'] as num).toInt()),
  accentColor: json['accentColor'] == null
      ? const Color(0xFF00E5FF)
      : const ColorConverter().fromJson((json['accentColor'] as num).toInt()),
  backgroundColor: json['backgroundColor'] == null
      ? const Color(0xFF0A0E27)
      : const ColorConverter().fromJson(
          (json['backgroundColor'] as num).toInt(),
        ),
  isDarkMode: json['isDarkMode'] as bool? ?? true,
);

Map<String, dynamic> _$ThemeSettingsToJson(
  _ThemeSettings instance,
) => <String, dynamic>{
  'primaryColor': const ColorConverter().toJson(instance.primaryColor),
  'accentColor': const ColorConverter().toJson(instance.accentColor),
  'backgroundColor': const ColorConverter().toJson(instance.backgroundColor),
  'isDarkMode': instance.isDarkMode,
};
