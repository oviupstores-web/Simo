import React, { createContext, useContext, useMemo, useState, useCallback, useEffect } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { initialPantry, PantryItem, Cuisine, PurchaseRule, MealOverride } from '../services/mockData';
import { getRecipe } from '../services/recipes';

interface MealChoice {
  people: number;
  meals: number;
  cuisine: Cuisine;
  purchaseRule: PurchaseRule;
}

export type ParcoursType = 'pour-moi' | 'pour-famille';

interface MenooState {
  pantry: PantryItem[];
  setPantryItem: (id: string, patch: Partial<PantryItem>) => void;
  applyRecipeConsumption: (consumption: Record<string, number>) => void;
  resetPantry: () => void;
  meal: MealChoice;
  setMeal: (patch: Partial<MealChoice>) => void;
  cooked: boolean;
  setCooked: (v: boolean) => void;
  // Menu de la semaine (post-onboarding)
  weekOverrides: Record<string, MealOverride>;
  swapMeal: (id: string, next: MealOverride) => void;
  confirmedMeals: Record<string, boolean>;
  confirmMeal: (id: string) => void;
  regenerateWeek: () => void;
  weekVersion: number;
  purchased: Record<string, boolean>;
  togglePurchased: (id: string) => void;
  pinned: Record<string, boolean>; // key = recipeId stable
  togglePinned: (recipeId: string) => void;
  voiceEnabled: boolean;
  setVoiceEnabled: (v: boolean) => void;
  // Onboarding 12-step (per organigramme v1)
  parcours: ParcoursType | null;
  setParcours: (v: ParcoursType | null) => void;
  currentStep: number; // 1..12
  setCurrentStep: (n: number) => void;
  answers: Record<ParcoursType, Record<string, any>>;
  setAnswer: (type: ParcoursType, key: string, value: any) => void;
  resetOnboarding: () => void;
  hydrated: boolean;
}

const MenooContext = createContext<MenooState | null>(null);
const STORAGE_KEY = 'menoo:storage:v3';
const LEGACY_STORAGE_KEY = 'menoo:onboarding:v2';

type JsonRecord = Record<string, unknown>;

function isRecord(value: unknown): value is JsonRecord {
  return typeof value === 'object' && value !== null && !Array.isArray(value);
}

function booleanRecord(value: unknown): Record<string, boolean> {
  if (!isRecord(value)) return {};
  return Object.fromEntries(
    Object.entries(value).filter((entry): entry is [string, boolean] => typeof entry[1] === 'boolean')
  );
}

function sanitizedPantry(value: unknown): PantryItem[] {
  if (!Array.isArray(value)) return initialPantry;

  const savedById = new Map(
    value
      .filter(isRecord)
      .filter((item) => typeof item.id === 'string')
      .map((item) => [item.id as string, item])
  );

  return initialPantry.map((fallback) => {
    const saved = savedById.get(fallback.id);
    const available = saved?.available;
    if (typeof available !== 'number' || !Number.isFinite(available)) return fallback;
    return { ...fallback, available: Math.max(0, Math.min(fallback.containerSize, available)) };
  });
}

function sanitizedMeal(value: unknown): MealChoice | null {
  if (!isRecord(value)) return null;
  const cuisines: Cuisine[] = ['italienne', 'française', 'méditerranéenne', 'asiatique'];
  const rules: PurchaseRule[] = ['none', 'one_or_two', 'anti_waste'];
  if (
    typeof value.people !== 'number' || value.people < 1 || value.people > 6 ||
    typeof value.meals !== 'number' || value.meals < 1 || value.meals > 4 ||
    !cuisines.includes(value.cuisine as Cuisine) ||
    !rules.includes(value.purchaseRule as PurchaseRule)
  ) return null;

  return {
    people: Math.floor(value.people),
    meals: Math.floor(value.meals),
    cuisine: value.cuisine as Cuisine,
    purchaseRule: value.purchaseRule as PurchaseRule,
  };
}

