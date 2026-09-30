import 'package:flutter/material.dart';

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

  static const diets = [
    ('vegetarien', 'Végétarien', AppIcons.leaf, Tint.leafy),
    ('vegan', 'Végan', AppIcons.sprout, Tint.mint),
    ('pescetarien', 'Pescétarien', AppIcons.fish, Tint.sky),
    ('sans_porc', 'Sans porc', AppIcons.noPork, Tint.lavender),
    ('sans_lactose', 'Sans lactose', AppIcons.noMilk, Tint.sky),
    ('sans_gluten', 'Sans gluten', AppIcons.noGluten, Tint.peach),
  ];

  /// Allergènes courants (un choix peut couvrir plusieurs codes). Dernier champ : photo (assets/images/allergens/).
  static const commonAllergens = [
    (['gluten'], 'Gluten', 'Blé, seigle, orge', AppIcons.wheat, Tint.peach, 'gluten'),
    (['arachides'], 'Arachides', 'Cacahuètes & dérivés', AppIcons.nut, Tint.sand, 'arachides'),
    (['crustaces', 'mollusques'], 'Fruits de mer', 'Crustacés, mollusques', AppIcons.shrimp, Tint.sky, 'fruits_de_mer'),
    (['oeufs'], 'Œufs', 'Jaune, blanc', AppIcons.egg, Tint.peach, 'oeufs'),
    (['soja'], 'Soja', 'Tofu, sauce soja', AppIcons.sprout, Tint.leafy, 'soja'),
    (['fruits_a_coque'], 'Fruits à coque', 'Noix, amandes', AppIcons.nut, Tint.leafy, 'fruits_a_coque'),
  ];

  /// Le code est aussi le nom de la photo.
  static const otherAllergens = [
    ('poisson', 'Poisson', AppIcons.fish, Tint.sky),
    ('lait', 'Lait', AppIcons.drop, Tint.sky),
    ('sesame', 'Sésame', AppIcons.sparkles, Tint.sand),
    ('moutarde', 'Moutarde', AppIcons.drop, Tint.peach),
    ('celeri', 'Céleri', AppIcons.leaf, Tint.leafy),
    ('sulfites', 'Sulfites', AppIcons.drop, Tint.lavender),
    ('lupin', 'Lupin', AppIcons.sprout, Tint.leafy),
  ];

  /// Tous les choix d'allergènes (codes couverts, libellé, icône, teinte).
  static List<(List<String>, String, String, Tint)> get allergenChoices => [
    for (final a in commonAllergens) (a.$1, a.$2, a.$4, a.$5),
    for (final a in otherAllergens) ([a.$1], a.$2, a.$3, a.$4),
  ];

  /// Libellés des allergènes d'un ensemble de codes (« Fruits de mer » couvre 2 codes).
  static List<String> allergenLabels(Set<String> codes) => [
    for (final a in allergenChoices)
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
    final d = OnboardingScope.of(context);
    final othersSelected = ConstraintsScreen.otherAllergens.where((a) => d.allergens.contains(a.$1)).length;
    return OnboardingStepScaffold(
      step: OnboardingFlow.number(context, OnbStep.constraints),
      totalSteps: OnboardingFlow.total(context),
      eyebrow: d.isFoyer ? 'CUISINE UNIFIÉE' : 'PRESQUE FINI !',
      eyebrowIcon: AppIcons.checkCircle,
      title: d.isFoyer ? 'Régimes & contraintes partagées' : 'Régimes & contraintes alimentaires',
      subtitle: d.isFoyer
          ? 'Définissez les règles communes à toute la tablée : aucun repas du foyer ne les enfreindra.'
          : 'Indiquez vos régimes, allergies et aliments exclus : aucun menu ne les contiendra.',
      onContinue: () {
        _addFood();
        OnboardingFlow.next(context, OnbStep.constraints);
      },
      children: [
        const StepSectionTitle('Régimes alimentaires', hint: 'Choix multiple', icon: AppIcons.leaf, tint: Tint.leafy),
        Wrap(
          spacing: AppSpace.x2,
          runSpacing: AppSpace.x2,
          children: [
            ToggleChip(
              label: 'Omnivore',
              icon: AppIcons.cutlery,
              tint: Tint.peach,
              selected: d.diets.isEmpty,
              onTap: () => d.update(d.diets.clear),
            ),
            for (final diet in ConstraintsScreen.diets)
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
        const StepSectionTitle('Allergènes', hint: 'Exclusion stricte', icon: AppIcons.shield, tint: Tint.peach),
        if (d.isFoyer && d.memberAllergens.isNotEmpty) ...[
          InfoBanner(
            icon: AppIcons.shield,
            title: 'Déjà exclus grâce aux profils',
            text: [
              for (final a in ConstraintsScreen.allergenChoices)
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
            for (final a in ConstraintsScreen.commonAllergens)
              OptionTile(
                label: a.$2,
                subtitle: a.$3,
                leading: FoodThumb(
                  photo: 'assets/images/allergens/${a.$6}.jpg',
                  icon: a.$4,
                  tint: a.$5,
                  size: AppSizes.iconTileSm,
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
                othersSelected > 0 ? 'Autres allergènes ($othersSelected)' : 'Autres allergènes',
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
                      for (final a in ConstraintsScreen.otherAllergens)
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
        const StepSectionTitle('Aliments exclus', hint: 'Sur-mesure', icon: AppIcons.block, tint: Tint.lavender),
        IconTextField(
          icon: AppIcons.search,
          hint: 'Ex. : coriandre, anchois, poivron…',
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
        const InfoBanner(
          icon: AppIcons.sparkles,
          title: 'Zéro compromis sur votre bien-être',
          text: 'Vous pourrez affiner vos goûts et ajouter d\'autres exclusions à tout moment dans vos réglages.',
        ),
      ],
    );
  }
}
