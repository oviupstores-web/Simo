-- =====================================================================
-- Menoo — poids cible et rythme hebdomadaire (retours jalon 4)
-- + 3 équipements de l'écran « Ma cuisine » (autocuiseur, mijoteuse, plancha)
-- + données de démo mises à jour (Karim vise 72 kg à 0,5 kg/semaine).
-- =====================================================================

-- Poids visé et rythme (kg par semaine) ; aucun pour « maintien & équilibre ».
alter table public.household_members
  add column target_weight_kg numeric(5, 1) check (target_weight_kg between 30 and 300),
  add column weekly_rate_kg  numeric(3, 2) check (weekly_rate_kg in (0.25, 0.5, 0.75));

comment on column public.household_members.target_weight_kg is 'Poids visé (perte, prise de masse, sèche).';
comment on column public.household_members.weekly_rate_kg is 'Rythme visé en kg par semaine (perte : 0,25/0,5/0,75 ; prise : 0,25/0,5).';

-- Garde-fous : pas de rythme sans poids cible ; poids cible avec un IMC d'au moins 18,5 ;
-- rythme de prise de masse limité à 0,5 kg/semaine ; pas de poids cible en maintien.
alter table public.household_members
  add constraint household_members_rate_needs_target
    check (weekly_rate_kg is null or target_weight_kg is not null),
  add constraint household_members_target_bmi
    check (target_weight_kg is null or height_cm is null
           or target_weight_kg >= round(18.5 * (height_cm / 100.0) ^ 2, 1)),
  add constraint household_members_gain_rate
    check (goal is distinct from 'prise_masse' or weekly_rate_kg is null or weekly_rate_kg <= 0.5),
  add constraint household_members_no_target_maintain
    check (goal is distinct from 'maintien' or target_weight_kg is null);

insert into public.equipment (code, label, position) values
  ('autocuiseur', 'Autocuiseur',   10),
  ('mijoteuse',   'Mijoteuse',     11),
  ('plancha',     'Plancha / BBQ', 12)
on conflict (code) do nothing;

create or replace function public.load_demo_data(p_owner uuid) returns void
language plpgsql security definer set search_path = '' as $$
declare
  v_karim    uuid;  v_karim_m   uuid;
  v_martin   uuid;  v_thomas    uuid;  v_sarah uuid;  v_lucas uuid;  v_emma uuid;
  v_budget   uuid;  v_allergie  uuid;  v_reserve uuid;  v_grand uuid;
  v_m        uuid;
  v_all_equipment text[] := array(select code from public.equipment);
