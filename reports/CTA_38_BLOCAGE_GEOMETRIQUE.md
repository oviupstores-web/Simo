# CTA 38 px — blocage géométrique avant validation

## État final

Correction non appliquée : arrêt conformément aux consignes de Simo en cas de collision. Un essai limité au composant local a été rendu dans Flutter, puis rétabli à l’identique. Toutes les empreintes lib/assets sont identiques à celles du début de cette intervention. CaliScan minimum 240 px, son smartphone et ses indicateurs, les textes, images, pastilles, boutons, navigation et autres cartes sont préservés. Le composant d’animation antérieur est conservé, sans prétendre qu’il est validé.

Seul nouveau fichier conservé dans le projet pour cette intervention : reports/CTA_38_BLOCAGE_GEOMETRIQUE.md. Code de l’essai et test diagnostique conservés hors dépôt dans le dossier de preuves. Aucun commit, push ou installation.

## Causes identifiées

- Le contour de la main précédente dépasse à gauche de sa zone de peinture : coordonnées x = -1,048 à 24,277, y = 11,732 à 42,222 au repos, pour une zone 38 × 48. Le contour n’est donc pas entièrement contenu dans le canevas déclaré. Les cercles précédents peuvent dépasser jusqu’à x = -5,5. Ce dépassement est mesuré ; il ne prouve pas à lui seul que chaque capture ou appareil rogne la main. Le poignet est dans la hauteur de cette zone dans le cas mesuré. Aucune reproduction Android effectuée.
- Les dernières captures CaliScan désactivaient explicitement les animations via MediaQuery.disableAnimations dans caliscan_targeted_test.dart. Le composant impose alors progress = 0 ; ses cercles sont dessinés seulement après progress > 0,3. Leur absence sur ces captures est donc expliquée directement par ce mode de capture, pas par une preuve que le timer ne fonctionne pas.
- Dans le composant précédent, les cercles sont peints avant le remplissage blanc de la main ; la silhouette masque une partie des ondes. L’essai a utilisé un foregroundPainter indépendant pour empêcher ce masquage.

## Essai réel et blocage

L’essai utilise la même silhouette, avec une hauteur de 38 px contour compris, sans compression ni réduction automatique ; la silhouette remplie mesure environ 37,09 px de haut et 30,66 px de large. Le mouvement est une translation réelle de 3 px. Une zone de dessin 64 × 76 contient les rotations, le poignet et les ondes. Les cartes gardent leur clipping. Les trois diamètres maximaux prévus sont 12 / 20 / 28 px ; apparition successive en couche indépendante, même point de contact, expansion et fondu. Clic 600 ms, pause 3000 ms ; décalages conservés.

Avec les pastilles et espacements actuels, les cercles en premier plan recouvrent la fin des libellés des pastilles, visible dans les captures de Menus et Courses. À 320 et 390, la silhouette intersecte également les boîtes typographiques de leurs titres. Cette mesure représente la zone de mise en page du texte, pas une affirmation que chaque pixel de lettre est recouvert ; elle ne laisse pas de marge de sécurité pour conserver l’espacement actuel.

| CTA | 320 px : intersection main / zone titre | 390 px : intersection main / zone titre |
|---|---|---|
| Instant Recipe AI | Non | Non |
| CaliScan AI | Non | Non |
| Menus | Oui : Votre semaine / déjà organisée | Oui : Votre semaine / déjà organisée |
| Courses | Oui : Des courses claires et optimisées | Oui : Des courses claires et optimisées |

Les captures proviennent des vrais contrôleurs Flutter, pendant la pression (progress entre 0,44 et 0,49), avec les décalages réels. Aucun peintre de substitution ni synchronisation forcée dans ces captures. Les trois captures finales demandées par CTA ne sont pas présentées comme réalisées : l’essai a été arrêté dès confirmation du blocage.

## Autorisation nécessaire

Pour poursuivre sans réduire la cible de 38 px, autoriser une réserve locale autour des CTA : davantage de marge à droite du texte de la pastille pour accueillir les ondes de 28 px, et davantage d’espace sous les pastilles de Menus/Courses pour dégager le poignet du titre. Cela dépasse les garde-fous actuels sur les pastilles, textes en place et cartes. Les mesures finales seraient vérifiées avant toute validation. Aucun ajustement de ce type n’a été appliqué.

## Vérifications

Deux tests diagnostiques Flutter réussis : ils enregistrent les géométries et capturent le blocage, ils ne valident pas une correction. Après restauration, 17 tests CaliScan/CTA réussis. flutter analyze --no-pub : No issues found!. git diff --check : réussi. Aucun test existant modifié dans cette intervention.

## Preuves

- [Gros plan menus à 320 px](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\cta_38_audit\320_menus_collision.png>).
- [Rendu Flutter entier menus à 320 px](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\cta_38_audit\320_menus.png>).

- [Gros plan shopping à 320 px](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\cta_38_audit\320_shopping_collision.png>).
- [Rendu Flutter entier shopping à 320 px](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\cta_38_audit\320_shopping.png>).

- [Gros plan menus à 390 px](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\cta_38_audit\390_menus_collision.png>).
- [Rendu Flutter entier menus à 390 px](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\cta_38_audit\390_menus.png>).

- [Gros plan shopping à 390 px](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\cta_38_audit\390_shopping_collision.png>).
- [Rendu Flutter entier shopping à 390 px](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\cta_38_audit\390_shopping.png>).

[Mesures 320](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\cta_38_audit\320.json>) · [Mesures 390](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\cta_38_audit\390.json>).
