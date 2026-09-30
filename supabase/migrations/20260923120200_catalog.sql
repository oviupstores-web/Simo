-- =====================================================================
-- Menoo — 3/4 : catalogue de référence
-- Rayons, équipements, régimes, allergènes, ingrédients (prix estimés),
-- recettes (ingrédients pour 4 portions, étapes, équipements), enseignes.
-- Prix : estimations moyennes en grande surface (France, 2026), en centimes
-- par gramme, par millilitre ou par pièce. Ils seront remplacés par Open
-- Prices et les tickets scannés (PRD §5.5).
-- =====================================================================

insert into public.aisles (code, label, position) values
  ('fruits_legumes',  'Fruits & Légumes',   1),
  ('frais_proteines', 'Frais & Protéines',  2),
  ('cremerie',        'Crèmerie',           3),
  ('boulangerie',     'Boulangerie',        4),
  ('epicerie',        'Épicerie',           5),
  ('surgeles',        'Surgelés',           6);

insert into public.equipment (code, label, position) values
  ('plaques',        'Plaques de cuisson',  1),
  ('four',           'Four',                2),
  ('micro_ondes',    'Micro-ondes',         3),
  ('mixeur',         'Mixeur / blender',    4),
  ('robot',          'Robot cuiseur',       5),
  ('airfryer',       'Friteuse sans huile', 6),
  ('wok',            'Wok',                 7),
  ('grille_pain',    'Grille-pain',         8),
  ('cuiseur_vapeur', 'Cuiseur vapeur',      9);

insert into public.diets (code, label) values
  ('vegetarien',   'Végétarien'),
  ('vegan',        'Végan'),
  ('pescetarien',  'Pescétarien'),
  ('sans_porc',    'Sans porc / halal'),
  ('sans_gluten',  'Sans gluten'),
  ('sans_lactose', 'Sans lactose');

insert into public.allergens (code, label) values
  ('gluten',         'Gluten'),
  ('crustaces',      'Crustacés'),
  ('oeufs',          'Œufs'),
  ('poisson',        'Poisson'),
  ('arachides',      'Arachides'),
  ('soja',           'Soja'),
  ('lait',           'Lait'),
  ('fruits_a_coque', 'Fruits à coque'),
  ('celeri',         'Céleri'),
  ('moutarde',       'Moutarde'),
  ('sesame',         'Sésame'),
  ('sulfites',       'Sulfites'),
  ('lupin',          'Lupin'),
  ('mollusques',     'Mollusques');

