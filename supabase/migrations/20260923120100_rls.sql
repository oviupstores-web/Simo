-- =====================================================================
-- Menoo — 2/4 : sécurité (RLS sur toutes les tables)
-- Principe : chaque utilisateur ne voit et ne modifie que les données de
-- ses propres foyers. Les catalogues sont en lecture seule pour les
-- utilisateurs connectés. Le rôle « anon » (non connecté) ne voit rien.
-- =====================================================================

-- ---------------------------------------------------------------------
-- Fonctions d'appartenance (security definer : évitent la récursion RLS)
-- ---------------------------------------------------------------------
create function public.owns_household(p_household_id uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.households h
    where h.id = p_household_id and h.owner_id = (select auth.uid())
  );
$$;

create function public.owns_member(p_member_id uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.household_members m
    join public.households h on h.id = m.household_id
    where m.id = p_member_id and h.owner_id = (select auth.uid())
  );
$$;

create function public.owns_menu(p_menu_id uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.weekly_menus w
    join public.households h on h.id = w.household_id
    where w.id = p_menu_id and h.owner_id = (select auth.uid())
  );
$$;

create function public.owns_shopping_list(p_list_id uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.shopping_lists l
    join public.households h on h.id = l.household_id
    where l.id = p_list_id and h.owner_id = (select auth.uid())
  );
$$;

revoke all on function public.owns_household(uuid), public.owns_member(uuid),
                      public.owns_menu(uuid), public.owns_shopping_list(uuid) from public, anon;
grant execute on function public.owns_household(uuid), public.owns_member(uuid),
                          public.owns_menu(uuid), public.owns_shopping_list(uuid) to authenticated;

-- ---------------------------------------------------------------------
-- Activation de RLS partout
-- ---------------------------------------------------------------------
alter table public.aisles                      enable row level security;
alter table public.equipment                   enable row level security;
alter table public.diets                       enable row level security;
alter table public.allergens                   enable row level security;
alter table public.ingredients                 enable row level security;
alter table public.ingredient_allergens        enable row level security;
alter table public.recipes                     enable row level security;
alter table public.recipe_ingredients          enable row level security;
alter table public.recipe_equipment            enable row level security;
alter table public.recipe_steps                enable row level security;
alter table public.stores                      enable row level security;
alter table public.profiles                    enable row level security;
alter table public.households                  enable row level security;
alter table public.household_members           enable row level security;
alter table public.kitchen_settings            enable row level security;
alter table public.household_equipment         enable row level security;
alter table public.member_diets                enable row level security;
alter table public.member_allergens            enable row level security;
alter table public.member_excluded_ingredients enable row level security;
alter table public.meal_plan_slots             enable row level security;
alter table public.weekly_menus                enable row level security;
alter table public.menu_meals                  enable row level security;
alter table public.pantry_items                enable row level security;
alter table public.pantry_events               enable row level security;
alter table public.shopping_lists              enable row level security;
alter table public.shopping_list_items         enable row level security;
alter table public.orders                      enable row level security;
alter table public.weight_entries              enable row level security;

-- ---------------------------------------------------------------------
-- Catalogues : lecture seule pour les utilisateurs connectés
-- (écriture réservée aux migrations et au rôle service)
-- ---------------------------------------------------------------------
create policy "catalogue lisible" on public.aisles               for select to authenticated using (true);
create policy "catalogue lisible" on public.equipment            for select to authenticated using (true);
create policy "catalogue lisible" on public.diets                for select to authenticated using (true);
create policy "catalogue lisible" on public.allergens            for select to authenticated using (true);
create policy "catalogue lisible" on public.ingredients          for select to authenticated using (true);
create policy "catalogue lisible" on public.ingredient_allergens for select to authenticated using (true);
create policy "catalogue lisible" on public.recipes              for select to authenticated using (is_published);
create policy "catalogue lisible" on public.recipe_ingredients   for select to authenticated using (true);
create policy "catalogue lisible" on public.recipe_equipment     for select to authenticated using (true);
create policy "catalogue lisible" on public.recipe_steps         for select to authenticated using (true);
create policy "catalogue lisible" on public.stores               for select to authenticated using (true);

-- ---------------------------------------------------------------------
-- Profil : chacun lit et modifie le sien ; « premium » est protégé
-- ---------------------------------------------------------------------
create policy "profil : lecture du sien" on public.profiles
  for select to authenticated using (id = (select auth.uid()));

