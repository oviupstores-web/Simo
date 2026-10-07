import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../l10n/formats.dart';
import '../../models/food_images.dart';
import '../../navigation.dart';
import '../../onboarding/onboarding_data.dart';
import '../../onboarding/onboarding_scope.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import 'pantry_add_manual_screen.dart';
import 'pantry_quick_check_screen.dart';
import 'pantry_scan_screens.dart';

String _premiumLocationIcon(PantryLocation location) => switch (location) {
  PantryLocation.fridge => AppIcons.pantryFridge,
  PantryLocation.fruitBasket => AppIcons.pantryFruitBasket,
  PantryLocation.pantry => AppIcons.pantryCupboard,
  PantryLocation.freezer => AppIcons.pantryFreezer,
};

/// pantry_home_onboarding (nouvel écran design/new) — détour Réserve de l'onboarding (SPEC §4) :
/// pas de compteur d'étape, pas de barre de navigation. Chaque ajout revient ici.
/// Produits regroupés par emplacement (SPEC §7, maître opérationnel).
class PantryHubOnboardingScreen extends StatefulWidget {
  const PantryHubOnboardingScreen({super.key, required this.onFinish});

  /// « Terminer et continuer » ou « Passer pour l'instant ».
  final void Function(BuildContext context) onFinish;

  @override
  State<PantryHubOnboardingScreen> createState() => _PantryHubOnboardingScreenState();
}

