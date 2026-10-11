# CTA 38 px — ondes sous le doigt

## Correction appliquée

La silhouette blanche de la référence est conservée, avec une hauteur vectorielle de **38 px contour inclus** (largeur environ 31,6 px contour inclus). Elle conserve son inclinaison finale d’environ 25° à gauche. La zone technique de peinture est 64 × 76 px ; elle contient le contour, le poignet, les ondes et le déplacement de 3 px. Aucun clipping de carte modifié.

Trois cercles concentriques sont peints par un CustomPainter indépendant **derrière la main**. La pastille reste également devant la portion des ondes qui traverserait son libellé : le texte demeure lisible. Il y a donc trois cercles dessinés, avec les portions naturellement masquées par le doigt et la pastille. Aucun trait de clic ni ripple standard ajouté. Diamètres maximaux : **12 / 20 / 28 px**, contour noir fin de 0,75 px.

La main descend réellement de 3 px, reste brièvement au contact, puis remonte. Cycle de 600 ms, pause de 3000 ms. Les cercles commencent à 180 / 216 / 252 ms, s’agrandissent et s’effacent. Les quatre décalages initiaux sont conservés, adaptés au cycle de 3600 ms : 0 / 828 / 1656 / 2484 ms. Les préférences disableAnimations et accessibleNavigation immobilisent la main et suppriment les ondes. Timers et contrôleurs sont arrêtés et libérés au dispose ; aucun événement de navigation n’est généré par l’animation.

## Pourquoi les captures précédentes posaient problème

1. L’ancienne silhouette débordait de sa zone de peinture déclarée : x minimal -1,048 px au repos, pour un canevas 38 × 48. Les ondes débordaient aussi à gauche. La nouvelle zone contient l’intégralité du dessin. Le diagnostic précédent établissait le dépassement, sans prouver à lui seul chaque découpage observé sur un appareil ; aucune installation Android n’a été faite ici.
2. Les captures de CaliScan utilisaient disableAnimations=true : progress était fixé à zéro, ce qui retirait les ondes. Les nouvelles captures gardent les animations actives et suivent les vrais contrôleurs Flutter.
3. L’essai qui mettait les ondes devant la main recouvrait les libellés. La consigne de Simo les place désormais derrière le doigt ; la pastille protège également son texte.
4. Le premier contrôle de collision avec les titres était trop conservateur : il utilisait les boîtes typographiques, qui incluent des espaces autour des lettres. Un contrôle des pixels réellement peints confirme que les lettres restent intactes, permettant de garder les cartes sans augmentation d’espacement.

## Périmètre préservé

Empreintes vérifiées : seul lib/screens/entry/landing_badge_cta.dart change dans lib/assets pendant cette correction. landing_screen.dart, les PNG, les traductions, les images, les indicateurs et la navigation sont inchangés. Les 24 relevés de cartes correspondent exactement aux géométries antérieures à 320/390 px. CaliScan conserve son minimum de 240 px et le même smartphone. Suivi garde zéro main, zéro onde et aucune nouvelle interaction. Aucun composant partagé hors Landing modifié.

Fichiers de cette intervention :
- lib/screens/entry/landing_badge_cta.dart ;
- test/landing_cta_test.dart : attentes de la zone de dessin et dossier de captures actualisés ;
- test/cta_38_animation_test.dart : nouveau contrôle des phases, du dessin contenu et des pixels des lettres ;
- reports/CTA_38_ONDES_SOUS_DOIGT.md.

## Vérifications

**22 tests ciblés réussis** : captures/contrôles des CTA, navigation et préférences système, régressions CaliScan dans les cinq langues et deux tests couvrant 24 phases réelles des quatre CTA à 320/390 px. **21 057 pixels centraux de glyphes vérifiés, zéro pixel masqué**. Cette vérification porte sur les pixels pleins de la couleur des lettres, pas sur l’intégralité de leur contour anticrénelé ; les gros plans complètent le contrôle visuel.

La totalité du contour de la main est dans la zone technique et dans sa carte au repos, à la pression maximale et au retour. Le déplacement est borné, sans rebond ni dépassement entre ces positions. Analyse statique : No issues found! (9,0 s). git diff --check : réussi. Suite complète et Golden non relancés pour cette correction locale.

Les captures livrées proviennent du véritable rendu Flutter : aucun progress imposé au peintre. Le test attend que chaque contrôleur atteigne repos, pression ou expansion. Les témoins sans superposition servent seulement au contrôle des pixels ; ils ne sont pas les captures livrées. Le GIF provient des captures successives des vrais contrôleurs, avec leurs décalages.

## Captures des trois phases

| Largeur | CTA | Repos | Pression : trois cercles | Expansion / fondu |
|---|---|---|---|---|
| 320 | Instant Recipe AI | [Capture](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\cta_38_behind\320_scan_repos_carte.png>) | [Capture](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\cta_38_behind\320_scan_pression_carte.png>) | [Capture](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\cta_38_behind\320_scan_expansion_carte.png>) |
| 320 | CaliScan AI | [Capture](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\cta_38_behind\320_meal_scan_repos_carte.png>) | [Capture](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\cta_38_behind\320_meal_scan_pression_carte.png>) | [Capture](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\cta_38_behind\320_meal_scan_expansion_carte.png>) |
| 320 | Menus | [Capture](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\cta_38_behind\320_menus_repos_carte.png>) | [Capture](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\cta_38_behind\320_menus_pression_carte.png>) | [Capture](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\cta_38_behind\320_menus_expansion_carte.png>) |
| 320 | Courses | [Capture](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\cta_38_behind\320_shopping_repos_carte.png>) | [Capture](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\cta_38_behind\320_shopping_pression_carte.png>) | [Capture](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\cta_38_behind\320_shopping_expansion_carte.png>) |
| 390 | Instant Recipe AI | [Capture](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\cta_38_behind\390_scan_repos_carte.png>) | [Capture](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\cta_38_behind\390_scan_pression_carte.png>) | [Capture](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\cta_38_behind\390_scan_expansion_carte.png>) |
| 390 | CaliScan AI | [Capture](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\cta_38_behind\390_meal_scan_repos_carte.png>) | [Capture](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\cta_38_behind\390_meal_scan_pression_carte.png>) | [Capture](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\cta_38_behind\390_meal_scan_expansion_carte.png>) |
| 390 | Menus | [Capture](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\cta_38_behind\390_menus_repos_carte.png>) | [Capture](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\cta_38_behind\390_menus_pression_carte.png>) | [Capture](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\cta_38_behind\390_menus_expansion_carte.png>) |
| 390 | Courses | [Capture](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\cta_38_behind\390_shopping_repos_carte.png>) | [Capture](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\cta_38_behind\390_shopping_pression_carte.png>) | [Capture](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\cta_38_behind\390_shopping_expansion_carte.png>) |

## Gros plans CaliScan et Landing

- [CaliScan, trois phases, cadrage fixe à 320 px](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\cta_38_behind\caliscan_320_trois_phases.png>).
- [Landing complète à 320 px](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\cta_38_behind\landing_320.png>).

- [CaliScan, trois phases, cadrage fixe à 390 px](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\cta_38_behind\caliscan_390_trois_phases.png>).
- [Landing complète à 390 px](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\cta_38_behind\landing_390.png>).

- [Animation réelle](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\cta_38_behind\animation_reelle.gif>).

Aucun commit, push ni installation Android. Aucune phase 6B/7. Arrêt pour validation visuelle de Simo.
