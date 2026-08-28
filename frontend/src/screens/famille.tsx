// Parcours « Pour la famille » — 12 étapes interactives (organigramme Menoo v1)
import React from "react";
import { View, Text, StyleSheet, TextInput, Pressable } from "react-native";
import { Ionicons } from "@expo/vector-icons";
import { useMenoo } from "../store/menoo";
import { colors, radius, spacing, typography, shadow } from "../theme/tokens";
import { ChipMulti, ChipSingle } from "../components/Chip";
import Counter from "../components/Counter";
import PrimaryButton from "../components/PrimaryButton";
import { DIETS, ALLERGIES, TASTES, CUISINES, EQUIPMENT, RESTES } from "./moi";

export interface Member {
  id: string;
  name: string;
  type: "adulte" | "enfant" | "invite";
  age?: number;
  portion?: "petite" | "moyenne" | "grande";
  objectif?: string;
  diet?: string;
  allergies?: string[];
  likes?: string[];
  dislikes?: string[];
}

function useFam<T = any>(key: string, fallback: T): [T, (v: T) => void] {
  const { answers, setAnswer } = useMenoo();
  const value = (answers["pour-famille"]?.[key] as T) ?? fallback;
  const set = (v: T) => setAnswer("pour-famille", key, v);
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

// -- Step 1 : Notre priorité ------------------------------------------------

const PRIORITIES = [
  { id: "budget", label: "Maîtriser le budget", emoji: "💶" },
  { id: "temps", label: "Gagner du temps", emoji: "⏱️" },
  { id: "equilibre", label: "Manger équilibré", emoji: "🥗" },
  { id: "varier", label: "Varier", emoji: "🌈" },
  { id: "gaspillage", label: "Moins gaspiller", emoji: "🌱" },
  { id: "partage", label: "Partager", emoji: "🍽️" },
];
function Step1() {
  const [v, set] = useFam<string | null>("priorite", null);
  return (
    <Card>
      <Label>Priorité principale du foyer</Label>
      <Hint>Elle guide les arbitrages.</Hint>
      <View style={{ height: spacing.sm }} />
      <ChipSingle options={PRIORITIES} value={v} onSelect={set} testIDPrefix="fam-priorite" />
    </Card>
  );
}

// -- Step 2 : Qui mange à la maison -----------------------------------------

function defaultMembers(adultes: number, enfants: number, invites: number): Member[] {
  const list: Member[] = [];
  for (let i = 0; i < adultes; i++) list.push({ id: `a${i + 1}`, name: `Adulte ${i + 1}`, type: "adulte" });
  for (let i = 0; i < enfants; i++) list.push({ id: `e${i + 1}`, name: `Enfant ${i + 1}`, type: "enfant", age: 8 });
  for (let i = 0; i < invites; i++) list.push({ id: `i${i + 1}`, name: `Invité ${i + 1}`, type: "invite" });
  return list;
}

function Step2() {
  const { answers, setAnswer } = useMenoo();
  const counts = (answers["pour-famille"]?.counts as { adultes: number; enfants: number; invites: number } | undefined) ?? {
    adultes: 2, enfants: 0, invites: 0,
  };
  const membersStored = answers["pour-famille"]?.members as Member[] | undefined;
  const setCounts = (c: typeof counts) => {
    setAnswer("pour-famille", "counts", c);
    // Sync members list to reflect counts, keep individual data when possible.
    const current = membersStored ?? [];
    const currentByType = {
      adulte: current.filter((m) => m.type === "adulte"),
      enfant: current.filter((m) => m.type === "enfant"),
      invite: current.filter((m) => m.type === "invite"),
    };
    const next: Member[] = [];
    for (let i = 0; i < c.adultes; i++) next.push(currentByType.adulte[i] ?? { id: `a${i + 1}`, name: `Adulte ${i + 1}`, type: "adulte" });
    for (let i = 0; i < c.enfants; i++) next.push(currentByType.enfant[i] ?? { id: `e${i + 1}`, name: `Enfant ${i + 1}`, type: "enfant", age: 8 });
    for (let i = 0; i < c.invites; i++) next.push(currentByType.invite[i] ?? { id: `i${i + 1}`, name: `Invité ${i + 1}`, type: "invite" });
    setAnswer("pour-famille", "members", next);
  };

  React.useEffect(() => {
    if (!membersStored) {
      setAnswer("pour-famille", "members", defaultMembers(counts.adultes, counts.enfants, counts.invites));
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const total = counts.adultes + counts.enfants + counts.invites;
  return (
    <View>
      <Card>
        <View style={styles.rowBetween}>
          <View style={{ flex: 1 }}>
            <Label>Adultes</Label>
          </View>
          <Counter value={counts.adultes} min={0} max={10} onChange={(v) => setCounts({ ...counts, adultes: v })} testID="fam-adultes" />
        </View>
      </Card>
      <Card>
        <View style={styles.rowBetween}>
          <View style={{ flex: 1 }}>
            <Label>Enfants</Label>
          </View>
          <Counter value={counts.enfants} min={0} max={10} onChange={(v) => setCounts({ ...counts, enfants: v })} testID="fam-enfants" />
        </View>
      </Card>
      <Card>
        <View style={styles.rowBetween}>
          <View style={{ flex: 1 }}>
            <Label>Invités récurrents</Label>
          </View>
          <Counter value={counts.invites} min={0} max={10} onChange={(v) => setCounts({ ...counts, invites: v })} testID="fam-invites" />
        </View>
      </Card>
      <View style={styles.totalBanner}>
        <Ionicons name="people" size={18} color={colors.onBrandSecondary} />
        <Text style={styles.totalText}>Total : {total} personne{total > 1 ? "s" : ""}</Text>
      </View>
    </View>
  );
}

// -- Step 3 : Profil et besoins de chacun -----------------------------------

const PORTIONS = [
  { id: "petite", label: "Petite", emoji: "🥄" },
  { id: "moyenne", label: "Moyenne", emoji: "🍽️" },
  { id: "grande", label: "Grande", emoji: "🍽️🍽️" },
];

function Step3() {
  const [members, setMembers] = useFam<Member[]>("members", []);
  const upd = (id: string, patch: Partial<Member>) =>
    setMembers(members.map((m) => (m.id === id ? { ...m, ...patch } : m)));

  if (members.length === 0) return <EmptyMembers />;
  return (
    <View>
      {members.map((m) => (
        <View key={m.id} testID={`fam-member-${m.id}`} style={styles.memberCard}>
          <View style={styles.memberHeader}>
            <View style={styles.memberBadge}>
              <Ionicons
                name={m.type === "adulte" ? "person" : m.type === "enfant" ? "happy" : "people"}
                size={14}
                color={colors.onBrandSecondary}
              />
              <Text style={styles.memberBadgeText}>
                {m.type === "adulte" ? "Adulte" : m.type === "enfant" ? "Enfant" : "Invité"}
              </Text>
            </View>
          </View>
          <Text style={styles.inputLabel}>Prénom ou surnom</Text>
          <TextInput
            testID={`fam-name-${m.id}`}
            value={m.name}
            onChangeText={(t) => upd(m.id, { name: t })}
            style={styles.textInput}
          />
          {m.type === "enfant" && (
            <View style={[styles.rowBetween, { marginTop: spacing.sm }]}>
              <Text style={styles.inputLabel}>Âge</Text>
              <Counter
                value={m.age ?? 8}
                min={0}
                max={17}
                onChange={(v) => upd(m.id, { age: v })}
                testID={`fam-age-${m.id}`}
              />
            </View>
          )}
          <Text style={[styles.inputLabel, { marginTop: spacing.sm }]}>Taille de portion</Text>
          <ChipSingle
            options={PORTIONS}
            value={m.portion}
            onSelect={(p) => upd(m.id, { portion: p as any })}
            testIDPrefix={`fam-portion-${m.id}`}
          />
          <Text style={[styles.inputLabel, { marginTop: spacing.sm }]}>Objectif individuel (facultatif)</Text>
          <TextInput
            testID={`fam-goal-${m.id}`}
            value={m.objectif ?? ""}
            onChangeText={(t) => upd(m.id, { objectif: t })}
            placeholder="Ex. rester en forme"
            placeholderTextColor={colors.muted}
            style={styles.textInput}
          />
        </View>
      ))}
    </View>
  );
}

// -- Step 4 : Notre rythme --------------------------------------------------

const CONTEXTS = [
  { id: "travail", label: "Travail", emoji: "💼" },
  { id: "ecole", label: "École", emoji: "🎒" },
  { id: "cantine", label: "Cantine", emoji: "🍱" },
  { id: "teletravail", label: "Télétravail", emoji: "💻" },
  { id: "maison", label: "À la maison", emoji: "🏡" },
  { id: "weekend", label: "Week-end", emoji: "🌞" },
];

function Step4() {
  const [members] = useFam<Member[]>("members", []);
  const [presence, setPresence] = useFam<Record<string, string[]>>("presence", {});
  const toggle = (ctx: string, memberId: string) => {
    const list = presence[ctx] ?? [];
    const next = list.includes(memberId) ? list.filter((x) => x !== memberId) : [...list, memberId];
    setPresence({ ...presence, [ctx]: next });
  };
  if (members.length === 0) return <EmptyMembers />;
  return (
    <View>
      <View style={styles.helperBanner}>
        <Ionicons name="information-circle-outline" size={16} color={colors.onBrandTertiary} />
        <Text style={styles.helperText}>Cochez les personnes concernées pour chaque contexte.</Text>
      </View>
      {CONTEXTS.map((ctx) => (
        <View key={ctx.id} style={styles.card}>
          <Text style={styles.label}>
            {ctx.emoji} {ctx.label}
          </Text>
          <View style={{ height: spacing.sm }} />
          <View style={styles.rowWrap}>
            {members.map((m) => {
              const active = (presence[ctx.id] ?? []).includes(m.id);
              return (
                <Pressable
                  key={m.id}
                  testID={`fam-presence-${ctx.id}-${m.id}`}
                  onPress={() => toggle(ctx.id, m.id)}
                  style={[styles.miniChip, active && styles.miniChipActive]}
                >
                  <Text style={[styles.miniChipText, active && styles.miniChipTextActive]}>{m.name}</Text>
                </Pressable>
              );
            })}
          </View>
        </View>
      ))}
    </View>
  );
}

// -- Step 5 : Nos repas de la semaine ---------------------------------------

const MEAL_TYPES = ["Petit-déjeuner", "Déjeuner", "Dîner", "Collation"];
const DAYS = ["Lun", "Mar", "Mer", "Jeu", "Ven", "Sam", "Dim"];

function Step5() {
  const [meals, setMeals] = useFam<Record<string, number>>("repas", {
    "Petit-déjeuner": 0, "Déjeuner": 5, "Dîner": 5, "Collation": 0,
  });
  const [days, setDays] = useFam<string[]>("jours", ["Lun", "Mar", "Mer", "Jeu", "Ven"]);
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
              testID={`fam-meal-${m}`}
            />
          </View>
        ))}
        <Text style={[styles.hint, { marginTop: 8 }]}>Total : {total} repas / semaine</Text>
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
                testID={`fam-day-${d}`}
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

// -- Step 6 : Notre budget --------------------------------------------------

const BUDGET_PERIODS = [
  { id: "semaine", label: "Par semaine", emoji: "📅" },
  { id: "jour", label: "Par jour", emoji: "☀️" },
  { id: "repas", label: "Par repas", emoji: "🍽️" },
];
function Step6() {
  const [period, setPeriod] = useFam<string>("budgetPeriod", "semaine");
  const [amount, setAmount] = useFam<number>("budgetAmount", 100);
  return (
    <View>
      <Card>
        <Label>Fréquence du budget</Label>
        <View style={{ height: spacing.sm }} />
        <ChipSingle options={BUDGET_PERIODS} value={period} onSelect={setPeriod} testIDPrefix="fam-budget-period" />
      </Card>
      <Card>
        <View style={styles.rowBetween}>
          <View style={{ flex: 1 }}>
            <Label>Montant (€)</Label>
            <Hint>Menoo convertit en interne selon vos repas.</Hint>
          </View>
          <TextInput
            testID="fam-budget-amount"
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

// -- Step 7 : Courses / réserves --------------------------------------------

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
  const [mode, setMode] = useFam<string>("mode", "mixte");
  const [stores, setStores] = useFam<string[]>("stores", ["Carrefour"]);
  const [cp, setCp] = useFam<string>("codePostal", "");
  const toggle = (id: string) =>
    setStores(stores.includes(id) ? stores.filter((x) => x !== id) : [...stores, id]);
  const showReserves = mode === "reserves" || mode === "mixte";
  return (
    <View>
      <Card>
        <Label>Choix du mode</Label>
        <View style={{ height: spacing.sm }} />
        <ChipSingle options={MODES} value={mode} onSelect={setMode} testIDPrefix="fam-mode" />
      </Card>
      <Card>
        <Label>Magasins préférés</Label>
        <View style={{ height: spacing.sm }} />
        <ChipMulti options={STORES} values={stores} onToggle={toggle} testIDPrefix="fam-store" />
        <View style={{ height: spacing.md }} />
        <Label>Code postal</Label>
        <TextInput
          testID="fam-cp"
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
          <Label>Nos réserves</Label>
          <Hint>Écrire, parler, photo, ticket ou code-barres.</Hint>
          <View style={{ height: spacing.sm }} />
          <PrimaryButton
            testID="btn-open-input"
            label="Ajouter nos réserves"
            variant="secondary"
            onPress={onOpenPantry}
            icon={<Ionicons name="basket-outline" size={18} color={colors.onBrandSecondary} />}
          />
        </Card>
      )}
    </View>
  );
}

// -- Step 8 : Régime par personne -------------------------------------------

function Step8() {
  const [members, setMembers] = useFam<Member[]>("members", []);
  const upd = (id: string, patch: Partial<Member>) =>
    setMembers(members.map((m) => (m.id === id ? { ...m, ...patch } : m)));
  if (members.length === 0) return <EmptyMembers />;
  return (
    <View>
      {members.map((m) => (
        <View key={m.id} testID={`fam-diet-member-${m.id}`} style={styles.memberCard}>
          <View style={styles.memberHeader}>
            <View style={styles.memberBadge}>
              <Ionicons
                name={m.type === "adulte" ? "person" : m.type === "enfant" ? "happy" : "people"}
                size={14}
                color={colors.onBrandSecondary}
              />
              <Text style={styles.memberBadgeText}>{m.name}</Text>
            </View>
          </View>
          <ChipSingle
            options={DIETS}
            value={m.diet}
            onSelect={(d) => upd(m.id, { diet: d })}
            testIDPrefix={`fam-diet-${m.id}`}
          />
        </View>
      ))}
    </View>
  );
}

// -- Step 9 : Allergies par personne ----------------------------------------

function Step9() {
  const [members, setMembers] = useFam<Member[]>("members", []);
  const toggle = (id: string, aId: string) => {
    setMembers(
      members.map((m) => {
        if (m.id !== id) return m;
        const list = m.allergies ?? [];
        return { ...m, allergies: list.includes(aId) ? list.filter((a) => a !== aId) : [...list, aId] };
      })
    );
  };
  if (members.length === 0) return <EmptyMembers />;
  return (
    <View>
      <View style={styles.helperBanner}>
        <Ionicons name="information-circle-outline" size={16} color={colors.onBrandTertiary} />
        <Text style={styles.helperText}>Aucune fusion entre les personnes. Rien à signaler ? Passez au suivant.</Text>
      </View>
      {members.map((m) => (
        <View key={m.id} testID={`fam-allergy-member-${m.id}`} style={styles.memberCard}>
          <View style={styles.memberHeader}>
            <View style={styles.memberBadge}>
              <Ionicons
                name={m.type === "adulte" ? "person" : m.type === "enfant" ? "happy" : "people"}
                size={14}
                color={colors.onBrandSecondary}
              />
              <Text style={styles.memberBadgeText}>{m.name}</Text>
            </View>
          </View>
          <ChipMulti
            options={ALLERGIES}
            values={m.allergies ?? []}
            onToggle={(a) => toggle(m.id, a)}
            testIDPrefix={`fam-allergy-${m.id}`}
          />
        </View>
      ))}
    </View>
  );
}

// -- Step 10 : Goûts, cuisines, ambiance ------------------------------------

const AMBIANCES = [
  { id: "familiale", label: "Familiale", emoji: "🏡" },
  { id: "legere", label: "Légère", emoji: "🥗" },
  { id: "express", label: "Express", emoji: "⚡" },
  { id: "festive", label: "Festive", emoji: "🎉" },
  { id: "reconfortante", label: "Réconfortante", emoji: "🕯️" },
];

function Step10() {
  const [members, setMembers] = useFam<Member[]>("members", []);
  const [cuisines, setCu] = useFam<string[]>("cuisines", []);
  const [ambiance, setAmb] = useFam<string | null>("ambiance", null);
  const toggleC = (id: string) =>
    setCu(cuisines.includes(id) ? cuisines.filter((c) => c !== id) : [...cuisines, id]);
  const toggleTaste = (id: string, field: "likes" | "dislikes", tasteId: string) => {
    setMembers(
      members.map((m) => {
        if (m.id !== id) return m;
        const list = (m[field] as string[] | undefined) ?? [];
        const other = field === "likes" ? "dislikes" : "likes";
        const otherList = (m[other] as string[] | undefined) ?? [];
        const active = list.includes(tasteId);
        const nextList = active ? list.filter((x) => x !== tasteId) : [...list, tasteId];
        const nextOther = active ? otherList : otherList.filter((x) => x !== tasteId);
        return { ...m, [field]: nextList, [other]: nextOther } as Member;
      })
    );
  };
  if (members.length === 0) return <EmptyMembers />;
  return (
    <View>
      {members.map((m) => (
        <View key={m.id} testID={`fam-tastes-${m.id}`} style={styles.memberCard}>
          <View style={styles.memberHeader}>
            <View style={styles.memberBadge}>
              <Ionicons
                name={m.type === "adulte" ? "person" : m.type === "enfant" ? "happy" : "people"}
                size={14}
                color={colors.onBrandSecondary}
              />
              <Text style={styles.memberBadgeText}>{m.name}</Text>
            </View>
          </View>
          <Text style={styles.subLabel2}>J'aime</Text>
          <ChipMulti
            options={TASTES}
            values={m.likes ?? []}
            onToggle={(t) => toggleTaste(m.id, "likes", t)}
            testIDPrefix={`fam-likes-${m.id}`}
          />
          <View style={{ height: spacing.md }} />
          <Text style={styles.subLabel2}>Je n'aime pas</Text>
          <ChipMulti
            options={TASTES}
            values={m.dislikes ?? []}
            onToggle={(t) => toggleTaste(m.id, "dislikes", t)}
            testIDPrefix={`fam-dislikes-${m.id}`}
          />
        </View>
      ))}
      <Card>
        <Label>Cuisines aimées (foyer)</Label>
        <View style={{ height: spacing.sm }} />
        <ChipMulti options={CUISINES} values={cuisines} onToggle={toggleC} testIDPrefix="fam-cuisine" />
      </Card>
      <Card>
        <Label>Ambiance des repas</Label>
        <View style={{ height: spacing.sm }} />
        <ChipSingle options={AMBIANCES} value={ambiance} onSelect={setAmb} testIDPrefix="fam-ambiance" />
      </Card>
    </View>
  );
}

// -- Step 11 : Organisation -------------------------------------------------

const NIVEAUX = [
  { id: "debutant", label: "Débutant", emoji: "🌱" },
  { id: "intermediaire", label: "Intermédiaire", emoji: "👍" },
  { id: "avance", label: "Avancé", emoji: "⭐" },
];

function Step11() {
  const [equipment, setEq] = useFam<string[]>("equipment", ["plaques", "four"]);
  const [tempsSem, setTS] = useFam<number>("tempsSemaine", 30);
  const [tempsWE, setTWE] = useFam<number>("tempsWeekEnd", 60);
  const [niveau, setN] = useFam<string | null>("niveau", null);
  const [restes, setR] = useFam<string[]>("restes", []);
  const toggle = (id: string, list: string[], setL: (v: string[]) => void) =>
    setL(list.includes(id) ? list.filter((x) => x !== id) : [...list, id]);
  return (
    <View>
      <Card>
        <Label>Matériel disponible</Label>
        <View style={{ height: spacing.sm }} />
        <ChipMulti options={EQUIPMENT} values={equipment} onToggle={(id) => toggle(id, equipment, setEq)} testIDPrefix="fam-equipment" />
      </Card>
      <Card>
        <View style={styles.rowBetween}>
          <View style={{ flex: 1 }}>
            <Label>Temps — semaine (min)</Label>
          </View>
          <Counter value={tempsSem} min={5} max={120} step={5} onChange={setTS} testID="fam-temps-sem" />
        </View>
      </Card>
      <Card>
        <View style={styles.rowBetween}>
          <View style={{ flex: 1 }}>
            <Label>Temps — week-end (min)</Label>
          </View>
          <Counter value={tempsWE} min={5} max={180} step={5} onChange={setTWE} testID="fam-temps-we" />
        </View>
      </Card>
      <Card>
        <Label>Niveau en cuisine du foyer</Label>
        <View style={{ height: spacing.sm }} />
        <ChipSingle options={NIVEAUX} value={niveau} onSelect={setN} testIDPrefix="fam-niveau" />
      </Card>
      <Card>
        <Label>Gestion des restes</Label>
        <View style={{ height: spacing.sm }} />
        <ChipMulti options={RESTES} values={restes} onToggle={(id) => toggle(id, restes, setR)} testIDPrefix="fam-restes" />
      </Card>
    </View>
  );
}

// -- Step 12 : Résumé -------------------------------------------------------

function Step12() {
  const { answers } = useMenoo();
  const a = answers["pour-famille"] ?? {};
  const members: Member[] = a.members ?? [];
  const findLabel = (arr: any[], id: any) => arr.find((x) => x.id === id)?.label ?? "—";
  const joinLabels = (arr: any[], ids: string[] = []) =>
    ids.length ? ids.map((i) => findLabel(arr, i)).join(", ") : "—";
  const meals = a.repas ?? {};
  const mealsTotal = Object.values<any>(meals).reduce((s: number, v: any) => s + (Number(v) || 0), 0);

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
  return (
    <View>
      <Card>
        <Label>Foyer ({members.length} personne{members.length > 1 ? "s" : ""})</Label>
        <View style={{ height: spacing.sm }} />
        {members.map((m) => (
          <View key={m.id} style={styles.memberLine}>
            <Ionicons
              name={m.type === "adulte" ? "person" : m.type === "enfant" ? "happy" : "people"}
              size={16}
              color={colors.brandPrimary}
            />
            <Text style={styles.memberLineText}>
              {m.name}
              {m.type === "enfant" && m.age !== undefined ? ` · ${m.age} ans` : ""}
              {m.diet ? ` · ${findLabel(DIETS, m.diet)}` : ""}
            </Text>
          </View>
        ))}
      </Card>
      <Card>
        {line("flag-outline", "Priorité", findLabel(PRIORITIES, a.priorite))}
        {line("calendar-outline", "Repas / semaine", `${mealsTotal} sur ${(a.jours ?? []).length} jours`)}
        {line("wallet-outline", "Budget", `${a.budgetAmount ?? "—"} € / ${a.budgetPeriod ?? "—"}`)}
        {line("storefront-outline", "Mode", findLabel(MODES, a.mode))}
        {line("restaurant-outline", "Cuisines", joinLabels(CUISINES, a.cuisines))}
        {line("sparkles-outline", "Ambiance", findLabel(AMBIANCES, a.ambiance))}
        {line("hardware-chip-outline", "Matériel", joinLabels(EQUIPMENT, a.equipment))}
        {line("time-outline", "Temps semaine / WE", `${a.tempsSemaine ?? "—"} min / ${a.tempsWeekEnd ?? "—"} min`)}
      </Card>
    </View>
  );
}

// -- Common ----------------------------------------------------------------

function EmptyMembers() {
  return (
    <View style={styles.emptyBanner}>
      <Ionicons name="information-circle-outline" size={18} color={colors.onBrandTertiary} />
      <Text style={styles.emptyText}>
        Aucun membre du foyer renseigné. Revenez à l'étape 2 pour en ajouter.
      </Text>
    </View>
  );
}

// -- Validation ------------------------------------------------------------

export function familleCanContinue(step: number, a: any): true | string {
  switch (step) {
    case 1: return a?.priorite ? true : "Choisissez une priorité.";
    case 2: {
      const c = a?.counts ?? { adultes: 0, enfants: 0, invites: 0 };
      return c.adultes + c.enfants + c.invites >= 1 || "Ajoutez au moins une personne.";
    }
    case 11: return a?.niveau ? true : "Choisissez un niveau en cuisine.";
    default: return true;
  }
}

// -- Router ----------------------------------------------------------------

export default function FamilleStep({ step, onOpenPantry }: { step: number; onOpenPantry: () => void }) {
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

// -- Styles ----------------------------------------------------------------

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
  subLabel2: { ...typography.small, color: colors.onSurface, fontWeight: "700", marginBottom: 8 },
  inputLabel: { ...typography.caption, color: colors.muted, marginTop: spacing.sm, marginBottom: 4 },
  rowBetween: { flexDirection: "row", alignItems: "center", gap: spacing.md, justifyContent: "space-between" },
  rowWrap: { flexDirection: "row", flexWrap: "wrap", gap: 8 },
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
  memberCard: {
    backgroundColor: colors.surfaceSecondary,
    borderRadius: radius.lg,
    padding: spacing.lg,
    marginBottom: spacing.md,
    ...shadow.soft,
  },
  memberHeader: { flexDirection: "row", justifyContent: "space-between", alignItems: "center", marginBottom: spacing.sm },
  memberBadge: {
    flexDirection: "row",
    alignItems: "center",
    gap: 6,
    backgroundColor: colors.brandSecondaryMuted,
    paddingHorizontal: 10,
    paddingVertical: 5,
    borderRadius: radius.pill,
  },
  memberBadgeText: { ...typography.caption, color: colors.onBrandSecondary, fontWeight: "700" },
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
  totalBanner: {
    flexDirection: "row",
    gap: 8,
    padding: spacing.md,
    backgroundColor: colors.brandSecondaryMuted,
    borderRadius: radius.md,
    alignItems: "center",
  },
  totalText: { ...typography.bodyMd, color: colors.onBrandSecondary, fontWeight: "700" },
  helperBanner: {
    flexDirection: "row",
    gap: 6,
    padding: spacing.md,
    backgroundColor: colors.brandTertiaryMuted,
    borderRadius: radius.md,
    marginBottom: spacing.md,
    alignItems: "center",
  },
  helperText: { flex: 1, ...typography.caption, color: colors.onBrandTertiary, lineHeight: 17 },
  emptyBanner: {
    flexDirection: "row",
    gap: 6,
    padding: spacing.md,
    backgroundColor: colors.brandTertiaryMuted,
    borderRadius: radius.md,
    alignItems: "center",
  },
  emptyText: { flex: 1, ...typography.small, color: colors.onBrandTertiary, lineHeight: 19 },
  miniChip: {
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderRadius: radius.pill,
    backgroundColor: colors.surfaceTertiary,
    borderWidth: 1.5,
    borderColor: "transparent",
  },
  miniChipActive: { backgroundColor: colors.brandSecondaryMuted, borderColor: colors.brandPrimary },
  miniChipText: { ...typography.caption, color: colors.onSurfaceTertiary, fontWeight: "600" },
  miniChipTextActive: { color: colors.onBrandSecondary, fontWeight: "700" },
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
  memberLine: { flexDirection: "row", alignItems: "center", gap: 6, paddingVertical: 4 },
  memberLineText: { flex: 1, ...typography.body, color: colors.onSurface },
});