begin
  if not exists (select 1 from public.profiles where id = p_owner) then
    raise exception 'Aucun profil pour %, créez d''abord le compte de test', p_owner;
  end if;

  -- Remise à zéro des foyers de démo de ce compte
  delete from public.households where owner_id = p_owner and is_demo;

  -- ===================================================================
  -- 1. Karim — Solo (SPEC §9) : 32 ans, 180 cm, 75 kg, perte de poids, 65 €
  -- ===================================================================
  insert into public.households (owner_id, name, mode, weekly_budget_cents, management_mode, shopping_channel, is_demo)
  values (p_owner, 'Karim', 'solo', 6500, 'mixte', 'drive', true)
  returning id into v_karim;

  insert into public.household_members (household_id, first_name, role, sex, age_years, height_cm, weight_kg, goal, activity, avatar_path, is_owner, target_weight_kg, weekly_rate_kg)
  values (v_karim, 'Karim', 'adulte', 'homme', 32, 180, 75, 'perte_poids', 'modere', 'avatar.jpg', true, 72, 0.5)
  returning id into v_karim_m;
  update public.households set main_cook_member_id = v_karim_m where id = v_karim;

  insert into public.kitchen_settings (household_id, cooking_level, weekday_minutes, weekend_minutes)
  values (v_karim, 'intermediaire', 30, 45);
  insert into public.household_equipment (household_id, equipment_code)
  select v_karim, unnest(array['plaques', 'four', 'micro_ondes', 'mixeur', 'grille_pain']);

  insert into public.meal_plan_slots (household_id, day_of_week, meal_type)
  select v_karim, d, m from generate_series(1, 7) d
  cross join unnest(array['petit_dejeuner', 'dejeuner', 'diner']::public.meal_type[]) m;

  -- Réserve du maître « opérationnel » (regroupée par emplacement)
  insert into public.pantry_items (household_id, ingredient_id, name, quantity, unit, location, expires_on, opened)
  select v_karim, i.id, v.name, v.qty, i.unit, v.loc::public.pantry_location, current_date + v.days, v.opened
  from (values
    ('poulet',          'Poulet',           300,  'fridge',       2,   false),
    ('yaourt_nature',   'Yaourt nature',    2,    'fridge',       8,   false),
    ('lait',            'Lait demi-écrémé', 1000, 'fridge',       3,   true),
    ('carottes',        'Carottes',         500,  'fridge',       5,   false),
    ('citron',          'Citrons',          2,    'fruit_basket', 9,   false),
    ('tomates_cerises', 'Tomates cerises',  250,  'fruit_basket', 4,   false),
    ('quinoa',          'Quinoa',           500,  'pantry',       500, true),
    ('huile_olive',     'Huile d''olive',   750,  'pantry',       500, false),
    ('brocoli_surgele', 'Brocoli surgelé',  1000, 'freezer',      90,  false)
  ) as v (slug, name, qty, loc, days, opened)
  join public.ingredients i on i.slug = v.slug;

  -- Courbe de poids (Suivi > Performance) : 75,0 → 74,3 kg sur 4 semaines
  insert into public.weight_entries (member_id, measured_at, weight_kg, source)
  values (v_karim_m, now() - interval '28 days', 75.0, 'health_connect'),
         (v_karim_m, now() - interval '21 days', 74.9, 'health_connect'),
         (v_karim_m, now() - interval '14 days', 74.6, 'manuel'),
         (v_karim_m, now() - interval '7 days',  75.0, 'health_connect'),
         (v_karim_m, now(),                      74.3, 'health_connect');

  -- ===================================================================
  -- 2. Famille Martin — Foyer (SPEC §9) : Thomas, Sarah, Lucas, Emma, 110 €
  -- ===================================================================
  insert into public.households (owner_id, name, mode, weekly_budget_cents, management_mode, shopping_channel, cuisine_preferences, is_demo)
  values (p_owner, 'Famille Martin', 'foyer', 11000, 'courses', 'drive', array['francaise', 'mediterraneenne', 'asiatique'], true)
  returning id into v_martin;

  insert into public.household_members (household_id, first_name, role, sex, age_years, height_cm, weight_kg, goal, activity, is_owner, position)
  values (v_martin, 'Thomas', 'adulte', 'homme', 38, 182, 84, 'maintien', 'actif', true, 0) returning id into v_thomas;
  insert into public.household_members (household_id, first_name, role, sex, age_years, height_cm, weight_kg, goal, activity, position)
  values (v_martin, 'Sarah', 'adulte', 'femme', 35, 168, 62, 'maintien', 'modere', 1) returning id into v_sarah;
  insert into public.household_members (household_id, first_name, role, sex, age_years, height_cm, weight_kg, activity, position)
  values (v_martin, 'Lucas', 'enfant', 'homme', 9, 134, 29, 'actif', 2) returning id into v_lucas;
  insert into public.household_members (household_id, first_name, role, sex, age_years, height_cm, weight_kg, activity, position)
  values (v_martin, 'Emma', 'enfant', 'femme', 6, 116, 21, 'actif', 3) returning id into v_emma;
  update public.households set main_cook_member_id = v_sarah where id = v_martin;

  insert into public.kitchen_settings (household_id, cooking_level, weekday_minutes, weekend_minutes)
  values (v_martin, 'intermediaire', 45, 60);
  insert into public.household_equipment (household_id, equipment_code)
  select v_martin, unnest(array['plaques', 'four', 'micro_ondes', 'mixeur', 'robot', 'grille_pain']);

  -- Emma : allergie aux fruits à coque
  insert into public.member_allergens (member_id, allergen_code) values (v_emma, 'fruits_a_coque');

  -- Petits-déjeuners et dîners toute la semaine, déjeuners le week-end
  insert into public.meal_plan_slots (household_id, day_of_week, meal_type)
  select v_martin, d, 'petit_dejeuner'::public.meal_type from generate_series(1, 7) d
  union all select v_martin, d, 'diner'::public.meal_type from generate_series(1, 7) d
  union all select v_martin, d, 'dejeuner'::public.meal_type from generate_series(6, 7) d;

  -- ===================================================================
  -- 3. Piège « budget impossible » : 20 € pour 4 personnes et 21 repas
  --    (la semaine la moins chère possible coûte ≈ 63 €). Attendu au jalon 6 :
  --    échec propre (« budget insuffisant »), jamais un menu qui dépasse le budget.
  -- ===================================================================
  insert into public.households (owner_id, name, mode, weekly_budget_cents, management_mode, is_demo)
  values (p_owner, 'Piège — budget impossible', 'foyer', 2000, 'courses', true)
  returning id into v_budget;
  insert into public.household_members (household_id, first_name, role, sex, age_years, height_cm, weight_kg, goal, activity, is_owner, position, target_weight_kg, weekly_rate_kg) values
    (v_budget, 'Nadia',  'adulte', 'femme', 34, 170, 58, 'prise_masse', 'tres_actif', true,  0, 62, 0.25),
    (v_budget, 'Samir',  'adulte', 'homme', 36, 181, 78, 'prise_masse', 'tres_actif', false, 1, 82, 0.25),
    (v_budget, 'Yanis',  'enfant', 'homme', 12, 150, 40, null,          'actif',      false, 2, null, null),
    (v_budget, 'Lila',   'enfant', 'femme', 8,  128, 26, null,          'actif',      false, 3, null, null);
  insert into public.kitchen_settings (household_id, cooking_level, weekday_minutes, weekend_minutes)
  values (v_budget, 'debutant', 15, 30);
  insert into public.household_equipment (household_id, equipment_code) values (v_budget, 'plaques');
  insert into public.meal_plan_slots (household_id, day_of_week, meal_type)
  select v_budget, d, m from generate_series(1, 7) d
  cross join unnest(array['petit_dejeuner', 'dejeuner', 'diner']::public.meal_type[]) m;

  -- ===================================================================
  -- 4. Piège « allergies cumulées » : presque toutes les recettes exclues
  --    Attendu : génération avec le peu de recettes restantes, ou message
  --    clair si aucune ne convient.
  -- ===================================================================
  insert into public.households (owner_id, name, mode, weekly_budget_cents, management_mode, is_demo)
  values (p_owner, 'Piège — allergies cumulées', 'foyer', 12000, 'courses', true)
  returning id into v_allergie;
  insert into public.kitchen_settings (household_id, cooking_level, weekday_minutes, weekend_minutes)
  values (v_allergie, 'confirme', 60, 60);
  insert into public.household_equipment (household_id, equipment_code)
  select v_allergie, unnest(v_all_equipment);
  insert into public.meal_plan_slots (household_id, day_of_week, meal_type)
  select v_allergie, d, 'diner' from generate_series(1, 7) d;

  insert into public.household_members (household_id, first_name, role, sex, age_years, is_owner, position)
  values (v_allergie, 'Julie', 'adulte', 'femme', 41, true, 0) returning id into v_m;
  insert into public.member_allergens (member_id, allergen_code)
  select v_m, unnest(array['gluten', 'lait', 'oeufs']);
  insert into public.household_members (household_id, first_name, role, sex, age_years, position)
  values (v_allergie, 'Marc', 'adulte', 'homme', 43, 1) returning id into v_m;
  insert into public.member_allergens (member_id, allergen_code)
  select v_m, unnest(array['poisson', 'crustaces', 'mollusques', 'soja']);
  insert into public.household_members (household_id, first_name, role, sex, age_years, position)
  values (v_allergie, 'Léo', 'enfant', 'homme', 10, 2) returning id into v_m;
  insert into public.member_allergens (member_id, allergen_code)
  select v_m, unnest(array['arachides', 'fruits_a_coque', 'sesame', 'moutarde', 'celeri']);
  insert into public.member_diets (member_id, diet_code) values (v_m, 'vegetarien');
  insert into public.household_members (household_id, first_name, role, sex, age_years, position)
  values (v_allergie, 'Inès', 'enfant', 'femme', 7, 3) returning id into v_m;
  insert into public.member_excluded_ingredients (member_id, ingredient_id)
  select v_m, id from public.ingredients where slug in ('courgette', 'poivron');

  -- ===================================================================
  -- 5. Piège « réserve couvrant tout » : tous les ingrédients en réserve
  --    Attendu : liste de courses à 0 € (tout est « En réserve ✓ »).
  -- ===================================================================
  insert into public.households (owner_id, name, mode, weekly_budget_cents, management_mode, is_demo)
  values (p_owner, 'Piège — réserve couvrant tout', 'solo', 5000, 'reserves', true)
  returning id into v_reserve;
  insert into public.household_members (household_id, first_name, role, sex, age_years, height_cm, weight_kg, goal, activity, is_owner)
  values (v_reserve, 'Hugo', 'adulte', 'homme', 45, 176, 80, 'maintien', 'leger', true);
  insert into public.kitchen_settings (household_id, cooking_level, weekday_minutes, weekend_minutes)
  values (v_reserve, 'confirme', 60, 60);
  insert into public.household_equipment (household_id, equipment_code)
  select v_reserve, unnest(v_all_equipment);
  insert into public.meal_plan_slots (household_id, day_of_week, meal_type)
  select v_reserve, d, m from generate_series(1, 7) d
  cross join unnest(array['dejeuner', 'diner']::public.meal_type[]) m;
  insert into public.pantry_items (household_id, ingredient_id, name, quantity, unit, location, expires_on)
  select v_reserve, i.id, i.name,
         case i.unit when 'piece' then 60 else 10000 end,
         i.unit,
         -- les produits frais passent au congélateur pour tenir la semaine
         case when i.default_location = 'fridge' and i.shelf_life_days < 10 then 'freezer' else i.default_location end,
         current_date + 30
  from public.ingredients i;

  -- ===================================================================
  -- 6. Piège « foyer de 7 personnes » : 3 adultes, 3 enfants, 1 bébé
  --    Budget de départ SPEC §6 : 30 € × 3 adultes + 20 € × 4 enfants = 170 €
  -- ===================================================================
  insert into public.households (owner_id, name, mode, weekly_budget_cents, management_mode, shopping_channel, is_demo)
  values (p_owner, 'Piège — foyer de 7 personnes', 'foyer', 17000, 'mixte', 'livraison', true)
  returning id into v_grand;
  insert into public.kitchen_settings (household_id, cooking_level, weekday_minutes, weekend_minutes)
  values (v_grand, 'intermediaire', 30, 60);
  insert into public.household_equipment (household_id, equipment_code)
  select v_grand, unnest(array['plaques', 'four', 'micro_ondes', 'robot']);
  insert into public.meal_plan_slots (household_id, day_of_week, meal_type)
  select v_grand, d, m from generate_series(1, 7) d
  cross join unnest(array['dejeuner', 'diner']::public.meal_type[]) m;
  insert into public.household_members (household_id, first_name, role, sex, age_years, is_owner, position) values
    (v_grand, 'Karine',  'adulte', 'femme', 44, true,  0),
    (v_grand, 'Olivier', 'adulte', 'homme', 46, false, 1),
    (v_grand, 'Mamie Jo','adulte', 'femme', 72, false, 2),
    (v_grand, 'Chloé',   'enfant', 'femme', 14, false, 3),
    (v_grand, 'Noah',    'enfant', 'homme', 11, false, 4),
    (v_grand, 'Lina',    'enfant', 'femme', 5,  false, 5),
    (v_grand, 'Sacha',   'bebe',   'homme', 1,  false, 6);

  -- Le compte de test ouvre l'app sur Karim (Solo)
  update public.profiles
  set active_household_id = v_karim, mode = 'solo', display_name = coalesce(display_name, 'Karim')
  where id = p_owner;
end $$;

comment on function public.load_demo_data(uuid) is
  'Crée les foyers de démo (Karim, famille Martin) et les 4 cas pièges pour un compte de test.';

-- Réservée à l'administrateur : l'app ne peut pas l'appeler
revoke all on function public.load_demo_data(uuid) from public, anon, authenticated;

-- Foyers de démo déjà chargés : mêmes objectifs que la fonction ci-dessus.
update public.household_members m
set target_weight_kg = v.target, weekly_rate_kg = v.rate
from (values ('Karim', 72.0, 0.5), ('Nadia', 62.0, 0.25), ('Samir', 82.0, 0.25)) as v (first_name, target, rate),
     public.households h
where h.id = m.household_id and h.is_demo and m.first_name = v.first_name;
