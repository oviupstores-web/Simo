# Landing — CTA avec main animée

## Résultat et fichiers

Implémentation locale : lib/screens/entry/landing_screen.dart et nouveau lib/screens/entry/landing_badge_cta.dart. Tests : test/landing_cta_test.dart. Documentation : ce rapport, PLAN.md et DECISIONS.md. Les empreintes des fichiers préexistants lib/assets/test sont vérifiées : seule landing_screen.dart a changé pendant cette intervention ; les autres corrections et tous les PNG sont préservés.

Les cinq cartes, leurs photos, textes, couleurs, dimensions minimales, marges et polices sont conservés. La pastille garde son Container et ses paddings ; le dessin est superposé dans un Stack sans participer à la hauteur. Le bouton Commencer conserve sa route. La pastille Suivi ne contient ni main, ni animation, ni nouveau gestionnaire de clic ; le clic déjà existant sur sa carte reste inchangé.

## Routes et comportement réellement disponible

| Pastille | Route examinée | Connexion retenue | Limite |
|---|---|---|---|
| Instant Recipe AI | Ancien lien vers ImprovComingSoonScreen | Aucune navigation, composant visuel animé uniquement | Écran temporaire, pas de génération de recette fonctionnelle : lien retiré localement de cette carte pour ne pas présenter ce parcours comme opérationnel |
| CaliScan AI | Aucune route fonctionnelle identifiée ; les scanners Réserve sont eux aussi des écrans annoncés comme futurs | Aucune navigation, composant visuel animé uniquement | Pas de caméra ni d’analyse nutritionnelle opérationnelle connectée |
| Menus | PathChoiceScreen ; puis onboarding Solo/Famille et SummaryScreen → SignupScreen | Même route vers PathChoiceScreen sur la carte et la pastille | Pas d’accès direct au menu : inscription et génération réelles encore non opérationnelles dans SignupScreen |
| Courses | PathChoiceScreen ; ShoppingListScreen existe séparément | Même route d’entrée existante vers PathChoiceScreen | Pas de raccourci arbitraire vers ShoppingListScreen ni contournement du parcours |

Sources : lib/screens/entry/improv_coming_soon_screen.dart, lib/screens/pantry/pantry_scan_screens.dart, lib/screens/entry/path_choice_screen.dart, lib/screens/onboarding/summary_screen.dart, lib/screens/entry/signup_screen.dart, lib/screens/shopping/shopping_list_screen.dart. Aucun écran fonctionnel fictif ajouté. Les deux CTA sans destination restent visuels, sans sémantique de bouton activé. Leur navigation devra faire l’objet d’un travail ultérieur autorisé.

Pour Menus/Courses, une cible locale de 48 px de haut est superposée ; la carte entière reste également tactile et couvre la zone autour de la petite pastille. Le GestureDetector de la pastille remporte le geste sur son parent : un seul push par appui vérifié. Aucun clic ne se produit automatiquement.

## Dessin et animation

Dessin Flutter CustomPainter, rempli blanc, contour #303030 de 1 px, jointures et extrémités arrondies. Zone de peinture 26 × 32 px ; illustration compacte, index incliné par rotation de -25°. Point de contact près du bord extérieur de la pastille, main superposée à son extrémité droite en LTR. Aucun emoji ni nouvel asset. Aucune référence graphique supplémentaire précise n’a été identifiée dans la demande ; ce dessin fondé sur les spécifications reste soumis à la validation visuelle.

En arabe, la main est en miroir à l’extrémité gauche de la pastille : le placement à droite était coupé par la carte. Cette adaptation évite de déplacer les textes et de rogner la main ; l’inclinaison devient symétrique en RTL.

Clic de 600 ms ; translation maximale 1,5 px par axe vers le point de contact, sans déplacer le texte. Onde circulaire de rayon 2 à 7 px, opacité décroissante, deux traits courts. Retour au repos puis pause de 4200 ms, sans frames d’animation pendant cette pause. Décalages initiaux : 0, 1104, 2208, 3312 ms. Pas de grossissement de carte ni de flash.

MediaQuery.disableAnimations ou accessibleNavigation : main statique, onde absente, timer annulé. TickerMode désactivé : arrêt et remise au repos. AnimationController et Timer libérés au dispose, callback protégé par mounted. RepaintBoundary isolant le petit dessin. Les quatre widgets restent montés pendant le défilement ; le cycle continue, sans recréer de contrôleur. Aucun benchmark sur téléphone effectué.

## Tests et limites

