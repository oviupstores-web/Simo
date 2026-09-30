import 'package:flutter/material.dart';

import '../../onboarding/onboarding_data.dart';
import '../../onboarding/onboarding_scope.dart';
import '../../onboarding/onboarding_flow.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

/// onboarding_weeklygrid (Solo 5/12) et onboarding_weeklygrid_household (Foyer 3/10).
class WeeklyGridScreen extends StatelessWidget {
  const WeeklyGridScreen({super.key});

  static const _days = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
  static const _meals = [
    (MealType.petitDejeuner, 'P.-déj'),
    (MealType.dejeuner, 'Déjeuner'),
    (MealType.diner, 'Dîner'),
  ];

  @override
  Widget build(BuildContext context) {
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
      step: OnboardingFlow.number(context, OnbStep.grid),
      totalSteps: OnboardingFlow.total(context),
      title: d.isFoyer ? 'Quels repas souhaitez-vous planifier en famille ?' : 'Quels repas souhaitez-vous planifier ?',
      subtitle: d.isFoyer
          ? 'Sélectionnez les repas pris ensemble : Menoo les prépare pour tout le foyer.'
          : 'Sélectionnez les repas de la semaine que Menoo doit préparer pour vous.',
      onContinue: n == 0 ? null : () => OnboardingFlow.next(context, OnbStep.grid),
      children: [
        Wrap(
          spacing: AppSpace.x2,
          runSpacing: AppSpace.x2,
          children: [
            if (d.isFoyer)
              ToggleChip(
                label: 'Soirs + week-end',
                icon: AppIcons.people,
                selected: false,
                onTap: () => d.update(() {
                  d.slots
                    ..clear()
                    ..addAll(OnboardingData.foyerDefaultSlots);
                }),
              ),
            ToggleChip(
              label: 'Déj + Dîner',
              icon: AppIcons.week,
              selected: false,
              onTap: () => preset({MealType.dejeuner, MealType.diner}),
            ),
            ToggleChip(
              label: 'Tout cocher',
              icon: AppIcons.checkCircle,
              selected: false,
              onTap: () => preset(MealType.values.toSet()),
            ),
            ToggleChip(label: 'Tout décocher', icon: AppIcons.close, selected: false, onTap: () => preset({})),
          ],
        ),
        const SizedBox(height: AppSpace.x4),
        AppCard(
          padding: const EdgeInsets.fromLTRB(AppSpace.x4, AppSpace.x3, AppSpace.x4, AppSpace.x2),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: Text('Jour', style: AppText.meta)),
                  for (final m in _meals)
                    SizedBox(
                      width: AppSizes.gridColumn,
                      child: Text(
                        m.$2,
                        textAlign: TextAlign.center,
                        style: AppText.of(AppFont.s12, weight: AppFont.bold, color: AppColors.ink2),
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
                      Expanded(child: Text(_days[day - 1], style: AppText.rowTitle)),
                      for (final m in _meals)
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$n repas',
                    style: AppText.of(AppFont.s14, weight: AppFont.extrabold),
                  ),
                  TextSpan(
                    text: ' sélectionnés sur 21',
                    style: AppText.of(AppFont.s14, color: AppColors.ink2),
                  ),
                ],
              ),
            ),
            PillBadge('$perDay repas / jour', size: AppFont.s12),
          ],
        ),
        if (d.isFoyer) ...[
          const SizedBox(height: AppSpace.x3),
          InfoBanner(
            icon: AppIcons.people,
            title: 'Adapté à votre foyer',
            text:
                'Chaque repas est prévu pour ${d.peopleCount} personnes, soit ${d.weeklyPortions} portions par semaine. '
                'Les portions des enfants sont ajustées à leur âge.',
            background: AppColors.leafySoft,
          ),
        ],
        const SizedBox(height: AppSpace.x4),
        const InfoBanner(
          icon: AppIcons.bulb,
          title: 'Astuce Menoo',
          text: 'Vous pourrez régénérer, échanger ou ajouter des repas à tout moment depuis votre semaine.',
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
