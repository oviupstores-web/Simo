# SPEC.md — Menoo · Planning v4 (source de vérité)

> **Statut : v4 proposée le 2026-09-30, en attente de la validation de Simo.** Rien de cette version n'est codé.
> Elle intègre les 8 changements de structure du 2026-09-30 et les décisions déjà validées dans `DECISIONS.md`.

Ce document fait foi. En cas de conflit avec un écran Stitch (`design/stitch/`) ou une maquette (`design/maquettes/`), **ce document gagne**.
Les écrans Stitch et les maquettes donnent la structure, les textes et le rendu ; ce document donne l'ordre, les liaisons, les règles et les corrections.

## 0. Règles globales

1. **Design** : `design/DESIGN_V2.md` + écrans maîtres `design/masters/` (prioritaires sur le style Stitch). Vert `#0B6B43` pour les actions, orange `#F58A1F` en accent seulement, fond `#FAFBF8`, cartes blanches rayon 14 px, boutons rayon 14 px, Plus Jakarta Sans. Rendu premium, couleurs douces. Tout est rectangulaire arrondi, **sauf le cercle d'improvisation de l'Accueil** (§7, onglet 1), seule forme ronde de l'app.
2. **En-tête standard** : bouton retour, logo `design/logo.png` (texte alternatif « Menoo »), logotype « Menoo ». Avatar à droite **uniquement une fois le compte créé**. **Les réglages passent par l'avatar** (pas d'onglet Profil).
3. **Barre de navigation unique** (5 onglets, mêmes icônes partout) : **Accueil · Menus · Courses · Réserve · Suivi**. L'onglet « Semaine » est renommé « Menus » partout (icône couverts inchangée). Onglet actif en vert, icône remplie. **La barre ne s'affiche jamais avant la création du compte** : ni pendant l'onboarding, ni pendant le détour Réserve, ni pendant une improvisation lancée sans compte.
4. **Aucun chiffre inventé** : ni note (4,9 ; 4,3), ni nombre d'utilisateurs, ni économie promise. Un chiffre affiché vient soit des réponses de l'utilisateur, soit du catalogue vérifié, soit d'une **source publique citée à l'écran** (ADEME, INSEE…).
5. **Le budget est la contrainte n°1** : aucun menu généré ne dépasse le budget ; le budget apparaît en premier sur les accueils.
6. **Mode Solo / Foyer** : un seul code, des variantes d'écran selon le mode (`_Household` = Foyer).
7. **L'IA ne crée rien** : elle reconnaît des ingrédients et choisit dans le **catalogue** (macros vérifiées, prix connus, photo existante). Une recette générée librement n'arrive qu'en **dernier recours**, marquée « Recette générée par IA, non vérifiée » et **hors budget garanti** (§8).
8. **Photo IA = Premium, saisie = gratuit** : partout, y compris dans le détour Réserve, la reconnaissance par photo est réservée aux abonnés ; la saisie manuelle et le code-barres restent gratuits. L'abonnement achète du confort, pas l'accès.
9. **Le compte arrive après la valeur**, jamais avant (§5).
10. **Origine du prix toujours affichée** : estimation, communautaire ou réel (§10). Quand les prix sont estimés, le badge « Dans le budget ✓ » devient « Estimation dans votre budget ».
11. **Visuels** : aucune référence à l'alcool (app classée 3 ans et plus) ; jamais de silhouette corporelle avant/après.
12. **International** : aucun texte en dur dans le code ; 6 langues au lancement (§10).
13. **Vocabulaire — `landing` et `home` sont deux écrans distincts**, jamais confondus ni fusionnés :
    - **`landing`** = la **page déroulante d'avant le compte** : la promesse, ses 4 avantages, les 4 cartes de fonctions, le bouton « Commencer » collé en bas. Pas de barre de navigation. Elle s'appelle « la Landing » dans tous nos échanges.
    - **`home`** = le **premier onglet de l'app, après connexion** : « Bonjour Karim », le repas du jour, les indicateurs, et le cercle d'improvisation quand aucun repas n'est prévu. Barre de navigation présente. Il s'appelle « l'Accueil ».
    - Le mot « accueil » ne désigne jamais la Landing. Le fichier `design/maquettes/accueil_deroulant.png` montre en réalité la **Landing** : son nom est trompeur (§13).
14. **Un nom = un écran, un écran = un nom.** Règles : minuscules avec tirets bas, pas de numéro d'ordre Stitch, suffixe `_household` pour la variante Foyer (jamais `_foyer`), et le nom sans suffixe est toujours la variante Solo. Les états d'un même écran (gratuit / premium, repos / caméra) ne créent pas un nouveau nom. L'inventaire complet est en §15.

## 1. Entrée

