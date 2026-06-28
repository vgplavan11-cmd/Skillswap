import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme(bool isOn) {
    _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  // Neomorphic Color Tokens
  static const Color primaryColor = Color(0xFF3B82F6);
  static const Color secondaryColor = Color(0xFF60A5FA);
  static const Color lightBackgroundColor = Color(0xFFEAECEF);
  static const Color lightSurfaceColor = Color(0xFFF4F5F7);
  static const Color lightPrimaryText = Color(0xFF1F2937);
  static const Color lightSecondaryText = Color(0xFF6B7280);

  static const Color darkBackgroundColor = Color(0xFF111827); // Dark Neomorphic BG
  static const Color darkSurfaceColor = Color(0xFF1F2937); // Dark Neomorphic Surface
  static const Color darkPrimaryText = Color(0xFFF9FAFB);
  static const Color darkSecondaryText = Color(0xFF9CA3AF);

  static const Color successColor = Color(0xFF22C55E);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color dividerColor = Color(0xFFD6D8DB);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: lightSurfaceColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: lightBackgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: lightPrimaryText,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: lightSurfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(const TextTheme(
        headlineLarge: TextStyle(fontWeight: FontWeight.bold, color: lightPrimaryText, fontSize: 28.0),
        titleLarge: TextStyle(fontWeight: FontWeight.bold, color: lightPrimaryText, fontSize: 22.0),
        titleMedium: TextStyle(fontWeight: FontWeight.w600, color: lightPrimaryText, fontSize: 18.0),
        titleSmall: TextStyle(fontWeight: FontWeight.w500, color: lightPrimaryText, fontSize: 16.0),
        bodyLarge: TextStyle(color: lightPrimaryText, fontSize: 14.0),
        bodyMedium: TextStyle(color: lightSecondaryText, fontSize: 14.0),
        bodySmall: TextStyle(color: lightSecondaryText, fontSize: 12.0),
      )),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: darkSurfaceColor,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: darkBackgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: darkPrimaryText,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: darkSurfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(const TextTheme(
        headlineLarge: TextStyle(fontWeight: FontWeight.bold, color: darkPrimaryText, fontSize: 28.0),
        titleLarge: TextStyle(fontWeight: FontWeight.bold, color: darkPrimaryText, fontSize: 22.0),
        titleMedium: TextStyle(fontWeight: FontWeight.w600, color: darkPrimaryText, fontSize: 18.0),
        titleSmall: TextStyle(fontWeight: FontWeight.w500, color: darkPrimaryText, fontSize: 16.0),
        bodyLarge: TextStyle(color: darkPrimaryText, fontSize: 14.0),
        bodyMedium: TextStyle(color: darkSecondaryText, fontSize: 14.0),
        bodySmall: TextStyle(color: darkSecondaryText, fontSize: 12.0),
      )),
    );
  }
}
