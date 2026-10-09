# Phase 3 — Diagnostic Réserve et plan à valider

Date : 9 octobre 2026. Référence : master, 4f569a090b9cdab95b5d8891894857e04cdbd3b3.

## Statut

Diagnostic et tests de reproduction seulement. Aucune correction applicative effectuée. Les choix métier de déduplication restent à valider par Simo avant correction. Phases 4 à 7 non commencées. Les six illustrations Landing provisoires non suivies restent intactes.

## Anomalies confirmées

| ID | Fichier / ligne | Cause | Preuve avant correction | Correction minimale proposée |
|---|---|---|---|---|
| B04 | lib/screens/pantry/pantry_add_manual_screen.dart:41 et :125–129 | Recherche par sous-chaîne ; fruits avant légumes ; pas d’alias précis pour pomme de terre | Poireau → fruits/corbeille/7 jours ; Laitue → laitiers/frigo/10 jours ; Pommes de terre → fruits/corbeille/7 jours | Reconnaître mots et expressions complets ; privilégier les expressions précises ; séparer aliment/catégorie et proposition de conservation |
| B05 | même fichier :146–152 et :322–343 ; lib/models/food_images.dart:61–70 | Libellés traduits analysés par des règles françaises ; vignettes déduites du texte affiché | Les 6 suggestions EN et les 6 DE ont une catégorie null et ne retrouvent pas leurs 12 photos françaises existantes | Identifiants internes des suggestions ; catégorie, unité, emplacement et image existante attachés à ces identifiants ; aliases FR/EN/DE pour saisie libre |
| B06 | lib/screens/pantry/pantry_quick_check_screen.dart:45–62 | Chaque validation ajoute des lignes sans chercher un stock rapide déjà déclaré | Deux validations de la catégorie pâtes/riz donnent 2 lignes, en FR/FR, FR/EN et FR/DE | Une déclaration rapide par clé stable source + catégorie rapide + emplacement, sans fusion avec produits manuels |
| B07 | lib/onboarding/onboarding_data.dart:143–156 ; pantry_add_manual_screen.dart:145 et :239 ; pantry_hub_onboarding_screen.dart:389–393 | L’unité est un texte traduit ; stock qualitatif aussi enregistré dans unitLabel | Une unité « pièce(s) » sélectionnée en FR cesse d’être sélectionnée en EN/DE ; les 2 pièces héritées ne s’affichent pas comme 2 items/2 Stück | Identifiants d’unité stables ; affichage traduit seulement ; conserver libellés hérités inconnus ; séparer statut qualitatif et unité physique |
| R02 | lib/screens/pantry/pantry_add_manual_screen.dart:207–220 | setState après await showDatePicker sans contrôle mounted | Retrait de la route du formulaire pendant le calendrier puis validation : setState() called after dispose, pile :216 | Après await : if (!mounted || picked == null) return ; conserver le comportement normal |

Les lignes citées correspondent au code applicatif inchangé du commit 4f569a0.

Poire et pomme restent correctement reconnues comme fruits ; lait reste classé en laitiers. La correction doit conserver ces cas. Les tests poireau/laitue à frigo/5 jours caractérisent la proposition déjà existante du groupe légumes, pas une validité sanitaire de cinq jours.

R02 : scénario de retrait de route simulé par le test (par exemple un remplacement de navigation pendant la boîte modale). Le simple retour arrière ferme normalement la boîte de dialogue en premier ; aucun crash de ce parcours normal n’est affirmé. La validation ordinaire du calendrier passe également le test témoin.

## Règles d’identification proposées

1. Suggestions : identifiants fixes, par exemple avocado, salmon, eggs, pasta, yogurt, milk ; les traductions changent le libellé, jamais l’identité, la catégorie ou l’unité. Les six langues existantes restent disponibles. Les photos existantes sont réutilisées, sans nouvel asset ni modification d’illustration.
2. Saisie libre : aliases explicites FR/EN/DE, mots complets et expressions composées prioritaires. Pas de rapprochement approximatif de noms, pas de suppression arbitraire des fins de mots. Poireau et poire, laitue et lait, pommes de terre et pomme restent distincts. Produits inconnus ou ambigus : pas de classification inventée, choix manuel disponible.
3. Identité alimentaire et identité de ligne de réserve sont différentes : deux produits d’un même aliment peuvent représenter des achats, préparations ou lots distincts. La reconnaissance d’un aliment ne déclenche pas une fusion des lignes manuelles.
4. Vérification rapide : les entrées représentent des catégories de stock, pas des aliments précis ni des poids mesurés. Identifiants de catégories stables tels que pasta_rice_starches, eggs_dairy, fresh_vegetables, frozen_meat_fish ; ne pas utiliser l’ordre de la liste ou son libellé traduit comme identité.

