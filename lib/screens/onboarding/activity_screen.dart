import 'package:flutter/material.dart';

import '../../onboarding/onboarding_data.dart';
import '../../onboarding/onboarding_scope.dart';
import '../../onboarding/onboarding_flow.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

/// onboarding_activity (Solo, étape 3/12) — gabarit « étape à choix ».
class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  static const _levels = [
    (
      ActivityLevel.sedentaire,
      AppIcons.chair,
      'Sédentaire',
      null,
      'Travail de bureau, peu ou pas de sport hebdomadaire',
      Tint.sky,
    ),
    (
      ActivityLevel.modere,
      AppIcons.walk,
      'Modéré',
      'Recommandé',
      'Activité quotidienne légère, 1 à 2 séances de sport par semaine',
      Tint.mint,
    ),
    (
      ActivityLevel.actif,
      AppIcons.run,
      'Actif',
      null,
      'Travail dynamique ou 3 à 4 séances d\'entraînement par semaine',
      Tint.peach,
    ),
    (
      ActivityLevel.tresActif,
      AppIcons.flame,
      'Très actif',
      null,
      'Métier physique ou 5 séances intenses et plus par semaine',
      Tint.lavender,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final d = OnboardingScope.of(context);
    return OnboardingStepScaffold(
      step: OnboardingFlow.number(context, OnbStep.activity),
      totalSteps: OnboardingFlow.total(context),
      title: 'Quel est votre niveau d\'activité ?',
      subtitle: 'Indiquez vos habitudes quotidiennes et sportives moyennes pour calibrer vos besoins nutritionnels.',
      onContinue: () => OnboardingFlow.next(context, OnbStep.activity),
      children: [
        for (final (i, l) in _levels.indexed) ...[
          if (i > 0) const SizedBox(height: AppSpace.x3),
          ChoiceCard(
            icon: l.$2,
            title: l.$3,
            badge: l.$4,
            description: l.$5,
            iconBackground: l.$6.soft,
            iconForeground: l.$6.ink,
            selected: d.activity == l.$1,
            onTap: () => d.update(() => d.activity = l.$1),
          ),
        ],
        const SizedBox(height: AppSpace.x4),
        const InfoBanner(
          icon: AppIcons.bulb,
          text: 'Votre niveau d\'activité permet d\'ajuster vos macronutriments et votre apport calorique journalier.',
        ),
      ],
    );
  }
}