- 17 tests CTA réussis : six langues × deux largeurs, absence d’overflow, quatre mains et aucune sur Suivi, positions de contact, défilement, absence de navigation automatique, dispose, deux navigations uniques, durée/pause et changement de préférence système, deux modes de réduction des animations.
- 430 tests de régression réussis : solo_flow, family_profiles_regression, phase4bis_constraints, icon_preview, goal_card_padding, harmonisation_card.
- flutter analyze --no-pub : No issues found!
- git diff --check : réussi, aucune erreur.
- Suite complète et Golden non relancés ici. Le dernier bilan antérieur de 1161 réussites / 17 échecs historiques reste un bilan antérieur, pas une validation complète de cette nouvelle Landing. Les Golden Landing changeront visuellement et ne sont pas régénérés.

L’analyse initiale a relevé une API TickerMode dépréciée, remplacée par valuesOf. Les premières captures nécessitaient un contexte runAsync dans le test ; les tests de navigation et de timing ont été ajustés aux frames réelles des transitions. Aucun échec ciblé ne reste.

## Captures

Captures Flutter à largeur logique 320/390, hauteur 900, résolution d’export ×2, sans téléphone. Chaque carte concernée dispose d’une capture après défilement. Les quatre mains sont visibles sur les captures scan ; les autres montrent les cartes suivantes.

[Comparatif FR 320 / 390](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta\FR_320_390.png>)

| Langue / largeur | Instant Recipe AI | CaliScan AI | Menus | Courses | Mesures |
|---|---|---|---|---|---|
| fr 320 | [Voir](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta\fr_320_scan.png>) | [Voir](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta\fr_320_meal_scan.png>) | [Voir](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta\fr_320_menus.png>) | [Voir](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta\fr_320_shopping.png>) | [JSON](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta\fr_320_sizes.json>) |
| fr 390 | [Voir](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta\fr_390_scan.png>) | [Voir](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta\fr_390_meal_scan.png>) | [Voir](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta\fr_390_menus.png>) | [Voir](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta\fr_390_shopping.png>) | [JSON](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta\fr_390_sizes.json>) |
| en 320 | [Voir](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta\en_320_scan.png>) | [Voir](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta\en_320_meal_scan.png>) | [Voir](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta\en_320_menus.png>) | [Voir](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta\en_320_shopping.png>) | [JSON](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta\en_320_sizes.json>) |
| en 390 | [Voir](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta\en_390_scan.png>) | [Voir](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta\en_390_meal_scan.png>) | [Voir](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta\en_390_menus.png>) | [Voir](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta\en_390_shopping.png>) | [JSON](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta\en_390_sizes.json>) |
| de 320 | [Voir](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta\de_320_scan.png>) | [Voir](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta\de_320_meal_scan.png>) | [Voir](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta\de_320_menus.png>) | [Voir](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta\de_320_shopping.png>) | [JSON](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta\de_320_sizes.json>) |
| de 390 | [Voir](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta\de_390_scan.png>) | [Voir](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta\de_390_meal_scan.png>) | [Voir](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta\de_390_menus.png>) | [Voir](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta\de_390_shopping.png>) | [JSON](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta\de_390_sizes.json>) |
| es 320 | [Voir](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta\es_320_scan.png>) | [Voir](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta\es_320_meal_scan.png>) | [Voir](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta\es_320_menus.png>) | [Voir](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta\es_320_shopping.png>) | [JSON](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta\es_320_sizes.json>) |
| es 390 | [Voir](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta\es_390_scan.png>) | [Voir](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta\es_390_meal_scan.png>) | [Voir](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta\es_390_menus.png>) | [Voir](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta\es_390_shopping.png>) | [JSON](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta\es_390_sizes.json>) |
| it 320 | [Voir](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta\it_320_scan.png>) | [Voir](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta\it_320_meal_scan.png>) | [Voir](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta\it_320_menus.png>) | [Voir](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta\it_320_shopping.png>) | [JSON](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta\it_320_sizes.json>) |
| it 390 | [Voir](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta\it_390_scan.png>) | [Voir](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta\it_390_meal_scan.png>) | [Voir](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta\it_390_menus.png>) | [Voir](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta\it_390_shopping.png>) | [JSON](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta\it_390_sizes.json>) |
| ar 320 | [Voir](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta\ar_320_scan.png>) | [Voir](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta\ar_320_meal_scan.png>) | [Voir](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta\ar_320_menus.png>) | [Voir](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta\ar_320_shopping.png>) | [JSON](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta\ar_320_sizes.json>) |
| ar 390 | [Voir](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta\ar_390_scan.png>) | [Voir](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta\ar_390_meal_scan.png>) | [Voir](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta\ar_390_menus.png>) | [Voir](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta\ar_390_shopping.png>) | [JSON](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta\ar_390_sizes.json>) |

