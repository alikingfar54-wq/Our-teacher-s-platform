import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ===== ألوان المنصة =====
class AppColors {
  // ألوان الطالب
  static const student = Color(0xFF4361EE);
  static const studentLight = Color(0xFF738DFF);
  static const studentDark = Color(0xFF2F4BD9);
  static const studentBg = Color(0xFF0A0E27);
  static const studentSurface = Color(0xFF0D1340);

  // ألوان الأستاذ
  static const teacher = Color(0xFF0D9488);
  static const teacherLight = Color(0xFF14B8A6);
  static const teacherDark = Color(0xFF0A7A70);
  static const teacherBg = Color(0xFF020F0E);
  static const teacherSurface = Color(0xFF051A18);

  // ألوان المالك
  static const owner = Color(0xFF7C3AED);
  static const ownerLight = Color(0xFFA78BFA);
  static const ownerDark = Color(0xFF6027C9);
  static const ownerBg = Color(0xFF0F0A1E);
  static const ownerSurface = Color(0xFF1A1030);

  // عام
  static const dark = Color(0xFF0F0C29);
  static const white = Colors.white;
  static const error = Color(0xFFEF4444);
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const textMuted = Color(0x80FFFFFF);
  static const border = Color(0x1AFFFFFF);
}

// ===== ثيم الطالب =====
ThemeData studentTheme() => _buildTheme(AppColors.student, AppColors.studentBg);

// ===== ثيم الأستاذ =====
ThemeData teacherTheme() => _buildTheme(AppColors.teacher, AppColors.teacherBg);

// ===== ثيم المالك =====
ThemeData ownerTheme() => _buildTheme(AppColors.owner, AppColors.ownerBg);

ThemeData _buildTheme(Color primary, Color bg) {
  final textTheme = GoogleFonts.cairoTextTheme().apply(
    bodyColor: Colors.white,
    displayColor: Colors.white,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      primary: primary,
      surface: bg,
      background: bg,
    ),
    scaffoldBackgroundColor: bg,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: bg,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: GoogleFonts.cairo(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 8,
        shadowColor: primary.withOpacity(0.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withOpacity(0.08),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: primary.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: primary.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: primary, width: 2),
      ),
      labelStyle: const TextStyle(color: AppColors.textMuted),
      hintStyle: const TextStyle(color: AppColors.textMuted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    ),
    cardTheme: CardTheme(
      color: Colors.white.withOpacity(0.06),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: primary.withOpacity(0.2)),
      ),
    ),
  );
}
