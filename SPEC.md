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
8. **Photo IA = Premium, saisie = gratuit, avec un scan offert** : partout, y compris dans le détour Réserve, la reconnaissance par photo est réservée aux abonnés ; la saisie manuelle et le code-barres restent gratuits. L'abonnement achète du confort, pas l'accès.
   **Un scan est offert par appareil** : sans lui, la promesse « Scan IA » de la Landing serait trompeuse. Le compte n'est pas nécessaire pour l'utiliser. Le paywall n'apparaît qu'**après** ce scan offert, jamais avant : on voit son écran avant qu'on lui demande de payer. Le quota est tenu **côté serveur** par l'identifiant d'appareil du jalon 12b (§16) — jamais dans l'app, qu'une réinstallation remettrait à zéro.
9. **Le compte arrive après la valeur**, jamais avant (§5).
10. **Origine du prix toujours affichée** : estimation, communautaire ou réel (§10). Quand les prix sont estimés, le badge « Dans le budget ✓ » devient « Estimation dans votre budget ».
11. **Visuels** : aucune référence à l'alcool (app classée 3 ans et plus) ; jamais de silhouette corporelle avant/après.
12. **International** : aucun texte en dur dans le code ; 6 langues au lancement (§10). Une **vérification automatique** (`test/i18n_test.dart`) échoue si un texte d'interface reste en dur ; sa liste d'écrans encore à traduire doit finir vide.
13. **Vocabulaire — `landing` et `home` sont deux écrans distincts**, jamais confondus ni fusionnés :
    - **`landing`** = la **page déroulante d'avant le compte** : la promesse, ses 4 avantages, les 4 cartes de fonctions, le bouton « Commencer » collé en bas. Pas de barre de navigation. Elle s'appelle « la Landing » dans tous nos échanges.
    - **`home`** = le **premier onglet de l'app, après connexion** : « Bonjour Karim », le repas du jour, les indicateurs, et le cercle d'improvisation quand aucun repas n'est prévu. Barre de navigation présente. Il s'appelle « l'Accueil ».
    - Le mot « accueil » ne désigne jamais la Landing. Le fichier `design/maquettes/landing.png` montre en réalité la **Landing** : son nom est trompeur (§13).
14. **Un nom = un écran, un écran = un nom.** Règles : minuscules avec tirets bas, pas de numéro d'ordre Stitch, suffixe `_household` pour la variante Foyer (jamais `_foyer`), et le nom sans suffixe est toujours la variante Solo. Les états d'un même écran (gratuit / premium, repos / caméra) ne créent pas un nouveau nom. L'inventaire complet est en §15.

## 1. Entrée

| Écran | Bouton | Va vers |
|---|---|---|
| `landing` | **Commencer** (seul bouton, collé en bas) | `path_choice` |
| `landing` | « J'ai déjà un compte » (lien texte discret dans l'en-tête — *point ouvert n°6*) | `login` |
| `login` | Se connecter / Google | Accueil du mode enregistré |
| `login` | S'inscrire | `signup` |
| `path_choice` | Continuer (Pour moi) | `cover_solo` |
| `path_choice` | Continuer (Pour la famille) | `cover_household` |
| `path_choice` | Ligne légère sous les deux cartes : « Juste une idée pour ce soir ? Improviser avec ce que j'ai » | Improvisation (§8), sans compte |

### `landing` — page déroulante (remplace le carrousel)
Référence visuelle : `design/maquettes/landing.png`.
1. **La promesse en haut** : titre, phrase d'accroche, photo, et ses **4 avantages** (repas variés et équilibrés ; budget maîtrisé chaque semaine ; liste de courses claire ; suivi personnalisé).
2. **4 cartes de fonctions**, chacune avec sa **pastille de couleur** et un **aperçu d'écran** : Scan IA (orange), Menus (corail), Courses (vert), Suivi (lavande).
3. Les cartes **n'ont pas de bouton** et ne sont pas cliquables : ce sont des promesses, pas des fonctions accessibles.
4. **Un seul bouton « Commencer »**, collé en bas pendant tout le défilement, avec « Vos données sont sécurisées » dessous.
5. **Sous le bouton, la même ligne légère que sur `path_choice`** : « Juste une idée pour ce soir ? Improviser avec ce que j'ai » → `improv_scan`, sans compte. C'est le seul accès direct depuis la Landing : les cartes, elles, restent inertes. Ce n'est pas une quatrième porte d'entrée, c'est la même ligne qu'ailleurs (§8).

