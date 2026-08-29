// Menoo mock data (démonstration). Toutes ces données sont fictives et
// clairement identifiées "démo" dans l'interface. Prêt pour être remplacé
// par de vrais appels Open Food Facts + Open Prices + Supabase plus tard.

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
  title: string;
  cuisine: Cuisine;
  time: number; // minutes
  steps: string[];
  perPerson: Record<string, number>;
}

export const italianRecipe: Recipe = {
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
  slot: 'Petit-déj' | 'Déjeuner' | 'Dîner' | 'Collation';
  title: string;
  emoji: string;
  time: number; // minutes
  noPurchase: boolean; // "0 € d'achat"
  confirmed: boolean;
}

export interface DayPlan {
  day: 'Lun' | 'Mar' | 'Mer' | 'Jeu' | 'Ven' | 'Sam' | 'Dim';
  meals: PlannedMeal[];
}

export const weeklyPlan: DayPlan[] = [
  {
    day: 'Lun',
    meals: [
      { id: 'l1', slot: 'Déjeuner', title: 'Pâtes crémeuses aux champignons', emoji: '🍝', time: 22, noPurchase: true, confirmed: true },
      { id: 'l2', slot: 'Dîner', title: 'Soupe de légumes rôtis', emoji: '🥣', time: 30, noPurchase: true, confirmed: true },
    ],
  },
  {
    day: 'Mar',
    meals: [
      { id: 'm1', slot: 'Déjeuner', title: 'Salade de riz croquant', emoji: '🥗', time: 15, noPurchase: false, confirmed: true },
      { id: 'm2', slot: 'Dîner', title: "Omelette aux herbes", emoji: '🍳', time: 12, noPurchase: true, confirmed: false },
    ],
  },
  {
    day: 'Mer',
    meals: [
      { id: 'w1', slot: 'Déjeuner', title: 'Poulet rôti et haricots verts', emoji: '🍗', time: 40, noPurchase: false, confirmed: false },
      { id: 'w2', slot: 'Dîner', title: 'Risotto aux champignons', emoji: '🍚', time: 35, noPurchase: true, confirmed: false },
    ],
  },
  {
    day: 'Jeu',
    meals: [
      { id: 'j1', slot: 'Déjeuner', title: 'Bol méditerranéen', emoji: '🫒', time: 20, noPurchase: false, confirmed: false },
      { id: 'j2', slot: 'Dîner', title: 'Curry de lentilles', emoji: '🍛', time: 30, noPurchase: false, confirmed: false },
    ],
  },
  {
    day: 'Ven',
    meals: [
      { id: 'v1', slot: 'Déjeuner', title: 'Wrap poulet-avocat', emoji: '🌯', time: 15, noPurchase: false, confirmed: false },
      { id: 'v2', slot: 'Dîner', title: 'Pizza maison', emoji: '🍕', time: 45, noPurchase: false, confirmed: false },
    ],
  },
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
