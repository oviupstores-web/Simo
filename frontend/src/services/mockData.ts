// Menoo mock data (démonstration). Toutes ces données sont fictives et
// clairement identifiées "démo" dans l'interface. Prêt pour être remplacé
// par de vrais appels Open Food Facts + Open Prices + Supabase plus tard.

import { getRecipe } from './recipes';

export type Cuisine = 'italienne' | 'française' | 'méditerranéenne' | 'asiatique';
export type PurchaseRule = 'none' | 'one_or_two' | 'anti_waste';

export interface PantryItem {
  id: string;
  name: string;
  emoji: string;
  containerSize: number; // contenance totale (unité brute)
  unit: 'g' | 'cl' | 'ml' | 'kg' | 'unité';
  available: number; // quantité restante réelle
  source: 'Open Food Facts';
  priceInfo?: { amount: number; date: string; store: string; source: 'Open Prices' };
}

export const initialPantry: PantryItem[] = [
  {
    id: 'pates',
    name: 'Pâtes',
    emoji: '🍝',
    containerSize: 500,
    unit: 'g',
    available: 250,
    source: 'Open Food Facts',
    priceInfo: { amount: 1.35, date: '12 mars 2026', store: 'Carrefour Market', source: 'Open Prices' },
  },
  {
    id: 'champignons',
    name: 'Champignons',
    emoji: '🍄',
    containerSize: 250,
    unit: 'g',
    available: 165,
    source: 'Open Food Facts',
    priceInfo: { amount: 2.10, date: '10 mars 2026', store: 'Monoprix', source: 'Open Prices' },
  },
  {
    id: 'creme',
    name: 'Crème liquide',
    emoji: '🥛',
    containerSize: 20,
    unit: 'cl',
    available: 20,
    source: 'Open Food Facts',
    priceInfo: { amount: 1.05, date: '11 mars 2026', store: 'Auchan', source: 'Open Prices' },
  },
];

// Recette italienne de démonstration - besoins par personne
export const italianRecipeNeeds = {
  pates: 100, // g
  champignons: 75, // g
  creme: 5, // cl
};

export const asianRecipeExtraNeed = {
  ingredient: 'sauce soja',
  reason: 'Complément indispensable pour la recette asiatique',
};

export interface Recipe {
  recipeId: string;
  title: string;
  cuisine: Cuisine;
  time: number; // minutes
  steps: string[];
  perPerson: Record<string, number>;
}

export const italianRecipe: Recipe = {
  recipeId: 'pasta-cream-mushroom',
  title: 'Pâtes crémeuses aux champignons',
  cuisine: 'italienne',
  time: 22,
  perPerson: italianRecipeNeeds,
  steps: [
    "Faites chauffer une grande casserole d'eau salée et lancez la cuisson des pâtes.",
    "Nettoyez et émincez les champignons. Faites-les revenir 5 min à la poêle avec un filet d'huile.",
    "Ajoutez la crème liquide, salez, poivrez et laissez frémir 2 min.",
    "Égouttez les pâtes al dente et mélangez-les à la sauce chaude.",
    "Servez immédiatement, avec un tour de moulin à poivre et quelques copeaux de parmesan si vous en avez.",
  ],
};

// Nutrition demo pour Suivi
export const nutritionRadar = [
  { label: 'Protéines', value: 0.72 },
  { label: 'Glucides', value: 0.85 },
  { label: 'Lipides', value: 0.6 },
  { label: 'Fibres', value: 0.55 },
  { label: 'Énergie', value: 0.78 },
];

export const weeklyCurve = [
  { day: 'Lun', value: 1850 },
  { day: 'Mar', value: 1720 },
  { day: 'Mer', value: 2100 },
  { day: 'Jeu', value: 1980 },
  { day: 'Ven', value: 2200 },
  { day: 'Sam', value: 2350 },
  { day: 'Dim', value: 2050 },
];

// -- Plan de la semaine (démo — sortie de l'étape 12) -----------------------

export interface PlannedMeal {
  id: string;
  recipeId: string;
  slot: 'Petit-déj' | 'Déjeuner' | 'Dîner' | 'Collation';
  title: string;
  emoji: string;
  image: string;
  time: number; // minutes
  price: number; // € par portion
  noPurchase: boolean;
  confirmed: boolean;
}

export interface DayPlan {
  day: 'Lun' | 'Mar' | 'Mer' | 'Jeu' | 'Ven' | 'Sam' | 'Dim';
  meals: PlannedMeal[];
}

export interface MealOverride {
  recipeId: string;
  emoji: string;
  noPurchase: boolean;
}

function plannedMeal(
  id: string,
  recipeId: string,
  emoji: string,
  noPurchase: boolean,
  confirmed = false
): PlannedMeal {
  const recipe = getRecipe(recipeId);
  if (!recipe) throw new Error(`Recette introuvable: ${recipeId}`);

  return {
    id,
    recipeId,
    slot: recipe.slot,
    title: recipe.title,
    emoji,
    image: recipe.image_url,
    time: recipe.time,
    price: recipe.price,
    noPurchase,
    confirmed,
  };
}

export function resolvePlannedMeal(base: PlannedMeal, override?: MealOverride): PlannedMeal {
  if (!override) return base;
  return plannedMeal(base.id, override.recipeId, override.emoji, override.noPurchase, base.confirmed);
}