| Écran | Bouton | Va vers |
|---|---|---|
| `landing` | **Commencer** (seul bouton, collé en bas) | `path_choice` |
| `landing` | « J'ai déjà un compte » (lien texte discret dans l'en-tête — *point ouvert n°6*) | `c02_auth_login` |
| `c02_auth_login` | Se connecter / Google | Accueil du mode enregistré |
| `c02_auth_login` | S'inscrire | `c03_auth_signup` |
| `path_choice` | Continuer (Pour moi) | `cover_individual` |
| `path_choice` | Continuer (Pour la famille) | `cover_household` |
| `path_choice` | Ligne légère sous les deux cartes : « Juste une idée pour ce soir ? Improviser avec ce que j'ai » | Improvisation (§8), sans compte |

### `landing` — page déroulante (remplace le carrousel)
Référence visuelle : `design/maquettes/accueil_deroulant.png`.
1. **La promesse en haut** : titre, phrase d'accroche, photo, et ses **4 avantages** (repas variés et équilibrés ; budget maîtrisé chaque semaine ; liste de courses claire ; suivi personnalisé).
2. **4 cartes de fonctions**, chacune avec sa **pastille de couleur** et un **aperçu d'écran** : Scan IA (orange), Menus (corail), Courses (vert), Suivi (lavande).
3. Les cartes **n'ont pas de bouton** et ne sont pas cliquables : ce sont des promesses, pas des fonctions accessibles.
4. **Un seul bouton « Commencer »**, collé en bas pendant tout le défilement, avec « Vos données sont sécurisées » dessous.

Corrections : logo et logotype Menoo de l'app (pas « MENOO » en capitales de la maquette) ; la carte Scan IA précise « Photo réservée aux abonnés, saisie manuelle gratuite » si la règle §0.8 reste sans scan offert (*point ouvert n°1*) ; `path_choice` reste hors compteur.

## 2. Onboarding Solo (12 étapes + écrans de réassurance)

| # | Écran | Fonction | Remarque |
|---|---|---|---|
| — | `cover_individual` | Présentation | — |
| 1 | `onboarding_goal` | Objectif santé | — |
| 2 | `onboarding_profile` | Sexe, âge, taille, poids, poids visé et rythme | Garde-fous : IMC ≥ 18,5, ≤ 1 kg/semaine |
| ★ | `reassurance_weight` | **Trajectoire de poids** | Hors compteur (§4b). Sauté si objectif « maintien » |
| 3 | `onboarding_activity` | Niveau d'activité | — |
| 4 | `onboarding_smartscale` | Balance (option, « Passer ») | — |
| ★ | `reassurance_metabolism` | **Métabolisme** | Hors compteur |
| 5 | `onboarding_weeklygrid` | Repas à planifier | — |
| 6 | `onboarding_budget` | Budget | Curseur (§6) |
| ★ | `reassurance_savings` | **Économies** | Hors compteur |
| 7 | `onboarding_managementmode` | Courses / Réserves / Mixte | + **détour Réserve** (§4) |
| ★ | `reassurance_waste` | **Gaspillage évité** | Hors compteur, après le détour s'il a lieu |
| 8 | `onboarding_constraints` | Régimes, allergènes, exclus | Régimes en pictogrammes |
| 9 | `onboarding_preferences` | Types de cuisine appréciés | Préférence, jamais un filtre bloquant |
| 10 | `onboarding_kitchen` | **Ma cuisine** : niveau, temps, équipements | — |
| 11 | `onboarding_supermarket` | **Enseigne habituelle** | Sert aux prix et au tri par rayon. **Plus de choix Drive / Livraison / En magasin** |
| ★ | `reassurance_ready` | **Plan prêt** | Hors compteur |
| 12 | `onboarding_summary` | Récapitulatif | Bloc « Ma cuisine » + cible kcal |

## 3. Onboarding Foyer (10 étapes + écrans de réassurance)

| # | Écran | Fonction | Remarque |
|---|---|---|---|
| — | `cover_household` | Présentation | — |
| 1 | `onboarding_householdsize` | Adultes, enfants, bébés | — |
| 2 | `onboarding_memberprofiles` | Profil de chaque membre | Pastille avec initiale, allergies par membre |
| 3 | `onboarding_weeklygrid_household` | Repas du foyer | — |
| 4 | `onboarding_budget_household` | Budget | Curseur (§6) |
| ★ | `reassurance_savings` | **Économies** | Hors compteur |
| 5 | `onboarding_constraints_household` | Régimes partagés | — |
| 6 | `onboarding_managementmode_household` | Courses / Réserves / Mixte | + **détour Réserve** |
| ★ | `reassurance_waste` | **Gaspillage évité** | Hors compteur |
| 7 | `onboarding_preferences` | Types de cuisine | — |
| 8 | `onboarding_kitchen_household` | Ma cuisine + qui cuisine | — |
| 9 | `onboarding_supermarket_household` | **Enseigne habituelle** | Plus de choix Drive / Livraison / En magasin |
| ★ | `reassurance_ready` | **Plan prêt** | Hors compteur |
| 10 | `onboarding_summary_household` | Récapitulatif | — |

