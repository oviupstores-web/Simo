import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Détecte les textes d'interface restés en dur dans le code (SPEC §0.12 : aucun texte
/// en dur). Le test échoue en listant le fichier, la ligne et le texte trouvé.
///
/// Pour lever une alerte injustifiée, ajouter le texte à [_allowed] avec la raison.
void main() {
  /// Textes qui ne sont pas de l'interface : ils ne se traduisent pas.
  const allowed = {
    // Marque et polices
    'Menoo', 'PlusJakartaSans', 'Caveat', 'NotoSansArabic',
    // Noms propres : marques et enseignes ne se traduisent pas.
    'Google', 'Apple', 'Health Connect', 'Open Prices',
    'E.Leclerc', 'Carrefour', 'Intermarché', 'Auchan', 'Super U', 'Lidl', 'Monoprix', 'Biocoop',
    // Prénom de démo (jalon 3, compte de test) : reste tel quel dans toutes les langues.
    'Karim',
    // Mot-clé de détection de catégorie (pantry_add_manual_screen.dart), pas un texte affiché.
    'pois chiche',
    // Famille de démo (SPEC §9, famille Martin) : prénoms, jamais traduits.
    'Thomas', 'Sarah', 'Lucas', 'Emma',
  };

  /// Fichiers sans texte d'interface : données, icônes, mots-clés de détection.
  const skippedFiles = {
    'lib/theme/app_icons.dart', // tracés SVG
    'lib/widgets/app_icon.dart', // assemblage d'attributs SVG
    'lib/models/food_images.dart', // mots-clés de correspondance
    'lib/models/food_catalog.dart', // aliases de reconnaissance, jamais affichés comme texte UI
  };

  /// Dossiers à ne pas scanner.
  const skippedDirs = {'lib/l10n'};

  /// Un texte est « visible » s'il ressemble à une phrase ou à un mot écrit pour être lu :
  /// un accent, deux mots, ou un seul mot qui commence par une majuscule (« Continuer »).
  /// Cela laisse passer les identifiants techniques (`sans_porc`, `fridge`, `EUR`).
  bool looksLikeUiText(String s) {
    if (s.trim().length < 3) return false;
    if (RegExp(r'^(assets/|package:|dart:|https?:|\.\.?/|[a-z_]+\.(dart|jpg|png|ttf|svg))').hasMatch(s)) return false;
    if (s.startsWith('<')) return false; // tracé SVG
    if (RegExp('[àâäéèêëîïôöùûüçœæÀÉÈÊÇÎÔÙ]').hasMatch(s)) return true;
    if (RegExp(r'[A-Za-z]{3,}\s+[A-Za-z]{2,}').hasMatch(s)) return true;
    // Un mot seul, capitalisé, d'au moins 3 lettres : « Passer », « Menus », « Email ».
    return RegExp(r'^[A-Z][a-z]{2,}$').hasMatch(s.trim());
  }

  /// Retire les commentaires de ligne, pour ne pas signaler les explications en français.
  String stripComments(String line) {
    final i = line.indexOf('//');
    if (i < 0) return line;
    // Un `//` à l'intérieur d'une chaîne (une URL) n'ouvre pas un commentaire.
    final before = line.substring(0, i);
    final quotes = "'".allMatches(before).length + '"'.allMatches(before).length;
    return quotes.isEven ? before : line;
  }

  final singleQuoted = RegExp(r"'((?:[^'\\\n]|\\.)*)'");
  final doubleQuoted = RegExp(r'"((?:[^"\\\n]|\\.)*)"');

  test('Aucun texte d\'interface en dur dans lib/', () {
    final found = <String>[];
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .map((f) => f.path.replaceAll(r'\', '/'))
        .where((p) => !skippedFiles.contains(p))
        .where((p) => !skippedDirs.any(p.startsWith))
        .where((p) => !p.contains('app_localizations'))
        .toList()
      ..sort();

    for (final path in files) {
      final lines = File(path).readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final code = stripComments(lines[i]);
        for (final re in [singleQuoted, doubleQuoted]) {
          for (final m in re.allMatches(code)) {
            final text = m.group(1)!;
            if (allowed.contains(text) || !looksLikeUiText(text)) continue;
            found.add('$path:${i + 1}  « $text »');
          }
        }
      }
    }

    expect(
      found,
      isEmpty,
      reason:
          '${found.length} texte(s) en dur à sortir dans lib/l10n/app_fr.arb :\n${found.join('\n')}',
    );
  });
}
