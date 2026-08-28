// Parcours « Pour moi » — 12 étapes interactives (organigramme Menoo v1)
import React from "react";
import { View, Text, StyleSheet, TextInput, Pressable } from "react-native";
import { Ionicons } from "@expo/vector-icons";
import { useMenoo } from "../store/menoo";
import { colors, radius, spacing, typography, shadow } from "../theme/tokens";
import { ChipMulti, ChipSingle } from "../components/Chip";
import Counter from "../components/Counter";
import PrimaryButton from "../components/PrimaryButton";

// -- Helpers -----------------------------------------------------------------

function useMoi<T = any>(key: string, fallback: T): [T, (v: T) => void] {
  const { answers, setAnswer } = useMenoo();
  const value = (answers["pour-moi"]?.[key] as T) ?? fallback;
  const set = (v: T) => setAnswer("pour-moi", key, v);
  return [value, set];
}

function Card({ children }: { children: React.ReactNode }) {
  return <View style={styles.card}>{children}</View>;
}

function Label({ children }: { children: React.ReactNode }) {
  return <Text style={styles.label}>{children}</Text>;
}
function Hint({ children }: { children: React.ReactNode }) {
  return <Text style={styles.hint}>{children}</Text>;
}

// -- Step 1 : Mon objectif ---------------------------------------------------

const OBJECTIFS = [
  { id: "poids-perdre", label: "Perdre du poids", emoji: "⚖️" },
  { id: "masse", label: "Prendre de la masse", emoji: "💪" },
  { id: "seche", label: "Faire une sèche", emoji: "🔥" },
  { id: "equilibre", label: "Rester en équilibre", emoji: "🌿" },
];
function Step1() {
  const [v, set] = useMoi<string | null>("objectif", null);
  return (
    <Card>
      <Label>Quel est votre objectif principal ?</Label>
      <Hint>Modifiable à tout moment.</Hint>
      <View style={{ height: spacing.sm }} />
      <ChipSingle options={OBJECTIFS} value={v} onSelect={set} testIDPrefix="moi-objectif" />
    </Card>
  );
}

// -- Step 2 : Mon profil -----------------------------------------------------

const SEXES = [
  { id: "femme", label: "Femme", emoji: "♀️" },
  { id: "homme", label: "Homme", emoji: "♂️" },
  { id: "autre", label: "Autre", emoji: "✨" },
];
function Step2() {
  const [profil, set] = useMoi<any>("profil", { age: 30, sexe: null, taille: 170, poids: 70, poidsCible: "" });
  const upd = (patch: any) => set({ ...profil, ...patch });
  return (
    <View>
      <Card>
        <View style={styles.rowBetween}>
          <View style={{ flex: 1 }}>
            <Label>Âge</Label>
            <Hint>En années.</Hint>
          </View>
          <Counter value={profil.age ?? 30} min={16} max={99} onChange={(v) => upd({ age: v })} testID="moi-age" />
        </View>
      </Card>
      <Card>
        <Label>Sexe</Label>
        <View style={{ height: spacing.sm }} />
        <ChipSingle options={SEXES} value={profil.sexe} onSelect={(v) => upd({ sexe: v })} testIDPrefix="moi-sexe" />
      </Card>
      <Card>
        <View style={styles.rowBetween}>
          <View style={{ flex: 1 }}>
            <Label>Taille (cm)</Label>
          </View>
          <TextInput
            testID="moi-taille"
            keyboardType="number-pad"
            value={String(profil.taille ?? "")}
            onChangeText={(t) => upd({ taille: Number(t.replace(/[^0-9]/g, "")) || 0 })}
            style={styles.numInput}
          />
        </View>
      </Card>
      <Card>
        <View style={styles.rowBetween}>
          <View style={{ flex: 1 }}>
            <Label>Poids actuel (kg)</Label>
          </View>
          <TextInput
            testID="moi-poids"
            keyboardType="number-pad"
            value={String(profil.poids ?? "")}
            onChangeText={(t) => upd({ poids: Number(t.replace(/[^0-9.]/g, "")) || 0 })}
            style={styles.numInput}
          />
        </View>
      </Card>
      <Card>
        <View style={styles.rowBetween}>
          <View style={{ flex: 1 }}>
            <Label>Poids visé (kg)</Label>
            <Hint>Facultatif.</Hint>
          </View>
          <TextInput
            testID="moi-poids-cible"
            keyboardType="number-pad"
            placeholder="—"
            placeholderTextColor={colors.muted}
            value={String(profil.poidsCible ?? "")}
            onChangeText={(t) => upd({ poidsCible: t.replace(/[^0-9.]/g, "") })}
            style={styles.numInput}
          />
        </View>
      </Card>
    </View>
  );
}

