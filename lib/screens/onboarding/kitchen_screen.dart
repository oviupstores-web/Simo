import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../onboarding/onboarding_data.dart';
import '../../onboarding/onboarding_scope.dart';
import '../../onboarding/onboarding_flow.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import 'member_profiles_screen.dart';

/// onboarding_kitchen (Solo 10/12) et design/new/onboarding_kitchen_household (Foyer 8/10, + « Qui cuisine ? »).
/// SPEC §6 : niveau, temps en semaine et le week-end (15/30/45/60+), équipements.
/// La génération exclut toute recette trop longue, trop difficile ou sans l'équipement coché.
class KitchenScreen extends StatelessWidget {
  const KitchenScreen({super.key});

  /// Niveaux : photo « toque de chef + ustensile » détourée (assets/images/levels/<code>.jpg, fournies par Simo).
  static List<(CookingLevel, String, String, String, String)> levels(L l) => [
    (CookingLevel.debutant, 'debutant', l.kitchenLevelBeginner, l.kitchenLevelBeginnerText, AppIcons.egg),
    (CookingLevel.intermediaire, 'intermediaire', l.kitchenLevelIntermediate, l.kitchenLevelIntermediateText, AppIcons.skillet),
    (CookingLevel.confirme, 'confirme', l.kitchenLevelAdvanced, l.kitchenLevelAdvancedText, AppIcons.chefHat),
  ];

  /// Équipements dans l'ordre demandé par Simo ; codes alignés sur la table `equipment`.
  /// Photo produit détourée : assets/images/equipment/<code>.jpg (fournies par Simo).
  static List<(String, String, String)> equipment(L l) => [
    ('four', l.equipOven, AppIcons.oven),
    ('micro_ondes', l.equipMicrowave, AppIcons.microwave),
    ('plaques', l.equipHob, AppIcons.stovetop),
    ('airfryer', l.equipAirFryer, AppIcons.airfryer),
    ('mixeur', l.equipBlender, AppIcons.blender),
    ('robot', l.equipFoodProcessor, AppIcons.robot),
    ('cuiseur_vapeur', l.equipSteamer, AppIcons.steamer),
    ('autocuiseur', l.equipPressureCooker, AppIcons.pressureCooker),
    ('mijoteuse', l.equipSlowCooker, AppIcons.slowCooker),
    ('plancha', l.equipGrill, AppIcons.grill),
    ('wok', l.equipWok, AppIcons.wok),
    ('grille_pain', l.equipToaster, AppIcons.toaster),
  ];

  static const times = [15, 30, 45, 60];