## Dimensions rendues

Pixels logiques. Ce tableau relève les dimensions finales des cartes et pastilles, sans changer leurs contraintes existantes.

| Langue | Largeur | Carte | Largeur × hauteur carte | Largeur × hauteur pastille |
|---|---|---|---|---|
| fr | 320 | scan | 292.00 × 221.59 | 125.40 × 25.15 |
| fr | 320 | meal_scan | 292.00 × 173.59 | 91.49 × 25.15 |
| fr | 320 | menus | 292.00 × 200.59 | 63.10 × 25.15 |
| fr | 320 | shopping | 292.00 × 226.59 | 74.14 × 25.15 |
| fr | 320 | tracking | 292.00 × 200.59 | 51.31 × 25.15 |
| fr | 390 | scan | 362.00 × 205.96 | 130.27 × 26.49 |
| fr | 390 | meal_scan | 362.00 × 157.96 | 96.37 × 26.49 |
| fr | 390 | menus | 362.00 × 184.96 | 67.97 × 26.49 |
| fr | 390 | shopping | 362.00 × 184.96 | 79.01 × 26.49 |
| fr | 390 | tracking | 362.00 × 158.96 | 56.18 × 26.49 |
| en | 320 | scan | 292.00 × 200.59 | 125.40 × 25.15 |
| en | 320 | meal_scan | 292.00 × 152.59 | 91.49 × 25.15 |
| en | 320 | menus | 292.00 × 179.59 | 63.10 × 25.15 |
| en | 320 | shopping | 292.00 × 179.59 | 83.30 × 25.15 |
| en | 320 | tracking | 292.00 × 179.59 | 74.59 × 25.15 |
| en | 390 | scan | 362.00 × 158.96 | 130.27 × 26.49 |
| en | 390 | meal_scan | 362.00 × 157.96 | 96.37 × 26.49 |
| en | 390 | menus | 362.00 × 184.96 | 67.97 × 26.49 |
| en | 390 | shopping | 362.00 × 184.96 | 88.18 × 26.49 |
| en | 390 | tracking | 362.00 × 137.96 | 79.47 × 26.49 |
| de | 320 | scan | 292.00 × 242.59 | 125.40 × 25.15 |
| de | 320 | meal_scan | 292.00 × 194.59 | 91.49 × 25.15 |
| de | 320 | menus | 292.00 × 221.59 | 63.10 × 25.15 |
| de | 320 | shopping | 292.00 × 221.59 | 68.21 × 25.15 |
| de | 320 | tracking | 292.00 × 200.59 | 66.09 × 25.15 |
| de | 390 | scan | 362.00 × 200.96 | 130.27 × 26.49 |
| de | 390 | meal_scan | 362.00 × 178.96 | 96.37 × 26.49 |
| de | 390 | menus | 362.00 × 205.96 | 67.97 × 26.49 |
| de | 390 | shopping | 362.00 × 205.96 | 73.08 × 26.49 |
| de | 390 | tracking | 362.00 × 184.96 | 70.96 × 26.49 |
| es | 320 | scan | 292.00 × 200.59 | 125.40 × 25.15 |
| es | 320 | meal_scan | 292.00 × 194.59 | 91.49 × 25.15 |
| es | 320 | menus | 292.00 × 200.59 | 63.10 × 25.15 |
| es | 320 | shopping | 292.00 × 200.59 | 80.01 × 25.15 |
| es | 320 | tracking | 292.00 × 174.59 | 101.78 × 25.15 |
| es | 390 | scan | 362.00 × 184.96 | 130.27 × 26.49 |
| es | 390 | meal_scan | 362.00 × 157.96 | 96.37 × 26.49 |
| es | 390 | menus | 362.00 × 184.96 | 67.97 × 26.49 |
| es | 390 | shopping | 362.00 × 184.96 | 84.89 × 26.49 |
| es | 390 | tracking | 362.00 × 158.96 | 106.65 × 26.49 |
| it | 320 | scan | 292.00 × 221.59 | 125.40 × 25.15 |
| it | 320 | meal_scan | 292.00 × 173.59 | 91.49 × 25.15 |
| it | 320 | menus | 292.00 × 179.59 | 56.46 × 25.15 |
| it | 320 | shopping | 292.00 × 221.59 | 61.48 × 25.15 |
| it | 320 | tracking | 292.00 × 200.59 | 106.72 × 25.15 |
| it | 390 | scan | 362.00 × 205.96 | 130.27 × 26.49 |
| it | 390 | meal_scan | 362.00 × 157.96 | 96.37 × 26.49 |
| it | 390 | menus | 362.00 × 184.96 | 61.33 × 26.49 |
| it | 390 | shopping | 362.00 × 205.96 | 66.35 × 26.49 |
| it | 390 | tracking | 362.00 × 158.96 | 111.59 × 26.49 |
| ar | 320 | scan | 292.00 × 154.59 | 125.40 × 25.15 |
| ar | 320 | meal_scan | 292.00 × 173.59 | 91.49 × 25.15 |
| ar | 320 | menus | 292.00 × 160.59 | 61.09 × 26.15 |
| ar | 320 | shopping | 292.00 × 181.59 | 64.86 × 26.15 |
| ar | 320 | tracking | 292.00 × 134.59 | 67.73 × 26.15 |
| ar | 390 | scan | 362.00 × 159.96 | 130.27 × 26.49 |
| ar | 390 | meal_scan | 362.00 × 178.96 | 96.37 × 26.49 |
| ar | 390 | menus | 362.00 × 139.96 | 65.96 × 27.49 |
| ar | 390 | shopping | 362.00 × 139.96 | 69.73 × 27.49 |
| ar | 390 | tracking | 362.00 × 139.96 | 72.60 × 27.49 |

