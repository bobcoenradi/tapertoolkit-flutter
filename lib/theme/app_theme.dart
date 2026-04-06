import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary sage-green palette (from mockup: #5a8a72)
  static const Color primary = Color(0xFF5A8A72);
  static const Color primaryLight = Color(0xFF7EAD94);
  static const Color primarySoft = Color(0xFFD6F0DC);   // light mint from gradient

  // Backgrounds — warm peachy-beige (#f5ece0)
  static const Color background = Color(0xFFF5ECE0);
  static const Color cardBackground = Color(0xFFFFFBF7); // near-white warm

  // Text — warm dark tones
  static const Color textDark = Color(0xFF2C2017);       // near-black warm
  static const Color textMid = Color(0xFF5C4E3A);        // warm mid brown
  static const Color textLight = Color(0xFF9A8C7C);      // muted warm grey

  // Semantic colours
  static const Color success = Color(0xFF4A8C5E);
  static const Color warning = Color(0xFFD4860A);
  static const Color danger = Color(0xFFD94040);
  static const Color info = Color(0xFF5B7FC2);

  // Dividers / borders
  static const Color border = Color(0xFFE8DDD0);

  // Nav bar
  static const Color navBackground = Colors.white;
}

const double kNavBarClearance = 64.0;

class AppTextStyles {
  // Headings use Lora (serif) — matches mockup
  static TextStyle h1({Color? color}) => GoogleFonts.lora(
        fontSize: 32, fontWeight: FontWeight.w700,
        color: color ?? AppColors.textDark, height: 1.15);

  static TextStyle h2({Color? color}) => GoogleFonts.lora(
        fontSize: 24, fontWeight: FontWeight.w700,
        color: color ?? AppColors.textDark, height: 1.2);

  static TextStyle h3({Color? color}) => GoogleFonts.lora(
        fontSize: 20, fontWeight: FontWeight.w600,
        color: color ?? AppColors.textDark, height: 1.25);

  static TextStyle h4({Color? color}) => GoogleFonts.lora(
        fontSize: 16, fontWeight: FontWeight.w600,
        color: color ?? AppColors.textDark, height: 1.3);

  // Body / UI uses DM Sans
  static TextStyle bodyLarge({Color? color}) => GoogleFonts.dmSans(
        fontSize: 16, fontWeight: FontWeight.w400,
        color: color ?? AppColors.textDark, height: 1.5);

  static TextStyle body({Color? color}) => GoogleFonts.dmSans(
        fontSize: 14, fontWeight: FontWeight.w400,
        color: color ?? AppColors.textMid, height: 1.5);

  static TextStyle bodySmall({Color? color}) => GoogleFonts.dmSans(
        fontSize: 12, fontWeight: FontWeight.w400,
        color: color ?? AppColors.textLight, height: 1.4);

  static TextStyle label({Color? color}) => GoogleFonts.dmSans(
        fontSize: 13, fontWeight: FontWeight.w600,
        color: color ?? AppColors.textMid, height: 1.4);

  static TextStyle caption({Color? color}) => GoogleFonts.dmSans(
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
        surfaceTint: Colors.transparent, // kills M3 green tint on surfaces
      ),
      scaffoldBackgroundColor: AppColors.background,
      useMaterial3: true,
    );

    return base.copyWith(
      // Disable M3 surface tint everywhere
      colorScheme: base.colorScheme.copyWith(surfaceTint: Colors.transparent),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        // Always white — suppress M3 focus/hover tints
        fillColor: Colors.white,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE8DDD0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE8DDD0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF5A8A72), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD94040)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD94040), width: 1.5),
        ),
        hintStyle: const TextStyle(color: Color(0xFF9A8C7C), fontSize: 14),
      ),
      textTheme: GoogleFonts.dmSansTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.lora(
            fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.textDark),
        displayMedium: GoogleFonts.lora(
            fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textDark),
        displaySmall: GoogleFonts.lora(
            fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textDark),
        headlineMedium: GoogleFonts.lora(
            fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textDark),
        headlineSmall: GoogleFonts.lora(
            fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark),
        bodyLarge: GoogleFonts.dmSans(
            fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textDark),
        bodyMedium: GoogleFonts.dmSans(
            fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textMid),
        bodySmall: GoogleFonts.dmSans(
            fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textLight),
        labelLarge: GoogleFonts.dmSans(
            fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark),
        labelMedium: GoogleFonts.dmSans(
            fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMid),
        labelSmall: GoogleFonts.dmSans(
            fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textLight),
      ),
    );
  }
}

class AppDecorations {
  // Standard input field box decoration
  static BoxDecoration inputField({double radius = 12}) =>
      BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: const Color(0xFFE8DDD0), width: 1),
      );

  // Standard frosted card — warm white with soft shadow
  static BoxDecoration card({double radius = 20, Color? color}) =>
      BoxDecoration(
        color: color ?? AppColors.cardBackground,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: const Color(0xFFE8DDD0), width: 1),
        boxShadow: const [
          BoxShadow(color: Color(0x12000000), blurRadius: 16, offset: Offset(0, 4)),
        ],
      );

  // Gradient green card — for hero/feature cards
  static BoxDecoration gradientCard({double radius = 20}) =>
      BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFD6F0DC), Color(0xFF9EBFAD)],
        ),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: const Color(0xFFB8D8C4), width: 1),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, 4)),
        ],
      );
}
