# Phase 4 — corrections des formats régionaux

Date : 2026-10-09. Référence : `master`, `4f569a0`. Phase 3 locale préservée. Périmètre B08/B09/B10 autorisé par Simo.

## Corrections et preuves avant/après

| Anomalie | Cause | Correction appliquée | Tests avant/après | Résultat |
|---|---|---|---|---|
| B08 devises | Euros fixes dans Budget/ARB ; CAD/AUD absents ; montant sans code | Code ISO attaché au budget, formatage homogène Budget/récapitulatif ; CAD/AUD pris en charge | 18 cas monétaires échouaient ; passent après. 8 tests supplémentaires de pays/devise native | Corrigé, aucune conversion |
| B08 pays perdu | Le callback Flutter fournissait la locale préférée, utilisée à tort comme pays du téléphone | Reprendre le pays réel de platformDispatcher ; langue indépendante | 3 changements de langue échouaient ; passent. Canada français/région AU avec budget CAD testé | Corrigé, montant/code conservés |
| B08 collage décimal | digitsOnly supprimait les séparateurs, 65,50 devenait 6550 | Entier strict, int.tryParse, erreur traduite ; dernier budget valide préservé | 3 reproductions échouaient ; passent. Décimales, texte, négatif, sous-borne et dépassement testés | Corrigé sans arrondi |
| B08 budgets hérités | Absence de devise explicite et réinterprétation possible depuis la région | Restauration conserve montant/code nullable ; inconnue signalée ; choix explicite sans présélection dans Budget existant | Nouveaux tests restauration, confirmation/annulation, ancienne API, région, récapitulatif, montant 7 et entier maximal | 38 nouveaux contrôles passent |
| B09 pieds/pouces | Pieds séparés avant arrondi des pouces, sans report | Arrondir pouces totaux puis ~/12 et %12 ; cm inchangés | 4 reproductions échouaient, dont balayage de 1101 tailles ; passent. Ancien test B09 réactivé | 182 cm → 6 ft 0 in |
| B10 grille | Virgule forcée avec replaceAll | Formats.number sur locale complète ; moyenne interne inchangée | 16 cas EN/de-CH échouaient ; passent | FR/DE virgule ; EN/de-CH point |

Les 44 échecs diagnostiques ont disparu. Les observations CAD/AUD du diagnostic ont été mises à jour selon la politique désormais autorisée, sans affaiblir les assertions reproduisant les défauts.

## Vérifications exactes

- Diagnostic initial : 131 tests, 87 réussites, 44 échecs ; 165 contrôles de préservation réussis.
- Après : `phase4_regional_diagnostic_test.dart` : **131 réussites**, aucun échec.
- `phase4_budget_regression_test.dart` : **38 réussites**, aucun échec, également relancé séparément (code 0).
- Suite complète `flutter test --no-pub --reporter json` : **718 réussites, 13 échecs, 0 ignoré**, code 1 dû aux références visuelles historiques.
- Sous-ensemble pertinent de cette suite, hors golden/démarrage/widget de base : **707 réussites / 0 échec**. Il comprend Solo/Famille, phases 1–3, calculs numériques, conversions, localisation et responsive.
- Régressions Réserve : 80 diagnostics + 69 contrôles supplémentaires, tous réussis. Profils Famille : 22 modèle + 36 interface ; éligibilité Solo : 24 ; champs numériques : 81 ; modèle numérique : 35, incluant B09 réactivé ; caractérisation nutritionnelle : 29 ; parcours Solo/Famille : 3. Tous réussis.
- Responsive existant : 42 contrôles à 320 px + 90 balayages. Diagnostic régional et nouveaux tests Budget/récapitulatif couvrent FR/EN/DE à 320 et 390 px ; aucune exception/débordement dans le périmètre testé.
- `flutter analyze --no-pub` : aucun problème. `git diff --check` : code 0.
- Tests ciblés initiaux diagnostic/formats/modèle numérique : 171 réussites, 0 échec.

### Les 13 échecs visuels historiques

