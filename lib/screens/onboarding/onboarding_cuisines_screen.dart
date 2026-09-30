import 'package:flutter/material.dart';

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
  static const cuisines = [
    ('francaise', 'Française', null),
    ('italienne', 'Italienne', null),
    ('mediterraneenne', 'Méditerranéenne', null),
    ('maghrebine', 'Maghrébine', null),
    ('japonaise', 'Japonaise', null),
    ('asiatique', 'Asiatique', 'Chine, Thaïlande, Vietnam'),
    ('mexicaine', 'Mexicaine', null),
    ('americaine', 'Américaine', null),
  ];

  static String label(String code) => cuisines.firstWhere((c) => c.$1 == code).$2;

  @override
  Widget build(BuildContext context) {
    final d = OnboardingScope.of(context);
    final n = d.cuisinePreferences.length;
    return OnboardingStepScaffold(
      step: OnboardingFlow.number(context, OnbStep.cuisines),
      totalSteps: OnboardingFlow.total(context),
      eyebrow: 'VOS GOÛTS',
      eyebrowIcon: AppIcons.cutlery,
      title: d.isFoyer ? 'Quelles cuisines font l\'unanimité ?' : 'Quelles cuisines aimez-vous ?',
      subtitle: d.isFoyer
          ? 'Menoo privilégiera ces saveurs pour régaler petits et grands. Sans choix, toutes les cuisines seront proposées.'
          : 'Menoo privilégiera ces saveurs dans vos menus. Sans choix, toutes les cuisines vous seront proposées.',
      onContinue: () => OnboardingFlow.next(context, OnbStep.cuisines),
      children: [
        StepSectionTitle(
          'Types de cuisine appréciés',
          hint: n == 0 ? 'Choix multiple' : '$n sélectionnée${n > 1 ? 's' : ''}',
        ),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpace.x3,
          crossAxisSpacing: AppSpace.x3,
          childAspectRatio: AppSizes.cuisineTileAspect,
          children: [
            for (final c in cuisines)
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
        const InfoBanner(
          icon: AppIcons.bulb,
          text: 'Vos régimes et allergies restent prioritaires : une cuisine appréciée ne passe jamais avant vos contraintes.',
        ),
      ],
    );
  }
}
