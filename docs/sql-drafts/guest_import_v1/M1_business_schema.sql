-- MENOO / menoo.guest-import v1 / 2026-10-22
-- BROUILLON NON EXÉCUTABLE EN L'ÉTAT. Aucune exécution autorisée.
-- Lire TECHNICAL_DECISIONS.md et TEST_PLAN.md. Ordre candidat : M1, M2, M3, M4.
-- La garde ci-dessous fait échouer toute la transaction, volontairement.
-- Ne pas la retirer sans une nouvelle autorisation et la levée des blocages.
begin;
do $draft$ begin
  raise exception 'MENOO_DRAFT_NOT_AUTHORIZED: M1';
end $draft$;

do $preflight$ begin
  if current_setting('server_version_num')::integer / 10000 <> 17 then
    raise exception 'MENOO_REQUIRES_POSTGRESQL_17';
  end if;
end $preflight$;

-- Schéma privé, non ajouté aux schémas exposés par PostgREST.
-- Une collision de nom doit arrêter la préparation, jamais reprendre un objet inconnu.
create schema menoo_private;
revoke all on schema menoo_private from public, anon, authenticated;
alter default privileges in schema menoo_private revoke execute on functions from public;

create function menoo_private.currency_exponent(p_code text) returns integer
language plpgsql immutable set search_path = '' as $fn$
begin
  case p_code
    when 'TND' then return 3;
    when 'EUR', 'GBP', 'USD', 'CAD', 'AUD', 'CHF', 'MAD', 'DZD' then return 2;
    else raise exception using errcode = '22023', message = 'import_currency_unsupported';
  end case;
end $fn$;

create function menoo_private.budget_to_minor(p_major numeric, p_currency text)
returns numeric language plpgsql immutable set search_path = '' as $fn$
declare v_minor numeric;
begin
  if p_major is null or not (p_major >= 20 and p_major <= 9223372036854775807)
     or p_major <> pg_catalog.trunc(p_major) then
    -- Le modèle Dart actuel collecte un nombre ENTIER d'unités majeures.
    raise exception using errcode = '22023', message = 'import_budget_invalid';
  end if;
  v_minor := p_major * pg_catalog.power(10::numeric, menoo_private.currency_exponent(p_currency));
  if v_minor <> pg_catalog.trunc(v_minor) then
    raise exception using errcode = '22023', message = 'import_budget_not_representable';
  end if;
  return v_minor;
end $fn$;

create function menoo_private.valid_minor_budget(p_minor numeric, p_currency text)
returns boolean language plpgsql immutable set search_path = '' as $fn$
begin
  if p_minor is null or not (p_minor >= 2000 and p_minor < 'Infinity'::numeric)
     or p_minor <> pg_catalog.trunc(p_minor) then return false; end if;
  -- NULL = devise historique inconnue, sans attribution fictive d'EUR.
  if p_currency is null then return true; end if;
  return p_minor >= 20 * pg_catalog.power(10::numeric, menoo_private.currency_exponent(p_currency));
exception when invalid_parameter_value then return false;
end $fn$;

create function menoo_private.text_array_shape(p_values text[], p_unique boolean)
returns boolean language sql immutable set search_path = '' as $fn$
  select p_values is null or (
    (pg_catalog.cardinality(p_values) = 0 or
      (pg_catalog.array_ndims(p_values) = 1 and pg_catalog.array_lower(p_values, 1) = 1))
    and not exists (select 1 from pg_catalog.unnest(p_values) v where v is null)
    and (not p_unique or pg_catalog.cardinality(p_values) =
      (select pg_catalog.count(distinct v collate "C") from pg_catalog.unnest(p_values) v))
  );
$fn$;

-- NUMERIC sans typmod : pas de perte due à numeric(5,1), numeric(10,2),
-- ni de plafond bigint artificiel pour budgetAmount * 1000.
-- Les noms historiques *_cents sont conservés : unités mineures de la devise.
alter table public.households
  alter column weekly_budget_cents type numeric using weekly_budget_cents::numeric,
  add column budget_currency text,
  add column diet_codes text[],
  add column allergen_codes text[],
  add column excluded_foods text[],
  add column portion_rules_version smallint;

alter table public.households
  drop constraint households_weekly_budget_cents_check,
  add constraint households_budget_exact
    check (menoo_private.valid_minor_budget(weekly_budget_cents, budget_currency)) not valid,
  add constraint households_diets_shape
    check (menoo_private.text_array_shape(diet_codes, true)) not valid,
  add constraint households_allergens_shape
    check (menoo_private.text_array_shape(allergen_codes, true)) not valid,
  add constraint households_exclusions_shape
    check (menoo_private.text_array_shape(excluded_foods, false)) not valid,
  add constraint households_portions_version
    check (portion_rules_version is null or portion_rules_version = 1) not valid;

comment on column public.households.budget_currency is
  'NULL historique non résolu. Import V1 : devise explicite, jamais déduite de la langue.';