create policy "profil : modification du sien" on public.profiles
  for update to authenticated
  using (id = (select auth.uid()))
  with check (
    id = (select auth.uid())
    and (active_household_id is null or public.owns_household(active_household_id))
  );

-- Le profil est créé par le déclencheur d'inscription, jamais par l'app.
-- Colonnes modifiables par l'app : tout sauf « premium » et les dates techniques.
revoke insert, update, delete on public.profiles from anon, authenticated;
grant update (display_name, mode, active_household_id, onboarding_completed_at)
  on public.profiles to authenticated;

-- ---------------------------------------------------------------------
-- Foyers et tout ce qui en dépend : propriétaire uniquement
-- ---------------------------------------------------------------------
create policy "foyer : propriétaire" on public.households
  for all to authenticated
  using (owner_id = (select auth.uid()))
  with check (owner_id = (select auth.uid()));

create policy "membres : propriétaire du foyer" on public.household_members
  for all to authenticated
  using (public.owns_household(household_id))
  with check (public.owns_household(household_id));

create policy "ma cuisine : propriétaire du foyer" on public.kitchen_settings
  for all to authenticated
  using (public.owns_household(household_id))
  with check (public.owns_household(household_id));

create policy "équipements : propriétaire du foyer" on public.household_equipment
  for all to authenticated
  using (public.owns_household(household_id))
  with check (public.owns_household(household_id));

create policy "régimes : propriétaire du membre" on public.member_diets
  for all to authenticated
  using (public.owns_member(member_id))
  with check (public.owns_member(member_id));

create policy "allergènes : propriétaire du membre" on public.member_allergens
  for all to authenticated
  using (public.owns_member(member_id))
  with check (public.owns_member(member_id));

create policy "exclusions : propriétaire du membre" on public.member_excluded_ingredients
  for all to authenticated
  using (public.owns_member(member_id))
  with check (public.owns_member(member_id));

create policy "grille : propriétaire du foyer" on public.meal_plan_slots
  for all to authenticated
  using (public.owns_household(household_id))
  with check (public.owns_household(household_id));

create policy "réserve : propriétaire du foyer" on public.pantry_items
  for all to authenticated
  using (public.owns_household(household_id))
  with check (public.owns_household(household_id));

create policy "anti-gaspi : propriétaire du foyer" on public.pantry_events
  for all to authenticated
  using (public.owns_household(household_id))
  with check (public.owns_household(household_id));

create policy "poids : propriétaire du membre" on public.weight_entries
  for all to authenticated
  using (public.owns_member(member_id))
  with check (public.owns_member(member_id));

-- Menus : l'app les lit ; ils sont créés et modifiés par la génération
-- (Edge Function, rôle service), jamais directement par l'app.
create policy "menus : lecture" on public.weekly_menus
  for select to authenticated using (public.owns_household(household_id));

create policy "repas : lecture" on public.menu_meals
  for select to authenticated using (public.owns_menu(menu_id));

-- Seule action directe autorisée : marquer un repas comme cuisiné.
create policy "repas : marquer cuisiné" on public.menu_meals
  for update to authenticated
  using (public.owns_menu(menu_id))
  with check (public.owns_menu(menu_id));
revoke insert, update, delete on public.weekly_menus, public.menu_meals from anon, authenticated;
grant update (cooked_at) on public.menu_meals to authenticated;

-- Listes de courses : lecture ; seule la case « coché » est modifiable.
create policy "listes : lecture" on public.shopping_lists
  for select to authenticated using (public.owns_household(household_id));

create policy "articles : lecture" on public.shopping_list_items
  for select to authenticated using (public.owns_shopping_list(list_id));

create policy "articles : cocher" on public.shopping_list_items
  for update to authenticated
  using (public.owns_shopping_list(list_id))
  with check (public.owns_shopping_list(list_id));
revoke insert, update, delete on public.shopping_lists, public.shopping_list_items from anon, authenticated;
grant update (checked) on public.shopping_list_items to authenticated;

-- Commandes : lecture et création/modification par le propriétaire.
create policy "commandes : propriétaire du foyer" on public.orders
  for all to authenticated
  using (public.owns_household(household_id))
  with check (public.owns_household(household_id) and public.owns_shopping_list(list_id));

-- Rien pour le rôle « anon » : sans connexion, aucune donnée n'est accessible.
