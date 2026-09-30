import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../l10n/formats.dart';
import '../../models/food_images.dart';
import '../../onboarding/onboarding_data.dart';
import '../../onboarding/onboarding_scope.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

/// Catégorie de produit : emplacement et durée de conservation proposés par défaut.
enum FoodCategory {
  fruits(AppIcons.basket, PantryLocation.fruitBasket, 7, 'fruits'),
  legumes(AppIcons.leaf, PantryLocation.fridge, 5, 'legumes'),
  laitiers(AppIcons.egg, PantryLocation.fridge, 10, 'laitiers_oeufs'),
  viandes(AppIcons.fish, PantryLocation.fridge, 3, 'viandes_poissons'),
  epicerie(AppIcons.cupboard, PantryLocation.pantry, 180, 'epicerie_salee'),
  sucre(AppIcons.sparkles, PantryLocation.pantry, 180, 'epicerie_sucree'),
  surgeles(AppIcons.snowflake, PantryLocation.freezer, 90, 'surgeles');

  const FoodCategory(this.icon, this.location, this.shelfDays, this.photo);

  final String icon;
  final PantryLocation location;
  final int shelfDays;

  /// Vignette photo (assets/images/categories/).
  final String photo;

  String label(L l) => switch (this) {
    FoodCategory.fruits => l.categoryFruits,
    FoodCategory.legumes => l.categoryVegetables,
    FoodCategory.laitiers => l.categoryDairy,
    FoodCategory.viandes => l.categoryMeatFish,
    FoodCategory.epicerie => l.categorySavoryGrocery,
    FoodCategory.sucre => l.categorySweetGrocery,
    FoodCategory.surgeles => l.categoryFrozen,
  };

  /// Mots-clés sans accents (le nom saisi est ramené à la même forme par [FoodImages.fold]).
  static const _keywords = {
    FoodCategory.surgeles: ['surgel', 'glace'],
    FoodCategory.fruits: [
      'avocat',
      'banane',
      'pomme',
      'poire',
      'citron',
      'fraise',
      'orange',
      'kiwi',
      'raisin',
      'mangue',
      'clementine',
      'myrtille',
      'framboise',
    ],
    FoodCategory.legumes: [
      'salade',
      'epinard',
      'carotte',
      'courgette',
      'tomate',
      'brocoli',
      'poivron',
      'oignon',
      'poireau',
      'champignon',
      'concombre',
      'chou',
    ],
    // Avant les laitiers : « boeuf » contient « oeuf ».
    FoodCategory.viandes: [
      'poulet',
      'boeuf',
      'saumon',
      'poisson',
      'jambon',
      'steak',
      'dinde',
      'porc',
      'cabillaud',
      'thon',
      'crevette',
      'viande',
    ],
    FoodCategory.laitiers: [
      'yaourt',
      'lait',
      'fromage',
      'beurre',
      'creme',
      'oeuf',
      'feta',
      'chevre',
      'parmesan',
      'emmental',
    ],
    FoodCategory.sucre: ['chocolat', 'biscuit', 'sucre', 'miel', 'confiture', 'cereale', 'gateau'],
    FoodCategory.epicerie: [
      'pate',
      'riz',
      'quinoa',
      'lentille',
      'conserve',
      'huile',
      'farine',
      'semoule',
      'haricot',
      'pois chiche',
      'sauce',
      'vinaigre',
      'ketchup',
      'mayonnaise',
      'moutarde',
      'sel',
      'poivre',
      'epice',
      'herbe',
      'bouillon',
    ],
  };

  /// Détection d'après le nom saisi (null si aucune correspondance).
  static FoodCategory? detect(String name) {
    final n = FoodImages.fold(name);
    for (final e in _keywords.entries) {
      if (e.value.any(n.contains)) return e.key;
    }
    return null;
  }
}

/// pantry_addmanual — ajout manuel à la réserve. SPEC §7 : l'emplacement est obligatoire,
/// pré-rempli selon la catégorie (yaourt → Réfrigérateur, pâtes → Placard, surgelé → Congélateur,
/// fruits → Corbeille) et modifiable.
class PantryAddManualScreen extends StatefulWidget {
  const PantryAddManualScreen({super.key});

  @override
  State<PantryAddManualScreen> createState() => _PantryAddManualScreenState();
}

