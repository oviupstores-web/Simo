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

const IMG = {
  // Images alignées avec le nom de la recette (Unsplash).
  granola: 'https://images.unsplash.com/photo-1490474418585-ba9bad8fd0ea?w=600&q=70', // bowl granola & fruits
  toastMiel: 'https://images.unsplash.com/photo-1484723091739-30a097e8f929?w=600&q=70', // tartines
  yaourtFruits: 'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=600&q=70', // yaourt fruits
  pancakes: 'https://images.unsplash.com/photo-1528207776546-365bb710ee93?w=600&q=70', // pancakes
  pasta: 'https://images.unsplash.com/photo-1621996346565-e3dbc353d2e5?w=600&q=70', // pâtes crémeuses champignons
  soup: 'https://images.unsplash.com/photo-1547592180-85f173990554?w=600&q=70', // soupe légumes rôtis
  saladRice: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=600&q=70', // salade
  omelette: 'https://images.unsplash.com/photo-1510693206972-df098062cb71?w=600&q=70', // omelette
  chicken: 'https://images.unsplash.com/photo-1598103442097-8b74394b95c6?w=600&q=70', // poulet rôti
  risotto: 'https://images.unsplash.com/photo-1476124369491-e7addf5db371?w=600&q=70', // risotto champignons
  medBowl: 'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=600&q=70', // bol méditerranéen
  curry: 'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=600&q=70', // curry lentilles
  wrap: 'https://images.unsplash.com/photo-1626700051175-6818013e1d4f?w=600&q=70', // wrap
  pizza: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=600&q=70', // pizza
  tarte: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600&q=70', // tarte légumes
  fish: 'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=600&q=70', // poisson grillé
};

export const weeklyPlan: DayPlan[] = [
  {
    day: 'Lun',
    meals: [
      { id: 'lun-pd', slot: 'Petit-déj', title: 'Bowl fruits & granola', emoji: '🥣', image: IMG.granola, time: 8, price: 2.10, noPurchase: true, confirmed: true },
      { id: 'lun-dej', slot: 'Déjeuner', title: 'Pâtes crémeuses aux champignons', emoji: '🍝', image: IMG.pasta, time: 22, price: 3.40, noPurchase: true, confirmed: true },
      { id: 'lun-din', slot: 'Dîner', title: 'Soupe de légumes rôtis', emoji: '🥣', image: IMG.soup, time: 30, price: 2.80, noPurchase: true, confirmed: true },
    ],
  },
  {
    day: 'Mar',
    meals: [
      { id: 'mar-pd', slot: 'Petit-déj', title: 'Tartines pain complet & miel', emoji: '🍞', image: IMG.toastMiel, time: 5, price: 1.20, noPurchase: true, confirmed: true },
      { id: 'mar-dej', slot: 'Déjeuner', title: 'Salade de riz croquant', emoji: '🥗', image: IMG.saladRice, time: 15, price: 3.10, noPurchase: false, confirmed: true },
      { id: 'mar-din', slot: 'Dîner', title: 'Omelette aux herbes', emoji: '🍳', image: IMG.omelette, time: 12, price: 1.80, noPurchase: true, confirmed: false },
    ],
  },
  {
    day: 'Mer',
    meals: [
      { id: 'mer-pd', slot: 'Petit-déj', title: 'Yaourt & fruits frais', emoji: '🍓', image: IMG.yaourtFruits, time: 5, price: 1.60, noPurchase: true, confirmed: false },
      { id: 'mer-dej', slot: 'Déjeuner', title: 'Poulet rôti & haricots verts', emoji: '🍗', image: IMG.chicken, time: 40, price: 4.80, noPurchase: false, confirmed: false },
      { id: 'mer-din', slot: 'Dîner', title: 'Risotto aux champignons', emoji: '🍚', image: IMG.risotto, time: 35, price: 3.20, noPurchase: true, confirmed: false },
    ],
  },
  {
    day: 'Jeu',
    meals: [
      { id: 'jeu-pd', slot: 'Petit-déj', title: 'Bowl fruits & granola', emoji: '🥣', image: IMG.granola, time: 8, price: 2.10, noPurchase: true, confirmed: false },
      { id: 'jeu-dej', slot: 'Déjeuner', title: 'Bol méditerranéen', emoji: '🫒', image: IMG.medBowl, time: 20, price: 3.60, noPurchase: false, confirmed: false },
      { id: 'jeu-din', slot: 'Dîner', title: 'Curry de lentilles', emoji: '🍛', image: IMG.curry, time: 30, price: 2.90, noPurchase: false, confirmed: false },
    ],
  },
  {
    day: 'Ven',
    meals: [
      { id: 'ven-pd', slot: 'Petit-déj', title: 'Tartines pain complet & miel', emoji: '🍞', image: IMG.toastMiel, time: 5, price: 1.20, noPurchase: true, confirmed: false },
      { id: 'ven-dej', slot: 'Déjeuner', title: 'Wrap poulet-avocat', emoji: '🌯', image: IMG.wrap, time: 15, price: 3.80, noPurchase: false, confirmed: false },
      { id: 'ven-din', slot: 'Dîner', title: 'Pizza maison', emoji: '🍕', image: IMG.pizza, time: 45, price: 4.20, noPurchase: false, confirmed: false },
    ],
  },
  {
    day: 'Sam',
    meals: [
      { id: 'sam-pd', slot: 'Petit-déj', title: 'Pancakes légers', emoji: '🥞', image: IMG.pancakes, time: 15, price: 1.90, noPurchase: false, confirmed: false },
      { id: 'sam-dej', slot: 'Déjeuner', title: 'Tarte aux légumes du soleil', emoji: '🥧', image: IMG.tarte, time: 40, price: 3.90, noPurchase: false, confirmed: false },
      { id: 'sam-din', slot: 'Dîner', title: 'Poisson grillé & légumes', emoji: '🐟', image: IMG.fish, time: 25, price: 5.10, noPurchase: false, confirmed: false },
    ],
  },
  {
    day: 'Dim',
    meals: [
      { id: 'dim-pd', slot: 'Petit-déj', title: 'Yaourt & fruits frais', emoji: '🍓', image: IMG.yaourtFruits, time: 5, price: 1.60, noPurchase: true, confirmed: false },
      { id: 'dim-dej', slot: 'Déjeuner', title: 'Poulet rôti dominical', emoji: '🍗', image: IMG.chicken, time: 60, price: 5.30, noPurchase: false, confirmed: false },
      { id: 'dim-din', slot: 'Dîner', title: 'Soupe légère', emoji: '🥣', image: IMG.soup, time: 20, price: 2.40, noPurchase: true, confirmed: false },
    ],
  },
];

// Alternatives pour swap 1-tap (3 propositions par repas — même slot)
export const swapAlternatives: { title: string; emoji: string; image: string; time: number; price: number; noPurchase: boolean }[] = [
  { title: 'Salade tiède quinoa & légumes', emoji: '🥗', image: IMG.saladRice, time: 18, price: 3.20, noPurchase: true },
  { title: 'Wok de nouilles aux légumes', emoji: '🍜', image: IMG.risotto, time: 15, price: 2.80, noPurchase: false },
  { title: 'Gratin de courgettes', emoji: '🥘', image: IMG.tarte, time: 35, price: 3.10, noPurchase: false },
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
