-- MENOO / menoo.guest-import v1 / 2026-10-22
-- BROUILLON NON EXÉCUTABLE EN L'ÉTAT. Dépend de M1/M2.
-- Durcissement candidat : ne pas appliquer isolément à une application existante.
begin;
do $draft$ begin
  raise exception 'MENOO_DRAFT_NOT_AUTHORIZED: M3';
end $draft$;

-- Ne jamais réutiliser silencieusement un rôle préexistant.
create role menoo_import_executor nologin nosuperuser nocreatedb nocreaterole
  noinherit noreplication nobypassrls;

revoke all on schema menoo_private from public, anon, authenticated;
revoke create on schema public from public, anon, authenticated;
grant usage on schema public, auth, menoo_private to menoo_import_executor;
grant usage on schema public, auth to authenticated;
grant execute on function auth.uid() to authenticated;
grant usage on type public.app_mode, public.health_goal, public.sex,
  public.activity_level, public.member_role, public.management_mode,
  public.cooking_level, public.meal_type, public.pantry_location,
  public.pantry_source to menoo_import_executor;
grant execute on function auth.uid(), public.owns_household(uuid),
  public.owns_member(uuid) to menoo_import_executor;
grant execute on function pg_catalog.gen_random_uuid(), pg_catalog.transaction_timestamp(),
  pg_catalog.now() to menoo_import_executor;

-- Contrôle conservateur des rôles hérités ET de SET ROLE (pas seulement INHERIT).
-- Le rôle authenticator du gateway peut être membre d'authenticated : ce sens
-- inverse ne donne pas au client authenticated le droit d'assumer authenticator.
do $roles$
declare v_client oid;
begin
  for v_client in select oid from pg_catalog.pg_roles
    where rolname in ('anon','authenticated','menoo_import_executor') loop
    if exists (
      with recursive parents(roleid) as (
        select roleid from pg_catalog.pg_auth_members where member = v_client
        union
        select m.roleid from pg_catalog.pg_auth_members m join parents p on m.member = p.roleid
      ) select 1 from parents
    ) then
      raise exception 'MENOO_ROLE_MEMBERSHIPS_REQUIRE_REVIEW';
    end if;
  end loop;
end $roles$;

-- Retirer AUSSI les droits de colonne historiques, notamment sur profiles.
-- Ensemble limité aux 28 tables des sept migrations, jamais ALL TABLES public.
do $acl$
declare v_table text; v_columns text;
begin
  foreach v_table in array array[
    'aisles','equipment','diets','allergens','ingredients','ingredient_allergens',
    'recipes','recipe_ingredients','recipe_equipment','recipe_steps','stores',
    'profiles','households','household_members','kitchen_settings','household_equipment',
    'member_diets','member_allergens','member_excluded_ingredients','meal_plan_slots',
    'weekly_menus','menu_meals','pantry_items','pantry_events','shopping_lists',
    'shopping_list_items','orders','weight_entries'
  ] loop
    execute pg_catalog.format('REVOKE ALL PRIVILEGES ON TABLE public.%I FROM PUBLIC, anon, authenticated', v_table);
    select pg_catalog.string_agg(pg_catalog.quote_ident(a.attname), ', ' order by a.attnum)
      into v_columns from pg_catalog.pg_attribute a
      where a.attrelid = pg_catalog.to_regclass('public.' || v_table)
        and a.attnum > 0 and not a.attisdropped;
    execute pg_catalog.format(
      'REVOKE ALL PRIVILEGES (%s) ON TABLE public.%I FROM PUBLIC, anon, authenticated', v_columns, v_table);
    execute pg_catalog.format('GRANT SELECT ON TABLE public.%I TO authenticated', v_table);
  end loop;
end $acl$;
revoke all on public.recipe_catalog from public, anon, authenticated;
grant select on public.recipe_catalog to authenticated;

-- Remplacer les anciens FOR ALL ; ajouter une politique ne les neutraliserait pas.
-- Les noms inattendus sont bloquants : ne pas effacer une politique distante inconnue.
do $policies$
declare v_table text; v_predicate text; v_policy record;
begin
  for v_table, v_predicate in select * from (values
    ('households', 'owner_id = (select auth.uid())'),
    ('household_members', 'public.owns_household(household_id)'),
    ('kitchen_settings', 'public.owns_household(household_id)'),
    ('household_equipment', 'public.owns_household(household_id)'),
    ('member_diets', 'public.owns_member(member_id)'),
    ('member_allergens', 'public.owns_member(member_id)'),
    ('member_excluded_ingredients', 'public.owns_member(member_id)'),
    ('meal_plan_slots', 'public.owns_household(household_id)'),
    ('pantry_items', 'public.owns_household(household_id)'),
    ('pantry_events', 'public.owns_household(household_id)'),
    ('weight_entries', 'public.owns_member(member_id)'),
    ('orders', 'public.owns_household(household_id)')
  ) as rules(table_name, predicate) loop
    for v_policy in select polname from pg_catalog.pg_policy
      where polrelid = pg_catalog.to_regclass('public.' || v_table) loop
      if v_policy.polname <> all(array[
        'foyer : propriétaire','membres : propriétaire du foyer','ma cuisine : propriétaire du foyer',
        'équipements : propriétaire du foyer','régimes : propriétaire du membre',
        'allergènes : propriétaire du membre','exclusions : propriétaire du membre',
        'grille : propriétaire du foyer','réserve : propriétaire du foyer',
        'anti-gaspi : propriétaire du foyer','poids : propriétaire du membre',
        'commandes : propriétaire du foyer'
      ]) then raise exception 'MENOO_UNKNOWN_POLICY_REQUIRES_REVIEW'; end if;
      execute pg_catalog.format('DROP POLICY %I ON public.%I', v_policy.polname, v_table);
    end loop;
    execute pg_catalog.format(
      'CREATE POLICY menoo_owner_read ON public.%I FOR SELECT TO authenticated USING (%s)',
      v_table, v_predicate);
  end loop;
