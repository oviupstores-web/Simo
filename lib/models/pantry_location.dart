import 'package:flutter/widgets.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_tints.dart';

/// Emplacements obligatoires de la réserve (SPEC §7 onglet 4) — enum `pantry_location` de la base.
enum PantryLocation {
  fridge(AppIcons.fridge, AppColors.mint, AppColors.primary, 'fridge'),
  fruitBasket(AppIcons.basket, AppColors.orangeSoft, AppColors.warn, 'fruit_basket'),
  pantry(AppIcons.cupboard, AppColors.pantrySoft, AppColors.pantryInk, 'pantry'),
  freezer(AppIcons.snowflake, AppColors.freezerSoft, AppColors.freezerInk, 'freezer');

  const PantryLocation(this.icon, this.soft, this.ink, this.dbValue);

  final String icon;
  final Color soft;
  final Color ink;

  String label(L l) => switch (this) {
    PantryLocation.fridge => l.locationFridge,
    PantryLocation.fruitBasket => l.locationFruitBasket,
    PantryLocation.pantry => l.locationPantry,
    PantryLocation.freezer => l.locationFreezer,
  };

  String short(L l) => switch (this) {
    PantryLocation.fridge => l.locationFridgeShort,
    PantryLocation.fruitBasket => l.locationFruitBasketShort,
    PantryLocation.pantry => l.locationPantryShort,
    PantryLocation.freezer => l.locationFreezerShort,
  };

  /// Valeur enregistrée en base.
  final String dbValue;

  String get photo => switch (this) {
    PantryLocation.pantry => 'assets/images/placard_bocaux.jpg',
    _ => 'assets/images/locations/$dbValue.jpg',
  };

  /// Famille de pastille associée (mêmes teintes que les sections de la Réserve).
  Tint get tint => switch (this) {
    PantryLocation.fridge => Tint.mint,
    PantryLocation.fruitBasket => Tint.peach,
    PantryLocation.pantry => Tint.sand,
    PantryLocation.freezer => Tint.sky,
  };
}