// -- Step 3 : Mon activité ---------------------------------------------------

const ACTIVITES = [
  { id: "sedentaire", label: "Sédentaire", emoji: "🪑" },
  { id: "peu", label: "Peu actif", emoji: "🚶" },
  { id: "modere", label: "Modéré", emoji: "🚴" },
  { id: "actif", label: "Actif", emoji: "🏃" },
  { id: "tres-actif", label: "Très actif", emoji: "🔥" },
];
function Step3() {
  const [v, set] = useMoi<string | null>("activite", null);
  return (
    <Card>
      <Label>Votre niveau d'activité physique</Label>
      <View style={{ height: spacing.sm }} />
      <ChipSingle options={ACTIVITES} value={v} onSelect={set} testIDPrefix="moi-activite" />
    </Card>
  );
}

// -- Step 4 : Rythme et repères ---------------------------------------------

const RYTHMES = [
  { id: "progressif", label: "Progressif", emoji: "🌱" },
  { id: "soutenu", label: "Plus soutenu", emoji: "⚡" },
];
const NUTRIENTS = ["Énergie", "Protéines", "Glucides", "Lipides", "Fibres"];
function Step4() {
  const [rythme, setR] = useMoi<string | null>("rythme", "progressif");
  const [reperes, setRep] = useMoi<Record<string, number>>("reperes", {
    Énergie: 2, Protéines: 2, Glucides: 2, Lipides: 2, Fibres: 2,
  });
  return (
    <View>
      <Card>
        <Label>Votre rythme</Label>
        <View style={{ height: spacing.sm }} />
        <ChipSingle options={RYTHMES} value={rythme} onSelect={setR} testIDPrefix="moi-rythme" />
      </Card>
      <Card>
        <Label>Repères informatifs</Label>
        <Hint>Non médicaux. De 1 (bas) à 3 (élevé).</Hint>
        <View style={{ height: spacing.sm }} />
        {NUTRIENTS.map((n) => (
          <View key={n} style={styles.rowBetween}>
            <Text style={styles.subLabel}>{n}</Text>
            <Counter
              value={reperes[n] ?? 2}
              min={1}
              max={3}
              onChange={(v) => setRep({ ...reperes, [n]: v })}
              testID={`moi-repere-${n.toLowerCase()}`}
            />
          </View>
        ))}
      </Card>
    </View>
  );
}

// -- Step 5 : Repas de la semaine -------------------------------------------

const MEAL_TYPES = ["Petit-déjeuner", "Déjeuner", "Dîner", "Collation"];
const DAYS = ["Lun", "Mar", "Mer", "Jeu", "Ven", "Sam", "Dim"];

