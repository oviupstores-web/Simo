# Agrandissement local des pastilles 3D — 9 octobre 2026

## Tailles appliquées

Toutes les dimensions ci-dessous sont en pixels logiques Flutter. Les tailles extérieures et celles des images sont vérifiées sur les objets réellement rendus par les tests.

| Emplacement | Pastille avant → après | Image avant → après |
|---|---:|---:|
| Objectif, quatre choix | 56 → 64 | 52 → 60 |
| Activité, quatre choix | 56 → 64 | 52 → 60 |
| Mode de gestion Solo et Famille, trois choix | 56 → 64 | 52 → 60 |
| Couverture Solo, trois avantages | 56 → 64 | 52 → 60 |
| Couverture Famille, Zéro gaspillage uniquement | 56 → 64 | 52 → 60 |
| Régimes et restrictions, sept choix | 40 → 48 | 36 → 44 |
| Hub Réserve, Vérification rapide | 48 → 56 | 44 → 52 |
| Hub Réserve, Ma réserve | 56 → 56 | 52 → 52 |

**Proposition non appliquée pour Ma réserve :** pastille de 64 px, image de 60 px. Cela correspondrait aux autres grandes illustrations. Son maintien à 56 px conserve aussi une cohérence avec la nouvelle pastille Vérification rapide de 56 px. Aucun autre pictogramme du hub n'est modifié.

Les copies PNG existantes sont inchangées : même transparence, mêmes ombres, mêmes proportions. Leur contenu maximal occupe environ 92,3 % des grandes pastilles, 90,2 % des pastilles alimentaires et 91,4 % de Vérification rapide, en tenant compte de la marge transparente du fichier. Marge axiale proche de 2–3 px. Le rendu utilise toujours BoxFit.contain.

## Modifications techniques limitées

- `lib/widgets/selectable_card.dart` : paramètre optionnel `iconTileSize`, dont la valeur par défaut reste 56 px. Seuls Objectif, Activité et Gestion passent explicitement 64 px. Un test vérifie que les anciennes cartes restent à 56 px. Aucun comportement global changé.
- `lib/screens/onboarding/goal_screen.dart`, `activity_screen.dart`, `management_mode_screen.dart` : pastille 64 px, illustration 60 px.
- `lib/screens/onboarding/cover_solo_screen.dart` : les trois nouvelles illustrations passent à 64/60 px.
- `lib/screens/onboarding/cover_household_screen.dart` : uniquement Zéro gaspillage passe à 64/60 px ; les deux autres avantages restent à 56 px.
- `lib/screens/onboarding/constraints_screen.dart` : pastilles 48 px et images 44 px. Hauteur locale des sept choix portée de 44 à 56 px, sans modifier ToggleChip ni ses valeurs par défaut.
- `lib/screens/pantry/pantry_hub_onboarding_screen.dart` : uniquement Vérification rapide passe à 56/52 px ; Ma réserve et les autres pictogrammes restent inchangés.
- `test/icon_preview_test.dart` : assertions des dimensions extérieures et intérieures, vérifications RGBA conservées, test d'absence d'effet sur les anciennes ChoiceCard.

Les premiers tests ont montré qu'une hauteur de choix de 44 px comprimait la nouvelle image alimentaire à 44 × 41 px et empêchait une pastille réelle de 48 × 48 px. La correction locale de hauteur permet maintenant une image de 44 × 44 px dans une pastille de 48 × 48 px. Les textes, couleurs, bordures et actions restent identiques.

Les autres cartes ont une hauteur adaptée automatiquement à leur contenu. L'agrandissement réduit de 8 px la largeur disponible pour certains textes : davantage de retours à la ligne sont visibles à 320 px. Les titres avec badge peuvent toujours se couper sur plusieurs lignes, comme avant ; aucune police ni traduction n'a été réduite pour contourner cette contrainte.

## Vérifications et résultats

