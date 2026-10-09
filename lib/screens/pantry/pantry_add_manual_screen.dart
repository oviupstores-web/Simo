import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../l10n/formats.dart';
import '../../models/food_catalog.dart';
import '../../models/pantry_values.dart';
export '../../models/food_catalog.dart' show FoodCategory;
import '../../onboarding/onboarding_data.dart';
import '../../onboarding/onboarding_scope.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

/// pantry_addmanual — ajout manuel à la réserve. SPEC §7 : l'emplacement est obligatoire,
/// pré-rempli selon la catégorie (yaourt → Réfrigérateur, pâtes → Placard, surgelé → Congélateur,
/// fruits → Corbeille) et modifiable.
class PantryAddManualScreen extends StatefulWidget {
  const PantryAddManualScreen({super.key});

  @override
  State<PantryAddManualScreen> createState() => _PantryAddManualScreenState();
}

class _PantryAddManualScreenState extends State<PantryAddManualScreen> {
  static PantryUnit _suggestedUnit(FoodIdentity food) => switch (food.id) {
    'saumon' || 'pate' => PantryUnit.gram,
    'lait' => PantryUnit.liter,
    _ => PantryUnit.piece,
  };

  final _name = TextEditingController();
  double _quantity = 1;
  PantryUnit _unit = PantryUnit.piece;
  bool _quantityEdited = false;
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
  DateTime _afterDays(int days) => DateTime(_today.year, _today.month, _today.day + days);

  void _setCategory(FoodCategory? c, {bool manual = false}) {
    setState(() {
      _category = c;
      if (manual) _categoryManual = true;
      final food = FoodCatalog.match(_name.text);
      final matchingFood = food?.category == c ? food : null;
      if (!_locationManual) _location = matchingFood?.suggestedLocation ?? c?.location;
      if (!_expiresManual) {
        final days = matchingFood != null ? matchingFood.suggestedDays : c?.shelfDays;
        _expires = days == null ? null : _afterDays(days);
      }
    });
  }

  void _onName(String value) {
    _setCategory(_categoryManual ? _category : FoodCategory.detect(value));
    if (_error != null && value.trim().isNotEmpty) setState(() => _error = null);
  }

  void _step(int dir) => setState(() {
    _quantityEdited = true;
    final big = _unit == PantryUnit.gram || _unit == PantryUnit.milliliter;
    final delta = big ? (_quantity >= 100 || (dir > 0 && _quantity >= 50) ? 50.0 : 10.0) : 1.0;
    _quantity = (_quantity + dir * delta).clamp(big ? 10 : 1, 100000).toDouble();
  });

  String get _quantityLabel => Formats.of(context).number(_quantity, decimals: 2);

  String _dateLabel(L l, DateTime d) {
    final days = PantryDraft.calendarDaysBetween(_today, d);
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
      initialDate: _expires ?? _afterDays(7),
      firstDate: _today,
      lastDate: _afterDays(365 * 3),
      locale: Localizations.localeOf(context),
    );
    if (!mounted || picked == null) return;
    setState(() {
      _expires = picked;
      _expiresManual = true;
    });
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
          name: name,
          foodId: FoodCatalog.match(name)?.id,
          quantity: _quantity,
          unit: _unit,
          expiryOrigin: _expires == null
              ? ExpiryOrigin.unknown
              : _expiresManual
              ? ExpiryOrigin.userProvided
              : ExpiryOrigin.estimated,
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
    final unit = _unit;
    Widget optionGrid(List<Widget> tiles) => LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 360) {
          return Wrap(
            spacing: AppSpace.x2,
            runSpacing: AppSpace.x2,
            children: [
              for (final tile in tiles) SizedBox(width: (constraints.maxWidth - AppSpace.x2) / 2, child: tile),
            ],
          );
        }
        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpace.x2,
          crossAxisSpacing: AppSpace.x2,
          childAspectRatio: AppSizes.locationTileRatio,
          children: tiles,
        );
      },
    );
    final categoryTiles = [
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
    ];
    final locationTiles = [
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
    ];
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
        IconTextField(icon: AppIcons.search, hint: l.pantryAddNameHint, controller: _name, onChanged: _onName),
        const SizedBox(height: AppSpace.x2_5),
        Wrap(
          spacing: AppSpace.x2,
          runSpacing: AppSpace.x2,
          children: [
            for (final s in FoodCatalog.suggestions(l))
              ToggleChip(
                label: s.$2,
                leading: FoodThumb(
                  photo: s.$1.photo,
                  icon: s.$1.category.icon,
                  tint: s.$1.suggestedLocation.tint,
                  size: AppSizes.chipBadge,
                  circle: true,
                ),
                selected: false,
                onTap: () {
                  _name.text = s.$2;
                  setState(() {
                    _unit = _suggestedUnit(s.$1);
                    if (!_quantityEdited) _quantity = _unit == PantryUnit.gram ? 200 : 1;
                    // Une valeur préremplie puis acceptée reste conservée aux choix suivants.
                    _quantityEdited = true;
                    _categoryManual = false;
                  });
                  _onName(s.$2);
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
                    for (final (i, u) in PantryUnit.values.indexed) ...[
                      if (i > 0) const SizedBox(width: AppSpace.x1_5),
                      ToggleChip(
                        label: u.label(l),
                        selected: unit == u,
                        onTap: () => setState(() {
                          _unit = u;
                          _quantityEdited = true;
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
        StepSectionTitle(
          l.pantryAddCategorySection,
          hint: _category != null && !_categoryManual ? l.pantryAddCategoryAuto : null,
        ),
        optionGrid(categoryTiles),
        const SizedBox(height: AppSpace.x6),
        StepSectionTitle(l.pantryAddLocationSection, hint: l.pantryAddLocationRequired),
        optionGrid(locationTiles),
        const SizedBox(height: AppSpace.x6),
        StepSectionTitle(
          l.pantryAddExpirySection,
          hint: _expires != null && !_expiresManual ? l.pantryAddExpiryEstimated : null,
        ),
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
            for (final s in [
              (3, l.pantryAdd3Days),
              (7, l.pantryAdd1Week),
              (14, l.pantryAdd2Weeks),
              (30, l.pantryAdd1Month),
            ])
              ToggleChip(
                label: s.$2,
                selected: _expires != null && PantryDraft.calendarDaysBetween(_today, _expires!) == s.$1,
                onTap: () => setState(() {
                  _expires = _afterDays(s.$1);
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
