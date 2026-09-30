import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../onboarding/onboarding_data.dart';
import '../../onboarding/onboarding_flow.dart';
import '../../onboarding/onboarding_scope.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

/// onboarding_householdsize (Foyer, étape 1/10) — adultes, enfants, bébés.
class HouseholdSizeScreen extends StatelessWidget {
  const HouseholdSizeScreen({super.key});

  static List<(MemberRole, String, String, Tint)> roles(L l) => [
    (MemberRole.adulte, l.householdAdultText, AppIcons.user, Tint.mint),
    (MemberRole.enfant, l.householdChildText, AppIcons.child, Tint.peach),
    (MemberRole.bebe, l.householdBabyText, AppIcons.baby, Tint.lavender),
  ];

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final d = OnboardingScope.of(context);
    final n = d.members.length;
    return OnboardingStepScaffold(
      step: OnboardingFlow.number(context, OnbStep.household),
      totalSteps: OnboardingFlow.total(context),
      eyebrow: l.householdEyebrow,
      eyebrowIcon: AppIcons.people,
      title: l.householdTitle,
      subtitle: l.householdSubtitle,
      onContinue: () => OnboardingFlow.next(context, OnbStep.household),
      children: [
        for (final (i, r) in roles(l).indexed) ...[
          if (i > 0) const SizedBox(height: AppSpace.x3),
          AppCard(
            padding: const EdgeInsets.all(AppSpace.x3_5),
            child: Row(
              children: [
                TintBadge(icon: r.$3, tint: r.$4, size: AppSizes.iconTileMd),
                const SizedBox(width: AppSpace.x3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.$1.groupLabel, style: AppText.of(AppFont.s15, weight: AppFont.bold, lineHeight: 21)),
                      Text(r.$2, style: AppText.caption),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpace.x2),
                QuantityStepper(
                  value: '${d.count(r.$1)}',
                  onMinus: () => d.setCount(r.$1, d.count(r.$1) - 1),
                  onPlus: () => d.setCount(r.$1, d.count(r.$1) + 1),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSpace.x4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.x4, vertical: AppSpace.x3),
          decoration: const BoxDecoration(color: AppColors.mint, borderRadius: AppRadius.cardR),
          child: Row(
            children: [
              const AppIcon(AppIcons.cutlery, size: 20, color: AppColors.primary),
              const SizedBox(width: AppSpace.x2_5),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: l.householdTotalLabel,
                      style: AppText.of(AppFont.s15, color: AppColors.ink2),
                    ),
                    TextSpan(
                      text: l.householdPeopleAtTable(n),
                      style: AppText.of(AppFont.s15, weight: AppFont.extrabold, color: AppColors.primaryDark),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpace.x4),
        InfoBanner(
          icon: AppIcons.bulb,
          title: l.commonMenooTip,
          text: l.householdTipText,
        ),
      ],
    );
  }
}
