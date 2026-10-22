-- MENOO / menoo.guest-import v1 / 2026-10-22
-- BROUILLON NON EXÉCUTABLE EN L'ÉTAT. Dépend de M1/M2/M3.
-- Candidat complet à relire et tester, PAS une migration validée.
-- Le protocole de transport proposé est détaillé dans TECHNICAL_DECISIONS.md.
begin;
do $draft$ begin
  raise exception 'MENOO_DRAFT_NOT_AUTHORIZED: M4';
end $draft$;

create function menoo_private.require(p_ok boolean, p_error text) returns void
language plpgsql immutable set search_path = '' as $fn$
begin
  if p_ok is distinct from true then
    raise exception using errcode = '22023', message = p_error;
  end if;
end $fn$;

create function menoo_private.exact_keys(p_object jsonb, p_keys text[]) returns void
language plpgsql immutable set search_path = '' as $fn$
begin
  perform menoo_private.require(pg_catalog.jsonb_typeof(p_object) = 'object', 'import_object_required');
  perform menoo_private.require(p_object ?& p_keys and
    (select pg_catalog.count(*) from pg_catalog.jsonb_object_keys(p_object)) = pg_catalog.cardinality(p_keys),
    'import_keys_invalid');
end $fn$;

-- Tester la vacuité comme Dart trim(), mais conserver la chaîne originale.
create function menoo_private.nonblank(p_value jsonb) returns boolean
language sql immutable set search_path = '' as $fn$
  select pg_catalog.jsonb_typeof(p_value) = 'string' and pg_catalog.btrim(p_value #>> '{}',
    E' \t\n\r\f' || pg_catalog.chr(11) || pg_catalog.chr(133) || pg_catalog.chr(160) || pg_catalog.chr(5760) ||
    pg_catalog.chr(8192) || pg_catalog.chr(8193) || pg_catalog.chr(8194) || pg_catalog.chr(8195) ||
    pg_catalog.chr(8196) || pg_catalog.chr(8197) || pg_catalog.chr(8198) || pg_catalog.chr(8199) ||
    pg_catalog.chr(8200) || pg_catalog.chr(8201) || pg_catalog.chr(8202) || pg_catalog.chr(8232) ||
    pg_catalog.chr(8233) || pg_catalog.chr(8239) || pg_catalog.chr(8287) || pg_catalog.chr(12288) ||
    pg_catalog.chr(65279)) <> '';
$fn$;

-- Les nombres métier arrivent sous forme de CHAÎNES décimales, pas de double JSON.
-- Leurs chemins sont typés dans project_payload ; une chaîne libre "123" reste du texte.
create function menoo_private.decimal_value(p_value jsonb, p_integer boolean default false)
returns numeric language plpgsql immutable set search_path = '' as $fn$
declare v_text text; v_number numeric;
begin
  perform menoo_private.require(pg_catalog.jsonb_typeof(p_value) = 'string', 'import_decimal_string_required');
  v_text := p_value #>> '{}';
  perform menoo_private.require(pg_catalog.octet_length(v_text) <= 1024 and
    v_text ~ '^-?(0|[1-9][0-9]*)([.][0-9]+)?$', 'import_decimal_invalid');
  v_number := v_text::numeric;
  perform menoo_private.require(not p_integer or v_number = pg_catalog.trunc(v_number), 'import_integer_required');
  return pg_catalog.trim_scale(v_number);
end $fn$;

