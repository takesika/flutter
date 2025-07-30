import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF4DB6AC); // Colors.teal.shade200
  static const Color primaryColorLight = Color(0xFFB2DFDB); // Colors.teal.shade100
  static const Color backgroundColor = Color(0xFFF5F5F5); // Colors.grey[100]
  
  static ThemeData get lightTheme {
    return ThemeData(
      fontFamily: 'Georgia',
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColorLight,
        titleTextStyle: TextStyle(
          fontFamily: 'Georgia',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontFamily: 'Georgia',
          ),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
  
  static const TextStyle headingStyle = TextStyle(
    fontSize: 18,
    height: 1.5,
    fontFamily: 'Georgia',
  );
  
  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16,
    height: 1.6,
    fontFamily: 'Georgia',
  );
  
  static const TextStyle captionStyle = TextStyle(
    fontSize: 12,
    fontFamily: 'Georgia',
  );
}