  static String timeLabel(L l, int m) => m >= 60 ? l.kitchenTimeMax : l.unitMinutes(m);

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final d = OnboardingScope.of(context);
    return OnboardingStepScaffold(
      step: OnboardingFlow.number(context, OnbStep.kitchen),
      totalSteps: OnboardingFlow.total(context),
      eyebrow: l.kitchenEyebrow,
      eyebrowIcon: AppIcons.chefHat,
      title: l.kitchenTitle,
      subtitle: l.kitchenSubtitle,
      onContinue: d.equipment.isEmpty ? null : () => OnboardingFlow.next(context, OnbStep.kitchen),
      children: [
        if (d.isFoyer) ...[
          StepSectionTitle(l.kitchenCookSection, hint: l.commonSingleChoice, icon: AppIcons.people),
          Wrap(
            spacing: AppSpace.x2,
            runSpacing: AppSpace.x2,
            children: [
              for (final m in d.members.where((m) => m.role == MemberRole.adulte))
                ToggleChip(
                  label: d.displayName(m),
                  leading: MemberAvatar(name: d.displayName(m), tint: Tint.mint, size: AppSizes.chipBadge),
                  selected: d.mainCookId == m.id,
                  onTap: () => d.update(() => d.mainCookId = m.id),
                ),
              ToggleChip(
                label: l.kitchenCookTakingTurns,
                icon: AppIcons.people,
                selected: d.mainCookId == null,
                onTap: () => d.update(() => d.mainCookId = null),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.x2),
          Text(
            d.mainCookId == null
                ? l.kitchenCookNoteShared
                : l.kitchenCookNotePerson,
            style: AppText.caption,
          ),
          const SizedBox(height: AppSpace.x6),
        ],
        StepSectionTitle(l.kitchenLevelSection, hint: l.commonSingleChoice),
        Row(
          children: [
            for (final (i, lvl) in levels(l).indexed) ...[
              if (i > 0) const SizedBox(width: AppSpace.x2),
              Expanded(
                child: AspectRatio(
                  aspectRatio: AppSizes.levelTileAspect,
                  child: ProductTile(
                    radio: true,
                    label: lvl.$3,
                    subtitle: lvl.$4,
                    asset: 'assets/images/levels/${lvl.$2}.jpg',
                    cover: true,
                    fallbackIcon: lvl.$5,
                    selected: d.cookingLevel == lvl.$1,
                    onTap: () => d.update(() => d.cookingLevel = lvl.$1),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpace.x6),
        StepSectionTitle(l.kitchenTimeSection),
        AppCard(
          child: Column(
            children: [
              _TimeSlider(
                icon: AppIcons.briefcase,
                label: l.kitchenTimeWeekday,
                minutes: d.weekdayMinutes,
                onChanged: (m) => d.update(() => d.weekdayMinutes = m),
              ),
              const SizedBox(height: AppSpace.x3),
              _TimeSlider(
                icon: AppIcons.sun,
                label: l.kitchenTimeWeekend,
                minutes: d.weekendMinutes,
                onChanged: (m) => d.update(() => d.weekendMinutes = m),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpace.x6),
        StepSectionTitle(
          l.kitchenEquipmentSection,
          hint: l.commonSelectedCountMasc(d.equipment.length),
        ),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpace.x2,
          crossAxisSpacing: AppSpace.x2,
          childAspectRatio: AppSizes.equipmentTileAspect3Col,
          children: [
            for (final e in equipment(l))
              ProductTile(
                label: e.$2,
                asset: 'assets/images/equipment/${e.$1}.jpg',
                fallbackIcon: e.$3,
                selected: d.equipment.contains(e.$1),
                onTap: () => d.update(() => d.equipment.toggle(e.$1)),
              ),
          ],
        ),
        FormError(message: d.equipment.isEmpty ? l.kitchenEquipmentError : null),
        const SizedBox(height: AppSpace.x4),
        InfoBanner(
          icon: AppIcons.bulb,
          title: l.kitchenInfoTitle,
          text: l.kitchenInfoText,
        ),
      ],
    );
  }
}

class _TimeSlider extends StatelessWidget {
  const _TimeSlider({required this.icon, required this.label, required this.minutes, required this.onChanged});

  final String icon;
  final String label;
  final int minutes;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    const times = KitchenScreen.times;
    final index = times.indexOf(minutes).clamp(0, times.length - 1);
    return Column(
      children: [
        Row(
          children: [
            AppIcon(icon, size: 18, color: AppColors.ink2),
            const SizedBox(width: AppSpace.x2),
            Expanded(
              child: Text(label, style: AppText.of(AppFont.s14, weight: AppFont.semibold)),
            ),
            PillBadge(KitchenScreen.timeLabel(L.of(context), minutes), size: AppFont.s13, weight: AppFont.extrabold),
          ],
        ),
        MenooSlider(
          value: index.toDouble(),
          min: 0,
          max: (times.length - 1).toDouble(),
          divisions: times.length - 1,
          semanticLabel: '$label : ${KitchenScreen.timeLabel(L.of(context), minutes)}',
          onChanged: (v) => onChanged(times[v.round()]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.x2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [for (final t in times) Text(t >= 60 ? '60+' : '$t', style: AppText.meta)],
          ),
        ),
      ],
    );
  }
}