-- ---------------------------------------------------------------------
-- Ingrédients
-- ---------------------------------------------------------------------
insert into public.ingredients (slug, name, aisle_code, default_location, unit, price_cents_per_unit, origin, shelf_life_days) values
  -- Fruits & légumes
  ('pomme',            'Pomme',                  'fruits_legumes',  'fruit_basket', 'piece', 45,    'vegetal', 21),
  ('banane',           'Banane',                 'fruits_legumes',  'fruit_basket', 'piece', 25,    'vegetal', 6),
  ('kiwi',             'Kiwi',                   'fruits_legumes',  'fruit_basket', 'piece', 35,    'vegetal', 10),
  ('avocat',           'Avocat',                 'fruits_legumes',  'fruit_basket', 'piece', 99,    'vegetal', 5),
  ('citron',           'Citron',                 'fruits_legumes',  'fruit_basket', 'piece', 45,    'vegetal', 21),
  ('grenade',          'Grenade',                'fruits_legumes',  'fruit_basket', 'piece', 150,   'vegetal', 21),
  ('tomates_cerises',  'Tomates cerises',        'fruits_legumes',  'fruit_basket', 'g',     0.9,   'vegetal', 6),
  ('myrtilles',        'Myrtilles',              'fruits_legumes',  'fridge',       'g',     1.6,   'vegetal', 5),
  ('framboises',       'Framboises',             'fruits_legumes',  'fridge',       'g',     1.8,   'vegetal', 3),
  ('fraises',          'Fraises',                'fruits_legumes',  'fridge',       'g',     0.9,   'vegetal', 4),
  ('epinards',         'Épinards frais',         'fruits_legumes',  'fridge',       'g',     0.9,   'vegetal', 4),
  ('roquette',         'Roquette',               'fruits_legumes',  'fridge',       'g',     1.5,   'vegetal', 4),
  ('laitue',           'Laitue',                 'fruits_legumes',  'fridge',       'piece', 90,    'vegetal', 5),
  ('brocoli',          'Brocoli',                'fruits_legumes',  'fridge',       'g',     0.35,  'vegetal', 6),
  ('asperges',         'Asperges vertes',        'fruits_legumes',  'fridge',       'g',     1.2,   'vegetal', 4),
  ('carottes',         'Carottes',               'fruits_legumes',  'fridge',       'g',     0.18,  'vegetal', 14),
  ('poivron',          'Poivron',                'fruits_legumes',  'fridge',       'piece', 80,    'vegetal', 7),
  ('courgette',        'Courgette',              'fruits_legumes',  'fridge',       'piece', 60,    'vegetal', 7),
  ('poireaux',         'Poireaux',               'fruits_legumes',  'fridge',       'g',     0.35,  'vegetal', 10),
  ('chou_rouge',       'Chou rouge',             'fruits_legumes',  'fridge',       'g',     0.2,   'vegetal', 14),
  ('basilic',          'Basilic frais',          'fruits_legumes',  'fridge',       'g',     3.0,   'vegetal', 5),
  ('aneth',            'Aneth frais',            'fruits_legumes',  'fridge',       'g',     3.0,   'vegetal', 5),
  ('patate_douce',     'Patate douce',           'fruits_legumes',  'pantry',       'g',     0.3,   'vegetal', 21),
  ('pommes_de_terre',  'Pommes de terre',        'fruits_legumes',  'pantry',       'g',     0.15,  'vegetal', 30),
  ('courge_butternut', 'Courge butternut',       'fruits_legumes',  'pantry',       'g',     0.25,  'vegetal', 30),
  ('oignon',           'Oignon',                 'fruits_legumes',  'pantry',       'piece', 20,    'vegetal', 30),
  ('ail',              'Ail (gousse)',           'fruits_legumes',  'pantry',       'piece', 15,    'vegetal', 60),
  -- Frais & protéines
  ('saumon',           'Pavé de saumon frais',   'frais_proteines', 'fridge',       'g',     2.6,   'poisson', 3),
  ('cabillaud',        'Dos de cabillaud',       'frais_proteines', 'fridge',       'g',     2.2,   'poisson', 2),
  ('poulet',           'Filet de poulet',        'frais_proteines', 'fridge',       'g',     1.3,   'viande',  3),
  ('boeuf',            'Bœuf à braiser',         'frais_proteines', 'fridge',       'g',     2.0,   'viande',  3),
  ('lardons',          'Lardons fumés',          'frais_proteines', 'fridge',       'g',     1.4,   'porc',    10),
  ('crevettes',        'Crevettes cuites',       'frais_proteines', 'fridge',       'g',     2.4,   'fruits_de_mer', 3),
  ('tofu',             'Tofu ferme',             'frais_proteines', 'fridge',       'g',     0.9,   'vegetal', 20),
  -- Crèmerie
  ('lait',             'Lait demi-écrémé',       'cremerie',        'fridge',       'ml',    0.105, 'laitier', 7),
  ('yaourt_grec',      'Yaourt grec',            'cremerie',        'fridge',       'g',     0.45,  'laitier', 14),
  ('yaourt_nature',    'Yaourt nature',          'cremerie',        'fridge',       'piece', 30,    'laitier', 21),
  ('yaourt_coco',      'Yaourt végétal coco',    'cremerie',        'fridge',       'g',     0.6,   'vegetal', 14),
  ('oeufs',            'Œufs',                   'cremerie',        'fridge',       'piece', 30,    'oeuf',    28),
  ('beurre',           'Beurre doux',            'cremerie',        'fridge',       'g',     1.0,   'laitier', 60),
  ('creme_fraiche',    'Crème fraîche',          'cremerie',        'fridge',       'ml',    0.5,   'laitier', 14),
  ('feta',             'Feta',                   'cremerie',        'fridge',       'g',     1.4,   'laitier', 20),
  ('chevre',           'Fromage de chèvre',      'cremerie',        'fridge',       'g',     1.8,   'laitier', 14),
  ('parmesan',         'Parmesan',               'cremerie',        'fridge',       'g',     2.5,   'laitier', 60),
  ('emmental',         'Emmental râpé',          'cremerie',        'fridge',       'g',     1.1,   'laitier', 30),
  ('pate_brisee',      'Pâte brisée',            'cremerie',        'fridge',       'piece', 120,   'laitier', 21),
  ('pate_feuilletee',  'Pâte feuilletée',        'cremerie',        'fridge',       'piece', 130,   'laitier', 21),
  -- Boulangerie
  ('pain_complet',     'Pain complet',           'boulangerie',     'pantry',       'g',     0.5,   'vegetal', 4),
  ('tortillas',        'Tortillas de blé',       'boulangerie',     'pantry',       'piece', 25,    'vegetal', 30),
  -- Épicerie
  ('flocons_avoine',   'Flocons d''avoine',      'epicerie',        'pantry',       'g',     0.25,  'vegetal', 365),
  ('quinoa',           'Quinoa',                 'epicerie',        'pantry',       'g',     0.7,   'vegetal', 540),
  ('riz',              'Riz basmati',            'epicerie',        'pantry',       'g',     0.25,  'vegetal', 540),
  ('riz_arborio',      'Riz arborio',            'epicerie',        'pantry',       'g',     0.5,   'vegetal', 540),
  ('pates',            'Tagliatelles',           'epicerie',        'pantry',       'g',     0.3,   'vegetal', 540),
  ('nouilles_soba',    'Nouilles soba',          'epicerie',        'pantry',       'g',     0.8,   'vegetal', 365),
  ('lentilles_vertes', 'Lentilles vertes',       'epicerie',        'pantry',       'g',     0.4,   'vegetal', 540),
  ('pois_chiches',     'Pois chiches cuits',     'epicerie',        'pantry',       'g',     0.35,  'vegetal', 540),
  ('coulis_tomate',    'Coulis de tomate',       'epicerie',        'pantry',       'g',     0.25,  'vegetal', 365),
  ('huile_olive',      'Huile d''olive',         'epicerie',        'pantry',       'ml',    1.0,   'vegetal', 540),
  ('sauce_soja',       'Sauce soja',             'epicerie',        'pantry',       'ml',    0.8,   'vegetal', 540),
  ('moutarde',         'Moutarde de Dijon',      'epicerie',        'pantry',       'g',     0.8,   'vegetal', 365),
  ('miel',             'Miel',                   'epicerie',        'pantry',       'g',     1.2,   'miel',    730),
  ('puree_amande',     'Purée d''amande',        'epicerie',        'pantry',       'g',     2.2,   'vegetal', 365),
  ('amandes',          'Amandes',                'epicerie',        'pantry',       'g',     1.6,   'vegetal', 365),
  ('noix',             'Cerneaux de noix',       'epicerie',        'pantry',       'g',     1.8,   'vegetal', 365),
  ('dattes',           'Dattes',                 'epicerie',        'pantry',       'g',     0.9,   'vegetal', 365),
  ('graines_chia',     'Graines de chia',        'epicerie',        'pantry',       'g',     1.4,   'vegetal', 540),
  ('sesame',           'Graines de sésame',      'epicerie',        'pantry',       'g',     1.5,   'vegetal', 540),
  ('olives',           'Olives noires',          'epicerie',        'pantry',       'g',     1.2,   'vegetal', 365),
  ('cacao',            'Cacao non sucré',        'epicerie',        'pantry',       'g',     1.5,   'vegetal', 540),
  ('matcha',           'Thé matcha',             'epicerie',        'pantry',       'g',     15.0,  'vegetal', 365),
  ('lait_avoine',      'Boisson à l''avoine',    'epicerie',        'pantry',       'ml',    0.2,   'vegetal', 180),
  ('bouillon_legumes', 'Bouillon de légumes',    'epicerie',        'pantry',       'piece', 20,    'vegetal', 540),
  ('herbes_provence',  'Herbes de Provence',     'epicerie',        'pantry',       'g',     5.0,   'vegetal', 730),
  ('cumin',            'Cumin',                  'epicerie',        'pantry',       'g',     4.0,   'vegetal', 730),
  ('paprika',          'Paprika',                'epicerie',        'pantry',       'g',     4.0,   'vegetal', 730),
  ('cannelle',         'Cannelle',               'epicerie',        'pantry',       'g',     3.0,   'vegetal', 730),
  -- Surgelés
  ('fruits_rouges_surgeles', 'Fruits rouges surgelés', 'surgeles',  'freezer',      'g',     0.9,   'vegetal', 365),
  ('edamame',          'Edamame surgelés',       'surgeles',        'freezer',      'g',     0.8,   'vegetal', 365),
  ('brocoli_surgele',  'Brocoli surgelé',        'surgeles',        'freezer',      'g',     0.3,   'vegetal', 365);

