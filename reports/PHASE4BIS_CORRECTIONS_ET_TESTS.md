# Phase 4 bis — restructuration de l’étape 8

Date : 2026-10-09. Projet : C:\Users\simos\Menoo-Flutter-V2. Branche master, référence 4f569a0. Autorisation : décisions produit de Simo pour la phase 4 bis exclusivement.

## Organisation appliquée

Un seul écran, même étape et mêmes parcours :

1. **Régime alimentaire** : Omnivore, Végétarien, Vegan, Pescétarien. Sélection unique. Omnivore correspond à l’absence de code principal, indépendamment des restrictions.
2. **Restrictions alimentaires** : Sans porc, Sans lactose, Sans gluten. Indépendantes et combinables.
3. **Allergies et problèmes alimentaires** : Arachides, Fruits à coque, Œufs, Soja, Crustacés, Mollusques, Céréales contenant du gluten. Déroulant conservé : Poisson, Lait, Sésame, Moutarde, Céleri, Sulfites, Lupin.
4. **Aliments non aimés** : saisie libre existante, ajout par validation/bouton, déduplication sans tenir compte des majuscules, suppression explicite. La liste reste contraignante ; aucune ancienne exclusion n’est rendue facultative.

Styles, composants, pictogrammes, illustrations et parcours existants conservés. La photo fruits_de_mer est réutilisée dans les deux cartes marines ; aucune illustration créée. À 390 px, la grille gère sept cartes avec une dernière cellule seule ; à 320 px elle reste sur une colonne.

## Corrections et preuves avant/après

| Point | Cause avant | Correction minimale | Preuve après |
|---|---|---|---|
| Régime principal | Toggle indépendant des six codes, autorisant plusieurs régimes | selectPrincipalDiet ne remplace que les trois codes principaux, sur action explicite | Tests modèle et interface : Végétarien → Vegan → Pescétarien, restrictions/codes inconnus/allergies intacts |
| Omnivore | diets.clear effaçait aussi les restrictions | Retrait exclusif des codes principaux | Sans porc/lactose/gluten restent indépendants, sans modification de lait/gluten allergènes |
| Anciennes combinaisons | Aucun signalement ni résolution requise | Combinaison conservée, message traduit, continuer désactivé jusqu’au choix explicite | Tests initialisation et résolution ; accès direct au récapitulatif renvoie à l’étape existante sans effacer les réponses |
| Crustacés/mollusques | Carte groupée sélectionnée seulement si les deux codes étaient présents ; résumé ambigu | Deux cartes et deux libellés précis, mêmes identifiants historiques | Quatorze codes uniques ; crustacés seuls, mollusques seuls, profils et récapitulatif indépendants |
| Code gluten | Libellé trop général, confusion possible avec restriction sans_gluten | Code conservé, titre céréales contenant du gluten, texte explicite sans diagnostic implicite | Tous les codes conservés pendant les changements de langue ; aucune conversion vers sans_gluten |
| Profils du foyer | Réutilisaient le choix groupé | Liste commune précise, union des allergies individuelles/communes inchangée | Adultes, enfants et bébés conservés ; enregistrer un profil crustacés seuls conserve ce seul code |
| Anciennes exclusions | Texte libre sans provenance médicale/préférence | Renommage et explication, mêmes valeurs et même caractère contraignant | Saisie, doublon, texte historique conservés ; aucune migration vers une préférence facultative |
| Grille impaire | Accès i+1 sans vérification | Cellule vide si dernière carte seule | FR/EN/DE à 320/390 px sans erreur d’index |
| Libellés longs dans les profils | Badges et puces sur une seule ligne | Option locale de retour à la ligne, activée seulement pour les allergènes familiaux | Trois échecs responsive apparus dans la première suite complète, corrigés ; 125 tests ciblés réussis |
| Codes inconnus | Codes non représentés pouvaient rester invisibles | Conservation, signalement à l’étape et affichage brut au récapitulatif/cartes de profils | Tests de codes hérités ; aucune traduction ou substitution d’identifiant |

## Données et compatibilité

- Aucun identifiant supprimé ou renommé. diets garde ses six codes historiques ; principalDiets et hasDietConflict interprètent uniquement vegetarien/vegan/pescetarien. Les restrictions sans_porc/sans_lactose/sans_gluten restent dans la même structure compatible.
- Les 14 codes d’allergènes sont conservés : arachides, fruits_a_coque, oeufs, soja, crustaces, mollusques, gluten, poisson, lait, sesame, moutarde, celeri, sulfites, lupin. Chaque code possède un seul choix visible.
- Aucune modification automatique d’allergie lors de l’ouverture, du changement de régime, du changement de langue ou de la résolution d’un conflit. Le retrait d’une contrainte commune n’efface pas une allergie du profil d’un membre.
- allAllergens continue d’unir allergies communes et individuelles. La précision des libellés s’applique aussi aux profils et au récapitulatif, sans modifier les données.
- Les textes libres et leur casse enregistrée restent inchangés. Les nouvelles saisies suivent le fonctionnement antérieur. Aucun moteur de préférences facultatives ajouté.
- Les inconnus restent présents, affichés et signalés. La future génération devra traiter leur absence de correspondance explicitement ; ce rapport ne prouve pas qu’un moteur distant sait les filtrer.

## Tests

Avant correction : **42 tests, 0 réussite, 42 échecs attendus**. Six contrôles des identifiants dans les six langues et 36 contrôles interface FR/EN/DE à 320/390 px reproduisent les défauts : sélection multiple, Omnivore destructif, conflit non bloqué, sections incorrectes et regroupement marin.

