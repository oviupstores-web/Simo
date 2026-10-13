> Document historique : décrit une version antérieure. Pour la Landing courante provisoire, consulter [REFERENCE](../step1_landing_review/REFERENCE.md). Ne pas réappliquer ses anciennes dimensions ou ressources.

# Landing — correction ciblée de phase 1

## Corrections intégrées

- Quatre CTA : écart mesuré de **16 px** entre le rectangle de description et le haut du bouton, à 320 et 390 px. Style, libellés, taille, position horizontale et largeur de texte inchangés. Hauteur des cartes adaptée automatiquement au contenu ; minimum existant conservé.
- Instant Recipe AI et CaliScan : marge intérieure de 10 px sur les quatre côtés de leur emplacement d'image. Mise à l'échelle uniforme en contain ; aucun recadrage, étirement, flou ou modification de PNG. La largeur des emplacements et les colonnes restent inchangées. Les fichiers étant carrés, l'image complète est visible avec davantage de recul.
- Aucun changement d'espacement entre cartes : toujours 10 px. Suivi, Commencer, autres écrans, splash et navigation ne sont pas modifiés.

## Limite sur les poignets et propositions non intégrées

Les PNG sources coupent déjà le bras/poignet à leur bord inférieur ou gauche. Une marge Flutter permet de voir toute l'image mais ne restitue pas les pixels absents. La correction des poignets n'est donc pas déclarée terminée.

Deux propositions ImageGen d'extension sont enregistrées séparément : `proposal_scan.png` et `proposal_meal_scan.png`. Elles sont présentées AVANT toute intégration, conformément à la consigne utilisateur. Elles ne remplacent aucun asset de l'app. La génération peut recréer de petits détails du repas, du smartphone ou des indicateurs ; ces images ne sont pas des extensions garanties pixel-identiques. Validation visuelle explicite attendue, ou refus et révision de ces propositions.

## Captures et comparaisons

- `flutter_320.png` : 320 × 1200 px.
- `flutter_390.png` : 390 × 1190 px.
- `comparison_320.png` et `comparison_390.png` : maquette originale normalisée à gauche, Flutter à droite. Les références d'origine restent celles des deux PNG joints, avec retrait des marges blanches extérieures comme expliqué dans le rapport de phase 1.

Les captures montrent l'app avec les PNG inchangés, pas les propositions générées. Les différences de phase 1 précédemment signalées (cadrages des scènes, retours à la ligne, détails des illustrations) restent hors de cette correction ciblée.

## Vérifications

Deux tests à 320/390 réussis : huit écarts de 16 px, CTA de 28 px de haut, alignement sur le début de description, scans inactifs et routes existantes de Menus, Courses et Commencer. Analyse ciblée sans problème et diff check réussi.

Les empreintes de tous les PNG de l'app, des traductions, du splash et des autres écrans restent identiques à l'état de début de cette correction. Les dimensions de Suivi sont inchangées. Son déplacement vertical occasionne au plus une différence d'arrondi de 1/255 sur quelques pixels dans les captures ; aucun changement de style. Le bloc après Suivi est identique pixel pour pixel après compensation du déplacement.

Fichiers applicatifs modifiés : `lib/screens/entry/landing_screen.dart`, `lib/theme/app_tokens.dart` (uniquement deux nouvelles valeurs locales : marge image et écart CTA). Nouveau test : `test/landing_phase1_targeted_test.dart`. Rapport, captures, sauvegardes et propositions dans ce dossier ; note de reprise dans PLAN.md.

Aucune compilation APK, installation Android, commit ou push. Phase 2 non commencée. Attendre la validation avant toute nouvelle intervention.
