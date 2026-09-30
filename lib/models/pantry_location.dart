import 'package:flutter/widgets.dart';

import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_tints.dart';

/// Emplacements obligatoires de la réserve (SPEC §7 onglet 4) — enum `pantry_location` de la base.
enum PantryLocation {
  fridge('Réfrigérateur', 'Frigo', AppIcons.fridge, AppColors.mint, AppColors.primary, 'fridge'),
  fruitBasket('Corbeille à fruits', 'Corbeille', AppIcons.basket, AppColors.orangeSoft, AppColors.warn, 'fruit_basket'),
  pantry('Placard', 'Placard', AppIcons.cupboard, AppColors.pantrySoft, AppColors.pantryInk, 'pantry'),
  freezer('Congélateur', 'Congél.', AppIcons.snowflake, AppColors.freezerSoft, AppColors.freezerInk, 'freezer');

  const PantryLocation(this.label, this.short, this.icon, this.soft, this.ink, this.dbValue);

  final String label;
  final String short;
  final String icon;
  final Color soft;
  final Color ink;

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
