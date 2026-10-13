> Document historique : décrit une version antérieure. Pour la Landing courante provisoire, consulter [REFERENCE](../step1_landing_review/REFERENCE.md). Ne pas réappliquer ses anciennes dimensions ou ressources.

# Landing — correction structurelle — validation attendue

Chaque carte est un conteneur unique avec une décoration de fond et de bordure. Son Stack ne coupe pas les calques : image superposée via Positioned.fill / Align, puis bloc texte + CTA. Aucune paire de colonnes texte/image. Les images entières utilisent BoxFit.contain, avec une marge intérieure de 5 px et filtrage de qualité élevée. Les ombres restent dans les images ; aucun masque, détourage, seuil de couleur, génération, flou ou recompression.

Les cinq nouveaux fichiers `assets/images/landing/original_scan.png`, `original_meal_scan.png`, `original_menus.png`, `original_shopping.png`, `original_tracking.png` sont des copies binaires identiques aux cinq PNG du ZIP MENOO_5_VISUELS_CARRES.zip. Empreintes dans original_manifest.json. Les copies dérivées et les propositions générées des phases précédentes ne sont plus référencées par les cartes et restent intactes.

Les quatre CTA ont 24 px mesurés entre le bas de la description et le haut du bouton. Libellés, styles et couleurs inchangés ; les cartes grandissent lorsque leur contenu l'exige. Espacement global conservé à 10 px, sans phase 2. Textes, couleurs de cartes, polices, splash, autres écrans, navigation, en-tête et bloc Commencer inchangés. Le code avant la classe des cartes, incluant le reste de la Landing et Commencer, est identique au début de cette intervention.

## Captures

Captures complètes du moteur Flutter via tests de widgets, à 320 et 390 px, sans installation Android : flutter_320.png et flutter_390.png. Comparaisons avec les maquettes jointes normalisées : comparison_320.png et comparison_390.png (maquette à gauche, Flutter à droite). Les marges extérieures des maquettes ont été retirées selon la mesure documentée dans reports/landing_phase1/README.md.

## Limites visibles à valider

Flutter ne coupe plus aucune partie supplémentaire des PNG. Cependant, les fichiers d'origine ont déjà des mains/poignets interrompus au bord de l'image : la partie absente ne peut pas être affichée sans modifier ou recréer la source, ce que la demande interdit. La demande de poignets anatomiquement entiers n'est donc pas déclarée satisfaite.

Les PNG du ZIP sont RGB, sans transparence : leurs fonds et coins intégrés sont visibles, notamment les coins noirs de Suivi. L'image superposée peut conserver une démarcation visuelle de fond même si la carte n'est plus structurellement divisée en colonnes. Le filtrage élevé ne crée pas de détail absent à la résolution d'affichage. Les scènes et dates ne sont pas pixel-identiques aux maquettes, comme signalé lors des phases précédentes. Aucune retouche de ces éléments n'est faite.

## Vérification

Deux tests réussis aux deux largeurs : huit distances CTA de 24 px, hauteur des CTA préservée à 28 px, PNG originaux et filtrage élevé, rectangles d'image contenus dans les cartes, scans inactifs et destinations Menus/Courses/Commencer conservées. Analyse ciblée sans problème, diff check réussi. Tous les anciens assets et fichiers hors périmètre vérifiés par empreintes inchangés.

## Fichiers de cette intervention

- Modifiés : lib/screens/entry/landing_screen.dart, lib/theme/app_tokens.dart (écart CTA de 16 à 24 px), PLAN.md (note de reprise).
- Ajoutés : les cinq PNG originaux ci-dessus, test/landing_structure_test.dart et les fichiers de ce dossier (captures, comparaisons, mesures, sauvegardes et rapport).

Aucun commit, push, compilation APK ou installation Android. Validation visuelle explicite attendue avant toute autre intervention.
