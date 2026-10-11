# Réduction locale du padding Objectif — 10 octobre 2026

## Modification appliquée

Uniquement sur les quatre ChoiceCard de GoalScreen : gauche/haut/bas 8 px, ou 7 px lorsque sélectionné ; droite 16 px, ou 15 px lorsque sélectionné. Bordures 1/2 px inchangées. L'écart pastille–texte reste à 12 px, la pastille à 64 px et l'image à 60 px. Centrage vertical, polices, textes, badges, couleurs, indicateurs et logique de sélection inchangés.

ChoiceCard reçoit un paramètre optionnel `padding`, utilisé seulement par GoalScreen. Sans ce paramètre, son comportement historique reste strictement identique : padding uniforme de 16/15 px. Aucune modification globale des cartes des autres écrans.

## Méthode

Mesures des rectangles réellement rendus par Flutter, polices Plus Jakarta Sans/Readex Pro chargées, densité 1 pour les mesures, captures à densité 2, viewport de 320/390 × 1500 pixels logiques. Les espaces gauche/haut/bas sont mesurés entre le bord intérieur de la carte et le bord extérieur de la pastille, bordure soustraite. Aucune mesure des transparences du PNG ou du padding intérieur de la pastille dans ces tableaux.

24 variantes d'écran : trois langues, deux largeurs et quatre objectifs sélectionnés successivement. Chaque variante vérifie les quatre cartes : 96 observations de cartes, couvrant tous les états. Les dimensions restent stables lors du passage sélectionné/non sélectionné, grâce à la compensation de bordure.

## Résultats et limites

- Avant correction : 24 variantes réussies et six captures de référence.
- Après correction : 26 tests dédiés réussis, dont deux contrôles du padding historique des autres ChoiceCard.
- Tests concernés, icônes et parcours Solo/Famille : **143 réussites, zéro échec**.
- `flutter analyze --no-pub` : **No issues found!**, 18,8 s.
- `git diff --check` : réussi.
- Les six comparaisons FR/EN/DE ont été inspectées. Aucun débordement ou texte masqué observé dans ce périmètre.
- Empreintes des PNG intégrés et des originaux inchangées. Les seuls fichiers préexistants de code modifiés sont GoalScreen et ChoiceCard.
- Suite complète non relancée : les 17 échecs historiques connus (13 Golden et quatre débordements ES/IT) ne sont ni corrigés ni requalifiés ici. Aucune référence Golden mise à jour.

La hauteur reste déterminée par le texte et la pastille. Lorsque le bloc de texte dépasse 64 px, les espaces haut/bas réels dépassent 8/7 px. À 320 px en français, le texte de Maintien gagne une ligne de titre et une ligne de description, ce qui réduit la hauteur de 158 à 100 px ; Perte de poids passe de 158 à 124 px. À 390 px, les quatre cartes perdent 16 px de hauteur. Aucun texte ni taille de police modifié pour obtenir ces résultats.

Captures de tests Flutter, sans contrôle Android réel. Validation visuelle de Simo attendue. Aucun commit, push, installation Android, modification Supabase ou démarrage de phase 6B/7.

Fichiers : `lib/screens/onboarding/goal_screen.dart`, `lib/widgets/selectable_card.dart`, nouveau `test/goal_card_padding_test.dart`, ce rapport ; PLAN.md et DECISIONS.md consignent le jalon.

## Mesures exactes avant/après et aperçus

Dans les tableaux suivants : **N = non sélectionnée, S = sélectionnée**. Toutes les valeurs sont en pixels logiques. La hauteur totale de carte inclut les bordures. Les autres mesures les excluent.

### FR

