# Base de données Menoo (Supabase `menoo-dev`)

Les fichiers de `migrations/` créent la base, dans l'ordre :

| Fichier | Contenu |
|---|---|
| `20260923120000_schema.sql` | Structure : 28 tables, types, vue du catalogue, création automatique du profil à l'inscription |
| `20260923120100_rls.sql` | Sécurité : RLS sur toutes les tables (chacun ne voit que ses foyers), `premium` protégé |
| `20260923120200_catalog.sql` | Catalogue : 6 rayons, 9 équipements, 6 régimes (« sans porc » et « halal » fusionnés), 14 allergènes, 80 ingrédients (prix estimés), 30 recettes, 3 enseignes |
| `20260923120300_demo_data.sql` | Fonction `load_demo_data` : Karim (Solo), famille Martin (Foyer) et 4 cas pièges |

## Les grandes familles de tables
- **Compte** : `profiles` (1 par compte ; `premium` = paywall simulé, non modifiable par l'app).
- **Foyer** : `households` (Solo = foyer d'une personne), `household_members`, `kitchen_settings` + `household_equipment` (« Ma cuisine »), `member_diets` / `member_allergens` / `member_excluded_ingredients` (contraintes), `meal_plan_slots` (grille des repas).
- **Catalogue** (lecture seule) : `ingredients`, `recipes`, `recipe_ingredients`, `recipe_equipment`, `recipe_steps`, `stores`… et la vue `recipe_catalog` (coût par portion, régimes compatibles, allergènes, équipements) qui servira au filtre SQL du jalon 6.
- **Semaine** : `weekly_menus` (une règle empêche d'enregistrer un menu « prêt » au-dessus du budget) et `menu_meals` (un seul repas « Offert » par menu).
- **Réserve** : `pantry_items` (emplacement obligatoire : frigo, placard, congélateur, corbeille) et `pantry_events` (anti-gaspi).
- **Courses** : `shopping_lists`, `shopping_list_items` (réserve déduite automatiquement), `orders` (un seul montant, identique du comparateur au paiement).
- **Suivi** : `weight_entries` (Health Connect ou saisie manuelle).

## Sécurité
- RLS activée sur les 28 tables. Sans connexion : aucune donnée visible.
- Menus et listes de courses sont écrits par la génération (Edge Function), l'app ne peut que les lire, cocher un article ou marquer un repas cuisiné.
- Suppression du compte : tout est supprimé en cascade (profil, foyers, réserve, menus, suivi).

## Données de démo
Après création d'un compte de test (tableau de bord Supabase → Authentication → Add user), dans l'éditeur SQL :

```sql
select public.load_demo_data('<identifiant du compte de test>');
```

Foyers créés pour ce compte : **Karim** (Solo, 65 €), **Famille Martin** (Thomas, Sarah, Lucas, Emma, 110 €) et 4 pièges :
1. **Budget impossible** — 20 € pour 21 repas en prise de masse → la génération doit échouer proprement.
2. **Allergies cumulées** — 12 allergènes + végétarien + exclusions → très peu de recettes possibles.
3. **Réserve couvrant tout** — tous les ingrédients en réserve → liste de courses à 0 €.
4. **Foyer de 7 personnes** — 3 adultes, 3 enfants, 1 bébé, budget 170 €.