function sanitizedOverrides(value: unknown): Record<string, MealOverride> {
  if (!isRecord(value)) return {};
  const result: Record<string, MealOverride> = {};

  for (const [mealId, raw] of Object.entries(value)) {
    if (
      !isRecord(raw) ||
      typeof raw.recipeId !== 'string' ||
      !getRecipe(raw.recipeId) ||
      typeof raw.emoji !== 'string' ||
      typeof raw.noPurchase !== 'boolean'
    ) continue;

    result[mealId] = {
      recipeId: raw.recipeId,
      emoji: raw.emoji,
      noPurchase: raw.noPurchase,
    };
  }

  return result;
}

function sanitizedPinned(value: unknown): Record<string, boolean> {
  return Object.fromEntries(
    Object.entries(booleanRecord(value)).filter(([recipeId]) => getRecipe(recipeId) !== null)
  );
}

function sanitizedAnswers(value: unknown): Record<ParcoursType, Record<string, any>> {
  const empty = { 'pour-moi': {}, 'pour-famille': {} };
  if (!isRecord(value)) return empty;
  return {
    'pour-moi': isRecord(value['pour-moi']) ? value['pour-moi'] : {},
    'pour-famille': isRecord(value['pour-famille']) ? value['pour-famille'] : {},
  };
}

