import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../onboarding/onboarding_data.dart';
import '../../onboarding/onboarding_scope.dart';
import '../../onboarding/onboarding_flow.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

/// Types de cuisine appréciés (Solo, après les contraintes) — équivalent de onboarding_preferences
/// du parcours Foyer. Choix multiple ; aucun choix = toutes les cuisines. Codes enregistrés dans
/// households.cuisine_preferences.
class OnboardingCuisinesScreen extends StatelessWidget {
  const OnboardingCuisinesScreen({super.key});

  /// Photo : assets/images/cuisines/<code>.jpg (fournies par Simo).
  /// « Asiatique » couvre Chine, Thaïlande et Vietnam ; le Japon a sa propre catégorie.
  static List<(String, String, String?)> cuisines(L l) => [
    ('francaise', l.cuisineFrench, null),
    ('italienne', l.cuisineItalian, null),
    ('mediterraneenne', l.cuisineMediterranean, null),
    ('maghrebine', l.cuisineMaghrebi, null),
    ('japonaise', l.cuisineJapanese, null),
    ('asiatique', l.cuisineAsian, l.cuisineAsianSubtitle),
    ('mexicaine', l.cuisineMexican, null),
    ('americaine', l.cuisineAmerican, null),
  ];

  static String label(L l, String code) => cuisines(l).firstWhere((c) => c.$1 == code).$2;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final d = OnboardingScope.of(context);
    final n = d.cuisinePreferences.length;
    return OnboardingStepScaffold(
      step: OnboardingFlow.number(context, OnbStep.cuisines),
      totalSteps: OnboardingFlow.total(context),
      eyebrow: l.cuisinesEyebrow,
      eyebrowIcon: AppIcons.cutlery,
      title: d.isFoyer ? l.cuisinesTitleHousehold : l.cuisinesTitleSolo,
      subtitle: d.isFoyer
          ? l.cuisinesSubtitleHousehold
          : l.cuisinesSubtitleSolo,
      onContinue: () => OnboardingFlow.next(context, OnbStep.cuisines),
      children: [
        StepSectionTitle(
          l.cuisinesSection,
          hint: n == 0 ? l.commonMultipleChoice : l.commonSelectedCount(n),
        ),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpace.x3,
          crossAxisSpacing: AppSpace.x3,
          childAspectRatio: AppSizes.cuisineTileAspect,
          children: [
            for (final c in cuisines(l))
              ProductTile(
                cover: true,
                label: c.$2,
                subtitle: c.$3,
                asset: 'assets/images/cuisines/${c.$1}.jpg',
                fallbackIcon: AppIcons.cutlery,
                selected: d.cuisinePreferences.contains(c.$1),
                onTap: () => d.update(() => d.cuisinePreferences.toggle(c.$1)),
              ),
          ],
        ),
        const SizedBox(height: AppSpace.x4),
        InfoBanner(
          icon: AppIcons.bulb,
          text: l.cuisinesInfoText,
        ),
      ],
    );
  }
}
