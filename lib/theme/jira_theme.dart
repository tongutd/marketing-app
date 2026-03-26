import 'package:flutter/material.dart';

class JiraTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: false,

      /// 🎨 Primary (Jira Blue)
      primaryColor: const Color(0xFF0052CC),
      scaffoldBackgroundColor: const Color(0xFFF4F5F7),

      fontFamily: 'NotoSansThai',

      colorScheme: ColorScheme.light(
        primary: const Color(0xFF0052CC),
        secondary: const Color(0xFF36B37E),
        error: const Color(0xFFDE350B),
        background: const Color(0xFFF4F5F7),
        surface: Colors.white,
      ),

      /// 🧱 AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Color(0xFF172B4D),
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF172B4D),
        ),
      ),

      /// ✏️ Text
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF172B4D),
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF172B4D),
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Color(0xFF42526E),
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: Color(0xFF6B778C),
        ),
      ),

      /// 🔘 Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0052CC),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF0052CC),
        ),
      ),

      /// 📦 Card / Surface
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),

      /// 📋 Divider
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade300,
        thickness: 1,
      ),
    );
  }
}