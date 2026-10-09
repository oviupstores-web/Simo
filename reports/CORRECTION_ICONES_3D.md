# Correction visuelle des 23 icônes — 9 octobre 2026

## Résultat et périmètre

23 copies remplacées par des PNG RGBA de 256 × 256 px, avec transparence extérieure réelle. Les originaux sont inchangés, vérifiés par SHA-256. Les chemins Flutter et pubspec.yaml restent inchangés pour cette correction.

Sept fichiers d'écran ajustés localement : goal_screen.dart, activity_screen.dart, management_mode_screen.dart, cover_solo_screen.dart, cover_household_screen.dart, constraints_screen.dart, pantry_hub_onboarding_screen.dart. Le test icon_preview_test.dart vérifie les tailles rendues, les assets attendus, BoxFit.contain, le format RGBA, les quatre coins transparents, les pixels opaques et les pixels semi-transparents. Aucun composant partagé, texte, couleur, interaction, formule ou règle métier modifié.

## Détourage et dimensions

Traitement déterministe depuis chaque original : masque extérieur relié aux bords, séparation des zones neutres du contour coloré, restitution des ombres grises par alpha et retrait de leur composante blanche. Les blancs enfermés dans le dessin restent opaques. Aucun effacement global du blanc, aucune génération d'une nouvelle illustration. Les transparences extérieures inférieures à 5/255 sont éliminées pour retirer le bruit presque invisible. Recadrage sur l'enveloppe alpha, proportions conservées, côté maximal de 252 px centré dans un canevas de 256 px, réduction Lanczos.

Les contours et ombres ont été contrôlés visuellement sur pastel. Aucun carré blanc extérieur ni halo blanc parasite observé aux tailles d'affichage. Les blancs internes du lait, de la toque et des dessins sont conservés. Certaines images étaient déjà proches des bords dans l'original : aucun détail supplémentaire n'a été reconstitué.

| Usage | Pastille inchangée | Image avant → après | Occupation maximale après recadrage |
|---|---:|---:|---:|
| Objectif et activité | 56 px | 40 → 52 px | environ 91 % |
| Gestion Solo/Famille | 56 px | 36 â†’ 52 px | environ 91 % |
| Couverture Solo | 56 px | 36 â†’ 52 px | environ 91 % |
| Couverture Famille, Zéro gaspillage seulement | 56 px | 28 → 52 px | environ 91 % |
| Contraintes alimentaires | 40 px | 40 â†’ 36 px | environ 89 % |
| Hub, Ma réserve | 56 px | 26 → 52 px | environ 91 % |
| Hub, Vérification rapide | 48 px | 24 → 44 px | environ 90 % |

Exception explicitée : les sept images alimentaires occupaient déjà presque toute une pastille de 40 px. Elles ne sont pas agrandies ; le cadrage transparent et le centrage sont corrigés, avec environ 2 px de marge. Une taille supérieure compromettrait la marge demandée sans agrandir le conteneur. Les autres illustrations sont sensiblement agrandies. Les dimensions externes, les bordures et les états sélectionnés sont conservés.

## Vérifications

- Avant : 113 tests ciblés réussis, capture des dix variantes d'écran avec les copies opaques.
- Premier passage après : 90 tests d'écran réussis, 23 assertions de format encore RGB en échec attendu. Assertions ensuite adaptées au RGBA et complétées par décodage des pixels alpha.
- Dernier passage ciblé : **113 réussites, 0 échec**, dont FR/EN/DE à 320 et 390 px ; ES/IT/AR à 390 px.
- Suite complète : **934 réussites, 17 échecs historiques, aucun test ignoré**. Navigation Solo/Famille et régressions des phases 1 à 5 incluses.
- `flutter analyze --no-pub` : **No issues found!**, dernier passage 6,3 s.
- `git diff --check` : réussi.

Les 13 Golden toujours en échec sont : landing, path_choice, cover_solo, cover_household, signup en FR et AR (10), pantry_home en FR/DE/AR (3). Ils ne sont pas actualisés. Les couvertures qui utilisent ces icônes ont désormais aussi la différence visuelle autorisée ; leurs différences complètes restent à valider en phase 6B.

Les quatre débordements historiques : couvertures Solo/Famille en ES/IT à 320 px, tests de phase 5. Aucun de ces défauts n'est corrigé dans cette intervention.

## Aperçus et limites

Les dix comparaisons avant/après à 390 px ont été inspectées, ainsi que les captures corrigées à 320 px. Les captures proviennent du rendu Flutter des tests avec les polices de l'application, à densité 2, sans téléphone. Le viewport de diagnostic mesure 1500 px de haut : ces aperçus ne constituent pas une vérification Android réelle ni une validation du défilement de l'intégralité d'un long écran.

Les fichiers de preuve et journaux sont conservés hors du dépôt dans le dossier de visualisations lié ci-dessous. Les Golden de référence sont inchangés. Les comparaisons portent sur la version opaque immédiatement précédente et la version transparente corrigée.

Les phases 6B et 7 restent en attente. Aucun commit, push, installation Android ou modification Supabase. Validation visuelle de Simo attendue.

## Inventaire détaillé et liens de preuve

