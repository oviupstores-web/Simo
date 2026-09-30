# Visuels à fournir — inventaire complet

Mis à jour le 2026-09-24. Liste, écran par écran, tout ce qui affiche encore une **icône sur pastille** (ou une image provisoire) au lieu d'une vraie image.

## Conventions
| Type de visuel | Format | Taille | Fond |
|---|---|---|---|
| Produit détouré (ingrédient, équipement) | JPG | 512 × 512 px | blanc pur, produit seul, ombre douce |
| Vignette thématique (catégorie, emplacement, régime, allergène, objectif…) | JPG | 512 × 512 px | scène claire et lumineuse, cuisine claire, cadrage serré |
| Photo de recette | JPG | 1200 × 900 px (4:3) | plat servi, lumière naturelle, vue de trois-quarts |
| Élément décoratif | PNG transparent | 512 × 512 px | transparent |

Tous les fichiers vont dans `assets/images/<dossier>/`. Les originaux lourds sont rangés dans `design/originals/<dossier>/`.

**Colonne « Production »** :
- **Claude** : je peux le faire moi-même (monogramme, recadrage d'une photo de `design/stitch_images/`) ;
- **Photo** : il faut une vraie photo, générée ou fournie.

---

## ✅ Déjà fournis
- **12 équipements, 3 niveaux de cuisine, 8 types de cuisine** : fournis par Simo le 2026-09-24. Ils sont dans `equipment/`, `levels/` et `cuisines/`, avec les originaux dans `design/originals/`.

---

## 1. Supermarché (étape 11 Solo, puis Foyer et Courses)
Tuiles nominatives uniquement : initiales ou nom sur une pastille pastel. **Jamais de logo officiel ni de couleur de marque** (marques déposées).

| Écran | Élément | Fichier attendu | Dossier | Format | Taille | Production |
|---|---|---|---|---|---|---|
| Supermarché | E.Leclerc | aucun (dessiné en code) | — | monogramme | — | Claude ✅ fait |
| Supermarché | Carrefour | aucun | — | monogramme | — | Claude ✅ fait |
| Supermarché | Intermarché | aucun | — | monogramme | — | Claude ✅ fait |
| Supermarché | Auchan | aucun | — | monogramme | — | Claude ✅ fait |
| Supermarché | Super U | aucun | — | monogramme | — | Claude ✅ fait |
| Supermarché | Lidl | aucun | — | monogramme | — | Claude ✅ fait |
| Supermarché | Monoprix | aucun | — | monogramme | — | Claude ✅ fait |
| Supermarché | Biocoop | aucun | — | monogramme | — | Claude ✅ fait |

⚠️ La base contient encore les 3 enseignes fictives de Stitch (Épicure, Clean, Community Grocery), avec des images Stitch comme « logo ». Je les remplacerai par les 8 enseignes, sans logo, au jalon 9, avec une migration que je te montrerai avant l'envoi.

## 2. Produits de la réserve — les 80 ingrédients du catalogue
- **Où on les voit** : Réserve, ajout manuel, liste de courses et fiches recette.
- **Emplacement** : `assets/images/ingredients/`, en JPG sur fond blanc, 512 × 512 px, un fichier par ingrédient (nom = code de l'ingrédient en base).
- **État actuel** : seuls 18 aliments ont une vignette générique (une photo de scène qui sert pour toute une famille ; par exemple, « saumon » sert pour tous les poissons). Les 13 vignettes détourées de Stitch ne font que 50 px, elles sont floues au-delà.

| Ingrédient | Fichier attendu | Image actuelle | Production |
|---|---|---|---|
| **Fruits & légumes** | | | |
| Pomme | `pomme.jpg` | aucune image | photo |
| Banane | `banane.jpg` | vignette 50 px existante, trop petite | photo |
| Kiwi | `kiwi.jpg` | aucune image | photo |
| Avocat | `avocat.jpg` | photo de scène Stitch recadrable en attendant | photo |
| Citron | `citron.jpg` | vignette 50 px existante, trop petite | photo |
| Grenade | `grenade.jpg` | aucune image | photo |
| Tomates cerises | `tomates_cerises.jpg` | vignette 50 px existante, trop petite | photo |
| Myrtilles | `myrtilles.jpg` | aucune image | photo |
| Framboises | `framboises.jpg` | aucune image | photo |
| Fraises | `fraises.jpg` | aucune image | photo |
| Épinards frais | `epinards.jpg` | vignette 50 px existante, trop petite ; photo de scène Stitch recadrable en attendant | photo |
| Roquette | `roquette.jpg` | photo de scène Stitch recadrable en attendant | photo |
| Laitue | `laitue.jpg` | aucune image | photo |
| Brocoli | `brocoli.jpg` | vignette 50 px existante, trop petite | photo |
| Asperges vertes | `asperges.jpg` | photo de scène Stitch recadrable en attendant | photo |
| Carottes | `carottes.jpg` | vignette 50 px existante, trop petite | photo |
| Poivron | `poivron.jpg` | aucune image | photo |
| Courgette | `courgette.jpg` | aucune image | photo |
| Poireaux | `poireaux.jpg` | aucune image | photo |
| Chou rouge | `chou_rouge.jpg` | aucune image | photo |
| Basilic frais | `basilic.jpg` | aucune image | photo |
| Aneth frais | `aneth.jpg` | aucune image | photo |
| Patate douce | `patate_douce.jpg` | photo de scène Stitch recadrable en attendant | photo |
| Pommes de terre | `pommes_de_terre.jpg` | aucune image | photo |
| Courge butternut | `courge_butternut.jpg` | aucune image | photo |
| Oignon | `oignon.jpg` | aucune image | photo |
| Ail (gousse) | `ail.jpg` | aucune image | photo |
| **Frais & protéines** | | | |
| Pavé de saumon frais | `saumon.jpg` | vignette 50 px existante, trop petite ; photo de scène Stitch recadrable en attendant | photo |
| Dos de cabillaud | `cabillaud.jpg` | aucune image | photo |
| Filet de poulet | `poulet.jpg` | vignette 50 px existante, trop petite | photo |
| Bœuf à braiser | `boeuf.jpg` | aucune image | photo |
| Lardons fumés | `lardons.jpg` | aucune image | photo |
| Crevettes cuites | `crevettes.jpg` | aucune image | photo |
| Tofu ferme | `tofu.jpg` | aucune image | photo |
| **Crèmerie** | | | |
| Lait demi-écrémé | `lait.jpg` | vignette 50 px existante, trop petite | photo |
| Yaourt grec | `yaourt_grec.jpg` | photo de scène Stitch recadrable en attendant | photo |
| Yaourt nature | `yaourt_nature.jpg` | vignette 50 px existante, trop petite | photo |
| Yaourt végétal coco | `yaourt_coco.jpg` | aucune image | photo |
| Œufs | `oeufs.jpg` | aucune image | photo |
| Beurre doux | `beurre.jpg` | aucune image | photo |
| Crème fraîche | `creme_fraiche.jpg` | photo de scène Stitch recadrable en attendant | photo |
| Feta | `feta.jpg` | aucune image | photo |
| Fromage de chèvre | `chevre.jpg` | aucune image | photo |
| Parmesan | `parmesan.jpg` | aucune image | photo |
| Emmental râpé | `emmental.jpg` | aucune image | photo |
| Pâte brisée | `pate_brisee.jpg` | aucune image | photo |
| Pâte feuilletée | `pate_feuilletee.jpg` | aucune image | photo |
| **Boulangerie** | | | |
| Pain complet | `pain_complet.jpg` | aucune image | photo |
| Tortillas de blé | `tortillas.jpg` | aucune image | photo |
| **Épicerie** | | | |
| Flocons d'avoine | `flocons_avoine.jpg` | aucune image | photo |
| Quinoa | `quinoa.jpg` | vignette 50 px existante, trop petite ; photo de scène Stitch recadrable en attendant | photo |
| Riz basmati | `riz.jpg` | aucune image | photo |
| Riz arborio | `riz_arborio.jpg` | aucune image | photo |
| Tagliatelles | `pates.jpg` | aucune image | photo |
| Nouilles soba | `nouilles_soba.jpg` | aucune image | photo |
| Lentilles vertes | `lentilles_vertes.jpg` | aucune image | photo |
| Pois chiches cuits | `pois_chiches.jpg` | aucune image | photo |
| Coulis de tomate | `coulis_tomate.jpg` | aucune image | photo |
| Huile d'olive | `huile_olive.jpg` | vignette 50 px existante, trop petite | photo |
| Sauce soja | `sauce_soja.jpg` | aucune image | photo |
| Moutarde de Dijon | `moutarde.jpg` | aucune image | photo |
| Miel | `miel.jpg` | aucune image | photo |
| Purée d'amande | `puree_amande.jpg` | aucune image | photo |
| Amandes | `amandes.jpg` | vignette 50 px existante, trop petite | photo |
| Cerneaux de noix | `noix.jpg` | aucune image | photo |
| Dattes | `dattes.jpg` | aucune image | photo |
| Graines de chia | `graines_chia.jpg` | aucune image | photo |
| Graines de sésame | `sesame.jpg` | aucune image | photo |
| Olives noires | `olives.jpg` | aucune image | photo |
| Cacao non sucré | `cacao.jpg` | aucune image | photo |
| Thé matcha | `matcha.jpg` | aucune image | photo |
| Boisson à l'avoine | `lait_avoine.jpg` | aucune image | photo |
| Bouillon de légumes | `bouillon_legumes.jpg` | aucune image | photo |
| Herbes de Provence | `herbes_provence.jpg` | aucune image | photo |
| Cumin | `cumin.jpg` | aucune image | photo |
| Paprika | `paprika.jpg` | aucune image | photo |
| Cannelle | `cannelle.jpg` | aucune image | photo |
| **Surgelés** | | | |
| Fruits rouges surgelés | `fruits_rouges_surgeles.jpg` | aucune image | photo |
| Edamame surgelés | `edamame.jpg` | aucune image | photo |
| Brocoli surgelé | `brocoli_surgele.jpg` | aucune image | photo |

## 3. Catégories d'aliments (ajout manuel, vérification rapide du placard)
Aujourd'hui, ces écrans réutilisent la vignette générique d'un aliment, et « Conserves » ainsi qu'« Épices » n'ont qu'une icône.

| Écran | Élément | Fichier attendu | Dossier | Format | Taille | Production |
|---|---|---|---|---|---|---|
| Ajout manuel | Fruits | `fruits.jpg` | `categories/` | JPG | 512² | Photo |
| Ajout manuel, vérif. rapide | Légumes frais | `legumes.jpg` | `categories/` | JPG | 512² | Photo (recadrage provisoire possible : `decor_marche_legumes_vue_dessus.jpg`) |
| Ajout manuel, vérif. rapide | Laitiers & œufs | `laitiers_oeufs.jpg` | `categories/` | JPG | 512² | Photo |
| Ajout manuel | Viandes & poissons | `viandes_poissons.jpg` | `categories/` | JPG | 512² | Photo |
| Ajout manuel | Épicerie salée | `epicerie_salee.jpg` | `categories/` | JPG | 512² | Photo (recadrage provisoire possible : `decor_placard_bocaux.jpg`) |
| Ajout manuel | Épicerie sucrée | `epicerie_sucree.jpg` | `categories/` | JPG | 512² | Photo |
| Ajout manuel | Surgelés | `surgeles.jpg` | `categories/` | JPG | 512² | Photo |
| Vérif. rapide | Pâtes, riz & féculents | `pates_riz.jpg` | `categories/` | JPG | 512² | Claude (recadrage de `ingredient_bocaux_quinoa_pates_huile.jpg`) |
| Vérif. rapide | Huile, vinaigre & condiments | `huiles_condiments.jpg` | `categories/` | JPG | 512² | Claude (recadrage de `decor_huiles_epicerie_fine.jpg`) |
| Vérif. rapide | Conserves & sauces tomate | `conserves_sauces.jpg` | `categories/` | JPG | 512² | Photo |
| Vérif. rapide | Farine, sucre & levure | `farine_sucre.jpg` | `categories/` | JPG | 512² | Photo |
| Vérif. rapide | Épices & herbes | `epices_herbes.jpg` | `categories/` | JPG | 512² | Photo |
| Vérif. rapide | Viandes & poissons surgelés | `viandes_poissons_surgeles.jpg` | `categories/` | JPG | 512² | Photo |

## 4. Emplacements de la réserve (Réserve, ajout manuel)
| Écran | Élément | Fichier attendu | Dossier | Format | Taille | Production |
|---|---|---|---|---|---|---|
| Réserve, ajout manuel | Réfrigérateur | `fridge.jpg` | `locations/` | JPG | 512² | Photo (la photo Stitch `decor_frigo_ouvert_camera.jpg` contient une interface incrustée) |
| Réserve, ajout manuel | Corbeille à fruits | `fruit_basket.jpg` | `locations/` | JPG | 512² | Photo |
| Réserve, ajout manuel | Placard | `pantry.jpg` | `locations/` | JPG | 512² | Claude (recadrage de `decor_placard_bocaux.jpg`) |
| Réserve, ajout manuel | Congélateur | `freezer.jpg` | `locations/` | JPG | 512² | Photo |

## 5. Régimes alimentaires (étape 8 « Contraintes »)
| Écran | Élément | Fichier attendu | Dossier | Format | Taille | Production |
|---|---|---|---|---|---|---|
| Contraintes | Omnivore | `omnivore.jpg` | `diets/` | JPG | 512² | Photo |
| Contraintes | Végétarien | `vegetarien.jpg` | `diets/` | JPG | 512² | Photo |
| Contraintes | Végan | `vegan.jpg` | `diets/` | JPG | 512² | Photo |
| Contraintes | Pescétarien | `pescetarien.jpg` | `diets/` | JPG | 512² | Photo |
| Contraintes | Sans porc | `sans_porc.jpg` | `diets/` | JPG | 512² | Photo |
| Contraintes | Sans lactose | `sans_lactose.jpg` | `diets/` | JPG | 512² | Photo |
| Contraintes | Sans gluten | `sans_gluten.jpg` | `diets/` | JPG | 512² | Photo |

## 6. Allergènes (étape 8 « Contraintes »)
Crustacés et mollusques partagent une seule tuile, « Fruits de mer ». Aujourd'hui, seuls le gluten, le soja, le poisson et le lait réutilisent une vignette générique.

| Écran | Élément | Fichier attendu | Dossier | Format | Taille | Production |
|---|---|---|---|---|---|---|
| Contraintes | Gluten | `gluten.jpg` | `allergens/` | JPG | 512² | Photo (provisoire : vignette `pain`) |
| Contraintes | Arachides | `arachides.jpg` | `allergens/` | JPG | 512² | Photo |
| Contraintes | Fruits de mer | `fruits_de_mer.jpg` | `allergens/` | JPG | 512² | Photo |
| Contraintes | Œufs | `oeufs.jpg` | `allergens/` | JPG | 512² | Photo |
| Contraintes | Soja | `soja.jpg` | `allergens/` | JPG | 512² | Photo (provisoire : vignette `tofu`) |
| Contraintes | Fruits à coque | `fruits_a_coque.jpg` | `allergens/` | JPG | 512² | Photo |
| Contraintes | Poisson | `poisson.jpg` | `allergens/` | JPG | 512² | Photo (provisoire : vignette `saumon`) |
| Contraintes | Lait | `lait.jpg` | `allergens/` | JPG | 512² | Photo (provisoire : vignette `yaourt`) |
| Contraintes | Sésame | `sesame.jpg` | `allergens/` | JPG | 512² | Photo |
| Contraintes | Moutarde | `moutarde.jpg` | `allergens/` | JPG | 512² | Photo |
| Contraintes | Céleri | `celeri.jpg` | `allergens/` | JPG | 512² | Photo |
| Contraintes | Sulfites | `sulfites.jpg` | `allergens/` | JPG | 512² | Photo (fruits secs et verre de vin) |
| Contraintes | Lupin | `lupin.jpg` | `allergens/` | JPG | 512² | Photo |

## 7. Objectifs, activité, mode de gestion — restent en icônes
Décision de Simo (2026-09-24) : ce sont des concepts abstraits, donc on garde les icônes sur pastilles, et l'écran Objectif validé ne change pas. Les photos sont réservées à ce qui se mange : ingrédients, catégories, régimes, allergènes, recettes, cuisines.

## 8. Autres écrans
| Écran | Élément | Fichier attendu | Dossier | Format | Taille | Production |
|---|---|---|---|---|---|---|
| Choix du mode | Personne qui mange une salade (carte « Pour moi ») | `mode_solo.jpg` | `assets/images/` | JPG | 1080 × 1350 | Photo |
| En-têtes après création du compte | Avatar du compte de démo | `avatar.jpg` | `assets/images/` | JPG | 256² | Photo (ou Claude : recadrage de `portrait_homme_30_ans.jpg`) |
| Balance connectée (étape 4) | Balance connectée (icône aujourd'hui) | `balance_connectee.jpg` | `assets/images/` | JPG | 512² | Photo |
| Tous les formulaires | 2 feuilles de basilic | `leaf_a.png` | `assets/images/` | PNG transparent | 512² | Photo |
| Tous les formulaires | 1 feuille de basilic | `leaf_b.png` | `assets/images/` | PNG transparent | 512² | Photo |
| Réserve, scan | Code-barres, appareil photo, +, loupe… | — | — | icône | — | **Reste une icône** (bouton d'action, pas un visuel) |

## 9. Photos de recettes
- **Emplacement** : `assets/images/recipes/`, en attendant Supabase Storage au jalon 8.
- **Format** : JPG, 1200 × 900 px. Le nom du fichier est le code de la recette.

| Recette | Fichier attendu | Production |
|---|---|---|
| Omelette épinards & feta | `omelette_epinards_feta.jpg` | Photo |
| Pancakes banane & avoine | `pancakes_banane_avoine.jpg` | Photo |
| Smoothie bowl vert | `smoothie_bowl_epinards.jpg` | Photo |
| Tartine avocat & œuf | `tartine_avocat_oeuf.jpg` | Photo |
| Frites de patate douce | `frites_patate_douce.jpg` | Photo |
| Pomme & purée d'amande | `pomme_puree_amande.jpg` | Photo |
| Les 24 autres recettes | déjà dans `design/stitch_images/plats/` | Claude (recadrage 4:3) |
| 80 recettes à venir (jalon « Recettes des 8 cuisines », voir PLAN.md) | `<code>.jpg` | Photo |

**Liens Stitch expirés** (écrans des jalons suivants). Ils seront couverts par les photos de recettes ci-dessus :
- Tablée familiale conviviale (`dashboard_home_household`) : **Photo**, fichier `famille_table.jpg`, 1080 × 810.
- Suprême de volaille, Poke bowl, Bowl saumon quinoa : **Claude**, en recadrant des photos proches de `plats/`.
- Tofu rôti : déjà disponible en HD dans `design/stitch/_assets/`.

---

## Récapitulatif : qui produit quoi
| Claude peut produire (0 €) | À générer en photo |
|---|---|
| 8 monogrammes d'enseignes (déjà faits) | 80 ingrédients du catalogue |
| 2 catégories (pâtes-riz, huiles) recadrées | 11 catégories d'aliments |
| Emplacement « Placard » recadré | 3 emplacements (frigo, corbeille, congélateur) |
| | 7 régimes |
| 24 photos de recettes recadrées en 4:3 | 13 allergènes |
| Avatar (recadrage d'un portrait) | |
| 3 photos des liens expirés (recadrages proches) | 5 visuels divers (mode solo, balance, 2 feuilles de basilic, tablée familiale) |
| | 6 recettes sans photo |
| **≈ 40 visuels** | **≈ 125 visuels maintenant** (lot « images par API ») ; les photos des 80 nouvelles recettes et de leurs ~45 nouveaux ingrédients viendront avec le jalon « Recettes des 8 cuisines » |
