-- =====================================================================
-- Menoo — 1/4 : structure de la base
-- Solo et Foyer partagent les mêmes tables : un compte Solo possède un
-- « foyer » d'un seul membre (SPEC §0.6 : un seul code, variantes d'écran).
-- Montants en centimes d'euro (entiers) pour éviter les erreurs d'arrondi.
-- =====================================================================

-- ---------------------------------------------------------------------
-- Types énumérés
-- ---------------------------------------------------------------------
create type public.app_mode          as enum ('solo', 'foyer');
create type public.health_goal       as enum ('perte_poids', 'prise_masse', 'seche', 'maintien');
create type public.sex               as enum ('homme', 'femme');
create type public.activity_level    as enum ('sedentaire', 'leger', 'modere', 'actif', 'tres_actif');
create type public.member_role       as enum ('adulte', 'enfant', 'bebe');
create type public.management_mode   as enum ('courses', 'reserves', 'mixte');
create type public.shopping_channel  as enum ('drive', 'magasin', 'livraison');
create type public.cooking_level     as enum ('debutant', 'intermediaire', 'confirme');
create type public.meal_type         as enum ('petit_dejeuner', 'dejeuner', 'diner', 'collation');
-- SPEC §7 onglet 4 : emplacement obligatoire de chaque aliment
create type public.pantry_location   as enum ('fridge', 'pantry', 'freezer', 'fruit_basket');
create type public.pantry_source     as enum ('manuel', 'code_barres', 'photo_ia', 'verification_rapide');
create type public.pantry_event_type as enum ('consomme', 'jete', 'recette_anti_gaspi');
create type public.food_origin       as enum ('vegetal', 'viande', 'porc', 'poisson', 'fruits_de_mer', 'laitier', 'oeuf', 'miel');
create type public.unit              as enum ('g', 'ml', 'piece');
create type public.menu_status       as enum ('en_generation', 'pret', 'echec');
create type public.order_status      as enum ('brouillon', 'valide', 'paye', 'annule');
create type public.weight_source     as enum ('health_connect', 'manuel');

-- Mise à jour automatique de updated_at
create function public.set_updated_at() returns trigger
language plpgsql set search_path = '' as $$
begin
  new.updated_at := now();
  return new;
end $$;

