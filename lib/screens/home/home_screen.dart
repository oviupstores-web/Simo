import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../l10n/app_localizations.dart';
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
  static List<(String, int)> _days(L l) => [
    (l.dayMonShort, 14), (l.dayTueShort, 15), (l.dayWedShort, 16), (l.dayThuShort, 17), (l.dayFriShort, 18), (l.daySatShort, 19), (l.daySunShort, 20),
  ];
  static List<(String, String, String, int)> _meals(L l) => [
    ('meal_breakfast.jpg', l.mealBreakfastShortLabel, l.homeDemoBreakfast, 320),
    ('meal_lunch.jpg', l.mealLunch, l.homeDemoLunch, 520),
    ('meal_dinner.jpg', l.mealDinner, l.homeDemoDinner, 450),
  ];

  int _day = 1;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
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
                        Text(l.homeGreeting('Karim'), style: AppText.h1Dash),
                        const SizedBox(height: AppSpace.x1),
                        Text(l.homeSubtitle, style: AppText.lead),
                        const SizedBox(height: AppSpace.x4),
                        _DayStrip(days: _days(l), selected: _day, onSelect: (i) => setState(() => _day = i)),
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
                        Text(l.homeMenuOfDay, style: AppText.h2),
                        Row(
                          children: [
                            Text(
                              l.homeSeeAll,
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
                          for (final (i, m) in _meals(l).indexed) ...[
                            if (i > 0) const SizedBox(width: AppSpace.x2_5),
                            Expanded(
                              child: _MealCard(image: m.$1, label: m.$2, name: m.$3, kcal: m.$4),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpace.x6),
                    Text(l.homeIndicators, style: AppText.h2),
                    const SizedBox(height: AppSpace.x3),
                    const _BudgetSnippet(),
                    const SizedBox(height: AppSpace.x3),
                    const _NutritionSnippet(),
                    const SizedBox(height: AppSpace.x3),
                    const _DietSnippet(),
                    const SizedBox(height: AppSpace.x3),
                    AlertBanner(
                      text: TextSpan(
                        text: l.homeAntiwasteAlert(2),
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
    final l = L.of(context);
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
    final l = L.of(context);
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
                  l.unitKcal('$kcal'),
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
    final l = L.of(context);
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
    final l = L.of(context);
    return AppCard(
      onTap: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SnippetHeader(
            icon: AppIcons.wallet,
            title: l.homeBudgetTitle,
            subtitle: l.homeInBudget,
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
                AppText.highlightSubstring(
                  L.of(context).homeRemaining('16,80 €'),
                  '16,80 €',
                  AppText.of(AppFont.s12, weight: AppFont.bold, color: AppColors.primary),
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
    final l = L.of(context);
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
                Text(L.of(context).homeCaloriesToday, style: AppText.of(AppFont.s13, color: AppColors.ink2, lineHeight: 18)),
                Text.rich(_valueWithUnit('1 450', '/ 2 000 kcal')),
                const SizedBox(height: AppSpace.x1_5),
                Wrap(
                  spacing: AppSpace.x3,
                  children: [
                    legend(AppColors.primary, L.of(context).homeMacroProtein(90)),
                    legend(AppColors.orange, L.of(context).homeMacroCarbs(160)),
                    legend(AppColors.fat, L.of(context).homeMacroFat(54)),
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
    final l = L.of(context);
    return AppCard(
      onTap: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SnippetHeader(icon: AppIcons.scale, title: L.of(context).homeDietTitle, subtitle: L.of(context).homeWeighedThisMorning),
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
                  Text(L.of(context).homeWeightTarget('72 kg', '0,5 kg'), style: AppText.meta),
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