| Contrôle | Résultat |
|---|---|
| Version avant, tests ciblés | 113 réussites |
| Version finale, tests ciblés | **114 réussites, 0 échec** |
| Langues et largeurs des écrans ciblés | FR/EN/DE à 320 et 390 px ; ES/IT/AR à 390 px |
| Suite complète, navigation Solo/Famille et régressions des phases 1 à 5 | **935 réussites, 17 échecs historiques, 0 ignoré** |
| `flutter analyze --no-pub` | **No issues found!**, 41,1 s |
| `git diff --check` | Réussi |
| PNG intégrés et originaux | SHA-256 inchangés par rapport au début de cette intervention |
| Autres sources et tests | Empreintes inchangées hors des neuf fichiers listés ci-dessus |

Les 17 échecs sont séparés de cette correction :

- **13 Golden historiques** : landing, path_choice, cover_solo, cover_household et signup en FR/AR ; pantry_home en FR/DE/AR. Les couvertures comprennent aussi les modifications visuelles autorisées. Aucune référence régénérée, aucune conclusion automatique que ces références sont obsolètes.
- **4 débordements historiques ES/IT à 320 px** : couvertures Solo et Famille dans les tests de phase 5. Ils restent hors du périmètre de cette intervention.

Aucun nouvel échec fonctionnel identifié. Un avertissement de variable inutilisée dans le test a été corrigé avant l'analyse finale.

## Validation visuelle et limites

Vingt comparaisons FR avant/après ont été générées et inspectées : dix variantes d'écran à 320 px et dix à 390 px. Aucune illustration coupée ni texte masqué par les icônes observé dans ces rendus. Les couleurs pastel, les blancs internes des dessins et les états sélectionnés sont conservés.

Les captures utilisent le rendu Flutter des tests avec les polices de l'application, densité 2 et viewport haut de 1500 px. Les écrans longs nécessitent un défilement ; la capture initiale ne représente pas leur totalité. Il ne s'agit pas de captures Android. La validation utilisateur sur téléphone reste à effectuer après autorisation distincte.

PLAN.md et DECISIONS.md consignent ce jalon. Aucun asset modifié, aucune règle nutritionnelle ou Supabase modifiée. Aucun commit, push ou installation Android. Phases 6B et 7 en attente. Arrêt pour validation visuelle.

## Aperçus avant/après et journaux

| Ecran | 320 px | 390 px |
|---|---|---|
| goal | [Avant/apres](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\icons_resize/goal_320_compare.png>) | [Avant/apres](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\icons_resize/goal_compare.png>) |
| activity | [Avant/apres](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\icons_resize/activity_320_compare.png>) | [Avant/apres](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\icons_resize/activity_compare.png>) |
| management_solo | [Avant/apres](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\icons_resize/management_solo_320_compare.png>) | [Avant/apres](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\icons_resize/management_solo_compare.png>) |
| management_foyer | [Avant/apres](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\icons_resize/management_foyer_320_compare.png>) | [Avant/apres](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\icons_resize/management_foyer_compare.png>) |
| cover_solo | [Avant/apres](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\icons_resize/cover_solo_320_compare.png>) | [Avant/apres](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\icons_resize/cover_solo_compare.png>) |
| cover_foyer | [Avant/apres](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\icons_resize/cover_foyer_320_compare.png>) | [Avant/apres](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\icons_resize/cover_foyer_compare.png>) |
| constraints_solo | [Avant/apres](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\icons_resize/constraints_solo_320_compare.png>) | [Avant/apres](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\icons_resize/constraints_solo_compare.png>) |
| constraints_foyer | [Avant/apres](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\icons_resize/constraints_foyer_320_compare.png>) | [Avant/apres](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\icons_resize/constraints_foyer_compare.png>) |
| pantry_solo | [Avant/apres](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\icons_resize/pantry_solo_320_compare.png>) | [Avant/apres](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\icons_resize/pantry_solo_compare.png>) |
| pantry_foyer | [Avant/apres](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\icons_resize/pantry_foyer_320_compare.png>) | [Avant/apres](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\icons_resize/pantry_foyer_compare.png>) |

[Journal targeted.log](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\icons_resize/targeted.log>)

[Journal full.log](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\icons_resize/full.log>)

[Journal analyze.log](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\icons_resize/analyze.log>)
