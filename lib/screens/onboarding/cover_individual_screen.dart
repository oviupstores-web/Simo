import 'package:flutter/material.dart';

import '../../onboarding/onboarding_flow.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

/// cover_individual — présentation du mode Solo (hors compteur d'étapes).
/// SPEC §0.4 : pas de chiffre marketing (« moins de 20 min », « moins de 3 minutes » retirés).
class CoverIndividualScreen extends StatelessWidget {
  const CoverIndividualScreen({super.key});

  static const _features = [
    (
      AppIcons.bars,
      Tint.mint,
      'Calories & macros calculés',
      'Selon votre profil et votre objectif, sans calcul fastidieux',
    ),
    (AppIcons.clock, Tint.peach, 'Adapté à votre temps', 'Des recettes qui tiennent dans le temps que vous avez'),
    (AppIcons.leaf, Tint.leafy, 'Zéro gaspillage', 'Liste de courses ajustée, réserve déduite'),
  ];

  @override
  Widget build(BuildContext context) {
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
                      semanticLabel: 'Bowl de saumon poêlé, quinoa, avocat et légumes',
                    ),
                    const Positioned(
                      left: AppSpace.gutter,
                      bottom: AppSpace.x4,
                      child: PillBadge(
                        'Mode Individuel',
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
                      AppText.noBreakHyphens('Votre programme sur-mesure pour manger sain sans compromis'),
                      style: AppText.h1,
                    ),
                    const SizedBox(height: AppSpace.x2),
                    Text(
                      'Des repas personnalisés selon vos objectifs, votre budget et votre rythme de vie.',
                      style: AppText.lead,
                    ),
                    const SizedBox(height: AppSpace.x5),
                    for (final (i, f) in _features.indexed) ...[
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
                    PrimaryButton(label: 'Commencer mon profil', onPressed: () => OnboardingFlow.start(context)),
                    const SizedBox(height: AppSpace.x3),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const AppIcon(AppIcons.shield, size: 15, color: AppColors.ink2),
                        const SizedBox(width: AppSpace.x1_5),
                        Text('12 étapes rapides · modifiable à tout moment', style: AppText.meta),
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