Corrections : logo et logotype Menoo de l'app (pas « MENOO » en capitales de la maquette) ; la carte Scan IA porte la mention **« 1 scan offert »**, qui rend la promesse tenable (§0.8) ; `path_choice` reste hors compteur.

## 2. Onboarding Solo (11 étapes + écrans de réassurance)

| # | Écran | Fonction | Remarque |
|---|---|---|---|
| — | `cover_solo` | Présentation | — |
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
| 9 | `onboarding_cuisines` | Types de cuisine appréciés | Préférence, jamais un filtre bloquant |
| 10 | `onboarding_kitchen` | **Ma cuisine** : niveau, temps, équipements | — |
| ★ | `reassurance_ready` | **Plan prêt** | Hors compteur |
| 11 | `onboarding_summary` | Récapitulatif | Bloc « Ma cuisine » + cible kcal |

## 3. Onboarding Foyer (9 étapes + écrans de réassurance)

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
| 7 | `onboarding_cuisines` | Types de cuisine | — |
| 8 | `onboarding_kitchen_household` | Ma cuisine + qui cuisine | — |
| ★ | `reassurance_ready` | **Plan prêt** | Hors compteur |
| 9 | `onboarding_summary_household` | Récapitulatif | — |

Le Foyer n'a ni étape balance ni objectif de poids commun : les écrans « trajectoire de poids » et « métabolisme » n'y apparaissent pas.
`pantry_quickcheck` reste l'option « vérification rapide » du détour Réserve (Solo et Foyer), hors compteur.

## 4. Détour Réserve (onboarding)