-- Allergènes des ingrédients
insert into public.ingredient_allergens (ingredient_id, allergen_code)
select i.id, a.code
from (values
  ('flocons_avoine', 'gluten'), ('pain_complet', 'gluten'), ('tortillas', 'gluten'),
  ('pates', 'gluten'), ('pates', 'oeufs'), ('nouilles_soba', 'gluten'), ('lait_avoine', 'gluten'),
  ('pate_brisee', 'gluten'), ('pate_brisee', 'lait'), ('pate_feuilletee', 'gluten'), ('pate_feuilletee', 'lait'),
  ('sauce_soja', 'soja'), ('sauce_soja', 'gluten'), ('tofu', 'soja'), ('edamame', 'soja'),
  ('lait', 'lait'), ('yaourt_grec', 'lait'), ('yaourt_nature', 'lait'), ('beurre', 'lait'),
  ('creme_fraiche', 'lait'), ('feta', 'lait'), ('chevre', 'lait'), ('parmesan', 'lait'), ('emmental', 'lait'),
  ('oeufs', 'oeufs'),
  ('saumon', 'poisson'), ('cabillaud', 'poisson'), ('crevettes', 'crustaces'),
  ('puree_amande', 'fruits_a_coque'), ('amandes', 'fruits_a_coque'), ('noix', 'fruits_a_coque'),
  ('sesame', 'sesame'), ('moutarde', 'moutarde'), ('bouillon_legumes', 'celeri')
) as v (slug, code)
join public.ingredients i on i.slug = v.slug
join public.allergens a on a.code = v.code;

