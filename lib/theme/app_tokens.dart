import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Approved loading storyboard. Geometry uses a 432 × 936 logical artboard.
abstract final class StartupTokens {
  static const green = Color(0xFF094E39);
  static const cream = Color(0xFFF9F7E7);
  static const leaf = Color(0xFF91B568);
  static const carrot = Color(0xFFFF842E);
  static const background = AppColors.bg;
  static const logoAsset = 'assets/images/startup_logo.png';
  static const artboard = Size(432, 936);
  static const sequence = Duration(milliseconds: 4500);
  static const readySequence = Duration(milliseconds: 1800);
  static const exit = Duration(milliseconds: 180);
  static const sloganHold = Duration(milliseconds: 600);
  static const sloganSize = 18.0;
  static const sloganGap = 32.0;
  static const sloganWidth = 360.0;
  static const titleSize = 66.0;
  static const largeMSize = 176.0;
  static const listTitleSize = 14.0;
  static const listTextSize = 11.0;
  static const tile = Rect.fromLTWH(67, 320, 298, 296);
  static const tileScale = Offset(.9552904212, 1.0132968375);
  static const tileTranslation = Offset(10.2393002717, 32.2962135545);
}

/// Dimensions des pictogrammes du mode Solo.
abstract final class CoverSoloTokens {
  static const featureIconSize = 36.0;
  static const gutter = AppSpace.x3_5;
  static const cardGap = AppSpace.x2_5;
  static const bodyInk = LandingTokens.bodyInk;
  static const badgeRadius = BorderRadius.all(Radius.circular(AppSpace.x2_5));
}

abstract final class GoalTokens {
  static const iconSize = 36.0;
  static const gutter = AppSpace.x3_5;
}

abstract final class ActivityTokens {
  static const gutter = AppSpace.x3_5;
  static const cardGap = AppSpace.x2_5;
  static const iconSize = 36.0;
  static const bodyInk = LandingTokens.bodyInk;
}

abstract final class ManagementTokens {
  static const iconSize = 36.0;
  static const gutter = AppSpace.x3_5;
  static const cardGap = AppSpace.x2_5;
  static const bodyInk = LandingTokens.bodyInk;
}

abstract final class BudgetTokens {
  static const gutter = AppSpace.x3_5;
  static const bodyInk = LandingTokens.bodyInk;
  static const badgeRadius = BorderRadius.all(Radius.circular(AppSpace.x2_5));
}

abstract final class WeeklyGridTokens {
  static const gutter = AppSpace.x3_5;
  static const bodyInk = LandingTokens.bodyInk;
}

abstract final class SmartScaleTokens {
  static const gutter = AppSpace.x3_5;
  static const bodyInk = LandingTokens.bodyInk;
}

abstract final class ProfileTokens {
  static const gutter = AppSpace.x3_5;
  static const bodyInk = LandingTokens.bodyInk;
}

/// Espacements (échelle Tailwind des écrans maîtres : 1 unité = 4 px).
abstract final class AppSpace {
  static const double x0_5 = 2;
  static const double x1 = 4;
  static const double x1_5 = 6;
  static const double x2 = 8;
  static const double x2_5 = 10;
  static const double x3 = 12;
  static const double x3_5 = 14;
  static const double x4 = 16;
  static const double x5 = 20;
  static const double x6 = 24;
  static const double x7 = 28;
  static const double x8 = 32;
  static const double x10 = 40;

  /// Marge latérale des écrans (px-5).
  static const double gutter = x5;

  /// Espace réservé sous le contenu quand la barre de navigation est affichée (pb-28).
  static const double navClearance = 112;
}

/// Rayons.
abstract final class AppRadius {
  static const double card = 14;
  static const double btn = 14;
  static const double field = 12;

  /// Vignettes internes (pastilles d'icône, macros, jours).
  static const double tile = 8;
  static const double chip = 8;
  static const double logo = 11;
  static const double checkbox = 6;
  static const double pill = 999;

  static const BorderRadius cardR = BorderRadius.all(Radius.circular(card));
  static const BorderRadius btnR = BorderRadius.all(Radius.circular(btn));
  static const BorderRadius fieldR = BorderRadius.all(Radius.circular(field));
  static const BorderRadius tileR = BorderRadius.all(Radius.circular(tile));
  static const BorderRadius chipR = BorderRadius.all(Radius.circular(chip));
  static const BorderRadius pillR = BorderRadius.all(Radius.circular(pill));
}

/// Ombres.
abstract final class AppShadows {
  static const card = [BoxShadow(color: AppColors.shadowCard, offset: Offset(0, 2), blurRadius: 10)];
  static const btn = [BoxShadow(color: AppColors.shadowBtn, offset: Offset(0, 6), blurRadius: 16)];
}