| Original intact | Copie RGBA | Dimensions | Poids en octets | Detourage |
|---|---|---|---:|---|
| icone perte de poids.png | goal_loss.png | 256 x 256 | 88809 | Valide visuellement ; blancs internes preserves |
| icone prise de masse.png | goal_gain.png | 256 x 256 | 108391 | Valide visuellement ; blancs internes preserves |
| icone sèche et définition.png | goal_definition.png | 256 x 256 | 109546 | Valide visuellement ; blancs internes preserves |
| icone maintien et équilibre.png | goal_balance.png | 256 x 256 | 107617 | Valide visuellement ; blancs internes preserves |
| icone sédentaire .png | activity_desk.png | 256 x 256 | 100187 | Valide visuellement ; blancs internes preserves |
| icone modéré.png | activity_walk.png | 256 x 256 | 119460 | Valide visuellement ; blancs internes preserves |
| icone actif.png | activity_run.png | 256 x 256 | 105942 | Valide visuellement ; blancs internes preserves |
| icone tres actif.png | activity_training.png | 256 x 256 | 105780 | Valide visuellement ; blancs internes preserves |
| icone courses uniquement.png | management_shopping.png | 256 x 256 | 104800 | Valide visuellement ; blancs internes preserves |
| icone reserve uniquement.png | management_pantry.png | 256 x 256 | 121502 | Valide visuellement ; blancs internes preserves |
| icone mixte.png | management_mixed.png | 256 x 256 | 120664 | Valide visuellement ; blancs internes preserves |
| Icone Adapté à votre temps.png | solo_time.png | 256 x 256 | 59034 | Valide visuellement ; blancs internes preserves |
| Icone Calories et macros calculés.png | solo_nutrition.png | 256 x 256 | 68041 | Valide visuellement ; blancs internes preserves |
| icone Zero gaspillage.png | solo_waste.png | 256 x 256 | 74409 | Valide visuellement ; blancs internes preserves |
| icone omnivore.png | diet_omnivore.png | 256 x 256 | 120932 | Valide visuellement ; blancs internes preserves |
| icone végétarien.png | diet_vegetarian.png | 256 x 256 | 112330 | Valide visuellement ; blancs internes preserves |
| icone végan.png | diet_vegan.png | 256 x 256 | 123071 | Valide visuellement ; blancs internes preserves |
| icone pescétarien.png | diet_pescatarian.png | 256 x 256 | 127585 | Valide visuellement ; blancs internes preserves |
| icone sans porc.png | diet_no_pork.png | 256 x 256 | 105620 | Valide visuellement ; blancs internes preserves |
| icone sans lactose.png | diet_no_lactose.png | 256 x 256 | 88992 | Valide visuellement ; blancs internes preserves |
| icone sans gluten.png | diet_no_gluten.png | 256 x 256 | 106987 | Valide visuellement ; blancs internes preserves |
| icone ma reserve.png | pantry_reserve.png | 256 x 256 | 116783 | Valide visuellement ; blancs internes preserves |
| icone vérification rapide.png | pantry_quick_check.png | 256 x 256 | 87237 | Valide visuellement ; blancs internes preserves |

Poids total des copies : 2,383,719 octets, contre 2,131,899 avant correction (+11.81 %). Originaux : 41,059,971 octets. Les 256 px couvrent plus de quatre pixels physiques par pixel logique pour une image de 52 px.

[Planche des 23 icones avant/apres](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\icons_correction/23_icones_pastels_avant_apres.png>)

- [Comparaison goal a 390 px](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\icons_correction/goal_compare.png>) ; [rendu corrige a 320 px](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980/icons_integration/transparent/goal_320.png>).
- [Comparaison activity a 390 px](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\icons_correction/activity_compare.png>) ; [rendu corrige a 320 px](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980/icons_integration/transparent/activity_320.png>).
- [Comparaison management_solo a 390 px](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\icons_correction/management_solo_compare.png>) ; [rendu corrige a 320 px](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980/icons_integration/transparent/management_solo_320.png>).
- [Comparaison management_foyer a 390 px](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\icons_correction/management_foyer_compare.png>) ; [rendu corrige a 320 px](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980/icons_integration/transparent/management_foyer_320.png>).
- [Comparaison cover_solo a 390 px](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\icons_correction/cover_solo_compare.png>) ; [rendu corrige a 320 px](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980/icons_integration/transparent/cover_solo_320.png>).
- [Comparaison cover_foyer a 390 px](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\icons_correction/cover_foyer_compare.png>) ; [rendu corrige a 320 px](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980/icons_integration/transparent/cover_foyer_320.png>).
- [Comparaison constraints_solo a 390 px](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\icons_correction/constraints_solo_compare.png>) ; [rendu corrige a 320 px](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980/icons_integration/transparent/constraints_solo_320.png>).
- [Comparaison constraints_foyer a 390 px](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\icons_correction/constraints_foyer_compare.png>) ; [rendu corrige a 320 px](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980/icons_integration/transparent/constraints_foyer_320.png>).
- [Comparaison pantry_solo a 390 px](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\icons_correction/pantry_solo_compare.png>) ; [rendu corrige a 320 px](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980/icons_integration/transparent/pantry_solo_320.png>).
- [Comparaison pantry_foyer a 390 px](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\icons_correction/pantry_foyer_compare.png>) ; [rendu corrige a 320 px](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980/icons_integration/transparent/pantry_foyer_320.png>).

[Journal icons_correction_after.log](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\icons_correction\icons_correction_after.log>)

[Journal icons_correction_analyze.log](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\icons_correction\icons_correction_analyze.log>)

[Journal icons_correction_before.log](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\icons_correction\icons_correction_before.log>)

[Journal icons_correction_full.log](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\icons_correction\icons_correction_full.log>)
