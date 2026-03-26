import 'package:flutter/material.dart';

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFFF4F5F7),
    // scaffoldBackgroundColor: const Color(0xFFF4F5F7),

    /// -----------------------
    /// Color Scheme
    /// -----------------------
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF2DA44E),
      primary: const Color(0xFF2DA44E),
      secondary: const Color(0xFF1A7F37),
      background: const Color(0xFFF4F5F7),
      surface: Colors.white,
    ),

    /// -----------------------
    /// AppBar
    /// -----------------------
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 1,
      foregroundColor: Color(0xFF172B4D),
      titleTextStyle: TextStyle(
        color: Color(0xFF172B4D),
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),

    /// -----------------------
    /// Text
    /// -----------------------
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Color(0xFF172B4D)),
      bodySmall: TextStyle(color: Color(0xFF6B778C)),
    ),

    /// -----------------------
    /// Buttons
    /// -----------------------
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2DA44E),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF2DA44E),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF2DA44E),
        side: const BorderSide(color: Color(0xFF2DA44E)),
      ),
    ),

    /// -----------------------
    /// Floating Action Button
    /// -----------------------
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF2DA44E),
      foregroundColor: Colors.white,
    ),

    /// -----------------------
    /// ListTile (Sidebar / Lists)
    /// -----------------------
    listTileTheme: const ListTileThemeData(
      iconColor: Color(0xFF6B778C),
      textColor: Color(0xFF172B4D),
      selectedColor: Color(0xFF2DA44E),
    ),

    /// -----------------------
    /// Divider / Card
    /// -----------------------
    dividerTheme: const DividerThemeData(
      color: Color(0xFFDFE1E6),
      thickness: 1,
    ),

    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(
          color: Color(0xFFDFE1E6),
        ),
      ),
    ),
  );
}