/// Tailles fixes des composants.
abstract final class AppSizes {
  static const double logo = 40;
  static const double avatar = 40;
  static const double headerIconBox = 36;
  static const double btnHeight = 54;
  static const double btnSecondaryHeight = 50;
  static const double fieldHeight = 52;
  static const double inputHeight = 48;
  static const double chipHeight = 40;
  static const double tagHeight = 32;
  static const double quickActionHeight = 44;
  static const double progressSegment = 4;
  static const double gaugeHeight = 8;
  static const double navHeight = 64;
  static const double iconTileSm = 44;
  static const double iconTile = 48;
  static const double iconTileMd = 56;
  static const double iconTileLg = 56;
  static const double allergenImage = 72;
  static const double checkCircle = 24;
  static const double checkCircleLg = 28;
  static const double checkBullet = 17;
  static const double thumbW = 44;
  static const double thumbH = 36;
  static const double thumbSmW = 40;
  static const double thumbSmH = 32;
  static const double dot = 8;
  static const double checkbox = 20;
  static const double mealThumbH = 104;
  static const double recipeHeroH = 250;
  static const double landingHeroRatio = 5 / 4;
  static const double ring = 62;
  static const double sparkW = 96;
  static const double sparkH = 36;
  static const double orangeBadge = 28;
  static const double navItemW = 64;
  static const double loginDecorH = 120;
  static const double handUnderlineW = 112;
  static const double handUnderlineH = 3;
  static const double lockCircle = 48;

  /// Cartes avec photo latérale : photo = moitié de la carte (Expanded 1:1), hauteur min.
  static const double photoCardMinH = 232;
  static const double leafFooterH = 100;
  static const double sliderTrack = 6;
  static const double sliderThumb = 24;
  static const double stepperValueW = 56;
  static const double gridCell = 44;
  static const double coverHeroH = 260;
  static const double scaleHero = 150;
  static const double gridColumn = 64;
  static const double budgetPhotoH = 150;
  static const double photoTileH = 120;
  static const double allergenTileRatio = 1.5;
  static const double equipmentTileRatio = 1.05;
  static const double locationTileRatio = 3.0;
  static const double chipBadge = 32;
  static const double miniCheck = 18;
  static const double productFallbackIcon = 40;
  static const double equipmentTileAspect = 0.95;
  static const double equipmentTileAspect3Col = 0.75;
  static const double levelTileAspect = 0.62;
  static const double cuisineTileAspect = 0.82;

  /// Couverture Foyer : plus large que le 5:4 de la landing pour garder toute la famille.
  static const double householdHeroRatio = 16 / 10;
  static const double memberAvatar = 48;
  static const double scanPreviewH = 220;
  static const double scanFrame = 200;

  /// Landing : aperçu d'écran dans une carte de fonction (§1).
  static const double landingCardPreviewH = 170;

  /// Inclinaison des phrases manuscrites (-6°).
  static const double handTilt = -0.105;
}

/// Durées des micro-animations.
abstract final class AppMotion {
  static const fast = Duration(milliseconds: 120);
  static const normal = Duration(milliseconds: 220);
  static const page = Duration(milliseconds: 300);
  static const progress = Duration(milliseconds: 650);
  static const curve = Curves.easeOutCubic;
}

/// Landing-only values measured from accueil_deroulant.png. Shared screens retain their tokens.
abstract final class LandingTokens {
  static const double referenceWidth = 833;
  static const titleInk = Color(0xFF061718);
  static const bodyInk = Color(0xFF19234F);
  static const teal = Color(0xFF007765);
  static const scanSoft = Color(0xFFF0F8F4);
  static const menuSoft = Color(0xFFFFF3E3);
  static const shoppingSoft = Color(0xFFFDECEF);
  static const shoppingBorder = Color(0xFFE9B8C2);
  static const trackingSoft = Color(0xFFF0EDFF);
  static const mealScanSoft = Color(0xFFEAF4FF);
  static const mealScanBorder = Color(0xFFB8D4F2);
  static const mealScanTitleInk = titleInk;
  static const mealScanBodyInk = bodyInk;
  static const mealScanBadge = Color(0xFF4A90E2);
  static const mealScanAsset = 'assets/images/landing/meal_scan-v3-transparent.png';
  static const scanBadge = teal;
  static const menuBadge = Color(0xFFFF5C61);
  static const shoppingBadge = Color(0xFFD96C83);
  static const trackingBadge = Color(0xFFA65BFF);
  static const innerBorder = Color(0xD9FFFFFF);
  static const double cardBorderDarkening = .06;
  static const double trackingArtScale = 1.12;
}

/// Entry choice follows the approved landing palette and spacing locally.
abstract final class PathChoiceTokens {
  static const gutter = AppSpace.x3_5;
  static const cardGap = AppSpace.x2_5;
  static const bodyInk = LandingTokens.bodyInk;
  static const soloSoft = LandingTokens.shoppingSoft;
  static const householdSoft = LandingTokens.menuSoft;
}