function Step5() {
  const [meals, setMeals] = useMoi<Record<string, number>>("repas", {
    "Petit-déjeuner": 0, "Déjeuner": 5, "Dîner": 5, "Collation": 0,
  });
  const [days, setDays] = useMoi<string[]>("jours", ["Lun", "Mar", "Mer", "Jeu", "Ven"]);
  const toggleDay = (d: string) =>
    setDays(days.includes(d) ? days.filter((x) => x !== d) : [...days, d]);
  const total = Object.values(meals).reduce((a, b) => a + b, 0);
  return (
    <View>
      <Card>
        <Label>Repas par jour</Label>
        <View style={{ height: spacing.sm }} />
        {MEAL_TYPES.map((m) => (
          <View key={m} style={[styles.rowBetween, { paddingVertical: 6 }]}>
            <Text style={styles.subLabel}>{m}</Text>
            <Counter
              value={meals[m] ?? 0}
              min={0}
              max={7}
              onChange={(v) => setMeals({ ...meals, [m]: v })}
              testID={`moi-meal-${m}`}
            />
          </View>
        ))}
        <Text style={[styles.hint, { marginTop: 8 }]}>Total : {total} repas / semaine (indicatif)</Text>
      </Card>
      <Card>
        <Label>Jours à planifier</Label>
        <View style={{ height: spacing.sm }} />
        <View style={styles.daysRow}>
          {DAYS.map((d) => {
            const active = days.includes(d);
            return (
              <Pressable
                key={d}
                testID={`moi-day-${d}`}
                onPress={() => toggleDay(d)}
                style={[styles.dayChip, active && styles.dayChipActive]}
              >
                <Text style={[styles.dayText, active && styles.dayTextActive]}>{d}</Text>
              </Pressable>
            );
          })}
        </View>
      </Card>
    </View>
  );
}

// -- Step 6 : Budget --------------------------------------------------------

const BUDGET_PERIODS = [
  { id: "semaine", label: "Par semaine", emoji: "📅" },
  { id: "jour", label: "Par jour", emoji: "☀️" },
  { id: "repas", label: "Par repas", emoji: "🍽️" },
];
function Step6() {
  const [period, setPeriod] = useMoi<string>("budgetPeriod", "semaine");
  const [amount, setAmount] = useMoi<number>("budgetAmount", 60);
  return (
    <View>
      <Card>
        <Label>Fréquence du budget</Label>
        <View style={{ height: spacing.sm }} />
        <ChipSingle options={BUDGET_PERIODS} value={period} onSelect={setPeriod} testIDPrefix="moi-budget-period" />
      </Card>
      <Card>
        <View style={styles.rowBetween}>
          <View style={{ flex: 1 }}>
            <Label>Montant (€)</Label>
            <Hint>Menoo convertit en interne selon vos repas.</Hint>
          </View>
          <TextInput
            testID="moi-budget-amount"
            keyboardType="number-pad"
            value={String(amount ?? "")}
            onChangeText={(t) => setAmount(Number(t.replace(/[^0-9]/g, "")) || 0)}
            style={styles.numInput}
          />
        </View>
      </Card>
    </View>
  );
}

// -- Step 7 : Courses et/ou réserves ----------------------------------------

const STORES = [
  "Carrefour", "E.Leclerc", "Intermarché", "Auchan", "Lidl",
  "Aldi", "Monoprix", "Grand Frais", "Biocoop",
].map((s) => ({ id: s, label: s }));

const MODES = [
  { id: "courses", label: "Courses uniquement", emoji: "🛒" },
  { id: "reserves", label: "Réserves uniquement", emoji: "🥫" },
  { id: "mixte", label: "Mixte", emoji: "🔄" },
];
function Step7({ onOpenPantry }: { onOpenPantry: () => void }) {
  const [mode, setMode] = useMoi<string>("mode", "courses");
  const [stores, setStores] = useMoi<string[]>("stores", ["Carrefour"]);
  const [cp, setCp] = useMoi<string>("codePostal", "");
  const toggle = (id: string) =>
    setStores(stores.includes(id) ? stores.filter((x) => x !== id) : [...stores, id]);
  const showReserves = mode === "reserves" || mode === "mixte";
  return (
    <View>
      <Card>
        <Label>Choix du mode</Label>
        <Hint>Vous pouvez tout modifier plus tard.</Hint>
        <View style={{ height: spacing.sm }} />
        <ChipSingle options={MODES} value={mode} onSelect={setMode} testIDPrefix="moi-mode" />
      </Card>
      <Card>
        <Label>Magasins préférés</Label>
        <View style={{ height: spacing.sm }} />
        <ChipMulti options={STORES} values={stores} onToggle={toggle} testIDPrefix="moi-store" />
        <View style={{ height: spacing.md }} />
        <Label>Code postal</Label>
        <TextInput
          testID="moi-cp"
          keyboardType="number-pad"
          value={cp}
          onChangeText={(t) => setCp(t.replace(/[^0-9]/g, "").slice(0, 5))}
          placeholder="75001"
          placeholderTextColor={colors.muted}
          style={styles.textInput}
        />
      </Card>
      {showReserves && (
        <Card>
          <Label>Mes réserves</Label>
          <Hint>Écrire, parler, photo, ticket ou code-barres.</Hint>
          <View style={{ height: spacing.sm }} />
          <PrimaryButton
            testID="btn-open-input"
            label="Ajouter mes réserves"
            variant="secondary"
            onPress={onOpenPantry}
            icon={<Ionicons name="basket-outline" size={18} color={colors.onBrandSecondary} />}
          />
        </Card>
      )}
    </View>
  );
}