-- ---------------------------------------------------------------------
-- Recettes (quantités pour servings_base = 4 portions)
-- Images : photos HD rangées dans design/stitch_images/ (Storage au jalon 8)
-- ---------------------------------------------------------------------
insert into public.recipes
  (slug, title, description, meal_types, cooking_level, total_minutes, kcal_per_serving, protein_g, carbs_g, fat_g, image_path)
values
  -- Petits-déjeuners
  ('porridge_pommes_caramelisees', 'Porridge aux pommes caramélisées', 'Flocons d''avoine crémeux, pommes fondantes et une touche de cannelle.',
    '{petit_dejeuner}', 'debutant', 10, 380, 11, 62, 9, 'plats/plat_porridge_pommes_caramelisees.jpg'),
  ('bowl_yaourt_grec_fruits', 'Bowl yaourt grec & fruits frais', 'Yaourt grec, fruits rouges, banane et flocons croustillants.',
    '{petit_dejeuner,collation}', 'debutant', 5, 320, 18, 38, 10, 'plats/plat_bowl_yaourt_grec_fruits.jpg'),
  ('bowl_yaourt_coco_chia', 'Bowl yaourt végétal coco, chia & baies', 'Version végétale : yaourt coco, graines de chia et baies.',
    '{petit_dejeuner}', 'debutant', 5, 300, 6, 34, 15, 'plats/plat_bowl_yaourt_coco_chia_baies.jpg'),
  ('tartines_beurre_amande_fraises', 'Tartines purée d''amande & fraises', 'Pain complet grillé, purée d''amande et fraises fraîches.',
    '{petit_dejeuner}', 'debutant', 7, 360, 11, 44, 16, 'plats/plat_tartines_beurre_amande_fraises.jpg'),
  ('omelette_epinards_feta', 'Omelette épinards & feta', 'Omelette moelleuse aux jeunes pousses d''épinards et à la feta.',
    '{petit_dejeuner,dejeuner}', 'debutant', 12, 310, 21, 4, 23, null),
  ('pancakes_banane_avoine', 'Pancakes banane & avoine', 'Pancakes sans farine blanche, à la banane et aux flocons d''avoine.',
    '{petit_dejeuner}', 'intermediaire', 20, 340, 14, 48, 10, null),
  ('smoothie_bowl_epinards', 'Smoothie bowl vert', 'Banane, épinards, kiwi et chia, mixés avec une boisson à l''avoine.',
    '{petit_dejeuner,collation}', 'debutant', 8, 260, 6, 45, 7, null),
  ('tartine_avocat_oeuf', 'Tartine avocat & œuf', 'Pain complet grillé, avocat écrasé au citron et œuf au plat.',
    '{petit_dejeuner}', 'debutant', 12, 390, 15, 36, 21, null),

  -- Plats (déjeuner / dîner)
  ('saumon_grille_quinoa_legumes', 'Saumon grillé, quinoa et légumes', 'Un plat sain et savoureux, riche en oméga-3 et en fibres. Parfait pour un dîner léger et nourrissant.',
    '{dejeuner,diner}', 'debutant', 25, 450, 32, 48, 18, 'plats/plat_bowl_equilibre_saumon_landing.jpg'),
  ('bol_quinoa_poulet', 'Bol quinoa poulet', 'Poulet grillé, quinoa, épinards, avocat et tomates cerises.',
    '{dejeuner,diner}', 'debutant', 25, 520, 38, 45, 19, 'plats/plat_bowl_epinards_poulet_quinoa.jpg'),
  ('supreme_volaille_puree_patate_douce', 'Suprême de volaille & purée de patate douce', 'Volaille dorée, purée onctueuse et asperges vertes.',
    '{dejeuner,diner}', 'intermediaire', 45, 540, 40, 52, 16, 'plats/plat_supreme_volaille_puree_patate_douce.jpg'),
  ('tofu_roti_mousseline_patate_douce', 'Tofu rôti aux herbes & mousseline de patate douce', 'Tofu rôti aux herbes de Provence, mousseline de patate douce et asperges.',
    '{dejeuner,diner}', 'intermediaire', 40, 470, 22, 55, 17, 'plats/plat_tofu_roti_mousseline_patate_douce.jpg'),
  ('salade_lentilles_chevre', 'Salade de lentilles, chèvre & grenade', 'Lentilles vertes tièdes, chèvre frais, grenade, roquette et noix.',
    '{dejeuner,diner}', 'debutant', 30, 480, 24, 46, 21, 'plats/plat_salade_lentilles_chevre_grenade.jpg'),
  ('gratin_butternut', 'Gratin de butternut au parmesan', 'Courge butternut fondante, gratinée au parmesan.',
    '{dejeuner,diner}', 'intermediaire', 50, 390, 13, 38, 21, 'plats/plat_gratin_butternut_potimarron.jpg'),
  ('wok_soba_tofu', 'Wok de nouilles soba au tofu', 'Nouilles soba sautées, tofu doré et légumes croquants.',
    '{dejeuner,diner}', 'intermediaire', 20, 510, 24, 68, 15, 'plats/plat_wok_soba_tofu.jpg'),
  ('poulet_carottes_roties', 'Poulet rôti & carottes au four', 'Filets de poulet et carottes rôtis aux herbes.',
    '{dejeuner,diner}', 'debutant', 45, 430, 38, 22, 20, 'plats/plat_poulet_poele_carottes_roties.jpg'),
  ('gratin_dauphinois', 'Gratin de pommes de terre', 'Le gratin familial, crémeux et doré.',
    '{dejeuner,diner}', 'intermediaire', 75, 460, 14, 50, 22, 'plats/plat_gratin_pommes_de_terre.jpg'),
  ('cabillaud_legumes_soleil', 'Cabillaud & légumes du soleil', 'Dos de cabillaud au four, courgettes, poivrons, tomates et olives.',
    '{dejeuner,diner}', 'intermediaire', 35, 360, 30, 18, 18, 'plats/plat_mediterraneen_poisson_legumes.jpg'),
  ('tagliatelles_tomate_basilic', 'Tagliatelles tomate & basilic', 'Tagliatelles, sauce tomate mijotée, parmesan et basilic frais.',
    '{dejeuner,diner}', 'debutant', 25, 490, 17, 80, 11, 'plats/plat_tagliatelles_tomate.jpg'),
  ('wrap_poulet_avocat', 'Wraps poulet & avocat', 'Tortillas garnies de poulet, avocat, salade et yaourt citronné.',
    '{dejeuner}', 'debutant', 20, 480, 33, 42, 20, 'plats/plat_wrap_avocat_poulet.jpg'),
  ('poelee_pois_chiches_legumes', 'Poêlée méditerranéenne de pois chiches', 'Pois chiches, courgettes, poivrons et tomates au cumin.',
    '{dejeuner,diner}', 'debutant', 25, 380, 15, 48, 13, 'plats/plat_poelee_pois_chiches_legumes.jpg'),
  ('quiche_saumon_aneth', 'Quiche saumon, épinards & aneth', 'Quiche généreuse au saumon, épinards et aneth.',
    '{dejeuner,diner}', 'confirme', 55, 520, 26, 30, 33, 'plats/plat_quiche_saumon_aneth.jpg'),
  ('risotto_butternut', 'Risotto à la butternut', 'Risotto crémeux à la courge butternut et au parmesan.',
    '{dejeuner,diner}', 'confirme', 40, 480, 13, 72, 14, 'plats/plat_risotto_butternut.jpg'),
  ('saumon_creme_epinards', 'Saumon crème & épinards, riz basmati', 'Saumon poêlé, sauce crème à l''ail et épinards fondus.',
    '{dejeuner,diner}', 'intermediaire', 25, 590, 34, 50, 27, 'plats/plat_saumon_creme_ail_epinards_avec_ui.jpg'),
  ('boeuf_bistrot_poireaux', 'Bœuf bistrot, poireaux & pommes de terre', 'Bœuf braisé à la moutarde, poireaux fondants et pommes de terre rôties.',
    '{diner}', 'confirme', 60, 560, 38, 40, 26, 'plats/plat_bistrot_poireaux_boeuf.jpg'),
  ('tarte_legumes_mediterraneenne', 'Tarte fine aux légumes du soleil', 'Pâte feuilletée, courgettes, poivron, oignons et chèvre.',
    '{dejeuner,diner}', 'intermediaire', 45, 450, 14, 38, 27, 'plats/plat_tarte_legumes_mediterraneenne.jpg'),
  ('poke_bowl_saumon', 'Poke bowl saumon & edamame', 'Riz, saumon mariné, edamame, avocat et chou rouge.',
    '{dejeuner}', 'intermediaire', 30, 560, 30, 62, 20, 'plats/plat_poke_bowl_saumon_edamame.jpg'),
  ('frites_patate_douce', 'Frites de patate douce', 'Frites croustillantes à la friteuse sans huile, au paprika.',
    '{dejeuner,diner}', 'debutant', 25, 230, 3, 44, 5, null),

  -- Collations
  ('bouchees_matcha_cacao', 'Bouchées énergétiques matcha & cacao', 'Dattes, amandes, avoine, cacao et matcha, sans cuisson.',
    '{collation}', 'debutant', 15, 210, 5, 28, 9, 'plats/plat_bouchees_matcha_cacao_the.jpg'),
  ('pomme_puree_amande', 'Pomme & purée d''amande', 'Une collation simple et rassasiante.',
    '{collation}', 'debutant', 3, 190, 4, 22, 10, null);

