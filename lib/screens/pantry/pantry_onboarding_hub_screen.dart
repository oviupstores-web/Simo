import 'package:flutter/material.dart';

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
class PantryOnboardingHubScreen extends StatefulWidget {
  const PantryOnboardingHubScreen({super.key, required this.onFinish});

  /// « Terminer et continuer » ou « Passer pour l'instant ».
  final void Function(BuildContext context) onFinish;

  @override
  State<PantryOnboardingHubScreen> createState() => _PantryOnboardingHubScreenState();
}

class _PantryOnboardingHubScreenState extends State<PantryOnboardingHubScreen> {
  PantryLocation? _filter;

  @override
  Widget build(BuildContext context) {
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
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: EyebrowTag(label: 'FACULTATIF', icon: AppIcons.fridge),
                    ),
                    const SizedBox(height: AppSpace.x3),
                    Text('Remplissez votre réserve', style: AppText.h1),
                    const SizedBox(height: AppSpace.x2),
                    Text(
                      'Ajoutez ce que vous avez déjà : Menoo en tiendra compte pour vos menus et vos courses. Vous pourrez compléter plus tard.',
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
                                  'Ma réserve',
                                  style: AppText.of(AppFont.s16, weight: AppFont.extrabold, lineHeight: 24),
                                ),
                                Text(
                                  items.isEmpty
                                      ? 'Vide pour l\'instant'
                                      : '${items.length} produit${items.length > 1 ? 's' : ''} · ${items.map((i) => i.location).toSet().length} emplacement${items.map((i) => i.location).toSet().length > 1 ? 's' : ''}',
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
                                  ? ' et ${urgent.length - 1} autre${urgent.length > 2 ? 's' : ''} à consommer d\'ici 2 jours'
                                  : ' à consommer d\'ici 2 jours · ${urgent.first.location.label}',
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
                                  'Vérification rapide',
                                  style: AppText.of(AppFont.s15, weight: AppFont.extrabold, lineHeight: 21),
                                ),
                                Text(
                                  'Cochez en quelques secondes ce que vos placards contiennent',
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
                            label: 'Manuel',
                            onTap: () => push(context, const PantryAddManualScreen()),
                          ),
                        ),
                        const SizedBox(width: AppSpace.x2),
                        Expanded(
                          child: _QuickAction(
                            icon: AppIcons.barcode,
                            label: 'Code-barres',
                            onTap: () => push(context, const PantryScanScreen()),
                          ),
                        ),
                        const SizedBox(width: AppSpace.x2),
                        Expanded(
                          child: _QuickAction(
                            icon: AppIcons.camera,
                            label: 'Photo IA',
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
                        label: 'Tous · ${items.length}',
                        selected: _filter == null,
                        onTap: () => setState(() => _filter = null),
                      ),
                      for (final loc in PantryLocation.values) ...[
                        const SizedBox(width: AppSpace.x2),
                        FilterPill(
                          label: '${loc.short} · ${items.where((i) => i.location == loc).length}',
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
                    PrimaryButton(label: 'Terminer et continuer', onPressed: () => widget.onFinish(context)),
                    const SizedBox(height: AppSpace.x3),
                    Center(
                      child: TextLink(
                        'Passer pour l\'instant',
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
    return AppCard(
      padding: const EdgeInsets.all(AppSpace.x5),
      child: Column(
        children: [
          const IconTile(icon: AppIcons.fridge, size: AppSizes.lockCircle, iconSize: 22, circle: true),
          const SizedBox(height: AppSpace.x3),
          Text('Votre réserve est vide', style: AppText.of(AppFont.s16, weight: AppFont.extrabold)),
          const SizedBox(height: AppSpace.x1),
          Text(
            'Commencez par la vérification rapide ou ajoutez un aliment : ils apparaîtront ici, rangés par emplacement.',
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

  static String _left(PantryDraft i) {
    final days = i.daysLeft;
    if (days == null) return '';
    if (days < 0) return 'Périmé';
    if (days > 60) return '${(days / 30).round()} mois';
    return '$days j';
  }

  @override
  Widget build(BuildContext context) {
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
                Expanded(child: Text(location.label, style: AppText.sectionTitle)),
                Text('${items.length} produit${items.length > 1 ? 's' : ''}', style: AppText.meta),
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
                      child: Text(_left(it), textAlign: TextAlign.right, style: AppText.meta),
                    ),
                  ],
                  Semantics(
                    button: true,
                    label: 'Retirer ${it.name}',
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
