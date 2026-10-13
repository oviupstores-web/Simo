> Document historique : décrit une version antérieure. Pour la Landing courante provisoire, consulter [REFERENCE](../step1_landing_review/REFERENCE.md). Ne pas réappliquer ses anciennes dimensions ou ressources.

# Cartes plus hautes et compositions originales — maquettes uniquement

Proposition : +32 px sur les quatre cartes. Colonnes de même largeur. Les textes et CTA sont repris des captures existantes, sans modification de police, libellé ou dessin. Espacement ajouté : 8 px en haut, 16 px avant le CTA, 8 px en bas. Suivi, haut de Landing et Commencer repris sans changement de dessin ; ils se décalent naturellement avec la hauteur ajoutée aux cartes précédentes.

Maquettes graphiques : landing_mockup_320.png (320×1837) et landing_mockup_390.png (390×1718). Aucune capture d'application modifiée n'est revendiquée. Dimensions logiques des cartes et zones d'image dans dimensions.json.

Compositions d'origine : téléphone et légumes pour Instant Recipe AI, téléphone et trois indicateurs pour CaliScan, trois cartes principales des menus horizontaux (Mar/Mer/Jeu), téléphone et sac côte à côte pour Courses. Aucun montage vertical refusé n'est réutilisé. Dézoom uniforme, sans étirement. Les menus gardent leurs éléments originaux et leur disposition horizontale. Courses reprend le fichier original avec ses objets côte à côte.

Nouveaux fonds proposés : background_scan.png, background_meal_scan.png, background_menus.png, background_shopping.png, présentés dans backgrounds_for_validation.png. La scène Instant Recipe AI dispose aussi d'un raccord dérivé proposé (scan_raccord_reference.png), obtenu depuis l'original pour compléter le réfrigérateur et nettoyer les jonctions. Ce raccord est à valider comme un nouvel asset, pas à considérer comme une copie pixel-identique de l'original.

À 320 px, Courses est nécessairement plus dézoomé pour afficher téléphone et sac entiers dans la largeur inchangée. Cette limite visuelle est présentée à l'utilisateur avant toute intégration.

Les fichiers images d'origine restent intacts ; aucune modification supplémentaire de code, de tests, de PLAN ou de DECISIONS pour cette préparation. Aucun commit, push, compilation ou installation. Attendre validation des hauteurs, des cadrages et des nouveaux fonds avant toute intégration.
