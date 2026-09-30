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
    // Écrans encore en français, traduits au fur et à mesure (liste vidée à la fin du 5i).
  };

  /// Fichiers sans texte d'interface : données, icônes, mots-clés de détection.
  const skippedFiles = {
    'lib/theme/app_icons.dart', // tracés SVG
    'lib/widgets/app_icon.dart', // assemblage d'attributs SVG
    'lib/models/food_images.dart', // mots-clés de correspondance
  };

  /// Écrans pas encore traduits (jalon 5i, étape 4). **Cette liste doit finir vide.**
  const notYetTranslated = {
    'lib/models/pantry_location.dart',
    'lib/onboarding/onboarding_data.dart',
    'lib/onboarding/onboarding_flow.dart',
    'lib/navigation.dart',
    'lib/screens/home/',
    'lib/screens/menus/',
    'lib/screens/onboarding/activity_screen.dart',
    'lib/screens/onboarding/budget_screen.dart',
    'lib/screens/onboarding/constraints_screen.dart',
    'lib/screens/onboarding/goal_screen.dart',
    'lib/screens/onboarding/household_size_screen.dart',
    'lib/screens/onboarding/kitchen_screen.dart',
    'lib/screens/onboarding/management_mode_screen.dart',
    'lib/screens/onboarding/member_profiles_screen.dart',
    'lib/screens/onboarding/onboarding_cuisines_screen.dart',
    'lib/screens/onboarding/profile_screen.dart',
    'lib/screens/onboarding/smart_scale_screen.dart',
    'lib/screens/onboarding/summary_screen.dart',
    'lib/screens/onboarding/supermarket_screen.dart',
    'lib/screens/onboarding/weekly_grid_screen.dart',
    'lib/screens/pantry/',
    'lib/screens/shopping/',
    'lib/widgets/fields.dart',
    'lib/widgets/list_section.dart',
    'lib/widgets/onboarding_step.dart',
    'lib/widgets/surfaces.dart',
  };

  /// Dossiers à ne pas scanner.
  const skippedDirs = {'lib/l10n'};

  /// Un texte est « visible » s'il contient un accent français, ou au moins deux mots
  /// de trois lettres. Cela laisse passer les identifiants (`sans_porc`, `fridge`).
  bool looksLikeUiText(String s) {
    if (s.length < 4) return false;
    if (RegExp(r'^(assets/|package:|dart:|https?:|\.\.?/|[a-z_]+\.(dart|jpg|png|ttf|svg))').hasMatch(s)) return false;
    if (s.startsWith('<')) return false; // tracé SVG
    if (RegExp('[àâäéèêëîïôöùûüçœæÀÉÈÊÇ]').hasMatch(s)) return true;
    return RegExp(r'[A-Za-z]{3,}\s+[A-Za-z]{3,}').hasMatch(s);
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
        .where((p) => !notYetTranslated.any(p.startsWith))
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
