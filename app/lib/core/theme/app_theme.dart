import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary & Secondary Colors defined by user
  static const Color primaryPurple = Color(0xFF5E35B1);
  static const Color secondaryYellow = Color(0xFFFFC107);

  // Neutral Colors for Backgrounds & Text
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color textDark = Color(0xFF212529);
  static const Color textLight = Color(0xFF757575);

  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryPurple,
        primary: primaryPurple,
        secondary: secondaryYellow,
        background: Colors.transparent,
      ),
      scaffoldBackgroundColor: Colors.transparent,
      useMaterial3: true,

      // Setup Typography using Google Fonts
      textTheme: TextTheme(
        // Headings use Poppins for a premium, geometric look
        displayLarge: GoogleFonts.poppins(
          color: textDark,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: GoogleFonts.poppins(
          color: textDark,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: GoogleFonts.poppins(
          color: textDark,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: GoogleFonts.poppins(
          color: textDark,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: GoogleFonts.poppins(
          color: textDark,
          fontWeight: FontWeight.w600,
        ),

        // Body text uses Inter for high readability in lists and descriptions
        bodyLarge: GoogleFonts.inter(color: textDark, fontSize: 16),
        bodyMedium: GoogleFonts.inter(color: textDark, fontSize: 14),
        labelLarge: GoogleFonts.inter(
          color: primaryPurple,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Configure default button styling
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPurple,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      // AppBar styling
      appBarTheme: AppBarTheme(
        backgroundColor: primaryPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
