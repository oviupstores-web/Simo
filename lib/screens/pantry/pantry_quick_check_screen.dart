import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../onboarding/onboarding_data.dart';
import '../../models/pantry_values.dart';
import '../../onboarding/onboarding_scope.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

enum _Stock { none, present, some }

/// onboarding_pantrycheck — « vérification rapide » du détour Réserve (SPEC §3-4 : hors compteur).
/// Un appui fait passer une catégorie de « Non » à « Présent », puis « Quelques restes ».
class PantryQuickCheckScreen extends StatefulWidget {
  const PantryQuickCheckScreen({super.key});

  static List<(String, String, PantryLocation, String)> categories(L l) => [
    for (final c in QuickCategory.values) (c.label(l), c.icon, c.location, c.photo),
  ];

  @override
  State<PantryQuickCheckScreen> createState() => _PantryQuickCheckScreenState();
}

class _PantryQuickCheckScreenState extends State<PantryQuickCheckScreen> {
  final _state = <QuickCategory, _Stock>{};
  String? _error;
  bool _restored = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_restored) return;
    _restored = true;
    final d = OnboardingScope.read(context);
    final saved = d.isFoyer
        ? OnboardingScope.family(context)?.pantryForms.quick
        : OnboardingScope.solo(context)?.pantryForms.quick;
    if (saved != null) {
      for (final entry in saved.entries) {
        _state[QuickCategory.values.byName(entry.key)] = _Stock.values.byName(entry.value as String);
      }
    }
  }

  void _persist() {
    final saved = {for (final entry in _state.entries) entry.key.name: entry.value.name};
    if (OnboardingScope.read(context).isFoyer) {
      OnboardingScope.family(context)?.setQuickForm(saved);
    } else {
      OnboardingScope.solo(context)?.setQuickForm(saved);
    }
  }

  int get _count => _state.values.where((s) => s != _Stock.none).length;
  void _cycle(QuickCategory category) {
    setState(() {
      _error = null;
      _state[category] = switch (_state[category] ?? _Stock.none) {
        _Stock.none => _Stock.present,
        _Stock.present => _Stock.some,
        _Stock.some => _Stock.none,
      };
    });
    _persist();
  }

  void _save() {
    final l = L.of(context);
    final d = OnboardingScope.read(context);
    final active = _state.entries.where((e) => e.value != _Stock.none).toList();
    // Vérification complète avant toute mutation : un cas ambigu n'enregistre rien.
    for (final e in active) {
      final location = e.key.location;
      if (d.quickMatches(e.key, location).length > 1) {
        setState(() => _error = l.quickCheckAmbiguousStock(e.key.label(l)));
        return;
      }
    }
    if (d.isFoyer) {
      OnboardingScope.family(context)?.setQuickForm(null, persist: false);
    } else {
      OnboardingScope.solo(context)?.setQuickForm(null, persist: false);
    }
    final applied = d.declareQuickStockBatch({
      for (final e in active) e.key: e.value == _Stock.some ? QuickStock.some : QuickStock.present,
    }, l);
    if (!applied) {
      _persist();
      setState(() => _error = l.quickCheckAmbiguousStock(active.first.key.label(l)));
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return OnboardingStepScaffold(
      eyebrow: l.quickCheckEyebrow,
      eyebrowIcon: AppIcons.list,
      title: l.quickCheckTitle,
      subtitle: l.quickCheckSubtitle,
      continueLabel: _count == 0 ? l.quickCheckSkip : l.quickCheckAddCount(_count),
      showArrow: _count > 0,
      onContinue: _count == 0
          ? () {
              if (OnboardingScope.read(context).isFoyer) {
                OnboardingScope.family(context)?.setQuickForm(null);
              } else {
                OnboardingScope.solo(context)?.setQuickForm(null);
              }
              Navigator.of(context).pop();
            }
          : _save,
      children: [
        ClipRRect(
          borderRadius: AppRadius.cardR,
          child: Image.asset(
            'assets/images/placard_bocaux.jpg',
            height: AppSizes.photoTileH,
            fit: BoxFit.cover,
            excludeFromSemantics: true,
          ),
        ),
        const SizedBox(height: AppSpace.x4),
        for (final (i, c) in QuickCategory.values.indexed) ...[
          if (i > 0) const SizedBox(height: AppSpace.x2),
          _CategoryRow(
            label: c.label(l),
            icon: c.icon,
            location: c.location,
            photo: c.photo,
            stock: _state[c] ?? _Stock.none,
            onTap: () => _cycle(c),
          ),
        ],
        FormError(message: _error),
        const SizedBox(height: AppSpace.x4),
        InfoBanner(icon: AppIcons.bulb, text: l.quickCheckInfoText),
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.label,
    required this.icon,
    required this.location,
    required this.photo,
    required this.stock,
    required this.onTap,
  });

  final PantryLocation location;
  final String photo;

  final String label;
  final String icon;
  final _Stock stock;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final on = stock != _Stock.none;
    final (tag, tagBg, tagFg) = switch (stock) {
      _Stock.present => (l.quickCheckPresent, AppColors.mint, AppColors.primary),
      _Stock.some => (l.quickCheckSome, AppColors.orangeSoft, AppColors.warn),
      _Stock.none => (l.quickCheckNone, AppColors.neutralSoft, AppColors.ink3),
    };
    return Semantics(
      button: true,
      label: l.quickCheckLabelStatus(label, tag),
      child: Pressable(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppMotion.normal,
          curve: AppMotion.curve,
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.x3_5, vertical: AppSpace.x3),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: AppRadius.cardR,
            border: Border.all(color: on ? AppColors.primary : AppColors.line, width: on ? 1.5 : 1),
            boxShadow: AppShadows.card,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 300;
              final status = AnimatedSwitcher(
                duration: AppMotion.fast,
                child: PillBadge(tag, key: ValueKey(stock), background: tagBg, foreground: tagFg, size: AppFont.s12),
              );
              return Row(
                children: [
                  FoodThumb(
                    photo: 'assets/images/$photo.jpg',
                    icon: icon,
                    tint: location.tint,
                    size: AppSizes.iconTileMd,
                  ),
                  const SizedBox(width: AppSpace.x3),
                  Expanded(
                    child: compact
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(label, style: AppText.of(AppFont.s14, weight: AppFont.semibold, lineHeight: 20)),
                              const SizedBox(height: AppSpace.x1),
                              status,
                            ],
                          )
                        : Text(label, style: AppText.of(AppFont.s14, weight: AppFont.semibold, lineHeight: 20)),
                  ),
                  if (!compact) status,
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