create function menoo_private.string_list(p_values jsonb, p_allowed text[], p_set boolean)
returns jsonb language plpgsql immutable set search_path = '' as $fn$
declare v jsonb; v_result jsonb;
begin
  perform menoo_private.require(pg_catalog.jsonb_typeof(p_values) = 'array', 'import_array_required');
  for v in select value from pg_catalog.jsonb_array_elements(p_values) loop
    perform menoo_private.require(pg_catalog.jsonb_typeof(v) = 'string', 'import_string_required');
    perform menoo_private.require(p_allowed is null or (v #>> '{}') = any(p_allowed), 'import_code_unknown');
  end loop;
  if not p_set then return p_values; end if;
  perform menoo_private.require(
    pg_catalog.jsonb_array_length(p_values) =
      (select pg_catalog.count(distinct (value #>> '{}') collate "C") from pg_catalog.jsonb_array_elements(p_values)),
    'import_duplicate_code');
  select coalesce(pg_catalog.jsonb_agg(value order by pg_catalog.convert_to(value #>> '{}','UTF8')), '[]'::jsonb)
    into v_result from pg_catalog.jsonb_array_elements(p_values);
  return v_result;
end $fn$;

create function menoo_private.journey_mode(p_journey text) returns public.app_mode
language plpgsql immutable set search_path = '' as $fn$
begin
  case p_journey when 'solo' then return 'solo'::public.app_mode;
    when 'family' then return 'foyer'::public.app_mode;
    else raise exception using errcode='22023', message='import_journey_invalid'; end case;
end $fn$;

create function menoo_private.pantry_unit(p_unit text) returns text
language plpgsql immutable set search_path = '' as $fn$
begin
  if p_unit is null then return null; end if;
  case p_unit when 'piece' then return 'piece'; when 'gram' then return 'g';
    when 'kilogram' then return 'kg'; when 'milliliter' then return 'ml';
    when 'liter' then return 'l'; when 'pack' then return 'pack';
    else raise exception using errcode='22023', message='import_unit_invalid'; end case;
end $fn$;

-- Projection figée V1 : validation structurelle, codes constants, nombres typés,
-- tri des ensembles, ordre des membres/exclusions conservé, lots triés par id.
-- Les catalogues SQL mutables ne sont vérifiés QU'APRÈS la recherche d'un reçu.
create function menoo_private.project_payload(p jsonb) returns jsonb
language plpgsql immutable set search_path = '' as $fn$
declare
  v jsonb := p; a jsonb; m jsonb; item jsonb; slot jsonb; n numeric;
  v_members jsonb := '[]'; v_slots jsonb := '[]'; v_pantry jsonb := '[]';
  v_ids text[] := '{}'; v_lots text[] := '{}'; v_slot_ids text[] := '{}';
  v_key text; v_id text; v_role text; v_cook text; v_day numeric; v_date date;
  v_adults integer := 0; v_children integer := 0; v_babies integer := 0;
  v_goal text; v_height numeric; v_weight numeric; v_target numeric; v_rate numeric;
  v_allergens constant text[] := array['gluten','crustaces','oeufs','poisson','arachides','soja','lait',
    'fruits_a_coque','celeri','moutarde','sesame','sulfites','lupin','mollusques'];
  v_diets constant text[] := array['vegetarien','vegan','pescetarien','sans_porc','sans_gluten','sans_lactose'];
  v_common constant text[] := array['slots','budgetAmount','budgetCurrency','management','diets','allergens',
    'excludedFoods','cuisinePreferences','cookingLevel','weekdayMinutes','weekendMinutes','equipment'];
begin
  perform menoo_private.exact_keys(v,array['contract','version','canonicalVersion','originId','journey',
    'sourceVersions','sourceCurrency','sourceManagement','identity','answers','pantry']);
  perform menoo_private.require(v->'contract' = '"menoo.guest-import"'::jsonb and v->'version' = '1'::jsonb
    and v->'canonicalVersion' = '"canonical-1"'::jsonb, 'import_version_unsupported');
  perform menoo_private.require(pg_catalog.jsonb_typeof(v->'originId') = 'string' and
    (v->>'originId') ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$', 'import_origin_invalid');
  perform menoo_private.journey_mode(v->>'journey');
  perform menoo_private.exact_keys(v->'sourceVersions',array['localDraft','answers','pantry']);
  perform menoo_private.require(v#>'{sourceVersions,localDraft}'='1'::jsonb and
    v#>'{sourceVersions,answers}'='1'::jsonb and
    v#>'{sourceVersions,pantry}' in ('0'::jsonb,'1'::jsonb), 'import_source_version_unsupported');
  perform menoo_private.exact_keys(v->'identity',array['householdName','soloFirstName','confirmed']);
  perform menoo_private.require(menoo_private.nonblank(v#>'{identity,householdName}') and
    v#>'{identity,confirmed}'='true'::jsonb, 'import_identity_confirmation_required');
  a := v->'answers';
  if v->>'journey' = 'solo' then
    perform menoo_private.exact_keys(a,v_common || array['goal','sex','age','heightCm','weightKg',
      'targetWeightKg','weeklyRateKg','activity','wantsScale']);
    perform menoo_private.require(menoo_private.nonblank(v#>'{identity,soloFirstName}'), 'import_identity_required');
  else
    perform menoo_private.exact_keys(a,v_common || array['members','mainCookId','portionRulesVersion','portionFactors']);
    perform menoo_private.require(v#>'{identity,soloFirstName}'='null'::jsonb, 'import_family_identity_invalid');
  end if;
  perform menoo_private.require(pg_catalog.jsonb_typeof(a->'budgetCurrency')='string' and
    v->'sourceCurrency'=a->'budgetCurrency', 'import_currency_conflict');
  n := menoo_private.decimal_value(a->'budgetAmount',true);
  perform menoo_private.budget_to_minor(n,a->>'budgetCurrency');
  a := pg_catalog.jsonb_set(a,'{budgetAmount}',pg_catalog.to_jsonb(n));
  perform menoo_private.require(a->>'management' in ('courses','reserves','mixte') and
    (case v->>'sourceManagement' when 'shopping' then 'courses' when 'pantry' then 'reserves'
      when 'mixed' then 'mixte' end) = a->>'management', 'import_management_conflict');
  a := pg_catalog.jsonb_set(a,'{diets}',menoo_private.string_list(a->'diets',v_diets,true));
  perform menoo_private.require((select pg_catalog.count(*) from pg_catalog.jsonb_array_elements_text(a->'diets') d
    where d in ('vegetarien','vegan','pescetarien')) <= 1, 'import_diet_conflict');
  a := pg_catalog.jsonb_set(a,'{allergens}',menoo_private.string_list(a->'allergens',v_allergens,true));
  a := pg_catalog.jsonb_set(a,'{excludedFoods}',menoo_private.string_list(a->'excludedFoods',null,false));
  a := pg_catalog.jsonb_set(a,'{equipment}',menoo_private.string_list(a->'equipment',array['four','micro_ondes',
    'plaques','airfryer','mixeur','robot','cuiseur_vapeur','autocuiseur','mijoteuse','plancha','wok','grille_pain'],true));
  a := pg_catalog.jsonb_set(a,'{cuisinePreferences}',menoo_private.string_list(a->'cuisinePreferences',array[
    'francaise','italienne','mediterraneenne','maghrebine','japonaise','asiatique','mexicaine','americaine'],true));
  perform menoo_private.require(a->>'cookingLevel' in ('debutant','intermediaire','confirme'), 'import_cooking_level_invalid');
  foreach v_key in array array['weekdayMinutes','weekendMinutes'] loop
    n := menoo_private.decimal_value(a->v_key,true);
    perform menoo_private.require(n in (15,30,45,60), 'import_cooking_time_invalid');
    a := pg_catalog.jsonb_set(a,array[v_key],pg_catalog.to_jsonb(n));
  end loop;
  perform menoo_private.require(pg_catalog.jsonb_typeof(a->'slots')='array' and
    pg_catalog.jsonb_array_length(a->'slots') between 1 and 21,'import_slots_invalid');
  for slot in select value from pg_catalog.jsonb_array_elements(a->'slots') loop
    perform menoo_private.exact_keys(slot,array['day','meal']);
    v_day := menoo_private.decimal_value(slot->'day',true);
    perform menoo_private.require(v_day between 1 and 7 and slot->>'meal' in
      ('petitDejeuner','dejeuner','diner'),'import_slot_invalid');
    v_id := v_day::text || ':' || (slot->>'meal');
    perform menoo_private.require(not (v_id=any(v_slot_ids)),'import_duplicate_slot');
    v_slot_ids := pg_catalog.array_append(v_slot_ids,v_id);
    v_slots := v_slots || pg_catalog.jsonb_build_array(pg_catalog.jsonb_set(slot,'{day}',pg_catalog.to_jsonb(v_day)));
  end loop;
  select pg_catalog.jsonb_agg(value order by (value->>'day')::integer,
    pg_catalog.convert_to(value->>'meal','UTF8')) into v_slots from pg_catalog.jsonb_array_elements(v_slots);
  a := pg_catalog.jsonb_set(a,'{slots}',v_slots);

  if v->>'journey'='solo' then
    perform menoo_private.require(a->>'goal' in ('pertePoids','priseMasse','seche','maintien') and
      a->>'sex' in ('homme','femme') and a->>'activity' in ('sedentaire','modere','actif','tresActif') and
      pg_catalog.jsonb_typeof(a->'wantsScale')='boolean','import_solo_codes_invalid');
    foreach v_key in array array['age','heightCm','weightKg'] loop
      n := menoo_private.decimal_value(a->v_key,v_key <> 'weightKg');
      perform menoo_private.require(case v_key when 'age' then n between 18 and 100
        when 'heightCm' then n between 120 and 230 else n between 35 and 250 end,'import_solo_profile_invalid');
      a := pg_catalog.jsonb_set(a,array[v_key],pg_catalog.to_jsonb(n));
    end loop;
    v_goal := a->>'goal'; v_height := (a->>'heightCm')::numeric; v_weight := (a->>'weightKg')::numeric;
    if v_goal='maintien' then
      perform menoo_private.require(a->'targetWeightKg'='null'::jsonb and a->'weeklyRateKg'='null'::jsonb,
        'import_inactive_target_must_stay_local');
    else
      v_target := menoo_private.decimal_value(a->'targetWeightKg');
      v_rate := menoo_private.decimal_value(a->'weeklyRateKg');
      perform menoo_private.require(v_target > 0 and v_target <= 250 and
        v_target >= pg_catalog.ceil(18.5 * (v_height/100) * (v_height/100) * 10)/10 and
        (case when v_goal='priseMasse' then v_target>v_weight else v_target<v_weight end) and
        (case v_goal when 'priseMasse' then v_rate in (0.25,0.5)
          when 'seche' then v_rate=0.5 else v_rate in (0.25,0.5,0.75) end),'import_target_invalid');
      a := pg_catalog.jsonb_set(a,'{targetWeightKg}',pg_catalog.to_jsonb(v_target));
      a := pg_catalog.jsonb_set(a,'{weeklyRateKg}',pg_catalog.to_jsonb(v_rate));
    end if;
  else
    perform menoo_private.require(a->'portionRulesVersion'='1'::jsonb,'import_portions_version_invalid');
    perform menoo_private.exact_keys(a->'portionFactors',array['adulte','enfant','bebe']);
    perform menoo_private.require(menoo_private.decimal_value(a#>'{portionFactors,adulte}')=1 and
      menoo_private.decimal_value(a#>'{portionFactors,enfant}')=0.65 and
      menoo_private.decimal_value(a#>'{portionFactors,bebe}')=0.3,'import_portions_invalid');
    a := pg_catalog.jsonb_set(a,'{portionFactors}','{"adulte":1,"enfant":0.65,"bebe":0.3}'::jsonb);
    perform menoo_private.require(pg_catalog.jsonb_typeof(a->'members')='array' and
      pg_catalog.jsonb_array_length(a->'members') between 1 and 20,'import_members_invalid');
    for m in select value from pg_catalog.jsonb_array_elements(a->'members') loop
      perform menoo_private.exact_keys(m,array['id','role','firstName','age','heightCm','weightKg','allergens']);
      n := menoo_private.decimal_value(m->'id',true);
      perform menoo_private.require(n between 1 and 9223372036854775807,'import_member_id_invalid');
      v_id := pg_catalog.trim_scale(n)::text;
      perform menoo_private.require(not(v_id=any(v_ids)) and menoo_private.nonblank(m->'firstName'),'import_member_identity_invalid');
      v_ids := pg_catalog.array_append(v_ids,v_id);
      m := pg_catalog.jsonb_set(m,'{id}',pg_catalog.to_jsonb(n));
      n := menoo_private.decimal_value(m->'age',true); v_role := m->>'role';
      perform menoo_private.require(case v_role when 'adulte' then n between 14 and 100
        when 'enfant' then n between 4 and 13 when 'bebe' then n between 0 and 3 else false end,'import_member_age_invalid');
      m := pg_catalog.jsonb_set(m,'{age}',pg_catalog.to_jsonb(n));
      if v_role='adulte' then v_adults:=v_adults+1;
      elsif v_role='enfant' then v_children:=v_children+1; else v_babies:=v_babies+1; end if;
      foreach v_key in array array['heightCm','weightKg'] loop
        if m->v_key='null'::jsonb then
          perform menoo_private.require(v_role='bebe','import_member_measure_missing');
        else
          n := menoo_private.decimal_value(m->v_key,v_key='heightCm');
          perform menoo_private.require(case
            when v_role='bebe' then n>0 and n<=9007199254740991
            when v_role='adulte' and v_key='heightCm' then n between 120 and 230
            when v_role='adulte' then n between 35 and 250
            when v_key='heightCm' then n between 80 and 190 else n between 12 and 100 end,'import_member_measure_invalid');
          m := pg_catalog.jsonb_set(m,array[v_key],pg_catalog.to_jsonb(n));
        end if;
      end loop;
      m := pg_catalog.jsonb_set(m,'{allergens}',menoo_private.string_list(m->'allergens',v_allergens,true));
      v_members := v_members || pg_catalog.jsonb_build_array(m);
    end loop;
    perform menoo_private.require(v_adults between 1 and 8 and v_children<=8 and v_babies<=4,'import_composition_invalid');
    a := pg_catalog.jsonb_set(a,'{members}',v_members);
    if a->'mainCookId'<>'null'::jsonb then
      n := menoo_private.decimal_value(a->'mainCookId',true);
      perform menoo_private.require(exists (select 1 from pg_catalog.jsonb_array_elements(v_members) x
        where (x->>'id')::numeric=n and x->>'role'='adulte'),'import_main_cook_invalid');
      a := pg_catalog.jsonb_set(a,'{mainCookId}',pg_catalog.to_jsonb(n));
    end if;
  end if;

  perform menoo_private.require(pg_catalog.jsonb_typeof(v->'pantry')='array','import_pantry_invalid');
  if v#>'{sourceVersions,pantry}'='0'::jsonb then
    perform menoo_private.require(v->'pantry'='[]'::jsonb,'import_unversioned_pantry_nonempty');
  end if;
  for item in select value from pg_catalog.jsonb_array_elements(v->'pantry') loop
    perform menoo_private.exact_keys(item,array['id','name','quantity','unit','unitLabel','location',
      'expiresOn','expiryOrigin','source','foodId','declaredCategory','declaredStock']);
    perform menoo_private.require(pg_catalog.jsonb_typeof(item->'id')='string' and
      (item->>'id') ~ '^[A-Za-z0-9][A-Za-z0-9._:-]{0,127}$' and not((item->>'id')=any(v_lots))
      and menoo_private.nonblank(item->'name'),'import_pantry_identity_invalid');
    v_lots := pg_catalog.array_append(v_lots,item->>'id');
    if item->'quantity'<>'null'::jsonb then
      n := menoo_private.decimal_value(item->'quantity');
      perform menoo_private.require(n>=0 and n<=1.7976931348623157e308::numeric,'import_quantity_invalid');
      item := pg_catalog.jsonb_set(item,'{quantity}',pg_catalog.to_jsonb(n));
    end if;
    perform menoo_private.require(item->'unit'='null'::jsonb or pg_catalog.jsonb_typeof(item->'unit')='string','import_unit_invalid');
    perform menoo_private.pantry_unit(item->>'unit');
    perform menoo_private.require(pg_catalog.jsonb_typeof(item->'unitLabel')='string' and
      item->>'location' in ('fridge','pantry','freezer','fruit_basket') and
      item->>'source' in ('manuel','code_barres','photo_ia','verification_rapide') and
      item->>'expiryOrigin' in ('unknown','estimated','userProvided') and
      (item->'foodId'='null'::jsonb or menoo_private.nonblank(item->'foodId')),'import_pantry_attributes_invalid');
    if item->'expiresOn'='null'::jsonb then
      perform menoo_private.require(item->>'expiryOrigin'='unknown','import_expiry_invalid');
    else
      perform menoo_private.require(pg_catalog.jsonb_typeof(item->'expiresOn')='string' and
        (item->>'expiresOn') ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$','import_date_invalid');
      v_date := (item->>'expiresOn')::date;
      perform menoo_private.require(pg_catalog.to_char(v_date,'YYYY-MM-DD')=item->>'expiresOn' and
        v_date between date '0001-01-01' and date '9999-12-31','import_date_invalid');
    end if;
    perform menoo_private.require(item->'declaredCategory'='null'::jsonb or
      item->>'declaredCategory' in ('pasta_rice_starches','oil_condiments','eggs_dairy','canned_sauce',
      'fresh_vegetables','fruits','flour_sugar','spices_herbs','frozen_meat_fish'),'import_category_invalid');
    perform menoo_private.require(item->'declaredStock'='null'::jsonb or
      item->>'declaredStock' in ('present','some'),'import_qualitative_stock_invalid');
    v_pantry := v_pantry || pg_catalog.jsonb_build_array(item);
  end loop;
  select coalesce(pg_catalog.jsonb_agg(value order by pg_catalog.convert_to(value->>'id','UTF8')),'[]'::jsonb)
    into v_pantry from pg_catalog.jsonb_array_elements(v_pantry);
  return pg_catalog.jsonb_set(pg_catalog.jsonb_set(v,'{answers}',a),'{pantry}',v_pantry);
end $fn$;

create function menoo_private.canonical_node(p jsonb, p_depth integer default 0)
returns bytea language plpgsql immutable set search_path = '' as $fn$
declare v_result bytea; v_text text; v_type text; x record;
begin
  perform menoo_private.require(p is not null and p_depth between 0 and 32,'import_canonical_depth_invalid');
  v_type := pg_catalog.jsonb_typeof(p);
  if v_type='null' then return pg_catalog.convert_to('N','UTF8'); end if;
  if v_type='boolean' then return pg_catalog.convert_to(case when p='true'::jsonb then 'B1' else 'B0' end,'UTF8'); end if;
  if v_type in ('string','number') then
    if v_type='string' then v_text:=p#>>'{}';
    else v_text:=pg_catalog.trim_scale((p#>>'{}')::numeric)::text;
      if (p#>>'{}')::numeric=0 then v_text:='0'; end if; end if;
    return pg_catalog.convert_to((case v_type when 'string' then 'S' else 'D' end) ||
      pg_catalog.octet_length(pg_catalog.convert_to(v_text,'UTF8'))::text || ':' || v_text,'UTF8');
  end if;
  if v_type='array' then
    v_result:=pg_catalog.convert_to('A'||pg_catalog.jsonb_array_length(p)::text||':','UTF8');
    for x in select value from pg_catalog.jsonb_array_elements(p) loop
      v_result:=v_result || menoo_private.canonical_node(x.value,p_depth+1);
    end loop;
    return v_result;
  end if;
  perform menoo_private.require(v_type='object','import_canonical_type_invalid');
  v_result:=pg_catalog.convert_to('O'||(select pg_catalog.count(*) from pg_catalog.jsonb_object_keys(p))::text||':','UTF8');
  for x in select key,value from pg_catalog.jsonb_each(p) order by pg_catalog.convert_to(key,'UTF8') loop
    v_result:=v_result || menoo_private.canonical_node(pg_catalog.to_jsonb(x.key),p_depth+1)
      || menoo_private.canonical_node(x.value,p_depth+1);
  end loop;
  return v_result;
end $fn$;

create function menoo_private.payload_hash(p_projected jsonb) returns bytea
language sql immutable set search_path = '' as $fn$
  select pg_catalog.sha256(pg_catalog.convert_to(E'menoo.guest-import/v1/canonical-1\n','UTF8') ||
    menoo_private.canonical_node(p_projected,0));
$fn$;

-- Suite : RPC transactionnelle, reçu et ACL dans la même transaction DDL.
create function public.import_guest_v1(
  p_expected_user_id uuid, p_operation_id uuid, p_payload text, p_expected_hash text
) returns jsonb language plpgsql security definer set search_path = '' as $fn$
declare
  v_user uuid := auth.uid(); v_origin uuid; v_mode public.app_mode; v_payload jsonb;
  a jsonb; m jsonb; item jsonb; slot jsonb; v_hash bytea; v_profile public.profiles%rowtype;
  v_existing menoo_private.guest_imports%rowtype;
  v_house uuid := pg_catalog.gen_random_uuid(); v_member uuid; v_lot uuid; v_local text;
  v_member_map jsonb := '{}'; v_lot_map jsonb := '{}'; v_receipt jsonb;
  v_position integer := 0; v_equipment text[]; v_diets text[]; v_allergens text[]; v_excluded text[];
  v_expected_members integer;
begin
  perform menoo_private.require(v_user is not null,'import_authentication_required');
  -- Assertion du compte attendu ; le propriétaire effectif reste EXCLUSIVEMENT auth.uid().
  perform menoo_private.require(p_expected_user_id=v_user,'import_session_mismatch');
  perform menoo_private.require(p_operation_id is not null,'import_operation_required');
  perform menoo_private.require(p_payload is not null and pg_catalog.octet_length(p_payload)<=8388608,
    'import_payload_size_invalid');
  if not (p_payload is json object with unique keys) then
    raise exception using errcode='22023', message='import_json_invalid_or_duplicate_keys';
  end if;
  -- Préserver le texte brut jusqu'au contrôle précédent : jsonb perdrait les doublons.
  v_payload := menoo_private.project_payload(p_payload::jsonb);
  v_hash := menoo_private.payload_hash(v_payload);
  perform menoo_private.require(p_expected_hash ~ '^[0-9a-f]{64}$','import_hash_format_invalid');
  perform menoo_private.require(pg_catalog.decode(p_expected_hash,'hex')=v_hash,'import_hash_mismatch');
  v_origin := (v_payload->>'originId')::uuid;
  v_mode := menoo_private.journey_mode(v_payload->>'journey');
  a := v_payload->'answers';

  -- Ordre stable : profil, recherche du reçu, état métier, foyer/enfants/registre.
  -- Tous les imports d'un compte, même d'origines différentes, se sérialisent ici.
  select * into v_profile from public.profiles where id=v_user for update;
  perform menoo_private.require(found,'import_profile_missing');
  select * into v_existing from menoo_private.guest_imports
    where owner_id=v_user and operation_id=p_operation_id;
  if found then
    perform menoo_private.require(v_existing.payload_hash=v_hash and
      v_existing.source_origin_id=v_origin and v_existing.journey=v_mode,
      'import_operation_content_conflict');
    return v_existing.receipt;
  end if;
  select * into v_existing from menoo_private.guest_imports
    where owner_id=v_user and source_origin_id=v_origin and journey=v_mode;
  if found then
    perform menoo_private.require(v_existing.payload_hash=v_hash,'import_origin_already_used');
    return v_existing.receipt; -- Identifiant d'opération initial conservé, pas de nouveau foyer.
  end if;
  perform menoo_private.require(v_profile.active_household_id is null and
    v_profile.onboarding_completed_at is null and v_profile.mode is null and
    not exists(select 1 from public.households where owner_id=v_user),'import_account_has_data');

  select array(select pg_catalog.jsonb_array_elements_text(a->'equipment')) into v_equipment;
  select array(select pg_catalog.jsonb_array_elements_text(a->'diets')) into v_diets;
  select array(select pg_catalog.jsonb_array_elements_text(a->'allergens')) into v_allergens;
  select array(select pg_catalog.jsonb_array_elements_text(a->'excludedFoods')) into v_excluded;
  -- Catalogues mutables après reprise d'un reçu : ne pas casser une opération déjà validée.
  perform menoo_private.require(not exists(select 1 from pg_catalog.unnest(v_equipment) c
    where not exists(select 1 from public.equipment e where e.code=c)) and
    not exists(select 1 from pg_catalog.unnest(v_diets) c
    where not exists(select 1 from public.diets d where d.code=c)) and
    not exists(select 1 from pg_catalog.unnest(v_allergens) c
    where not exists(select 1 from public.allergens al where al.code=c)), 'import_catalog_incompatible');
  if v_mode='foyer' then
    perform menoo_private.require(not exists(
      select 1 from pg_catalog.jsonb_array_elements(a->'members') mm
      cross join lateral pg_catalog.jsonb_array_elements_text(mm->'allergens') al
      where not exists(select 1 from public.allergens c where c.code=al)), 'import_catalog_incompatible');
  end if;

  insert into public.households(id,owner_id,name,mode,weekly_budget_cents,budget_currency,
    management_mode,cuisine_preferences,diet_codes,allergen_codes,excluded_foods,portion_rules_version)
  values(v_house,v_user,v_payload#>>'{identity,householdName}',v_mode,
    menoo_private.budget_to_minor((a->>'budgetAmount')::numeric,a->>'budgetCurrency'),a->>'budgetCurrency',
    (a->>'management')::public.management_mode,
    array(select pg_catalog.jsonb_array_elements_text(a->'cuisinePreferences')),
    case when v_mode='foyer' then v_diets else '{}'::text[] end,
    case when v_mode='foyer' then v_allergens else '{}'::text[] end,
    case when v_mode='foyer' then v_excluded else '{}'::text[] end,
    case when v_mode='foyer' then 1 else null end);

  if v_mode='solo' then
    v_member:=pg_catalog.gen_random_uuid();
    insert into public.household_members(id,household_id,first_name,role,sex,age_years,height_cm,
      weight_kg,goal,activity,is_owner,position,target_weight_kg,weekly_rate_kg,excluded_foods,wants_scale,source_local_id)
    values(v_member,v_house,v_payload#>>'{identity,soloFirstName}','adulte',
      (a->>'sex')::public.sex,(a->>'age')::smallint,(a->>'heightCm')::bigint,(a->>'weightKg')::numeric,
      (case a->>'goal' when 'pertePoids' then 'perte_poids' when 'priseMasse' then 'prise_masse'
        else a->>'goal' end)::public.health_goal,
      (case a->>'activity' when 'tresActif' then 'tres_actif' else a->>'activity' end)::public.activity_level,
      true,0,(a->>'targetWeightKg')::numeric,(a->>'weeklyRateKg')::numeric,v_excluded,(a->>'wantsScale')::boolean,'solo');
    insert into public.member_diets(member_id,diet_code) select v_member,c from pg_catalog.unnest(v_diets) c;
    insert into public.member_allergens(member_id,allergen_code) select v_member,c from pg_catalog.unnest(v_allergens) c;
    v_member_map:=pg_catalog.jsonb_build_object('solo',v_member::text);
    v_expected_members:=1;
    -- Aucun cuisinier principal Solo inventé : la source Solo ne collecte pas ce choix.
  else
    for m in select value from pg_catalog.jsonb_array_elements(a->'members') loop
      v_member:=pg_catalog.gen_random_uuid(); v_local:=m->>'id';
      insert into public.household_members(id,household_id,first_name,role,age_years,height_cm,
        weight_kg,position,source_local_id)
      values(v_member,v_house,m->>'firstName',(m->>'role')::public.member_role,(m->>'age')::smallint,
        (m->>'heightCm')::bigint,(m->>'weightKg')::numeric,v_position,v_local);
      insert into public.member_allergens(member_id,allergen_code)
        select v_member,c from pg_catalog.jsonb_array_elements_text(m->'allergens') c;
      v_member_map:=pg_catalog.jsonb_set(v_member_map,array[v_local],pg_catalog.to_jsonb(v_member::text));
      v_position:=v_position+1;
    end loop;
    v_expected_members:=v_position;
    if a->'mainCookId'<>'null'::jsonb then
      update public.households set main_cook_member_id=(v_member_map->>(a->>'mainCookId'))::uuid where id=v_house;
    end if;
  end if;

  insert into public.kitchen_settings(household_id,cooking_level,weekday_minutes,weekend_minutes)
    values(v_house,(a->>'cookingLevel')::public.cooking_level,
      (a->>'weekdayMinutes')::smallint,(a->>'weekendMinutes')::smallint);
  insert into public.household_equipment(household_id,equipment_code)
    select v_house,c from pg_catalog.unnest(v_equipment) c;
  for slot in select value from pg_catalog.jsonb_array_elements(a->'slots') loop
    insert into public.meal_plan_slots(household_id,day_of_week,meal_type)
    values(v_house,(slot->>'day')::smallint,
      (case slot->>'meal' when 'petitDejeuner' then 'petit_dejeuner' else slot->>'meal' end)::public.meal_type);
  end loop;
  for item in select value from pg_catalog.jsonb_array_elements(v_payload->'pantry') loop
    v_lot:=pg_catalog.gen_random_uuid();
    insert into public.pantry_items(id,household_id,name,quantity,unit,unit_label,location,expires_on,
      expiry_origin,source,local_food_id,declared_category,declared_stock,source_local_id)
    values(v_lot,v_house,item->>'name',(item->>'quantity')::numeric,menoo_private.pantry_unit(item->>'unit'),
      item->>'unitLabel',(item->>'location')::public.pantry_location,(item->>'expiresOn')::date,
      item->>'expiryOrigin',(item->>'source')::public.pantry_source,item->>'foodId',
      item->>'declaredCategory',item->>'declaredStock',item->>'id');
    perform menoo_private.require(exists(select 1 from public.pantry_items pi where pi.id=v_lot
      and pi.quantity is not distinct from (item->>'quantity')::numeric
      and pi.unit is not distinct from menoo_private.pantry_unit(item->>'unit')
      and pi.unit_label is not distinct from item->>'unitLabel'
      and pi.declared_category is not distinct from item->>'declaredCategory'
      and pi.declared_stock is not distinct from item->>'declaredStock'),'import_pantry_readback_mismatch');
    v_lot_map:=pg_catalog.jsonb_set(v_lot_map,array[item->>'id'],pg_catalog.to_jsonb(v_lot::text));
  end loop;
  perform menoo_private.require((select pg_catalog.count(*) from public.household_members where household_id=v_house)=v_expected_members
    and (select pg_catalog.count(*) from public.pantry_items where household_id=v_house)=pg_catalog.jsonb_array_length(v_payload->'pantry')
    and (select pg_catalog.count(*) from public.meal_plan_slots where household_id=v_house)=pg_catalog.jsonb_array_length(a->'slots'),
    'import_readback_count_mismatch');
  update public.profiles set mode=v_mode, active_household_id=v_house,
    onboarding_completed_at=pg_catalog.transaction_timestamp() where id=v_user;
  v_receipt:=pg_catalog.jsonb_build_object('contract','menoo.guest-import','version',1,
    'canonicalVersion','canonical-1','ownerId',v_user::text,'operationId',p_operation_id::text,
    'originId',v_origin::text,'journey',v_payload->>'journey','hash',pg_catalog.encode(v_hash,'hex'),
    'sourceVersions',v_payload->'sourceVersions','householdId',v_house::text,
    'members',v_member_map,'pantry',v_lot_map);
  insert into menoo_private.guest_imports(owner_id,operation_id,source_origin_id,journey,
    contract_version,canonical_version,source_versions,payload_hash,household_id,receipt)
  values(v_user,p_operation_id,v_origin,v_mode,1,1,v_payload->'sourceVersions',v_hash,v_house,v_receipt);
  set constraints public.profiles_active_household_owner_fk,
    public.households_main_cook_same_household_fk, public.menoo_household_cook_integrity,
    public.menoo_member_cook_integrity, menoo_private.guest_imports_household_owner_fk immediate;
  return v_receipt;
exception
  when unique_violation then
    raise exception using errcode='P0001',message='import_conflict';
  when foreign_key_violation or check_violation then
    raise exception using errcode='P0001',message='import_integrity_conflict';
  when invalid_text_representation or invalid_datetime_format or datetime_field_overflow
    or numeric_value_out_of_range or untranslatable_character or character_not_in_repertoire then
    raise exception using errcode='22023',message='import_value_invalid';
end $fn$;

create function public.get_guest_import_receipt_v1(
  p_expected_user_id uuid, p_operation_id uuid,
  p_source_origin_id uuid default null, p_journey text default null
) returns jsonb language plpgsql security definer set search_path = '' as $fn$
declare v_user uuid:=auth.uid(); v_receipt jsonb; v_mode public.app_mode;
begin
  perform menoo_private.require(v_user is not null,'import_authentication_required');
  perform menoo_private.require(v_user=p_expected_user_id,'import_session_mismatch');
  perform menoo_private.require(p_operation_id is not null,'import_operation_required');
  -- Attendre l'import déjà engagé sur ce compte, sans exposer un reçu partiel.
  perform 1 from public.profiles where id=v_user for update;
  perform menoo_private.require(found,'import_profile_missing');
  select receipt into v_receipt from menoo_private.guest_imports
    where owner_id=v_user and operation_id=p_operation_id;
  if found then return v_receipt; end if;
  if p_source_origin_id is not null and p_journey is not null then
    v_mode:=menoo_private.journey_mode(p_journey);
    select receipt into v_receipt from menoo_private.guest_imports
      where owner_id=v_user and source_origin_id=p_source_origin_id and journey=v_mode;
  end if;
  return v_receipt; -- SQL NULL signifie « aucun reçu trouvé », pas autorisation de nouvel id.
end $fn$;

-- Nouveau propriétaire : CREATE temporaire requis par ALTER FUNCTION OWNER.
-- L'administrateur exécutant devra pouvoir SET ROLE vers ce rôle ; précontrôle obligatoire.
-- Ces permissions temporaires et toutes les fonctions deviennent visibles au COMMIT seulement.
grant create on schema public to menoo_import_executor;
alter function public.import_guest_v1(uuid,uuid,text,text) owner to menoo_import_executor;
alter function public.get_guest_import_receipt_v1(uuid,uuid,uuid,text) owner to menoo_import_executor;
revoke create on schema public from menoo_import_executor;
revoke all on function public.import_guest_v1(uuid,uuid,text,text),
  public.get_guest_import_receipt_v1(uuid,uuid,uuid,text) from public, anon, authenticated;
grant execute on function public.import_guest_v1(uuid,uuid,text,text),
  public.get_guest_import_receipt_v1(uuid,uuid,uuid,text) to authenticated;
revoke all on all functions in schema menoo_private from public, anon, authenticated;
grant execute on function menoo_private.require(boolean,text), menoo_private.exact_keys(jsonb,text[]),
  menoo_private.nonblank(jsonb), menoo_private.decimal_value(jsonb,boolean),
  menoo_private.string_list(jsonb,text[],boolean), menoo_private.journey_mode(text),
  menoo_private.pantry_unit(text), menoo_private.project_payload(jsonb),
  menoo_private.canonical_node(jsonb,integer), menoo_private.payload_hash(jsonb)
  to menoo_import_executor;

-- Aucune fonction SECURITY DEFINER ne possède de SQL dynamique contrôlé par le client.
-- Aucun COMMIT interne, aucune absorption d'erreur pour conserver des écritures partielles.
-- Ne pas créer de fonction d'édition générale contournant ce point d'entrée.
commit;
