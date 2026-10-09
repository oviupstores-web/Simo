# Rectification des règles produit — Individuel 18+ et Famille

Date : 9 octobre 2026. Périmètre autorisé uniquement ; phases 3 à 7 non commencées.

## Résultat

- Individuel : borne 18–100 ans appliquée aux champs, validations, modèle, calculs et navigation. Taille 120–230 cm, poids 35–250 kg et cible maximale provisoire 250 kg inchangés.
- Les anciens profils mineurs restent enregistrés en mémoire ; aucune valeur n’est remplacée automatiquement. Le récapitulatif et les accès directs aux écrans physiques renvoient au formulaire. La saisie explicite de 18 ans permet de reprendre le parcours, avec conservation de la cible existante.
- Famille : fiches et récapitulatif sans objectif physique ni sélection d’activité nutritionnelle. Les accès directs aux écrans physiques Solo montrent la composition du foyer ; la couverture Solo ouverte en Famille montre la couverture Famille.
- Calories personnalisées, macros et projections Solo indisponibles en mode Famille, même si un ancien objectif est injecté. Aucun moteur familial ajouté.
- Identifiants, prénoms, mensurations, profils enfants/bébés, allergies et exclusions communes conservés. Les anciens champs goal/activity ne sont pas supprimés ; ils ne sont plus proposés ni utilisés pour recommander une transformation familiale.
- Formules BMR, activité, calories, planchers et macros inchangées pour les adultes Solo éligibles. Les références numériques ordinaires, fortes corpulences et sportifs fictifs restent vérifiées.

## Preuves avant/après

| Cas | Avant correction | Après correction | Preuve |
|---|---|---|---|
| Solo 17 ans | Validation sans erreur ; calculs adultes possibles | Erreur traduite 18–100 ; calories/macros/projections indisponibles | individual_eligibility_test.dart et nutrition_profile_characterization_test.dart |
| Solo 18 ans | Accepté | Accepté ; calculs et navigation opérationnels | Modèle et saisie réelle FR/EN/DE à 320/390 px |
| Ancien profil 17 ans, cible 70 kg | Peut atteindre le récapitulatif physique | Renvoi au profil ; 17 refusé, 18 explicitement accepté ; cible conservée | Test de saisie depuis SummaryScreen |
| Famille avec objectif prise de masse hérité | Getter calorique = 3 040 kcal | Getters calories/macros/durée/date = null ; objectif hérité conservé | Régression modèle FR/EN/DE |
| Objectifs dans fiches familiales | Choix perte/prise/sèche/maintien et badges adultes | Choix et badges retirés ; résumé sans objectif par membre | Tests de fiches et récapitulatif FR/EN/DE à 320/390 px |
| Accès direct à un écran physique | Pas de contrôle de mode/âge à la navigation | Contrôle du mode, de l’âge et du récapitulatif ; aucune recommandation mineure/familiale | Tests d’accès directs et de navigation |
| Catégories familiales | Adulte 14–100, enfant 4–13, bébé 0–3 | Inchangées, indépendantes de Solo | Assertions modèle et régressions phase 1 |

Reproduction avant correction : `flutter test test/individual_eligibility_test.dart --reporter expanded`, 9 tests : **3 réussites, 6 échecs attendus**, refus 17 ans absent et calcul calorique familial encore disponible. Après correction, le fichier enrichi contient **24 tests réussis**.

## Tests finaux

Commande exécutée :

```powershell
& C:\src\flutter\bin\flutter.bat test --no-pub test/individual_eligibility_test.dart test/numeric_fields_diagnostic_test.dart test/numeric_model_diagnostic_test.dart test/nutrition_profile_characterization_test.dart test/family_profiles_regression_test.dart test/family_profiles_ui_test.dart test/solo_flow_test.dart test/overflow_320_regression_test.dart test/overflow_sweep_test.dart test/formats_test.dart test/i18n_test.dart test/pantry_hub_i18n_test.dart test/language_picker_test.dart --reporter expanded
```

Résultat final : **386 réussites, 0 échec, 1 test B09 différé**, code de sortie 0. Preuve intégrale : `reports/rectification_tests.log`.

