# CaliScan AI — correction strictement ciblée

## Modifications

Un seul fichier applicatif modifié pendant cette intervention : lib/screens/entry/landing_screen.dart. Nouveau test : test/caliscan_targeted_test.dart. Nouveau rapport : reports/CALISCAN_CORRECTION_CIBLEE.md. Aucun fichier de traduction, PNG, autre écran ou composant d’animation modifié. Les empreintes SHA-256 des fichiers lib/assets sont vérifiées avant/après.

La carte CaliScan utilise une hauteur minimale locale de 240 px ; la hauteur proportionnelle existante est conservée si elle est supérieure. Paramètre facultatif minimumHeight sur _FunctionCard, utilisé seulement par CaliScan ; comportement par défaut inchangé pour les autres cartes.

Son image conserve BoxFit.contain avec 12 px de marge verticale. Le ShaderMask qui atténuait le bord gauche de cette illustration est retiré. Ses badges nutritionnels gardent leur largeur et leur style ; ils sont alignés au bord droit de la zone d’illustration pour dégager le téléphone. Le même PNG 1254 × 1254 est conservé. L’image entière tient dans la carte, avec sa proportion d’origine.

Les descriptions actuelles satisfont déjà la borne langue par langue. Aucun ajout de texte nécessaire ; aucun texte modifié, y compris les intitulés CaliScan AI / Scannez votre repas. Les compteurs portent sur les caractères Unicode, espaces et ponctuation inclus.

## Comptage des descriptions

| Langue | Instant Recipe AI | CaliScan AI | Conforme |
|---|---|---|---|
| FR | 120 | 72 | Oui |
| EN | 98 | 59 | Oui |
| DE | 131 | 77 | Oui |
| ES | 100 | 72 | Oui |
| IT | 110 | 73 | Oui |

## Dimensions mesurées de CaliScan

Pixels logiques Flutter. La largeur de carte ne change pas. Les dimensions « image peinte » concernent le PNG carré entier ; le téléphone occupe une partie de ce PNG transparent. L’espace disponible est la boîte de rendu de l’image avant application de BoxFit.contain.

| Langue | Écran | Largeur carte | Hauteur avant → après | Image peinte avant → après | Hauteur disponible avant → après |
|---|---|---|---|---|---|
| FR | 320 | 292.00 | 185.28 → 240.00 | 143.74 × 143.74 → 143.74 × 143.74 | 182.98 → 213.70 |
| FR | 390 | 362.00 | 169.15 → 240.00 | 166.35 × 166.35 → 175.19 × 175.19 | 166.35 → 213.19 |
| EN | 320 | 292.00 | 164.28 → 240.00 | 143.74 × 143.74 → 143.74 × 143.74 | 161.98 → 213.70 |
| EN | 390 | 362.00 | 169.15 → 240.00 | 166.35 × 166.35 → 175.19 × 175.19 | 166.35 → 213.19 |
| DE | 320 | 292.00 | 206.28 → 240.00 | 143.74 × 143.74 → 143.74 × 143.74 | 203.98 → 213.70 |
| DE | 390 | 362.00 | 190.15 → 240.00 | 175.19 × 175.19 → 175.19 × 175.19 | 187.35 → 213.19 |
| ES | 320 | 292.00 | 206.28 → 240.00 | 143.74 × 143.74 → 143.74 × 143.74 | 203.98 → 213.70 |
| ES | 390 | 362.00 | 169.15 → 240.00 | 166.35 × 166.35 → 175.19 × 175.19 | 166.35 → 213.19 |
| IT | 320 | 292.00 | 185.28 → 240.00 | 143.74 × 143.74 → 143.74 × 143.74 | 182.98 → 213.70 |
| IT | 390 | 362.00 | 169.15 → 240.00 | 166.35 × 166.35 → 175.19 × 175.19 | 166.35 → 213.19 |

## Garde-fous et tests

- 10 cas CaliScan FR/EN/DE/ES/IT à 320/390 : tests avant et après, descriptions bornées, contenu de l’image entièrement dans la carte, absence d’overflow.
- 7 tests CTA existants : navigation unique de Menus/Courses, rendu, absence de navigation automatique, préférences système, timing et cycle de vie. Les 17 tests passent ensemble.
- flutter analyze --no-pub : No issues found!. git diff --check : réussi.
- Les dimensions des cartes Instant Recipe AI, Menus, Courses et Suivi sont identiques dans les dix relevés avant/après (40 comparaisons). Leurs positions verticales après CaliScan descendent naturellement du fait de sa hauteur ; leurs hauteurs, images, cadrages et textes ne changent pas.
- Suivi conserve son état informatif : aucun gestionnaire de clic, aucune main ni animation CTA. Le code de navigation, le bouton Commencer et le composant partagé de main restent inchangés.
- Aucune traduction modifiée. Les cinq descriptions CaliScan sont conservées telles quelles.
- La première régression de navigation a révélé un débordement de badges CaliScan à la largeur de test 800 px lorsque la hauteur était fixée à 240 : corrigé localement en conservant la hauteur proportionnelle supérieure. Aucun changement des cartes voisines. Les avertissements d’accolades du nouveau test sont résolus.

## Captures

Les animations sont désactivées dans les captures de comparaison pour stabiliser le rendu ; leur fonctionnement reste couvert par les tests CTA existants. Les titres et le téléphone sont visibles sans collision dans les cas inspectés FR/EN/DE à 320/390. Les dix cas automatisés couvrent aussi ES/IT.

[Aperçu FR 320 et 390](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\caliscan_cible\caliscan_320_390.png>)

| Format | Carte corrigée | Avant/après |
|---|---|---|
| FR 320 | [Voir](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\caliscan_cible\caliscan_320.png>) | [Comparer](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\caliscan_cible\comparaison_320.png>) |
| FR 390 | [Voir](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\caliscan_cible\caliscan_390.png>) | [Comparer](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\caliscan_cible\comparaison_390.png>) |

| Langue | Landing après à 320 | Landing après à 390 |
|---|---|---|
| FR | [Capture](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\caliscan_cible\after\fr_320.png>) | [Capture](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\caliscan_cible\after\fr_390.png>) |
| EN | [Capture](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\caliscan_cible\after\en_320.png>) | [Capture](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\caliscan_cible\after\en_390.png>) |
| DE | [Capture](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\caliscan_cible\after\de_320.png>) | [Capture](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\caliscan_cible\after\de_390.png>) |
| ES | [Capture](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\caliscan_cible\after\es_320.png>) | [Capture](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\caliscan_cible\after\es_390.png>) |
| IT | [Capture](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\caliscan_cible\after\it_320.png>) | [Capture](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\caliscan_cible\after\it_390.png>) |

## Arrêt

Aucun commit, push ou installation Android. Pas de refonte, ni phase 6B/7. Validation visuelle attendue.