| Largeur | Carte | Hauteur avant / apres | Gauche N/S | Haut N/S | Bas N/S | Pastille / image | Ecart texte |
|---|---|---:|---:|---:|---:|---:|---:|
| 320 | Perte de poids | 158 / 124 | 8/7 | 29/28 | 29/28 | 64 / 60 | 12 |
| 320 | Prise de masse | 134 / 118 | 8/7 | 26/25 | 26/25 | 64 / 60 | 12 |
| 320 | Sèche & Définition | 116 / 100 | 8/7 | 17/16 | 17/16 | 64 / 60 | 12 |
| 320 | Maintien & Équilibre | 158 / 100 | 8/7 | 17/16 | 17/16 | 64 / 60 | 12 |
| 390 | Perte de poids | 98 / 82 | 8/7 | 8/7 | 8/7 | 64 / 60 | 12 |
| 390 | Prise de masse | 116 / 100 | 8/7 | 17/16 | 17/16 | 64 / 60 | 12 |
| 390 | Sèche & Définition | 98 / 82 | 8/7 | 8/7 | 8/7 | 64 / 60 | 12 |
| 390 | Maintien & Équilibre | 98 / 82 | 8/7 | 8/7 | 8/7 | 64 / 60 | 12 |

[Comparaison FR 320 px](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\goal_padding/fr_320_compare.png>) - [Comparaison FR 390 px](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\goal_padding/fr_390_compare.png>)

### EN

| Largeur | Carte | Hauteur avant / apres | Gauche N/S | Haut N/S | Bas N/S | Pastille / image | Ecart texte |
|---|---|---:|---:|---:|---:|---:|---:|
| 320 | Weight loss | 158 / 142 | 8/7 | 38/37 | 38/37 | 64 / 60 | 12 |
| 320 | Building muscle | 116 / 100 | 8/7 | 17/16 | 17/16 | 64 / 60 | 12 |
| 320 | Cutting & definition | 140 / 100 | 8/7 | 17/16 | 17/16 | 64 / 60 | 12 |
| 320 | Staying steady | 134 / 100 | 8/7 | 17/16 | 17/16 | 64 / 60 | 12 |
| 390 | Weight loss | 116 / 100 | 8/7 | 17/16 | 17/16 | 64 / 60 | 12 |
| 390 | Building muscle | 98 / 82 | 8/7 | 8/7 | 8/7 | 64 / 60 | 12 |
| 390 | Cutting & definition | 98 / 82 | 8/7 | 8/7 | 8/7 | 64 / 60 | 12 |
| 390 | Staying steady | 98 / 82 | 8/7 | 8/7 | 8/7 | 64 / 60 | 12 |

[Comparaison EN 320 px](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\goal_padding/en_320_compare.png>) - [Comparaison EN 390 px](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\goal_padding/en_390_compare.png>)

### DE

| Largeur | Carte | Hauteur avant / apres | Gauche N/S | Haut N/S | Bas N/S | Pastille / image | Ecart texte |
|---|---|---:|---:|---:|---:|---:|---:|
| 320 | Abnehmen | 158 / 118 | 8/7 | 26/25 | 26/25 | 64 / 60 | 12 |
| 320 | Muskelaufbau | 134 / 118 | 8/7 | 26/25 | 26/25 | 64 / 60 | 12 |
| 320 | Definition | 116 / 100 | 8/7 | 17/16 | 17/16 | 64 / 60 | 12 |
| 320 | Halten & Balance | 152 / 118 | 8/7 | 26/25 | 26/25 | 64 / 60 | 12 |
| 390 | Abnehmen | 116 / 82 | 8/7 | 8/7 | 8/7 | 64 / 60 | 12 |
| 390 | Muskelaufbau | 116 / 100 | 8/7 | 17/16 | 17/16 | 64 / 60 | 12 |
| 390 | Definition | 98 / 82 | 8/7 | 8/7 | 8/7 | 64 / 60 | 12 |
| 390 | Halten & Balance | 116 / 100 | 8/7 | 17/16 | 17/16 | 64 / 60 | 12 |

[Comparaison DE 320 px](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\goal_padding/de_320_compare.png>) - [Comparaison DE 390 px](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\goal_padding/de_390_compare.png>)

[Journal regressions.log](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\goal_padding/regressions.log>)

[Journal analyze.log](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\goal_padding/analyze.log>)