end $policies$;

-- Réduire les écritures client aux trois colonnes déjà utiles et non privilégiées.
-- Les politiques existantes profil/repas/articles continuent à contrôler le propriétaire.
grant update (display_name) on public.profiles to authenticated;
grant update (cooked_at) on public.menu_meals to authenticated;
grant update (checked) on public.shopping_list_items to authenticated;

-- Détails de recettes : remplacer la politique permissive historique.
drop policy "catalogue lisible" on public.recipe_ingredients;
drop policy "catalogue lisible" on public.recipe_equipment;
drop policy "catalogue lisible" on public.recipe_steps;
create policy menoo_published_recipe_detail on public.recipe_ingredients
  for select to authenticated using (exists (
    select 1 from public.recipes r where r.id = recipe_id and r.is_published));
create policy menoo_published_recipe_detail on public.recipe_equipment
  for select to authenticated using (exists (
    select 1 from public.recipes r where r.id = recipe_id and r.is_published));
create policy menoo_published_recipe_detail on public.recipe_steps
  for select to authenticated using (exists (
    select 1 from public.recipes r where r.id = recipe_id and r.is_published));

-- Rôle technique soumis à RLS, propriétaire d'aucune table.
create policy menoo_executor_profile_read on public.profiles
  for select to menoo_import_executor using (id = (select auth.uid()));
create policy menoo_executor_profile_update on public.profiles
  for update to menoo_import_executor using (id = (select auth.uid()))
  with check (id = (select auth.uid()) and
    (active_household_id is null or public.owns_household(active_household_id)));
create policy menoo_executor_household_read on public.households
  for select to menoo_import_executor using (owner_id = (select auth.uid()));
create policy menoo_executor_household_insert on public.households
  for insert to menoo_import_executor with check (owner_id = (select auth.uid()) and not is_demo);
create policy menoo_executor_household_update on public.households
  for update to menoo_import_executor using (owner_id = (select auth.uid()))
  with check (owner_id = (select auth.uid()) and not is_demo);

do $executor_policies$
declare v_table text; v_predicate text;
begin
  for v_table, v_predicate in select * from (values
    ('household_members','public.owns_household(household_id)'),
    ('kitchen_settings','public.owns_household(household_id)'),
    ('household_equipment','public.owns_household(household_id)'),
    ('member_diets','public.owns_member(member_id)'),
    ('member_allergens','public.owns_member(member_id)'),
    ('meal_plan_slots','public.owns_household(household_id)'),
    ('pantry_items','public.owns_household(household_id)')
  ) as rules(table_name, predicate) loop
    execute pg_catalog.format(
      'CREATE POLICY menoo_executor_read ON public.%I FOR SELECT TO menoo_import_executor USING (%s)',
      v_table, v_predicate);
    execute pg_catalog.format(
      'CREATE POLICY menoo_executor_insert ON public.%I FOR INSERT TO menoo_import_executor WITH CHECK (%s)',
      v_table, v_predicate);
  end loop;
end $executor_policies$;

create policy menoo_executor_equipment_catalog on public.equipment
  for select to menoo_import_executor using (true);
create policy menoo_executor_diet_catalog on public.diets
  for select to menoo_import_executor using (true);
create policy menoo_executor_allergen_catalog on public.allergens
  for select to menoo_import_executor using (true);
create policy menoo_executor_registry_read on menoo_private.guest_imports
  for select to menoo_import_executor using (owner_id = (select auth.uid()));
create policy menoo_executor_registry_insert on menoo_private.guest_imports
  for insert to menoo_import_executor with check (
    owner_id = (select auth.uid()) and public.owns_household(household_id));

grant select on public.profiles, public.households, public.household_members,
  public.kitchen_settings, public.household_equipment, public.member_diets,
  public.member_allergens, public.meal_plan_slots, public.pantry_items,
  public.equipment, public.diets, public.allergens, menoo_private.guest_imports
  to menoo_import_executor;
grant update (mode, active_household_id, onboarding_completed_at)
  on public.profiles to menoo_import_executor;