-- Ingrédients des recettes (pour 4 portions)
insert into public.recipe_ingredients (recipe_id, ingredient_id, quantity)
select r.id, i.id, v.qty
from (values
  ('porridge_pommes_caramelisees', 'flocons_avoine', 320), ('porridge_pommes_caramelisees', 'lait', 800),
  ('porridge_pommes_caramelisees', 'pomme', 2), ('porridge_pommes_caramelisees', 'miel', 40), ('porridge_pommes_caramelisees', 'cannelle', 4),

  ('bowl_yaourt_grec_fruits', 'yaourt_grec', 600), ('bowl_yaourt_grec_fruits', 'myrtilles', 150), ('bowl_yaourt_grec_fruits', 'framboises', 125),
  ('bowl_yaourt_grec_fruits', 'banane', 2), ('bowl_yaourt_grec_fruits', 'flocons_avoine', 80), ('bowl_yaourt_grec_fruits', 'miel', 30),

  ('bowl_yaourt_coco_chia', 'yaourt_coco', 500), ('bowl_yaourt_coco_chia', 'graines_chia', 60),
  ('bowl_yaourt_coco_chia', 'fruits_rouges_surgeles', 250), ('bowl_yaourt_coco_chia', 'banane', 2),

  ('tartines_beurre_amande_fraises', 'pain_complet', 320), ('tartines_beurre_amande_fraises', 'puree_amande', 80), ('tartines_beurre_amande_fraises', 'fraises', 250),

  ('omelette_epinards_feta', 'oeufs', 8), ('omelette_epinards_feta', 'epinards', 200), ('omelette_epinards_feta', 'feta', 100), ('omelette_epinards_feta', 'huile_olive', 20),

  ('pancakes_banane_avoine', 'oeufs', 4), ('pancakes_banane_avoine', 'banane', 3), ('pancakes_banane_avoine', 'flocons_avoine', 160), ('pancakes_banane_avoine', 'lait', 200),

  ('smoothie_bowl_epinards', 'banane', 3), ('smoothie_bowl_epinards', 'epinards', 100), ('smoothie_bowl_epinards', 'lait_avoine', 400),
  ('smoothie_bowl_epinards', 'graines_chia', 30), ('smoothie_bowl_epinards', 'kiwi', 2),

  ('tartine_avocat_oeuf', 'pain_complet', 320), ('tartine_avocat_oeuf', 'avocat', 2), ('tartine_avocat_oeuf', 'oeufs', 4), ('tartine_avocat_oeuf', 'citron', 1),

  ('saumon_grille_quinoa_legumes', 'saumon', 600), ('saumon_grille_quinoa_legumes', 'quinoa', 200), ('saumon_grille_quinoa_legumes', 'brocoli', 300),
  ('saumon_grille_quinoa_legumes', 'tomates_cerises', 250), ('saumon_grille_quinoa_legumes', 'huile_olive', 30), ('saumon_grille_quinoa_legumes', 'citron', 1),

  ('bol_quinoa_poulet', 'poulet', 500), ('bol_quinoa_poulet', 'quinoa', 240), ('bol_quinoa_poulet', 'epinards', 150), ('bol_quinoa_poulet', 'avocat', 2),
  ('bol_quinoa_poulet', 'tomates_cerises', 250), ('bol_quinoa_poulet', 'citron', 1), ('bol_quinoa_poulet', 'huile_olive', 30),

  ('supreme_volaille_puree_patate_douce', 'poulet', 600), ('supreme_volaille_puree_patate_douce', 'patate_douce', 800),
  ('supreme_volaille_puree_patate_douce', 'asperges', 400), ('supreme_volaille_puree_patate_douce', 'beurre', 30), ('supreme_volaille_puree_patate_douce', 'lait', 100),

  ('tofu_roti_mousseline_patate_douce', 'tofu', 400), ('tofu_roti_mousseline_patate_douce', 'patate_douce', 800), ('tofu_roti_mousseline_patate_douce', 'asperges', 300),
  ('tofu_roti_mousseline_patate_douce', 'huile_olive', 40), ('tofu_roti_mousseline_patate_douce', 'herbes_provence', 5),

  ('salade_lentilles_chevre', 'lentilles_vertes', 300), ('salade_lentilles_chevre', 'chevre', 150), ('salade_lentilles_chevre', 'grenade', 1),
  ('salade_lentilles_chevre', 'roquette', 100), ('salade_lentilles_chevre', 'noix', 50), ('salade_lentilles_chevre', 'huile_olive', 30),

  ('gratin_butternut', 'courge_butternut', 1200), ('gratin_butternut', 'parmesan', 80), ('gratin_butternut', 'creme_fraiche', 200), ('gratin_butternut', 'oignon', 1),

  ('wok_soba_tofu', 'nouilles_soba', 300), ('wok_soba_tofu', 'tofu', 300), ('wok_soba_tofu', 'poivron', 2), ('wok_soba_tofu', 'carottes', 300),
  ('wok_soba_tofu', 'sauce_soja', 60), ('wok_soba_tofu', 'sesame', 15),

  ('poulet_carottes_roties', 'poulet', 600), ('poulet_carottes_roties', 'carottes', 800), ('poulet_carottes_roties', 'oignon', 2),
  ('poulet_carottes_roties', 'huile_olive', 30), ('poulet_carottes_roties', 'herbes_provence', 5),

  ('gratin_dauphinois', 'pommes_de_terre', 1200), ('gratin_dauphinois', 'lait', 500), ('gratin_dauphinois', 'creme_fraiche', 200),
  ('gratin_dauphinois', 'ail', 2), ('gratin_dauphinois', 'emmental', 100),

  ('cabillaud_legumes_soleil', 'cabillaud', 600), ('cabillaud_legumes_soleil', 'courgette', 2), ('cabillaud_legumes_soleil', 'poivron', 2),
  ('cabillaud_legumes_soleil', 'tomates_cerises', 250), ('cabillaud_legumes_soleil', 'olives', 80), ('cabillaud_legumes_soleil', 'huile_olive', 40),

  ('tagliatelles_tomate_basilic', 'pates', 400), ('tagliatelles_tomate_basilic', 'coulis_tomate', 500), ('tagliatelles_tomate_basilic', 'parmesan', 60),
  ('tagliatelles_tomate_basilic', 'basilic', 20), ('tagliatelles_tomate_basilic', 'ail', 2),

  ('wrap_poulet_avocat', 'tortillas', 8), ('wrap_poulet_avocat', 'poulet', 400), ('wrap_poulet_avocat', 'avocat', 2),
  ('wrap_poulet_avocat', 'laitue', 1), ('wrap_poulet_avocat', 'yaourt_grec', 150), ('wrap_poulet_avocat', 'citron', 1),

  ('poelee_pois_chiches_legumes', 'pois_chiches', 500), ('poelee_pois_chiches_legumes', 'courgette', 2), ('poelee_pois_chiches_legumes', 'poivron', 2),
  ('poelee_pois_chiches_legumes', 'oignon', 1), ('poelee_pois_chiches_legumes', 'tomates_cerises', 250), ('poelee_pois_chiches_legumes', 'cumin', 5),
  ('poelee_pois_chiches_legumes', 'huile_olive', 30),

  ('quiche_saumon_aneth', 'pate_brisee', 1), ('quiche_saumon_aneth', 'saumon', 300), ('quiche_saumon_aneth', 'oeufs', 3),
  ('quiche_saumon_aneth', 'creme_fraiche', 200), ('quiche_saumon_aneth', 'aneth', 10), ('quiche_saumon_aneth', 'epinards', 150),

  ('risotto_butternut', 'riz_arborio', 320), ('risotto_butternut', 'courge_butternut', 600), ('risotto_butternut', 'parmesan', 60),
  ('risotto_butternut', 'oignon', 1), ('risotto_butternut', 'bouillon_legumes', 1), ('risotto_butternut', 'beurre', 20),

  ('saumon_creme_epinards', 'saumon', 600), ('saumon_creme_epinards', 'creme_fraiche', 200), ('saumon_creme_epinards', 'epinards', 300),
  ('saumon_creme_epinards', 'ail', 2), ('saumon_creme_epinards', 'riz', 240),

  ('boeuf_bistrot_poireaux', 'boeuf', 600), ('boeuf_bistrot_poireaux', 'poireaux', 800), ('boeuf_bistrot_poireaux', 'pommes_de_terre', 800),
  ('boeuf_bistrot_poireaux', 'moutarde', 30), ('boeuf_bistrot_poireaux', 'huile_olive', 20),

  ('tarte_legumes_mediterraneenne', 'pate_feuilletee', 1), ('tarte_legumes_mediterraneenne', 'courgette', 2), ('tarte_legumes_mediterraneenne', 'poivron', 1),
  ('tarte_legumes_mediterraneenne', 'oignon', 2), ('tarte_legumes_mediterraneenne', 'chevre', 100),

  ('poke_bowl_saumon', 'saumon', 400), ('poke_bowl_saumon', 'riz', 300), ('poke_bowl_saumon', 'edamame', 200), ('poke_bowl_saumon', 'avocat', 2),
  ('poke_bowl_saumon', 'chou_rouge', 200), ('poke_bowl_saumon', 'sauce_soja', 40), ('poke_bowl_saumon', 'sesame', 10),

  ('frites_patate_douce', 'patate_douce', 800), ('frites_patate_douce', 'huile_olive', 15), ('frites_patate_douce', 'paprika', 5),

  ('bouchees_matcha_cacao', 'dattes', 200), ('bouchees_matcha_cacao', 'flocons_avoine', 100), ('bouchees_matcha_cacao', 'amandes', 80),
  ('bouchees_matcha_cacao', 'cacao', 20), ('bouchees_matcha_cacao', 'matcha', 5),

  ('pomme_puree_amande', 'pomme', 4), ('pomme_puree_amande', 'puree_amande', 80)
) as v (recipe_slug, ingredient_slug, qty)
join public.recipes r on r.slug = v.recipe_slug
join public.ingredients i on i.slug = v.ingredient_slug;

