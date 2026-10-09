import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../onboarding/onboarding_data.dart';
import '../../onboarding/onboarding_scope.dart';
import '../../onboarding/onboarding_flow.dart';
import 'household_size_screen.dart';
import 'profile_screen.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

/// onboarding_goal (Solo, étape 1/12) — maître : design/masters/master_onboarding_goal.html
/// (réf. 04). Modèle de toutes les étapes à choix. SPEC §0.2 : pas d'avatar pendant l'onboarding.
class GoalScreen extends StatelessWidget {
  const GoalScreen({super.key});

  static List<(HealthGoal, String, String, String?, String, Tint)> _goals(L l) => [
    (HealthGoal.pertePoids, AppIcons.goalWeightLoss, l.goalLossTitle, l.commonPopular, l.goalLossText, Tint.mint),
    (HealthGoal.priseMasse, AppIcons.goalMuscleGain, l.goalGainTitle, null, l.goalGainText, Tint.peach),
    (HealthGoal.seche, AppIcons.goalDefinition, l.goalCutTitle, null, l.goalCutText, Tint.lavender),
    (HealthGoal.maintien, AppIcons.goalBalance, l.goalMaintainTitle, null, l.goalMaintainText, Tint.leafy),
  ];

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final data = OnboardingScope.of(context);
    if (data.isFoyer) return const HouseholdSizeScreen();
    if (!data.isEligibleForIndividual) return const ProfileScreen();
    return OnboardingStepScaffold(
      horizontalPadding: GoalTokens.gutter,
      step: OnboardingFlow.number(context, OnbStep.goal),
      totalSteps: OnboardingFlow.total(context),
      eyebrow: l.goalEyebrow,
      eyebrowIcon: AppIcons.target,
      title: l.goalTitle,
      subtitle: l.goalSubtitle,
      onContinue: () => OnboardingFlow.next(context, OnbStep.goal),
      children: [
        for (final (i, g) in _goals(l).indexed) ...[
          if (i > 0) const SizedBox(height: AppSpace.x3),
          ChoiceCard(
            icon: g.$2,
            illustrationSize: 60,
            iconTileSize: 64,
            illustrationAsset: switch (g.$1) {
              HealthGoal.pertePoids => 'assets/images/new_icons/goal_loss.png',
              HealthGoal.priseMasse => 'assets/images/new_icons/goal_gain.png',
              HealthGoal.seche => 'assets/images/new_icons/goal_definition.png',
              HealthGoal.maintien => 'assets/images/new_icons/goal_balance.png',
            },
            iconSize: GoalTokens.iconSize,
            centerIcon: true,
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
        InfoBanner(icon: AppIcons.sun, title: l.goalInfoTitle, text: l.goalInfoText, background: AppColors.neutralSoft),
      ],
    );
  }
}