## Déduplication — choix métier soumis à validation

Proposition conservatrice recommandée :

- Même déclaration rapide = source verification_rapide + identifiant de catégorie rapide + emplacement.
- Une validation identique répétée ne crée rien et ne cumule pas une quantité fictive.
- Si une déclaration unique existante passe de « Présent » à « Quelques restes », mettre à jour son statut ; ne pas créer une deuxième ligne. Cette règle de remplacement du statut attend l’accord de Simo.
- « Non » ne supprime aucun stock existant dans cette phase. Il signifie absence de nouvelle déclaration pour la catégorie ; une éventuelle future gestion de retrait est une décision séparée.
- Produits ajoutés manuellement : jamais fusionnés automatiquement, même si leur nom ressemble à une catégorie rapide. Produits de lieux différents : toujours distincts. Aucune conversion de quantité, regroupement d’unités, fusion de lots ou modification de dates implicite.
- Entrées historiques rapides : reconnaître uniquement leur source et leur libellé exact parmi les traductions connues, avec emplacement cohérent. Ne pas modifier leur nom original ou leur quantité lors d’un changement de langue.
- Doublons historiques déjà présents : les conserver, sans suppression ni fusion ; bloquer l’ajout d’une nouvelle déclaration identique. Si plusieurs anciennes lignes rendent une mise à jour de statut ambiguë, préserver les lignes et signaler le cas plutôt que choisir arbitrairement une ligne.

Alternative : ignorer toute validation d’une catégorie déjà présente, même quand le statut change. Cela évite les doublons mais empêche de corriger « Présent » en « Quelques restes » depuis cet écran. Simo doit valider l’une des politiques avant implémentation.

## Unités — compatibilité proposée

- Identifiants internes : piece, gram, kilogram, milliliter, liter, pack, indépendants des six langues.
- Traduction au rendu uniquement, y compris dans le formulaire ouvert pendant un changement de langue et dans le hub.
- Préserver toutes les quantités déjà saisies. Un changement de langue ne transforme pas g en kg, ne réinitialise pas la quantité et ne convertit pas les données.
- Reconnaître les anciens libellés connus des six langues, singuliers/pluriels inclus ; conserver un libellé historique brut si sa signification est inconnue. Aucune unité devinée.
- « En stock » et « Quelques restes » sont des statuts, pas des unités. Les stocker séparément pour les catégories rapides ; ne pas en déduire une quantité alimentaire précise. La quantité historique n’est ni supprimée ni additionnée.
- Les noms manuels libres ne sont pas traduits automatiquement. Le nom affiché d’une catégorie rapide reconnue peut utiliser sa traduction actuelle tout en préservant son texte original stocké.

## Conservation et durées — limites et décision nécessaire

Les durées existantes sont des heuristiques par catégorie : fruits 7 jours, légumes 5, laitier 10, viande/poisson 3, épicerie 180, surgelés 90. Le logiciel ne connaît ni date d’achat, ni ouverture, ni température effective, ni état du produit. Elles ne sont pas des garanties sanitaires ou des dates d’emballage.

Pour poireau et laitue, corriger la confusion ramènerait la suggestion au groupe légumes/frigo/5 jours existant ; cette valeur reste une estimation produit et n’est pas validée cliniquement par les tests. Les choix manuels d’emplacement et de date doivent rester prioritaires.

