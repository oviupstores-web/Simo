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
  static const animationAsset = 'assets/images/startup_c.gif';
  static const animationFinalAsset = 'assets/images/startup_c_final.png';
  static const artboard = Size(432, 936);
  static const sequence = Duration(milliseconds: 5540);
  static const exit = Duration(milliseconds: 180);
  static const sloganHold = Duration.zero;
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
  static const screenBackground = Color(0xFFF8F9FB);
  static const cardGap = 16.0;
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

/// Outlined CTAs from the supplied landing reference; artwork stays unchanged.
abstract final class LandingCtaTokens {
  static const height = 38.0;
  static const radius = 14.5;
  static const horizontalPadding = 8.0;
  static const iconSize = 18.0;
  static const gap = 6.0;
  static const fontSize = 14.0;
  static const lineHeight = 20.0;
  static const borderWidth = 1.4;
  static const topGap = 8.0;
  static const bottomGap = 10.0;
  static const fillOpacity = .88;
  static const fullLabelMinWidth = 390.0;
}

/// Entry choice follows the approved landing palette and spacing locally.
abstract final class PathChoiceTokens {
  static const gutter = AppSpace.x3_5;
  static const cardGap = AppSpace.x2_5;
  static const bodyInk = LandingTokens.bodyInk;
  static const soloSoft = LandingTokens.shoppingSoft;
  static const householdSoft = LandingTokens.menuSoft;
}

/// Values measured from the two supplied phase-1 landing references.
abstract final class LandingPhase1Tokens {
  static const scanSoft = Color(0xFFF4FCF8);
  static const mealScanSoft = Color(0xFFF5FAFF);
  static const menuSoft = Color(0xFFFFF9F3);
  static const shoppingSoft = Color(0xFFFFF8FA);
  static const trackingSoft = Color(0xFFFAF7FE);
  static const cardHeights = <String, (double, double)>{
    'scan': (195, 192), 'meal_scan': (171, 164), 'menus': (170, 175),
    'shopping': (164, 166), 'tracking': (115, 117),
  };
  static const artWidths = <String, (double, double)>{
    'scan': (150, 190), 'meal_scan': (145, 180), 'menus': (135, 180),
    'shopping': (150, 165), 'tracking': (155, 185),
  };
  static const startHeight = 44.0;
  static const startFontSize = 16.0;
  static const startLineHeight = 24.0;
  static const cardRadius = 12.0;
  static const cardPadding = 20.0;
  static const artInset = 5.0;
  static const textFraction = .48;
  static const bodySize = 13.0;
  static const bodyLineHeight = 14.0;
  static const titleSize = 17.0;
  static const titleLineHeight = 17.0;
  static const contentGap = 3.0;
  static const ctaDescriptionGap = 24.0;
  static const handArtMargin = 10.0;
  static const badgeHorizontal = 10.0;
  static const badgeVertical = 4.0;
  static const badgeRadius = 9.0;
  static const badgeIcon = 16.0;
  static const badgeGap = 6.0;
  static const badgeSize = 14.0;
  static const badgeLineHeight = 20.0;
  static const narrowHeaderInset = 14.0;
  static const wideHeaderInset = 14.0;
  static const brandWidth = 100.0;
  static const brandHeight = 32.0;
  static const headerTitleGap = 14.0;
  static const headerTitleNarrow = 23.0;
  static const headerTitleWide = 25.0;
  static const headerTitleLineHeight = 32.0;
  static const featureWidthNarrow = 165.0;
  static const featureWidthWide = 185.0;
  static const featureSize = 13.0;
  static const featureLineHeight = 18.0;
  static const heroWidthWide = 220.0;
  static const heroWidthNarrow = 180.0;
  static const heroWidthGermanNarrow = 150.0;
  static const heroWidthGermanWide = 200.0;
  static const bananaWidth = 80.0;
  static const bananaEnd = 12.0;
  static const bananaCardGap = 16.0;
  static const heroTop = 44.0;
}

/// Shared vertical layout approved on Instant Recipe AI.
abstract final class LandingVerticalTokens {
  static const cardBorders = <String, Color>{
    'scan': Color(0xFFB5DFCC),
    'meal_scan': Color(0xFFB4D5F2),
    'menus': Color(0xFFF0CEAE),
    'shopping': Color(0xFFF0BFD0),
    'tracking': Color(0xFFD6C5EF),
  };
  static const screenInset = 20.0;
  // Full PNG height and last non-transparent row, relative to source width.
  // Only transparent bottom rows extend beyond the artwork layout slot.
  static const artAspectHeight = <String, double>{
    'scan': 1086 / 1448, 'meal_scan': 1086 / 1448, 'menus': 1086 / 1448,
    'shopping': 1086 / 1448, 'tracking': 1086 / 1448,
  };
  static const artVisibleBottomRatio = <String, double>{
    'scan': 1086 / 1448, 'meal_scan': 1086 / 1448, 'menus': 1062 / 1448,
    'shopping': 1058 / 1448, 'tracking': 841 / 1448,
  };
  static const ctaWidthFraction = .85;
  static const badgeTitleGap = 8.0;
  static const titleBodyGap = 10.0;
  static const titleLineHeight = 24.0;
  static const bodyLineHeight = 20.0;
  static const headerFeaturesGap = 18.0;
  static const featureGap = 10.0;
  static const featureIconGap = 8.0;
  static const benefitIconScale = 1.45;
  static const benefitSheetWidth = 461.0;
  static const benefitSheetHeight = 1290.0;
  static const benefitCropSize = 310.0;
  static const benefitCropLeft = 80.0;
  static const benefitCropTops = [45.0, 335.0, 635.0, 930.0];
  static const featureLeftInset = 10.0;
  static const verticalArtGap = 12.0;
  // Tracking layout keeps the main graphs and their shadows, excluding empty surround.
  static const trackingTransparentTopRatio = 235 / 1448;
  static const trackingArtGap = 6.0;
  static const verticalArtFraction = .75;
  static const instantArtFraction = 1.20;
  static const caliArtFraction = 1.20;
  static const remainingArtFraction = 1.20;
  static const remainingArtCenter = <String, double>{
    'menus': 729.5 / 1448, 'shopping': 724.5 / 1448, 'tracking': 730 / 1448,
  };
  static const caliCenterOffset = (724 - 727) / 1448;
  static const caliVisibleWidthFraction = (2 * 727) / 1448;
  static const artBorderInset = 1.0;
  // Main fridge/hand silhouette is centered at x=819 in the 1448 px PNG.
  static const instantCenterOffset = (724 - 819) / 1448;
  static const textFraction = .50;
  static const artFraction = .50;
}

/// Approved minimum logical size for the premium illustration collection.
abstract final class PremiumIconTokens {
  static const minSize = 32.0;
  static const largeSize = 36.0;
  static const largeSupport = 56.0;
  static const minSupport = 40.0;
  static const compactHeight = 40.0;
}