// -- Step 8 : Régime alimentaire -------------------------------------------

export const DIETS = [
  { id: "omnivore", label: "Omnivore", emoji: "🍽️" },
  { id: "flexi", label: "Flexitarien", emoji: "🌾" },
  { id: "vegetarien", label: "Végétarien", emoji: "🥬" },
  { id: "vegan", label: "Végan", emoji: "🌱" },
  { id: "pesco", label: "Pescetarien", emoji: "🐟" },
  { id: "sans-porc", label: "Sans porc", emoji: "🚫" },
  { id: "halal", label: "Halal", emoji: "🌙" },
];
function Step8() {
  const [v, set] = useMoi<string | null>("regime", null);
  return (
    <Card>
      <Label>Votre régime alimentaire</Label>
      <View style={{ height: spacing.sm }} />
      <ChipSingle options={DIETS} value={v} onSelect={set} testIDPrefix="moi-regime" />
    </Card>
  );
}

// -- Step 9 : Allergies -----------------------------------------------------

export const ALLERGIES = [
  { id: "gluten", label: "Gluten", emoji: "🌾" },
  { id: "lactose", label: "Lait/lactose", emoji: "🥛" },
  { id: "oeuf", label: "Œuf", emoji: "🥚" },
  { id: "arachide", label: "Arachide", emoji: "🥜" },
  { id: "fruits-coque", label: "Fruits à coque", emoji: "🌰" },
  { id: "poisson", label: "Poisson", emoji: "🐟" },
  { id: "crustaces", label: "Crustacés", emoji: "🦐" },
  { id: "soja", label: "Soja", emoji: "🫘" },
  { id: "sesame", label: "Sésame", emoji: "◽" },
];
function Step9() {
  const [v, set] = useMoi<string[]>("allergies", []);
  const toggle = (id: string) => set(v.includes(id) ? v.filter((x) => x !== id) : [...v, id]);
  return (
    <Card>
      <Label>Sélectionnez ce qui doit être évité</Label>
      <Hint>Rien à signaler ? Passez au suivant.</Hint>
      <View style={{ height: spacing.sm }} />
      <ChipMulti options={ALLERGIES} values={v} onToggle={toggle} testIDPrefix="moi-allergy" />
    </Card>
  );
}

// -- Step 10 : Goûts + cuisines --------------------------------------------