comment on column public.households.weekly_budget_cents is
  'Nom historique conservé ; entier exact en unités mineures, associé à budget_currency. Aucun change.';
comment on column public.households.portion_rules_version is
  '1 : adulte=1, enfant=0.65, bebe=0.3. NULL historique, sans recalcul ni backfill.';

alter table public.household_members
  alter column height_cm type bigint using height_cm::bigint,
  alter column weight_kg type numeric using weight_kg::numeric,
  alter column target_weight_kg type numeric using target_weight_kg::numeric,
  add column excluded_foods text[],
  add column wants_scale boolean,
  add column source_local_id text;

-- Élargissement seulement : les valeurs historiques restent inchangées.
-- La validation différenciée Solo/adulte/enfant/bébé appartient à M4.
alter table public.household_members
  drop constraint household_members_height_cm_check,
  drop constraint household_members_weight_kg_check,
  drop constraint household_members_target_weight_kg_check,
  add constraint household_members_height_positive
    check (height_cm is null or height_cm between 1 and 9007199254740991) not valid,
  add constraint household_members_weight_finite
    check (weight_kg is null or (weight_kg > 0 and weight_kg <= 9007199254740991)) not valid,
  add constraint household_members_target_positive
    check (target_weight_kg is null or (target_weight_kg > 0 and target_weight_kg <= 300)) not valid,
  add constraint household_members_exclusions_shape
    check (menoo_private.text_array_shape(excluded_foods, false)) not valid,
  add constraint household_members_source_id_valid
    check (source_local_id is null or source_local_id ~ '^(solo|[1-9][0-9]*)$') not valid;

-- Les autres contraintes historiques de cible/rythme sont conservées.
-- Le seuil Dart utilise ceil(...*10)/10, contrôlé pour les NOUVEAUX imports.
-- Ne pas réécrire les cibles historiques au nouveau seuil.

alter table public.pantry_items
  alter column quantity type numeric using quantity::numeric,
  alter column quantity drop not null,
  alter column unit type text using unit::text,
  alter column unit drop not null,
  add column unit_label text,
  add column expiry_origin text,
  add column local_food_id text,
  add column declared_category text,
  add column declared_stock text,
  add column source_local_id text;

alter table public.pantry_items
  drop constraint pantry_items_quantity_check,
  add constraint pantry_items_quantity_exact
    check (quantity is null or (quantity >= 0 and quantity < 'Infinity'::numeric)) not valid,
  add constraint pantry_items_unit_controlled
    check (unit is null or unit in ('g','kg','ml','l','piece','pack')) not valid,
  add constraint pantry_items_expiry_origin_controlled
    check (expiry_origin is null or expiry_origin in ('unknown','estimated','userProvided')) not valid,
  add constraint pantry_items_expiry_consistent
    check (expires_on is not null or expiry_origin is null or expiry_origin = 'unknown') not valid,
  add constraint pantry_items_declared_category_controlled check (
    declared_category is null or declared_category in (
      'pasta_rice_starches','oil_condiments','eggs_dairy','canned_sauce',
      'fresh_vegetables','fruits','flour_sugar','spices_herbs','frozen_meat_fish')) not valid,
  add constraint pantry_items_declared_stock_controlled
    check (declared_stock is null or declared_stock in ('present','some')) not valid,
  add constraint pantry_items_source_id_valid check (
    source_local_id is null or source_local_id ~ '^[A-Za-z0-9][A-Za-z0-9._:-]{0,127}$') not valid;

-- Ne PAS modifier public.unit, encore utilisé par ingredients.
-- Ne PAS déduire FoodCategory de declared_category, d'un nom ou d'un formulaire.
-- Aucun UPDATE de données historiques, aucune valeur par défaut pour les ajouts.

-- Contrôles de catalogue pour les tableaux : un CHECK avec sous-requête serait invalide.
-- Le déclencheur contrôle les écritures ; les catalogues restent administrés.
create function menoo_private.check_household_arrays() returns trigger
language plpgsql set search_path = '' as $fn$
begin
  if exists (select 1 from pg_catalog.unnest(new.diet_codes) c
             where not exists (select 1 from public.diets d where d.code = c))
     or exists (select 1 from pg_catalog.unnest(new.allergen_codes) c
             where not exists (select 1 from public.allergens a where a.code = c))
     or (select pg_catalog.count(*) from pg_catalog.unnest(new.diet_codes) c
          where c in ('vegetarien','vegan','pescetarien')) > 1 then
    raise exception using errcode = '23514', message = 'import_household_constraints_invalid';
  end if;
  return new;
end $fn$;

create trigger menoo_household_arrays
before insert or update of diet_codes, allergen_codes on public.households
for each row execute function menoo_private.check_household_arrays();

-- Les FK des tableaux ne sont pas natives : toute future suppression/modification
-- d'un code de catalogue doit d'abord vérifier ces références (blocage documenté).
revoke all on all functions in schema menoo_private from public, anon, authenticated;
commit;
