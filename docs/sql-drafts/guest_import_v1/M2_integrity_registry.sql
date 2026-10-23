-- MENOO / menoo.guest-import v1 / 2026-10-22
-- BROUILLON NON EXÉCUTABLE EN L'ÉTAT. Dépend de M1. Aucune exécution autorisée.
begin;
do $draft$ begin
  raise exception 'MENOO_DRAFT_NOT_AUTHORIZED: M2';
end $draft$;

-- Clés candidates NON DEFERRABLE : nécessaires pour servir de cibles de FK.
alter table public.households
  add constraint households_id_owner_key unique (id, owner_id);
alter table public.household_members
  add constraint household_members_id_household_key unique (id, household_id);
alter table public.weekly_menus
  add constraint weekly_menus_id_household_key unique (id, household_id);
alter table public.shopping_lists
  add constraint shopping_lists_id_household_key unique (id, household_id);

-- Les FK simples historiques, dont ON DELETE SET NULL, sont conservées.
-- NOT VALID préserve les anciennes lignes incohérentes sans les réparer.
-- Il contrôle néanmoins les nouvelles écritures : analyser les conflits avant adoption.
alter table public.profiles add constraint profiles_active_household_owner_fk
  foreign key (active_household_id, id) references public.households (id, owner_id)
  deferrable initially deferred not valid;
alter table public.households add constraint households_main_cook_same_household_fk
  foreign key (main_cook_member_id, id) references public.household_members (id, household_id)
  deferrable initially deferred not valid;
alter table public.shopping_lists add constraint shopping_lists_menu_household_fk
  foreign key (menu_id, household_id) references public.weekly_menus (id, household_id)
  deferrable initially deferred not valid;
alter table public.orders add constraint orders_list_household_fk
  foreign key (list_id, household_id) references public.shopping_lists (id, household_id)
  deferrable initially deferred not valid;

create unique index household_members_import_source_key
  on public.household_members (household_id, source_local_id)
  where source_local_id is not null;
create unique index pantry_items_import_source_key
  on public.pantry_items (household_id, source_local_id)
  where source_local_id is not null;

-- Une seule nouvelle table ; aucun instantané personnel complet dupliqué.
create table menoo_private.guest_imports (
  owner_id uuid not null references public.profiles(id) on delete cascade,
  operation_id uuid not null,
  source_origin_id uuid not null,
  journey public.app_mode not null,
  contract_version smallint not null check (contract_version = 1),
  canonical_version smallint not null check (canonical_version = 1),
  source_versions jsonb not null check (pg_catalog.jsonb_typeof(source_versions) = 'object'),
  payload_hash bytea not null check (pg_catalog.octet_length(payload_hash) = 32),
  household_id uuid not null unique,
  receipt jsonb not null check (pg_catalog.jsonb_typeof(receipt) = 'object'),
  committed_at timestamptz not null default pg_catalog.transaction_timestamp(),
  primary key (owner_id, operation_id),
  unique (source_origin_id, journey),
  constraint guest_imports_household_owner_fk
    foreign key (household_id, owner_id) references public.households(id, owner_id)
    on delete no action deferrable initially deferred
);
alter table menoo_private.guest_imports enable row level security;
alter table menoo_private.guest_imports force row level security;
revoke all on menoo_private.guest_imports from public, anon, authenticated;

-- Aucun registre « pending » : les données et leur reçu sont validés ensemble.
-- Une origine déjà attribuée à un autre compte produit un refus générique.
-- Une suppression isolée d'un foyer importé est bloquée ; suppression du compte
-- entier : cascades à vérifier en base isolée, pas de nettoyage automatique ici.

-- Verrou commun à TOUS les chemins ordinaires de création de foyer.
-- SECURITY INVOKER : le rôle appelant doit pouvoir verrouiller son profil.
-- Supabase service_role/admin restent des rôles de confiance à auditer.
create function menoo_private.lock_household_owner() returns trigger
language plpgsql set search_path = '' as $fn$
declare v_owner uuid;
begin
  if tg_op = 'UPDATE' and new.owner_id is distinct from old.owner_id then
    raise exception using errcode = '23514', message = 'household_owner_change_forbidden';
  end if;
  if tg_op = 'DELETE' then v_owner := old.owner_id; else v_owner := new.owner_id; end if;
  perform 1 from public.profiles where id = v_owner for update;
  -- Lors d'une cascade de suppression du compte, le profil peut déjà être absent.
  if not found and tg_op <> 'DELETE' then
    raise exception using errcode = '23503', message = 'import_profile_missing';
  end if;
  if tg_op = 'DELETE' then return old; else return new; end if;
end $fn$;
create trigger menoo_household_owner_lock
before insert or update or delete on public.households
for each row execute function menoo_private.lock_household_owner();

-- La FK composite protège l'appartenance. Le rôle « adulte » est un contrôle
-- distinct, vérifié dans les deux directions au terme de la transaction.
-- OLD/NEW identifient les foyers touchés par l'événement ; seul l'état courant
-- de ces foyers décide du résultat différé (y compris H1 -> H2 -> H1).
create function menoo_private.check_main_cook() returns trigger
language plpgsql set search_path = '' as $fn$
declare v_houses uuid[];
begin
  if tg_table_name = 'households' then
    v_houses := array[new.id];
  elsif tg_op = 'DELETE' then
    v_houses := array[old.household_id];
  else
    v_houses := array[old.household_id, new.household_id];
  end if;
  if exists (
    select 1 from public.households h
    where h.id = any(v_houses) and h.main_cook_member_id is not null
      and not exists (
        select 1 from public.household_members m
        where m.id = h.main_cook_member_id
          and m.household_id = h.id and m.role = 'adulte'
      )
  ) then
    raise exception using errcode = '23514', message = 'import_main_cook_invalid';
  end if;
  -- Un foyer supprimé n'a plus d'invariant à contrôler. Le SET NULL historique
  -- et les cascades restent inchangés ; aucun membre ni foyer n'est réparé ici.
  return null;
end $fn$;
create constraint trigger menoo_household_cook_integrity
after insert or update on public.households deferrable initially deferred
for each row execute function menoo_private.check_main_cook();
create constraint trigger menoo_member_cook_integrity
after update or delete on public.household_members deferrable initially deferred
for each row execute function menoo_private.check_main_cook();

-- Aucune UNIQUE(owner_id) : les foyers historiques multiples restent intacts.
-- La restriction « compte vierge » de M4 + verrou profil empêche un second import.
revoke all on all functions in schema menoo_private from public, anon, authenticated;
commit;
