import 'package:flutter/widgets.dart' show Locale;

import '../l10n/app_localizations.dart';
import 'food_catalog.dart';
import 'pantry_location.dart';
import '../theme/app_icons.dart';

const pantryLanguages = ['fr', 'en', 'de', 'es', 'it', 'ar'];

String _plural(String label, double? quantity) {
  final plural = quantity != null && quantity > 1;
  if (label.endsWith('/i')) {
    final base = label.substring(0, label.length - 2);
    return plural ? '${base.substring(0, base.length - 1)}i' : base;
  }
  if (label.contains('/')) return label.split('/')[plural ? 1 : 0];
  return label
      .replaceAll('(s)', quantity != null && quantity > 1 ? 's' : '')
      .replaceAll('(en)', quantity != null && quantity > 1 ? 'en' : '')
      .replaceAll('(es)', quantity != null && quantity > 1 ? 'es' : '');
}

enum PantryUnit {
  piece('piece'),
  gram('gram'),
  kilogram('kilogram'),
  milliliter('milliliter'),
  liter('liter'),
  pack('pack');

  const PantryUnit(this.id);
  final String id;
  String label(L l) => switch (this) {
    piece => l.unitPieces2,
    gram => 'g',
    kilogram => 'kg',
    milliliter => 'ml',
    liter => 'L',
    pack => l.unitPacks2,
  };
  String display(L l, double? quantity) => _plural(label(l), quantity);
  static PantryUnit? fromLegacy(String value) {
    final n = FoodCatalog.normalize(value);
    if (n.isEmpty) return null;
    for (final unit in values) {
      if (n == unit.id) return unit;
      for (final language in pantryLanguages) {
        final l = lookupL(Locale(language));
        if ([unit.label(l), unit.display(l, 1), unit.display(l, 2)].any((s) => FoodCatalog.normalize(s) == n)) {
          return unit;
        }
      }
    }
    return null;
  }
}

enum QuickStock {
  present,
  some;

  String label(L l) => this == present ? l.quickCheckInStock : l.quickCheckSomeStored;
  static QuickStock? fromLegacy(String value) {
    final n = FoodCatalog.normalize(value);
    for (final stock in values) {
      for (final language in pantryLanguages) {
        if (FoodCatalog.normalize(stock.label(lookupL(Locale(language)))) == n) return stock;
      }
    }
    return null;
  }
}

enum QuickCategory {
  pastaRice('pasta_rice_starches', AppIcons.wheat, PantryLocation.pantry, 'categories/epicerie_salee'),
  oilCondiments('oil_condiments', AppIcons.drop, PantryLocation.pantry, 'ingredients/huile_olive'),
  eggsDairy('eggs_dairy', AppIcons.egg, PantryLocation.fridge, 'categories/laitiers_oeufs'),
  cansSauce('canned_sauce', AppIcons.cupboard, PantryLocation.pantry, 'categories/conserves_sauces'),
  freshVeg('fresh_vegetables', AppIcons.leaf, PantryLocation.fridge, 'categories/legumes'),
  fruit('fruits', AppIcons.basket, PantryLocation.fruitBasket, 'categories/fruits'),
  flourSugar('flour_sugar', AppIcons.bag, PantryLocation.pantry, 'categories/farine_sucre'),
  spicesHerbs('spices_herbs', AppIcons.sparkles, PantryLocation.pantry, 'categories/epices_herbes'),
  frozenMeatFish(
    'frozen_meat_fish',
    AppIcons.snowflake,
    PantryLocation.freezer,
    'categories/viandes_poissons_surgeles',
  );

  const QuickCategory(this.id, this.icon, this.location, this.photo);
  final String id;
  final String icon;
  final PantryLocation location;
  final String photo;
  String label(L l) => switch (this) {
    pastaRice => l.quickCheckPastaRice,
    oilCondiments => l.quickCheckOilCondiments,
    eggsDairy => l.quickCheckEggsDairy,
    cansSauce => l.quickCheckCansAndSauce,
    freshVeg => l.quickCheckFreshVeg,
    fruit => l.quickCheckFruit,
    flourSugar => l.quickCheckFlourSugar,
    spicesHerbs => l.quickCheckSpicesHerbs,
    frozenMeatFish => l.quickCheckFrozenMeatFish,
  };
  static QuickCategory? fromLegacy(String name) {
    final n = FoodCatalog.normalize(name);
    for (final category in values) {
      for (final language in pantryLanguages) {
        if (FoodCatalog.normalize(category.label(lookupL(Locale(language)))) == n) return category;
      }
    }
    return null;
  }
}

enum ExpiryOrigin { unknown, estimated, userProvided }
