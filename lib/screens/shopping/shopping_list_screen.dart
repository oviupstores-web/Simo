import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

typedef _Article = (String image, String name, String qty, String price);

/// liste_courses (version gratuite) — maître : design/masters/master_courses_gratuit.html.
/// SPEC §6 : total, budget et premier rayon en clair ; rayons suivants floutés
/// sous la carte « Débloquez la liste complète » → paywall_premium.
class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  static const List<_Article> _fruits = [
    ('f_banane.jpg', 'Bananes', '1 kg', '1,99 €'),
    ('f_epinards.jpg', 'Épinards frais', '200 g', '1,89 €'),
    ('i_tomates.jpg', 'Tomates cerises', '250 g', '2,29 €'),
    ('i_citron.jpg', 'Citrons', '2 pièces', '0,98 €'),
  ];
  static const List<_Article> _fresh = [
    ('i_saumon.jpg', 'Pavés de saumon', '4 pièces', '16,40 €'),
    ('p_poulet.jpg', 'Filets de poulet', '600 g', '8,90 €'),
    ('p_yaourt.jpg', 'Yaourt grec', '1 kg', '3,20 €'),
  ];
  static const List<_Article> _grocery = [
    ('f_amandes.jpg', 'Amandes', '250 g', '3,49 €'),
    ('i_quinoa.jpg', 'Quinoa bio', '500 g', '3,40 €'),
  ];

  final _checked = <String>{};

  Widget _section(String icon, String title, String count, List<_Article> items, {bool interactive = true}) {
    return ListSectionCard(
      leading: AppIcon(icon, size: 20, color: AppColors.primary),
      title: title,
      count: count,
      rows: [
        for (final a in items)
          ItemRow(
            small: true,
            image: a.$1,
            title: a.$2,
            subtitle: a.$3,
            leading: SquareCheck(
              checked: _checked.contains(a.$2),
              onChanged: interactive ? (v) => setState(() => v ? _checked.add(a.$2) : _checked.remove(a.$2)) : null,
            ),
            trailing: [Text(a.$4, style: AppText.of(AppFont.s14, weight: AppFont.bold))],
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const MenooNavBar(current: MenooTab.courses),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: AppSpace.x6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const MenooHeader(showBack: false, trailing: HeaderAvatar()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpace.gutter),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpace.x5),
                    Text('Ma liste de courses', style: AppText.h1Dash),
                    const SizedBox(height: AppSpace.x1),
                    Text(
                      'Semaine du 14 au 20 · réserve déduite',
                      style: AppText.of(AppFont.s14, color: AppColors.ink2),
                    ),
                    const SizedBox(height: AppSpace.x4),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Total estimé · 12 articles', style: AppText.caption),
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(text: '52,80 €', style: AppText.bigNumber),
                                        TextSpan(
                                          text: ' / 65 €',
                                          style: AppText.of(AppFont.s13, weight: AppFont.medium, color: AppColors.ink2),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const PillBadge(
                                'Dans le budget ✓',
                                size: AppFont.s12,
                                padding: EdgeInsets.symmetric(horizontal: AppSpace.x2_5, vertical: AppSpace.x1),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpace.x2),
                          const GaugeBar(value: 0.81),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpace.x4),
                    _section(AppIcons.leaf, 'Fruits & Légumes', '4 articles', _fruits),
                    const SizedBox(height: AppSpace.x3),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ExcludeSemantics(
                          child: ImageFiltered(
                            imageFilter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _section(
                                  AppIcons.fridge,
                                  'Frais & Protéines',
                                  '5 articles',
                                  _fresh,
                                  interactive: false,
                                ),
                                const SizedBox(height: AppSpace.x3),
                                _section(AppIcons.cupboard, 'Épicerie', '3 articles', _grocery, interactive: false),
                              ],
                            ),
                          ),
                        ),
                        const Positioned(left: AppSpace.x1, right: AppSpace.x1, top: AppSpace.x6, child: _UnlockCard()),
                      ],
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

class _UnlockCard extends StatelessWidget {
  const _UnlockCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpace.x5),
      decoration: BoxDecoration(
        color: AppColors.overlayCard,
        borderRadius: AppRadius.cardR,
        border: Border.all(color: AppColors.line),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          const IconTile(icon: AppIcons.lock, size: AppSizes.lockCircle, iconSize: 22, circle: true),
          const SizedBox(height: AppSpace.x3),
          Text(
            'Débloquez la liste complète',
            style: AppText.of(AppFont.s17, weight: AppFont.extrabold, lineHeight: 24),
          ),
          const SizedBox(height: AppSpace.x1),
          Text(
            '8 articles de plus, le comparateur de prix entre enseignes et l\'envoi au drive.',
            textAlign: TextAlign.center,
            style: AppText.of(AppFont.s13, color: AppColors.ink2, lineHeight: 19),
          ),
          const SizedBox(height: AppSpace.x4),
          PrimaryButton(
            label: 'Essayer 7 jours gratuits',
            showArrow: false,
            height: AppSizes.btnSecondaryHeight,
            textStyle: AppText.of(AppFont.s16, weight: AppFont.bold, color: AppColors.white),
            onPressed: () {}, // → paywall_premium (jalon 7)
          ),
          const SizedBox(height: AppSpace.x2),
          Text('Puis 9,99 €/mois · sans engagement', style: AppText.of(AppFont.s12, color: AppColors.ink3)),
        ],
      ),
    );
  }
}
