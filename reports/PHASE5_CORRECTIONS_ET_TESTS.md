# Phase 5 — B11 : compteur du parcours Famille

Date : 2026-10-09. Projet : C:\Users\simos\Menoo-Flutter-V2. Branche master, commit de référence 4f569a0. Corrections locales des phases 1–4 bis conservées.

## Cause exacte et correction

La source de vérité existe déjà dans lib/onboarding/onboarding_flow.dart : OnboardingFlow.solo contient 11 étapes ; OnboardingFlow.foyer en contient 9. steps(context), number(context, step) et total(context) déduisent les valeurs depuis ces listes.

Tous les écrans principaux utilisent ces fonctions pour le compteur et sa barre de progression. La couverture Solo utilisait déjà OnboardingFlow.solo.length. La couverture Famille passait seule le nombre fixe 10 à commonQuickSteps.

Correction applicative unique : dans lib/screens/onboarding/cover_household_screen.dart:105, commonQuickSteps(10) devient commonQuickSteps(OnboardingFlow.foyer.length). Même widget Text, style AppText.meta, disposition et contenu voisin ; aucune constante ajoutée, aucun composant partagé modifié, aucune étape créée ou supprimée.

| Point | Avant | Après | Preuve |
|---|---|---|---|
| Couverture Famille | 10 étapes annoncées | 9 depuis la liste réelle | Tests six langues ; FR/EN/DE 320/390 px, ES/IT 390 px, AR 320/390 px |
| Écrans Famille | 1/9 à 9/9 déjà dynamiques | Inchangés | Parcours complets et retours, 3 langues × 2 largeurs |
| Couverture et étapes Solo | 11 étapes | Inchangées | Couverture et parcours complets ; source Solo identique |
| Réserve conditionnelle | Hors liste, sans compteur | Inchangée | Mixte/Réserves passent par le hub ; Courses le contourne ; édition du récapitulatif revient correctement |
| Réponses | Modèle partagé entre les écrans | Inchangé | Budget 87 CAD, régime/restriction, allergènes, exclusions, membres, grille et Réserve conservés après avances/retours/édition |

## Audit de chaque étape Famille

| Numéro | Écran | Total affiché | Suite principale |
|---|---|---|---|
| 1 | Composition du foyer | 9 | Profils |
| 2 | Profils des membres | 9 | Grille |
| 3 | Grille hebdomadaire | 9 | Budget |
| 4 | Budget | 9 | Contraintes |
| 5 | Contraintes alimentaires | 9 | Mode de gestion |
| 6 | Mode de gestion | 9 | Types de cuisine, après Réserve si Mixte/Réserves |
| 7 | Types de cuisine | 9 | Ma cuisine |
| 8 | Ma cuisine | 9 | Récapitulatif |
| 9 | Récapitulatif | 9 | Inscription selon les validations existantes |

Solo garde : objectif, profil, activité, balance, grille, budget, mode de gestion, contraintes, cuisines, Ma cuisine, récapitulatif. Le détour Solo 7A suit le mode de gestion et rejoint 8/11 Contraintes ; côté Famille le détour après 6/9 rejoint 7/9 Cuisines. Aucun compteur sur le hub.

Retour : la pile Navigator conserve les écrans précédents. Le détour remplace son hub par l’étape suivante ; revenir depuis cette étape retrouve le mode de gestion. Depuis le récapitulatif, open(...fromSummary:true) puis Continuer ramène au récapitulatif ; mode de gestion avec détour utilise les deux retours déjà présents. Aucun changement de ces règles.

## Traductions et valeurs codées en dur

Les six ARB utilisent commonQuickSteps({count}) et commonStepOf({step}, {total}), sans total 9/10/11 fixe dans ces clés ni les textes de couverture. Aucune traduction ou clé modifiée/supprimée. Les localisations générées restent identiques.

Le nombre 10 exécuté dans la couverture Famille était la seule occurrence incorrecte confirmée pour ce compteur. Quelques commentaires historiques d’écrans mentionnent encore 1/10, 2/10, 3/10, 6/10, 8/10 ou 10/10, et d’anciens totaux Solo 12 : ils ne pilotent ni navigation ni interface. Ils sont signalés pour le futur traitement documentaire, sans refactoring dans cette correction minimale. Autres 9/10/11 trouvés ne sont pas automatiquement des compteurs (jalon Health Connect, tailles/valeurs métier, etc.).

## Tests ajoutés, avant/après

test/phase5_onboarding_count_test.dart contient **42 tests** :
- 2 vérifications des ordres exacts validés Solo/Famille ; aucune Réserve dans les listes.
- 24 couvertures : six langues × deux largeurs × deux modes.
- 12 parcours complets Mixte : FR/EN/DE × 320/390 px × deux modes, contrôle de chaque numéro/total, retours et éditions du récapitulatif.
- 4 parcours Courses/Réserves en FR à 390 px, Solo/Famille ; présence/absence effective du détour vérifiée.

Les parcours appellent les callbacks des boutons Continuer des écrans réels, tapent les boutons de départ et de sortie du hub, utilisent Navigator pour les retours et vérifient les réponses conservées. Les 3 tests de parcours existants continuent également d’exercer les interactions de navigation.