Pommes de terre crues : proposer « Légumes » et « Placard » pour représenter un endroit frais, sec et sombre, conformément au [Ministère de l’Agriculture](https://agriculture.gouv.fr/fruits-et-legumes-moches-et-guide-de-conservation-des-legumes). Ce placard est une approximation d’emplacement dans les quatre options existantes, pas une garantie de température réelle. Ne pas appliquer automatiquement les 180 jours de l’épicerie : catégorie et emplacement doivent rester indépendants.

Proposition à valider : **aucune date automatique pour les pommes de terre**, tant qu’une durée produit appropriée n’a pas été décidée. Le calendrier et les raccourcis de date existants restent disponibles. Ne pas inventer une nouvelle durée fixe. Les tests de classification ne verrouillent pas une durée de pomme de terre.

Préserver l’origine d’une date (estimée ou choisie par l’utilisateur) pour éviter qu’une estimation soit ensuite présentée comme une péremption vérifiée dans le hub. La mention d’estimation doit utiliser les emplacements textuels existants, sans nouveau design. Les instructions et dates du fabricant ne doivent pas être remplacées par ces heuristiques. [FSA, guide du stockage et de l’étiquetage](https://www.food.gov.uk/sites/default/files/media/document/sfbb-retailers-pack-jan-2020_0_0_4.pdf).

## Plan de correction après accord

1. B04/B05 : identifiants de suggestions et aliases complets ; règles de classification précises ; métadonnées de conservation distinctes des catégories ; photos existantes référencées directement.
2. B07 : unités stables et compatibilité des libellés hérités ; état du formulaire indépendant de la langue ; statut rapide séparé.
3. B06 : appliquer uniquement la règle de déduplication validée, centralisée dans le modèle ; préserver toutes les lignes et valeurs historiques. Ajouter les cas statut modifié, lieux différents, variantes de produits et anciennes données ambiguës.
4. R02 : contrôle mounted après le calendrier, avec témoins fermeture/annulation/validation normale ; aucun changement de navigation.
5. Compléter les tests, faire passer les reproductions ; contrôler les saisies/suggestions FR/EN/DE et les six langues conservées, les unités héritées et les changements de langue.
6. Analyse Flutter, tests Réserve, parcours Solo/Famille, protections phases 1/2, responsive 320/390. Les références visuelles obsolètes et B09 restent hors de cette phase.
7. Actualiser PLAN.md et DECISIONS.md avec les règles effectivement validées ; présenter le résultat avant/après ; arrêter avant phase 4. Aucun commit/push, installation, Supabase ou suppression.

Fichiers applicatifs susceptibles d’être concernés après accord : pantry_add_manual_screen.dart, pantry_quick_check_screen.dart, pantry_hub_onboarding_screen.dart, onboarding_data.dart, food_images.dart et un petit modèle partagé d’identifiants alimentaires/unités si nécessaire. Aucun fichier applicatif n’a été modifié pendant ce diagnostic.

## Tests et preuves

Nouveau fichier : test/phase3_pantry_diagnostic_test.dart, **80 cas : 31 réussites, 49 échecs attendus**. Ces échecs restent volontairement visibles avant correction autorisée : classification 15, propositions poireau/laitue 2, suggestions EN/DE 12, photos existantes EN/DE 12, validations répétées 3, unités/changement de langue 4, calendrier après fermeture 1. Contrôles positifs : 18 rendus FR/EN/DE × 320/390 px × ajout/vérification/hub, cas alimentaires déjà corrects, inconnus, produits manuels distincts et calendrier normal.

Commande finale :

```powershell
& C:\src\flutter\bin\flutter.bat test --no-pub test/phase3_pantry_diagnostic_test.dart test/detect_test.dart test/pantry_hub_i18n_test.dart test/solo_flow_test.dart test/family_profiles_regression_test.dart test/family_profiles_ui_test.dart test/individual_eligibility_test.dart test/numeric_model_diagnostic_test.dart test/numeric_fields_diagnostic_test.dart test/nutrition_profile_characterization_test.dart --reporter expanded
```

Résultat : **275 réussites, 49 échecs reproduisant exclusivement les défauts de phase 3, 1 test B09 différé**, code 1 attendu. Les **244 régressions existantes vérifiées passent**, notamment Réserve existante, parcours Solo/Famille, profils familiaux, éligibilité 18+ et protections R01. Il ne s’agit pas de la suite complète ni d’une validation après correction. Journal local ignoré : reports/phase3_diagnostic.log.

`flutter analyze --no-pub` : aucun problème, code 0. `git diff --check` : aucune erreur. Code applicatif inchangé par comparaison Git avec 4f569a0 ; fichiers de diagnostic uniquement. Les propositions de déduplication et la politique de date des pommes de terre attendent l’accord de Simo.
