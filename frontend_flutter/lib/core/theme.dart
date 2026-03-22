import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color darkBg = Color(0xFF0B0D17);
  static const Color glassColor = Color(0x1AFFFFFF);
  static const Color neonCyan = Color(0xFF00FFFF);
  static const Color neonPurple = Color(0xFFBC13FE);
  static const Color neonGreen = Color(0xFF39FF14);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      primaryColor: neonCyan,
      hintColor: neonPurple,
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: glassColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.white10),
        ),
      ),
    );
  }
}