Inclut les 24 nouveaux contrôles d’éligibilité, les 115 régressions R01, les 58 tests de phase 1, les 29 caractérisations nutritionnelles, les parcours Solo/Famille et les contrôles responsive/localisation FR/EN/DE. Les tests Solo utilisant l’ancienne borne 14 ans sont adaptés à 18 ; les âges 14–17 restent présents comme cas de refus. Les fixtures responsive des écrans physiques sont désormais en mode Solo pour tester leurs contenus réels.

`flutter analyze --no-pub` : **No issues found!**, code 0 ; preuve `reports/rectification_analyze.log`.

`git diff --check` : code 0, aucune erreur de diff. Les messages Git LF/CRLF concernent des fichiers déjà modifiés des phases précédentes, sans échec.

La suite de références visuelles n’a pas été relancée : ses 13 échecs précédemment documentés restent à examiner en phase 6 ; ce rapport ne les présente pas comme un résultat courant. Aucune image de référence remplacée. B09 reste volontairement hors périmètre (phase 4).

## Fichiers de cette rectification

| Groupe | Fichiers |
|---|---|
| Modèle et navigation | lib/onboarding/onboarding_data.dart ; lib/onboarding/onboarding_flow.dart |
| Contrôles d’accès Solo | lib/screens/onboarding/cover_solo_screen.dart ; goal_screen.dart ; profile_screen.dart ; activity_screen.dart ; smart_scale_screen.dart |
| Famille et récapitulatif | lib/screens/onboarding/member_profiles_screen.dart ; summary_screen.dart |
| Traductions | lib/l10n/app_fr.arb ; app_en.arb ; app_de.arb ; app_es.arb ; app_it.arb ; app_ar.arb (borne 18, localisations générées automatiquement) |
| Tests ajoutés/adaptés | test/individual_eligibility_test.dart ; numeric_fields_diagnostic_test.dart ; numeric_model_diagnostic_test.dart ; nutrition_profile_characterization_test.dart ; overflow_320_regression_test.dart ; overflow_sweep_test.dart |
| Documentation | PLAN.md ; DECISIONS.md ; reports/PHASE2_B_AUDIT_SCIENTIFIQUE.md ; présent rapport |

Les autres changements locaux préexistants des phases 1 et 2 restent conservés. Les illustrations Landing non suivies déjà présentes ne sont pas touchées.

## Incohérences et limites restantes

1. Le libellé familial « adulte » inclut encore les 14–17 ans. Il s’agit d’une catégorie du foyer, sans éligibilité Solo ni objectif physique. La sélection du cuisinier suit ces catégories existantes ; enfants et bébés restent exclus. Aucune reclassification décidée dans cette mission.
2. PRD.md ligne 105 mentionne encore « calories et macros, par membre en mode Foyer ». Cette ancienne proposition contredit la décision actuelle. PLAN.md, DECISIONS.md et l’audit B consignent la règle validée ; aucun moteur ou écran de recommandations familiales par membre n’est ajouté. PRD/SPEC historiques ne sont pas réécrits dans cette correction limitée.
3. Les anciens champs goal/activity des membres restent conservés pour éviter une suppression de données. Tout futur consommateur doit respecter le périmètre Famille sans transformation.
4. Les migrations SQL locales contiennent encore des contraintes et bornes différentes ; aucune intervention Supabase. Une future connexion de données doit conserver les contrôles Flutter et respecter les décisions produit.
5. Les promesses d’adaptation des portions et les facteurs 1/0,65/0,3 ne constituent pas un moteur familial actuellement vérifié ni des prescriptions pédiatriques. Aucune implémentation nouvelle dans cette mission.
6. L’âge minimal produit 18 ans ne valide pas scientifiquement toute estimation à 18 ans, ni pour chaque sportif ou forte corpulence. Incertitude des équations, disponibilité énergétique et divergence entre plancher calorique et projection restent à valider dans l’audit B ; aucune formule changée.
7. L’éligibilité repose sur l’âge déclaré ; aucune vérification d’identité ou de date de naissance n’est introduite. Un âge inférieur à 18 stocké ou saisi est refusé ; le logiciel ne peut pas vérifier la véracité d’un âge déclaré adulte.

Branche finale : master. Dernier commit : f37797b. Aucun commit/push, installation Android, changement Supabase, design ou illustration. Arrêt après cette rectification ; attente de Simo pour toute suite.
