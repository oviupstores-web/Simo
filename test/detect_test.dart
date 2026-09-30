import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:menoo/models/food_images.dart';
import 'package:menoo/screens/pantry/pantry_add_manual_screen.dart';

void main() {
  test('Catégorie détectée d\'après le nom saisi (ajout manuel à la réserve)', () {
    for (final n in [
      'Ketchup',
      'Mayonnaise',
      'Moutarde de Dijon',
      'Vinaigre balsamique',
      'Huile d\'olive',
      'Sel',
      'Poivre noir',
      'Épices',
      'Herbes de Provence',
      'Bouillon cube',
      'Conserve',
    ]) {
      expect(FoodCategory.detect(n), FoodCategory.epicerie, reason: n);
    }
    expect(FoodCategory.detect('Poivrons'), FoodCategory.legumes);
    expect(FoodCategory.detect('Bœuf haché'), FoodCategory.viandes);
    expect(FoodCategory.detect('Œufs'), FoodCategory.laitiers);
    expect(FoodCategory.detect('CRÈME'), FoodCategory.laitiers);
    expect(FoodCategory.detect('Clémentine'), FoodCategory.fruits);
    expect(FoodCategory.detect('Chocolat'), FoodCategory.sucre);
    expect(FoodCategory.detect('Tahini'), isNull);
  });

  test('Photo d\'un aliment : catalogue d\'abord, mots-clés ensuite', () {
    String? photo(String n) => FoodImages.forName(n)?.replaceFirst('assets/images/', '');
    expect(photo('Yaourt nature'), 'ingredients/yaourt_nature.jpg');
    expect(photo('Pommes de terre'), 'ingredients/pommes_de_terre.jpg');
    expect(photo('Pomme'), 'ingredients/pomme.jpg');
    expect(photo('Bœuf haché'), 'ingredients/boeuf.jpg');
    expect(photo('Œufs'), 'ingredients/oeufs.jpg');
    expect(photo('Huile d\'olive'), 'ingredients/huile_olive.jpg');
    expect(photo('Poireau'), 'ingredients/poireaux.jpg');
    expect(photo('Tomates'), 'food/tomates.jpg');
    expect(photo('Tahini'), isNull);
    for (final i in FoodImages.ingredients) {
      expect(File('assets/images/ingredients/$i.jpg').existsSync(), isTrue, reason: i);
    }
    expect(FoodImages.ingredients.length, Directory('assets/images/ingredients').listSync().length);
  });
}