Identiques aux catégories déjà documentées en phase 3, références non remplacées : `golden_ar_test.dart`, Landing/choix du parcours/couverture Solo/couverture Famille/inscription en FR et AR (10 échecs ; connexion FR/AR réussie) ; `golden_pantry_test.dart`, Réserve FR/DE/AR (3 échecs). Ils restent à traiter lors de la phase prévue pour les références visuelles. Aucun nouvel échec fonctionnel observé.

## Fichiers de cette phase

Application :
- `lib/l10n/formats.dart` : devises, montant entier exact, symbole explicite hors région d’origine, conversion pieds/pouces.
- `lib/main.dart` : conservation du pays réel et initialisation des nouveaux budgets.
- `lib/onboarding/onboarding_data.dart` : montant/code ISO/statut hérité, restauration et confirmation sans conversion ; aucun changement des calculs nutritionnels.
- `lib/screens/onboarding/budget_screen.dart` : saisie entière, devise homogène, confirmation des hérités, protections des montants dérivés.
- `lib/screens/onboarding/summary_screen.dart` : même montant/code, retour à Budget si devise inconnue ou montant sous borne.
- `lib/screens/onboarding/weekly_grid_screen.dart` : formatage de moyenne.
- Les six ARB `lib/l10n/app_{fr,en,de,es,it,ar}.arb` : paramètres monétaires et messages traduits ; ES/IT/AR conservés. Fichiers de localisation générés régénérés, ignorés par Git.

Tests : `test/phase4_regional_diagnostic_test.dart`, `test/phase4_budget_regression_test.dart`, `test/numeric_model_diagnostic_test.dart` (B09 réactivé). Documentation : `PLAN.md`, `DECISIONS.md`, ce rapport. Le diagnostic préalable reste dans `reports/PHASE4_DIAGNOSTIC_ET_PLAN.md`.

Les autres fichiers Réserve modifiés dans git status appartiennent à la phase 3 et ont été préservés ; leurs fichiers modèles/écrans/tests ainsi que les images Landing ont les mêmes empreintes que le snapshot du diagnostic de phase 4. Dans OnboardingData, les changements de cette phase concernent seulement le budget et sa préservation ; la logique Réserve et les calculs nutritionnels restent inchangés.

## Limites et décisions restantes

- Brouillon local uniquement : aucun branchement Supabase modifié. La future persistance devra enregistrer montant ET code ; un ancien montant ne doit jamais recevoir automatiquement une devise. L’appel explicite restoreBudget constitue le point d’entrée pour cette restauration future.
- 65 initial, minimum 20, curseur 20–350/pas 5 et coefficients familiaux existants restent nominaux et provisoires, sans étude des prix locaux. La saisie personnalisée peut dépasser le curseur comme auparavant. Aucune nouvelle borne produit.
- Les prix de démo et tarifs d’abonnement restent inchangés ; le formatage d’un budget ne transforme pas ces prix en tarifs régionaux. Politique de prix régionaux à décider séparément avant exploitation commerciale.
- Pays actuellement repris depuis l’appareil, aucun écran de pays créé. Pour les pays hors périmètre, le comportement EUR de secours existant reste inchangé ; toute nouvelle politique reste à valider.
- Un budget déjà connu garde sa devise même après changement réel de région ; un éventuel changement monétaire explicite futur nécessitera une politique distincte. Aucun taux ni conversion implémenté.
- Entier hérité très grand affiché exactement ; un montant dérivé hors capacité numérique est déclaré indisponible. Montant ancien sous minimum conservé, poursuite bloquée jusqu’à correction explicite. Pas de normalisation silencieuse.
- Risque résiduel : futurs appels de sauvegarde/restauration doivent utiliser ensemble montant et code ; l’API historique budgetEuros reste nommée ainsi pour éviter une refonte du modèle. Les tests ne constituent pas une validation sur téléphone, aucune installation n’a été réalisée.

Aucun changement Supabase, formule nutritionnelle, Solo 18+, règle Famille, illustration, tarif d’abonnement, prix de démo, commit, push, reset ou clean. Six images Landing provisoires restent non suivies et intactes. Phase 4 terminée dans le périmètre testé, résultat à valider. **Phase 4 bis et phases 5–7 non commencées.**
