# Phase 3 — Corrections B04/B05/B06/B07 et R02

Date : 9 octobre 2026. Référence Git : master, 4f569a0. Corrections autorisées par Simo ; arrêt après phase 3, validation du résultat attendue.

## Résultat avant/après

| ID | Fichiers | Avant | Après / preuve |
|---|---|---|---|
| B04 | food_catalog.dart ; pantry_add_manual_screen.dart | Poireau → fruits/corbeille/7 j ; laitue → laitiers/frigo/10 j ; pommes de terre → fruits/corbeille/7 j | Poireau et laitue → légumes/frigo/5 j selon l’heuristique existante ; pommes de terre crues → légumes/placard/sans date automatique. Expressions complètes et mots délimités ; noms inconnus/composés ambigus → choix manuel. Tests des trois langues et témoins pomme/poire/lait. |
| B05 | food_catalog.dart ; food_images.dart ; pantry_add_manual_screen.dart | Les six suggestions EN et DE perdaient catégorie et image | Suggestions attachées aux mêmes identités, catégories, emplacements, unités et photos existantes dans les six langues. Les photos de catalogue plus précises conservent leur priorité (ex. yaourt grec). Aucun asset modifié. |
| B06 | pantry_values.dart ; onboarding_data.dart ; pantry_quick_check_screen.dart | Deux validations produisaient deux lignes ; langue utilisée comme identité | Clé origine verification_rapide + catégorie stable + emplacement. Validation identique sans mutation ; statut changé actualisé ; produits manuels et lieux différents séparés. Doublons historiques conservés et refus traduit si ambiguïté, avant toute mutation du lot de validations. « Non » ne retire rien. |
| B07 | pantry_values.dart ; onboarding_data.dart ; pantry_add_manual_screen.dart ; pantry_hub_onboarding_screen.dart | Libellé d’unité traduit stocké ; sélection perdue au changement de langue ; statut qualitatif rangé dans une unité | Identifiants piece/gram/kilogram/milliliter/liter/pack ; traduction au rendu. Libellés hérités connus FR/EN/DE/ES/IT/AR reconnus sans réécriture ; libellés inconnus conservés tels quels. Statut séparé. Nouveau stock qualitatif : quantité null et aucune unité physique inventée. Quantités préexistantes et préremplies conservées, sans conversion implicite. |
| R02 | pantry_add_manual_screen.dart | setState après fermeture pendant showDatePicker | Contrôle mounted après await, annulation ignorée, validation normale inchangée. Reproduction fermeture et témoins annulation FR/EN/DE / validation normale passent. |
| Calendrier Réserve | pantry_add_manual_screen.dart ; PantryDraft dans onboarding_data.dart | Test ajouté : raccourci 30 jours tombant un jour trop tôt au passage heure d’hiver | Construction en jours civils et comparaison UTC des composantes de date. Les durées existantes ne changent pas ; heures été/hiver testées. Aucune modification de targetDate ou des projections Solo. |

## Préservation des données et règles validées

- Noms manuels conservés, sans traduction ni capitalisation automatique. Les identifiants internes sont distincts du nom affiché ; deux produits manuels ne sont jamais fusionnés par leur nom ou leur identité alimentaire.
- Les anciens noms, quantités, textes d’unité et dates sont conservés lors d’une actualisation du statut. Une reconnaissance de données héritées n’est pas une migration qui remplace leur contenu.
- Les catégories rapides et leurs métadonnées sont définies ensemble ; l’identité ne dépend pas du numéro de ligne ou de la traduction.
- Si plusieurs anciennes lignes correspondent à la même clé, aucune ligne n’est choisie arbitrairement. La validation reste sur l’écran et explique le problème dans les six langues ; aucune autre catégorie sélectionnée n’est enregistrée partiellement.
- Les emplacements et dates explicitement choisis ne sont jamais écrasés par une détection ou suggestion ultérieure. Les anciennes dates sans provenance restent de provenance inconnue ; aucune origine n’est inventée.
- Une date automatique porte la provenance estimated ; le hub affiche « Estimée » / « Estimated » / « Geschätzt » dans le composant de statut existant, au lieu de présenter cette estimation comme « Frais ». La date choisie par l’utilisateur porte userProvided ; aucune n’est convertie en DLC/DDM officielle.
- Pommes de terre crues : placard proposé, sans date automatique ; cette option représente un lieu frais, sec et sombre, sans garantir les conditions réelles du logement. Les produits cuisinés ou composés non reconnus restent à choisir manuellement.
- Les autres heuristiques sont conservées : fruits 7 j, légumes 5 j, laitier 10 j, viande/poisson 3 j, épicerie 180 j, surgelés 90 j. Ce sont des estimations produit, pas des garanties sanitaires.
- Changer la langue ou l’unité ne convertit ni ne remet à zéro la quantité. Une quantité déjà préremplie n’est plus remplacée par une suggestion suivante ; seules les valeurs initiales de la première suggestion restent celles proposées auparavant. Les choix d’unité sont visibles et modifiables.

## Tests et commandes

Avant correction : `phase3_pantry_diagnostic_test.dart`, **80 cas, 31 réussites / 49 échecs reproduits**. Après correction : **80/80 réussites**. Les mêmes assertions de reproduction restent présentes.

Tests supplémentaires : `phase3_pantry_regression_test.dart`, **69/69 réussites**. Ils couvrent les six langues pour les identités et unités héritées ; changements de statut dans les deux sens ; lieux différents ; produits manuels ; doublons historiques ; refus sans notification ni ajout partiel ; quantités/noms/dates préservés ; statut sans quantité fictive ; noms composés inconnus ; calendrier annulé et jours civils ; rendus et interactions FR/EN/DE à 320/390 px.