Au bouton « Continuer » de l'écran Mode de gestion :
- **« Courses uniquement »** → étape suivante directement.
- **« Réserves uniquement » ou « Mixte »** → `pantry_hub_onboarding` (pas de compteur d'étape, pas de barre de navigation).
  - Depuis ce hub : `pantry_quickcheck` (rapide, gratuit), `pantry_addmanual` (gratuit), `pantry_scanbarcode` (gratuit), `pantry_photoai` (**Premium**, règle §0.8 : la carte affiche un cadenas et renvoie vers la saisie manuelle ou le code-barres) → chacun revient au hub après ajout.
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

Parcours planification : `onboarding_summary(_household)` → « Générer mon/notre menu » → `generation` / `generation_household` → `menu_blurred(_household)` → proposition de sauvegarde (`signup`, « Plus tard » possible).
`signup` → « Se connecter » → `login`.

## 6. Règles métier

- **Budget** : curseur de 20 € à 350 € (pas de 5 €) + champ « Budget personnalisé » au-delà. Valeur de départ : Solo ≈ 65 € ; Foyer = 30 € × adultes + 20 € × enfants + **25 € × bébés**.
- **Ma cuisine** : niveau (Débutant / Intermédiaire / Confirmé), temps par repas en semaine et le week-end (15, 30, 45, 60+ min), équipements (choix multiple). En Foyer : « Qui cuisine le plus souvent ? ». La génération **exclut** toute recette nécessitant un équipement non coché, dépassant le temps disponible ou au-dessus du niveau.
- **Types de cuisine** : une préférence (Menoo privilégie), jamais un filtre qui bloquerait la génération.
- **Gratuit / payant** (détail §9) :
  - Menu de la semaine : 1 repas affiché en clair (badge « Offert »), les autres floutés avec cadenas.
  - Liste de courses : total estimé, budget et premier rayon en clair ; rayons suivants floutés (modèle `master_courses_gratuit`).
  - Fiche recette : onglets Ingrédients et Ustensiles visibles, Instructions floutées après 3 lignes.
  - Photo IA : réservée aux abonnés.
  - **Pas d'essai de 7 jours** : il exigerait une carte bancaire, ce qui est exclu (§9). Le scan offert et le repas offert tiennent ce rôle.
- **Courses** : prix **estimés**, sans enseigne (Menoo est internationale, §10) ; tri par **rayon générique** (fruits et légumes, viandes, etc.). Aucune commande, aucun panier drive, aucune livraison (§7, onglet 3).

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
- Toutes les fiches (`recipe_sheet`, recette improvisée, recette anti-gaspi) utilisent **la même fiche recette à 3 onglets** (§9). `recipe_sheet` devient l'onglet Ingrédients.
- `mealconfirmation` (Solo) : boutons « Voir ma liste de courses » et « Accéder au suivi ».
- Un repas improvisé et validé est inscrit dans le menu du jour et compté dans le Suivi.

### Onglet 3 — Courses (sans drive)
`shopping_list` (Solo) ou `shopping_list_household` (Foyer), triée par rayon, réserve déduite. Depuis la liste :
- **Mode magasin** : tri par **rayon générique** (fruits et légumes, viandes, crémerie, épicerie…), cases à cocher, **total qui se met à jour**, **écran qui reste allumé**.
- **Partager** (feuille de partage Android), **imprimer en A4**, **exporter en PDF**, **copier en texte**.
- **Supprimés** : `shopping_list_checkout`, `shopping_list_confirmation`, les boutons « Commander en drive », `shopping_list_supermarketselect`, `shopping_list_pricecompare`, et toute mention de commande, panier drive, livraison ou enseigne (décision du 2026-09-30, Menoo est internationale : *point ouvert n°5 retiré*, §14).
- La liste partagée en temps réel entre membres du foyer est en **phase 2** (non codée).

### Onglet 4 — Réserve
**Emplacement obligatoire pour chaque aliment** : Réfrigérateur, Placard, Congélateur, Corbeille à fruits.
- `pantry_home` : produits regroupés par emplacement, puces de filtre « Tous · Frigo · Corbeille · Placard · Congél. » avec compteur, statut et délai restant. **Entrée permanente vers l'improvisation** (« Cuisiner avec ma réserve »).
- `pantry_addmanual` (gratuit) : emplacement obligatoire, pré-rempli selon la catégorie, modifiable.
- `pantry_scanbarcode` (gratuit) et `pantry_photoai` (**Premium**) : après détection, emplacement par défaut de chaque produit, modifiable avant l'ajout.
- Les alertes de péremption indiquent l'emplacement (« Poulet · Réfrigérateur · 2 jours »). Les produits **périmés sont signalés en rouge** d'après les dates en base.
- Données : champ `location` (enum `fridge`, `pantry`, `freezer`, `fruit_basket`) sur `pantry_items`.

`pantry_expiryalert` → `pantry_antiwasterecipe` ; `pantry_antiwaste` (Solo) accessible d'ici.

### Onglet 5 — Suivi (sous-onglets Budget | Nutrition | Performance)
| Sous-onglet | Solo | Foyer |
|---|---|---|
| Budget | `tracking_budget` | `tracking_budget_household` |
| Nutrition | `tracking_nutrition` | `tracking_nutrition_household` |
| Performance | `tracking_weight` (Régime) → `scale_manage`, `weight_manualentry` | `tracking_antiwaste_household` |

### Réglages (avatar de l'en-tête)
Solo : `settings`. Foyer : `settings_household` + bloc « Ma cuisine ». On y trouve aussi la langue, le pays, les unités et la **gestion de l'abonnement** (résiliation simple, via Google Play).

### États vides / erreurs
3 composants (réserve vide, aucun menu, hors ligne) affichés dans les écrans concernés.

## 8. Improvisation (jalon 6b, construit avec le paywall §9)

Trouver quoi cuisiner **maintenant** avec ce qu'on a. Parcours en **6 étapes** (compteur « ÉTAPE X SUR 6 »), sans barre de navigation tant qu'il n'y a pas de compte.

| # | Écran | Contenu |
|---|---|---|
| 1 | `improv_scan` | **Scan** du frigo et des réserves (photo : **1 scan offert par appareil**, puis Premium) **ou sélection manuelle** d'ingrédients (toujours gratuite). Onglets Frigo / Garde-manger. **Deux états, voir ci-dessous.** Puis liste « Ingrédients détectés » : cases à cocher, quantité, emplacement, corriger, retirer, ajouter. |
| 2 | `improv_guests` | **Nombre de convives** : valeur du foyer par défaut, réglable en plus ou en moins. |
| 3 | `improv_condiments` | **Condiments à cocher : 6 à 8 cases maximum**, déduites des ingrédients retenus (huiles, épices, bouillons, vinaigres, sauces). En petit : « Sel, poivre et huile sont supposés présents. » |
| 4 | `improv_equipment` | **Équipement disponible**, pré-coché depuis « Ma cuisine » si elle est connue. |
| 5 | `improv_cuisines` | **Choix de cuisine** (voir ci-dessous). |
| 6 | Fiche recette (§9) | **La recette.** |

**Étape 1 — deux états du même écran** (maquette `maquette_6b_cercle_et_cuisines.html`, référence `scan_ia_ecran1.png`) :
- **Au repos** : la zone photo n'est qu'un aperçu de ce qui va se passer — l'illustration `assets/images/scan_frigo_main.jpg` (une main qui tient un téléphone devant le frigo ouvert), la pastille orange « Scan IA » et les étiquettes d'ingrédients posées par l'app (jamais dans l'image). Bouton principal « Analyser mes ingrédients ».
- **Caméra active** : un appui sur l'onglet « Frigo » ou « Garde-manger », ou sur le bouton principal, fait disparaître l'illustration ; **la caméra s'active en direct dans cette même zone**, avec un cadre de visée aux quatre coins, une pastille « En direct » et les étiquettes qui apparaissent au fil de la reconnaissance. Le bouton principal devient **« Scanner »** et déclenche la prise de vue ; un lien « Annuler » ramène au premier état.
- Les trois cartes (Prendre une photo, Importer une photo, Saisie manuelle) restent visibles dans les deux états ; celle qui correspond à l'action en cours est marquée. Mentions « Abonnés » ou « Gratuit » sur chacune (§0.8).
- **Quand le paywall s'affiche** : jamais avant le scan offert. La caméra s'active et le premier scan se déroule entièrement, jusqu'à la liste des ingrédients détectés et la recette. Le paywall n'arrive qu'au **deuxième** scan photo, avec un message qui rappelle ce qui reste gratuit (saisie manuelle et code-barres). Le quota est vérifié **côté serveur** avant l'appel à l'IA (§16).
- Tant que le scan offert n'a pas servi, les cartes « Prendre une photo » et « Importer une photo » portent la mention **« 1 scan offert »** plutôt que « Abonnés ».

