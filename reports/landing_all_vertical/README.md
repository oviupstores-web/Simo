> Document historique : décrit une version antérieure. Pour la Landing courante provisoire, consulter [REFERENCE](../step1_landing_review/REFERENCE.md). Ne pas réappliquer ses anciennes dimensions ou ressources.

# Landing : cinq cartes verticales — validation attendue

Modèle Instant Recipe AI validé par Simo et étendu à CaliScan AI, Menus, Courses et Suivi : badge/titre 8 px, titre/description 10 px, interlignes 20/17 px, description/CTA 24 px. Quatre CTA centrés à 85 % de la largeur intérieure avec textes et icônes centrés, libellés complets traduits. Suivi sans CTA. Illustration entière centrée sous le texte/CTA, à 75 % de la largeur intérieure, BoxFit.contain, 12 px avant le cadre de l'image. Fond pastel, bordure, police et couleur de chaque carte conservés. Espacement entre cartes 10 px inchangé.

Les quatre PNG ajoutés sont identiques aux derniers fichiers fournis, empreintes dans assets.json. Aucun détourage, masque, recadrage ni retouche. L'illustration Instant Recipe AI reste inchangée. La transparence et les marges internes aux PNG peuvent rendre les distances visuelles différentes des distances de leurs cadres.

Captures Flutter complètes all_vertical_fr_320.png, all_vertical_fr_390.png, all_vertical_de_320.png, all_vertical_de_390.png. Quatre tests réussis : image entière et centrée, CTA à 85 % et centré, distances, Suivi sans CTA, scans inactifs, destinations Menus/Courses PathChoiceScreen. Analyse ciblée : aucune anomalie. Header et Instant Recipe AI strictement identiques pixel par pixel aux quatre captures validées narrow_cta. Traductions des CTA présentes en FR/EN/ES/IT/DE.

Limites visuelles : les avant-bras sont déjà coupés dans les PNG sources ; CaliScan contient protein/carbs en anglais ; les dates/chiffres des PNG restent incorporés. Légères franges et résidus clairs sur Suivi, petit halo autour de certains contours ; aucune correction des pixels. La Landing est plus longue et les cartes diffèrent en hauteur selon le texte et le format de l'image (Menus est horizontal).

Aucun APK, installation Android, commit, push ni ajout de dépendance. Autres écrans et splash non modifiés. Attendre validation explicite du rendu des quatre nouvelles cartes.