grant update (main_cook_member_id) on public.households to menoo_import_executor;
grant insert (id, owner_id, name, mode, weekly_budget_cents, budget_currency,
  management_mode, cuisine_preferences, diet_codes, allergen_codes, excluded_foods,
  portion_rules_version) on public.households to menoo_import_executor;
grant insert (id, household_id, first_name, role, sex, age_years, height_cm,
  weight_kg, goal, activity, is_owner, position, target_weight_kg, weekly_rate_kg,
  excluded_foods, wants_scale, source_local_id)
  on public.household_members to menoo_import_executor;
grant insert (household_id, cooking_level, weekday_minutes, weekend_minutes)
  on public.kitchen_settings to menoo_import_executor;
grant insert (household_id, equipment_code) on public.household_equipment to menoo_import_executor;
grant insert (member_id, diet_code) on public.member_diets to menoo_import_executor;
grant insert (member_id, allergen_code) on public.member_allergens to menoo_import_executor;
grant insert (household_id, day_of_week, meal_type) on public.meal_plan_slots to menoo_import_executor;
grant insert (id, household_id, name, quantity, unit, unit_label, location, expires_on,
  expiry_origin, source, local_food_id, declared_category, declared_stock, source_local_id)
  on public.pantry_items to menoo_import_executor;
grant insert (owner_id, operation_id, source_origin_id, journey, contract_version,
  canonical_version, source_versions, payload_hash, household_id, receipt)
  on menoo_private.guest_imports to menoo_import_executor;

-- Helpers privés existants ; les nouvelles fonctions M4 auront leurs GRANT explicites.
grant execute on function menoo_private.currency_exponent(text),
  menoo_private.budget_to_minor(numeric,text), menoo_private.valid_minor_budget(numeric,text),
  menoo_private.text_array_shape(text[],boolean) to menoo_import_executor;

-- Les fonctions trigger ne sont pas des RPC. Aucun appel direct client autorisé.
revoke all on function public.handle_new_user(), public.set_updated_at(),
  public.load_demo_data(uuid) from public, anon, authenticated, menoo_import_executor;

-- Aucun GRANT de séquence : les sept migrations utilisent des UUID, aucune séquence.
-- Aucun droit sur premium, aucun DELETE, aucun UPDATE/DELETE du registre,
-- aucun INSERT dans weekly_menus/menu_meals/courses/poids, aucun CREATE permanent.
-- Les privilèges des rôles service/admin et les DEFAULT PRIVILEGES de CHAQUE
-- créateur réel doivent être inventoriés avant adoption. Ne pas les présumer sûrs.

-- Contrôle de contexte candidat PostgreSQL 17 : compatible avec le principe
-- Supabase de rôles clients distincts de service_role/supabase_admin/postgres.
-- Ces rôles administratifs légitimes ne sont PAS interdits comme propriétaires.
-- Leur configuration effective et les memberships doivent être vérifiés en base
-- isolée avant adoption : aucun rôle distant n'est modifié ou présumé conforme.
do $security_guard$
begin
  if exists (
    select 1 from pg_catalog.pg_roles
    where rolname in ('anon', 'authenticated', 'menoo_import_executor')
      and (rolsuper or rolbypassrls or rolcreaterole or rolcreatedb or rolreplication)
  ) then
    raise exception 'MENOO_UNSAFE_ROLE_ATTRIBUTES';
  end if;

  if exists (
    select 1
    from pg_catalog.pg_class c
    join pg_catalog.pg_namespace n on n.oid = c.relnamespace
    where c.relkind in ('r', 'p') and (
      (n.nspname = 'public' and c.relname = any(array[
        'aisles','equipment','diets','allergens','ingredients','ingredient_allergens',
        'recipes','recipe_ingredients','recipe_equipment','recipe_steps','stores',
        'profiles','households','household_members','kitchen_settings','household_equipment',
        'member_diets','member_allergens','member_excluded_ingredients','meal_plan_slots',
        'weekly_menus','menu_meals','pantry_items','pantry_events','shopping_lists',
        'shopping_list_items','orders','weight_entries'
      ])) or (n.nspname = 'menoo_private' and c.relname = 'guest_imports')
    ) and (
      not c.relrowsecurity
      or (n.nspname = 'menoo_private' and not c.relforcerowsecurity)
      or exists (
        select 1 from pg_catalog.pg_roles r
        where r.rolname in ('anon', 'authenticated', 'menoo_import_executor')
          and (
            pg_catalog.pg_has_role(r.oid, c.relowner, 'USAGE')
            or pg_catalog.pg_has_role(r.oid, c.relowner, 'SET')
          )
      )
    )
  ) then
    raise exception 'MENOO_UNSAFE_TABLE_SECURITY';
  end if;
end $security_guard$;

-- Ce garde-fou ne prouve ni l'absence d'autres politiques permissives/fonctions
-- privilégiées ni la sécurité des chemins service/admin. En cas de refus,
-- diagnostiquer la configuration ; ne pas corriger les rôles automatiquement.
commit;
