import 'package:flutter/material.dart';

import '../../onboarding/onboarding_data.dart';
import '../../onboarding/onboarding_scope.dart';
import '../../onboarding/onboarding_flow.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

/// onboarding_managementmode (Solo 7/12) et _household (Foyer 6/10).
/// SPEC §4 : « Réserves uniquement » ou « Mixte » → détour Réserve, puis retour aux contraintes.
class ManagementModeScreen extends StatelessWidget {
  const ManagementModeScreen({super.key});

  static const _modes = [
    (
      ManagementMode.courses,
      AppIcons.cart,
      'Courses uniquement',
      null,
      'Menoo prépare une liste de courses optimisée pour tous vos repas.',
      Tint.peach,
    ),
    (
      ManagementMode.reserves,
      AppIcons.fridge,
      'Réserves uniquement',
      null,
      'Menoo cuisine en priorité avec ce que vous avez déjà dans vos placards et votre frigo.',
      Tint.sky,
    ),
    (
      ManagementMode.mixte,
      AppIcons.balance,
      'Mixte',
      'Recommandé',
      'Menoo utilise vos réserves pour éviter le gaspillage et complète avec les courses nécessaires.',
      Tint.mint,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final d = OnboardingScope.of(context);
    final withPantry = d.management != ManagementMode.courses;
    return OnboardingStepScaffold(
      step: OnboardingFlow.number(context, OnbStep.management),
      totalSteps: OnboardingFlow.total(context),
      title: 'Comment souhaitez-vous gérer vos repas ?',
      subtitle: d.isFoyer
          ? 'Choisissez la méthode qui correspond le mieux au rythme de votre famille.'
          : 'Choisissez la façon dont Menoo compose vos menus chaque semaine.',
      onContinue: () => OnboardingFlow.next(context, OnbStep.management),
      children: [
        for (final (i, m) in _modes.indexed) ...[
          if (i > 0) const SizedBox(height: AppSpace.x3),
          ChoiceCard(
            icon: m.$2,
            title: m.$3,
            badge: m.$4,
            description: m.$5,
            iconBackground: m.$6.soft,
            iconForeground: m.$6.ink,
            selected: d.management == m.$1,
            onTap: () => d.update(() => d.management = m.$1),
          ),
        ],
        const SizedBox(height: AppSpace.x4),
        AnimatedSwitcher(
          duration: AppMotion.normal,
          child: withPantry
              ? const InfoBanner(
                  key: ValueKey('pantry'),
                  icon: AppIcons.fridge,
                  title: 'Onglet Réserve activé',
                  text: 'À l\'étape suivante, vous pourrez ajouter ce que vous avez déjà chez vous (facultatif).',
                )
              : const InfoBanner(
                  key: ValueKey('courses'),
                  icon: AppIcons.bulb,
                  text: 'Vous pourrez changer ce mode à tout moment dans vos réglages.',
                  background: AppColors.neutralSoft,
                ),
        ),
      ],
    );
  }
}
