import React, { createContext, useContext, useMemo, useState, useCallback, useEffect } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { initialPantry, PantryItem, Cuisine, PurchaseRule } from '../services/mockData';

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
const STORAGE_KEY = 'menoo:onboarding:v2';

export function MenooProvider({ children }: { children: React.ReactNode }) {
  const [pantry, setPantry] = useState<PantryItem[]>(initialPantry);
  const [meal, setMealState] = useState<MealChoice>({
    people: 2,
    meals: 1,
    cuisine: 'italienne',
    purchaseRule: 'none',
  });
  const [cooked, setCooked] = useState(false);

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
        const raw = await AsyncStorage.getItem(STORAGE_KEY);
        if (raw) {
          const s = JSON.parse(raw);
          if (s.parcours !== undefined) setParcoursState(s.parcours);
          if (typeof s.currentStep === 'number') setCurrentStep(s.currentStep);
          if (s.answers) setAnswers({ 'pour-moi': {}, 'pour-famille': {}, ...s.answers });
        }
      } catch {}
      setHydrated(true);
    })();
  }, []);

  useEffect(() => {
    if (!hydrated) return;
    AsyncStorage.setItem(
      STORAGE_KEY,
      JSON.stringify({ parcours, currentStep, answers })
    ).catch(() => {});
  }, [parcours, currentStep, answers, hydrated]);

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
      parcours, setParcours,
      currentStep, setCurrentStep,
      answers, setAnswer, resetOnboarding,
      hydrated,
    }),
    [pantry, setPantryItem, applyRecipeConsumption, resetPantry, meal, setMeal, cooked, parcours, currentStep, answers, setAnswer, resetOnboarding, hydrated, setParcours]
  );

  return <MenooContext.Provider value={value}>{children}</MenooContext.Provider>;
}

export function useMenoo() {
  const ctx = useContext(MenooContext);
  if (!ctx) throw new Error('useMenoo must be used within MenooProvider');
  return ctx;
}
