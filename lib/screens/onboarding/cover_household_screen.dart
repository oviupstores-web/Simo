import 'package:flutter/material.dart';

import '../../onboarding/onboarding_flow.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

/// cover_household — présentation du mode Foyer (hors compteur d'étapes).
/// SPEC §3 : « +15 000 familles », « 4,9/5 », « -200 €/mois » retirés ; SPEC §0.4 : pas de
/// « configuration en 3 minutes ».
class CoverHouseholdScreen extends StatelessWidget {
  const CoverHouseholdScreen({super.key});

  static const _features = [
    (
      AppIcons.cutlery,
      Tint.mint,
      'Menus adaptés à tous les âges',
      'Portions enfants et adultes calculées automatiquement',
    ),
    (AppIcons.wallet, Tint.peach, 'Budget courses maîtrisé', 'Un budget global pour tout le foyer, jamais dépassé'),
    (AppIcons.leaf, Tint.leafy, 'Zéro gaspillage', 'Placards et produits frais utilisés en priorité'),
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
              AspectRatio(
                aspectRatio: AppSizes.householdHeroRatio,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/cover_household.jpg',
                      fit: BoxFit.cover,
                      semanticLabel: 'Famille partageant un repas autour d\'une table en bois',
                    ),
                    const Positioned(
                      left: AppSpace.gutter,
                      bottom: AppSpace.x4,
                      child: PillBadge(
                        'Mode Foyer & Famille',
                        icon: AppIcons.people,
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
                    Text('Des repas sains et savoureux qui rassemblent toute la maison', style: AppText.h1),
                    const SizedBox(height: AppSpace.x2),
                    Text(
                      'Menoo concilie les goûts de chacun, respecte votre budget et limite le gaspillage.',
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
                    PrimaryButton(label: 'Commencer la configuration', onPressed: () => OnboardingFlow.start(context)),
                    const SizedBox(height: AppSpace.x3),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const AppIcon(AppIcons.shield, size: 15, color: AppColors.ink2),
                        const SizedBox(width: AppSpace.x1_5),
                        Text('10 étapes rapides · modifiable à tout moment', style: AppText.meta),
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