## Arrêt

Validation visuelle attendue avant toute installation Xiaomi. Aucune installation Android, aucun commit/push, aucun changement Supabase. Phases 6B et 7 non commencées.


## Correction validable sur référence fournie — version actuelle

Cette section remplace les descriptions antérieures du dessin. Référence obligatoire : codex-clipboard-2f0125b6-dcfb-4ff5-ada8-b923300dfba5.png, fournie par Simo. Silhouette retracée en Flutter : index tendu long, trois doigts arrondis avec séparations internes, pouce ouvert, paume et poignet. Remplissage blanc, contour noir d’environ 0,55 px. Taille visuelle proche de 23 px ; la zone technique de peinture reste 26 × 32 px sans changer le layout. La référence déjà inclinée est redressée avant l’inclinaison de 25° à gauche.

Le point de contact fixe est maintenant au bord droit de la pastille en LTR. La main reste ancrée ; une compression de 1,5 % autour de ce point simule la pression. Trois cercles concentriques sous l’index : rayons maximaux 2 / 3,7 / 5,4 px, agrandissement progressif et disparition en fondu. Traits de clic conservés selon la référence. Clic 600 ms, pause 4200 ms et décalages inchangés. Préférences de réduction des animations et libération des timers/contrôleurs préservées.

Tests exécutés uniquement en FR, EN, ES, IT et DE, à 320 et 390 px : 17 réussites, dont deux captures de page entière et vérification du point de contact pendant l’expansion à 60 % du clic. L’arabe n’a pas été testé pendant cette correction. Les dix relevés dimensionnels des cinq cartes et pastilles sont identiques à ceux de l’intervention précédente. Les empreintes confirment que les PNG, les autres écrans et landing_screen.dart (donc les navigations, textes, couleurs et photos) n’ont pas changé. Seuls landing_badge_cta.dart et landing_cta_test.dart ont été modifiés dans lib/test pendant cette correction.

Les 430 régressions mentionnées plus haut correspondent à l’intervention précédente ; elles ne sont pas présentées comme relancées ici. flutter analyze --no-pub : No issues found! (4,6 s). git diff --check : réussi. Aucune installation Android, aucun commit ni push. Validation visuelle attendue.

### Aperçus de la version corrigée

- [Landing entière 320 px](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_main_reference\landing_entiere_320.png>).
- [Gros plan : trois cercles en expansion à 320 px](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_main_reference\main_expansion_320.png>).

- [Landing entière 390 px](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_main_reference\landing_entiere_390.png>).
- [Gros plan : trois cercles en expansion à 390 px](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_main_reference\main_expansion_390.png>).

| Langue | 320 px | 390 px |
|---|---|---|
| fr | [Capture](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_main_reference\fr_320_scan.png>) | [Capture](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_main_reference\fr_390_scan.png>) |
| en | [Capture](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_main_reference\en_320_scan.png>) | [Capture](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_main_reference\en_390_scan.png>) |
| es | [Capture](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_main_reference\es_320_scan.png>) | [Capture](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_main_reference\es_390_scan.png>) |
| it | [Capture](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_main_reference\it_320_scan.png>) | [Capture](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_main_reference\it_390_scan.png>) |
| de | [Capture](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_main_reference\de_320_scan.png>) | [Capture](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_main_reference\de_390_scan.png>) |


## Correction finale : uniquement trois cercles, sans traits de clic

