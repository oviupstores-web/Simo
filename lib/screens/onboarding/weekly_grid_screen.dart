import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../l10n/formats.dart';
import '../../onboarding/onboarding_data.dart';
import '../../onboarding/onboarding_scope.dart';
import '../../onboarding/onboarding_flow.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

/// onboarding_weeklygrid (Solo 5/12) et onboarding_weeklygrid_household (Foyer 3/10).
class WeeklyGridScreen extends StatelessWidget {
  const WeeklyGridScreen({super.key});

  static List<(MealType, String)> _meals(L l) => [
    (MealType.petitDejeuner, l.mealBreakfastShort),
    (MealType.dejeuner, l.mealLunch),
    (MealType.diner, l.mealDinner),
  ];

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final d = OnboardingScope.of(context);
    void preset(Set<MealType> types) => d.update(() {
      d.slots
        ..clear()
        ..addAll({
          for (var day = 1; day <= 7; day++)
            for (final t in types) (day, t),
        });
    });
    final n = d.plannedMeals;
    final perDay = (n / 7).toStringAsFixed(n % 7 == 0 ? 0 : 1).replaceAll('.', ',');

    return OnboardingStepScaffold(
      horizontalPadding: WeeklyGridTokens.gutter,
      subtitleColor: WeeklyGridTokens.bodyInk,
      step: OnboardingFlow.number(context, OnbStep.grid),
      totalSteps: OnboardingFlow.total(context),
      title: d.isFoyer ? l.gridTitleHousehold : l.gridTitleSolo,
      subtitle: d.isFoyer
          ? l.gridSubtitleHousehold
          : l.gridSubtitleSolo,
      onContinue: n == 0 ? null : () => OnboardingFlow.next(context, OnbStep.grid),
      children: [
        Wrap(
          spacing: AppSpace.x2,
          runSpacing: AppSpace.x2,
          children: [
            if (d.isFoyer)
              ToggleChip(
                label: l.gridPresetEvenings,
                icon: AppIcons.people,
                selected: false,
                onTap: () => d.update(() {
                  d.slots
                    ..clear()
                    ..addAll(OnboardingData.foyerDefaultSlots);
                }),
              ),
            ToggleChip(
              label: l.gridPresetLunchDinner,
              icon: AppIcons.gridCutlery,
              selected: false,
              onTap: () => preset({MealType.dejeuner, MealType.diner}),
            ),
            ToggleChip(
              label: l.gridPresetAll,
              icon: AppIcons.checkCircle,
              selected: false,
              onTap: () => preset(MealType.values.toSet()),
            ),
            ToggleChip(label: l.gridPresetNone, icon: AppIcons.close, selected: false, onTap: () => preset({})),
          ],
        ),
        const SizedBox(height: AppSpace.x4),
        AppCard(
          padding: const EdgeInsets.fromLTRB(AppSpace.x4, AppSpace.x3, AppSpace.x4, AppSpace.x2),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: Text(l.gridDayColumn, style: AppText.meta.copyWith(color: WeeklyGridTokens.bodyInk))),
                  for (final m in _meals(l))
                    SizedBox(
                      width: AppSizes.gridColumn,
                      child: Text(
                        m.$2,
                        textAlign: TextAlign.center,
                        style: AppText.of(AppFont.s12, weight: AppFont.bold, color: WeeklyGridTokens.bodyInk),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpace.x1),
              for (var day = 1; day <= 7; day++) ...[
                if (day > 1) const Divider(height: 1, thickness: 1, color: AppColors.line),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpace.x1_5),
                  child: Row(
                    children: [
                      Expanded(child: Text(Formats.of(context).weekdayName(day), style: AppText.rowTitle)),
                      for (final m in _meals(l))
                        SizedBox(
                          width: AppSizes.gridColumn,
                          child: Center(
                            child: _GridCell(
                              selected: d.slots.contains((day, m.$1)),
                              onTap: () => d.update(() => d.slots.toggle((day, m.$1))),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpace.x3),
        LayoutBuilder(
          builder: (context, constraints) {
            final count = Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: l.gridSelectedCount(n),
                    style: AppText.of(AppFont.s14, weight: AppFont.extrabold),
                  ),
                  TextSpan(
                    text: l.gridSelectedOutOf(21),
                    style: AppText.of(AppFont.s14, color: WeeklyGridTokens.bodyInk),
                  ),
                ],
              ),
            );
            final perDayBadge = PillBadge(l.gridPerDay(perDay), size: AppFont.s12);
            if (constraints.maxWidth < 360) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  count,
                  Align(alignment: AlignmentDirectional.centerEnd, child: perDayBadge),
                ],
              );
            }
            return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [count, perDayBadge]);
          },
        ),
        if (d.isFoyer) ...[
          const SizedBox(height: AppSpace.x3),
          InfoBanner(
            icon: AppIcons.people,
            title: l.gridHouseholdInfoTitle,
            text: l.gridHouseholdInfoText(d.peopleCount, d.weeklyPortions),
            background: AppColors.leafySoft,
          ),
        ],
        const SizedBox(height: AppSpace.x4),
        InfoBanner(
          icon: AppIcons.bulb,
          title: l.commonMenooTip,
          text: l.gridTipText,
          textColor: WeeklyGridTokens.bodyInk,
        ),
      ],
    );
  }
}

class _GridCell extends StatelessWidget {
  const _GridCell({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: selected,
      button: true,
      child: Pressable(
        onTap: onTap,
        scale: 0.92,
        child: AnimatedContainer(
          duration: AppMotion.normal,
          curve: AppMotion.curve,
          width: AppSizes.gridCell,
          height: AppSizes.gridCell - AppSpace.x2,
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.card,
            borderRadius: AppRadius.tileR,
            border: Border.all(color: selected ? AppColors.primary : AppColors.line, width: 1.5),
          ),
          child: selected
              ? const Center(child: AppIcon(AppIcons.check, size: 18, color: AppColors.white, strokeWidth: 2.8))
              : null,
        ),
      ),
    );
  }
}