Le Foyer n'a ni étape balance ni objectif de poids commun : les écrans « trajectoire de poids » et « métabolisme » n'y apparaissent pas.
`onboarding_pantrycheck` reste l'option « vérification rapide » du détour Réserve (Solo et Foyer), hors compteur.

## 4. Détour Réserve (onboarding)

Au bouton « Continuer » de l'écran Mode de gestion :
- **« Courses uniquement »** → étape suivante directement.
- **« Réserves uniquement » ou « Mixte »** → `pantry_home_onboarding` (pas de compteur d'étape, pas de barre de navigation).
  - Depuis ce hub : `onboarding_pantrycheck` (rapide, gratuit), `pantry_addmanual` (gratuit), `pantry_scanbarcode` (gratuit), `pantry_photoai_1` (**Premium**, règle §0.8 : la carte affiche un cadenas et renvoie vers la saisie manuelle ou le code-barres) → chacun revient au hub après ajout.
  - « Terminer et continuer » ou « Passer pour l'instant » → retour à l'étape qui suit le mode de gestion.

## 4b. Écrans de réassurance (5 écrans, hors compteur)

Intercalés dans l'onboarding aux emplacements des tableaux §2 et §3. Un seul bouton « Continuer ». Pas de barre de progression d'étape.

| Écran | Après | Ce qu'il montre | D'où viennent les chiffres |
|---|---|---|---|
| `reassurance_weight` | Profil | La **courbe** de poids projetée : poids actuel → poids visé, date estimée | Réponses de l'utilisateur (poids, cible, rythme) |
| `reassurance_metabolism` | Balance | Le besoin quotidien estimé et la cible calorique | Calcul Mifflin-St Jeor sur ses réponses ; la formule est nommée |
| `reassurance_savings` | Budget | Son budget ramené au repas et à l'année ; ce que le plafond garantit | Son budget et sa grille de repas ; comparaison éventuelle à une moyenne **INSEE citée** |
| `reassurance_waste` | Mode de gestion | Ce que la réserve évite de jeter | Sa réserve si elle est renseignée ; repère **ADEME cité** |
| `reassurance_ready` | Avant le récapitulatif | « Votre plan est prêt » : ce qui va être généré | Ses réponses |

Règles :
- **Jamais de silhouette corporelle avant/après** : on projette la courbe de poids, pas un corps.
- **Aucun chiffre inventé** : chaque chiffre vient des réponses ou d'une source publique dont le nom et l'année sont écrits à l'écran. Les valeurs exactes des sources sont à relever et à vérifier au moment de la construction ; aucune n'est fixée dans ce document.
- Pas de promesse de résultat (« vous perdrez… ») : on parle d'estimation.

## 5. Compte et génération

**Le compte arrive après la valeur.**
- Dès la première ouverture, l'app travaille avec un **compte invité** (invisible pour l'utilisateur). Tout ce qu'il crée avant le compte (réponses d'onboarding, réserve, recette improvisée, recettes débloquées) y est rattaché.
- À la création du compte, le compte invité est **converti** en vrai compte : **aucune donnée n'est perdue ni recopiée**.
- Le bouton Google est formulé comme une **sauvegarde** : « Gardez cette recette et votre réserve » (improvisation) ou « Gardez votre menu » (planification), avec un **« Plus tard » toujours visible**.
- Moments où la sauvegarde est proposée : après la première recette improvisée ; à la fin de l'onboarding, après l'affichage du menu généré ; avant tout achat (un achat exige un compte pour pouvoir être retrouvé).

Parcours planification : `onboarding_summary(_household)` → « Générer mon/notre menu » → `s10_generation_ia_solo` / `f07_generation_ia_foyer` → `menu_blurred(_household)` → proposition de sauvegarde (`c03_auth_signup`, « Plus tard » possible).
`c03_auth_signup` → « Se connecter » → `c02_auth_login`.

## 6. Règles métier

- **Budget** : curseur de 20 € à 350 € (pas de 5 €) + champ « Budget personnalisé » au-delà. Valeur de départ : Solo ≈ 65 € ; Foyer = 30 € × adultes + 20 € × enfants + **25 € × bébés**.
- **Ma cuisine** : niveau (Débutant / Intermédiaire / Confirmé), temps par repas en semaine et le week-end (15, 30, 45, 60+ min), équipements (choix multiple). En Foyer : « Qui cuisine le plus souvent ? ». La génération **exclut** toute recette nécessitant un équipement non coché, dépassant le temps disponible ou au-dessus du niveau.
- **Types de cuisine** : une préférence (Menoo privilégie), jamais un filtre qui bloquerait la génération.
- **Gratuit / payant** (détail §9) :
  - Menu de la semaine : 1 repas affiché en clair (badge « Offert »), les autres floutés avec cadenas.
  - Liste de courses : total estimé, budget et premier rayon en clair ; rayons suivants floutés (modèle `master_courses_gratuit`).
  - Fiche recette : onglets Ingrédients et Ustensiles visibles, Instructions floutées après 3 lignes.
  - Photo IA : réservée aux abonnés.
  - **Plus d'essai de 7 jours** : il exigerait une carte bancaire (*point ouvert n°2*).
