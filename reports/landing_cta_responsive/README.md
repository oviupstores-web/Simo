> Document historique : décrit une version antérieure. Pour la Landing courante provisoire, consulter [REFERENCE](../step1_landing_review/REFERENCE.md). Ne pas réappliquer ses anciennes dimensions ou ressources.

# Landing — CTA responsive — 12 octobre 2026

Captures complètes : landing_320.png (320 × 1709) et landing_390.png (390 × 1590).

À 320 px : Scanner, Analyser, Mes menus, Ma liste. À 390 px : Scanner mon frigo, Analyser mon repas, Voir mes menus, Créer ma liste.

Chaque CTA est limité à la largeur de la description et à la moitié gauche de la carte. Une seule ligne, police 12 px et icônes 18 px conservées. Espacements intérieurs et marges latérales du bouton : 4 px. Couleurs, contours, flèches et fonctionnement conservés. Les deux scans restent inactifs ; Menus et Courses gardent leur parcours existant. Suivi reste sans CTA.

Zone droite : aucune modification du code des illustrations. Comparaisons de géométrie avec d7b5a68 réussies à 320/390 ; assets, dimensions, BoxFit et coordonnées relatives identiques. Les hauteurs des cartes restent celles de l'ajout précédent, sans augmentation supplémentaire pour cette correction. Descriptions, splash et Commencer inchangés.

## Résultats

- Pré-mesure française : réussite. À 390, Analyser mon repas nécessite 166 px ; zone texte 168,55 px.
- Tests français 320/390, une ligne et colonne gauche : réussite.
- Tests de géométrie et navigation existante : réussite.
- Contrôle supplémentaire des six langues : 15 tests CTA réussis, un échec en allemand à 390 px. Kühlschrank scannen nécessite 122,70 px de texte, mais 116,55 px restent après les icônes et espacements.
- Total de la campagne : 36 tests réussis, un échec identifié en allemand. Aucun résultat global entièrement réussi n'est revendiqué.
- git diff --check : réussi.

Arrêt conformément au garde-fou. Aucun ajustement supplémentaire de ce libellé, de la police ou de ses espacements sans accord. Proposition : resserrer uniquement les espacements du cas allemand, après autorisation et nouvelle mesure. Rendu français à valider. Aucun commit, push, APK ou installation Android.

final result: blocked

Le blocage concerne la largeur de la traduction allemande ; les captures françaises respectent la demande.
