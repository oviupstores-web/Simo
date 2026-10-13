# Menoo — cinq langues — 13 octobre 2026

## Résultat et cause

L'application et son sélecteur utilisaient AppLanguages.launchLocales, limité à FR/EN/DE malgré les traductions ES/IT disponibles. La liste est désormais exactement FR/EN/ES/IT/DE. L'arabe reste conservé dans les traductions historiques et certains tests, mais n'est pas sélectionnable et ne peut pas être restauré comme langue active.

683 textes présents et non vides dans chacun des cinq ARB ; chargement du delegate vérifié pour chaque langue. Aucun ARB ni illustration modifié.

Les quatre erreurs à 320 provenaient du Row inférieur des couvertures Solo/Famille : texte non contraint. Ajout d'un Flexible et alignement centré du texte, permettant les retours à la ligne et une hauteur naturelle. Les polices, couleurs, boutons et destinations restent identiques.

## Langue conservée

Ajout explicitement autorisé par Simo : shared_preferences ^2.5.6 et dépendances transitives résolues par Flutter. LocalePreferences utilise SharedPreferencesAsync, clé menoo.language, contenant seulement le code de langue. Chargement avant runApp, puis passage de la langue restaurée à MenooApp. Le sélecteur attend l'enregistrement avant d'appliquer le changement. La région continue de venir du téléphone, sans modification des règles monétaires.

Tests de sauvegarde/relecture avec une nouvelle instance de stockage et tests de première image d'une nouvelle instance de Menoo dans les cinq langues. Ces tests utilisent le simulateur de stockage du plugin : aucun redémarrage physique Android n'a été effectué, puisque l'installation est interdite. La vérification native sur téléphone reste à réaliser lors d'une future installation autorisée.

Documentation technique consultée : https://pub.dev/packages/shared_preferences (API Async recommandée pour nouveau code).

## Fichiers modifiés pendant cette mission

Application :
- lib/l10n/app_languages.dart : cinq langues actives.
- lib/l10n/locale_preferences.dart : nouveau stockage local limité à la langue.
- lib/l10n/locale_scope.dart : enregistrement depuis le sélecteur.
- lib/main.dart : chargement initial et reprise de langue.
- lib/screens/onboarding/cover_solo_screen.dart et cover_household_screen.dart : ligne inférieure adaptative.
- pubspec.yaml et pubspec.lock : dépendance autorisée et résolutions associées.

Tests :
- test/formats_test.dart : cinq langues, résolution ES conservant sa région.
- test/language_picker_test.dart : cinq noms, dix tailles/langues, choix effectif, arabe absent.
- test/locale_preferences_test.dart : stockage, reprise, rejet de langue non proposée et première image de Menoo.
- test/landing_replacement_1258_test.dart : dix captures et chemin de sortie configurable.
- test/landing_responsive_test.dart : ES/IT ajoutés aux cas de texte agrandi 1,3/2,0.
- test/goldens/landing_provisional/full_es_320.png, full_es_390.png, full_it_320.png, full_it_390.png : nouvelles références ES/IT.

Documentation : PLAN.md, DECISIONS.md, SPEC.md et ce dossier de preuves. Les états précédents sont conservés. Les modifications Git antérieures de Landing, thèmes et ARB restent en place ; elles ne proviennent pas de cette mission.

## Tests et limites

| Contrôle | Résultat |
|---|---|
| Tests ciblés five-language (validated.jsonl) | 93 réussites, zéro échec |
| Tests de reprise enrichis (restart.jsonl) | 11 réussites |
| Dernier contrôle i18n + reprise (final_regression.jsonl) | 12 réussites |
| Analyse des fichiers applicatifs modifiés et du stockage | Aucune erreur ni avertissement |
| Suite complète (full.jsonl), avant la dernière correction du diagnostic | 1 307 réussites, 11 erreurs visuelles historiques, 1 échec i18n |
| Échec i18n de ce passage | Diagnostic technique dans main.dart corrigé sans assouplir le test ; contrôle repassé avec succès |
| Quatre débordements ES/IT connus | Tous corrigés ; phase5_onboarding_count_test passe |

La suite complète n'a pas été relancée après cette dernière correction limitée au diagnostic. Les 11 comparaisons visuelles hors Landing restent inchangées et échouées : FR/DE/AR Réserve, FR/AR choix du parcours, couvertures Solo/Famille et inscription. Aucune actualisation de leurs références. Le reste des tests de cette exécution complète est passé.

## Captures Flutter complètes

| Langue | 320 px | 390 px |
|---|---|---|
| FR | [Voir](captures/full_fr_320.png) | [Voir](captures/full_fr_390.png) |
| EN | [Voir](captures/full_en_320.png) | [Voir](captures/full_en_390.png) |
| ES | [Voir](captures/full_es_320.png) | [Voir](captures/full_es_390.png) |
| IT | [Voir](captures/full_it_320.png) | [Voir](captures/full_it_390.png) |
| DE | [Voir](captures/full_de_320.png) | [Voir](captures/full_de_390.png) |

Les six captures FR/EN/DE sont identiques byte pour byte aux contrôles de l'étape 1. Les 300 fichiers protégés (Landing, jetons, ressources, ARB) ont leurs empreintes inchangées ; voir protected_before.json et integrity_after.json.

Constats visuels sans correction : à 320, les feuilles touchent la zone de bénéfices en ES et le titre italien en trois lignes atteint le visuel du plat ; chevauchement anglais déjà signalé. À 390 le titre italien utilise également trois lignes, sans débordement Flutter. Ces constats ne sont pas masqués par les tests d'absence de RenderFlex. Aucune adaptation graphique de la Landing n'a été appliquée.

## Arrêt

Aucun commit/push, aucune installation Android, aucun travail Supabase. Attendre la validation de Simo avant toute correction visuelle supplémentaire ou étape 2.
