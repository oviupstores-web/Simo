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