-- Équipements nécessaires (une recette n'est proposée que si tout est coché)
insert into public.recipe_equipment (recipe_id, equipment_code)
select r.id, v.code
from (values
  ('porridge_pommes_caramelisees', 'plaques'),
  ('tartines_beurre_amande_fraises', 'grille_pain'),
  ('omelette_epinards_feta', 'plaques'),
  ('pancakes_banane_avoine', 'plaques'),
  ('smoothie_bowl_epinards', 'mixeur'),
  ('tartine_avocat_oeuf', 'plaques'), ('tartine_avocat_oeuf', 'grille_pain'),
  ('saumon_grille_quinoa_legumes', 'four'), ('saumon_grille_quinoa_legumes', 'plaques'),
  ('bol_quinoa_poulet', 'plaques'),
  ('supreme_volaille_puree_patate_douce', 'four'), ('supreme_volaille_puree_patate_douce', 'plaques'),
  ('tofu_roti_mousseline_patate_douce', 'four'), ('tofu_roti_mousseline_patate_douce', 'mixeur'),
  ('salade_lentilles_chevre', 'plaques'),
  ('gratin_butternut', 'four'),
  ('wok_soba_tofu', 'wok'),
  ('poulet_carottes_roties', 'four'),
  ('gratin_dauphinois', 'four'),
  ('cabillaud_legumes_soleil', 'four'),
  ('tagliatelles_tomate_basilic', 'plaques'),
  ('wrap_poulet_avocat', 'plaques'),
  ('poelee_pois_chiches_legumes', 'plaques'),
  ('quiche_saumon_aneth', 'four'),
  ('risotto_butternut', 'plaques'),
  ('saumon_creme_epinards', 'plaques'),
  ('boeuf_bistrot_poireaux', 'plaques'), ('boeuf_bistrot_poireaux', 'four'),
  ('tarte_legumes_mediterraneenne', 'four'),
  ('poke_bowl_saumon', 'plaques'),
  ('frites_patate_douce', 'airfryer'),
  ('bouchees_matcha_cacao', 'mixeur')
) as v (slug, code)
join public.recipes r on r.slug = v.slug;

-- Étapes (recette maître + premières recettes ; les autres au jalon 8)
insert into public.recipe_steps (recipe_id, position, instruction, minutes)
select r.id, v.pos, v.txt, v.mins
from (values
  ('saumon_grille_quinoa_legumes', 1, 'Préchauffez le four à 200 °C. Rincez le quinoa puis faites-le cuire 12 minutes dans deux fois son volume d''eau salée.', 12),
  ('saumon_grille_quinoa_legumes', 2, 'Détaillez le brocoli en fleurettes et coupez les tomates cerises en deux.', 5),
  ('saumon_grille_quinoa_legumes', 3, 'Disposez le saumon et le brocoli sur une plaque, arrosez d''huile d''olive, salez, poivrez et enfournez 12 minutes.', 12),
  ('saumon_grille_quinoa_legumes', 4, 'Servez le saumon sur le quinoa avec les légumes et un filet de jus de citron.', 2),
  ('bol_quinoa_poulet', 1, 'Faites cuire le quinoa 12 minutes dans l''eau salée.', 12),
  ('bol_quinoa_poulet', 2, 'Saisissez les filets de poulet 5 à 6 minutes de chaque côté, puis tranchez-les.', 12),
  ('bol_quinoa_poulet', 3, 'Répartissez épinards, quinoa, poulet, avocat et tomates dans les bols. Assaisonnez de citron et d''huile d''olive.', 5),
  ('porridge_pommes_caramelisees', 1, 'Faites chauffer le lait avec les flocons d''avoine 5 minutes en remuant.', 5),
  ('porridge_pommes_caramelisees', 2, 'Poêlez les pommes en dés avec le miel et la cannelle 4 minutes, puis servez-les sur le porridge.', 5)
) as v (slug, pos, txt, mins)
join public.recipes r on r.slug = v.slug;

-- ---------------------------------------------------------------------
-- Enseignes (fictives, issues des écrans Stitch — pas d'API enseigne en France)
-- ---------------------------------------------------------------------
insert into public.stores (name, logo_path, supports_drive, supports_delivery) values
  ('Épicure Provisions', 'enseignes/enseigne_epicure_avec_ui.jpg',           true,  true),
  ('Clean Hypermarché',  'enseignes/enseigne_clean_avec_ui.jpg',             true,  false),
  ('Community Grocery',  'enseignes/enseigne_community_grocery_avec_ui.jpg', false, true);