class _PantryAddManualScreenState extends State<PantryAddManualScreen> {
  static List<String> _units(L l) => [l.unitPieces2, 'g', 'kg', 'ml', 'L', l.unitPacks2];
  static List<(String, String)> _suggestions(L l) => [
    (l.pantrySuggestAvocado, l.unitPieces2),
    (l.pantrySuggestFreshSalmon, 'g'),
    (l.pantrySuggestEggs, l.unitPieces2),
    (l.pantrySuggestPasta, 'g'),
    (l.pantrySuggestPlainYogurt, l.unitPieces2),
    (l.pantrySuggestMilk, 'L'),
  ];

  final _name = TextEditingController();
  double _quantity = 1;
  /// null tant que non choisi : la valeur par défaut dépend de la langue, donc calculée au premier build.
  String? _unit;
  FoodCategory? _category;
  bool _categoryManual = false;
  PantryLocation? _location;
  bool _locationManual = false;
  DateTime? _expires;
  bool _expiresManual = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  DateTime get _today => DateUtils.dateOnly(DateTime.now());

  void _setCategory(FoodCategory? c, {bool manual = false}) {
    setState(() {
      _category = c;
      if (manual) _categoryManual = true;
      if (c != null && !_locationManual) _location = c.location;
      if (c != null && !_expiresManual) _expires = _today.add(Duration(days: c.shelfDays));
    });
  }

  void _onName(String value) {
    if (!_categoryManual) _setCategory(FoodCategory.detect(value));
    if (_error != null && value.trim().isNotEmpty) setState(() => _error = null);
  }

  void _step(int dir) => setState(() {
    final big = _unit == 'g' || _unit == 'ml';
    final delta = big ? (_quantity >= 100 || (dir > 0 && _quantity >= 50) ? 50.0 : 10.0) : 1.0;
    _quantity = (_quantity + dir * delta).clamp(big ? 10 : 1, 100000).toDouble();
  });

  String get _quantityLabel =>
      _quantity == _quantity.roundToDouble() ? '${_quantity.round()}' : '$_quantity'.replaceAll('.', ',');

