import 'package:flutter/material.dart';

class AppTheme {
  static const Color mint = Color(0xFFAAC6AD);
  static const Color violet = Color(0xFFCBAACB);
  static const Color peach = Color(0xFFF6E6D0);
  static const Color white = Color(0xFFFFFCF8);
  static const Color darkText = Color(0xFF3A3A3A);
  static const Color bgLight = Color(0xFFF9FAFB);

  static const Color accent = Color(0xFFB5A2C4);

  static final ThemeData light = ThemeData(
    scaffoldBackgroundColor: bgLight,

    //font
    fontFamily: 'Nunito',

    colorScheme: ColorScheme.fromSeed(
      seedColor: mint,
      primary: mint,
      secondary: violet,
    ),

    // size font
    textTheme: const TextTheme(
      // Default text style for the app
      bodyMedium: TextStyle(fontSize: 15.0, color: darkText),
      // Style for things like ListTiles
      titleMedium: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w600),
      // Style for larger headings
      titleLarge: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
      // Style for buttons
      labelLarge: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: darkText,
      elevation: 1,
      shadowColor: Colors.black12,
      centerTitle: false,
      // Make app bar text bigger too
      titleTextStyle: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: darkText,
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: mint, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(color: Colors.black38),
      // Make input text bigger
      labelStyle: const TextStyle(fontSize: 16),
    ),
  );

  static ThemeData get lightTheme => light;
}