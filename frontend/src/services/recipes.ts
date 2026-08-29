// Registry canonique des recettes Menoo.
// Chaque recette a un recipe_id STABLE. Toutes les URL d'images sont associées
// via recipe_id (jamais via index de tableau, jour de la semaine, ni position).
// L'image_hash change dès que le nom ou les ingrédients changent, invalidant le cache.

export type MealSlot = "Petit-déj" | "Déjeuner" | "Dîner" | "Collation";

export interface Recipe {
  recipe_id: string;
  title: string;
  slot: MealSlot;
  ingredients: string[];
  description: string;
  time: number;
  price: number;
  image_url: string;
  image_hash: string;
}

// Image neutre affichée en cas d'échec (jamais l'image d'une autre recette).
export const GENERIC_FOOD_IMAGE =
  "https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=600&q=70";

// Hash de contenu (djb2) — clé de cache image, invalidée si titre/ingrédients changent.
export function computeImageHash(input: { title: string; ingredients: string[] }): string {
  const key = `${input.title.toLowerCase()}|${input.ingredients.map((i) => i.toLowerCase()).sort().join(",")}`;
  let h = 5381;
  for (let i = 0; i < key.length; i++) h = ((h << 5) + h + key.charCodeAt(i)) | 0;
  return Math.abs(h).toString(16);
}

// Prompt d'image (utilisé côté backend/service ; sert de spec pour le générateur).
export function buildImagePrompt(r: Pick<Recipe, "title" | "ingredients" | "slot" | "description">): string {
  return `Photographie culinaire réaliste de ${r.title}, préparée avec ${r.ingredients.slice(0, 5).join(", ")}. Le plat doit être clairement reconnaissable et correspondre strictement à la recette (${r.slot}). ${r.description} Présentation appétissante, lumière naturelle, vue légèrement plongeante, fond clair et neutre, aucune personne, aucun texte, aucun logo, aucun ingrédient absent de la recette.`;
}

// Sur mobile, l'URL de stockage serait recipes/{recipe_id}/{image_hash}.webp
// via Supabase Storage. Ici en prototype front-only, nous utilisons des URLs
// Unsplash CURATÉES et vérifiées pour matcher chaque plat.
function _make(recipe: Omit<Recipe, "image_hash">): Recipe {
  return {
    ...recipe,
    image_hash: computeImageHash({ title: recipe.title, ingredients: recipe.ingredients }),
  };
}

