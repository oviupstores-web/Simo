import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../onboarding/onboarding_flow.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

/// cover_individual — présentation du mode Solo (hors compteur d'étapes).
/// SPEC §0.4 : pas de chiffre marketing (« moins de 20 min », « moins de 3 minutes » retirés).
class CoverSoloScreen extends StatelessWidget {
  const CoverSoloScreen({super.key});

  static List<(String, Tint, String, String)> _features(L l) => [
    (
      AppIcons.bars,
      Tint.mint,
      l.coverSoloFeature1Title,
      l.coverSoloFeature1Text,
    ),
    (AppIcons.clock, Tint.peach, l.coverSoloFeature2Title, l.coverSoloFeature2Text),
    (AppIcons.leaf, Tint.leafy, l.coverSoloFeature3Title, l.coverSoloFeature3Text),
  ];

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: AppSpace.x8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const MenooHeader(),
              const SizedBox(height: AppSpace.x4),
              // Photo pleine largeur, format 5:4 comme la landing
              AspectRatio(
                aspectRatio: AppSizes.landingHeroRatio,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/cover_individual.jpg',
                      fit: BoxFit.cover,
                      semanticLabel: l.coverSoloHeroAlt,
                    ),
                    PositionedDirectional(
                      start: AppSpace.gutter,
                      bottom: AppSpace.x4,
                      child: PillBadge(
                        l.coverSoloBadge,
                        icon: AppIcons.user,
                        background: AppColors.overlayCard,
                        size: AppFont.s13,
                        padding: EdgeInsets.symmetric(horizontal: AppSpace.x3, vertical: AppSpace.x1_5),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpace.gutter),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpace.x5),
                    Text(
                      AppText.noBreakHyphens(l.coverSoloTitle),
                      style: AppText.h1,
                    ),
                    const SizedBox(height: AppSpace.x2),
                    Text(
                      l.coverSoloSubtitle,
                      style: AppText.lead,
                    ),
                    const SizedBox(height: AppSpace.x5),
                    for (final (i, f) in _features(l).indexed) ...[
                      if (i > 0) const SizedBox(height: AppSpace.x3),
                      AppCard(
                        padding: const EdgeInsets.all(AppSpace.x3_5),
                        child: Row(
                          children: [
                            TintBadge(icon: f.$1, tint: f.$2, size: AppSizes.iconTileMd),
                            const SizedBox(width: AppSpace.x3),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(f.$3, style: AppText.of(AppFont.s15, weight: AppFont.bold, lineHeight: 21)),
                                  Text(f.$4, style: AppText.caption),
                                ],
                              ),
                            ),
                            const AppIcon(AppIcons.checkCircle, size: 20, color: AppColors.leaf),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpace.x6),
                    PrimaryButton(label: l.coverSoloStart, onPressed: () => OnboardingFlow.start(context)),
                    const SizedBox(height: AppSpace.x3),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const AppIcon(AppIcons.shield, size: 15, color: AppColors.ink2),
                        const SizedBox(width: AppSpace.x1_5),
                        Text('${l.commonQuickSteps(12)} · ${l.commonEditableAnytime}', style: AppText.meta),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