Tous les traits de clic ont été supprimés du peintre commun LandingClickHandPainter. Les contours de la main et les séparations entre les doigts sont conservés. Instant Recipe AI, CaliScan AI, Menus et Courses utilisent exactement le même composant, les mêmes cercles et le même timing ; leurs décalages restent inchangés. Suivi reste sans main ni animation.

17 tests réussis en FR/EN/ES/IT/DE à 320/390 px. Les relevés des cartes et pastilles sont identiques ; les empreintes confirment que seule landing_badge_cta.dart a changé dans lib/assets. landing_screen.dart, PNG, textes et navigations sont inchangés. Le test de capture force uniquement la peinture à 60 % pour comparer les quatre mains ; aucune synchronisation ajoutée au code applicatif.

- [Quatre mains au même stade — 320 px](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta_final\quatre_mains_60pct_320.png>).
- [Landing complète de comparaison — 320 px](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta_final\landing_synchronisee_320.png>).

- [Quatre mains au même stade — 390 px](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta_final\quatre_mains_60pct_390.png>).
- [Landing complète de comparaison — 390 px](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta_final\landing_synchronisee_390.png>).

Aucun commit, push ni installation Android. Validation visuelle attendue.


## Version agrandie avec tap visible — 10 octobre 2026

Cette section décrit la dernière version. Main validée conservée et agrandie : hauteur visuelle d’environ 30 px (contre environ 23 px), contour noir fin, inclinaison conservée. Zone de peinture technique 38 × 48 px. Trois cercles sans aucun trait de clic : rayons maximaux 3 / 5,3 / 7,5 px, diamètre extérieur maximal 15 px contre 10,8 px auparavant.

Vrai mouvement de pression : descente de 3 px pendant les premières 180 ms, bref contact jusqu’à 300 ms, puis retour fluide jusqu’à 600 ms. Les cercles apparaissent au contact à partir de 180 ms, grandissent et disparaissent en fondu. Pause de 4200 ms entre deux clics, quatre décalages initiaux conservés. Le même composant sert aux quatre CTA. Les préférences de réduction des animations, l’arrêt des timers et le dispose restent vérifiés.

Pour que le poignet agrandi ne touche pas les titres, le seul espacement sous la pastille des quatre cartes passe à 14 px. La hauteur s’adapte au contenu ; les autres paddings, textes et styles sont conservés. Les photos des quatre cartes sont affichées avec BoxFit.contain, y compris CaliScan, pour montrer le fichier complet sans recadrage. Cela révèle plus de fond autour de certaines photos ; ce choix de rendu est à valider visuellement. Aucun PNG n’est modifié. La carte Suivi garde son visuel et sa hauteur ; son ancien clic sur la carte a été désactivé conformément à la demande de la conserver purement informative. Menus/Courses et Commencer conservent leurs routes ; les deux CTA IA restent visuels.

### Hauteurs réelles en pixels logiques

| Carte | 320 px avant → après | 390 px avant → après |
|---|---|---|
| Instant Recipe AI | 221.59 → 233.28 | 205.96 → 217.15 |
| CaliScan AI | 173.59 → 185.28 | 157.96 → 169.15 |
| Menus | 200.59 → 212.28 | 184.96 → 196.15 |
| Courses | 226.59 → 238.28 | 184.96 → 196.15 |
| Suivi | 200.59 → 200.59 | 158.96 → 158.96 |

Les quatre cartes gagnent environ 11,70 px à 320 et 11,19 px à 390. Aucun changement de hauteur sur Suivi.

### Vérifications et aperçus

10 tests réussis en FR à 320 et 390 px : rendu sans overflow, photos des quatre cartes en contain, Suivi sans interaction, quatre mains de même taille, navigations uniques, réduction des animations et cycle de vie. Les deux captures de comparaison montrent volontairement les quatre mains à 60 % du cycle, uniquement dans le test. Le GIF provient de 48 captures successives à 100 ms utilisant les vrais contrôleurs avec leurs décalages ; aucune synchronisation de production ajoutée. Analyse statique : No issues found!. git diff --check : réussi. La suite complète n’a pas été relancée.

- [Capture entière FR 320 px](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta_large\landing_320.png>).
- [Capture entière FR 390 px](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta_large\landing_390.png>).
- [Aperçu animé réel FR 320 px](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\landing_cta_large\animation_reelle_320.gif>).

Fichiers modifiés pour cette version : landing_badge_cta.dart, landing_screen.dart, landing_cta_test.dart, ce rapport, PLAN.md et DECISIONS.md. Empreintes vérifiées : seuls les deux fichiers Landing changent dans lib/assets. Aucune installation, commit ni push ; phases 6B et 7 non commencées. Attente de validation visuelle.