export const TASTES = [
  { id: "epice", label: "Épicé", emoji: "🌶️" },
  { id: "sucre", label: "Sucré", emoji: "🍯" },
  { id: "acidule", label: "Acidulé", emoji: "🍋" },
  { id: "fume", label: "Fumé", emoji: "🔥" },
  { id: "champignons", label: "Champignons", emoji: "🍄" },
  { id: "legumes", label: "Légumes", emoji: "🥦" },
  { id: "poisson", label: "Poisson", emoji: "🐟" },
  { id: "viande", label: "Viande", emoji: "🥩" },
  { id: "pates", label: "Pâtes", emoji: "🍝" },
  { id: "riz", label: "Riz", emoji: "🍚" },
];
export const CUISINES = [
  { id: "mediterraneenne", label: "Méditerranéenne", emoji: "🫒" },
  { id: "marocaine", label: "Marocaine", emoji: "🥘" },
  { id: "italienne", label: "Italienne", emoji: "🇮🇹" },
  { id: "francaise", label: "Française", emoji: "🇫🇷" },
  { id: "asiatique", label: "Asiatique", emoji: "🥢" },
  { id: "indienne", label: "Indienne", emoji: "🍛" },
  { id: "mexicaine", label: "Mexicaine", emoji: "🌮" },
  { id: "orientale", label: "Orientale", emoji: "🌯" },
  { id: "africaine", label: "Africaine", emoji: "🍲" },
  { id: "decouverte", label: "Découverte", emoji: "✨" },
];
function Step10() {
  const [likes, setLikes] = useMoi<string[]>("likes", []);
  const [dislikes, setDislikes] = useMoi<string[]>("dislikes", []);
  const [cuisinesLike, setCu] = useMoi<string[]>("cuisines", []);
  const [cuisinesDis, setCuDis] = useMoi<string[]>("cuisinesDislike", []);
  const toggleExcl = (id: string, list: string[], setL: (v: string[]) => void, otherList: string[], setOther: (v: string[]) => void) => {
    const active = list.includes(id);
    setL(active ? list.filter((x) => x !== id) : [...list, id]);
    if (!active && otherList.includes(id)) setOther(otherList.filter((x) => x !== id));
  };
  return (
    <View>
      <Card>
        <Label>J'aime — ingrédients</Label>
        <View style={{ height: spacing.sm }} />
        <ChipMulti options={TASTES} values={likes} onToggle={(id) => toggleExcl(id, likes, setLikes, dislikes, setDislikes)} testIDPrefix="moi-likes" />
      </Card>
      <Card>
        <Label>Je n'aime pas — ingrédients</Label>
        <View style={{ height: spacing.sm }} />
        <ChipMulti options={TASTES} values={dislikes} onToggle={(id) => toggleExcl(id, dislikes, setDislikes, likes, setLikes)} testIDPrefix="moi-dislikes" />
      </Card>
      <Card>
        <Label>J'aime — cuisines</Label>
        <View style={{ height: spacing.sm }} />
        <ChipMulti options={CUISINES} values={cuisinesLike} onToggle={(id) => toggleExcl(id, cuisinesLike, setCu, cuisinesDis, setCuDis)} testIDPrefix="moi-cuisine-like" />
      </Card>
      <Card>
        <Label>Je n'aime pas — cuisines</Label>
        <View style={{ height: spacing.sm }} />
        <ChipMulti options={CUISINES} values={cuisinesDis} onToggle={(id) => toggleExcl(id, cuisinesDis, setCuDis, cuisinesLike, setCu)} testIDPrefix="moi-cuisine-dislike" />
      </Card>
    </View>
  );
}

// -- Step 11 : Organisation -------------------------------------------------