export const weeklyPlan: DayPlan[] = [
  {
    day: 'Lun',
    meals: [
      plannedMeal('lun-pd', 'granola-bowl', '🥣', true, true),
      plannedMeal('lun-dej', 'pasta-cream-mushroom', '🍝', true, true),
      plannedMeal('lun-din', 'veg-soup', '🥣', true, true),
    ],
  },
  {
    day: 'Mar',
    meals: [
      plannedMeal('mar-pd', 'toast-honey', '🍞', true, true),
      plannedMeal('mar-dej', 'rice-salad', '🥗', false, true),
      plannedMeal('mar-din', 'herb-omelette', '🍳', true),
    ],
  },
  {
    day: 'Mer',
    meals: [
      plannedMeal('mer-pd', 'yogurt-fruits', '🍓', true),
      plannedMeal('mer-dej', 'roast-chicken', '🍗', false),
      plannedMeal('mer-din', 'mushroom-risotto', '🍚', true),
    ],
  },
  {
    day: 'Jeu',
    meals: [
      plannedMeal('jeu-pd', 'granola-bowl', '🥣', true),
      plannedMeal('jeu-dej', 'med-bowl', '🫒', false),
      plannedMeal('jeu-din', 'lentil-curry', '🍛', false),
    ],
  },
  {
    day: 'Ven',
    meals: [
      plannedMeal('ven-pd', 'toast-honey', '🍞', true),
      plannedMeal('ven-dej', 'chicken-wrap', '🌯', false),
      plannedMeal('ven-din', 'homemade-pizza', '🍕', false),
    ],
  },
  {
    day: 'Sam',
    meals: [
      plannedMeal('sam-pd', 'pancakes-light', '🥞', false),
      plannedMeal('sam-dej', 'veg-tart', '🥧', false),
      plannedMeal('sam-din', 'grilled-fish', '🐟', false),
    ],
  },
  {
    day: 'Dim',
    meals: [
      plannedMeal('dim-pd', 'yogurt-fruits', '🍓', true),
      plannedMeal('dim-dej', 'sunday-chicken', '🍗', false),
      plannedMeal('dim-din', 'light-soup', '🥣', true),
    ],
  },
];

// Les alternatives sont résolues depuis le registre canonique grâce à leur
// recipeId stable. Elles ne recopient plus les titres, prix ou images.
export const swapAlternatives: PlannedMeal[] = [
  plannedMeal('swap-quinoa', 'quinoa-salad-warm', '🥗', true),
  plannedMeal('swap-wok', 'veg-noodle-wok', '🍜', false),
  plannedMeal('swap-gratin', 'zucchini-gratin', '🥘', false),
];

// Étapes de préparation pas-à-pas (démo) avec minuteurs éventuels
export interface PrepStep {
  text: string;
  timerSec?: number; // durée en secondes
}
export const prepSteps: Record<string, PrepStep[]> = {
  default: [
    { text: "Sortir tous les ingrédients et couper ce qui doit l'être.", timerSec: 300 },
    { text: 'Faire chauffer une poêle à feu moyen avec un filet d\'huile.', timerSec: 120 },
    { text: 'Ajouter les ingrédients principaux et faire revenir 5 minutes.', timerSec: 300 },
    { text: 'Assaisonner, mélanger et laisser mijoter 8 minutes.', timerSec: 480 },
    { text: 'Vérifier la cuisson et l\'assaisonnement, dresser dans les assiettes.' },
    { text: 'Servez immédiatement. Bon appétit !' },
  ],
};

// Substitutions IA (démo) pour ingrédients manquants
export interface Substitution {
  missing: string;
  suggestion: string;
  note: string;
}
export const substitutions: Substitution[] = [
  { missing: 'Crème liquide', suggestion: 'Yaourt grec + un peu de lait', note: 'Texture similaire, moins gras.' },
  { missing: 'Parmesan', suggestion: 'Levure maltée', note: 'Note umami proche, végétal.' },
  { missing: 'Basilic frais', suggestion: 'Basilic séché ou persil', note: 'Diviser la quantité par 3.' },
];

export interface ShoppingItem {
  id: string;
  label: string;
  qty: string;
  rayon: 'Frais' | 'Sec' | 'Fruits & Légumes' | 'Boucherie' | 'Épicerie';
  store: string;
  price?: number;
}

export const shoppingList: ShoppingItem[] = [
  { id: 's1', label: 'Riz basmati', qty: '500 g', rayon: 'Sec', store: 'Carrefour Market', price: 2.10 },
  { id: 's2', label: 'Haricots verts', qty: '400 g', rayon: 'Fruits & Légumes', store: 'Grand Frais', price: 3.20 },
  { id: 's3', label: 'Blanc de poulet', qty: '500 g', rayon: 'Boucherie', store: 'Monoprix', price: 7.90 },
  { id: 's4', label: 'Pâte à pizza', qty: '2 unités', rayon: 'Frais', store: 'Carrefour Market', price: 2.30 },
  { id: 's5', label: 'Lentilles corail', qty: '250 g', rayon: 'Sec', store: 'Biocoop', price: 3.10 },
  { id: 's6', label: 'Avocat', qty: '2 unités', rayon: 'Fruits & Légumes', store: 'Grand Frais', price: 3.00 },
];
