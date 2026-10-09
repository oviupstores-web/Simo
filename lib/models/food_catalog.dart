import 'package:flutter/widgets.dart' show Locale;

import '../l10n/app_localizations.dart';
import '../theme/app_icons.dart';
import 'pantry_location.dart';

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

  static FoodCategory? detect(String name) => FoodCatalog.match(name)?.category;
}

/// Identité indépendante du libellé ; les variantes explicites ne fusionnent pas les lots.
class FoodIdentity {
  const FoodIdentity(this.id, this.category, this.aliases, {this.photo, this.location, this.noAutomaticDate = false});
  final String id;
  final FoodCategory category;
  final List<String> aliases;
  final String? photo;
  final PantryLocation? location;
  final bool noAutomaticDate;
  PantryLocation get suggestedLocation => location ?? category.location;
  int? get suggestedDays => noAutomaticDate ? null : category.shelfDays;
}

abstract final class FoodCatalog {
  static String normalize(String value) => value
      .toLowerCase()
      .replaceAll(RegExp('[àâä]'), 'a')
      .replaceAll(RegExp('[éèêë]'), 'e')
      .replaceAll(RegExp('[îï]'), 'i')
      .replaceAll(RegExp('[ôö]'), 'o')
      .replaceAll(RegExp('[ùûü]'), 'u')
      .replaceAll('œ', 'oe')
      .replaceAll('æ', 'ae')
      .replaceAll('ç', 'c')
      .replaceAll('ß', 'ss')
      .replaceAll(RegExp(r'[^a-z0-9\u0600-\u06ff]+'), ' ')
      .trim();

