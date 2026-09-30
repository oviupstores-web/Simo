import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../onboarding/onboarding_data.dart';
import '../../onboarding/onboarding_scope.dart';
import '../../onboarding/onboarding_flow.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

/// onboarding_activity (Solo, étape 3/12) — gabarit « étape à choix ».
class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  static List<(ActivityLevel, String, String, String?, String, Tint)> _levels(L l) => [
    (
      ActivityLevel.sedentaire,
      AppIcons.chair,
      l.activitySedentaryTitle,
      null,
      l.activitySedentaryText,
      Tint.sky,
    ),
    (
      ActivityLevel.modere,
      AppIcons.walk,
      l.activityModerateTitle,
      l.commonRecommended,
      l.activityModerateText,
      Tint.mint,
    ),
    (
      ActivityLevel.actif,
      AppIcons.run,
      l.activityActiveTitle,
      null,
      l.activityActiveText,
      Tint.peach,
    ),
    (
      ActivityLevel.tresActif,
      AppIcons.flame,
      l.activityVeryActiveTitle,
      null,
      l.activityVeryActiveText,
      Tint.lavender,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final d = OnboardingScope.of(context);
    return OnboardingStepScaffold(
      step: OnboardingFlow.number(context, OnbStep.activity),
      totalSteps: OnboardingFlow.total(context),
      title: l.activityTitle,
      subtitle: l.activitySubtitle,
      onContinue: () => OnboardingFlow.next(context, OnbStep.activity),
      children: [
        for (final (i, lvl) in _levels(l).indexed) ...[
          if (i > 0) const SizedBox(height: AppSpace.x3),
          ChoiceCard(
            icon: lvl.$2,
            title: lvl.$3,
            badge: lvl.$4,
            description: lvl.$5,
            iconBackground: lvl.$6.soft,
            iconForeground: lvl.$6.ink,
            selected: d.activity == lvl.$1,
            onTap: () => d.update(() => d.activity = lvl.$1),
          ),
        ],
        const SizedBox(height: AppSpace.x4),
        InfoBanner(
          icon: AppIcons.bulb,
          text: l.activityInfoText,
        ),
      ],
    );
  }
}
