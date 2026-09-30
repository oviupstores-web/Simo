/// Photos d'aliments (vignettes carrées tirées de design/stitch_images/, dans assets/images/food/).
/// Un aliment sans photo garde son icône sur pastille (jamais de liste nue).
abstract final class FoodImages {
  /// Mots-clés (minuscules, sans accent) → vignette. L'ordre compte : le plus précis d'abord.
  static const _rules = [
    (['patate douce'], 'patate_douce'),
    (['fruits rouges', 'myrtille', 'framboise', 'baie', 'cassis'], 'fruits_rouges'),
    (['avocat'], 'avocat'),
    (['saumon', 'poisson', 'cabillaud', 'truite', 'thon'], 'saumon'),
    (['epinard'], 'epinards'),
    (['yaourt', 'produits laitiers', 'laitiers', 'fromage blanc', 'skyr'], 'yaourt'),
    (['creme'], 'creme'),
    (['quinoa'], 'quinoa'),
    (['pate', 'riz', 'feculent', 'semoule', 'lentille'], 'pates_riz'),
    (['huile', 'vinaigre', 'condiment'], 'huile'),
    (['asperge'], 'asperges'),
    (['tomate'], 'tomates'),
    (['roquette', 'salade', 'laitue', 'mache'], 'roquette'),
    (['pain', 'farine', 'baguette', 'gluten'], 'pain'),
    (['tofu', 'soja'], 'tofu'),
    (['poulet', 'volaille', 'dinde', 'viande'], 'poulet'),
    (['legume', 'carotte', 'courgette', 'brocoli', 'poivron', 'poireau', 'chou'], 'legumes'),
    (['chocolat', 'biscuit', 'sucre', 'datte', 'epicerie sucree'], 'sucre'),
    (['fruit'], 'fruits_rouges'),
  ];

  /// Minuscules sans accents (« Crème brûlée » → « creme brulee »).
  static String fold(String s) => s
      .toLowerCase()
      .replaceAll(RegExp('[àâä]'), 'a')
      .replaceAll(RegExp('[éèêë]'), 'e')
      .replaceAll(RegExp('[îï]'), 'i')
      .replaceAll(RegExp('[ôö]'), 'o')
      .replaceAll(RegExp('[ùûü]'), 'u')
      .replaceAll('œ', 'oe')
      .replaceAll('æ', 'ae')
      .replaceAll('ç', 'c');

  /// Photos du catalogue (dossier assets/images/ingredients/).
  static const ingredients = [
    'ail', 'amandes', 'aneth', 'asperges', 'avocat', 'banane', 'basilic', 'beurre', 'boeuf', 'bouillon_legumes',
    'brocoli', 'brocoli_surgele', 'cabillaud', 'cacao', 'cannelle', 'carottes', 'chevre', 'chou_rouge', 'citron',
    'coulis_tomate', 'courge_butternut', 'courgette', 'creme_fraiche', 'crevettes', 'cumin', 'dattes', 'edamame',
    'emmental', 'epinards', 'feta', 'flocons_avoine', 'fraises', 'framboises', 'fruits_rouges_surgeles',
    'graines_chia', 'grenade', 'herbes_provence', 'huile_olive', 'kiwi', 'lait', 'lait_avoine', 'laitue', 'lardons',
    'lentilles_vertes', 'matcha', 'miel', 'moutarde', 'myrtilles', 'noix', 'nouilles_soba', 'oeufs', 'oignon',
    'olives', 'pain_complet', 'paprika', 'parmesan', 'patate_douce', 'pate_brisee', 'pate_feuilletee', 'pates',
    'poireaux', 'pois_chiches', 'poivron', 'pomme', 'pommes_de_terre', 'poulet', 'puree_amande', 'quinoa', 'riz',
    'riz_arborio', 'roquette', 'sauce_soja', 'saumon', 'sesame', 'tofu', 'tomates_cerises', 'tortillas',
    'yaourt_coco', 'yaourt_grec', 'yaourt_nature',
  ];

  /// Mots utiles au singulier, entourés d'espaces (« Pommes de terre » → « pomme terre »).
  static String _words(String s) {
    final words = fold(s).split(RegExp('[^a-z]+')).where((w) => w.length > 2);
    return ' ${words.map((w) => w.endsWith('s') || w.endsWith('x') ? w.substring(0, w.length - 1) : w).join(' ')} ';
  }

  /// Chemin de la vignette pour un nom d'aliment, ou null si aucune photo ne correspond.
  /// La photo du catalogue la plus précise d'abord, sinon les vignettes par mots-clés.
  static String? forName(String name) {
    final words = _words(name);
    String? best;
    for (final i in ingredients) {
      if (words.contains(_words(i)) && i.length > (best?.length ?? 0)) best = i;
    }
    if (best != null) return 'assets/images/ingredients/$best.jpg';
    final n = fold(name);
    for (final (keys, file) in _rules) {
      if (keys.any(n.contains)) return 'assets/images/food/$file.jpg';
    }
    return null;
  }

  /// Vignette explicite.
  static String asset(String file) => 'assets/images/food/$file.jpg';
}