  static final foods = <FoodIdentity>[
    FoodIdentity('surgel', FoodCategory.surgeles, [
      'surgele',
      'surgeles',
      'surgelee',
      'surgelees',
      'frozen',
      'tiefkuhl',
      'tiefgekuhlt',
    ], photo: null),
    FoodIdentity('glace', FoodCategory.surgeles, ['glace', 'glaces'], photo: null),
    FoodIdentity('avocat', FoodCategory.fruits, [
      'avocat',
      'avocats',
      'avocado',
      'avocados',
    ], photo: 'assets/images/ingredients/avocat.jpg'),
    FoodIdentity('banane', FoodCategory.fruits, ['banane', 'bananes'], photo: null),
    FoodIdentity('pomme', FoodCategory.fruits, [
      'pomme',
      'pommes',
      'apple',
      'apples',
      'apfel',
      'apfeln',
      'apfels',
      'aepfel',
    ], photo: 'assets/images/ingredients/pomme.jpg'),
    FoodIdentity('poire', FoodCategory.fruits, ['poire', 'poires', 'pear', 'pears', 'birne', 'birnen'], photo: null),
    FoodIdentity('citron', FoodCategory.fruits, ['citron', 'citrons'], photo: null),
    FoodIdentity('fraise', FoodCategory.fruits, ['fraise', 'fraises'], photo: null),
    FoodIdentity('orange', FoodCategory.fruits, ['orange', 'oranges'], photo: null),
    FoodIdentity('kiwi', FoodCategory.fruits, ['kiwi', 'kiwis'], photo: null),
    FoodIdentity('raisin', FoodCategory.fruits, ['raisin', 'raisins'], photo: null),
    FoodIdentity('mangue', FoodCategory.fruits, ['mangue', 'mangues'], photo: null),
    FoodIdentity('clementine', FoodCategory.fruits, ['clementine', 'clementines'], photo: null),
    FoodIdentity('myrtille', FoodCategory.fruits, ['myrtille', 'myrtilles'], photo: null),
    FoodIdentity('framboise', FoodCategory.fruits, ['framboise', 'framboises'], photo: null),
    FoodIdentity('salade', FoodCategory.legumes, ['salade', 'salades', 'salad', 'salate'], photo: null),
    FoodIdentity('epinard', FoodCategory.legumes, ['epinard', 'epinards'], photo: null),
    FoodIdentity('carotte', FoodCategory.legumes, ['carotte', 'carottes'], photo: null),
    FoodIdentity('courgette', FoodCategory.legumes, ['courgette', 'courgettes'], photo: null),
    FoodIdentity('tomate', FoodCategory.legumes, ['tomate', 'tomates', 'tomates cerises'], photo: null),
    FoodIdentity('brocoli', FoodCategory.legumes, ['brocoli', 'brocolis'], photo: null),
    FoodIdentity('poivron', FoodCategory.legumes, ['poivron', 'poivrons'], photo: null),
    FoodIdentity('oignon', FoodCategory.legumes, ['oignon', 'oignons'], photo: null),
    FoodIdentity('poireau', FoodCategory.legumes, [
      'poireau',
      'poireaus',
      'poireaux',
      'leek',
      'leeks',
      'lauch',
      'porree',
    ], photo: 'assets/images/ingredients/poireaux.jpg'),
    FoodIdentity('champignon', FoodCategory.legumes, ['champignon', 'champignons'], photo: null),
    FoodIdentity('concombre', FoodCategory.legumes, ['concombre', 'concombres'], photo: null),
    FoodIdentity('chou', FoodCategory.legumes, ['chou', 'chous'], photo: null),
    FoodIdentity('poulet', FoodCategory.viandes, ['poulet', 'poulets'], photo: null),
    FoodIdentity('boeuf', FoodCategory.viandes, ['boeuf', 'boeufs', 'boeuf hache'], photo: null),
    FoodIdentity('saumon', FoodCategory.viandes, [
      'saumon',
      'saumons',
      'salmon',
      'lachs',
    ], photo: 'assets/images/ingredients/saumon.jpg'),
    FoodIdentity('poisson', FoodCategory.viandes, ['poisson', 'poissons'], photo: null),
    FoodIdentity('jambon', FoodCategory.viandes, ['jambon', 'jambons'], photo: null),
    FoodIdentity('steak', FoodCategory.viandes, ['steak', 'steaks'], photo: null),
    FoodIdentity('dinde', FoodCategory.viandes, ['dinde', 'dindes'], photo: null),
    FoodIdentity('porc', FoodCategory.viandes, ['porc', 'porcs'], photo: null),
    FoodIdentity('cabillaud', FoodCategory.viandes, ['cabillaud', 'cabillauds'], photo: null),
    FoodIdentity('thon', FoodCategory.viandes, ['thon', 'thons'], photo: null),
    FoodIdentity('crevette', FoodCategory.viandes, ['crevette', 'crevettes'], photo: null),
    FoodIdentity('viande', FoodCategory.viandes, ['viande', 'viandes'], photo: null),
    FoodIdentity('yaourt', FoodCategory.laitiers, [
      'yaourt',
      'yaourts',
      'yogurt',
      'yoghurt',
      'joghurt',
      'naturjoghurt',
      'yaourt nature',
      'plain yoghurt',
      'yaourt grec',
      'yaourt coco',
    ], photo: 'assets/images/ingredients/yaourt_nature.jpg'),
    FoodIdentity('lait', FoodCategory.laitiers, [
      'lait',
      'laits',
      'milk',
      'milch',
    ], photo: 'assets/images/ingredients/lait.jpg'),
    FoodIdentity('fromage', FoodCategory.laitiers, ['fromage', 'fromages'], photo: null),
    FoodIdentity('beurre', FoodCategory.laitiers, ['beurre', 'beurres'], photo: null),
    FoodIdentity('creme', FoodCategory.laitiers, ['creme', 'cremes'], photo: null),
    FoodIdentity('oeuf', FoodCategory.laitiers, [
      'oeuf',
      'oeufs',
      'oeufs',
      'egg',
      'eggs',
      'ei',
      'eier',
    ], photo: 'assets/images/ingredients/oeufs.jpg'),
    FoodIdentity('feta', FoodCategory.laitiers, ['feta', 'fetas'], photo: null),
    FoodIdentity('chevre', FoodCategory.laitiers, ['chevre', 'chevres'], photo: null),
    FoodIdentity('parmesan', FoodCategory.laitiers, ['parmesan', 'parmesans'], photo: null),
    FoodIdentity('emmental', FoodCategory.laitiers, ['emmental', 'emmentals'], photo: null),
    FoodIdentity('chocolat', FoodCategory.sucre, ['chocolat', 'chocolats'], photo: null),
    FoodIdentity('biscuit', FoodCategory.sucre, ['biscuit', 'biscuits'], photo: null),
    FoodIdentity('sucre', FoodCategory.sucre, ['sucre', 'sucres'], photo: null),
    FoodIdentity('miel', FoodCategory.sucre, ['miel', 'miels'], photo: null),
    FoodIdentity('confiture', FoodCategory.sucre, ['confiture', 'confitures'], photo: null),
    FoodIdentity('cereale', FoodCategory.sucre, ['cereale', 'cereales'], photo: null),
    FoodIdentity('gateau', FoodCategory.sucre, ['gateau', 'gateaus'], photo: null),
    FoodIdentity('pate', FoodCategory.epicerie, [
      'pate',
      'pates',
      'pates',
      'pasta',
      'noodles',
      'nudeln',
    ], photo: 'assets/images/ingredients/pates.jpg'),
    FoodIdentity('riz', FoodCategory.epicerie, ['riz', 'rizs'], photo: null),
    FoodIdentity('quinoa', FoodCategory.epicerie, ['quinoa', 'quinoas'], photo: null),
    FoodIdentity('lentille', FoodCategory.epicerie, ['lentille', 'lentilles'], photo: null),
    FoodIdentity('conserve', FoodCategory.epicerie, ['conserve', 'conserves'], photo: null),
    FoodIdentity('huile', FoodCategory.epicerie, ['huile', 'huiles', 'huile d olive'], photo: null),
    FoodIdentity('farine', FoodCategory.epicerie, ['farine', 'farines'], photo: null),
    FoodIdentity('semoule', FoodCategory.epicerie, ['semoule', 'semoules'], photo: null),
    FoodIdentity('haricot', FoodCategory.epicerie, ['haricot', 'haricots'], photo: null),
    FoodIdentity('pois_chiche', FoodCategory.epicerie, ['pois chiche', 'pois chiches'], photo: null),
    FoodIdentity('sauce', FoodCategory.epicerie, ['sauce', 'sauces'], photo: null),
    FoodIdentity('vinaigre', FoodCategory.epicerie, ['vinaigre', 'vinaigres', 'vinaigre balsamique'], photo: null),
    FoodIdentity('ketchup', FoodCategory.epicerie, ['ketchup', 'ketchups'], photo: null),
    FoodIdentity('mayonnaise', FoodCategory.epicerie, ['mayonnaise', 'mayonnaises'], photo: null),
    FoodIdentity('moutarde', FoodCategory.epicerie, ['moutarde', 'moutardes', 'moutarde de dijon'], photo: null),
    FoodIdentity('sel', FoodCategory.epicerie, ['sel', 'sels'], photo: null),
    FoodIdentity('poivre', FoodCategory.epicerie, ['poivre', 'poivres', 'poivre noir'], photo: null),
    FoodIdentity('epice', FoodCategory.epicerie, ['epice', 'epices'], photo: null),
    FoodIdentity('herbe', FoodCategory.epicerie, ['herbe', 'herbes', 'herbes de provence'], photo: null),
    FoodIdentity('bouillon', FoodCategory.epicerie, ['bouillon', 'bouillons', 'bouillon cube'], photo: null),
    FoodIdentity('laitue', FoodCategory.legumes, [
      'laitue',
      'laitues',
      'lettuce',
      'kopfsalat',
      'salat',
    ], photo: 'assets/images/ingredients/laitue.jpg'),
    FoodIdentity(
      'potato',
      FoodCategory.legumes,
      ['pomme de terre', 'pommes de terre', 'potato', 'potatoes', 'kartoffel', 'kartoffeln'],
      photo: 'assets/images/ingredients/pommes_de_terre.jpg',
      location: PantryLocation.pantry,
      noAutomaticDate: true,
    ),
  ];

