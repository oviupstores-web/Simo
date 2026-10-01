import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../onboarding/onboarding_data.dart';
import '../../onboarding/onboarding_scope.dart';
import '../../onboarding/onboarding_flow.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

/// onboarding_constraints (Solo 8/12) et _household (Foyer 5/10) — régimes, allergènes, aliments exclus.
/// Foyer : règles communes à toute la tablée ; les allergies des profils sont rappelées et déjà exclues.
/// Codes alignés sur la base (diets, allergens) ; « halal » fusionné avec « sans porc ».
class ConstraintsScreen extends StatefulWidget {
  const ConstraintsScreen({super.key});

  static List<(String, String, String, Tint)> diets(L l) => [
    ('vegetarien', l.dietVegetarian, AppIcons.leaf, Tint.leafy),
    ('vegan', l.dietVegan, AppIcons.sprout, Tint.mint),
    ('pescetarien', l.dietPescatarian, AppIcons.fish, Tint.sky),
    ('sans_porc', l.dietNoPork, AppIcons.noPork, Tint.lavender),
    ('sans_lactose', l.dietNoLactose, AppIcons.noMilk, Tint.sky),
    ('sans_gluten', l.dietNoGluten, AppIcons.noGluten, Tint.peach),
  ];

  /// Allergènes courants (un choix peut couvrir plusieurs codes). Dernier champ : photo (assets/images/allergens/).
  static List<(List<String>, String, String, String, Tint, String)> commonAllergens(L l) => [
    (['gluten'], l.allergenGluten, l.allergenGlutenText, AppIcons.wheat, Tint.peach, 'gluten'),
    (['arachides'], l.allergenPeanuts, l.allergenPeanutsText, AppIcons.nut, Tint.sand, 'arachides'),
    (['crustaces', 'mollusques'], l.allergenSeafood, l.allergenSeafoodText, AppIcons.shrimp, Tint.sky, 'fruits_de_mer'),
    (['oeufs'], l.allergenEggs, l.allergenEggsText, AppIcons.egg, Tint.peach, 'oeufs'),
    (['soja'], l.allergenSoy, l.allergenSoyText, AppIcons.sprout, Tint.leafy, 'soja'),
    (['fruits_a_coque'], l.allergenTreeNuts, l.allergenTreeNutsText, AppIcons.nut, Tint.leafy, 'fruits_a_coque'),
  ];

  /// Le code est aussi le nom de la photo.
  static List<(String, String, String, Tint)> otherAllergens(L l) => [
    ('poisson', l.allergenFish, AppIcons.fish, Tint.sky),
    ('lait', l.allergenMilk, AppIcons.drop, Tint.sky),
    ('sesame', l.allergenSesame, AppIcons.sparkles, Tint.sand),
    ('moutarde', l.allergenMustard, AppIcons.drop, Tint.peach),
    ('celeri', l.allergenCelery, AppIcons.leaf, Tint.leafy),
    ('sulfites', l.allergenSulphites, AppIcons.drop, Tint.lavender),
    ('lupin', l.allergenLupin, AppIcons.sprout, Tint.leafy),
  ];

  /// Tous les choix d'allergènes (codes couverts, libellé, icône, teinte).
  static List<(List<String>, String, String, Tint)> allergenChoices(L l) => [
    for (final a in commonAllergens(l)) (a.$1, a.$2, a.$4, a.$5),
    for (final a in otherAllergens(l)) ([a.$1], a.$2, a.$3, a.$4),
  ];

  /// Libellés des allergènes d'un ensemble de codes (« Fruits de mer » couvre 2 codes).
  static List<String> allergenLabels(L l, Set<String> codes) => [
    for (final a in allergenChoices(l))
      if (a.$1.any(codes.contains)) a.$2,
  ];

  @override
  State<ConstraintsScreen> createState() => _ConstraintsScreenState();
}

class _ConstraintsScreenState extends State<ConstraintsScreen> {
  final _food = TextEditingController();
  late bool _showOthers = false;

  @override
  void dispose() {
    _food.dispose();
    super.dispose();
  }