Avant correction : **28 réussites / 14 échecs**. Dix échecs atteignent l’assertion du nombre Famille (10 au lieu de 9) ; quatre échecs sont des débordements préexistants ES/IT à 320 px, qui interrompent le contrôle du texte sur ces écrans. Le code fixe 10 est confirmé pour toutes les langues.

Après correction : **38 réussites / 4 échecs**, tous les échecs de compteur ayant disparu. Les quatre débordements préexistants restent volontairement signalés, sans suppression/ignorance de test ou modification des références.

Suite complète finale : `flutter test --no-pub --reporter json` : **821 réussites / 17 échecs / 0 ignoré**, code 1. Les échecs sont exactement les **13 références visuelles historiques** et les **4 débordements préexistants ES/IT à 320 px** détectés par les nouveaux tests. Aucun échec de compteur, de navigation ou des phases précédentes dans le périmètre de lancement.

Les 783 tests réussis de la référence précédente restent réussis, plus 38 nouveaux contrôles. Les 13 golden historiques restent inchangés : Landing/choix du parcours/couvertures Solo et Famille/inscription FR et AR (10), Réserve FR/DE/AR (3).

Contrôle combiné des nouveaux tests et de test/solo_flow_test.dart : **41 réussites / 4 échecs**, tous ceux-ci ES/IT hors périmètre responsive demandé. Dans ce journal, les **33 contrôles du périmètre FR/EN/DE, des ordres et des parcours existants réussissent**, sans aucun échec. La sélection par nom n’a pas restreint l’exécution aux seuls tests de lancement ; les comptes ci-dessus reflètent les résultats réellement exécutés, sans masquer les quatre échecs.

Une ancienne assertion de test/solo_flow_test.dart:195 attendait 10 étapes rapides. Après B11, elle échouait comme test obsolète. Elle vérifie désormais explicitement 9 étapes rapides, sans affaiblissement de la vérification. La première suite complète avait 820 réussites / 18 échecs, incluant cette assertion ; la dernière confirme sa résolution.

`flutter analyze --no-pub` : **aucun problème**, code 0, après correction de trois avertissements de style dans le nouveau test. `git diff --check` : **aucune erreur**, code 0. Aucun test ignoré, supprimé ou référence visuelle remplacée.

## Limites responsive supplémentaires, distinctes de B11

Les tests élargis aux langues conservées ont détecté quatre débordements de la ligne « étapes rapides · modifiable » à 320 px :

| Langue / couverture | Avant | Après | Classification |
|---|---|---|---|
| ES Solo | 21 px | 21 px | Préexistant, fichier Solo identique |
| IT Solo | 4,1 px | 4,1 px | Préexistant, fichier Solo identique |
| ES Famille | 37 px | 31 px | Préexistant, libellé plus court après B11 |
| IT Famille | 20 px | 14 px | Préexistant, libellé plus court après B11 |

FR/EN/DE à 320 et 390 px passent ; les six langues passent les couvertures à 390 px, AR passe aussi à 320 px. Les débordements ES/IT sont hors du périmètre de rendu de lancement demandé ; corriger leur disposition modifierait le design alors que la phase 5 demande uniquement les valeurs/libellés. Ils restent à traiter séparément après autorisation, sans commencer la phase 7.

## Fichiers modifiés

- lib/screens/onboarding/cover_household_screen.dart:104–108 : seul changement applicatif, total depuis OnboardingFlow.foyer.length.
- test/phase5_onboarding_count_test.dart : nouveau test, assertions et données conservées.
- test/solo_flow_test.dart:195 : assertion obsolète 10 remplacée par le total validé 9.
- reports/PHASE5_CORRECTIONS_ET_TESTS.md : ce rapport.
- PLAN.md et DECISIONS.md : résultat et décision appliquée.

Les journaux phase5_before.log, phase5_after.log, phase5_full_tests.log, phase5_analyze.log et phase5_launch_tests.log sont locaux et ignorés par Git. Les images de différences produites par les tests golden sont des sorties de diagnostic ; aucun fichier de référence golden n’est remplacé.

## Préservation et arrêt

Vérification des empreintes de lib/test/assets/Supabase avant/après : 127 fichiers vérifiés (sources/localisations/tests/migrations et PNG Landing) sont identiques au snapshot initial. Seuls la couverture Famille et l’assertion de test obsolète sont différents parmi les fichiers préexistants ; aucun modèle, traduction ou migration modifié. Aucune écriture dans les assets/illustrations. OnboardingFlow et composants partagés restent identiques. Les sorties générées des différences visuelles sont distinguées des sources.

Aucune modification nutritionnelle, Solo 18+, contraintes phase 4 bis, formats régionaux, devises, données Réserve, règles de composition du foyer ou Supabase. Aucun build d’application/APK, installation Android, commit/push, reset/clean ou suppression de données/assets.

**B11 corrigé dans le périmètre demandé ; arrêt après phase 5. Phases 6 et 7 non commencées. Résultat et limites à valider par Simo avant toute autre intervention.**