  String _dateLabel(L l, DateTime d) {
    final days = DateUtils.dateOnly(d).difference(_today).inDays;
    final when = days == 0
        ? l.pantryAddToday
        : days == 1
        ? l.pantryAddTomorrow
        : l.pantryAddInDays(days);
    return '${Formats.of(context).date(d)} · $when';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expires ?? _today.add(const Duration(days: 7)),
      firstDate: _today,
      lastDate: _today.add(const Duration(days: 365 * 3)),
      locale: const Locale('fr', 'FR'),
    );
    if (picked != null) {
      setState(() {
        _expires = picked;
        _expiresManual = true;
      });
    }
  }

  void _add() {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = L.of(context).pantryAddNameError);
      return;
    }
    if (_location == null) {
      setState(() => _error = L.of(context).pantryAddLocationError);
      return;
    }
    final d = OnboardingScope.read(context);
    d.update(
      () => d.pantry.add(
        PantryDraft(
          name: name[0].toUpperCase() + name.substring(1),
          quantity: _quantity,
          unitLabel: _unit ?? L.of(context).unitPieces2,
          location: _location!,
          expiresOn: _expires,
        ),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final unit = _unit ?? l.unitPieces2;
    return OnboardingStepScaffold(
      eyebrow: l.pantryAddEyebrow,
      eyebrowIcon: AppIcons.fridge,
      title: l.pantryAddTitle,
      subtitle: l.pantryAddSubtitle,
      continueLabel: l.pantryAddSubmit,
      showArrow: false,
      onContinue: _add,
      children: [
        StepSectionTitle(l.pantryAddNameSection),
        IconTextField(
          icon: AppIcons.search,
          hint: l.pantryAddNameHint,
          controller: _name,
          onChanged: _onName,
        ),
        const SizedBox(height: AppSpace.x2_5),
        Wrap(
          spacing: AppSpace.x2,
          runSpacing: AppSpace.x2,
          children: [
            for (final s in _suggestions(l))
              ToggleChip(
                label: s.$1,
                leading: FoodThumb(
                  photo: FoodImages.forName(s.$1),
                  icon: FoodCategory.detect(s.$1)?.icon ?? AppIcons.leaf,
                  tint: FoodCategory.detect(s.$1)?.location.tint ?? Tint.mint,
                  size: AppSizes.chipBadge,
                  circle: true,
                ),
                selected: false,
                onTap: () {
                  _name.text = s.$1;
                  setState(() {
                    _unit = s.$2;
                    _quantity = s.$2 == 'g' ? 200 : 1;
                    _categoryManual = false;
                  });
                  _onName(s.$1);
                },
              ),
          ],
        ),
        const SizedBox(height: AppSpace.x6),
        StepSectionTitle(l.pantryAddQuantitySection),
        Row(
          children: [
            QuantityStepper(large: true, value: _quantityLabel, onMinus: () => _step(-1), onPlus: () => _step(1)),
            const SizedBox(width: AppSpace.x3),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final (i, u) in _units(l).indexed) ...[
                      if (i > 0) const SizedBox(width: AppSpace.x1_5),
                      ToggleChip(
                        label: u,
                        selected: unit == u,
                        onTap: () => setState(() {
                          _unit = u;
                          if ((u == 'g' || u == 'ml') && _quantity < 10) _quantity = 100;
                          if (!(u == 'g' || u == 'ml') && _quantity >= 10) _quantity = 1;
                        }),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpace.x6),
        StepSectionTitle(l.pantryAddCategorySection, hint: _category != null && !_categoryManual ? l.pantryAddCategoryAuto : null),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpace.x2,
          crossAxisSpacing: AppSpace.x2,
          childAspectRatio: AppSizes.locationTileRatio,
          children: [
            for (final c in FoodCategory.values)
              OptionTile(
                label: c.label(l),
                leading: FoodThumb(
                  photo: 'assets/images/categories/${c.photo}.jpg',
                  icon: c.icon,
                  tint: c.location.tint,
                  size: AppSizes.iconTileSm,
                ),
                selected: _category == c,
                onTap: () => _setCategory(c, manual: true),
              ),
          ],
        ),
        const SizedBox(height: AppSpace.x6),
        StepSectionTitle(l.pantryAddLocationSection, hint: l.pantryAddLocationRequired),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpace.x2,
          crossAxisSpacing: AppSpace.x2,
          childAspectRatio: AppSizes.locationTileRatio,
          children: [
            for (final loc in PantryLocation.values)
              OptionTile(
                label: loc.label(l),
                leading: FoodThumb(photo: loc.photo, icon: loc.icon, tint: loc.tint, size: AppSizes.iconTileSm),
                selected: _location == loc,
                onTap: () => setState(() {
                  _location = loc;
                  _locationManual = true;
                  if (_error != null && _name.text.trim().isNotEmpty) _error = null;
                }),
              ),
          ],
        ),
        const SizedBox(height: AppSpace.x6),
        StepSectionTitle(l.pantryAddExpirySection, hint: _expires != null && !_expiresManual ? l.pantryAddExpiryEstimated : null),
        AppCard(
          onTap: _pickDate,
          padding: const EdgeInsets.all(AppSpace.x3_5),
          child: Row(
            children: [
              const IconTile(icon: AppIcons.calendar, size: AppSizes.iconTileSm, iconSize: 18),
              const SizedBox(width: AppSpace.x3),
              Expanded(
                child: Text(
                  _expires == null ? l.pantryAddPickDate : _dateLabel(l, _expires!),
                  style: AppText.of(AppFont.s14, weight: AppFont.bold),
                ),
              ),
              const AppIcon(AppIcons.edit, size: 16, color: AppColors.primary),
            ],
          ),
        ),
        const SizedBox(height: AppSpace.x2_5),
        Wrap(
          spacing: AppSpace.x2,
          runSpacing: AppSpace.x2,
          children: [
            for (final s in [(3, l.pantryAdd3Days), (7, l.pantryAdd1Week), (14, l.pantryAdd2Weeks), (30, l.pantryAdd1Month)])
              ToggleChip(
                label: s.$2,
                selected: _expires != null && DateUtils.dateOnly(_expires!).difference(_today).inDays == s.$1,
                onTap: () => setState(() {
                  _expires = _today.add(Duration(days: s.$1));
                  _expiresManual = true;
                }),
              ),
          ],
        ),
        FormError(message: _error),
      ],
    );
  }
}