  // Les suggestions conservent leurs identités aussi dans les langues non proposées au lancement.
  static final _suggestionAliases = <String, FoodIdentity>{
    for (final language in ['fr', 'en', 'de', 'es', 'it', 'ar'])
      for (final entry in suggestions(lookupL(Locale(language)))) normalize(entry.$2): entry.$1,
  };

  static List<(FoodIdentity, String)> suggestions(L l) => [
    (byId('avocat'), l.pantrySuggestAvocado),
    (byId('saumon'), l.pantrySuggestFreshSalmon),
    (byId('oeuf'), l.pantrySuggestEggs),
    (byId('pate'), l.pantrySuggestPasta),
    (byId('yaourt'), l.pantrySuggestPlainYogurt),
    (byId('lait'), l.pantrySuggestMilk),
  ];
  static FoodIdentity byId(String id) => foods.firstWhere((f) => f.id == id);

  static FoodIdentity? match(String name) {
    final n = normalize(name);
    if (n.isEmpty) return null;
    final translated = _suggestionAliases[n];
    if (translated != null) return translated;
    final padded = ' $n ';
    if ([
      'lait d avoine',
      'lait de soja',
      'oat milk',
      'soy milk',
      'hafermilch',
      'sojamilch',
    ].any((a) => padded.contains(' $a '))) {
      return null;
    }
    final matches = <(FoodIdentity, String)>[
      for (final f in foods)
        for (final alias in f.aliases)
          if (padded.contains(' ${normalize(alias)} ')) (f, normalize(alias)),
    ];
    // Une expression complète masque uniquement les mots qu'elle contient.
    final precise = matches
        .where((m) => !matches.any((other) => other.$2.length > m.$2.length && (' ${other.$2} ').contains(' ${m.$2} ')))
        .toList();
    final ids = precise.map((m) => m.$1.id).toSet();
    if (ids.contains('surgel') || ids.contains('glace')) return byId(ids.contains('surgel') ? 'surgel' : 'glace');
    if (ids.length != 1) return null;
    // Un nom composé non reconnu ne doit pas hériter d'un mot isolé (apple pie, sweet potatoes…).
    final covered = precise.expand((m) => m.$2.split(' ')).toSet();
    const descriptors = {
      'de',
      'du',
      'd',
      'des',
      'of',
      'von',
      'frais',
      'fraiche',
      'fraiches',
      'fresh',
      'frisch',
      'frischer',
      'frische',
      'frisches',
      'frischen',
      'nature',
      'plain',
      'bio',
      'organic',
    };
    if (n.split(' ').any((word) => !covered.contains(word) && !descriptors.contains(word))) return null;
    final food = byId(ids.single);
    if (food.noAutomaticDate && RegExp(r'\b(cuit|cuits|cuite|cuites|cooked|gekocht)\b').hasMatch(n)) return null;
    return food;
  }
}
