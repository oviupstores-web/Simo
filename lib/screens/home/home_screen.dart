import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

/// `home` (Solo) — **onglet 1 de l'app, après connexion** : « Bonjour Karim », repas du jour, indicateurs.
/// À ne jamais confondre avec `landing` (la page déroulante d'avant le compte) — SPEC §0.13.
/// Maître : design/masters/master_dashboard.html (réf. 06_type_dashboard.png).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _days = [('Lun', 14), ('Mar', 15), ('Mer', 16), ('Jeu', 17), ('Ven', 18), ('Sam', 19), ('Dim', 20)];
  static const _meals = [
    ('meal_breakfast.jpg', 'Petit-déj.', 'Porridge aux fruits', 320),
    ('meal_lunch.jpg', 'Déjeuner', 'Bol quinoa poulet', 520),
    ('meal_dinner.jpg', 'Dîner', 'Saumon grillé', 450),
  ];

  int _day = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const MenooNavBar(current: MenooTab.accueil),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: AppSpace.x6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const MenooHeader(
                brandLeft: true,
                trailing: Row(
                  children: [
                    AppIcon(AppIcons.bell, size: 24, strokeWidth: 1.9),
                    SizedBox(width: AppSpace.x3),
                    HeaderAvatar(),
                  ],
                ),
              ),
              Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  const Positioned(
                    right: AppSpace.x2,
                    top: AppSpace.x5,
                    child: BasilDecor(leafWidth: 30, mirror: true, peppers: false, opacity: 0.85),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpace.gutter),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: AppSpace.x5),
                        Text('Bonjour Karim 👋', style: AppText.h1Dash),
                        const SizedBox(height: AppSpace.x1),
                        Text('Voici votre programme du jour', style: AppText.lead),
                        const SizedBox(height: AppSpace.x4),
                        _DayStrip(days: _days, selected: _day, onSelect: (i) => setState(() => _day = i)),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpace.gutter),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpace.x6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Mon menu du jour', style: AppText.h2),
                        Row(
                          children: [
                            Text(
                              'Voir tout',
                              style: AppText.of(AppFont.s13, weight: AppFont.semibold, color: AppColors.primary),
                            ),
                            const AppIcon(AppIcons.chevronRight, size: 15, color: AppColors.primary),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpace.x3),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final (i, m) in _meals.indexed) ...[
                            if (i > 0) const SizedBox(width: AppSpace.x2_5),
                            Expanded(
                              child: _MealCard(image: m.$1, label: m.$2, name: m.$3, kcal: m.$4),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpace.x6),
                    Text('Mes indicateurs', style: AppText.h2),
                    const SizedBox(height: AppSpace.x3),
                    const _BudgetSnippet(),
                    const SizedBox(height: AppSpace.x3),
                    const _NutritionSnippet(),
                    const SizedBox(height: AppSpace.x3),
                    const _DietSnippet(),
                    const SizedBox(height: AppSpace.x3),
                    const AlertBanner(
                      text: TextSpan(
                        text: '2 produits à consommer d\'ici demain : une recette anti-gaspi vous attend.',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayStrip extends StatelessWidget {
  const _DayStrip({required this.days, required this.selected, required this.onSelect});

  final List<(String, int)> days;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpace.x1_5),
      child: Row(
        children: [
          for (final (i, d) in days.indexed)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onSelect(i),
                child: AnimatedContainer(
                  duration: AppMotion.normal,
                  curve: AppMotion.curve,
                  padding: const EdgeInsets.symmetric(vertical: AppSpace.x2),
                  decoration: BoxDecoration(
                    color: i == selected ? AppColors.primary : AppColors.card,
                    borderRadius: AppRadius.tileR,
                  ),
                  child: Column(
                    children: [
                      Text(
                        d.$1,
                        style: AppText.of(
                          AppFont.s11,
                          color: i == selected ? AppColors.white.withValues(alpha: 0.9) : AppColors.ink2,
                          lineHeight: 16,
                        ),
                      ),
                      Text(
                        '${d.$2}',
                        style: AppText.of(
                          AppFont.s15,
                          weight: AppFont.bold,
                          color: i == selected ? AppColors.white : AppColors.ink,
                          lineHeight: 22,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  const _MealCard({required this.image, required this.label, required this.name, required this.kcal});

  final String image;
  final String label;
  final String name;
  final int kcal;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      clip: true,
      onTap: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.asset('assets/images/$image', height: AppSizes.mealThumbH, fit: BoxFit.cover, semanticLabel: name),
          Padding(
            padding: const EdgeInsets.all(AppSpace.x2_5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppText.of(AppFont.s12, weight: AppFont.bold, lineHeight: 16)),
                const SizedBox(height: AppSpace.x0_5),
                Text(name, style: AppText.of(AppFont.s11, color: AppColors.ink2, lineHeight: 14)),
                const SizedBox(height: AppSpace.x1),
                Text(
                  '$kcal kcal',
                  style: AppText.of(AppFont.s11, weight: AppFont.semibold, color: AppColors.leaf, lineHeight: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// En-tête commun des cartes d'indicateur : pastille ronde, titre, sous-titre, chevron.
class _SnippetHeader extends StatelessWidget {
  const _SnippetHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.subtitleColor = AppColors.ink2,
    this.subtitleWeight = AppFont.regular,
  });

  final String icon;
  final String title;
  final String subtitle;
  final Color subtitleColor;
  final FontWeight subtitleWeight;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconTile(icon: icon, circle: true, iconSize: 20),
        const SizedBox(width: AppSpace.x3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppText.of(AppFont.s14, weight: AppFont.bold, lineHeight: 20)),
              Text(
                subtitle,
                style: AppText.of(AppFont.s12, weight: subtitleWeight, color: subtitleColor, lineHeight: 16),
              ),
            ],
          ),
        ),
        const CardChevron(),
      ],
    );
  }
}

TextSpan _valueWithUnit(String value, String unit) => TextSpan(
  children: [
    TextSpan(text: value, style: AppText.bigNumber),
    TextSpan(
      text: ' $unit',
      style: AppText.of(AppFont.s13, weight: AppFont.medium, color: AppColors.ink2),
    ),
  ],
);

class _BudgetSnippet extends StatelessWidget {
  const _BudgetSnippet();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SnippetHeader(
            icon: AppIcons.wallet,
            title: 'Budget de la semaine',
            subtitle: 'Dans le budget ✓',
            subtitleColor: AppColors.leaf,
            subtitleWeight: AppFont.semibold,
          ),
          const SizedBox(height: AppSpace.x3),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text.rich(_valueWithUnit('48,20 €', '/ 65 €')),
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: 'Reste '),
                    TextSpan(
                      text: '16,80 €',
                      style: AppText.of(AppFont.s12, weight: AppFont.bold, color: AppColors.primary),
                    ),
                  ],
                ),
                style: AppText.meta,
              ),
            ],
          ),
          const SizedBox(height: AppSpace.x2),
          const GaugeBar(value: 0.74),
        ],
      ),
    );
  }
}