Après : **42 reproductions réussies**, plus **23 contrôles supplémentaires** = **65 réussites / 0 échec**. Suppléments : résolution par le modèle, code de restriction refusé comme régime, retour depuis récapitulatif, changements entre six langues, conservation des allergies des trois rôles familiaux.

Après correction responsive : `flutter test --no-pub test/phase4bis_constraints_test.dart test/individual_eligibility_test.dart test/family_profiles_ui_test.dart --reporter json` : **125 réussites / 0 échec**, code 0.

Suite complète finale : `flutter test --no-pub --reporter json` : **783 réussites, 13 échecs visuels historiques, 0 test ignoré**. Le lanceur de tests retourne le code 1 du fait de ces références ; la commande d’analyse suivante réussit. Sous-ensemble pertinent hors fichiers golden/démarrage/widget de base : **772 réussites / 0 échec**.

`flutter analyze --no-pub` : **aucun problème**, code 0. `git diff --check` : **aucune erreur**, code 0. L’avertissement de style du nouveau test a été corrigé sans changer ses assertions.

Régressions des phases précédentes dans cette même suite : profils familiaux 22 modèle + 36 interface ; éligibilité Solo/Famille 24 ; champs numériques 81 ; modèle numérique 35 ; caractérisation nutritionnelle 29 ; Réserve 80 diagnostics + 69 contrôles ; formats régionaux 131 diagnostics + 38 contrôles de budget ; conversions 5 ; responsive existant 42 à 320 px + 90 balayages ; parcours Solo/Famille 3. Tous réussis. Les six langues et localisations existantes restent testées. Les fichiers et résultats détaillés sont dans reports/phase4bis_full_tests_final.log (journal local ignoré par Git).

La première suite complète avait 780 réussites et 16 échecs : 13 références visuelles historiques et 3 nouveaux débordements dans les profils à 320 px. Ces trois défauts ont été corrigés dans l’application ; les assertions des tests existants n’ont pas été modifiées.

Les 13 références visuelles historiques concernent Landing/choix du parcours/couverture Solo/couverture Famille/inscription en FR et AR (10), et Réserve FR/DE/AR (3). Elles restent inchangées ; aucun golden remplacé pour masquer un échec.

## Fichiers modifiés dans cette phase

- lib/onboarding/onboarding_data.dart : sélection principale et détection de conflit, commentaire de conservation des exclusions.
- lib/screens/onboarding/constraints_screen.dart : quatre sections, choix individuels, messages et grille impaire.
- lib/screens/onboarding/summary_screen.dart : libellés précis, inconnus visibles et retour à la résolution du conflit.
- lib/screens/onboarding/member_profiles_screen.dart : retour à la ligne des allergènes familiaux, données et règles inchangées.
- lib/widgets/pills.dart et lib/widgets/toggles.dart : option allowTextWrap désactivée par défaut ; styles existants conservés, activation uniquement sur les allergènes des profils.
- Six fichiers ARB FR/EN/DE/ES/IT/AR : sections, descriptions, crustacés/mollusques, céréales, exclusions et messages traduits. Anciennes clés Fruits de mer conservées ; localisations générées régénérées, ignorées par Git.
- test/phase4bis_constraints_test.dart : 65 tests. Aucun test existant affaibli ou supprimé.
- PLAN.md, DECISIONS.md et ce rapport : statut et décisions appliquées.

## Préservation et limites

- 168 fichiers préexistants lib/test/Landing restent identiques au snapshot initial. Les fichiers Formats, MenooApp, Budget, grille hebdomadaire, Réserve, garde-fous numériques et tests antérieurs restent identiques au snapshot initial de cette phase. Les modifications de OnboardingData et SummaryScreen concernent uniquement ce périmètre alimentaire ; aucune formule nutritionnelle changée.
- Les six assets Landing non suivis restent intacts. Aucun asset modifié ou supprimé. Référence Git master/4f569a0 inchangée, aucun commit ni push.
- Le brouillon local reste la représentation actuelle ; aucune sauvegarde Supabase ou nouvelle génération de recettes implémentée. Le futur filtre devra distinguer régime, restrictions, allergènes et exclusions historiques contraignantes. Ne pas assouplir les contraintes médicales pour résoudre un budget impossible.
- Sans lactose n’implique pas sans protéines de lait ; lait et sans_lactose restent indépendants. Gluten est un code historique de céréales, pas un diagnostic d’allergie au blé ou de maladie cœliaque. Aucun mécanisme de certification ou de maîtrise des contaminations croisées n’est ajouté.
- Les nouveaux textes ne promettent pas de protection médicale ou de compatibilité cœliaque. La relecture humaine des six langues pour les allergènes/restrictions et formulations de santé reste nécessaire avant publication ; les tests ne constituent pas cette validation.
- Pas de recherche catalogue ajoutée : la saisie libre est conservée. La clarification des anciennes exclusions et une éventuelle gestion de préférences facultatives restent à décider séparément.
- Aucun test sur téléphone ni installation effectués ; contrôles de widgets et responsive uniquement. Aucun changement Supabase, règles Famille, Solo 18+, nutrition, design ou illustration.

Références du diagnostic : [catégories réglementaires UE](https://eur-lex.europa.eu/legal-content/fr/ALL/?print=true&uri=CELEX%3A32011R1169), [allergie au lait et lactose](https://www.cuh.nhs.uk/patient-information/milk-allergy/), [maladie cœliaque](https://www.worcsacute.nhs.uk/leaflets/coeliac-disease-a-gluten-free-diet/). Ces distinctions ne certifient pas la compatibilité des recettes Menoo.

**Arrêt après phase 4 bis. Résultat à valider par Simo ; phases 5–7 non commencées.**
