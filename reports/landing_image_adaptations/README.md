> Document historique : décrit une version antérieure. Pour la Landing courante provisoire, consulter [REFERENCE](../step1_landing_review/REFERENCE.md). Ne pas réappliquer ses anciennes dimensions ou ressources.

# Adaptation des illustrations — aperçu uniquement

Prévisualisations par montage sur les captures Flutter existantes : landing_preview_320.png et landing_preview_390.png. Ce ne sont pas des captures d'une application modifiée.

Quatre nouvelles illustrations, avec une composition adaptée à chacune des deux largeurs. Instant Recipe AI conserve le téléphone et les aliments ; CaliScan conserve téléphone, repas et trois indicateurs ; Menus conserve les cinq plats ; Courses conserve téléphone, sac et aliments. Les proportions sont conservées lors du redimensionnement : mise à l'échelle uniforme et recadrage de petites marges de fond uniquement, aucun étirement.

La première composition Courses masquait une partie du téléphone à 390 px : elle a été corrigée avant présentation. Contrôle visuel des deux montages : téléphones, plats, indicateurs et sac visibles.

Les zones de montage gardent les dimensions des colonnes et des cartes existantes. La moitié gauche et tout ce qui se trouve en dehors des quatre zones droites sont identiques pixel pour pixel aux captures d'origine (preview_verification.json). Suivi, le haut de page et Commencer sont donc inchangés.

Les fichiers originaux ne sont pas modifiés. Leurs empreintes sont enregistrées dans original_assets_sha256.json. Les fichiers nouveaux se trouvent exclusivement dans ce dossier de prévisualisation, les sorties originales du générateur restant dans son dossier de génération.

Aucune modification du code applicatif ou des tests pour cette préparation, aucune compilation, aucun commit, push ou installation. Validation visuelle demandée avant toute intégration. La contrainte allemande des CTA signalée précédemment n'est pas traitée dans cette tâche.
