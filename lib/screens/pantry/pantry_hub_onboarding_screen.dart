import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../l10n/app_localizations.dart';
import '../../models/food_images.dart';
import '../../navigation.dart';
import '../../onboarding/onboarding_data.dart';
import '../../onboarding/onboarding_scope.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import 'pantry_add_manual_screen.dart';
import 'pantry_quick_check_screen.dart';
import 'pantry_scan_screens.dart';

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
                      child: EyebrowTag(label: l.pantryHubOptional, icon: AppIcons.fridge),
                    ),
                    const SizedBox(height: AppSpace.x3),
                    Text(l.pantryHubTitle, style: AppText.h1),
                    const SizedBox(height: AppSpace.x2),
                    Text(
                      l.pantryHubSubtitle,
                      style: AppText.of(AppFont.s14_5, color: AppColors.ink2, lineHeight: 21),
                    ),
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
                                  ? ' ' + l.pantryHubUrgentOthers(urgent.length - 1)
                                  : ' ' + l.pantryHomeUrgent(urgent.first.location.label(l)),
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
                            icon: AppIcons.list,
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
                                Text(
                                  l.pantryHubQuickCheckText,
                                  style: AppText.caption,
                                ),
                              ],
                            ),
                          ),
                          const CardChevron(),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpace.x3),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickAction(
                            icon: AppIcons.plus,
                            label: l.pantryQuickManual,
                            onTap: () => push(context, const PantryAddManualScreen()),
                          ),
                        ),
                        const SizedBox(width: AppSpace.x2),
                        Expanded(
                          child: _QuickAction(
                            icon: AppIcons.barcode,
                            label: l.pantryQuickBarcode,
                            onTap: () => push(context, const PantryScanScreen()),
                          ),
                        ),
                        const SizedBox(width: AppSpace.x2),
                        Expanded(
                          child: _QuickAction(
                            icon: AppIcons.camera,
                            label: l.pantryQuickPhotoAi,
                            onTap: () => push(context, const PantryPhotoAiScreen()),
                          ),
                        ),
                      ],
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
                      child: TextLink(
                        l.pantryHubSkip,
                        weight: AppFont.bold,
                        onTap: () => widget.onFinish(context),
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

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, required this.onTap});

  final String icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Pressable(
      onTap: onTap,
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

class _EmptyPantry extends StatelessWidget {
  const _EmptyPantry();

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return AppCard(
      padding: const EdgeInsets.all(AppSpace.x5),
      child: Column(
        children: [
          const IconTile(icon: AppIcons.fridge, size: AppSizes.lockCircle, iconSize: 22, circle: true),
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

  static String _qty(PantryDraft i) {
    final q = i.quantity == i.quantity.roundToDouble() ? '${i.quantity.round()}' : '${i.quantity}'.replaceAll('.', ',');
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
                  icon: location.icon,
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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpace.x2),
              child: Row(
                children: [
                  FoodThumb(
                    photo: FoodImages.forName(it.name),
                    icon: location.icon,
                    tint: location.tint,
                    size: AppSizes.iconTileSm,
                  ),
                  const SizedBox(width: AppSpace.x3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(it.name, style: AppText.rowTitle),
                        Text(_qty(it), style: AppText.meta),
                      ],
                    ),
                  ),
                  if (it.daysLeft != null) ...[
                    FreshnessStatus(urgent: it.daysLeft! <= 2),
                    const SizedBox(width: AppSpace.x2),
                    SizedBox(
                      width: AppSizes.thumbW,
                      child: Text(_left(L.of(context), it), textAlign: TextAlign.end, style: AppText.meta),
                    ),
                  ],
                  Semantics(
                    button: true,
                    label: L.of(context).pantryRemoveItem(it.name),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onRemove(it),
                      child: const Padding(
                        padding: EdgeInsets.all(AppSpace.x2),
                        child: AppIcon(AppIcons.close, size: 16, color: AppColors.ink3),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
