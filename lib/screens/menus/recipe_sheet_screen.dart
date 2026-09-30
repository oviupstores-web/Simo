import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

/// Fiche recette — maître : design/masters/master_recette.html (réf. 07_type_recette.png).
/// Gabarit de toutes les fiches repas et recettes.
class RecipeSheetScreen extends StatefulWidget {
  const RecipeSheetScreen({super.key});

  @override
  State<RecipeSheetScreen> createState() => _RecipeSheetScreenState();
}

class _RecipeSheetScreenState extends State<RecipeSheetScreen> {
  static const _ingredients = [
    ('i_saumon.jpg', 'Saumon frais', '4 pavés (600 g)', false),
    ('i_quinoa.jpg', 'Quinoa', '200 g', true),
    ('i_brocoli.jpg', 'Brocoli', '1 tête (300 g)', false),
    ('i_tomates.jpg', 'Tomates cerises', '250 g', false),
    ('i_huile.jpg', 'Huile d\'olive', '2 c. à soupe', true),
    ('i_citron.jpg', 'Citron', '1 pièce', true),
  ];

  // Macros : icône colorée (réf. 07), valeur, libellé.
  static const _macros = [
    (AppIcons.flame, AppColors.orange, '450', 'kcal'),
    (AppIcons.leaf, AppColors.leaf, '32 g', 'protéines'),
    (AppIcons.wheat, AppColors.warn, '48 g', 'glucides'),
    (AppIcons.drop, AppColors.fat, '18 g', 'lipides'),
  ];

  int _tab = 0;
  int _servings = 4;
  bool _favorite = false;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: AppSizes.btnHeight + AppSpace.x10 + bottomInset),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MenooHeader(
                    trailing: GestureDetector(
                      onTap: () => setState(() => _favorite = !_favorite),
                      child: AnimatedSwitcher(
                        duration: AppMotion.normal,
                        transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
                        child: AppIcon(
                          AppIcons.heart,
                          key: ValueKey(_favorite),
                          size: 24,
                          strokeWidth: 1.9,
                          color: _favorite ? AppColors.orange : AppColors.ink,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpace.x3),
                  Image.asset(
                    'assets/images/hero_saumon.jpg',
                    height: AppSizes.recipeHeroH,
                    fit: BoxFit.cover,
                    semanticLabel: 'Saumon grillé, quinoa et légumes',
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpace.gutter),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: AppSpace.x4),
                        Text(
                          'Saumon grillé, quinoa et légumes',
                          style: AppText.of(
                            AppFont.s23,
                            weight: AppFont.extrabold,
                            lineHeight: 29,
                            tightTracking: true,
                          ),
                        ),
                        const SizedBox(height: AppSpace.x3),
                        const Wrap(
                          spacing: AppSpace.x2,
                          runSpacing: AppSpace.x2,
                          children: [
                            InfoChip(label: 'Dîner', icon: AppIcons.moon, highlighted: true),
                            InfoChip(label: 'Facile', icon: AppIcons.level),
                            InfoChip(label: '25 min', icon: AppIcons.clock),
                            InfoChip(label: '4 pers.', icon: AppIcons.people),
                          ],
                        ),
                        const SizedBox(height: AppSpace.x3),
                        Text(
                          'Un plat sain et savoureux, riche en oméga-3 et en fibres. Parfait pour un dîner léger et nourrissant.',
                          style: AppText.body,
                        ),
                        const SizedBox(height: AppSpace.x4),
                        Row(
                          children: [
                            for (final (i, m) in _macros.indexed) ...[
                              if (i > 0) const SizedBox(width: AppSpace.x2),
                              Expanded(
                                child: _MacroTile(icon: m.$1, color: m.$2, value: m.$3, label: m.$4),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: AppSpace.x5),
                        _Tabs(
                          labels: const ['Ingrédients', 'Étapes', 'Infos'],
                          selected: _tab,
                          onSelect: (i) => setState(() => _tab = i),
                        ),
                        const SizedBox(height: AppSpace.x3),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '3 ingrédients déjà en réserve',
                              style: AppText.of(AppFont.s13, color: AppColors.ink2),
                            ),
                            QuantityStepper(
                              value: '$_servings',
                              onMinus: () => setState(() => _servings = (_servings - 1).clamp(1, 12)),
                              onPlus: () => setState(() => _servings = (_servings + 1).clamp(1, 12)),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpace.x1),
                        for (final (i, ing) in _ingredients.indexed) ...[
                          if (i > 0) const Divider(height: 1, thickness: 1, color: AppColors.line),
                          ItemRow(
                            image: ing.$1,
                            title: ing.$2,
                            subtitle: ing.$3,
                            trailing: [ing.$4 ? const PillBadge('En réserve ✓') : const PillBadge.orange('À acheter')],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Barre d'action fixe
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: AppColors.bottomBarBg,
              padding: EdgeInsets.fromLTRB(AppSpace.gutter, AppSpace.x3, AppSpace.gutter, bottomInset + AppSpace.x3_5),
              child: const PrimaryButton(label: 'Démarrer la recette'),
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroTile extends StatelessWidget {
  const _MacroTile({required this.icon, required this.color, required this.value, required this.label});

  final String icon;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpace.x2_5),
      decoration: const BoxDecoration(color: AppColors.card, borderRadius: AppRadius.tileR, boxShadow: AppShadows.card),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppIcon(icon, size: 15, color: color),
              const SizedBox(width: AppSpace.x1),
              Text(value, style: AppText.of(AppFont.s16, weight: AppFont.extrabold, lineHeight: 22)),
            ],
          ),
          Text(label, style: AppText.of(AppFont.s11, color: AppColors.ink2, lineHeight: 16)),
        ],
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({required this.labels, required this.selected, required this.onSelect});

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.line)),
      ),
      child: Row(
        children: [
          for (final (i, l) in labels.indexed)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onSelect(i),
                child: AnimatedContainer(
                  duration: AppMotion.normal,
                  padding: const EdgeInsets.only(bottom: AppSpace.x2_5),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: i == selected ? AppColors.primary : AppColors.transparent, width: 2.5),
                    ),
                  ),
                  child: Text(
                    l,
                    textAlign: TextAlign.center,
                    style: AppText.of(
                      AppFont.s14,
                      weight: i == selected ? AppFont.bold : AppFont.medium,
                      color: i == selected ? AppColors.primary : AppColors.ink2,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