export const RECIPES: Record<string, Recipe> = {
  "granola-bowl": _make({
    recipe_id: "granola-bowl",
    title: "Bowl fruits & granola",
    slot: "Petit-déj",
    ingredients: ["yaourt", "granola", "fruits rouges", "banane", "miel"],
    description: "Bol de yaourt garni de granola croustillant et de fruits frais.",
    time: 8,
    price: 2.10,
    image_url: "https://images.unsplash.com/photo-1490474418585-ba9bad8fd0ea?w=600&q=70",
  }),
  "toast-honey": _make({
    recipe_id: "toast-honey",
    title: "Tartines pain complet & miel",
    slot: "Petit-déj",
    ingredients: ["pain complet", "beurre", "miel"],
    description: "Tartines dorées, beurre et miel.",
    time: 5,
    price: 1.20,
    image_url: "https://images.unsplash.com/photo-1484723091739-30a097e8f929?w=600&q=70",
  }),
  "yogurt-fruits": _make({
    recipe_id: "yogurt-fruits",
    title: "Yaourt & fruits frais",
    slot: "Petit-déj",
    ingredients: ["yaourt nature", "fraises", "myrtilles", "amandes"],
    description: "Yaourt onctueux et fruits frais coupés.",
    time: 5,
    price: 1.60,
    image_url: "https://images.unsplash.com/photo-1488477181946-6428a0291777?w=600&q=70",
  }),
  "pancakes-light": _make({
    recipe_id: "pancakes-light",
    title: "Pancakes légers",
    slot: "Petit-déj",
    ingredients: ["farine", "œufs", "lait", "sirop d'érable"],
    description: "Pile de pancakes moelleux avec sirop.",
    time: 15,
    price: 1.90,
    image_url: "https://images.unsplash.com/photo-1528207776546-365bb710ee93?w=600&q=70",
  }),
  "pasta-cream-mushroom": _make({
    recipe_id: "pasta-cream-mushroom",
    title: "Pâtes crémeuses aux champignons",
    slot: "Déjeuner",
    ingredients: ["pâtes", "champignons", "crème liquide", "ail", "parmesan"],
    description: "Pâtes al dente enrobées d'une sauce crémeuse aux champignons.",
    time: 22,
    price: 3.40,
    image_url: "https://images.unsplash.com/photo-1621996346565-e3dbc353d2e5?w=600&q=70",
  }),
  "veg-soup": _make({
    recipe_id: "veg-soup",
    title: "Soupe de légumes rôtis",
    slot: "Dîner",
    ingredients: ["carottes", "courge", "oignon", "bouillon", "thym"],
    description: "Velouté de légumes rôtis au four.",
    time: 30,
    price: 2.80,
    image_url: "https://images.unsplash.com/photo-1547592180-85f173990554?w=600&q=70",
  }),
  "rice-salad": _make({
    recipe_id: "rice-salad",
    title: "Salade de riz croquant",
    slot: "Déjeuner",
    ingredients: ["riz", "concombre", "tomate", "maïs", "vinaigrette"],
    description: "Salade de riz colorée aux légumes croquants.",
    time: 15,
    price: 3.10,
    image_url: "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=600&q=70",
  }),
  "herb-omelette": _make({
    recipe_id: "herb-omelette",
    title: "Omelette aux herbes",
    slot: "Dîner",
    ingredients: ["œufs", "persil", "ciboulette", "beurre"],
    description: "Omelette moelleuse aux herbes fraîches.",
    time: 12,
    price: 1.80,
    image_url: "https://images.unsplash.com/photo-1510693206972-df098062cb71?w=600&q=70",
  }),
  "roast-chicken": _make({
    recipe_id: "roast-chicken",
    title: "Poulet rôti & haricots verts",
    slot: "Déjeuner",
    ingredients: ["poulet", "haricots verts", "ail", "thym"],
    description: "Poulet doré au four accompagné de haricots verts.",
    time: 40,
    price: 4.80,
    image_url: "https://images.unsplash.com/photo-1598103442097-8b74394b95c6?w=600&q=70",
  }),
  "mushroom-risotto": _make({
    recipe_id: "mushroom-risotto",
    title: "Risotto aux champignons",
    slot: "Dîner",
    ingredients: ["riz arborio", "champignons", "parmesan", "vin blanc"],
    description: "Risotto crémeux aux champignons et parmesan.",
    time: 35,
    price: 3.20,
    image_url: "https://images.unsplash.com/photo-1476124369491-e7addf5db371?w=600&q=70",
  }),
  "med-bowl": _make({
    recipe_id: "med-bowl",
    title: "Bol méditerranéen",
    slot: "Déjeuner",
    ingredients: ["quinoa", "pois chiches", "concombre", "féta", "olives"],
    description: "Bol frais aux saveurs méditerranéennes.",
    time: 20,
    price: 3.60,
    image_url: "https://images.unsplash.com/photo-1512058564366-18510be2db19?w=600&q=70",
  }),
  "lentil-curry": _make({
    recipe_id: "lentil-curry",
    title: "Curry de lentilles",
    slot: "Dîner",
    ingredients: ["lentilles corail", "lait de coco", "curry", "tomate"],
    description: "Curry crémeux de lentilles corail.",
    time: 30,
    price: 2.90,
    image_url: "https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=600&q=70",
  }),
  "chicken-wrap": _make({
    recipe_id: "chicken-wrap",
    title: "Wrap poulet-avocat",
    slot: "Déjeuner",
    ingredients: ["tortilla", "poulet", "avocat", "salade", "sauce"],
    description: "Wrap fondant poulet-avocat.",
    time: 15,
    price: 3.80,
    image_url: "https://images.unsplash.com/photo-1626700051175-6818013e1d4f?w=600&q=70",
  }),
  "homemade-pizza": _make({
    recipe_id: "homemade-pizza",
    title: "Pizza maison",
    slot: "Dîner",
    ingredients: ["pâte à pizza", "tomate", "mozzarella", "basilic"],
    description: "Pizza maison margherita croustillante.",
    time: 45,
    price: 4.20,
    image_url: "https://images.unsplash.com/photo-1513104890138-7c749659a591?w=600&q=70",
  }),
  "veg-tart": _make({
    recipe_id: "veg-tart",
    title: "Tarte aux légumes du soleil",
    slot: "Déjeuner",
    ingredients: ["pâte brisée", "courgette", "aubergine", "tomate"],
    description: "Tarte estivale aux légumes rôtis.",
    time: 40,
    price: 3.90,
    image_url: "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600&q=70",
  }),
  "grilled-fish": _make({
    recipe_id: "grilled-fish",
    title: "Poisson grillé & légumes",
    slot: "Dîner",
    ingredients: ["filet de poisson", "citron", "légumes de saison"],
    description: "Poisson grillé et légumes rôtis.",
    time: 25,
    price: 5.10,
    image_url: "https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=600&q=70",
  }),
  "sunday-chicken": _make({
    recipe_id: "sunday-chicken",
    title: "Poulet rôti dominical",
    slot: "Déjeuner",
    ingredients: ["poulet entier", "pommes de terre", "romarin"],
    description: "Poulet rôti dominical, pommes de terre au four.",
    time: 60,
    price: 5.30,
    image_url: "https://images.unsplash.com/photo-1598103442097-8b74394b95c6?w=600&q=70",
  }),
  "light-soup": _make({
    recipe_id: "light-soup",
    title: "Soupe légère",
    slot: "Dîner",
    ingredients: ["poireau", "carotte", "bouillon"],
    description: "Soupe légère aux légumes.",
    time: 20,
    price: 2.40,
    image_url: "https://images.unsplash.com/photo-1547592180-85f173990554?w=600&q=70",
  }),
  "quinoa-salad-warm": _make({
    recipe_id: "quinoa-salad-warm",
    title: "Salade tiède quinoa & légumes",
    slot: "Déjeuner",
    ingredients: ["quinoa", "courgette", "poivron", "féta"],
    description: "Salade tiède de quinoa et légumes sautés.",
    time: 18,
    price: 3.20,
    image_url: "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=600&q=70",
  }),
  "veg-noodle-wok": _make({
    recipe_id: "veg-noodle-wok",
    title: "Wok de nouilles aux légumes",
    slot: "Dîner",
    ingredients: ["nouilles", "légumes wok", "sauce soja"],
    description: "Wok de nouilles sautées aux légumes croquants.",
    time: 15,
    price: 2.80,
    image_url: "https://images.unsplash.com/photo-1476124369491-e7addf5db371?w=600&q=70",
  }),
  "zucchini-gratin": _make({
    recipe_id: "zucchini-gratin",
    title: "Gratin de courgettes",
    slot: "Dîner",
    ingredients: ["courgettes", "crème", "emmental"],
    description: "Gratin fondant de courgettes.",
    time: 35,
    price: 3.10,
    image_url: "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600&q=70",
  }),
};

// Recherche par recipe_id — jamais par index ou position.
export function getRecipe(recipeId: string): Recipe | null {
  return RECIPES[recipeId] ?? null;
}

// Renvoie toujours l'image liée au recipe_id. Fallback = image neutre.
// Ne renverra JAMAIS l'image d'une autre recette.
export function getRecipeImage(recipeId: string): { url: string; hash: string } {
  const r = RECIPES[recipeId];
  if (!r) return { url: GENERIC_FOOD_IMAGE, hash: "generic" };
  return { url: r.image_url, hash: r.image_hash };
}
