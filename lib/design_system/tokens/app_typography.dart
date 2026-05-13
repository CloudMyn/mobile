import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography extends ThemeExtension<AppTypography> {
  // Font family tokens — ubah di sini untuk ganti font seluruh app
  static const String fontHeading = 'Outfit';
  static const String fontBody = 'Inter';

  // M3 Display
  final TextStyle displaySmall;
  // M3 Headline
  final TextStyle headlineMedium;
  final TextStyle headlineSmall;
  // M3 Title
  final TextStyle titleLarge;
  final TextStyle titleMedium;
  final TextStyle titleSmall;
  // Legacy heading aliases (mapped to M3 equivalents)
  final TextStyle h1;
  final TextStyle h2;
  final TextStyle h3;
  // M3 Body
  final TextStyle bodyLarge;
  final TextStyle bodyMedium;
  final TextStyle bodySmall;
  // M3 Label
  final TextStyle labelLarge;
  final TextStyle labelMedium;
  final TextStyle labelSmall;
  // Caption
  final TextStyle caption;

  const AppTypography({
    required this.displaySmall,
    required this.headlineMedium,
    required this.headlineSmall,
    required this.titleLarge,
    required this.titleMedium,
    required this.titleSmall,
    required this.h1,
    required this.h2,
    required this.h3,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodySmall,
    required this.labelLarge,
    required this.labelMedium,
    required this.labelSmall,
    required this.caption,
  });

  @override
  AppTypography copyWith({
    TextStyle? displaySmall,
    TextStyle? headlineMedium,
    TextStyle? headlineSmall,
    TextStyle? titleLarge,
    TextStyle? titleMedium,
    TextStyle? titleSmall,
    TextStyle? h1,
    TextStyle? h2,
    TextStyle? h3,
    TextStyle? bodyLarge,
    TextStyle? bodyMedium,
    TextStyle? bodySmall,
    TextStyle? labelLarge,
    TextStyle? labelMedium,
    TextStyle? labelSmall,
    TextStyle? caption,
  }) {
    return AppTypography(
      displaySmall: displaySmall ?? this.displaySmall,
      headlineMedium: headlineMedium ?? this.headlineMedium,
      headlineSmall: headlineSmall ?? this.headlineSmall,
      titleLarge: titleLarge ?? this.titleLarge,
      titleMedium: titleMedium ?? this.titleMedium,
      titleSmall: titleSmall ?? this.titleSmall,
      h1: h1 ?? this.h1,
      h2: h2 ?? this.h2,
      h3: h3 ?? this.h3,
      bodyLarge: bodyLarge ?? this.bodyLarge,
      bodyMedium: bodyMedium ?? this.bodyMedium,
      bodySmall: bodySmall ?? this.bodySmall,
      labelLarge: labelLarge ?? this.labelLarge,
      labelMedium: labelMedium ?? this.labelMedium,
      labelSmall: labelSmall ?? this.labelSmall,
      caption: caption ?? this.caption,
    );
  }

  @override
  AppTypography lerp(ThemeExtension<AppTypography>? other, double t) {
    if (other is! AppTypography) return this;
    return AppTypography(
      displaySmall: TextStyle.lerp(displaySmall, other.displaySmall, t)!,
      headlineMedium: TextStyle.lerp(headlineMedium, other.headlineMedium, t)!,
      headlineSmall: TextStyle.lerp(headlineSmall, other.headlineSmall, t)!,
      titleLarge: TextStyle.lerp(titleLarge, other.titleLarge, t)!,
      titleMedium: TextStyle.lerp(titleMedium, other.titleMedium, t)!,
      titleSmall: TextStyle.lerp(titleSmall, other.titleSmall, t)!,
      h1: TextStyle.lerp(h1, other.h1, t)!,
      h2: TextStyle.lerp(h2, other.h2, t)!,
      h3: TextStyle.lerp(h3, other.h3, t)!,
      bodyLarge: TextStyle.lerp(bodyLarge, other.bodyLarge, t)!,
      bodyMedium: TextStyle.lerp(bodyMedium, other.bodyMedium, t)!,
      bodySmall: TextStyle.lerp(bodySmall, other.bodySmall, t)!,
      labelLarge: TextStyle.lerp(labelLarge, other.labelLarge, t)!,
      labelMedium: TextStyle.lerp(labelMedium, other.labelMedium, t)!,
      labelSmall: TextStyle.lerp(labelSmall, other.labelSmall, t)!,
      caption: TextStyle.lerp(caption, other.caption, t)!,
    );
  }

  static AppTypography get standard {
    return AppTypography(
      displaySmall: GoogleFonts.getFont(fontHeading, fontSize: 36, fontWeight: FontWeight.bold, height: 1.2),
      headlineMedium: GoogleFonts.getFont(fontHeading, fontSize: 28, fontWeight: FontWeight.bold, height: 1.2),
      headlineSmall: GoogleFonts.getFont(fontHeading, fontSize: 24, fontWeight: FontWeight.bold, height: 1.25),
      titleLarge: GoogleFonts.getFont(fontHeading, fontSize: 22, fontWeight: FontWeight.w600, height: 1.3),
      titleMedium: GoogleFonts.getFont(fontBody, fontSize: 16, fontWeight: FontWeight.w600, height: 1.4),
      titleSmall: GoogleFonts.getFont(fontBody, fontSize: 14, fontWeight: FontWeight.w600, height: 1.4),
      h1: GoogleFonts.getFont(fontHeading, fontSize: 32, fontWeight: FontWeight.bold, height: 1.2),
      h2: GoogleFonts.getFont(fontHeading, fontSize: 24, fontWeight: FontWeight.bold, height: 1.2),
      h3: GoogleFonts.getFont(fontHeading, fontSize: 20, fontWeight: FontWeight.w600, height: 1.2),
      bodyLarge: GoogleFonts.getFont(fontBody, fontSize: 16, fontWeight: FontWeight.normal, height: 1.5),
      bodyMedium: GoogleFonts.getFont(fontBody, fontSize: 14, fontWeight: FontWeight.normal, height: 1.5),
      bodySmall: GoogleFonts.getFont(fontBody, fontSize: 12, fontWeight: FontWeight.normal, height: 1.5),
      labelLarge: GoogleFonts.getFont(fontBody, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1),
      labelMedium: GoogleFonts.getFont(fontBody, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5),
      labelSmall: GoogleFonts.getFont(fontBody, fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5),
      caption: GoogleFonts.getFont(fontBody, fontSize: 10, fontWeight: FontWeight.normal, height: 1.4, letterSpacing: 0.4),
    );
  }
}