Contrôle ciblé final : ces deux fichiers + `detect_test.dart` = **151 réussites, 0 échec** ; journal `reports/phase3_correction_targeted.log`.

Régressions pertinentes :

```powershell
& C:\src\flutter\bin\flutter.bat test --no-pub test/phase3_pantry_diagnostic_test.dart test/phase3_pantry_regression_test.dart test/detect_test.dart test/individual_eligibility_test.dart test/numeric_fields_diagnostic_test.dart test/numeric_model_diagnostic_test.dart test/nutrition_profile_characterization_test.dart test/family_profiles_regression_test.dart test/family_profiles_ui_test.dart test/solo_flow_test.dart test/overflow_320_regression_test.dart test/overflow_sweep_test.dart test/formats_test.dart test/i18n_test.dart test/pantry_hub_i18n_test.dart test/language_picker_test.dart --reporter expanded
```

Résultat : **537 réussites, 0 échec, 1 B09 différé**, code 0 ; journal `reports/phase3_correction_tests.log`. Inclut phases 1 et 2, Solo 18+, Famille et responsive/localisation. La protection finale des noms composés a ensuite été recontrôlée dans les 151 tests ciblés puis dans la suite complète ci-dessous.

`flutter analyze --no-pub` : **No issues found!**, code 0 ; journal `reports/phase3_correction_analyze.log`.

`git diff --check` : code 0, aucune erreur. Les formules nutritionnelles, validations Solo 18+, écrans/règles Famille, OnboardingFlow, Formats, Android, assets, Supabase et références visuelles ne changent pas.

Suite complète finale : **548 réussites, 13 échecs visuels historiques, 1 B09 différé**, code 1 dû uniquement aux références visuelles. Commande `flutter test --no-pub --reporter json`, journal `reports/phase3_full_tests.log`. Les échecs sont détaillés séparément dans la section suivante.

## Échecs visuels historiques et B09 — hors correction de phase 3

- `golden_ar_test.dart` : Landing, choix du mode, couverture Solo, couverture Famille et inscription en FR/AR, soit 10 comparaisons historiques.
- `golden_pantry_test.dart` : Réserve principale FR/DE/AR, soit 3 comparaisons historiques.
- Aucun fichier de référence visuelle n’est remplacé. Les mêmes 13 identités de tests échouaient avant phase 3. Ce constat ne résout pas leurs divergences ; leur traitement reste en phase 6.
- B09 (182 cm → 5 ft 12 in) reste volontairement différé pour la phase 4. Aucune modification de la conversion finie.

## Fichiers modifiés ou ajoutés

| Groupe | Fichiers |
|---|---|
| Nouveaux modèles de Réserve | lib/models/food_catalog.dart ; lib/models/pantry_values.dart |
| Modèles adaptés | lib/models/food_images.dart ; lib/onboarding/onboarding_data.dart (PantryDraft et méthodes de stock rapide uniquement) |
| Écrans Réserve | lib/screens/pantry/pantry_add_manual_screen.dart ; pantry_quick_check_screen.dart ; pantry_hub_onboarding_screen.dart |
| Texte du statut existant | lib/widgets/list_section.dart : paramètre optionnel de libellé, couleurs/police/espacement inchangés |
| Message d’ambiguïté | lib/l10n/app_fr.arb ; app_en.arb ; app_de.arb ; app_es.arb ; app_it.arb ; app_ar.arb |
| Tests | test/phase3_pantry_diagnostic_test.dart ; phase3_pantry_regression_test.dart ; i18n_test.dart |
| Documents | PLAN.md ; DECISIONS.md ; reports/PHASE3_DIAGNOSTIC_ET_PLAN.md (diagnostic historique) ; présent rapport |

Adaptation du test i18n : le catalogue d’alias de reconnaissance est déclaré comme fichier de données non affichées, à l’image du fichier food_images.dart déjà exclu. Ce sont des mots d’entrée (« pommes de terre », etc.), pas des textes d’interface à traduire. Tous les écrans et messages d’interface continuent d’être contrôlés ; aucun échec visuel ou comportemental n’est masqué par cette adaptation.

## Limites résiduelles

1. Dictionnaire local fini : pas de reconnaissance universelle des marques, recettes ou produits transformés. Les noms composés non reconnus demandent un choix manuel plutôt qu’une catégorie déduite d’un mot isolé.
2. Les unités et catégories héritées non reconnues restent intactes. Leur correction éventuelle doit être explicite, pas une déduction automatique.
3. Les doublons historiques ambigus sont volontairement conservés ; la déclaration correspondante ne peut pas être actualisée automatiquement. Aucun outil de suppression/fusion n’est ajouté.
4. Les heuristiques de conservation n’intègrent pas ouverture, température, achat ou état réel. Une date estimée ne remplace jamais une information du fabricant.
5. Les nouveaux champs et quantités qualitatives nulles concernent les brouillons Flutter en mémoire. Le futur branchement de persistance devra enregistrer identifiants, statut et provenance et gérer quantity null ; aucune migration Supabase réalisée ici.
6. Les anciennes dates restent intactes, y compris un éventuel décalage historique : la correction en jours civils ne les réécrit pas.
7. Les 13 références visuelles et B09 demeurent hors périmètre. Les six assets Landing provisoires restent non suivis et intacts.

Aucun commit, push, installation Android, changement Supabase, nouvelle illustration ou suppression. Branche master, dernier commit 4f569a0. Phases 4 à 7 non commencées. Attendre la validation de Simo.
