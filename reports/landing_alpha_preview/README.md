> Document historique : décrit une version antérieure. Pour la Landing courante provisoire, consulter [REFERENCE](../step1_landing_review/REFERENCE.md). Ne pas réappliquer ses anciennes dimensions ou ressources.

# Landing sans fonds — aperçus pour validation

13 octobre 2026. Cinq nouvelles copies RGBA de 1254 × 1254 px : scan.png, meal_scan.png, menus.png, shopping.png et tracking.png. Chaque fichier conserve exactement les trois canaux RGB de son PNG original ; seul le canal alpha est ajouté. Vérification numérique dans rgb_proof.json. Les RGB produits par la génération ne sont jamais employés. Les masques de transparence seuls sont récupérés, et le verre de CaliScan est maintenu opaque à l'intérieur du cadre noir original, sans dessiner de nouvelle texture.

Les fonds pastel extérieurs, coins blancs/noirs et cadre extérieur disparaissent. Objets, dates, graphismes et textures d'origine restent inchangés. Les masques comportent des valeurs intermédiaires de transparence pour les contours et ombres douces. Les limites intrinsèques des mains/poignets touchant les bords de leurs sources ne sont pas recréées.

five_checkerboards.png présente les cinq illustrations sur quadrillé ; chaque fichier possède également son aperçu individuel *_checkerboard.png. Archive des cinq PNG : MENOO_5_PNG_TRANSPARENTS_PREVIEW.zip.

flutter_320.png et flutter_390.png sont des captures complètes Flutter d'une copie indépendante de la Landing qui charge ces fichiers en mémoire. Cette copie reprend le code actuel, les textes, CTA, couleurs, dimensions, navigation et espacements ; seuls les fournisseurs des cinq images changent dans cette copie. comparison_320.png et comparison_390.png comparent à gauche la référence originale normalisée et à droite l'aperçu sans fonds.

Deux tests d'aperçu réussis à 320 et 390 : aucun débordement, CTA toujours à 24 px des descriptions, images entières en contain et routes existantes conservées. Le code de production, les PNG existants, les traductions, le splash, Commencer et PLAN.md ne sont pas modifiés. Le test ajouté et tous les fichiers de ce dossier servent exclusivement à la prévisualisation. Contrôle par empreintes : tous les fichiers existants vérifiés sont inchangés.

Aucune intégration à l'app, compilation APK, installation Android, commit ou push. Validation visuelle explicite attendue avant intégration. Les contours fins et ombres sont à juger sur ces aperçus ; ne pas considérer le seul maintien des RGB comme une certification automatique de chaque bord du masque.