-- ---------------------------------------------------------------------
-- Catalogues de référence (lecture seule pour l'app)
-- ---------------------------------------------------------------------
create table public.aisles (
  code     text primary key,
  label    text not null,
  position smallint not null
);
comment on table public.aisles is 'Rayons du magasin (tri de la liste de courses).';

create table public.equipment (
  code     text primary key,
  label    text not null,
  position smallint not null
);
comment on table public.equipment is 'Équipements de cuisine (étape « Ma cuisine »).';

create table public.diets (
  code  text primary key,
  label text not null
);

create table public.allergens (
  code  text primary key,
  label text not null
);
comment on table public.allergens is 'Les 14 allergènes à déclaration obligatoire (UE).';

create table public.ingredients (
  id                   uuid primary key default gen_random_uuid(),
  slug                 text not null unique,
  name                 text not null,
  aisle_code           text not null references public.aisles (code),
  default_location     public.pantry_location not null,
  unit                 public.unit not null,
  -- prix estimé par unité (par g, par ml ou par pièce), en centimes
  price_cents_per_unit numeric(10, 4) not null check (price_cents_per_unit >= 0),
  origin               public.food_origin not null default 'vegetal',
  shelf_life_days      integer check (shelf_life_days > 0),
  image_path           text,
  created_at           timestamptz not null default now()
);
comment on column public.ingredients.default_location is 'Emplacement proposé par défaut à l''ajout en réserve (modifiable).';

create table public.ingredient_allergens (
  ingredient_id uuid not null references public.ingredients (id) on delete cascade,
  allergen_code text not null references public.allergens (code),
  primary key (ingredient_id, allergen_code)
);

create table public.recipes (
  id              uuid primary key default gen_random_uuid(),
  slug            text not null unique,
  title           text not null,
  description     text,
  meal_types      public.meal_type[] not null check (cardinality(meal_types) > 0),
  cooking_level   public.cooking_level not null,
  total_minutes   smallint not null check (total_minutes > 0),
  servings_base   smallint not null default 4 check (servings_base > 0),
  kcal_per_serving smallint not null check (kcal_per_serving > 0),
  protein_g       numeric(5, 1) not null,
  carbs_g         numeric(5, 1) not null,
  fat_g           numeric(5, 1) not null,
  image_path      text,
  is_published    boolean not null default true,
  created_at      timestamptz not null default now()
);
comment on column public.recipes.servings_base is 'Nombre de portions pour lesquelles les quantités de recipe_ingredients sont données.';

create table public.recipe_ingredients (
  recipe_id     uuid not null references public.recipes (id) on delete cascade,
  ingredient_id uuid not null references public.ingredients (id),
  quantity      numeric(10, 2) not null check (quantity > 0),
  primary key (recipe_id, ingredient_id)
);

create table public.recipe_equipment (
  recipe_id      uuid not null references public.recipes (id) on delete cascade,
  equipment_code text not null references public.equipment (code),
  primary key (recipe_id, equipment_code)
);

create table public.recipe_steps (
  recipe_id   uuid not null references public.recipes (id) on delete cascade,
  position    smallint not null check (position > 0),
  instruction text not null,
  minutes     smallint check (minutes >= 0),
  primary key (recipe_id, position)
);

create table public.stores (
  id                uuid primary key default gen_random_uuid(),
  name              text not null,
  logo_path         text,
  supports_drive    boolean not null default true,
  supports_delivery boolean not null default false
);

-- Vue calculée du catalogue : coût par portion, régimes compatibles,
-- allergènes et équipements. Base du filtre SQL de génération (jalon 6).
create view public.recipe_catalog with (security_invoker = true) as
select
  r.*,
  cost.cents_per_serving                                         as cost_cents_per_serving,
  flags.is_vegan,
  flags.is_vegetarian,
  flags.is_pescetarian,
  flags.is_pork_free,
  coalesce(alg.codes, '{}')                                      as allergens,
  coalesce(eq.codes, '{}')                                       as equipment
from public.recipes r
cross join lateral (
  select round(sum(ri.quantity * i.price_cents_per_unit) / r.servings_base)::integer as cents_per_serving
  from public.recipe_ingredients ri
  join public.ingredients i on i.id = ri.ingredient_id
  where ri.recipe_id = r.id
) cost
cross join lateral (
  select
    coalesce(bool_and(i.origin = 'vegetal'), true)                                            as is_vegan,
    coalesce(bool_and(i.origin not in ('viande', 'porc', 'poisson', 'fruits_de_mer')), true)  as is_vegetarian,
    coalesce(bool_and(i.origin not in ('viande', 'porc')), true)                              as is_pescetarian,
    coalesce(bool_and(i.origin <> 'porc'), true)                                              as is_pork_free
  from public.recipe_ingredients ri
  join public.ingredients i on i.id = ri.ingredient_id
  where ri.recipe_id = r.id
) flags
cross join lateral (
  select array_agg(distinct ia.allergen_code order by ia.allergen_code) as codes
  from public.recipe_ingredients ri
  join public.ingredient_allergens ia on ia.ingredient_id = ri.ingredient_id
  where ri.recipe_id = r.id
) alg
cross join lateral (
  select array_agg(re.equipment_code order by re.equipment_code) as codes
  from public.recipe_equipment re
  where re.recipe_id = r.id
) eq;

-- ---------------------------------------------------------------------
-- Comptes et foyers
-- ---------------------------------------------------------------------
create table public.profiles (
  id                      uuid primary key references auth.users (id) on delete cascade,
  display_name            text,
  mode                    public.app_mode,
  -- Paywall simulé tant que l'app n'est pas publiée : modifiable uniquement
  -- par l'administrateur (voir fichier RLS), jamais par l'app.
  premium                 boolean not null default false,
  active_household_id     uuid,
  onboarding_completed_at timestamptz,
  created_at              timestamptz not null default now(),
  updated_at              timestamptz not null default now()
);

create table public.households (
  id                   uuid primary key default gen_random_uuid(),
  owner_id             uuid not null references public.profiles (id) on delete cascade,
  name                 text not null,
  mode                 public.app_mode not null,
  -- SPEC §6 : curseur 20 € → 350 €, champ personnalisé au-delà (pas de maximum)
  weekly_budget_cents  integer not null check (weekly_budget_cents >= 2000),
  management_mode      public.management_mode not null default 'courses',
  shopping_channel     public.shopping_channel,
  preferred_store_id   uuid references public.stores (id) on delete set null,
  cuisine_preferences  text[] not null default '{}',
  main_cook_member_id  uuid,
  is_demo              boolean not null default false,
  created_at           timestamptz not null default now(),
  updated_at           timestamptz not null default now()
);
create index households_owner_idx on public.households (owner_id);

alter table public.profiles
  add constraint profiles_active_household_fk
  foreign key (active_household_id) references public.households (id) on delete set null;

create table public.household_members (
  id            uuid primary key default gen_random_uuid(),
  household_id  uuid not null references public.households (id) on delete cascade,
  first_name    text not null,
  role          public.member_role not null default 'adulte',
  sex           public.sex,
  age_years     smallint check (age_years between 0 and 120),
  height_cm     smallint check (height_cm between 40 and 250),
  weight_kg     numeric(5, 1) check (weight_kg between 2 and 400),
  goal          public.health_goal,
  activity      public.activity_level,
  avatar_path   text,
  is_owner      boolean not null default false,
  position      smallint not null default 0,
  created_at    timestamptz not null default now()
);
create index household_members_household_idx on public.household_members (household_id);
-- Un seul membre « titulaire du compte » par foyer
create unique index household_members_one_owner on public.household_members (household_id) where is_owner;

alter table public.households
  add constraint households_main_cook_fk
  foreign key (main_cook_member_id) references public.household_members (id) on delete set null;

-- « Ma cuisine » (SPEC §6) : niveau, temps par repas, équipements
create table public.kitchen_settings (
  household_id    uuid primary key references public.households (id) on delete cascade,
  cooking_level   public.cooking_level not null default 'intermediaire',
  -- 15, 30, 45 ou 60 minutes ; 60 signifie « 60 min et plus » (pas de limite)
  weekday_minutes smallint not null default 30 check (weekday_minutes in (15, 30, 45, 60)),
  weekend_minutes smallint not null default 45 check (weekend_minutes in (15, 30, 45, 60)),
  updated_at      timestamptz not null default now()
);

create table public.household_equipment (
  household_id   uuid not null references public.households (id) on delete cascade,
  equipment_code text not null references public.equipment (code),
  primary key (household_id, equipment_code)
);

-- Contraintes alimentaires par membre (Solo : un seul membre)
create table public.member_diets (
  member_id uuid not null references public.household_members (id) on delete cascade,
  diet_code text not null references public.diets (code),
  primary key (member_id, diet_code)
);

create table public.member_allergens (
  member_id     uuid not null references public.household_members (id) on delete cascade,
  allergen_code text not null references public.allergens (code),
  primary key (member_id, allergen_code)
);

create table public.member_excluded_ingredients (
  member_id     uuid not null references public.household_members (id) on delete cascade,
  ingredient_id uuid not null references public.ingredients (id) on delete cascade,
  primary key (member_id, ingredient_id)
);

-- Grille des repas à planifier (présence d'une ligne = repas à planifier)
create table public.meal_plan_slots (
  household_id uuid not null references public.households (id) on delete cascade,
  day_of_week  smallint not null check (day_of_week between 1 and 7), -- 1 = lundi
  meal_type    public.meal_type not null,
  primary key (household_id, day_of_week, meal_type)
);

-- ---------------------------------------------------------------------
-- Menus de la semaine
-- ---------------------------------------------------------------------
create table public.weekly_menus (
  id                    uuid primary key default gen_random_uuid(),
  household_id          uuid not null references public.households (id) on delete cascade,
  week_start            date not null check (extract(isodow from week_start) = 1),
  status                public.menu_status not null default 'en_generation',
  budget_cents          integer not null check (budget_cents > 0),
  estimated_cost_cents  integer check (estimated_cost_cents >= 0),
  generation_attempts   smallint not null default 0,
  failure_reason        text,
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now(),
  unique (household_id, week_start),
  -- Règle d'or (PRD §1, SPEC §0.5) : un menu prêt ne dépasse jamais le budget
  constraint weekly_menus_within_budget
    check (status <> 'pret' or (estimated_cost_cents is not null and estimated_cost_cents <= budget_cents))
);

create table public.menu_meals (
  id              uuid primary key default gen_random_uuid(),
  menu_id         uuid not null references public.weekly_menus (id) on delete cascade,
  day_of_week     smallint not null check (day_of_week between 1 and 7),
  meal_type       public.meal_type not null,
  recipe_id       uuid not null references public.recipes (id),
  servings        smallint not null check (servings > 0),
  -- Freemium (SPEC §6) : un seul repas « Offert » en clair par menu
  is_free_preview boolean not null default false,
  cooked_at       timestamptz,
  unique (menu_id, day_of_week, meal_type)
);
create index menu_meals_menu_idx on public.menu_meals (menu_id);
create unique index menu_meals_one_free_preview on public.menu_meals (menu_id) where is_free_preview;

-- ---------------------------------------------------------------------
-- Réserve
-- ---------------------------------------------------------------------
create table public.pantry_items (
  id            uuid primary key default gen_random_uuid(),
  household_id  uuid not null references public.households (id) on delete cascade,
  ingredient_id uuid references public.ingredients (id) on delete set null,
  name          text not null,
  quantity      numeric(10, 2) not null check (quantity >= 0),
  unit          public.unit not null,
  location      public.pantry_location not null,
  expires_on    date,
  opened        boolean not null default false,
  barcode       text,
  source        public.pantry_source not null default 'manuel',
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);
create index pantry_items_household_idx on public.pantry_items (household_id, location);
create index pantry_items_expiry_idx on public.pantry_items (household_id, expires_on);

-- Historique anti-gaspillage (Suivi > Performance en Foyer)
create table public.pantry_events (
  id            uuid primary key default gen_random_uuid(),
  household_id  uuid not null references public.households (id) on delete cascade,
  ingredient_id uuid references public.ingredients (id) on delete set null,
  event         public.pantry_event_type not null,
  value_cents   integer not null default 0 check (value_cents >= 0),
  created_at    timestamptz not null default now()
);
create index pantry_events_household_idx on public.pantry_events (household_id, created_at);

-- ---------------------------------------------------------------------
-- Courses
-- ---------------------------------------------------------------------
create table public.shopping_lists (
  id                    uuid primary key default gen_random_uuid(),
  menu_id               uuid not null unique references public.weekly_menus (id) on delete cascade,
  household_id          uuid not null references public.households (id) on delete cascade,
  estimated_total_cents integer not null default 0 check (estimated_total_cents >= 0),
  created_at            timestamptz not null default now()
);

create table public.shopping_list_items (
  id                    uuid primary key default gen_random_uuid(),
  list_id               uuid not null references public.shopping_lists (id) on delete cascade,
  ingredient_id         uuid not null references public.ingredients (id),
  quantity_needed       numeric(10, 2) not null check (quantity_needed >= 0),
  -- Réserve déduite (SPEC §7 onglet 3)
  quantity_from_pantry  numeric(10, 2) not null default 0 check (quantity_from_pantry >= 0),
  quantity_to_buy       numeric(10, 2) generated always as (greatest(quantity_needed - quantity_from_pantry, 0)) stored,
  estimated_price_cents integer not null default 0 check (estimated_price_cents >= 0),
  checked               boolean not null default false,
  unique (list_id, ingredient_id)
);

create table public.orders (
  id           uuid primary key default gen_random_uuid(),
  household_id uuid not null references public.households (id) on delete cascade,
  list_id      uuid not null references public.shopping_lists (id) on delete cascade,
  store_id     uuid not null references public.stores (id),
  channel      public.shopping_channel not null,
  -- Montant validé au comparateur = montant payé (SPEC §6) : une seule valeur stockée
  total_cents  integer not null check (total_cents >= 0),
  status       public.order_status not null default 'brouillon',
  slot_start   timestamptz,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

-- ---------------------------------------------------------------------
-- Suivi
-- ---------------------------------------------------------------------
create table public.weight_entries (
  id          uuid primary key default gen_random_uuid(),
  member_id   uuid not null references public.household_members (id) on delete cascade,
  measured_at timestamptz not null default now(),
  weight_kg   numeric(5, 1) not null check (weight_kg between 2 and 400),
  source      public.weight_source not null default 'manuel'
);
create index weight_entries_member_idx on public.weight_entries (member_id, measured_at);

-- ---------------------------------------------------------------------
-- updated_at automatique
-- ---------------------------------------------------------------------
create trigger profiles_updated_at         before update on public.profiles         for each row execute function public.set_updated_at();
create trigger households_updated_at       before update on public.households       for each row execute function public.set_updated_at();
create trigger kitchen_settings_updated_at before update on public.kitchen_settings for each row execute function public.set_updated_at();
create trigger weekly_menus_updated_at     before update on public.weekly_menus     for each row execute function public.set_updated_at();
create trigger pantry_items_updated_at     before update on public.pantry_items     for each row execute function public.set_updated_at();
create trigger orders_updated_at           before update on public.orders           for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------
-- Création automatique du profil à l'inscription
-- ---------------------------------------------------------------------
create function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  insert into public.profiles (id, display_name)
  values (new.id, nullif(new.raw_user_meta_data ->> 'first_name', ''));
  return new;
end $$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();
