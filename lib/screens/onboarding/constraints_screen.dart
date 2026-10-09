import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../onboarding/onboarding_data.dart';
import '../../onboarding/onboarding_scope.dart';
import '../../onboarding/onboarding_flow.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

/// Contraintes Solo/Foyer : régime unique, restrictions, problèmes alimentaires et goûts.
/// Les allergies individuelles et les codes historiques restent distincts et conservés.
class ConstraintsScreen extends StatefulWidget {
  const ConstraintsScreen({super.key});

  static List<(String, String, String, Tint)> principalDiets(L l) => [
    ('vegetarien', l.dietVegetarian, 'assets/images/new_icons/diet_vegetarian.png', Tint.leafy),
    ('vegan', l.dietVegan, 'assets/images/new_icons/diet_vegan.png', Tint.mint),
    ('pescetarien', l.dietPescatarian, 'assets/images/new_icons/diet_pescatarian.png', Tint.sky),
  ];

  static List<(String, String, String, Tint)> restrictions(L l) => [
    ('sans_porc', l.dietNoPork, 'assets/images/new_icons/diet_no_pork.png', Tint.lavender),
    ('sans_lactose', l.dietNoLactose, 'assets/images/new_icons/diet_no_lactose.png', Tint.sky),
    ('sans_gluten', l.dietNoGluten, 'assets/images/new_icons/diet_no_gluten.png', Tint.peach),
  ];

  /// Adaptateur historique pour le récapitulatif : mêmes six codes.
  static List<(String, String, String, Tint)> diets(L l) => [...principalDiets(l), ...restrictions(l)];

  /// Un choix par code ; les deux catégories marines réutilisent la photo existante.
  static List<(List<String>, String, String, String, Tint, String)> commonAllergens(L l) => [
    (['arachides'], l.allergenPeanuts, l.allergenPeanutsText, AppIcons.nut, Tint.sand, 'arachides'),
    (['fruits_a_coque'], l.allergenTreeNuts, l.allergenTreeNutsText, AppIcons.nut, Tint.leafy, 'fruits_a_coque'),
    (['oeufs'], l.allergenEggs, l.allergenEggsText, AppIcons.egg, Tint.peach, 'oeufs'),
    (['soja'], l.allergenSoy, l.allergenSoyText, AppIcons.sprout, Tint.leafy, 'soja'),
    (['crustaces'], l.allergenCrustaceans, l.allergenCrustaceansText, AppIcons.shrimp, Tint.sky, 'fruits_de_mer'),
    (['mollusques'], l.allergenMolluscs, l.allergenMolluscsText, AppIcons.shrimp, Tint.sky, 'fruits_de_mer'),
    (['gluten'], l.allergenGluten, l.allergenGlutenText, AppIcons.wheat, Tint.peach, 'gluten'),
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

  /// Chaque code reste visible, y compris les codes hérités inconnus.
  static List<String> allergenLabels(L l, Set<String> codes) => [
    for (final a in allergenChoices(l))
      if (a.$1.any(codes.contains)) a.$2,
    ...codes.difference(allergenChoices(l).expand((a) => a.$1).toSet()),
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
      localizeProgressDigits: true,
      eyebrow: d.isFoyer ? l.constraintsEyebrowHousehold : l.constraintsEyebrowSolo,
      eyebrowIcon: AppIcons.checkCircle,
      title: d.isFoyer ? l.constraintsTitleHousehold : l.constraintsTitleSolo,
      subtitle: d.isFoyer ? l.constraintsSubtitleHousehold : l.constraintsSubtitleSolo,
      onContinue: d.hasDietConflict
          ? null
          : () {
              _addFood();
              OnboardingFlow.next(context, OnbStep.constraints);
            },
      children: [
        StepSectionTitle(
          l.constraintsDietsSection,
          hint: l.constraintsPrincipalHint,
          icon: AppIcons.leaf,
          tint: Tint.leafy,
          adaptiveHint: true,
        ),
        Wrap(
          spacing: AppSpace.x2,
          runSpacing: AppSpace.x2,
          children: [
            ToggleChip(
              label: l.dietOmnivore,
              leading: const _DietIllustration(asset: 'assets/images/new_icons/diet_omnivore.png', tint: Tint.peach),
              selected: d.principalDiets.isEmpty,
              onTap: () => d.selectPrincipalDiet(null),
              height: 56,
            ),
            for (final diet in ConstraintsScreen.principalDiets(l))
              ToggleChip(
                label: diet.$2,
                leading: _DietIllustration(asset: diet.$3, tint: diet.$4),
                selected: d.diets.contains(diet.$1),
                onTap: () => d.selectPrincipalDiet(diet.$1),
                height: 56,
              ),
          ],
        ),
        if (d.hasDietConflict) ...[const SizedBox(height: AppSpace.x3), FormError(message: l.constraintsDietConflict)],
        if (d.diets.difference(ConstraintsScreen.diets(l).map((a) => a.$1).toSet()).isNotEmpty) ...[
          const SizedBox(height: AppSpace.x3),
          FormError(
            message: l.constraintsUnknownCodes(
              d.diets.difference(ConstraintsScreen.diets(l).map((a) => a.$1).toSet()).join(', '),
            ),
          ),
        ],
        const SizedBox(height: AppSpace.x6),
        StepSectionTitle(
          l.constraintsRestrictionsSection,
          hint: l.commonMultipleChoice,
          icon: AppIcons.leaf,
          tint: Tint.leafy,
          adaptiveHint: true,
        ),
        Text(l.constraintsRestrictionsDescription, style: AppText.of(AppFont.s14, color: AppColors.ink2)),
        const SizedBox(height: AppSpace.x2_5),
        Wrap(
          spacing: AppSpace.x2,
          runSpacing: AppSpace.x2,
          children: [
            for (final diet in ConstraintsScreen.restrictions(l))
              ToggleChip(
                label: diet.$2,
                leading: _DietIllustration(asset: diet.$3, tint: diet.$4),
                selected: d.diets.contains(diet.$1),
                onTap: () => d.update(() => d.diets.toggle(diet.$1)),
                height: 56,
              ),
          ],
        ),
        const SizedBox(height: AppSpace.x6),
        StepSectionTitle(
          l.constraintsAllergensSection,
          hint: l.constraintsAllergensHint,
          icon: AppIcons.shield,
          tint: Tint.peach,
          adaptiveHint: true,
        ),
        Text(l.constraintsAllergensDescription, style: AppText.of(AppFont.s14, color: AppColors.ink2)),
        const SizedBox(height: AppSpace.x3),
        if (d.allAllergens.difference(ConstraintsScreen.allergenChoices(l).expand((a) => a.$1).toSet()).isNotEmpty) ...[
          FormError(
            message: l.constraintsUnknownCodes(
              d.allAllergens.difference(ConstraintsScreen.allergenChoices(l).expand((a) => a.$1).toSet()).join(', '),
            ),
          ),
          const SizedBox(height: AppSpace.x3),
        ],
        if (d.isFoyer && d.memberAllergenNames(l).isNotEmpty) ...[
          InfoBanner(
            icon: AppIcons.shield,
            title: l.constraintsMemberAllergensTitle,
            text: [
              for (final a in ConstraintsScreen.allergenChoices(l))
                if (a.$1.any(d.memberAllergenNames(l).containsKey))
                  '${a.$2} (${{for (final c in a.$1) ...?d.memberAllergenNames(l)[c]}.join(', ')})',
            ].join(' · '),
            background: Tint.peach.soft,
          ),
          const SizedBox(height: AppSpace.x3),
        ],
        _ResponsiveAllergenGrid(
          allergens: ConstraintsScreen.commonAllergens(l),
          selectedCodes: d.allergens,
          onToggle: (codes) => d.update(() {
            d.allergens.containsAll(codes) ? d.allergens.removeAll(codes) : d.allergens.addAll(codes);
          }),
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
        StepSectionTitle(
          l.constraintsExcludedSection,
          hint: l.constraintsExcludedHint,
          icon: AppIcons.block,
          tint: Tint.lavender,
          adaptiveHint: true,
        ),
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
        InfoBanner(icon: AppIcons.sparkles, title: l.constraintsInfoTitle, text: l.constraintsInfoText),
      ],
    );
  }
}

class _DietIllustration extends StatelessWidget {
  const _DietIllustration({required this.asset, required this.tint});

