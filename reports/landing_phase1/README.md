> Document historique : décrit une version antérieure. Pour la Landing courante provisoire, consulter [REFERENCE](../step1_landing_review/REFERENCE.md). Ne pas réappliquer ses anciennes dimensions ou ressources.

# Landing — phase 1 — validation visuelle attendue

Implémentation Flutter limitée à la Landing, avec les cinq illustrations du ZIP. Captures françaises complètes `flutter_320.png` et `flutter_390.png`, comparaisons `comparison_320.png` et `comparison_390.png` (référence à gauche, Flutter à droite).

Les deux références originales font chacune 863 × 1822 px et comportent de grandes marges blanches extérieures. Pour comparer à 320 et 390 px, la zone utile a été normalisée d'après la largeur des cartes : découpe x=173..690 pour 320, x=123..743 pour 390, sans étirement. Les images normalisées mesurent 320 × 1128 et 390 × 1146. Ces dimensions résultent de la mesure du contenu, pas d'un fichier source natif à ces largeurs.

## Modification réalisée

- `lib/screens/entry/landing_screen.dart` : mise en page plus compacte, images à droite, marque et en-tête mesurés sur les références, CTA avec leurs libellés localisés complets aux deux largeurs. Les anciens libellés courts à 320 ne sont plus utilisés pour correspondre aux références. Aucun fichier de traduction modifié.
- `lib/theme/app_tokens.dart` : nouveaux réglages propres à la Landing et ajustement des jetons de ses CTA ; espacement `LandingTokens.cardGap` conservé à 10 px, sans phase 2.
- Cinq nouveaux fichiers `assets/images/landing/phase1_scan.png`, `phase1_meal_scan.png`, `phase1_menus.png`, `phase1_shopping.png`, `phase1_tracking.png`. Copies dérivées RGBA depuis le ZIP, avec fond extérieur connecté retiré pour laisser apparaître la couleur de la carte. Les sujets gardent leurs pixels et leurs proportions. Aucun PNG original remplacé. Les indicateurs blancs de CaliScan et les trois panneaux de Suivi sont préservés par des zones protégées.
- `test/landing_phase1_capture_test.dart` : captures Flutter complètes, absence d'erreur de rendu, scans inactifs et destinations existantes de Menus, Courses et Commencer.
- Ce dossier : sources sauvegardées avant intervention, manifestes, mesures, captures et comparaisons.
- `PLAN.md` : note de reprise et attente de validation ; aucune décision visuelle déclarée validée.

## Différences restantes

La reproduction n'est pas pixel-identique. Le plat de l'en-tête conserve la photographie déjà présente dans l'app : la reference montre une variante de cette scène. Les cadrages et la taille relative des sujets diffèrent encore, surtout pour Menus et Suivi. Suivi est affiché entièrement en contain pour ne pas couper les aliments et les panneaux ; il paraît donc plus petit que sur les références.

La référence 320 montre des étiquettes de jours (Lun 10, Mar 11, Mer 12, Jeu 13), tandis que l'illustration Menus du ZIP contient 12/10, 13/10, 14/10, 15/10. Ces étiquettes intégrées à l'image sont conservées. Les illustrations du ZIP ne sont pas des copies pixel-identiques des scènes recomposées dans les références.

Certains retours à la ligne, les icônes et les nuances diffèrent. Les fonds des cartes restent les couleurs de la Landing locale, et la suppression du fond des illustrations peut laisser un léger liseré sur certains contours. Les espacements restent 10 px : les références montrent des intervalles plus faibles après normalisation ; ces ajustements sont réservés à la phase 2.

## Vérification et limites

Deux tests de capture et de navigation réussis à 320 et 390 px ; analyse ciblée sans problème ; `git diff --check` réussi. Il s'agit de captures du moteur Flutter via tests de widgets, pas de captures sur téléphone. Aucune compilation APK, installation Android, commit ou push. Splash, navigation, autres écrans, traductions et anciens assets contrôlés par empreintes avant/après : inchangés pendant cette phase.

Validation visuelle explicite attendue. Aucun lancement de la phase 2.