export const EQUIPMENT = [
  { id: "plaques", label: "Plaques", emoji: "🍳" },
  { id: "four", label: "Four", emoji: "♨️" },
  { id: "microondes", label: "Micro-ondes", emoji: "📟" },
  { id: "airfryer", label: "Air fryer", emoji: "💨" },
  { id: "robot", label: "Robot", emoji: "🤖" },
  { id: "blender", label: "Blender", emoji: "🌀" },
  { id: "cocotte", label: "Cocotte", emoji: "🍲" },
  { id: "vapeur", label: "Vapeur", emoji: "☁️" },
  { id: "barbecue", label: "Barbecue", emoji: "🔥" },
];
const NIVEAUX = [
  { id: "debutant", label: "Débutant", emoji: "🌱" },
  { id: "intermediaire", label: "Intermédiaire", emoji: "👍" },
  { id: "avance", label: "Avancé", emoji: "⭐" },
];
export const RESTES = [
  { id: "lendemain", label: "Lendemain", emoji: "🍱" },
  { id: "congelation", label: "Congélation", emoji: "❄️" },
  { id: "nouvelle-recette", label: "Nouvelle recette", emoji: "✨" },
];
function Step11() {
  const [equipment, setEq] = useMoi<string[]>("equipment", ["plaques", "four"]);
  const [tempsSem, setTS] = useMoi<number>("tempsSemaine", 30);
  const [tempsWE, setTWE] = useMoi<number>("tempsWeekEnd", 60);
  const [niveau, setN] = useMoi<string | null>("niveau", null);
  const [restes, setR] = useMoi<string[]>("restes", []);
  const toggle = (id: string, list: string[], setL: (v: string[]) => void) =>
    setL(list.includes(id) ? list.filter((x) => x !== id) : [...list, id]);
  return (
    <View>
      <Card>
        <Label>Matériel disponible</Label>
        <View style={{ height: spacing.sm }} />
        <ChipMulti options={EQUIPMENT} values={equipment} onToggle={(id) => toggle(id, equipment, setEq)} testIDPrefix="moi-equipment" />
      </Card>
      <Card>
        <View style={styles.rowBetween}>
          <View style={{ flex: 1 }}>
            <Label>Temps de cuisine — semaine (min)</Label>
          </View>
          <Counter value={tempsSem} min={5} max={120} step={5} onChange={setTS} testID="moi-temps-sem" />
        </View>
      </Card>
      <Card>
        <View style={styles.rowBetween}>
          <View style={{ flex: 1 }}>
            <Label>Temps de cuisine — week-end (min)</Label>
          </View>
          <Counter value={tempsWE} min={5} max={180} step={5} onChange={setTWE} testID="moi-temps-we" />
        </View>
      </Card>
      <Card>
        <Label>Niveau en cuisine</Label>
        <View style={{ height: spacing.sm }} />
        <ChipSingle options={NIVEAUX} value={niveau} onSelect={setN} testIDPrefix="moi-niveau" />
      </Card>
      <Card>
        <Label>Gestion des restes</Label>
        <View style={{ height: spacing.sm }} />
        <ChipMulti options={RESTES} values={restes} onToggle={(id) => toggle(id, restes, setR)} testIDPrefix="moi-restes" />
      </Card>
    </View>
  );
}

// -- Step 12 : Résumé -------------------------------------------------------

function Step12() {
  const { answers } = useMenoo();
  const a = answers["pour-moi"] ?? {};
  const line = (icon: any, label: string, value: string) => (
    <View key={label} style={styles.summaryLine}>
      <View style={styles.sumIcon}>
        <Ionicons name={icon} size={18} color={colors.brandPrimary} />
      </View>
      <View style={{ flex: 1 }}>
        <Text style={styles.sumLabel}>{label}</Text>
        <Text style={styles.sumValue}>{value}</Text>
      </View>
    </View>
  );
  const findLabel = (arr: any[], id: any) => arr.find((x) => x.id === id)?.label ?? "—";
  const joinLabels = (arr: any[], ids: string[]) =>
    ids?.length ? ids.map((i) => findLabel(arr, i)).join(", ") : "—";
  const meals = a.repas ?? {};
  const mealsTotal = Object.values<any>(meals).reduce((s: number, v: any) => s + (Number(v) || 0), 0);
  return (
    <Card>
      {line("flag-outline", "Objectif", findLabel(OBJECTIFS, a.objectif))}
      {line("body-outline", "Profil", `${a.profil?.age ?? "—"} ans · ${findLabel(SEXES, a.profil?.sexe)} · ${a.profil?.taille ?? "—"} cm · ${a.profil?.poids ?? "—"} kg`)}
      {line("walk-outline", "Activité", findLabel(ACTIVITES, a.activite))}
      {line("pulse-outline", "Rythme", findLabel(RYTHMES, a.rythme))}
      {line("calendar-outline", "Repas / semaine", `${mealsTotal} sur ${(a.jours ?? []).length} jours`)}
      {line("wallet-outline", "Budget", `${a.budgetAmount ?? "—"} € / ${a.budgetPeriod ?? "—"}`)}
      {line("storefront-outline", "Mode", findLabel(MODES, a.mode))}
      {line("nutrition-outline", "Régime", findLabel(DIETS, a.regime))}
      {line("alert-circle-outline", "Allergies", joinLabels(ALLERGIES, a.allergies ?? []))}
      {line("heart-outline", "Cuisines aimées", joinLabels(CUISINES, a.cuisines ?? []))}
      {line("hardware-chip-outline", "Matériel", joinLabels(EQUIPMENT, a.equipment ?? []))}
      {line("time-outline", "Temps semaine / WE", `${a.tempsSemaine ?? "—"} min / ${a.tempsWeekEnd ?? "—"} min`)}
    </Card>
  );
}