class _NutritionSnippet extends StatelessWidget {
  const _NutritionSnippet();

  @override
  Widget build(BuildContext context) {
    Widget legend(Color c, String t) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Dot(c),
        const SizedBox(width: AppSpace.x1),
        Text(t, style: AppText.meta),
      ],
    );
    return AppCard(
      onTap: () {},
      child: Row(
        children: [
          const ProgressRing(value: 113 / 157),
          const SizedBox(width: AppSpace.x4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Calories du jour', style: AppText.of(AppFont.s13, color: AppColors.ink2, lineHeight: 18)),
                Text.rich(_valueWithUnit('1 450', '/ 2 000 kcal')),
                const SizedBox(height: AppSpace.x1_5),
                Wrap(
                  spacing: AppSpace.x3,
                  children: [
                    legend(AppColors.primary, 'P 90 g'),
                    legend(AppColors.orange, 'G 160 g'),
                    legend(AppColors.fat, 'L 54 g'),
                  ],
                ),
              ],
            ),
          ),
          const CardChevron(),
        ],
      ),
    );
  }
}

class _DietSnippet extends StatelessWidget {
  const _DietSnippet();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SnippetHeader(icon: AppIcons.scale, title: 'Mon régime', subtitle: 'Pesée synchronisée ce matin'),
          const SizedBox(height: AppSpace.x3),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text.rich(_valueWithUnit('74,3', 'kg')),
                      const SizedBox(width: AppSpace.x1 + AppSpace.x1),
                      const PillBadge(
                        '−0,7 kg',
                        icon: AppIcons.trendDown,
                        size: AppFont.s12,
                        padding: EdgeInsets.symmetric(horizontal: AppSpace.x2, vertical: AppSpace.x0_5),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpace.x0_5),
                  Text('Objectif : 72 kg · 0,5 kg/semaine', style: AppText.meta),
                ],
              ),
              const WeightSparkline(),
            ],
          ),
        ],
      ),
    );
  }
}