export function MenooProvider({ children }: { children: React.ReactNode }) {
  const [pantry, setPantry] = useState<PantryItem[]>(initialPantry);
  const [meal, setMealState] = useState<MealChoice>({
    people: 2,
    meals: 1,
    cuisine: 'italienne',
    purchaseRule: 'none',
  });
  const [cooked, setCooked] = useState(false);

  const [weekOverrides, setWeekOverrides] = useState<Record<string, MealOverride>>({});
  const [confirmedMeals, setConfirmedMeals] = useState<Record<string, boolean>>({});
  const [weekVersion, setWeekVersion] = useState(1);

  const swapMeal = useCallback((id: string, next: MealOverride) => {
    setWeekOverrides((prev) => ({ ...prev, [id]: next }));
  }, []);
  const confirmMeal = useCallback((id: string) => {
    setConfirmedMeals((prev) => ({ ...prev, [id]: true }));
  }, []);
  const regenerateWeek = useCallback(() => {
    setWeekOverrides({});
    setConfirmedMeals({});
    setWeekVersion((v) => v + 1);
  }, []);

  const [purchased, setPurchased] = useState<Record<string, boolean>>({});
  const togglePurchased = useCallback((id: string) => {
    setPurchased((prev) => ({ ...prev, [id]: !prev[id] }));
  }, []);

  const [pinned, setPinned] = useState<Record<string, boolean>>({});
  const togglePinned = useCallback((recipeId: string) => {
    setPinned((prev) => ({ ...prev, [recipeId]: !prev[recipeId] }));
  }, []);

  const [voiceEnabled, setVoiceEnabled] = useState(true);

  const [parcours, setParcoursState] = useState<ParcoursType | null>(null);
  const [currentStep, setCurrentStep] = useState<number>(1);
  const [answers, setAnswers] = useState<Record<ParcoursType, Record<string, any>>>({
    'pour-moi': {},
    'pour-famille': {},
  });
  const [hydrated, setHydrated] = useState(false);

  useEffect(() => {
    (async () => {
      try {
        const current = await AsyncStorage.getItem(STORAGE_KEY);
        const legacy = current ? null : await AsyncStorage.getItem(LEGACY_STORAGE_KEY);
        const raw = current ?? legacy;
        if (raw) {
          const parsed: unknown = JSON.parse(raw);
          if (isRecord(parsed)) {
            const savedMeal = sanitizedMeal(parsed.meal);
            if (savedMeal) setMealState(savedMeal);
            setPantry(sanitizedPantry(parsed.pantry));
            setCooked(typeof parsed.cooked === 'boolean' ? parsed.cooked : false);
            setWeekOverrides(sanitizedOverrides(parsed.weekOverrides));
            setConfirmedMeals(booleanRecord(parsed.confirmedMeals));
            setWeekVersion(
              typeof parsed.weekVersion === 'number' && parsed.weekVersion >= 1
                ? Math.floor(parsed.weekVersion)
                : 1
            );
            setPurchased(booleanRecord(parsed.purchased));
            setPinned(sanitizedPinned(parsed.pinned));
            setVoiceEnabled(typeof parsed.voiceEnabled === 'boolean' ? parsed.voiceEnabled : true);
            if (parsed.parcours === null || parsed.parcours === 'pour-moi' || parsed.parcours === 'pour-famille') {
              setParcoursState(parsed.parcours);
            }
            if (typeof parsed.currentStep === 'number') {
              setCurrentStep(Math.max(1, Math.min(12, Math.floor(parsed.currentStep))));
            }
            setAnswers(sanitizedAnswers(parsed.answers));
          }
        }
      } catch {
        // Une sauvegarde corrompue ne doit jamais empêcher l'application de démarrer.
      } finally {
        setHydrated(true);
      }
    })();
  }, []);

  useEffect(() => {
    if (!hydrated) return;
    AsyncStorage.setItem(
      STORAGE_KEY,
      JSON.stringify({
        version: 3,
        pantry,
        meal,
        cooked,
        weekOverrides,
        confirmedMeals,
        weekVersion,
        purchased,
        pinned,
        voiceEnabled,
        parcours,
        currentStep,
        answers,
      })
    ).catch(() => {});
  }, [
    pantry, meal, cooked, weekOverrides, confirmedMeals, weekVersion,
    purchased, pinned, voiceEnabled, parcours, currentStep, answers, hydrated,
  ]);

  const setPantryItem = useCallback((id: string, patch: Partial<PantryItem>) => {
    setPantry((prev) => prev.map((p) => (p.id === id ? { ...p, ...patch } : p)));
  }, []);

  const applyRecipeConsumption = useCallback((consumption: Record<string, number>) => {
    setPantry((prev) =>
      prev.map((p) => {
        const consumed = consumption[p.id] ?? 0;
        return { ...p, available: Math.max(0, p.available - consumed) };
      })
    );
  }, []);

  const resetPantry = useCallback(() => {
    setPantry(initialPantry);
    setCooked(false);
  }, []);

  const setMeal = useCallback((patch: Partial<MealChoice>) => {
    setMealState((prev) => ({ ...prev, ...patch }));
  }, []);

  const setParcours = useCallback((v: ParcoursType | null) => setParcoursState(v), []);

  const setAnswer = useCallback((type: ParcoursType, key: string, value: any) => {
    setAnswers((prev) => ({ ...prev, [type]: { ...prev[type], [key]: value } }));
  }, []);

  const resetOnboarding = useCallback(() => {
    setParcoursState(null);
    setCurrentStep(1);
    setAnswers({ 'pour-moi': {}, 'pour-famille': {} });
  }, []);

  const value = useMemo(
    () => ({
      pantry, setPantryItem, applyRecipeConsumption, resetPantry,
      meal, setMeal, cooked, setCooked,
      weekOverrides, swapMeal, confirmedMeals, confirmMeal, regenerateWeek, weekVersion,
      purchased, togglePurchased, pinned, togglePinned, voiceEnabled, setVoiceEnabled,
      parcours, setParcours,
      currentStep, setCurrentStep,
      answers, setAnswer, resetOnboarding,
      hydrated,
    }),
    [pantry, setPantryItem, applyRecipeConsumption, resetPantry, meal, setMeal, cooked, weekOverrides, swapMeal, confirmedMeals, confirmMeal, regenerateWeek, weekVersion, purchased, togglePurchased, pinned, togglePinned, voiceEnabled, parcours, currentStep, answers, setAnswer, resetOnboarding, hydrated, setParcours]
  );

  return <MenooContext.Provider value={value}>{hydrated ? children : null}</MenooContext.Provider>;
}

export function useMenoo() {
  const ctx = useContext(MenooContext);
  if (!ctx) throw new Error('useMenoo must be used within MenooProvider');
  return ctx;
}