  void _addFood() {
    final text = _food.text.trim();
    if (text.isEmpty) return;
    final d = OnboardingScope.read(context);
    if (!d.excludedFoods.any((f) => f.toLowerCase() == text.toLowerCase())) {
      d.update(() => d.excludedFoods.add(text[0].toUpperCase() + text.substring(1)));
    }
    _food.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final d = OnboardingScope.of(context);
    final othersSelected = ConstraintsScreen.otherAllergens(l).where((a) => d.allergens.contains(a.$1)).length;
    return OnboardingStepScaffold(
      step: OnboardingFlow.number(context, OnbStep.constraints),
      totalSteps: OnboardingFlow.total(context),
      eyebrow: d.isFoyer ? l.constraintsEyebrowHousehold : l.constraintsEyebrowSolo,
      eyebrowIcon: AppIcons.checkCircle,
      title: d.isFoyer ? l.constraintsTitleHousehold : l.constraintsTitleSolo,
      subtitle: d.isFoyer
          ? l.constraintsSubtitleHousehold
          : l.constraintsSubtitleSolo,
      onContinue: () {
        _addFood();
        OnboardingFlow.next(context, OnbStep.constraints);
      },
      children: [
        StepSectionTitle(l.constraintsDietsSection, hint: l.commonMultipleChoice, icon: AppIcons.leaf, tint: Tint.leafy),
        Wrap(
          spacing: AppSpace.x2,
          runSpacing: AppSpace.x2,
          children: [
            ToggleChip(
              label: l.dietOmnivore,
              icon: AppIcons.cutlery,
              tint: Tint.peach,
              selected: d.diets.isEmpty,
              onTap: () => d.update(d.diets.clear),
            ),
            for (final diet in ConstraintsScreen.diets(l))
              ToggleChip(
                label: diet.$2,
                icon: diet.$3,
                tint: diet.$4,
                selected: d.diets.contains(diet.$1),
                onTap: () => d.update(() => d.diets.toggle(diet.$1)),
              ),
          ],
        ),
        const SizedBox(height: AppSpace.x6),
        StepSectionTitle(l.constraintsAllergensSection, hint: l.constraintsAllergensHint, icon: AppIcons.shield, tint: Tint.peach),
        if (d.isFoyer && d.memberAllergens.isNotEmpty) ...[
          InfoBanner(
            icon: AppIcons.shield,
            title: l.constraintsMemberAllergensTitle,
            text: [
              for (final a in ConstraintsScreen.allergenChoices(l))
                if (a.$1.any(d.memberAllergens.containsKey))
                  '${a.$2} (${{for (final c in a.$1) ...?d.memberAllergens[c]}.join(', ')})',
            ].join(' · '),
            background: Tint.peach.soft,
          ),
          const SizedBox(height: AppSpace.x3),
        ],
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpace.x2,
          crossAxisSpacing: AppSpace.x2,
          childAspectRatio: AppSizes.allergenTileRatio,
          children: [
            for (final a in ConstraintsScreen.commonAllergens(l))
              OptionTile(
                label: a.$2,
                subtitle: a.$3,
                leading: FoodThumb(
                  photo: 'assets/images/allergens/${a.$6}.jpg',
                  icon: a.$4,
                  tint: a.$5,
                  size: AppSizes.allergenImage,
                ),
                selected: d.allergens.containsAll(a.$1),
                onTap: () => d.update(() {
                  d.allergens.containsAll(a.$1) ? d.allergens.removeAll(a.$1) : d.allergens.addAll(a.$1);
                }),
              ),
          ],
        ),
        const SizedBox(height: AppSpace.x3),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _showOthers = !_showOthers),
          child: Row(
            children: [
              Text(
                othersSelected > 0 ? l.constraintsOtherAllergensCount(othersSelected) : l.constraintsOtherAllergens,
                style: AppText.of(AppFont.s14, weight: AppFont.bold, color: AppColors.primary),
              ),
              const SizedBox(width: AppSpace.x1),
              AnimatedRotation(
                turns: _showOthers ? 0.5 : 0,
                duration: AppMotion.normal,
                child: const AppIcon(AppIcons.chevronDown, size: 18, color: AppColors.primary),
              ),
            ],
          ),
        ),
        AnimatedSize(
          duration: AppMotion.normal,
          curve: AppMotion.curve,
          alignment: Alignment.topCenter,
          child: _showOthers
              ? Padding(
                  padding: const EdgeInsets.only(top: AppSpace.x2_5),
                  child: Wrap(
                    spacing: AppSpace.x2,
                    runSpacing: AppSpace.x2,
                    children: [
                      for (final a in ConstraintsScreen.otherAllergens(l))
                        ToggleChip(
                          label: a.$2,
                          leading: FoodThumb(
                            photo: 'assets/images/allergens/${a.$1}.jpg',
                            icon: a.$3,
                            tint: a.$4,
                            size: AppSizes.chipBadge,
                            circle: true,
                          ),
                          selected: d.allergens.contains(a.$1),
                          onTap: () => d.update(() => d.allergens.toggle(a.$1)),
                        ),
                    ],
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
        const SizedBox(height: AppSpace.x6),
        StepSectionTitle(l.constraintsExcludedSection, hint: l.constraintsExcludedHint, icon: AppIcons.block, tint: Tint.lavender),
        IconTextField(
          icon: AppIcons.search,
          hint: l.constraintsExcludedPlaceholder,
          controller: _food,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _addFood(),
          trailingIcon: AppIcons.plus,
          onTrailingTap: _addFood,
        ),
        if (d.excludedFoods.isNotEmpty) ...[
          const SizedBox(height: AppSpace.x3),
          Wrap(
            spacing: AppSpace.x2,
            runSpacing: AppSpace.x2,
            children: [
              for (final f in d.excludedFoods)
                ToggleChip(label: f, selected: true, onRemove: () => d.update(() => d.excludedFoods.remove(f))),
            ],
          ),
        ],
        const SizedBox(height: AppSpace.x5),
        InfoBanner(
          icon: AppIcons.sparkles,
          title: l.constraintsInfoTitle,
          text: l.constraintsInfoText,
        ),
      ],
    );
  }
}
