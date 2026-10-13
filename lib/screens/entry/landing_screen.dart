import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../navigation.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import 'path_choice_screen.dart';

/// Live, translated landing UI. The independent illustrations below are extracted
/// from accueil_deroulant.png; the supplied screenshot is never a page background.
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  /// Warm the same image providers used by the unchanged landing, while the
  /// startup overlay is visible. No resizing or recompression is involved.
  static Future<void> prepareImages(BuildContext context) async {
    await Future.wait([
      for (final name in [
        'hero',
        'banana',
        'branch',
        'sprig',
        'scan',
        'meal_scan',
        'menus',
        'shopping',
        'tracking',
        'benefits',
      ])
        precacheImage(AssetImage(_Illustration.assetPath(name)), context),
      precacheImage(const AssetImage('assets/images/logo_96.png'), context),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    void start() => push(context, const PathChoiceScreen());
    return Scaffold(
      backgroundColor: LandingTokens.screenBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final s = constraints.maxWidth / LandingTokens.referenceWidth;
            String wrap(String value, List<int> breaks) {
              if (Localizations.localeOf(context).languageCode != 'fr') return value;
              final words = value.split(' ');
              return [
                for (var i = 0; i < words.length; i++)
                  '${words[i]}${i == words.length - 1
                      ? ''
                      : breaks.contains(i + 1)
                      ? '\n'
                      : ' '}',
              ].join();
            }

            final titleLine2 = Localizations.localeOf(context).languageCode == 'fr'
                ? l.landingTitleLine2.split(' ').skip(1).join(' ')
                : l.landingTitleLine2;
            final features = [
              wrap(l.landingFeatureMeals, [3]),
              wrap(l.landingFeatureBudget, [3]),
              wrap(l.landingFeatureShopping, [4]),
              wrap(l.landingFeatureTracking, [3]),
            ];
            final bodyStyle = AppText.of(LandingPhase1Tokens.featureSize, color: LandingTokens.bodyInk, lineHeight: LandingPhase1Tokens.featureLineHeight);
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Stack(
                    children: [
                      PositionedDirectional(
                        top: 90 * s,
                        start: 500 * s,
                        child: _Illustration('sprig', width: 61 * s, mirror: rtl),
                      ),
                      PositionedDirectional(
                        top: LandingPhase1Tokens.heroTop,
                        end: 0,
                        child: _Illustration('hero',
                          width: Localizations.localeOf(context).languageCode == 'de'
                              ? (constraints.maxWidth >= 390 ? LandingPhase1Tokens.heroWidthGermanWide : LandingPhase1Tokens.heroWidthGermanNarrow)
                              : (constraints.maxWidth >= 390 ? LandingPhase1Tokens.heroWidthWide : LandingPhase1Tokens.heroWidthNarrow),
                          mirror: rtl, label: l.landingHeroAlt),
                      ),
                      PositionedDirectional(
                        bottom: LandingPhase1Tokens.bananaCardGap,
                        end: LandingPhase1Tokens.bananaEnd,
                        child: SizedBox(
                          key: const ValueKey('landing_banana'),
                          width: LandingPhase1Tokens.bananaWidth,
                          child: const _Illustration('banana'),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(constraints.maxWidth >= 390 ? LandingPhase1Tokens.wideHeaderInset : LandingPhase1Tokens.narrowHeaderInset, 6, 14, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(width: LandingPhase1Tokens.brandWidth, height: LandingPhase1Tokens.brandHeight, child: FittedBox(alignment: AlignmentDirectional.centerStart, child: MenooBrand())),
                            const SizedBox(height: LandingPhase1Tokens.headerTitleGap),
                            SizedBox(
                              width: 495 * s,
                              child: Text(
                                '${l.landingTitleLine1}\n$titleLine2',
                                style: AppText.of(
                                  constraints.maxWidth >= 390 ? LandingPhase1Tokens.headerTitleWide : LandingPhase1Tokens.headerTitleNarrow,
                                  weight: AppFont.extrabold,
                                  color: LandingTokens.titleInk,
                                  lineHeight: LandingPhase1Tokens.headerTitleLineHeight,
                                  tightTracking: true,
                                ),
                              ),
                            ),
                            const SizedBox(height: LandingVerticalTokens.headerFeaturesGap),
                            for (final (i, feature) in features.indexed)
                              Padding(
                                padding: EdgeInsetsDirectional.only(
                                  start: LandingVerticalTokens.featureLeftInset,
                                  bottom: i == 3 ? 0 : LandingVerticalTokens.featureGap,
                                ),
                                child: SizedBox(
                                  width: constraints.maxWidth >= 390 ? LandingPhase1Tokens.featureWidthWide : LandingPhase1Tokens.featureWidthNarrow,
                                  child: Row(
                                    children: [
                                      _LandingBenefitIcon(index: i, size: 65 * s * LandingVerticalTokens.benefitIconScale),
                                      const SizedBox(width: LandingVerticalTokens.featureIconGap),
                                      Expanded(child: Text(feature, style: bodyStyle)),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: LandingVerticalTokens.screenInset),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _FunctionCard(
                          scale: s,
                          art: 'scan',
                          icon: AppIcons.scan,
                          label: l.landingCardScanLabel,
                          title: l.landingCardScanTitle,
                          text: l.landingCardScanText,
                          background: LandingPhase1Tokens.scanSoft,
                          badge: LandingTokens.scanBadge,
                          artFraction: .53,
                          referenceHeight: 276,
                          onTap: null,
                          ctaLabel: l.landingCtaScan,
                        ),
                        const SizedBox(height: LandingTokens.cardGap),
                        _FunctionCard(
                          scale: s,
                          art: 'meal_scan',
                          icon: AppIcons.camera,
                          label: l.landingCardMealScanLabel,
                          title: l.landingCardMealScanTitle,
                          text: l.landingCardMealScanText,
                          background: LandingPhase1Tokens.mealScanSoft,
                          border: LandingTokens.mealScanBorder,
                          badge: LandingTokens.mealScanBadge,
                          badgeFontSize: AppFont.s13,
                          titleFontSize: AppFont.s16,
                          titleLineHeight: 23,
                          titleInk: LandingTokens.mealScanTitleInk,
                          bodyInk: LandingTokens.mealScanBodyInk,
                          artFraction: .53,
                          referenceHeight: 276,
                          onTap: null,
                          ctaLabel: l.landingCtaMealScan,
                        ),
                        const SizedBox(height: LandingTokens.cardGap),
                        _FunctionCard(
                          scale: s,
                          art: 'menus',
                          icon: AppIcons.calendar,
                          label: l.landingCardMenusLabel,
                          title: l.landingCardMenusTitle,
                          text: l.landingCardMenusText,
                          background: LandingPhase1Tokens.menuSoft,
                          badge: LandingTokens.menuBadge,
                          artFraction: .54,
                          referenceHeight: 249,
                          onTap: start,
                          ctaLabel: l.landingCtaMenus,
                        ),
                        const SizedBox(height: LandingTokens.cardGap),
                        _FunctionCard(
                          scale: s,
                          art: 'shopping',
                          icon: AppIcons.cart,
                          label: l.landingCardShoppingLabel,
                          title: l.landingCardShoppingTitle,
                          text: l.landingCardShoppingText,
                          background: LandingPhase1Tokens.shoppingSoft,
                          border: LandingTokens.shoppingBorder,
                          badge: LandingTokens.shoppingBadge,
                          artFraction: .50,
                          referenceHeight: 250,
                          onTap: start,
                          ctaLabel: l.landingCtaShopping,
                        ),
                        const SizedBox(height: LandingTokens.cardGap),
                        _FunctionCard(
                          scale: s,
                          art: 'tracking',
                          icon: AppIcons.bars,
                          label: l.landingCardTrackingLabel,
                          title: l.landingCardTrackingTitle,
                          text: l.landingCardTrackingText,
                          background: LandingPhase1Tokens.trackingSoft,
                          badge: LandingTokens.trackingBadge,
                          artFraction: .52,
                          referenceHeight: 223,
                          onTap: null,
                        ),
                        const SizedBox(height: LandingTokens.cardGap),
                        PrimaryButton(label: l.landingStart, onPressed: start, height: LandingPhase1Tokens.startHeight, textStyle: AppText.of(LandingPhase1Tokens.startFontSize, color: AppColors.white, weight: AppFont.bold, lineHeight: LandingPhase1Tokens.startLineHeight)),
                        SizedBox(height: 8 * s),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AppIcon(AppIcons.shield, size: 24 * s, color: LandingTokens.titleInk),
                            SizedBox(width: 10 * s),
                            Flexible(
                              child: Text(
                                l.commonDataSecure,
                                style: AppText.of(AppFont.s13, color: LandingTokens.bodyInk),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8 * s),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FunctionCard extends StatelessWidget {
  const _FunctionCard({
    required this.scale,
    required this.art,
    required this.icon,
    required this.label,
    required this.title,
    required this.text,
    required this.background,
    required this.badge,
    required this.artFraction,
    required this.referenceHeight,
    required this.onTap,
    this.border,
    this.badgeFontSize = AppFont.s13,
    this.titleFontSize = AppFont.s16,
    this.titleLineHeight = 26,
    this.titleInk = LandingTokens.titleInk,
    this.bodyInk = LandingTokens.bodyInk,
    this.ctaLabel,
  });
  final double scale, artFraction, referenceHeight;
  final String art, icon, label, title, text;
  final Color background, badge, titleInk, bodyInk;
  final Color? border;
  final VoidCallback? onTap;
  final double badgeFontSize, titleFontSize, titleLineHeight;
  final String? ctaLabel;

  @override
  Widget build(BuildContext context) {
    final borderColor = LandingVerticalTokens.cardBorders[art]!;
    return Semantics(
      button: onTap != null,
      label: label,
      child: Container(
        clipBehavior: art == 'meal_scan' ? Clip.antiAlias : Clip.none,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(LandingPhase1Tokens.cardRadius),
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(LandingPhase1Tokens.cardRadius),
          border: Border.all(color: borderColor),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: LayoutBuilder(
              key: ValueKey('landing_card_$art'),
              builder: (context, bounds) {
                final innerWidth = bounds.maxWidth - 2 * LandingPhase1Tokens.cardPadding;
                final artworkWidth = art == 'meal_scan'
                    ? (innerWidth * LandingVerticalTokens.caliArtFraction).clamp(
                        0.0,
                        (bounds.maxWidth - 2 * LandingVerticalTokens.artBorderInset) /
                            LandingVerticalTokens.caliVisibleWidthFraction,
                      ).toDouble()
                    : art == 'scan'
                        ? innerWidth * LandingVerticalTokens.instantArtFraction
                        : (innerWidth * LandingVerticalTokens.remainingArtFraction).clamp(
                            0.0,
                            (bounds.maxWidth - 2 * LandingVerticalTokens.artBorderInset) /
                                (2 * LandingVerticalTokens.remainingArtCenter[art]!),
                          ).toDouble();
                return Padding(
                  padding: const EdgeInsets.fromLTRB(
                    LandingPhase1Tokens.cardPadding,
                    LandingPhase1Tokens.cardPadding,
                    LandingPhase1Tokens.cardPadding,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        key: ValueKey('landing_pill_$art'),
                        padding: const EdgeInsets.symmetric(
                          horizontal: LandingPhase1Tokens.badgeHorizontal,
                          vertical: LandingPhase1Tokens.badgeVertical,
                        ),
                        decoration: BoxDecoration(
                          color: badge,
                          borderRadius: BorderRadius.circular(LandingPhase1Tokens.badgeRadius),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppIcon(icon, size: LandingPhase1Tokens.badgeIcon, color: AppColors.white),
                            const SizedBox(width: LandingPhase1Tokens.badgeGap),
                            Flexible(child: Text(label, style: AppText.of(
                              LandingPhase1Tokens.badgeSize, color: AppColors.white,
                              weight: AppFont.semibold, lineHeight: LandingPhase1Tokens.badgeLineHeight,
                            ))),
                          ],
                        ),
                      ),
                      const SizedBox(height: LandingVerticalTokens.badgeTitleGap),
                      SizedBox(
                        width: innerWidth,
                        child: Text(title, style: AppText.of(
                          LandingPhase1Tokens.titleSize, weight: AppFont.extrabold,
                          color: titleInk, lineHeight: LandingVerticalTokens.titleLineHeight,
                          tightTracking: true,
                        )),
                      ),
                      const SizedBox(height: LandingVerticalTokens.titleBodyGap),
                      SizedBox(
                        width: innerWidth,
                        child: Text(text, style: AppText.of(
                          LandingPhase1Tokens.bodySize, color: bodyInk,
                          lineHeight: LandingVerticalTokens.bodyLineHeight,
                        )),
                      ),
                      if (ctaLabel != null) ...[
                        const SizedBox(height: LandingPhase1Tokens.ctaDescriptionGap),
                        Center(child: SizedBox(
                          width: innerWidth * LandingVerticalTokens.ctaWidthFraction,
                          child: _LandingOutlineCta(
                            key: ValueKey('landing_cta_$art'), wrap: true,
                            label: ctaLabel!, icon: icon, color: badge, onTap: onTap,
                          ),
                        )),
                      ],
                      SizedBox(height: art == 'tracking' ? LandingVerticalTokens.trackingArtGap : LandingVerticalTokens.verticalArtGap),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: ClipRect(
                          clipBehavior: art == 'tracking' ? Clip.hardEdge : Clip.none,
                          child: SizedBox(
                          key: ValueKey('landing_art_slot_$art'),
                          width: artworkWidth,
                          height: artworkWidth *
                              (LandingVerticalTokens.artVisibleBottomRatio[art]! -
                                  (art == 'tracking' ? LandingVerticalTokens.trackingTransparentTopRatio : 0)),
                          child: OverflowBox(
                            alignment: Alignment.topCenter,
                            minWidth: artworkWidth,
                            maxWidth: artworkWidth,
                            minHeight: artworkWidth *
                                LandingVerticalTokens.artAspectHeight[art]!,
                            maxHeight: artworkWidth *
                                LandingVerticalTokens.artAspectHeight[art]!,
                            child: Transform.translate(
                              offset: Offset(
                                artworkWidth * (art == 'scan'
                                    ? LandingVerticalTokens.instantCenterOffset
                                    : art == 'meal_scan' ? LandingVerticalTokens.caliCenterOffset
                                    : .5 - LandingVerticalTokens.remainingArtCenter[art]!) *
                                    (Directionality.of(context) == TextDirection.rtl ? -1 : 1),
                                art == 'tracking' ? -artworkWidth * LandingVerticalTokens.trackingTransparentTopRatio : 0,
                              ),
                              child: _Illustration(
                                art, width: artworkWidth,
                                fit: BoxFit.contain,
                                mirror: Directionality.of(context) == TextDirection.rtl,
                              ),
                            ),
                          ),
                        ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _LandingOutlineCta extends StatelessWidget {
  const _LandingOutlineCta({super.key, required this.label, required this.icon, required this.color, this.onTap, this.wrap = false});
  final bool wrap;
  final String label, icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: onTap != null,
    child: Material(
      color: AppColors.white.withValues(alpha: LandingCtaTokens.fillOpacity),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(LandingCtaTokens.radius),
        side: BorderSide(color: color, width: LandingCtaTokens.borderWidth),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: LandingCtaTokens.height),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: LandingCtaTokens.horizontalPadding),
            child: wrap ? SizedBox(
              width: double.infinity,
              child: Center(
                heightFactor: 1,
                child: Wrap(
              alignment: WrapAlignment.center,
              spacing: LandingCtaTokens.gap,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                AppIcon(icon, size: LandingCtaTokens.iconSize, color: color),
                for (final word in label.split(' ').take(label.split(' ').length - 1))
                  Text(word, style: AppText.of(
                    LandingCtaTokens.fontSize,
                    weight: AppFont.bold,
                    color: color,
                    lineHeight: LandingCtaTokens.lineHeight,
                  )),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(label.split(' ').last, style: AppText.of(
                    LandingCtaTokens.fontSize, weight: AppFont.bold,
                    color: color, lineHeight: LandingCtaTokens.lineHeight,
                  )),
                  const SizedBox(width: LandingCtaTokens.gap),
                  AppIcon(AppIcons.arrowRight, size: LandingCtaTokens.iconSize, color: color),
                ]),
              ],
            ),
            ),
            ) : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppIcon(icon, size: LandingCtaTokens.iconSize, color: color),
                const SizedBox(width: LandingCtaTokens.gap),
                Flexible(
                  child: Text(
                    label,
                    maxLines: wrap ? null : 1,
                    softWrap: wrap,
                    style: AppText.of(
                      LandingCtaTokens.fontSize,
                      weight: AppFont.bold,
                      color: color,
                      lineHeight: LandingCtaTokens.lineHeight,
                    ),
                  ),
                ),
                const SizedBox(width: LandingCtaTokens.gap),
                Transform.flip(
                  flipX: Directionality.of(context) == TextDirection.rtl,
                  child: AppIcon(AppIcons.arrowRight, size: LandingCtaTokens.iconSize, color: color),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

/// Displays one icon from the supplied sheet without changing the source pixels.
class _LandingBenefitIcon extends StatelessWidget {
  const _LandingBenefitIcon({required this.index, required this.size});
  final int index;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
    key: ValueKey('landing_benefit_icon_$index'),
    width: size,
    height: size,
    child: FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: LandingVerticalTokens.benefitCropSize,
        height: LandingVerticalTokens.benefitCropSize,
        child: ClipRect(
          child: OverflowBox(
            alignment: Alignment.topLeft,
            minWidth: LandingVerticalTokens.benefitSheetWidth,
            maxWidth: LandingVerticalTokens.benefitSheetWidth,
            minHeight: LandingVerticalTokens.benefitSheetHeight,
            maxHeight: LandingVerticalTokens.benefitSheetHeight,
            child: Transform.translate(
              offset: Offset(-LandingVerticalTokens.benefitCropLeft, -LandingVerticalTokens.benefitCropTops[index]),
              child: Image.asset(
                _Illustration.assetPath('benefits'),
                width: LandingVerticalTokens.benefitSheetWidth,
                height: LandingVerticalTokens.benefitSheetHeight,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                excludeFromSemantics: true,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _Illustration extends StatelessWidget {
  const _Illustration(this.name, {this.width, this.fit = BoxFit.contain, this.mirror = false, this.label});
  final String name;
  final double? width;
  final BoxFit fit;
  final bool mirror;
  final String? label;
  static String assetPath(String name) => switch (name) {
    'benefits' => 'assets/images/landing/benefit_icons_supplied_20261013.png',
    'banana' => 'assets/images/landing/banana_supplied_20261013.png',
    'hero' => 'assets/images/landing/hero_salmon_20261013.png',
    'scan' => 'assets/images/landing/scan_20261013_1258.png',
    'meal_scan' => 'assets/images/landing/meal_scan_20261013_1258.png',
    'menus' => 'assets/images/landing/menus_20261013_1258.png',
    'shopping' => 'assets/images/landing/shopping_20261013_1258.png',
    'tracking' => 'assets/images/landing/tracking_20261013_1258.png',
    _ => 'assets/images/landing/$name.png',
  };
  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      assetPath(name),
      width: width,
      fit: fit,
      semanticLabel: label,
      excludeFromSemantics: label == null,
      gaplessPlayback: true,
      filterQuality: name == 'banana'
          ? FilterQuality.high
          : const ['scan', 'meal_scan', 'menus', 'shopping', 'tracking'].contains(name)
          ? FilterQuality.medium
          : FilterQuality.low,
    );
    return mirror ? Transform.flip(flipX: true, child: image) : image;
  }
}
