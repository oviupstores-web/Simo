import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
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
  static Map<PantryLocation, List<_Item>> _stock(L l) => {
    PantryLocation.fridge: [
      ('p_poulet.jpg', l.pantryDemoChicken, l.pantryDemoChicken2Fillets, true, l.pantryDaysLeft(2)),
      ('p_yaourt.jpg', l.pantryDemoYogurt, l.pantryDemo2Pots, false, l.pantryDaysLeft(8)),
      ('p_lait.jpg', l.pantryDemoMilk, l.pantryDemoMilkOpen, false, l.pantryDaysLeft(3)),
      ('p_carotte.jpg', l.pantryDemoCarrots, l.pantryDemoCarrotsDrawer, false, l.pantryDaysLeft(5)),
    ],
    PantryLocation.fruitBasket: [
      ('i_citron.jpg', l.pantryDemoLemons2, l.qty2Pieces, false, l.pantryDaysLeft(9)),
      ('i_tomates.jpg', l.pantryDemoCherryTomatoes2, l.unitGrams('250'), false, l.pantryDaysLeft(4)),
    ],
    PantryLocation.pantry: [
      ('i_quinoa.jpg', l.recipeDemoQuinoa, l.pantryDemoQuinoaOpen, false, '2027'),
      ('i_huile.jpg', l.recipeDemoOliveOil, '75 cl', false, '2027'),
    ],
    PantryLocation.freezer: [
      ('i_brocoli.jpg', l.pantryDemoFrozenBroccoli, l.unitKilograms('1'), false, l.pantryDemo3Months),
    ],
  };

  /// null = « Tous ».
  PantryLocation? _filter;

  int _total(L l) => _stock(l).values.fold(0, (s, items) => s + items.length);

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final stock = _stock(l);
    final total = _total(l);
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
                  label: l.pantryHomeScan,
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
                          const IconTile(icon: AppIcons.fridge, size: AppSizes.iconTileMd, iconSize: 26),
                          const SizedBox(width: AppSpace.x3),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l.pantryHomeTitle,
                                  style: AppText.of(AppFont.s16, weight: AppFont.extrabold, lineHeight: 24),
                                ),
                                Text(l.pantryHomeSummary(total, 4), style: AppText.caption),
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
                            text: l.pantryDemoChicken,
                            style: AppText.of(AppFont.s12_5, weight: AppFont.bold, color: AppColors.alertInk),
                          ),
                          TextSpan(text: ' ${l.pantryHomeUrgent(PantryLocation.fridge.label(l))}'),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpace.x3),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickAction(icon: AppIcons.plus, label: l.pantryQuickManual),
                        ),
                        const SizedBox(width: AppSpace.x2),
                        Expanded(
                          child: _QuickAction(icon: AppIcons.barcode, label: l.pantryQuickBarcode),
                        ),
                        const SizedBox(width: AppSpace.x2),
                        Expanded(
                          child: _QuickAction(icon: AppIcons.camera, label: l.pantryQuickPhotoAi, locked: true),
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
                      label: l.pantryHomeAll(total),
                      selected: _filter == null,
                      onTap: () => setState(() => _filter = null),
                    ),
                    for (final loc in PantryLocation.values) ...[
                      const SizedBox(width: AppSpace.x2),
                      FilterPill(
                        label: '${loc.short(l)} · ${stock[loc]!.length}',
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
                        _LocationSection(location: loc, items: stock[loc]!),
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
                                    l.pantryHomeToBuyTitle,
                                    style: AppText.of(AppFont.s15, weight: AppFont.extrabold, lineHeight: 22),
                                  ),
                                  Text(l.pantryHomeToBuyText, style: AppText.meta),
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
  const _QuickAction({required this.icon, required this.label, this.locked = false});

  final String icon;
  final String label;

  /// Fonction Premium (Photo IA, SPEC §0.8) : cadenas en haut à droite du bouton.
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: () {},
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: AppSizes.quickActionHeight,
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.x1_5),
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
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: AppText.of(AppFont.s13, weight: AppFont.semibold),
                  ),
                ),
              ],
            ),
          ),
          if (locked)
            PositionedDirectional(
              top: -6,
              end: -6,
              child: Container(
                width: AppSizes.miniCheck,
                height: AppSizes.miniCheck,
                decoration: const BoxDecoration(color: AppColors.warn, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: const AppIcon(AppIcons.lock, size: 10, color: AppColors.white),
              ),
            ),
        ],
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
    final l = L.of(context);
    return ListSectionCard(
      leading: IconTile(
        icon: location.icon,
        size: AppSizes.iconTileSm,
        background: location.soft,
        foreground: location.ink,
      ),
      title: location.label(l),
      count: l.pantryHomeProductCount(items.length),
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
                child: Text(it.$5, textAlign: TextAlign.end, style: AppText.meta),
              ),
            ],
          ),
      ],
    );
  }
}
