import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../onboarding/onboarding_data.dart';
import '../../onboarding/onboarding_scope.dart';
import '../../onboarding/onboarding_flow.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

/// onboarding_supermarket (Solo, étape 11/12 — nouvel écran design/new/onboarding_supermarket).
/// SPEC §0.4 : « jusqu'à 45 min », « 35 € de réduction » et les rayons « synchronisés » retirés.
class SupermarketScreen extends StatefulWidget {
  const SupermarketScreen({super.key});

  static List<(ShoppingChannel, String, String, Tint)> channels(L l) => [
    (ShoppingChannel.drive, l.channelDrive, AppIcons.car, Tint.sky),
    (ShoppingChannel.magasin, l.channelInStore, AppIcons.bag, Tint.peach),
    (ShoppingChannel.livraison, l.channelDelivery, AppIcons.truck, Tint.lavender),
  ];

  /// Enseignes : monogramme neutre sur pastille (jamais de logo officiel sans accord).
  /// Modes de retrait généralement proposés par l'enseigne (indicatif ; la distance viendra avec
  /// la géolocalisation des magasins).
  static const stores = [
    ('E.Leclerc', Tint.sky, {ShoppingChannel.drive, ShoppingChannel.magasin}),
    ('Carrefour', Tint.mint, {ShoppingChannel.drive, ShoppingChannel.magasin, ShoppingChannel.livraison}),
    ('Intermarché', Tint.peach, {ShoppingChannel.drive, ShoppingChannel.magasin}),
    ('Auchan', Tint.leafy, {ShoppingChannel.drive, ShoppingChannel.magasin, ShoppingChannel.livraison}),
    ('Super U', Tint.lavender, {ShoppingChannel.drive, ShoppingChannel.magasin}),
    ('Lidl', Tint.sand, {ShoppingChannel.magasin}),
    ('Monoprix', Tint.sky, {ShoppingChannel.magasin, ShoppingChannel.livraison}),
    ('Biocoop', Tint.leafy, {ShoppingChannel.magasin}),
  ];

  @override
  State<SupermarketScreen> createState() => _SupermarketScreenState();
}

class _SupermarketScreenState extends State<SupermarketScreen> {
  final _place = TextEditingController();
  bool _init = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_init) return;
    _init = true;
    _place.text = OnboardingScope.read(context).postalCode;
  }

  @override
  void dispose() {
    _place.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final d = OnboardingScope.of(context);
    return OnboardingStepScaffold(
      step: OnboardingFlow.number(context, OnbStep.supermarket),
      totalSteps: OnboardingFlow.total(context),
      eyebrow: l.supermarketEyebrow,
      eyebrowIcon: AppIcons.store,
      title: l.supermarketTitle,
      subtitle: l.supermarketSubtitle,
      onContinue: () {
        d.update(() => d.postalCode = _place.text.trim());
        OnboardingFlow.next(context, OnbStep.supermarket);
      },
      children: [
        Text(l.supermarketPostcodeLabel, style: AppText.of(AppFont.s15, weight: AppFont.semibold, lineHeight: 22)),
        const SizedBox(height: AppSpace.x2_5),
        IconTextField(icon: AppIcons.mapPin, hint: l.supermarketPostcodeHint, controller: _place),
        const SizedBox(height: AppSpace.x6),
        StepSectionTitle(l.supermarketChannelSection, icon: AppIcons.car, tint: Tint.sky),
        Row(
          children: [
            for (final (i, c) in SupermarketScreen.channels(l).indexed) ...[
              if (i > 0) const SizedBox(width: AppSpace.x2),
              Expanded(
                child: OptionTile(
                  vertical: true,
                  label: c.$2,
                  icon: c.$3,
                  tint: c.$4,
                  selected: d.channel == c.$1,
                  onTap: () => d.update(() => d.channel = c.$1),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpace.x6),
        StepSectionTitle(l.supermarketStoreSection, hint: l.commonOptional, icon: AppIcons.store, tint: Tint.sand),
        for (final (i, s) in SupermarketScreen.stores.indexed) ...[
          if (i > 0) const SizedBox(height: AppSpace.x2),
          _StoreRow(
            name: s.$1,
            tint: s.$2,
            channels: s.$3,
            preferred: d.channel,
            selected: d.store == s.$1,
            onTap: () => d.update(() => d.store = d.store == s.$1 ? null : s.$1),
          ),
        ],
        const SizedBox(height: AppSpace.x4),
        InfoBanner(
          icon: AppIcons.info,
          text: l.supermarketPricesInfo,
          background: AppColors.neutralSoft,
        ),
      ],
    );
  }
}

class _StoreRow extends StatelessWidget {
  const _StoreRow({
    required this.name,
    required this.tint,
    required this.channels,
    required this.preferred,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final Tint tint;
  final Set<ShoppingChannel> channels;
  final ShoppingChannel preferred;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Semantics(
      selected: selected,
      button: true,
      child: Pressable(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppMotion.normal,
          curve: AppMotion.curve,
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.x3_5, vertical: AppSpace.x3),
          decoration: BoxDecoration(
            color: selected ? AppColors.mintTint : AppColors.card,
            borderRadius: AppRadius.cardR,
            border: Border.all(color: selected ? AppColors.primary : AppColors.line, width: selected ? 1.5 : 1),
            boxShadow: AppShadows.card,
          ),
          child: Row(
            children: [
              StoreMonogram(name: name, tint: tint),
              const SizedBox(width: AppSpace.x3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppText.of(AppFont.s15, weight: AppFont.bold, lineHeight: 21)),
                    const SizedBox(height: AppSpace.x1),
                    Wrap(
                      spacing: AppSpace.x1_5,
                      runSpacing: AppSpace.x1,
                      children: [
                        for (final c in SupermarketScreen.channels(L.of(context)))
                          if (channels.contains(c.$1))
                            PillBadge(
                              c.$2,
                              icon: c.$3,
                              size: AppFont.s11,
                              background: c.$1 == preferred ? AppColors.mint : AppColors.neutralSoft,
                              foreground: c.$1 == preferred ? AppColors.primary : AppColors.ink2,
                              padding: const EdgeInsets.symmetric(horizontal: AppSpace.x2, vertical: AppSpace.x0_5),
                            ),
                      ],
                    ),
                  ],
                ),
              ),
              SelectionIndicator(selected: selected, roundWhenOff: true),
            ],
          ),
        ),
      ),
    );
  }
}

/// Monogramme stylisé d'une enseigne (initiales sur pastille pastel) : neutre, sans logo ni
/// couleurs de marque.
class StoreMonogram extends StatelessWidget {
  const StoreMonogram({super.key, required this.name, required this.tint});

  final String name;
  final Tint tint;

  static String initials(String name) {
    final words = name.replaceAll('.', ' ').split(' ').where((w) => w.isNotEmpty).toList();
    if (words.length > 1) return (words[0][0] + words[1][0]).toUpperCase();
    return words.first.substring(0, 2).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Container(
      width: AppSizes.iconTile,
      height: AppSizes.iconTile,
      decoration: BoxDecoration(color: tint.soft, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        initials(name),
        style: AppText.of(AppFont.s14, weight: AppFont.extrabold, color: tint.ink).copyWith(letterSpacing: 0.3),
      ),
    );
  }
}