**Étape 5 — trois états par cuisine**, avec le **nombre de recettes** :
- **Disponible** : tout est là.
- **Presque** : il manque 1 ou 2 éléments, **affichés** (« Il manque : feta »).
- **Indisponible** : grisée, avec **la raison** (« pas de wok », « pas de sauce soja »).
Liste **dépliable** (une cuisine = une ligne qui s'ouvre sur ses recettes), **plusieurs cuisines ouvrables** en même temps, **retour en arrière possible** sans perdre les réponses. Ordre : disponibles, presque, indisponibles. Chaque recette affiche durée, prix par portion et ce qui manque éventuellement.

**Règle centrale** (§0.7) : l'IA reconnaît les ingrédients ; la recherche de recettes est une **correspondance dans le catalogue**. Recette générée librement : seulement si le catalogue ne donne rien, marquée « Recette générée par IA, non vérifiée », sans macros garanties et **hors budget garanti**.

**Étape 5 — « aucune recette possible » n'est jamais un cul-de-sac.** Quand aucune cuisine n'est disponible, l'écran ne se contente pas de l'annoncer : il propose **au minimum ces trois sorties**, dans cet ordre.
1. **Les 3 recettes les plus proches**, avec ce qui manque à chacune (« Il manque : lait, beurre »), triées par le plus petit nombre d'éléments manquants. Chacune est ouvrable : on voit la recette, on décide si on peut s'en passer ou sortir acheter.
2. **Ajouter un ingrédient** : retour direct à l'étape 1, réponses conservées. Les ingrédients qui débloqueraient le plus de recettes sont **suggérés en premier** (« avec des œufs, 6 recettes de plus »).
3. **Décocher une contrainte non bloquante** : équipement, temps, niveau, cuisine préférée. Chaque proposition dit ce qu'elle débloque (« sans le wok : 4 recettes de plus »).
   **Jamais les régimes ni les allergènes** : ceux-là ne se décochent pas, ce sont des exclusions strictes (§0.7, §6).

Le même principe vaut partout où une liste peut se vider : on montre toujours le geste le plus proche qui remet l'utilisateur en marche. En dernier recours seulement, la recette générée librement (voir la règle centrale ci-dessus).

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

Lots de recettes : **5 recettes = 3,49 €** (0,70 € l'une), **15 recettes = 7,99 €** (0,53 € l'une).

Règles :
- **Jamais de carte bancaire pour essayer** : ce qui est gratuit est visible sans rien saisir.
- **Résiliation simple dans l'app**, via Google Play Billing (lien direct vers la gestion de l'abonnement).
- Une recette débloquée le reste pour toujours, sur le compte.
- Les mêmes options s'affichent sur le menu flouté et la liste de courses floutée.
- Tant que l'app n'est pas publiée, les achats sont **simulés** (champ `premium` et recettes débloquées dans Supabase).