  final String asset;
  final Tint tint;

  @override
  Widget build(BuildContext context) => Container(
    width: 48,
    height: 48,
    decoration: BoxDecoration(color: tint.soft, shape: BoxShape.circle),
    alignment: Alignment.center,
    child: ExcludeSemantics(child: Image.asset(asset, width: 44, height: 44, fit: BoxFit.contain)),
  );
}

typedef _AllergenData = (List<String>, String, String, String, Tint, String);

class _ResponsiveAllergenGrid extends StatelessWidget {
  const _ResponsiveAllergenGrid({required this.allergens, required this.selectedCodes, required this.onToggle});

  final List<_AllergenData> allergens;
  final Set<String> selectedCodes;
  final ValueChanged<List<String>> onToggle;

  Widget _tile(_AllergenData allergen) => OptionTile(
    label: allergen.$2,
    subtitle: allergen.$3,
    leading: FoodThumb(
      photo: 'assets/images/allergens/${allergen.$6}.jpg',
      icon: allergen.$4,
      tint: allergen.$5,
      size: AppSizes.allergenImage,
    ),
    selected: selectedCodes.containsAll(allergen.$1),
    onTap: () => onToggle(allergen.$1),
    allowTextWrap: true,
  );

  @override
  Widget build(BuildContext context) {
    final singleColumn = MediaQuery.sizeOf(context).width < 360;
    if (singleColumn) {
      return Column(
        children: [
          for (var i = 0; i < allergens.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpace.x2),
            _tile(allergens[i]),
          ],
        ],
      );
    }

    return Column(
      children: [
        for (var i = 0; i < allergens.length; i += 2) ...[
          if (i > 0) const SizedBox(height: AppSpace.x2),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _tile(allergens[i])),
                const SizedBox(width: AppSpace.x2),
                Expanded(child: i + 1 < allergens.length ? _tile(allergens[i + 1]) : const SizedBox.shrink()),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
