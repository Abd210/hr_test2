import 'package:flutter/material.dart';

// Updated color palette as requested
const Color primaryDarkGreen = Color(0xFF1F4529);
const Color secondaryGreen = Color(0xFF47663B);
const Color backgroundLight = Color(0xFFE8ECD7);
const Color accentColor = Color(0xFFEED3B1);

final ThemeData appTheme = ThemeData(
  primaryColor: primaryDarkGreen,
  scaffoldBackgroundColor: backgroundLight,
  fontFamily: 'Roboto',
  colorScheme: ColorScheme.fromSwatch().copyWith(
    primary: primaryDarkGreen,
    secondary: secondaryGreen,
    background: backgroundLight,
    surface: Colors.white,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: primaryDarkGreen,
    elevation: 0,
    centerTitle: true,
    toolbarHeight: 64,
  ),
  cardTheme: CardTheme(
    color: Colors.white,
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    margin: EdgeInsets.zero,
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: secondaryGreen),
      borderRadius: BorderRadius.circular(12),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: primaryDarkGreen),
      borderRadius: BorderRadius.circular(12),
    ),
    fillColor: Colors.white,
    filled: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    labelStyle: TextStyle(color: primaryDarkGreen),
    hintStyle: TextStyle(color: secondaryGreen),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryDarkGreen,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
  ),
);
