-- =====================================================================
-- Menoo — libellé du régime « sans porc » (retours de Simo, 2026-09-24).
-- « Omnivore » n'est pas un régime en base : il correspond à l'absence de
-- ligne dans member_diets (aucune restriction), choix par défaut.
-- =====================================================================
update public.diets set label = 'Sans porc' where code = 'sans_porc';
