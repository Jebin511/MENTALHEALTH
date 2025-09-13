import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
final ThemeData mentalHealthTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: const Color(0xFFEADFF0),
  primaryColor: const Color(0xFFA786DF), 
  colorScheme: ColorScheme.light(
    primary: Color(0xFFA786DF),
    secondary: Color(0xFFB9D7EA), 
    surface: Color(0xFFF5F3FA), 
    onPrimary: Colors.white,
    onSecondary: Colors.black87,
    onSurface: Colors.black54,
  ),
   textTheme: GoogleFonts.poppinsTextTheme(
      const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: Color(0xFF4B4B4B),
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Color(0xFF2E2E2E),
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Color(0xFF4B4B4B),
        ),
      ),
    ),
  appBarTheme: const AppBarTheme(
    elevation: 0,
    backgroundColor: Color(0xFFA786DF),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    iconTheme: IconThemeData(color: Colors.white),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFA786DF),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFFF5F3FA),
    contentPadding: const EdgeInsets.all(14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    hintStyle: const TextStyle(color: Colors.grey),
  ),
);