- **Courses** : l'enseigne ne sert qu'aux **prix** et au **tri par rayon**. Aucune commande, aucun panier drive, aucune livraison (§7, onglet 3).

## 7. App (après création du compte)

### Onglet 1 — Accueil
`home` (Solo) et `home_household` (Foyer). **Ce n'est pas la Landing** (§0.13) :
1. Salutation + semaine.
2. Carte **Aujourd'hui / Ce soir** : photo, plat, durée, bouton « Voir la recette ».
   **Si aucun repas n'est prévu** : la carte est remplacée par le **cercle d'improvisation** — une **photo ronde du frigo** (≈ 60 % de la largeur, bord blanc, étiquettes d'ingrédients posées autour), sur une carte claire portant la pastille orange « Scan IA », avec le texte « Pas d'idée pour ce soir ? » et le lien « Improviser avec ma réserve ». Pulsation lente de **3,6 secondes** et deux halos fins. C'est la seule forme ronde et la seule animation permanente de l'app ; elle s'arrête si l'utilisateur a désactivé les animations sur son téléphone. Appui → improvisation (§8). Sous la carte, un lien « ou planifier ma semaine ».
   La photo est **celle du frigo seule** : l'illustration avec la main qui tient le téléphone serait illisible à cette taille. La variante montrant une assiette de plat déjà préparé est **abandonnée** : on scanne son frigo pour savoir quoi cuisiner, pas un plat terminé.
3. Extrait **Budget** (en premier) → Suivi > Budget.
4. Extrait **Nutrition** (anneau kcal Solo ; « 4/4 profils dans leur cible » en Foyer) → Suivi > Nutrition.
5. Extrait **Performance** : Solo = Régime (poids, tendance, mini-courbe) ; Foyer = Anti-gaspillage.
6. **Une seule** alerte en bas (Solo : produits à consommer → `pantry_antiwasterecipe` ; Foyer : astuce du chef).

### Onglet 2 — Menus (ex-Semaine)
`menu_blurred(_household)` (état gratuit) / `mealoverview_grid(_household)` (Premium) ⇄ `meallist_filter(_household)` → **fiche recette** (§9) → `recipesteps(_household)` (mode cuisine pas-à-pas) → `mealconfirmation(_household)`.
- Toutes les fiches (`mealdetail_*`, recette improvisée, recette anti-gaspi) utilisent **la même fiche recette à 3 onglets** (§9). `recipeingredientscheck` devient l'onglet Ingrédients.
- `mealconfirmation` (Solo) : boutons « Voir ma liste de courses » et « Accéder au suivi ».
- Un repas improvisé et validé est inscrit dans le menu du jour et compté dans le Suivi.

### Onglet 3 — Courses (sans drive)
`liste_courses` (Solo) ou `liste_courses_household` (Foyer), triée par rayon, réserve déduite. Depuis la liste :
- **Mode magasin** : tri par rayon de l'enseigne, cases à cocher, **total qui se met à jour**, **écran qui reste allumé**.
- **Partager** (feuille de partage Android), **imprimer en A4**, **exporter en PDF**, **copier en texte**.
- Changer d'enseigne : `shoppinglist_supermarketselect` (France : liste ; ailleurs : champ libre, §10). Le comparateur `shoppinglist_pricecompare` compare seulement des **prix** entre enseignes (*point ouvert n°5*).
- **Supprimés** : `shoppinglist_checkout`, `shoppinglist_confirmation`, les boutons « Commander en drive », et toute mention de commande, panier drive ou livraison.
- La liste partagée en temps réel entre membres du foyer est en **phase 2** (non codée).

### Onglet 4 — Réserve
**Emplacement obligatoire pour chaque aliment** : Réfrigérateur, Placard, Congélateur, Corbeille à fruits.
- `pantry_home` : produits regroupés par emplacement, puces de filtre « Tous · Frigo · Corbeille · Placard · Congél. » avec compteur, statut et délai restant. **Entrée permanente vers l'improvisation** (« Cuisiner avec ma réserve »).
- `pantry_addmanual` (gratuit) : emplacement obligatoire, pré-rempli selon la catégorie, modifiable.
- `pantry_scanbarcode` (gratuit) et `pantry_photoai_1` (**Premium**) : après détection, emplacement par défaut de chaque produit, modifiable avant l'ajout.
- Les alertes de péremption indiquent l'emplacement (« Poulet · Réfrigérateur · 2 jours »). Les produits **périmés sont signalés en rouge** d'après les dates en base.
- Données : champ `location` (enum `fridge`, `pantry`, `freezer`, `fruit_basket`) sur `pantry_items`.

`pantry_expiryalert` → `pantry_antiwasterecipe` ; `dashboard_antiwaste` (Solo) accessible d'ici.

### Onglet 5 — Suivi (sous-onglets Budget | Nutrition | Performance)
| Sous-onglet | Solo | Foyer |
|---|---|---|
| Budget | `dashboard_budget` | `dashboard_budget_household` |
| Nutrition | `dashboard_nutrition` | `dashboard_nutrition_household` |
| Performance | `dashboard_diet` (Régime) → `scale_manage`, `weight_manualentry` | `dashboard_antiwaste_household` |

### Réglages (avatar de l'en-tête)
Solo : `settings_profile_solo`. Foyer : `settings_profile` + bloc « Ma cuisine ». On y trouve aussi la langue, le pays, les unités et la **gestion de l'abonnement** (résiliation simple, via Google Play).

### États vides / erreurs
3 composants (réserve vide, aucun menu, hors ligne) affichés dans les écrans concernés.

## 8. Improvisation (jalon 6b, construit avec le paywall §9)

Trouver quoi cuisiner **maintenant** avec ce qu'on a. Parcours en **6 étapes** (compteur « ÉTAPE X SUR 6 »), sans barre de navigation tant qu'il n'y a pas de compte.

| # | Écran | Contenu |
|---|---|---|
| 1 | `improv_scan` | **Scan** du frigo et des réserves (photo : Premium) **ou sélection manuelle** d'ingrédients (gratuit). Onglets Frigo / Garde-manger. **Deux états, voir ci-dessous.** Puis liste « Ingrédients détectés » : cases à cocher, quantité, emplacement, corriger, retirer, ajouter. |
| 2 | `improv_guests` | **Nombre de convives** : valeur du foyer par défaut, réglable en plus ou en moins. |
| 3 | `improv_condiments` | **Condiments à cocher : 6 à 8 cases maximum**, déduites des ingrédients retenus (huiles, épices, bouillons, vinaigres, sauces). En petit : « Sel, poivre et huile sont supposés présents. » |
| 4 | `improv_equipment` | **Équipement disponible**, pré-coché depuis « Ma cuisine » si elle est connue. |
| 5 | `improv_cuisines` | **Choix de cuisine** (voir ci-dessous). |
| 6 | Fiche recette (§9) | **La recette.** |

**Étape 1 — deux états du même écran** (maquette `maquette_6b_cercle_et_cuisines.html`, référence `scan_ia_accueil.png`) :
- **Au repos** : la zone photo n'est qu'un aperçu de ce qui va se passer — l'illustration `assets/images/scan_frigo_main.jpg` (une main qui tient un téléphone devant le frigo ouvert), la pastille orange « Scan IA » et les étiquettes d'ingrédients posées par l'app (jamais dans l'image). Bouton principal « Analyser mes ingrédients ».
- **Caméra active** : un appui sur l'onglet « Frigo » ou « Garde-manger », ou sur le bouton principal, fait disparaître l'illustration ; **la caméra s'active en direct dans cette même zone**, avec un cadre de visée aux quatre coins, une pastille « En direct » et les étiquettes qui apparaissent au fil de la reconnaissance. Le bouton principal devient **« Scanner »** et déclenche la prise de vue ; un lien « Annuler » ramène au premier état.
- Les trois cartes (Prendre une photo, Importer une photo, Saisie manuelle) restent visibles dans les deux états ; celle qui correspond à l'action en cours est marquée. Mentions « Abonnés » ou « Gratuit » sur chacune (§0.8).
- **À trancher** (*point ouvert n°10*) : à quel moment le paywall s'affiche pour une personne non abonnée — dès l'activation de la caméra, ou seulement à l'appui sur « Scanner ».