Corrections des maquettes : ordre des onglets (la maquette met Instructions en premier) ; **« 4,3 note » retiré** (chiffre inventé, §0.4) ; **« Interrogez le coach » écarté** — il vient des maquettes d'Eatr, et une IA présentée comme une personne, photo de femme à l'appui, pose un problème d'honnêteté. La fonction pourra revenir plus tard, mais **annoncée clairement comme une IA**, sans visage ni prénom humains.

## 10. International (avant de créer les recettes)

**Prioritaire** : si les recettes sont créées en français seulement, il faudra tout refaire.
- **Textes de l'app** : internationalisation Flutter, tous les textes sortis du code.
- **Contenus** : tables de traduction pour recettes (titre, étapes), ingrédients, catégories, allergènes, régimes, cuisines, équipements. **Français en référence** ; une traduction manquante retombe sur le français.
- **Qualité des traductions, deux niveaux** :
  - **Allergènes et régimes** : **relecture obligatoire par une personne dont c'est la langue**, avant publication. Une erreur y est un risque de santé, ce n'est pas négociable. Aucune langue n'est mise en production sans cette relecture.
  - **Tout le reste** (recettes, ingrédients, catégories, cuisines, équipements, textes de l'app) : traduction automatique, corrigée au fil des retours.
- **6 langues au lancement** : français, anglais, espagnol, allemand, italien, arabe.
- **Choix de la langue** :
  - **À la première ouverture, la langue du téléphone est reprise automatiquement.** On ne demande rien : si le téléphone est en espagnol, l'app s'ouvre en espagnol.
  - **Langue non proposée → repli sur l'anglais, jamais sur le français.** Un téléphone en japonais, en polonais ou en portugais ouvre l'app en anglais. Le français est la langue de référence des traductions, pas la langue de secours : c'est l'anglais qui a le plus de chances d'être compris par quelqu'un dont la langue n'est pas encore gérée. La règle vaut aussi pour les contenus venant de la base (§ tables de traduction).
  - **Ensuite, elle se change dans les Réglages** (jalon 12), dans une ligne « Langue ». Le choix est enregistré et prime sur celui du téléphone.
  - **Jamais de drapeau.** Un drapeau désigne un pays, pas une langue : l'espagnol et l'arabe n'appartiennent à aucun pays en particulier. Chaque langue s'écrit **dans sa propre écriture**, pour être reconnue par qui ne lit pas les autres : Français · English · Español · Deutsch · Italiano · العربية.
  - La langue et le pays sont **deux réglages distincts** : le pays commande les unités, la devise et le format de date (§ ci-dessous), la langue commande les textes. Un Français aux États-Unis garde le français et passe aux unités impériales.
  - *Provisoire, jusqu'au jalon 12* : le choix se fait par un **appui long sur le logo Menoo**. Invisible pour un utilisateur, donc sans effet sur le design, et remplacé par la ligne des Réglages.
- **Arabe** : police **Noto Sans Arabic** en **secours**, jamais en police principale — Plus Jakarta Sans reste devant, ce qui garde « Menoo » et les mots latins dans le dessin de la marque au milieu d'un texte arabe.
- **Sens de lecture** : aucune position figée à gauche ou à droite dans le code. On écrit `start` et `end`, jamais `left` et `right` ; les icônes qui indiquent un sens (retour, flèche, chevron, courbes de tendance) se retournent, les autres non (horloge, coche, panier). Le **bloc de marque garde son ordre** : le logo reste à gauche du mot « Menoo », seule sa place dans l'écran change.
- **Arabe** : écriture de droite à gauche (mise en page inversée, icônes directionnelles retournées) et police compatible (Plus Jakarta Sans ne contient pas l'alphabet arabe).
- **Unités** : métriques par défaut, impériales aux États-Unis. **Devises et formats de date** selon le pays. Tout est réglable dans les réglages.
- **Plus d'enseignes** (décision du 2026-09-30) : Menoo est internationale, aucune liste de supermarchés par pays à maintenir. Les prix restent estimés et le tri par rayon reste générique (§6, §7 onglet 3).
- **Prix en trois niveaux**, l'app affichant toujours l'origine :
  1. **Estimation** : prix de référence France, ajusté par un **indice public cité**.
  2. **Communautaire** : Open Prices (couverture réelle par pays **à vérifier** avant de s'appuyer dessus).
  3. **Réel** : tickets de caisse scannés par l'utilisateur.
  Quand les prix sont estimés : badge **« Estimation dans votre budget »** au lieu de « Dans le budget ✓ ».

## 11. Écrans non utilisés ou supprimés
- `shopping_list_checkout`, `shopping_list_confirmation` : **supprimés** (plus de drive).
- `onboarding_supermarket(_household)`, `shopping_list_supermarketselect`, `shopping_list_pricecompare` : **supprimés** (décision du 2026-09-30, Menoo est internationale : plus d'enseignes de supermarché nulle part dans l'app).
- `pantry_photoai_2` : supprimé (doublon).
- `recipeingredientscheck(_household)` : absorbé par l'onglet Ingrédients de la fiche recette.
- Carrousel de la landing : remplacé par la page déroulante.
- `design/stitch/_assets/` : images de plats, utilisables comme visuels de recettes.

## 12. Données de démo cohérentes
Solo : Karim, 32 ans, 180 cm, 75 kg, objectif perte de poids, budget 65 €. Foyer : famille Martin (Thomas, Sarah, Lucas, Emma), budget 110 €. Mêmes prénoms sur tous les écrans Foyer.

## 13. Maquettes de référence (`design/maquettes/`)
| Fichier | Sert pour | À ne pas reprendre |
|---|---|---|
| `landing.png` | **`landing`** (malgré son nom : ce n'est pas l'Accueil, §0.13) | Logo « MENOO » en capitales |
| `scan_ia_ecran1.png` | Improvisation, étape 1 (état au repos) | Barre de navigation ; bandeau et bouton en pilule ; « Estimation des quantités » à présenter comme modifiable |
| `scan_ia_ingredients.png` | Improvisation, étape 1 (liste détectée) | Barre de navigation |
| `condiments_equipement.png` | Improvisation, étapes 3 et 4 | Un seul écran pour deux étapes ; plus de 8 condiments ; le bloc « Niveau en cuisine » |
| `cuisines_grisees.png` | Improvisation, étape 5 (aperçus de recettes, états grisés) | Le compteur « Étape 9 sur 12 » et le titre d'onboarding |
| `fiche_recette_infos.png`, `fiche_recette_ustensiles.png` | Fiche recette (§9) | « 4,3 note », « Interrogez le coach », ordre des onglets |
| `maquette_6b_cercle_et_cuisines.html` | Cercle animé de l'Accueil et étape 5 (proposition de Claude, à valider) | — |

## 14. Points tranchés le 2026-09-30

Les 13 questions ouvertes ont toutes reçu une réponse de Simo. Elles sont reportées ici pour mémoire, avec l'endroit où la règle est écrite.

| # | Question | Réponse | Où |
|---|---|---|---|
| 1 | Un scan offert ? | **Oui, 1 par appareil.** Sans lui, la promesse « Scan IA » de la Landing serait trompeuse | §0.8, §8 |
| 2 | Essai de 7 jours | **Non.** Jamais de carte bancaire pour essayer | §6, §9 |
| 3 | Menu et liste de courses floutés | **Conservés**, avec les trois mêmes options d'achat que la fiche recette | §6, §9 |
| 4 | Lots de recettes | **5 = 3,49 € · 15 = 7,99 €** | §9 |
| 5 | Comparateur de prix entre enseignes | Conservé le 30/09, puis **retiré le même jour** : Menoo est internationale, plus aucune enseigne nulle part dans l'app | §7, onglet 3 ; §11 |
| 6 | « J'ai déjà un compte » | **Lien discret dans l'en-tête** de la Landing | §1 |
| 7 | « Interrogez le coach » | **Écarté.** Vient des maquettes d'Eatr ; une IA présentée comme une personne pose un problème d'honnêteté. Reviendra peut-être, **annoncée clairement comme une IA** | §9 |
| 8 | Combien de recettes | **12 à 15 par cuisine sur 8 cuisines, soit environ 120** pour commencer (96 au jalon 5c). Les 500 viendront **après le lancement**, une fois qu'il y aura des utilisateurs | §10, PLAN.md |
| 9 | Traductions | **Relecture humaine obligatoire pour les allergènes et les régimes** (risque de santé, non négociable) ; traduction automatique pour le reste | §10 |
| 10 | Moment du paywall | **Après le scan offert**, jamais avant : on voit son écran avant qu'on lui demande de payer | §8 |
| 11 | Renommages d'écrans | **Adoptés et appliqués** | §15 |
| 12 | Carte « Scan IA » de la Landing | **Cartes inertes** ; une ligne légère sous « Commencer » mène à l'improvisation | §1 |
| 13 | Maquette `scan_ia_accueil.png` | **Renommée `scan_ia_ecran1.png`** | §13 |

## 15. Noms d'écrans — audit du 2026-09-30, **appliqué**

Règle : **un nom = un écran, un écran = un nom** (§0.14). Les 14 corrections ci-dessous ont été validées par Simo le 2026-09-30 et sont **appliquées** dans ce document et dans le code existant. Commit de départ : « Mise sous Git du projet Menoo », pour pouvoir revenir en arrière.

### 15.1 Deux écrans différents portaient le même nom

| | Avant | Après | Pourquoi |
|---|---|---|---|
| A | `landing_hook` | `landing` | Page déroulante d'avant le compte (§0.13) |
| B | `dashboard_home` · `dashboard_home_household` | `home` · `home_household` | Onglet 1 après connexion. « Dashboard » était un troisième mot pour l'Accueil |
| C | `dashboard_budget` · `dashboard_nutrition` · `dashboard_diet` · `dashboard_antiwaste_household` | `tracking_budget` · `tracking_nutrition` · `tracking_weight` · `tracking_antiwaste_household` | Le préfixe `dashboard_` couvrait **deux onglets** : l'Accueil et le Suivi |
| D | `dashboard_antiwaste` (Solo, atteint **depuis la Réserve**) contre `dashboard_antiwaste_household` (Foyer, sous-onglet **du Suivi**) | `pantry_antiwaste` · `tracking_antiwaste_household` | Noms quasi identiques pour deux emplacements et deux rôles différents |
| E | `dashboard_diet`, libellé « Régime » | `tracking_weight`, libellé « Poids » | **« Régime » est réservé aux restrictions alimentaires** (végétarien, sans gluten — table `diets`). Le suivi du poids ne s'appelle plus jamais « régime ». Collision la plus dangereuse de l'audit, les deux notions existant déjà en base |
| F | `pantry_home` (onglet, avec barre) et `pantry_home_onboarding` (hub du détour, sans barre) | `pantry_home` · `pantry_hub_onboarding` | Un « home » qui n'en était pas un |

### 15.2 Un même écran portait deux noms

| | Avant (SPEC · code) | Après | Note |
|---|---|---|---|
| G | `onboarding_preferences` · `CuisineTypesScreen` | `onboarding_cuisines` · `OnboardingCuisinesScreen` | Le préfixe de flux est **obligatoire** : `onboarding_cuisines` (les goûts) ne doit pas être confondu avec `improv_cuisines` (ce qui est faisable ce soir). La maquette `cuisines_grisees.png` mélange précisément ces deux écrans |
| H | `onboarding_pantrycheck` · `PantryQuickCheckScreen` | `pantry_quickcheck` | Hors compteur d'étapes, donc sans préfixe `onboarding_` |
| I | `pantry_home_onboarding` · `PantryOnboardingHubScreen` | `pantry_hub_onboarding` · `PantryHubOnboardingScreen` | |
| J | `liste_courses` (français) et `shoppinglist_*` (anglais) · `ShoppingListFreeScreen` | `shopping_list` · `shopping_list_household` · `ShoppingListScreen` | Gratuit et premium sont deux **états**, pas deux écrans. Le tunnel garde le préfixe `shopping_list_` |
| K | `mealdetail_breakfast`, `mealdetail_*`, `recipeingredientscheck` · `RecipeScreen` | `recipe_sheet` · `RecipeSheetScreen` | Une seule fiche pour toute l'app (§9), avec ses 3 onglets |
| L | `menu_blurred` (gratuit) et `mealoverview_grid` (premium) ; `meallist_filter` | `menus_grid` (deux états) · `menus_list` | |
| M | `s10_generation_ia_solo` · `f07_generation_ia_foyer` | `generation` · `generation_household` | Numérotation Stitch retirée ; suffixe `_foyer` remplacé par `_household` |
| N | `c02_auth_login` · `c03_auth_signup` | `login` · `signup` | Numérotation Stitch retirée |
| O | `settings_profile` = **Foyer** et `settings_profile_solo` = **Solo** | `settings` (Solo) · `settings_household` (Foyer) | L'ancien couple inversait la règle : le nom nu est toujours le Solo |
| P | `pantry_photoai_1` | `pantry_photoai` | Le `_1` venait de `pantry_photoai_2`, supprimé |
| Q | `cover_individual` · `CoverIndividualScreen` | `cover_solo` · `CoverSoloScreen` | Le mode s'appelle **Solo** partout ailleurs (`AppMode.solo`) |

### 15.3 Fait dans le code
`DashboardScreen` → `HomeScreen` (`home_screen.dart`) · `CuisineTypesScreen` → `OnboardingCuisinesScreen` · `CoverIndividualScreen` → `CoverSoloScreen` · `PantryOnboardingHubScreen` → `PantryHubOnboardingScreen` · `ShoppingListFreeScreen` → `ShoppingListScreen` · `RecipeScreen` → `RecipeSheetScreen` (dossier `screens/week/` → `screens/menus/`) · `MenooTab.semaine` → `MenooTab.menus`, libellé « Semaine » → « Menus ».
Les écrans qui n'existent pas encore seront créés directement sous leur nom définitif.

### 15.4 Maquettes renommées
`landing.png` → **`landing.png`** : le fichier montre la Landing, pas l'Accueil.
Reste à trancher : `scan_ia_ecran1.png` montre l'écran d'accueil du Scan IA, pas l'Accueil de l'app — le renommer en `scan_ia_ecran1.png` ?

## 16. Anti-fraude et quota du scan offert (jalon 12b — planifié, pas codé)

But : empêcher qu'on recrée des comptes ou qu'on réinstalle l'app pour consommer sans fin les appels à l'IA, tout en tenant la promesse du **scan offert par appareil** (§0.8).

- **App Set ID**, vérifié **côté serveur**. Pas le Firebase Installations ID (il disparaît à la désinstallation), pas l'`ANDROID_ID` (usage restreint par Google).
- **Play Integrity** pour écarter les émulateurs et les applications modifiées.
- **Vérification dans une Edge Function avant chaque appel à l'IA** : quota par appareil et par compte. Le compteur du scan offert vit **en base**, jamais dans l'app — sinon une réinstallation le remettrait à zéro.
- **Déclaration obligatoire** dans la politique de confidentialité et dans le formulaire Sécurité des données de Google Play.
- Tant que ce jalon n'est pas fait, le scan offert est compté localement : c'est **suffisant pour tester, pas pour publier**. L'app ne peut pas être publiée sans le jalon 12b.