class _PantryHubOnboardingScreenState extends State<PantryHubOnboardingScreen> {
  PantryLocation? _filter;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final d = OnboardingScope.of(context);
    final items = d.pantry;
    final urgent = items.where((i) => (i.daysLeft ?? 99) <= 2).toList();
    final shown = _filter == null ? PantryLocation.values : [_filter!];
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: AppSpace.x8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const MenooHeader(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpace.gutter),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpace.x5),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: EyebrowTag(label: l.pantryHubOptional, icon: AppIcons.pantryReserve),
                    ),
                    const SizedBox(height: AppSpace.x3),
                    Text(l.pantryHubTitle, style: AppText.h1),
                    const SizedBox(height: AppSpace.x2),
                    Text(l.pantryHubSubtitle, style: AppText.of(AppFont.s14_5, color: AppColors.ink2, lineHeight: 21)),
                    const SizedBox(height: AppSpace.x4),
                    AppCard(
                      child: Row(
                        children: [
                          const IconTile(icon: AppIcons.pantryReserve, size: AppSizes.iconTileMd, iconSize: 26),
                          const SizedBox(width: AppSpace.x3),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l.pantryHubCardTitle,
                                  style: AppText.of(AppFont.s16, weight: AppFont.extrabold, lineHeight: 24),
                                ),
                                Text(
                                  items.isEmpty
                                      ? l.pantryHubEmptyForNow
                                      : l.pantryHubSummary(items.length, items.map((i) => i.location).toSet().length),
                                  style: AppText.caption,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (urgent.isNotEmpty) ...[
                      const SizedBox(height: AppSpace.x3),
                      AlertBanner(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: urgent.first.name,
                              style: AppText.of(AppFont.s12_5, weight: AppFont.bold, color: AppColors.alertInk),
                            ),
                            TextSpan(
                              text: urgent.length > 1
                                  ? ' ${l.pantryHubUrgentOthers(urgent.length - 1)}'
                                  : ' ${l.pantryHomeUrgent(urgent.first.location.label(l))}',
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpace.x3),
                    AppCard(
                      onTap: () => push(context, const PantryQuickCheckScreen()),
                      padding: const EdgeInsets.all(AppSpace.x3_5),
                      child: Row(
                        children: [
                          const IconTile(
                            icon: AppIcons.pantryQuickCheck,
                            background: AppColors.orangeSoft,
                            foreground: AppColors.warn,
                          ),
                          const SizedBox(width: AppSpace.x3),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l.pantryHubQuickCheckTitle,
                                  style: AppText.of(AppFont.s15, weight: AppFont.extrabold, lineHeight: 21),
                                ),
                                Text(l.pantryHubQuickCheckText, style: AppText.caption),
                              ],
                            ),
                          ),
                          const CardChevron(),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpace.x3),
                    _QuickActions(
                      manualLabel: l.pantryQuickManual,
                      barcodeLabel: l.pantryQuickBarcode,
                      photoLabel: l.pantryQuickPhotoAi,
                      onManual: () => push(context, const PantryAddManualScreen()),
                      onBarcode: () => push(context, const PantryScanScreen()),
                      onPhoto: () => push(context, const PantryPhotoAiScreen()),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpace.x4),
              if (items.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpace.gutter),
                  child: _EmptyPantry(),
                )
              else ...[
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpace.gutter),
                  child: Row(
                    children: [
                      FilterPill(
                        label: l.pantryHubAll(items.length),
                        selected: _filter == null,
                        onTap: () => setState(() => _filter = null),
                      ),
                      for (final loc in PantryLocation.values) ...[
                        const SizedBox(width: AppSpace.x2),
                        FilterPill(
                          label: '${loc.short(l)} · ${items.where((i) => i.location == loc).length}',
                          icon: _premiumLocationIcon(loc),
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
                        for (final loc in shown)
                          if (items.any((i) => i.location == loc)) ...[
                            const SizedBox(height: AppSpace.x3),
                            _LocationSection(
                              location: loc,
                              items: items.where((i) => i.location == loc).toList(),
                              onRemove: (item) => d.update(() => d.pantry.remove(item)),
                            ),
                          ],
                      ],
                    ),
                  ),
                ),
              ],
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpace.gutter, AppSpace.x6, AppSpace.gutter, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PrimaryButton(label: l.pantryHubFinish, onPressed: () => widget.onFinish(context)),
                    const SizedBox(height: AppSpace.x3),
                    Center(
                      child: TextLink(l.pantryHubSkip, weight: AppFont.bold, onTap: () => widget.onFinish(context)),
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

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.manualLabel,
    required this.barcodeLabel,
    required this.photoLabel,
    required this.onManual,
    required this.onBarcode,
    required this.onPhoto,
  });

  final String manualLabel;
  final String barcodeLabel;
  final String photoLabel;
  final VoidCallback onManual;
  final VoidCallback onBarcode;
  final VoidCallback onPhoto;

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction(icon: AppIcons.pantryManualAdd, label: manualLabel, onTap: onManual),
      _QuickAction(icon: AppIcons.pantryBarcodeScan, label: barcodeLabel, onTap: onBarcode),
      _QuickAction(icon: AppIcons.pantryPhotoScan, label: photoLabel, locked: true, onTap: onPhoto),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const gaps = AppSpace.x2 * 2;
        final cellWidth = (constraints.maxWidth - gaps) / 3;
        final direction = Directionality.of(context);
        final style = AppText.of(AppFont.s13, weight: AppFont.semibold);
        final fitsInOneRow = [manualLabel, barcodeLabel, photoLabel].every((label) {
          final painter = TextPainter(
            text: TextSpan(text: label, style: style),
            textDirection: direction,
            maxLines: 1,
          )..layout();
          return painter.width + _QuickAction.iconSize + AppSpace.x1_5 + AppSpace.x3 <= cellWidth;
        });

        if (!fitsInOneRow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (index, action) in actions.indexed) ...[
                if (index > 0) const SizedBox(height: AppSpace.x2),
                action,
              ],
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: actions[0]),
            const SizedBox(width: AppSpace.x2),
            Expanded(child: actions[1]),
            const SizedBox(width: AppSpace.x2),
            Expanded(child: actions[2]),
          ],
        );
      },
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, required this.onTap, this.locked = false});

  static const double iconSize = 23;

  final String icon;
  final String label;
  final VoidCallback onTap;

  /// Fonction Premium (Photo IA, SPEC §0.8) : cadenas en haut à droite du bouton.
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
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
                AppIcon(icon, size: iconSize),
                const SizedBox(width: AppSpace.x1_5),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
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

class _EmptyPantry extends StatelessWidget {
  const _EmptyPantry();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpace.x5),
      child: Column(
        children: [
          const IconTile(icon: AppIcons.pantryReserve, size: AppSizes.lockCircle, iconSize: 22, circle: true),
          const SizedBox(height: AppSpace.x3),
          Text(L.of(context).pantryHubEmptyTitle, style: AppText.of(AppFont.s16, weight: AppFont.extrabold)),
          const SizedBox(height: AppSpace.x1),
          Text(
            L.of(context).pantryHubEmptyText,
            textAlign: TextAlign.center,
            style: AppText.of(AppFont.s13, color: AppColors.ink2, lineHeight: 19),
          ),
        ],
      ),
    );
  }
}