**Étape 5 — trois états par cuisine**, avec le **nombre de recettes** :
- **Disponible** : tout est là.
- **Presque** : il manque 1 ou 2 éléments, **affichés** (« Il manque : feta »).
- **Indisponible** : grisée, avec **la raison** (« pas de wok », « pas de sauce soja »).
Liste **dépliable** (une cuisine = une ligne qui s'ouvre sur ses recettes), **plusieurs cuisines ouvrables** en même temps, **retour en arrière possible** sans perdre les réponses. Ordre : disponibles, presque, indisponibles. Chaque recette affiche durée, prix par portion et ce qui manque éventuellement.

**Règle centrale** (§0.7) : l'IA reconnaît les ingrédients ; la recherche de recettes est une **correspondance dans le catalogue**. Recette générée librement : seulement si le catalogue ne donne rien, marquée « Recette générée par IA, non vérifiée », sans macros garanties et **hors budget garanti**.

**Le scan met la réserve à jour** :
- produits reconnus absents de la réserve → **ajoutés** (emplacement proposé) ;
- produits de la réserve non retrouvés → proposés au **retrait, avec confirmation** (jamais retirés d'office) ;
- **périmés signalés en rouge** d'après les dates déjà en base. **L'IA ne lit pas les dates sur une photo.**
- Après validation de la recette, les quantités utilisées sont déduites de la réserve, avec confirmation.

**Trois portes d'accès** :
1. `path_choice` : **ligne légère** sous les deux cartes (pas une troisième carte).
2. Accueil : **cercle animé** quand aucun repas n'est prévu (§7, onglet 1).
3. Onglet Réserve : **en permanence**.

**Pont vers la planification** (pour éviter que l'improvisation remplace le menu de la semaine) : après une recette improvisée, une carte propose « Planifier le reste de ma semaine » ; le repas improvisé est inscrit dans Menus et dans le Suivi.

Corrections des maquettes : `scan_ia_accueil` et `scan_ia_ingredients` ont une barre de navigation fausse (§0.3) ; `condiments_equipement` regroupe deux étapes et liste une vingtaine de condiments (ici : 2 étapes, 6 à 8 cases) ; `cuisines_grisees` mélange l'étape d'onboarding « Types de cuisine » et l'étape 5 de l'improvisation (ici : deux écrans distincts).

## 9. Fiche recette et paywall

Référence visuelle : `design/maquettes/fiche_recette_infos.png` et `fiche_recette_ustensiles.png`. Une seule fiche pour toute l'app.

Haut de fiche : photo, durée, kcal, titre, macros (« Informations »). **Trois onglets, dans cet ordre : Ingrédients · Ustensiles · Instructions.**
- **Ingrédients** : entièrement visible (avec ce qui est en réserve et ce qui manque).
- **Ustensiles** : entièrement visible, avec le bandeau « Recette adaptée à votre équipement ».
- **Instructions** : **les 3 premières lignes visibles, le reste flouté.**

Sous le flou, **trois options** :
| Option | Prix |
|---|---|
| Débloquer cette recette | **0,90 €** |
| Abonnement mensuel, résiliable à tout moment | **9,99 € / mois** |
| Abonnement annuel | **49,99 € / an** |

Lots de recettes (*proposition à valider, point ouvert n°4*) : **5 recettes = 3,49 €** (0,70 € l'une), **15 recettes = 7,99 €** (0,53 € l'une).

Règles :
- **Jamais de carte bancaire pour essayer** : ce qui est gratuit est visible sans rien saisir.
- **Résiliation simple dans l'app**, via Google Play Billing (lien direct vers la gestion de l'abonnement).
- Une recette débloquée le reste pour toujours, sur le compte.
- Les mêmes options s'affichent sur le menu flouté et la liste de courses floutée.
- Tant que l'app n'est pas publiée, les achats sont **simulés** (champ `premium` et recettes débloquées dans Supabase).

Corrections des maquettes : ordre des onglets (la maquette met Instructions en premier) ; **« 4,3 note » retiré** (chiffre inventé, §0.4) ; **« Interrogez le coach »** n'est pas retenu dans cette version (*point ouvert n°7*).

## 10. International (avant de créer les recettes)

**Prioritaire** : si les recettes sont créées en français seulement, il faudra tout refaire.
- **Textes de l'app** : internationalisation Flutter, tous les textes sortis du code.
- **Contenus** : tables de traduction pour recettes (titre, étapes), ingrédients, catégories, allergènes, régimes, cuisines, équipements. **Français en référence** ; une traduction manquante retombe sur le français.
- **6 langues au lancement** : français, anglais, espagnol, allemand, italien, arabe.
- **Arabe** : écriture de droite à gauche (mise en page inversée, icônes directionnelles retournées) et police compatible (Plus Jakarta Sans ne contient pas l'alphabet arabe).
- **Unités** : métriques par défaut, impériales aux États-Unis. **Devises et formats de date** selon le pays. Tout est réglable dans les réglages.
- **Enseignes** : France = liste curatée ; ailleurs = **champ libre**. Les noms saisis alimentent une table par pays et deviennent des **suggestions** (après validation, pour éviter les saisies abusives).
- **Prix en trois niveaux**, l'app affichant toujours l'origine :
  1. **Estimation** : prix de référence France, ajusté par un **indice public cité**.
  2. **Communautaire** : Open Prices (couverture réelle par pays **à vérifier** avant de s'appuyer dessus).
  3. **Réel** : tickets de caisse scannés par l'utilisateur.
  Quand les prix sont estimés : badge **« Estimation dans votre budget »** au lieu de « Dans le budget ✓ ».

## 11. Écrans non utilisés ou supprimés
- `shoppinglist_checkout`, `shoppinglist_confirmation` : **supprimés** (plus de drive).
- `pantry_photoai_2` : supprimé (doublon).
- `recipeingredientscheck(_household)` : absorbé par l'onglet Ingrédients de la fiche recette.
- Carrousel de la landing : remplacé par la page déroulante.
- `design/stitch/_assets/` : images de plats, utilisables comme visuels de recettes.

## 12. Données de démo cohérentes
Solo : Karim, 32 ans, 180 cm, 75 kg, objectif perte de poids, budget 65 €. Foyer : famille Martin (Thomas, Sarah, Lucas, Emma), budget 110 €. Mêmes prénoms sur tous les écrans Foyer.

## 13. Maquettes de référence (`design/maquettes/`)
| Fichier | Sert pour | À ne pas reprendre |
|---|---|---|
| `accueil_deroulant.png` | **`landing`** (malgré son nom : ce n'est pas l'Accueil, §0.13) | Logo « MENOO » en capitales |
| `scan_ia_accueil.png` | Improvisation, étape 1 (état au repos) | Barre de navigation ; bandeau et bouton en pilule ; « Estimation des quantités » à présenter comme modifiable |
| `scan_ia_ingredients.png` | Improvisation, étape 1 (liste détectée) | Barre de navigation |
| `condiments_equipement.png` | Improvisation, étapes 3 et 4 | Un seul écran pour deux étapes ; plus de 8 condiments ; le bloc « Niveau en cuisine » |
| `cuisines_grisees.png` | Improvisation, étape 5 (aperçus de recettes, états grisés) | Le compteur « Étape 9 sur 12 » et le titre d'onboarding |
| `fiche_recette_infos.png`, `fiche_recette_ustensiles.png` | Fiche recette (§9) | « 4,3 note », « Interrogez le coach », ordre des onglets |
| `maquette_6b_cercle_et_cuisines.html` | Cercle animé de l'Accueil et étape 5 (proposition de Claude, à valider) | — |

## 14. Points ouverts (à trancher par Simo)
1. **Scan offert ?** La photo IA est Premium, mais la landing promet le Scan IA et l'improvisation est proposée avant le compte. Faut-il 1 scan offert par appareil (ce que l'anti-fraude permettrait de limiter), ou saisie manuelle seulement en gratuit ?
2. **Essai de 7 jours** : supprimé, car incompatible avec « jamais de carte bancaire pour essayer ». À confirmer.
3. **Menu et liste de courses floutés** : conservés, avec les mêmes trois options que la fiche recette. À confirmer.
4. **Lots** : 5 recettes à 3,49 € et 15 recettes à 7,99 €. À valider.
5. **Comparateur de prix entre enseignes** : conservé (il ne sert qu'aux prix) ou supprimé avec le reste du tunnel ?
6. **« J'ai déjà un compte »** sur la landing : lien discret dans l'en-tête, pour respecter « un seul bouton ». À confirmer.
7. **« Interrogez le coach »** (maquettes de la fiche recette) : fonction non décrite ; écartée pour l'instant.
8. **500 recettes** : échéance et découpage (le jalon 5c en prévoit 96).
9. **Traductions des allergènes et des régimes** : relecture par une personne dont c'est la langue, avant publication (une erreur y est un risque de santé).
10. **Paywall du scan** : pour une personne non abonnée, le paywall s'affiche-t-il dès l'activation de la caméra, seulement à l'appui sur « Scanner » (recommandé), ou après un scan offert par appareil ? Lié à la question 1.
11. **Renommages d'écrans** : les 14 corrections proposées en §15 sont-elles adoptées ? Seul le couple `landing` / `home` est déjà appliqué.
12. **Carte « Scan IA » de la Landing** : doit-elle mener à l'écran `improv_scan` ? Cela contredit deux règles déjà écrites — voir §15, note finale.

## 15. Inventaire des noms d'écrans (audit du 2026-09-30)

Règle : **un nom = un écran, un écran = un nom** (§0.14). Seul le couple `landing` / `home` est **déjà appliqué** ; les 14 corrections ci-dessous sont **proposées et attendent la validation de Simo** (*point ouvert n°11*).

### 15.1 Appliqué
| Avant | Après | Pourquoi |
|---|---|---|
| `landing_hook` | **`landing`** | Page déroulante d'avant le compte |
| `dashboard_home` / `dashboard_home_household` | **`home`** / **`home_household`** | Onglet 1 après connexion. Le préfixe `dashboard_` désignait aussi les écrans de Suivi (voir 15.2, ligne A) ; « Dashboard » était en plus un troisième mot pour l'Accueil. Code renommé : `DashboardScreen` → `HomeScreen`, `dashboard_screen.dart` → `home_screen.dart` |

### 15.2 Corrections proposées

**Deux écrans différents qui portaient le même nom, ou presque**

| | Problème | Correction proposée |
|---|---|---|
| A | Le préfixe `dashboard_` couvrait **deux onglets** : l'Accueil (`dashboard_home`) et les sous-onglets de Suivi (`dashboard_budget`, `dashboard_nutrition`, `dashboard_diet`, `dashboard_antiwaste`) | Accueil = `home` (fait). Suivi = **`tracking_budget`**, **`tracking_nutrition`**, **`tracking_weight`**, **`tracking_antiwaste`** |
| B | `dashboard_antiwaste` (Solo, recette anti-gaspi atteinte **depuis la Réserve**) et `dashboard_antiwaste_household` (Foyer, sous-onglet **Performance du Suivi**) : noms quasi identiques, deux emplacements et deux rôles différents | **`pantry_antiwaste`** (Solo, onglet Réserve) et **`tracking_antiwaste_household`** (Foyer, onglet Suivi) |
| C | `pantry_home` (onglet Réserve, avec barre de navigation) et `pantry_home_onboarding` (hub du détour, sans barre ni compteur) | **`pantry_home`** et **`pantry_hub_onboarding`** |
| D | « Régime » désigne à la fois les **restrictions alimentaires** (végétarien, sans gluten — table `diets`) et le **suivi du poids** (`dashboard_diet`). Collision de vocabulaire dangereuse | Le suivi du poids devient **`tracking_weight`**, libellé « Poids ». « Régime » ne désigne plus que les restrictions |
| E | `onboarding_cuisines` (étape d'onboarding, les goûts) et `improv_cuisines` (étape 5, ce qui est faisable ce soir) sont proches, et la maquette `cuisines_grisees.png` mélange les deux | Noms conservés, mais les préfixes `onboarding_` et `improv_` sont **obligatoires** ; jamais de « écran cuisines » tout court |

**Un même écran qui portait deux noms**

| | Problème | Correction proposée |
|---|---|---|
| F | SPEC : `onboarding_preferences` · Code : `CuisineTypesScreen` / `cuisine_types_screen.dart` | **`onboarding_cuisines`** partout |
| G | SPEC : `onboarding_pantrycheck` · Code : `PantryQuickCheckScreen` | **`pantry_quickcheck`** partout (hors compteur, donc sans préfixe `onboarding_`) |
| H | SPEC : `pantry_home_onboarding` · Code : `PantryOnboardingHubScreen` | **`pantry_hub_onboarding`** partout |
| I | SPEC : `liste_courses(_household)` (français) et `shoppinglist_*` (anglais) pour le même onglet · Code : `ShoppingListFreeScreen` | **`shopping_list`** / **`shopping_list_household`**, avec deux **états** (gratuit, premium) et non deux écrans. Le reste du tunnel garde le préfixe `shopping_list_` |
| J | `mealdetail_breakfast`, `mealdetail_*`, `recipeingredientscheck` désignaient des morceaux de **la même** fiche recette (§9) | **`recipe_sheet`** unique, avec ses 3 onglets. `recipeingredientscheck` disparaît |
| K | `menu_blurred(_household)` (gratuit) et `mealoverview_grid(_household)` (premium) sont **deux états** d'un même écran | **`menus_grid`** / **`menus_grid_household`**, états gratuit et premium. La vue liste devient **`menus_list`** |
| L | `s10_generation_ia_solo` et `f07_generation_ia_foyer` : numérotation Stitch, et suffixe `_foyer` au lieu de `_household` | **`generation`** / **`generation_household`** |
| M | `c02_auth_login`, `c03_auth_signup` : numérotation Stitch | **`login`**, **`signup`** |
| N | `settings_profile` = **Foyer** et `settings_profile_solo` = **Solo** : l'inverse de la règle (le nom nu est le Solo) | **`settings`** (Solo) / **`settings_household`** (Foyer) |
| O | `pantry_photoai_1` : le `_1` venait de `pantry_photoai_2`, supprimé | **`pantry_photoai`** |
| P | `cover_individual` alors que le mode s'appelle **Solo** partout ailleurs (`AppMode.solo`) | **`cover_solo`** |

### 15.3 Noms de maquettes trompeurs (fichiers de Simo, à renommer si tu veux)
- `accueil_deroulant.png` montre la **Landing**, pas l'Accueil → `landing_deroulante.png`.
- `scan_ia_accueil.png` montre l'**écran d'accueil du Scan IA**, pas l'Accueil de l'app → `scan_ia_ecran1.png`.

### 15.4 La carte « Scan IA » de la Landing mène-t-elle à l'écran Scan IA ?
**Ce n'est pas prévu aujourd'hui, et cela contredit deux règles déjà écrites :**
1. §1 : « Les cartes **n'ont pas de bouton et ne sont pas cliquables** : ce sont des promesses, pas des fonctions accessibles » — reprise mot pour mot de la demande du 2026-09-30.
2. §8 : l'improvisation a **trois portes d'accès** (ligne sous `path_choice`, cercle de l'Accueil, onglet Réserve). Un lien depuis la Landing en ferait une quatrième.

Trois façons de lever la contradiction, **à trancher** (*point ouvert n°12*) :
- **(a)** Garder les cartes inertes. La porte d'entrée avant compte reste la ligne légère de `path_choice`, atteinte par « Commencer ».
- **(b)** Rendre la seule carte Scan IA cliquable, vers `improv_scan`. Il faut alors réécrire la règle §1 et accepter une quatrième porte.
- **(c)** Garder les cartes inertes, mais ajouter sur la Landing, sous le bouton « Commencer », la même ligne légère que sur `path_choice`.

Recommandation : **(c)**. Elle donne l'accès direct que tu cherches sans rendre les cartes cliquables et sans multiplier les chemins, puisque c'est la même ligne qu'ailleurs.
