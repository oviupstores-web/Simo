import 'package:flutter/material.dart';

import '../../models/pantry_location.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

typedef _Item = (String image, String name, String detail, bool urgent, String left);

/// pantry_home — maître : design/masters/master_operationnel.html (réf. 08_type_operationnel.png).
/// Produits regroupés par emplacement, puces de filtre avec compteur.
class PantryHomeScreen extends StatefulWidget {
  const PantryHomeScreen({super.key});

  @override
  State<PantryHomeScreen> createState() => _PantryHomeScreenState();
}

class _PantryHomeScreenState extends State<PantryHomeScreen> {
  static const Map<PantryLocation, List<_Item>> _stock = {
    PantryLocation.fridge: [
      ('p_poulet.jpg', 'Poulet', '2 filets (300 g)', true, '2 j'),
      ('p_yaourt.jpg', 'Yaourt nature', '2 pots', false, '8 j'),
      ('p_lait.jpg', 'Lait demi-écrémé', '1 L · entamé', false, '3 j'),
      ('p_carotte.jpg', 'Carottes', '500 g · bac à légumes', false, '5 j'),
    ],
    PantryLocation.fruitBasket: [
      ('i_citron.jpg', 'Citrons', '2 pièces', false, '9 j'),
      ('i_tomates.jpg', 'Tomates cerises', '250 g', false, '4 j'),
    ],
    PantryLocation.pantry: [
      ('i_quinoa.jpg', 'Quinoa', '500 g · entamé', false, '2027'),
      ('i_huile.jpg', 'Huile d\'olive', '75 cl', false, '2027'),
    ],
    PantryLocation.freezer: [('i_brocoli.jpg', 'Brocoli surgelé', '1 kg', false, '3 mois')],
  };

  /// null = « Tous ».
  PantryLocation? _filter;

  int get _total => _stock.values.fold(0, (s, l) => s + l.length);

  @override
  Widget build(BuildContext context) {
    final shown = _filter == null ? PantryLocation.values : [_filter!];
    return Scaffold(
      bottomNavigationBar: const MenooNavBar(current: MenooTab.reserve),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: AppSpace.x6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MenooHeader(
                showBack: false,
                trailing: Semantics(
                  button: true,
                  label: 'Scanner',
                  child: AppIcon(AppIcons.scan, size: 26, color: AppColors.primary),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpace.gutter),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpace.x4),
                    AppCard(
                      child: Row(
                        children: [
                          const IconTile(icon: AppIcons.fridge, size: AppSizes.iconTileMd, iconSize: 22),
                          const SizedBox(width: AppSpace.x3),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ma réserve alimentaire',
                                  style: AppText.of(AppFont.s16, weight: AppFont.extrabold, lineHeight: 24),
                                ),
                                Text('$_total produits · 4 emplacements', style: AppText.caption),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpace.x3),
                    AlertBanner(
                      onTap: () {},
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Poulet',
                            style: AppText.of(AppFont.s12_5, weight: AppFont.bold, color: AppColors.alertInk),
                          ),
                          const TextSpan(text: ' à consommer d\'ici 2 jours · Réfrigérateur'),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpace.x3),
                    const Row(
                      children: [
                        Expanded(
                          child: _QuickAction(icon: AppIcons.plus, label: 'Manuel'),
                        ),
                        SizedBox(width: AppSpace.x2),
                        Expanded(
                          child: _QuickAction(icon: AppIcons.barcode, label: 'Code-barres'),
                        ),
                        SizedBox(width: AppSpace.x2),
                        Expanded(
                          child: _QuickAction(icon: AppIcons.camera, label: 'Photo IA'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpace.x4),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpace.gutter),
                child: Row(
                  children: [
                    FilterPill(
                      label: 'Tous · $_total',
                      selected: _filter == null,
                      onTap: () => setState(() => _filter = null),
                    ),
                    for (final loc in PantryLocation.values) ...[
                      const SizedBox(width: AppSpace.x2),
                      FilterPill(
                        label: '${loc.short} · ${_stock[loc]!.length}',
                        icon: loc.icon,
                        selected: _filter == loc,
                        onTap: () => setState(() => _filter = loc),
                      ),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpace.gutter),
                child: AnimatedSize(
                  duration: AppMotion.normal,
                  curve: AppMotion.curve,
                  alignment: Alignment.topCenter,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final loc in shown) ...[
                        const SizedBox(height: AppSpace.x3),
                        _LocationSection(location: loc, items: _stock[loc]!),
                      ],
                      const SizedBox(height: AppSpace.x4),
                      AppCard(
                        onTap: () {},
                        child: Row(
                          children: [
                            const AppIcon(AppIcons.cart, size: 24, color: AppColors.orange),
                            const SizedBox(width: AppSpace.x3),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'À acheter cette semaine',
                                    style: AppText.of(AppFont.s15, weight: AppFont.extrabold, lineHeight: 22),
                                  ),
                                  Text('Réserve déjà déduite de la liste', style: AppText.meta),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpace.x3),
                            PillBadge(
                              '≈ 12,50 €',
                              size: AppFont.s14,
                              weight: AppFont.extrabold,
                              padding: const EdgeInsets.symmetric(horizontal: AppSpace.x3, vertical: AppSpace.x1),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label});

  final String icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: () {},
      child: Container(
        height: AppSizes.quickActionHeight,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppRadius.fieldR,
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIcon(icon, size: 17),
            const SizedBox(width: AppSpace.x1_5),
            Text(label, style: AppText.of(AppFont.s13, weight: AppFont.semibold)),
          ],
        ),
      ),
    );
  }
}

class _LocationSection extends StatelessWidget {
  const _LocationSection({required this.location, required this.items});

  final PantryLocation location;
  final List<_Item> items;

  @override
  Widget build(BuildContext context) {
    return ListSectionCard(
      leading: IconTile(
        icon: location.icon,
        size: AppSizes.iconTileSm,
        background: location.soft,
        foreground: location.ink,
      ),
      title: location.label,
      count: '${items.length} produit${items.length > 1 ? 's' : ''}',
      rows: [
        for (final it in items)
          ItemRow(
            image: it.$1,
            title: it.$2,
            subtitle: it.$3,
            trailing: [
              FreshnessStatus(urgent: it.$4),
              SizedBox(
                width: AppSizes.thumbW,
                child: Text(it.$5, textAlign: TextAlign.right, style: AppText.meta),
              ),
            ],
          ),
      ],
    );
  }
}
