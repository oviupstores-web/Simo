import 'package:flutter/material.dart';

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
  static const levels = [
    (CookingLevel.debutant, 'debutant', 'Débutant', 'Gestes guidés, recettes simples', AppIcons.egg),
    (CookingLevel.intermediaire, 'intermediaire', 'Intermédiaire', 'Cuissons et découpes de base', AppIcons.skillet),
    (CookingLevel.confirme, 'confirme', 'Confirmé', 'Plats élaborés, sauces', AppIcons.chefHat),
  ];

  /// Équipements dans l'ordre demandé par Simo ; codes alignés sur la table `equipment`.
  /// Photo produit détourée : assets/images/equipment/<code>.jpg (fournies par Simo).
  static const equipment = [
    ('four', 'Four', AppIcons.oven),
    ('micro_ondes', 'Micro-ondes', AppIcons.microwave),
    ('plaques', 'Plaques', AppIcons.stovetop),
    ('airfryer', 'Air fryer', AppIcons.airfryer),
    ('mixeur', 'Blender', AppIcons.blender),
    ('robot', 'Robot cuiseur', AppIcons.robot),
    ('cuiseur_vapeur', 'Cuiseur vapeur', AppIcons.steamer),
    ('autocuiseur', 'Autocuiseur', AppIcons.pressureCooker),
    ('mijoteuse', 'Mijoteuse', AppIcons.slowCooker),
    ('plancha', 'Plancha / BBQ', AppIcons.grill),
    ('wok', 'Wok', AppIcons.wok),
    ('grille_pain', 'Grille-pain', AppIcons.toaster),
  ];

  static const times = [15, 30, 45, 60];

  static String timeLabel(int m) => m >= 60 ? '60 min et +' : '$m min';

  @override
  Widget build(BuildContext context) {
    final d = OnboardingScope.of(context);
    return OnboardingStepScaffold(
      step: OnboardingFlow.number(context, OnbStep.kitchen),
      totalSteps: OnboardingFlow.total(context),
      eyebrow: 'MA CUISINE',
      eyebrowIcon: AppIcons.chefHat,
      title: 'Comment cuisinez-vous ?',
      subtitle: 'Menoo ne vous proposera que des recettes adaptées à votre niveau, votre temps et votre équipement.',
      onContinue: d.equipment.isEmpty ? null : () => OnboardingFlow.next(context, OnbStep.kitchen),
      children: [
        if (d.isFoyer) ...[
          const StepSectionTitle('Qui cuisine le plus souvent ?', hint: 'Un seul choix', icon: AppIcons.people),
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
                label: 'À tour de rôle',
                icon: AppIcons.people,
                selected: d.mainCookId == null,
                onTap: () => d.update(() => d.mainCookId = null),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.x2),
          Text(
            d.mainCookId == null
                ? 'Le niveau et le temps ci-dessous conviennent à tous ceux qui cuisinent.'
                : 'Le niveau et le temps ci-dessous concernent cette personne.',
            style: AppText.caption,
          ),
          const SizedBox(height: AppSpace.x6),
        ],
        const StepSectionTitle('Niveau en cuisine', hint: 'Un seul choix'),
        Row(
          children: [
            for (final (i, l) in levels.indexed) ...[
              if (i > 0) const SizedBox(width: AppSpace.x2),
              Expanded(
                child: AspectRatio(
                  aspectRatio: AppSizes.levelTileAspect,
                  child: ProductTile(
                    radio: true,
                    label: l.$3,
                    subtitle: l.$4,
                    asset: 'assets/images/levels/${l.$2}.jpg',
                    cover: true,
                    fallbackIcon: l.$5,
                    selected: d.cookingLevel == l.$1,
                    onTap: () => d.update(() => d.cookingLevel = l.$1),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpace.x6),
        const StepSectionTitle('Temps disponible par repas'),
        AppCard(
          child: Column(
            children: [
              _TimeSlider(
                icon: AppIcons.briefcase,
                label: 'En semaine',
                minutes: d.weekdayMinutes,
                onChanged: (m) => d.update(() => d.weekdayMinutes = m),
              ),
              const SizedBox(height: AppSpace.x3),
              _TimeSlider(
                icon: AppIcons.sun,
                label: 'Le week-end',
                minutes: d.weekendMinutes,
                onChanged: (m) => d.update(() => d.weekendMinutes = m),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpace.x6),
        StepSectionTitle(
          'Équipements disponibles',
          hint: '${d.equipment.length} sélectionné${d.equipment.length > 1 ? 's' : ''}',
        ),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpace.x3,
          crossAxisSpacing: AppSpace.x3,
          childAspectRatio: AppSizes.equipmentTileAspect,
          children: [
            for (final e in equipment)
              ProductTile(
                label: e.$2,
                asset: 'assets/images/equipment/${e.$1}.jpg',
                fallbackIcon: e.$3,
                selected: d.equipment.contains(e.$1),
                onTap: () => d.update(() => d.equipment.toggle(e.$1)),
              ),
          ],
        ),
        FormError(message: d.equipment.isEmpty ? 'Cochez au moins un équipement.' : null),
        const SizedBox(height: AppSpace.x4),
        const InfoBanner(
          icon: AppIcons.bulb,
          title: 'Recettes toujours réalisables',
          text:
              'Pas de four ? Aucune recette au four ne vous sera proposée. Modifiable à tout moment dans vos réglages.',
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
            PillBadge(KitchenScreen.timeLabel(minutes), size: AppFont.s13, weight: AppFont.extrabold),
          ],
        ),
        MenooSlider(
          value: index.toDouble(),
          min: 0,
          max: (times.length - 1).toDouble(),
          divisions: times.length - 1,
          semanticLabel: '$label : ${KitchenScreen.timeLabel(minutes)}',
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
