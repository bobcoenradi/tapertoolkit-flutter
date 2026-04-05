import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary teal palette
  static const Color primary = Color(0xFF2D5F57);       // dark teal — CTAs, active nav, headers
  static const Color primaryLight = Color(0xFF3D8075);  // mid teal
  static const Color primarySoft = Color(0xFFE8F2F0);   // very light teal tint

  // Backgrounds
  static const Color background = Color(0xFFF0F4F2);    // soft mint-white
  static const Color cardBackground = Colors.white;

  // Text
  static const Color textDark = Color(0xFF1A2E2A);      // near-black teal
  static const Color textMid = Color(0xFF4A6660);       // mid teal-grey
  static const Color textLight = Color(0xFF8BA8A1);     // muted teal-grey

  // Semantic colours
  static const Color success = Color(0xFF2D8C5E);       // green dot (logged)
  static const Color warning = Color(0xFFE8A020);       // amber dot (partial)
  static const Color danger = Color(0xFFD94040);        // red dot / urgent
  static const Color info = Color(0xFF5B8FC2);          // blue

  // Dividers / borders
  static const Color border = Color(0xFFD8E8E4);

  // Nav bar
  static const Color navBackground = Colors.white;
}

const double kNavBarClearance = 64.0;

class AppTextStyles {
  static TextStyle h1({Color? color}) => GoogleFonts.manrope(
        fontSize: 32, fontWeight: FontWeight.w700,
        color: color ?? AppColors.textDark, height: 1.15);

  static TextStyle h2({Color? color}) => GoogleFonts.manrope(
        fontSize: 24, fontWeight: FontWeight.w700,
        color: color ?? AppColors.textDark, height: 1.2);

  static TextStyle h3({Color? color}) => GoogleFonts.manrope(
        fontSize: 20, fontWeight: FontWeight.w700,
        color: color ?? AppColors.textDark, height: 1.25);

  static TextStyle h4({Color? color}) => GoogleFonts.manrope(
        fontSize: 16, fontWeight: FontWeight.w700,
        color: color ?? AppColors.textDark, height: 1.3);

  static TextStyle bodyLarge({Color? color}) => GoogleFonts.inter(
        fontSize: 16, fontWeight: FontWeight.w400,
        color: color ?? AppColors.textDark, height: 1.5);

  static TextStyle body({Color? color}) => GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w400,
        color: color ?? AppColors.textMid, height: 1.5);

  static TextStyle bodySmall({Color? color}) => GoogleFonts.inter(
        fontSize: 12, fontWeight: FontWeight.w400,
        color: color ?? AppColors.textLight, height: 1.4);

  static TextStyle label({Color? color}) => GoogleFonts.inter(
        fontSize: 13, fontWeight: FontWeight.w600,
        color: color ?? AppColors.textMid, height: 1.4);

  static TextStyle caption({Color? color}) => GoogleFonts.inter(
        fontSize: 11, fontWeight: FontWeight.w500,
        color: color ?? AppColors.textLight, height: 1.3);
}

class AppTheme {
  static ThemeData get theme {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.primaryLight,
        surface: AppColors.background,
      ),
      scaffoldBackgroundColor: AppColors.background,
      useMaterial3: true,
    );

    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.manrope(
            fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.textDark),
        displayMedium: GoogleFonts.manrope(
            fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textDark),
        displaySmall: GoogleFonts.manrope(
            fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark),
        headlineMedium: GoogleFonts.manrope(
            fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark),
        headlineSmall: GoogleFonts.manrope(
            fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark),
        bodyLarge: GoogleFonts.inter(
            fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textDark),
        bodyMedium: GoogleFonts.inter(
            fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textMid),
        bodySmall: GoogleFonts.inter(
            fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textLight),
        labelLarge: GoogleFonts.inter(
            fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark),
        labelMedium: GoogleFonts.inter(
            fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMid),
        labelSmall: GoogleFonts.inter(
            fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textLight),
      ),
    );
  }
}

class AppDecorations {
  static BoxDecoration card({double radius = 16, Color color = AppColors.cardBackground}) =>
      BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 12, offset: Offset(0, 4)),
        ],
      );
}
