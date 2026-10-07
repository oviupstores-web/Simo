import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../navigation.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import 'improv_coming_soon_screen.dart';
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
        'branch',
        'sprig',
        'scan',
        'menus',
        'shopping',
        'tracking',
        'feature0',
        'feature1',
        'feature2',
        'feature3',
      ])
        precacheImage(AssetImage(_Illustration.assetPath(name)), context),
      precacheImage(const AssetImage('assets/images/logo_96.png'), context),
      precacheImage(const AssetImage(LandingTokens.mealScanAsset), context),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    void start() => push(context, const PathChoiceScreen());
    return Scaffold(
      backgroundColor: AppColors.white,
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
            final bodyStyle = AppText.of(AppFont.s13, color: LandingTokens.bodyInk, lineHeight: 22);
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Stack(
                    children: [
                      PositionedDirectional(
                        top: 0,
                        end: 22 * s,
                        child: _Illustration('branch', width: 145 * s, mirror: rtl),
                      ),
                      PositionedDirectional(
                        top: 90 * s,
                        start: 387 * s,
                        child: _Illustration('sprig', width: 61 * s, mirror: rtl),
                      ),
                      PositionedDirectional(
                        top: 100 * s,
                        end: 0,
                        child: ShaderMask(
                          // Fade only the lower surround before the artwork's rectangular cutout.
                          blendMode: BlendMode.dstIn,
                          shaderCallback: (bounds) => const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.white, Colors.white, Colors.transparent, Colors.transparent],
                            stops: [0, .83, .917, 1],
                          ).createShader(bounds),
                          child: _Illustration('hero', width: 448 * s, mirror: rtl, label: l.landingHeroAlt),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(14, 18 * s, 14, 22 * s),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const MenooBrand(),
                            SizedBox(height: 22 * s),
                            SizedBox(
                              width: 495 * s,
                              child: Text(
                                '${l.landingTitleLine1}\n$titleLine2',
                                style: AppText.of(
                                  AppFont.s26,
                                  weight: AppFont.extrabold,
                                  color: LandingTokens.titleInk,
                                  lineHeight: 40,
                                  tightTracking: true,
                                ),
                              ),
                            ),
                            SizedBox(height: 14 * s),
                            for (final (i, feature) in features.indexed)
                              Padding(
                                padding: EdgeInsets.only(bottom: i == 3 ? 0 : 10 * s),
                                child: SizedBox(
                                  width: 430 * s,
                                  child: Row(
                                    children: [
                                      _Illustration('feature$i', width: 65 * s),
                                      SizedBox(width: 29 * s),
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
                    padding: const EdgeInsets.symmetric(horizontal: 14),
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
                          background: LandingTokens.scanSoft,
                          badge: LandingTokens.scanBadge,
                          artFraction: .53,
                          referenceHeight: 276,
                          onTap: () => push(context, const ImprovComingSoonScreen()),
                        ),
                        const SizedBox(height: 10),
                        _FunctionCard(
                          scale: s,
                          art: 'meal_scan',
                          illustration: const _MealScanIllustration(),
                          icon: AppIcons.camera,
                          label: l.landingCardMealScanLabel,
                          title: l.landingCardMealScanTitle,
                          text: l.landingCardMealScanText,
                          background: LandingTokens.mealScanSoft,
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
                        ),
                        const SizedBox(height: 10),
                        _FunctionCard(
                          scale: s,
                          art: 'menus',
                          icon: AppIcons.calendar,
                          label: l.landingCardMenusLabel,
                          title: l.landingCardMenusTitle,
                          text: l.landingCardMenusText,
                          background: LandingTokens.menuSoft,
                          badge: LandingTokens.menuBadge,
                          artFraction: .54,
                          referenceHeight: 249,
                          onTap: start,
                        ),
                        const SizedBox(height: 10),
                        _FunctionCard(
                          scale: s,
                          art: 'shopping',
                          icon: AppIcons.cart,
                          label: l.landingCardShoppingLabel,
                          title: l.landingCardShoppingTitle,
                          text: l.landingCardShoppingText,
                          background: LandingTokens.shoppingSoft,
                          border: LandingTokens.shoppingBorder,
                          badge: LandingTokens.shoppingBadge,
                          artFraction: .50,
                          referenceHeight: 250,
                          onTap: start,
                        ),
                        const SizedBox(height: 10),
                        _FunctionCard(
                          scale: s,
                          art: 'tracking',
                          icon: AppIcons.bars,
                          label: l.landingCardTrackingLabel,
                          title: l.landingCardTrackingTitle,
                          text: l.landingCardTrackingText,
                          background: LandingTokens.trackingSoft,
                          badge: LandingTokens.trackingBadge,
                          artFraction: .52,
                          referenceHeight: 223,
                          onTap: start,
                        ),
                        SizedBox(height: 14 * s),
                        PrimaryButton(label: l.landingStart, onPressed: start),
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
    this.illustration,
    this.border,
    this.badgeFontSize = AppFont.s13,
    this.titleFontSize = AppFont.s16,
    this.titleLineHeight = 26,
    this.titleInk = LandingTokens.titleInk,
    this.bodyInk = LandingTokens.bodyInk,
  });
  final double scale, artFraction, referenceHeight;
  final String art, icon, label, title, text;
  final Color background, badge, titleInk, bodyInk;
  final Color? border;
  final VoidCallback? onTap;
  final Widget? illustration;
  final double badgeFontSize, titleFontSize, titleLineHeight;

  String _title(BuildContext context) {
    if (Localizations.localeOf(context).languageCode != 'fr' || (art != 'scan' && art != 'menus')) return title;
    final words = title.split(' ');
    return '${words.take(2).join(' ')}\n${words.skip(2).join(' ')}';
  }

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final backgroundHsl = HSLColor.fromColor(background);
    final borderColor =
        border ??
        backgroundHsl
            .withLightness((backgroundHsl.lightness - LandingTokens.cardBorderDarkening).clamp(0.0, 1.0))
            .toColor();
    return Semantics(
      button: onTap != null,
      label: label,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(22 * s),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            constraints: BoxConstraints(minHeight: referenceHeight * s),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22 * s),
              border: Border.all(color: borderColor, width: 3 * s),
            ),
            child: Stack(
              children: [
                PositionedDirectional(
                  top: 0,
                  bottom: 0,
                  end: 0,
                  width: (706 * artFraction) * s,
                  child:
                      illustration ??
                      _Illustration(art, fit: BoxFit.cover, mirror: Directionality.of(context) == TextDirection.rtl),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(20 * s, 10 * s, 0, 20 * s),
                  child: SizedBox(
                    width: 360 * s,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 7 * s),
                          decoration: BoxDecoration(
                            color: badge,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.white.withValues(alpha: .45), width: s),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AppIcon(icon, size: 22 * s, color: AppColors.white),
                              SizedBox(width: 10 * s),
                              Flexible(
                                child: Text(
                                  label,
                                  style: AppText.of(badgeFontSize, color: AppColors.white, weight: AppFont.medium),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 6 * s),
                        Text(
                          _title(context),
                          style: AppText.of(
                            titleFontSize,
                            weight: AppFont.extrabold,
                            color: titleInk,
                            lineHeight: titleLineHeight,
                            tightTracking: true,
                          ),
                        ),
                        SizedBox(height: 6 * s),
                        SizedBox(
                          width: 360 * s,
                          child: Text(text, style: AppText.of(AppFont.s13, color: bodyInk, lineHeight: 21)),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20 * s),
                        border: Border.all(color: borderColor, width: s),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Illustration extends StatelessWidget {
  const _Illustration(this.name, {this.width, this.fit = BoxFit.contain, this.mirror = false, this.label});
  final String name;
  final double? width;
  final BoxFit fit;
  final bool mirror;
  final String? label;
  static String assetPath(String name) => switch (name) {
    'shopping' => 'assets/images/landing/shopping_dezoom_transparent.png',
    'tracking' => 'assets/images/landing/tracking_dezoom_transparent.png',
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
    );
    final artwork = name == 'tracking'
        ? ClipRect(
            child: Transform.scale(scale: LandingTokens.trackingArtScale, child: image),
          )
        : image;
    return mirror ? Transform.flip(flipX: true, child: artwork) : artwork;
  }
}

/// Presentation artwork from the supplied reference; example values only.
/// No camera, analysis or nutrition calculation.
class _MealScanIllustration extends StatelessWidget {
  const _MealScanIllustration();

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return ExcludeSemantics(
      child: LayoutBuilder(
        builder: (context, bounds) {
          final k = bounds.maxWidth / 176;
          return Stack(
            fit: StackFit.expand,
            children: [
              ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (bounds) => LinearGradient(
                  begin: Directionality.of(context) == TextDirection.rtl ? Alignment.centerRight : Alignment.centerLeft,
                  end: Directionality.of(context) == TextDirection.rtl ? Alignment.centerLeft : Alignment.centerRight,
                  colors: const [Colors.transparent, Colors.white],
                  stops: const [0, .10],
                ).createShader(bounds),
                child: Image.asset(LandingTokens.mealScanAsset, fit: BoxFit.cover),
              ),
              PositionedDirectional(
                end: 5 * k,
                top: bounds.maxHeight * .10,
                bottom: bounds.maxHeight * .10,
                width: 76 * k,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _MealScanMetric(icon: AppIcons.flame, value: l.unitKcal('520'), tint: AppColors.orange, scale: k),
                    _MealScanMetric(
                      icon: AppIcons.dumbbell,
                      value: '38 g',
                      label: l.macroProteinLabel,
                      tint: AppColors.primary,
                      scale: k,
                    ),
                    _MealScanMetric(
                      icon: AppIcons.wheat,
                      value: '46 g',
                      label: l.macroCarbsLabel,
                      tint: AppColors.orange,
                      scale: k,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MealScanMetric extends StatelessWidget {
  const _MealScanMetric({required this.icon, required this.value, required this.tint, required this.scale, this.label});
  final String icon, value;
  final String? label;
  final Color tint;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final k = scale;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 5 * k, vertical: 6 * k),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: .96),
        borderRadius: BorderRadius.circular(9 * k),
        boxShadow: [
          BoxShadow(color: AppColors.ink.withValues(alpha: .07), blurRadius: 6 * k, offset: Offset(0, 3 * k)),
        ],
      ),
      child: Row(
        children: [
          AppIcon(icon, size: 15 * k, color: tint, strokeWidth: 1.5),
          SizedBox(width: 4 * k),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppText.of(
                    10 * k,
                    weight: AppFont.bold,
                    color: LandingTokens.mealScanTitleInk,
                    lineHeight: 13 * k,
                  ),
                ),
                if (label != null)
                  Text(
                    label!,
                    style: AppText.of(8 * k, color: LandingTokens.mealScanBodyInk, lineHeight: 11 * k),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
