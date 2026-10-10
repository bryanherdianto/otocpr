import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color background = Color(0xFF000000);
  static const Color surface = Color(0xFF0C0D12);

  // Strict Color Palette: MERAH, BIRU, UNGU
  static const Color cyan = Color(0xFF3BA9DA); // Biru / Cyan
  static const Color blue = Color(0xFF3BA9DA); // Biru
  static const Color purple = Color(0xFFBB00FF); // Ungu
  static const Color red = Color(0xFFFF334B); // Merah

  // Glassmorphic translucent surfaces
  static const Color glassSurface = Color(0x1AFFFFFF); // Translucent white
  static const Color surfaceCard = Color(0x263BA9DA); // Glass blue
  static const Color surfaceCyan = Color(0x263BA9DA); // Glass cyan
  static const Color surfaceBlue = Color(0x263BA9DA); // Glass blue
  static const Color surfacePurple = Color(0x28BB00FF); // Glass purple
  static const Color surfaceRed = Color(0x28FF334B); // Glass red

  // Neutral Accents
  static const Color white = Color(0xFFFFFFFF);
  static const Color gray = Color(0xFF8E9BA4);
  static const Color darkGray = Color(0xFF1B1E26);

  // Fallback alias pointing to Blue/Cyan (Zero green in palette)
  static const Color green = Color(0xFF3BA9DA);
}

class AppTypography {
  static TextStyle sans({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color color = AppColors.white,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.ibmPlexSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle mono({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color color = AppColors.white,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.ibmPlexMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }
}