class _LocationSection extends StatelessWidget {
  const _LocationSection({required this.location, required this.items, required this.onRemove});

  final PantryLocation location;
  final List<PantryDraft> items;
  final ValueChanged<PantryDraft> onRemove;

  static String _qty(BuildContext context, PantryDraft i) {
    final q = Formats.of(context).number(i.quantity, decimals: 2);
    final unit = i.unitLabel.contains('(s)') ? i.unitLabel.replaceAll('(s)', i.quantity > 1 ? 's' : '') : i.unitLabel;
    return unit.isEmpty ? q : '$q $unit';
  }

  static String _left(L l, PantryDraft i) {
    final days = i.daysLeft;
    if (days == null) return '';
    if (days < 0) return l.pantryExpired;
    if (days > 60) return l.pantryMonthsLeft((days / 30).round());
    return l.pantryDaysLeft(days);
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return AppCard(
      padding: const EdgeInsets.fromLTRB(AppSpace.x4, AppSpace.x3, AppSpace.x2, AppSpace.x1),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpace.x2),
            child: Row(
              children: [
                IconTile(
                  icon: _premiumLocationIcon(location),
                  size: AppSizes.iconTileSm,
                  background: location.soft,
                  foreground: location.ink,
                ),
                const SizedBox(width: AppSpace.x2_5),
                Expanded(child: Text(location.label(l), style: AppText.sectionTitle)),
                Text(L.of(context).pantryHomeProductCount(items.length), style: AppText.meta),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.x1),
          for (final (idx, it) in items.indexed) ...[
            if (idx > 0) const Divider(height: 1, thickness: 1, color: AppColors.line),
            _PantryItemRow(
              item: it,
              location: location,
              quantity: _qty(context, it),
              timeLeft: _left(l, it),
              onRemove: () => onRemove(it),
            ),
          ],
        ],
      ),
    );
  }
}

class _PantryItemRow extends StatelessWidget {
  const _PantryItemRow({
    required this.item,
    required this.location,
    required this.quantity,
    required this.timeLeft,
    required this.onRemove,
  });

  final PantryDraft item;
  final PantryLocation location;
  final String quantity;
  final String timeLeft;
  final VoidCallback onRemove;

  Widget _product() => Row(
    children: [
      FoodThumb(
        photo: FoodImages.forName(item.name),
        icon: _premiumLocationIcon(location),
        tint: location.tint,
        size: AppSizes.iconTileSm,
      ),
      const SizedBox(width: AppSpace.x3),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.name, style: AppText.rowTitle),
            Text(quantity, style: AppText.meta),
          ],
        ),
      ),
    ],
  );

  Widget _removeButton(BuildContext context) => Semantics(
    button: true,
    label: L.of(context).pantryRemoveItem(item.name),
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onRemove,
      child: const Padding(
        padding: EdgeInsets.all(AppSpace.x2),
        child: AppIcon(AppIcons.close, size: 16, color: AppColors.ink3),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpace.x2),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 300) {
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _product()),
                    _removeButton(context),
                  ],
                ),
                if (item.daysLeft != null)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: AppSizes.iconTileSm + AppSpace.x3,
                      end: AppSpace.x2,
                      top: AppSpace.x1,
                    ),
                    child: Row(
                      children: [
                        FreshnessStatus(urgent: item.daysLeft! <= 2),
                        const Spacer(),
                        Text(timeLeft, textAlign: TextAlign.end, style: AppText.meta),
                      ],
                    ),
                  ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: _product()),
              if (item.daysLeft != null) ...[
                FreshnessStatus(urgent: item.daysLeft! <= 2),
                const SizedBox(width: AppSpace.x2),
                SizedBox(
                  width: AppSizes.thumbW,
                  child: Text(timeLeft, textAlign: TextAlign.end, style: AppText.meta),
                ),
              ],
              _removeButton(context),
            ],
          );
        },
      ),
    );
  }
}
