import 'package:flutter/material.dart';

import '../../onboarding/onboarding_data.dart';
import '../../onboarding/onboarding_scope.dart';
import '../../onboarding/onboarding_flow.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

/// onboarding_goal (Solo, étape 1/12) — maître : design/masters/master_onboarding_goal.html
/// (réf. 04). Modèle de toutes les étapes à choix. SPEC §0.2 : pas d'avatar pendant l'onboarding.
class GoalScreen extends StatelessWidget {
  const GoalScreen({super.key});

  static const _goals = [
    (
      HealthGoal.pertePoids,
      AppIcons.trendDown,
      'Perte de poids',
      'Populaire',
      'Déficit calorique modéré, maintien de l\'énergie et satiété durable sans frustration.',
      Tint.mint,
    ),
    (
      HealthGoal.priseMasse,
      AppIcons.dumbbell,
      'Prise de masse',
      null,
      'Surplus calorique sain et riche en protéines de qualité pour nourrir vos muscles.',
      Tint.peach,
    ),
    (
      HealthGoal.seche,
      AppIcons.bolt,
      'Sèche & Définition',
      null,
      'Optimisation de la masse maigre et réduction ciblée du taux de masse grasse.',
      Tint.lavender,
    ),
    (
      HealthGoal.maintien,
      AppIcons.lotus,
      'Maintien & Équilibre',
      null,
      'Stabiliser son poids, manger varié au quotidien et booster son bien-être général.',
      Tint.leafy,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final data = OnboardingScope.of(context);
    return OnboardingStepScaffold(
      step: OnboardingFlow.number(context, OnbStep.goal),
      totalSteps: OnboardingFlow.total(context),
      eyebrow: 'VOTRE POINT DE DÉPART',
      eyebrowIcon: AppIcons.target,
      title: 'Quel est votre objectif principal ?',
      subtitle: 'Nous adaptons l\'apport calorique et la répartition de vos macronutriments en toute précision.',
      onContinue: () => OnboardingFlow.next(context, OnbStep.goal),
      children: [
        for (final (i, g) in _goals.indexed) ...[
          if (i > 0) const SizedBox(height: AppSpace.x3),
          ChoiceCard(
            icon: g.$2,
            title: g.$3,
            badge: g.$4,
            description: g.$5,
            iconBackground: g.$6.soft,
            iconForeground: g.$6.ink,
            selected: data.goal == g.$1,
            onTap: () => data.update(() => data.goal = g.$1),
          ),
        ],
        const SizedBox(height: AppSpace.x4),
        const InfoBanner(
          icon: AppIcons.sun,
          title: 'Algorithme adaptatif',
          text: 'Menoo ajustera vos menus selon votre progression, vos habitudes et vos préférences.',
          background: AppColors.neutralSoft,
        ),
      ],
    );
  }
}
