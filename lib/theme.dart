import 'package:flutter/material.dart';

final ThemeData appLightTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.indigo,
  fontFamily: 'Inter',
  textTheme: const TextTheme(
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
    titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
  ),
);

final ThemeData appDarkTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.indigo,
  fontFamily: 'Inter',
  textTheme: const TextTheme(
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
    titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
  ),
);
