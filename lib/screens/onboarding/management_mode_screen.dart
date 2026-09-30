import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../onboarding/onboarding_data.dart';
import '../../onboarding/onboarding_scope.dart';
import '../../onboarding/onboarding_flow.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

/// onboarding_managementmode (Solo 7/12) et _household (Foyer 6/10).
/// SPEC §4 : « Réserves uniquement » ou « Mixte » → détour Réserve, puis retour aux contraintes.
class ManagementModeScreen extends StatelessWidget {
  const ManagementModeScreen({super.key});

  static List<(ManagementMode, String, String, String?, String, Tint)> _modes(L l) => [
    (
      ManagementMode.courses,
      AppIcons.cart,
      l.managementShoppingTitle,
      null,
      l.managementShoppingText,
      Tint.peach,
    ),
    (
      ManagementMode.reserves,
      AppIcons.fridge,
      l.managementPantryTitle,
      null,
      l.managementPantryText,
      Tint.sky,
    ),
    (
      ManagementMode.mixte,
      AppIcons.balance,
      l.managementMixedTitle,
      l.commonRecommended,
      l.managementMixedText,
      Tint.mint,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final d = OnboardingScope.of(context);
    final withPantry = d.management != ManagementMode.courses;
    return OnboardingStepScaffold(
      step: OnboardingFlow.number(context, OnbStep.management),
      totalSteps: OnboardingFlow.total(context),
      title: l.managementTitle,
      subtitle: d.isFoyer
          ? l.managementSubtitleHousehold
          : l.managementSubtitleSolo,
      onContinue: () => OnboardingFlow.next(context, OnbStep.management),
      children: [
        for (final (i, m) in _modes(l).indexed) ...[
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
              ? InfoBanner(
                  key: const ValueKey('pantry'),
                  icon: AppIcons.fridge,
                  title: l.managementPantryInfoTitle,
                  text: l.managementPantryInfoText,
                )
              : InfoBanner(
                  key: const ValueKey('courses'),
                  icon: AppIcons.bulb,
                  text: l.managementShoppingInfoText,
                  background: AppColors.neutralSoft,
                ),
        ),
      ],
    );
  }
}
