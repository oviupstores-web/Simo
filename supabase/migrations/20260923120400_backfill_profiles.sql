-- =====================================================================
-- Menoo — rattrapage : profils des comptes créés avant l'installation
-- de la base (le déclencheur d'inscription n'existait pas encore).
-- Sans effet sur les comptes qui ont déjà un profil.
-- =====================================================================
insert into public.profiles (id, display_name)
select u.id, nullif(u.raw_user_meta_data ->> 'first_name', '')
from auth.users u
on conflict (id) do nothing;