// -- Validation --------------------------------------------------------------

export function moiCanContinue(step: number, a: any): true | string {
  switch (step) {
    case 1: return a?.objectif ? true : "Choisissez un objectif.";
    case 2: return a?.profil?.sexe ? true : "Sélectionnez votre sexe.";
    case 3: return a?.activite ? true : "Choisissez votre niveau d'activité.";
    case 8: return a?.regime ? true : "Choisissez un régime.";
    case 11: return a?.niveau ? true : "Choisissez votre niveau en cuisine.";
    default: return true;
  }
}

// -- Router ------------------------------------------------------------------

export default function MoiStep({ step, onOpenPantry }: { step: number; onOpenPantry: () => void }) {
  switch (step) {
    case 1: return <Step1 />;
    case 2: return <Step2 />;
    case 3: return <Step3 />;
    case 4: return <Step4 />;
    case 5: return <Step5 />;
    case 6: return <Step6 />;
    case 7: return <Step7 onOpenPantry={onOpenPantry} />;
    case 8: return <Step8 />;
    case 9: return <Step9 />;
    case 10: return <Step10 />;
    case 11: return <Step11 />;
    case 12: return <Step12 />;
    default: return null;
  }
}

const styles = StyleSheet.create({
  card: {
    backgroundColor: colors.surfaceSecondary,
    borderRadius: radius.lg,
    padding: spacing.lg,
    marginBottom: spacing.md,
    ...shadow.soft,
  },
  label: { ...typography.bodyMd, color: colors.onSurface, fontWeight: "700" },
  hint: { ...typography.small, color: colors.muted, marginTop: 4 },
  subLabel: { ...typography.body, color: colors.onSurface },
  rowBetween: { flexDirection: "row", alignItems: "center", gap: spacing.md, justifyContent: "space-between" },
  numInput: {
    minWidth: 90,
    textAlign: "center",
    backgroundColor: colors.surfaceTertiary,
    borderRadius: radius.md,
    paddingHorizontal: spacing.md,
    paddingVertical: 10,
    ...typography.h3,
    color: colors.onSurface,
    borderWidth: 1,
    borderColor: colors.border,
  },
  textInput: {
    backgroundColor: colors.surfaceTertiary,
    borderRadius: radius.md,
    paddingHorizontal: spacing.md,
    paddingVertical: 10,
    ...typography.body,
    color: colors.onSurface,
    borderWidth: 1,
    borderColor: colors.border,
  },
  daysRow: { flexDirection: "row", gap: 6, flexWrap: "wrap" },
  dayChip: {
    width: 44, height: 44, borderRadius: 22,
    backgroundColor: colors.surfaceTertiary,
    borderWidth: 1.5, borderColor: "transparent",
    alignItems: "center", justifyContent: "center",
  },
  dayChipActive: { backgroundColor: colors.brandSecondaryMuted, borderColor: colors.brandPrimary },
  dayText: { ...typography.caption, color: colors.onSurfaceTertiary, fontWeight: "700" },
  dayTextActive: { color: colors.onBrandSecondary },
  summaryLine: {
    flexDirection: "row",
    gap: spacing.md,
    paddingVertical: spacing.sm,
    alignItems: "center",
    borderBottomWidth: 1,
    borderBottomColor: colors.divider,
  },
  sumIcon: {
    width: 32, height: 32, borderRadius: radius.md,
    backgroundColor: colors.brandSecondaryMuted,
    justifyContent: "center", alignItems: "center",
  },
  sumLabel: { ...typography.caption, color: colors.muted },
  sumValue: { ...typography.bodyMd, color: colors.onSurface, marginTop: 2 },
});
