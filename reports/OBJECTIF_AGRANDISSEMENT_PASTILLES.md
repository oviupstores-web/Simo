# Agrandissement local des quatre pastilles Objectif — 10 octobre 2026

## Taille finale : 70 / 66 px

Pastille 70 × 70 px, illustration 66 × 66 px. Padding réduit conservé : gauche/haut/bas 8 px, ou 7 px lorsque sélectionné. Droite 16/15 px inchangée, bordures 1/2 px inchangées, écart pastille–texte 12 px. Centrage vertical maintenu. Aucun changement de PNG, couleur, texte, police, badge ou case de sélection.

Le premier essai 72/68 px n'a pas produit d'exception de débordement, mais l'inspection allemande à 320 px a révélé un défaut de lisibilité : Abnehmen était coupé en « Abnehme » puis « n ». Le repli autorisé 70/66 px corrige ce cas ; un test vérifie que ce titre reste sur une ligne dans les quatre sélections à 320 px. Les retours à la ligne ordinaires de titres composés et des descriptions sont conservés.

## Périmètre et préservation

Seul `lib/screens/onboarding/goal_screen.dart` change dans le code applicatif pendant cet agrandissement : deux valeurs de taille. Le paramètre facultatif de padding ajouté dans l'intervention précédente n'est pas modifié. Aucun changement de composant partagé supplémentaire. Activité, Gestion, contraintes alimentaires, hub Réserve et couvertures gardent leurs réglages précédents.

Tests adaptés : `test/goal_card_padding_test.dart`, `test/icon_preview_test.dart`. Empreintes SHA-256 contrôlées avant/après : aucun autre fichier préexistant de lib/test modifié pendant cette intervention, aucun PNG intégré ni original modifié.

## Contrôles

26 tests dédiés réussis à 70/66 px : toutes les sélections et cartes non sélectionnées, FR/EN/DE à 320 et 390 px, dimensions réellement rendues, padding droit, écart texte et maintien du comportement historique des autres ChoiceCard. Les six aperçus ont été inspectés : pas de débordement ni de texte masqué observé dans ce périmètre.

Tests concernés, autres écrans à icônes et navigation Solo/Famille : 143 réussites, zéro échec. Analyse Flutter sans problème. `git diff --check` réussi. Suite complète non relancée : les 17 échecs historiques connus ne sont pas corrigés ni requalifiés ici, aucune référence Golden régénérée.

Captures de tests Flutter avec polices réelles, viewport haut de 1500 px, densité 2. Aucun contrôle Android effectué pendant cette intervention.

À 320 px, agrandir la pastille réduit la largeur disponible pour les textes de 6 px. Certains titres ou descriptions occupent davantage de lignes : en français Maintien passe de 100 à 142 px de hauteur, et Perte de poids de 124 à 142 px. Ce changement vient du contenu intégral conservé, sans réduction de police. À 390 px, les cartes dominées par la pastille passent de 82 à 88 px ; Prise de masse reste à 100 px.

Les espaces haut/bas réels incluent toujours le vide lié au centrage face à un texte plus haut que la pastille. Le padding demandé est respecté, mais ce vide n'est pas supprimé.

PLAN.md et DECISIONS.md consignent le réglage et l'attente de validation visuelle. Aucun commit, push, installation Android ou démarrage de phase 6B/7.

## Mesures finales et comparaisons

Toutes les valeurs sont en pixels logiques Flutter. Hauteur totale des cartes, bordures incluses ; espaces mesurés entre bord intérieur de carte et bord extérieur de pastille. N/S = non sélectionnée / sélectionnée. La pastille réellement rendue est de 70 px, l'image de 66 px et l'écart pastille–texte de 12 px dans toutes les lignes.

### FR

| Largeur | Carte | Hauteur avant / finale | Gauche N/S | Haut N/S | Bas N/S |
|---|---|---:|---:|---:|---:|
| 320 | Perte de poids | 124 / 142 | 8/7 | 35/34 | 35/34 |
| 320 | Prise de masse | 118 / 118 | 8/7 | 23/22 | 23/22 |
| 320 | Sèche & Définition | 100 / 100 | 8/7 | 14/13 | 14/13 |
| 320 | Maintien & Équilibre | 100 / 142 | 8/7 | 35/34 | 35/34 |
| 390 | Perte de poids | 82 / 88 | 8/7 | 8/7 | 8/7 |
| 390 | Prise de masse | 100 / 100 | 8/7 | 14/13 | 14/13 |
| 390 | Sèche & Définition | 82 / 88 | 8/7 | 8/7 | 8/7 |
| 390 | Maintien & Équilibre | 82 / 88 | 8/7 | 8/7 | 8/7 |

[Avant/apres FR 320 px](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\goal_72/fr_320_compare.png>) - [Avant/apres FR 390 px](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\goal_72/fr_390_compare.png>)

### EN

| Largeur | Carte | Hauteur avant / finale | Gauche N/S | Haut N/S | Bas N/S |
|---|---|---:|---:|---:|---:|
| 320 | Weight loss | 142 / 142 | 8/7 | 35/34 | 35/34 |
| 320 | Building muscle | 100 / 100 | 8/7 | 14/13 | 14/13 |
| 320 | Cutting & definition | 100 / 124 | 8/7 | 26/25 | 26/25 |
| 320 | Staying steady | 100 / 100 | 8/7 | 14/13 | 14/13 |
| 390 | Weight loss | 100 / 100 | 8/7 | 14/13 | 14/13 |
| 390 | Building muscle | 82 / 88 | 8/7 | 8/7 | 8/7 |
| 390 | Cutting & definition | 82 / 88 | 8/7 | 8/7 | 8/7 |
| 390 | Staying steady | 82 / 88 | 8/7 | 8/7 | 8/7 |

[Avant/apres EN 320 px](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\goal_72/en_320_compare.png>) - [Avant/apres EN 390 px](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\goal_72/en_390_compare.png>)

### DE

| Largeur | Carte | Hauteur avant / finale | Gauche N/S | Haut N/S | Bas N/S |
|---|---|---:|---:|---:|---:|
| 320 | Abnehmen | 118 / 118 | 8/7 | 23/22 | 23/22 |
| 320 | Muskelaufbau | 118 / 118 | 8/7 | 23/22 | 23/22 |
| 320 | Definition | 100 / 100 | 8/7 | 14/13 | 14/13 |
| 320 | Halten & Balance | 118 / 136 | 8/7 | 32/31 | 32/31 |
| 390 | Abnehmen | 82 / 100 | 8/7 | 14/13 | 14/13 |
| 390 | Muskelaufbau | 100 / 100 | 8/7 | 14/13 | 14/13 |
| 390 | Definition | 82 / 88 | 8/7 | 8/7 | 8/7 |
| 390 | Halten & Balance | 100 / 100 | 8/7 | 14/13 | 14/13 |

[Avant/apres DE 320 px](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\goal_72/de_320_compare.png>) - [Avant/apres DE 390 px](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\goal_72/de_390_compare.png>)

[Essai 72/68 px allemand a 320 px, non retenu](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\goal_72/after/de_320.png>)

[Tests de regression](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\goal_72/regressions.log>) - [Analyse Flutter](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\goal_72/analyze.log>)
