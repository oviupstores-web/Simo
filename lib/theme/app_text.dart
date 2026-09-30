import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Tailles de police relevées dans les écrans maîtres (en px logiques).
abstract final class AppFont {
  static const family = 'PlusJakartaSans';
  static const hand = 'Caveat';

  /// Plus Jakarta Sans ne contient pas l'alphabet arabe : Noto Sans Arabic prend le relais
  /// caractère par caractère, ce qui garde « Menoo » en Plus Jakarta au milieu d'un texte arabe.
  static const fallback = ['NotoSansArabic'];

  static const double s11 = 11;
  static const double s12 = 12;
  static const double s12_5 = 12.5;
  static const double s13 = 13;
  static const double s14 = 14;
  static const double s14_5 = 14.5;
  static const double s15 = 15;
  static const double s15_5 = 15.5;
  static const double s16 = 16;
  static const double s17 = 17;
  static const double s18 = 18;
  static const double s22 = 22;
  static const double s23 = 23;
  static const double s26 = 26;
  static const double s28 = 28;
  static const double s30 = 30;
  static const double s34 = 34;
  static const double s44 = 44;

  static const regular = FontWeight.w400;
  static const medium = FontWeight.w500;
  static const semibold = FontWeight.w600;
  static const bold = FontWeight.w700;
  static const extrabold = FontWeight.w800;
}

/// Styles de texte. Les écrans composent avec [AppText.of] ou les styles nommés.
abstract final class AppText {
  /// tracking-tight de Tailwind = -0,025 em.
  static double tight(double size) => -0.025 * size;

  /// Style de base : taille, graisse, couleur, interligne en px (optionnel).
  static TextStyle of(
    double size, {
    FontWeight weight = AppFont.regular,
    Color color = AppColors.ink,
    double? lineHeight,
    bool tightTracking = false,
  }) {
    return TextStyle(
      fontFamily: AppFont.family,
      fontFamilyFallback: AppFont.fallback,
      fontSize: size,
      fontWeight: weight,
      color: color,
      // Interligne par défaut du navigateur Tailwind : 1,5.
      height: lineHeight != null ? lineHeight / size : 1.5,
      letterSpacing: tightTracking ? tight(size) : 0,
    );
  }

  // Styles nommés récurrents
  static final logotype = of(
    AppFont.s22,
    weight: AppFont.extrabold,
    color: AppColors.primaryDark,
    tightTracking: true,
    lineHeight: 28,
  );
  static final display = of(AppFont.s34, weight: AppFont.extrabold, lineHeight: 38, tightTracking: true);
  static final h1 = of(AppFont.s28, weight: AppFont.extrabold, lineHeight: 34, tightTracking: true);
  static final h1Dash = of(AppFont.s26, weight: AppFont.extrabold, lineHeight: 32, tightTracking: true);
  static final h2 = of(AppFont.s18, weight: AppFont.extrabold, lineHeight: 26);
  static final sectionTitle = of(AppFont.s15, weight: AppFont.extrabold, lineHeight: 22);
  static final lead = of(AppFont.s15, color: AppColors.ink2, lineHeight: 22);
  static final body = of(AppFont.s14, color: AppColors.ink2, lineHeight: 21);
  static final caption = of(AppFont.s12_5, color: AppColors.ink2, lineHeight: 18);
  static final meta = of(AppFont.s12, color: AppColors.ink2, lineHeight: 16);
  static final button = of(AppFont.s17, weight: AppFont.bold, color: AppColors.white, lineHeight: 24);
  static final stepLabel = of(
    AppFont.s11,
    weight: AppFont.semibold,
    color: AppColors.ink2,
    lineHeight: 16,
  ).copyWith(letterSpacing: 0.275);
  static final bigNumber = of(AppFont.s22, weight: AppFont.extrabold, lineHeight: 30);
  static final rowTitle = of(AppFont.s14, weight: AppFont.semibold, lineHeight: 20);

  /// Remplace les traits d'union par des traits d'union insécables (« sur-mesure » ne se coupe plus).
  static String noBreakHyphens(String s) =>
      s.replaceAll('-', '‑').replaceAllMapped(RegExp(r' ([?!:;])'), (m) => ' ${m[1]}');

  static TextStyle hand(double size, {Color color = AppColors.primaryDark, double? lineHeight}) => TextStyle(
    fontFamily: AppFont.hand,
    fontFamilyFallback: AppFont.fallback,
    fontSize: size,
    fontWeight: AppFont.semibold,
    color: color,
    height: lineHeight != null ? lineHeight / size : 1.05,
  );
}
