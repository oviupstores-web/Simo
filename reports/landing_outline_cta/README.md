> Document historique : décrit une version antérieure. Pour la Landing courante provisoire, consulter [REFERENCE](../step1_landing_review/REFERENCE.md). Ne pas réappliquer ses anciennes dimensions ou ressources.

# Landing — quatre CTA avec contour — 12 octobre 2026

## Résultat

Quatre CTA seulement : Scanner mon frigo, Analyser mon repas, Voir mes menus, Créer ma liste. Fond clair, contour de la couleur de la pastille existante, icône et flèche. Suivi reste informatif. Aucun dessin de main ni cercle animé.

Le bloc original de chaque carte garde sa géométrie. Une zone de 56 px est ajoutée sous ce bloc dans les quatre cartes concernées. Cela évite de modifier la taille ou le cadrage des illustrations. La carte Suivi et la taille du texte Commencer sont identiques à la sauvegarde de départ.

## Navigation vérifiée

- Scanner mon frigo : inactif, conformément au choix explicite de Simo.
- Analyser mon repas : inactif, conformément au choix explicite de Simo.
- Menus et Courses : parcours existant vers PathChoiceScreen (choix Solo/Foyer). Aucun accès direct à des menus ou à une liste de courses n'est créé.
- Commencer : parcours inchangé vers PathChoiceScreen.

## Captures et preuves

- landing_320.png : capture Flutter complète, 320 × 1709 px.
- landing_390.png : capture Flutter complète, 390 × 1590 px.
- comparison.png : maquette des CTA, puis captures des deux largeurs. Le reste de la maquette n'est pas reproduit : la demande exige de conserver la Landing actuelle.
- geometry_320.json et geometry_390.json : géométrie avant/après des images et des trois textes originaux de chaque carte.
- baseline_landing.dart : référence de test copiée depuis d7b5a68, sans utilisation par l'application.

## Vérifications

36 tests ciblés réussis : 12 états des CTA (six langues, deux largeurs), quatre interactions des nouveaux CTA, deux comparaisons de géométrie et les 18 tests historiques de la Landing.

Dimensions, emplacement relatif, asset et BoxFit des illustrations identiques avant/après ; contenu et dimensions des textes originaux identiques. Différences d'arrondi de calcul comparées au millionième de pixel. Hauteur de Suivi inchangée ; quatre autres cartes +56 px.

Analyse ciblée du code : aucun problème. git diff --check : réussi. Aucun changement du splash, de ses assets ou d'un autre écran. Aucun commit, push, APK ou accès au téléphone.

## Fichiers applicatifs modifiés

- lib/screens/entry/landing_screen.dart : CTA et extension de hauteur sans changement du contenu d'origine.
- lib/theme/app_tokens.dart : dimensions et style des CTA uniquement, sans modification des jetons existants.
- lib/l10n/app_{fr,en,de,es,it,ar}.arb : quatre nouvelles traductions par langue.

## Tests ajoutés

- test/landing_outline_cta_test.dart
- test/landing_outline_geometry_test.dart

Validation visuelle de Simo attendue avant toute installation.

final result: passed

Comparaison visuelle après correction de la bordure intermédiaire et retrait du bandeau de débogage dans les captures. Le rythme des cartes et la position des illustrations restent ceux de la Landing existante. Les seuls écarts autorisés sont les CTA et les 56 px supplémentaires des quatre cartes. Acceptation utilisateur encore en attente.
