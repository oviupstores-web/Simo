// Écrans interactifs du parcours « Pour mon foyer » (étapes 3 à 12)
// Toutes les réponses sont persistées via le store Menoo (AsyncStorage).

import React from "react";
import { View, Text, StyleSheet, ScrollView, Pressable, TextInput } from "react-native";
import { Ionicons } from "@expo/vector-icons";
import { useMenoo } from "../store/menoo";
import { colors, radius, spacing, typography, shadow } from "../theme/tokens";
import { ChipMulti, ChipSingle } from "../components/Chip";
import Counter from "../components/Counter";
import PrimaryButton from "../components/PrimaryButton";

export interface HouseholdMember {
  id: string;
  name: string;
  type: "adulte" | "enfant" | "invite";
  age?: number;
  diet?: string;
  allergies?: string[];
  likes?: string[];
  dislikes?: string[];
}

// -- Helpers -----------------------------------------------------------------

function useFoyer<T = any>(key: string, fallback: T): [T, (v: T) => void] {
  const { answers, setAnswer } = useMenoo();
  const value = (answers["pour-foyer"]?.[key] as T) ?? fallback;
  const set = (v: T) => setAnswer("pour-foyer", key, v);
  return [value, set];
}

function SectionCard({ children, style }: { children: React.ReactNode; style?: any }) {
  return <View style={[styles.card, style]}>{children}</View>;
}

// -- Step 3 : Qui mange à la maison -----------------------------------------

const MEMBER_TYPES: { id: HouseholdMember["type"]; label: string; icon: any }[] = [
  { id: "adulte", label: "Adulte", icon: "person-outline" },
  { id: "enfant", label: "Enfant", icon: "happy-outline" },
  { id: "invite", label: "Invité", icon: "people-outline" },
];

function Step3Members() {
  const { answers, setAnswer } = useMenoo();
  const stored = answers["pour-foyer"]?.members as HouseholdMember[] | undefined;
  const members: HouseholdMember[] = stored ?? [
    { id: "m1", name: "Adulte 1", type: "adulte" },
    { id: "m2", name: "Adulte 2", type: "adulte" },
  ];
  const setMembers = (list: HouseholdMember[]) => setAnswer("pour-foyer", "members", list);
  // Persist default composition on first visit so validation passes.
  React.useEffect(() => {
    if (!stored) setMembers(members);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const addMember = (type: HouseholdMember["type"]) => {
    const nextId = `m${Date.now()}`;
    const count = members.filter((m) => m.type === type).length + 1;
    const label =
      type === "adulte" ? `Adulte ${count}` : type === "enfant" ? `Enfant ${count}` : `Invité ${count}`;
    setMembers([...members, { id: nextId, name: label, type }]);
  };

  const removeMember = (id: string) => setMembers(members.filter((m) => m.id !== id));
  const rename = (id: string, name: string) =>
    setMembers(members.map((m) => (m.id === id ? { ...m, name } : m)));
  const setAge = (id: string, age: number) =>
    setMembers(members.map((m) => (m.id === id ? { ...m, age } : m)));

  return (
    <View>
      <SectionCard>
        <Text style={styles.cardLabel}>Ajouter une personne</Text>
        <View style={styles.addRow}>
          {MEMBER_TYPES.map((t) => (
            <Pressable
              key={t.id}
              testID={`foyer-add-${t.id}`}
              onPress={() => addMember(t.id)}
              style={styles.addBtn}
            >
              <Ionicons name={t.icon} size={18} color={colors.brandPrimary} />
              <Text style={styles.addBtnText}>+ {t.label}</Text>
            </Pressable>
          ))}
        </View>
      </SectionCard>

      {members.map((m, idx) => (
        <View key={m.id} testID={`foyer-member-${m.id}`} style={styles.memberCard}>
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
            {members.length > 1 && (
              <Pressable
                testID={`foyer-remove-${m.id}`}
                onPress={() => removeMember(m.id)}
                hitSlop={8}
              >
                <Ionicons name="close-circle" size={22} color={colors.muted} />
              </Pressable>
            )}
          </View>

          <Text style={styles.inputLabel}>Prénom ou surnom</Text>
          <TextInput
            testID={`foyer-name-${m.id}`}
            value={m.name}
            onChangeText={(t) => rename(m.id, t)}
            style={styles.input}
            placeholder={`Personne ${idx + 1}`}
            placeholderTextColor={colors.muted}
          />

          {m.type === "enfant" && (
            <View style={styles.ageRow}>
              <Text style={styles.inputLabel}>Âge</Text>
              <Counter
                testID={`foyer-age-${m.id}`}
                value={m.age ?? 8}
                min={0}
                max={17}
                onChange={(v) => setAge(m.id, v)}
              />
            </View>
          )}
        </View>
      ))}
    </View>
  );
}

// -- Step 4 : Priorité commune ----------------------------------------------

const PRIORITIES = [
  { id: "temps", label: "Gagner du temps", emoji: "⏱️" },
  { id: "budget", label: "Maîtriser le budget", emoji: "💶" },
  { id: "sante", label: "Manger mieux", emoji: "🥗" },
  { id: "gaspillage", label: "Moins gaspiller", emoji: "🌱" },
  { id: "partage", label: "Plaisir de partager", emoji: "🍽️" },
];

function Step4Priority() {
  const [priority, setPriority] = useFoyer<string | null>("priority", null);
  return (
    <SectionCard>
      <Text style={styles.cardLabel}>Choisissez une priorité principale</Text>
      <ChipSingle options={PRIORITIES} value={priority} onSelect={setPriority} testIDPrefix="foyer-priority" />
    </SectionCard>
  );
}

// -- Step 5 : Repas de la semaine -------------------------------------------

function Step5Meals() {
  const [meals, setMeals] = useFoyer<number>("meals", 5);
  return (
    <SectionCard>
      <View style={styles.rowBetween}>
        <View style={{ flex: 1 }}>
          <Text style={styles.cardLabel}>Nombre de repas à préparer</Text>
          <Text style={styles.cardHint}>De 1 à 7 sur la semaine</Text>
        </View>
        <Counter value={meals} min={1} max={7} onChange={setMeals} testID="foyer-meals" />
      </View>
    </SectionCard>
  );
}

// -- Step 6 : Budget --------------------------------------------------------

const BUDGET_OPTIONS = [
  { id: "40", label: "≈ 40 €" },
  { id: "60", label: "≈ 60 €" },
  { id: "80", label: "≈ 80 €" },
  { id: "100", label: "≈ 100 €" },
  { id: "130", label: "≈ 130 €" },
  { id: "160", label: "≈ 160 €" },
];

function Step6Budget() {
  const [budget, setBudget] = useFoyer<string | null>("budget", null);
  return (
    <SectionCard>
      <Text style={styles.cardLabel}>Budget indicatif pour la semaine</Text>
      <Text style={styles.cardHint}>Sélectionnez une fourchette. Vous pourrez l'ajuster à tout moment.</Text>
      <View style={{ height: spacing.sm }} />
      <ChipSingle options={BUDGET_OPTIONS} value={budget} onSelect={setBudget} testIDPrefix="foyer-budget" />
    </SectionCard>
  );
}

// -- Steps 7, 8, 9 : per-member preferences ---------------------------------

const DIETS = [
  { id: "omnivore", label: "Omnivore", emoji: "🍽️" },
  { id: "flexi", label: "Flexitarien", emoji: "🌾" },
  { id: "vegetarien", label: "Végétarien", emoji: "🥬" },
  { id: "vegan", label: "Végan", emoji: "🌱" },
  { id: "pesco", label: "Pescetarien", emoji: "🐟" },
  { id: "sans-porc", label: "Sans porc", emoji: "🚫" },
];

const ALLERGIES = [
  { id: "gluten", label: "Gluten", emoji: "🌾" },
  { id: "lactose", label: "Lactose", emoji: "🥛" },
  { id: "oeuf", label: "Œuf", emoji: "🥚" },
  { id: "arachide", label: "Arachide", emoji: "🥜" },
  { id: "fruits-coque", label: "Fruits à coque", emoji: "🌰" },
  { id: "poisson", label: "Poisson", emoji: "🐟" },
  { id: "crustaces", label: "Crustacés", emoji: "🦐" },
  { id: "soja", label: "Soja", emoji: "🫘" },
];

const TASTES = [
  { id: "epice", label: "Épicé", emoji: "🌶️" },
  { id: "sucre", label: "Sucré", emoji: "🍯" },
  { id: "acidule", label: "Acidulé", emoji: "🍋" },
  { id: "fumé", label: "Fumé", emoji: "🔥" },
  { id: "legumes-verts", label: "Légumes verts", emoji: "🥦" },
  { id: "champignons", label: "Champignons", emoji: "🍄" },
  { id: "poisson", label: "Poisson", emoji: "🐟" },
  { id: "viande-rouge", label: "Viande rouge", emoji: "🥩" },
  { id: "pates", label: "Pâtes", emoji: "🍝" },
  { id: "riz", label: "Riz", emoji: "🍚" },
];

function MemberEditor({
  member,
  onUpdate,
  render,
  testIDPrefix,
}: {
  member: HouseholdMember;
  onUpdate: (patch: Partial<HouseholdMember>) => void;
  render: (m: HouseholdMember, onUpdate: (p: Partial<HouseholdMember>) => void) => React.ReactNode;
  testIDPrefix: string;
}) {
  return (
    <View testID={`${testIDPrefix}-${member.id}`} style={styles.memberCard}>
      <View style={styles.memberHeader}>
        <View style={styles.memberBadge}>
          <Ionicons
            name={member.type === "adulte" ? "person" : member.type === "enfant" ? "happy" : "people"}
            size={14}
            color={colors.onBrandSecondary}
          />
          <Text style={styles.memberBadgeText}>{member.name}</Text>
        </View>
      </View>
      {render(member, onUpdate)}
    </View>
  );
}

function Step7Diet() {
  const [members, setMembers] = useFoyer<HouseholdMember[]>("members", []);
  if (members.length === 0)
    return <EmptyMembers />;
  return (
    <View>
      {members.map((m) => (
        <MemberEditor
          key={m.id}
          member={m}
          testIDPrefix="foyer-diet-member"
          onUpdate={(patch) =>
            setMembers(members.map((x) => (x.id === m.id ? { ...x, ...patch } : x)))
          }
          render={(mm, upd) => (
            <ChipSingle
              options={DIETS}
              value={mm.diet}
              onSelect={(d) => upd({ diet: d })}
              testIDPrefix={`foyer-diet-${mm.id}`}
            />
          )}
        />
      ))}
    </View>
  );
}

function Step8Allergies() {
  const [members, setMembers] = useFoyer<HouseholdMember[]>("members", []);
  if (members.length === 0) return <EmptyMembers />;
  const toggle = (id: string, allergyId: string) => {
    setMembers(
      members.map((m) => {
        if (m.id !== id) return m;
        const list = m.allergies ?? [];
        return {
          ...m,
          allergies: list.includes(allergyId) ? list.filter((a) => a !== allergyId) : [...list, allergyId],
        };
      })
    );
  };
  return (
    <View>
      <View style={styles.helperBanner}>
        <Ionicons name="information-circle-outline" size={16} color={colors.onBrandTertiary} />
        <Text style={styles.helperText}>Cochez ce qui doit être évité. Rien à signaler ? Passez au suivant.</Text>
      </View>
      {members.map((m) => (
        <MemberEditor
          key={m.id}
          member={m}
          testIDPrefix="foyer-allergy-member"
          onUpdate={() => {}}
          render={(mm) => (
            <ChipMulti
              options={ALLERGIES}
              values={mm.allergies ?? []}
              onToggle={(a) => toggle(mm.id, a)}
              testIDPrefix={`foyer-allergy-${mm.id}`}
            />
          )}
        />
      ))}
    </View>
  );
}

function Step9Tastes() {
  const [members, setMembers] = useFoyer<HouseholdMember[]>("members", []);
  if (members.length === 0) return <EmptyMembers />;
  const toggle = (id: string, field: "likes" | "dislikes", tasteId: string) => {
    setMembers(
      members.map((m) => {
        if (m.id !== id) return m;
        const list = (m[field] as string[] | undefined) ?? [];
        const other = field === "likes" ? "dislikes" : "likes";
        const otherList = (m[other] as string[] | undefined) ?? [];
        const isActive = list.includes(tasteId);
        const nextList = isActive ? list.filter((a) => a !== tasteId) : [...list, tasteId];
        // Ensure a taste cannot be in likes and dislikes at the same time.
        const nextOther = isActive ? otherList : otherList.filter((a) => a !== tasteId);
        return { ...m, [field]: nextList, [other]: nextOther } as HouseholdMember;
      })
    );
  };
  return (
    <View>
      {members.map((m) => (
        <View key={m.id} testID={`foyer-tastes-${m.id}`} style={styles.memberCard}>
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
          <Text style={styles.subLabel}>J'aime</Text>
          <ChipMulti
            options={TASTES}
            values={m.likes ?? []}
            onToggle={(t) => toggle(m.id, "likes", t)}
            testIDPrefix={`foyer-likes-${m.id}`}
          />
          <View style={{ height: spacing.md }} />
          <Text style={styles.subLabel}>Je n'aime pas</Text>
          <ChipMulti
            options={TASTES}
            values={m.dislikes ?? []}
            onToggle={(t) => toggle(m.id, "dislikes", t)}
            testIDPrefix={`foyer-dislikes-${m.id}`}
          />
        </View>
      ))}
    </View>
  );
}

// -- Step 10 : Cuisines & vibe ----------------------------------------------

const CUISINES = [
  { id: "italienne", label: "Italienne", emoji: "🇮🇹" },
  { id: "française", label: "Française", emoji: "🇫🇷" },
  { id: "méditerranéenne", label: "Méditerranéenne", emoji: "🫒" },
  { id: "asiatique", label: "Asiatique", emoji: "🥢" },
  { id: "orientale", label: "Orientale", emoji: "🌯" },
  { id: "mexicaine", label: "Mexicaine", emoji: "🌮" },
  { id: "reconfort", label: "Réconfort", emoji: "🍲" },
];

const VIBES = [
  { id: "famille", label: "Familial", emoji: "🏡" },
  { id: "decouverte", label: "Découverte", emoji: "✨" },
  { id: "reconfort", label: "Réconfort", emoji: "🕯️" },
  { id: "leger", label: "Léger", emoji: "🥗" },
];

function Step10Vibe() {
  const [cuisines, setCuisines] = useFoyer<string[]>("cuisines", []);
  const [vibe, setVibe] = useFoyer<string | null>("vibe", null);
  const toggle = (id: string) =>
    setCuisines(cuisines.includes(id) ? cuisines.filter((c) => c !== id) : [...cuisines, id]);

  return (
    <View>
      <SectionCard>
        <Text style={styles.cardLabel}>Cuisines préférées</Text>
        <Text style={styles.cardHint}>Sélectionnez celles qui plaisent à la maison.</Text>
        <View style={{ height: spacing.sm }} />
        <ChipMulti options={CUISINES} values={cuisines} onToggle={toggle} testIDPrefix="foyer-cuisine" />
      </SectionCard>
      <SectionCard>
        <Text style={styles.cardLabel}>Vibe des repas</Text>
        <Text style={styles.cardHint}>Une ambiance globale — vous pourrez varier.</Text>
        <View style={{ height: spacing.sm }} />
        <ChipSingle options={VIBES} value={vibe} onSelect={setVibe} testIDPrefix="foyer-vibe" />
      </SectionCard>
    </View>
  );
}

// -- Step 11 : Matériel, temps, réserves ------------------------------------

const EQUIPMENT = [
  { id: "four", label: "Four", emoji: "♨️" },
  { id: "plaque", label: "Plaques", emoji: "🍳" },
  { id: "microondes", label: "Micro-ondes", emoji: "📟" },
  { id: "blender", label: "Blender", emoji: "🌀" },
  { id: "robot", label: "Robot", emoji: "🤖" },
  { id: "cocotte", label: "Cocotte", emoji: "🍲" },
  { id: "vapeur", label: "Vapeur", emoji: "💨" },
];

const TIMES = [
  { id: "rapide", label: "≤ 20 min", emoji: "⚡" },
  { id: "moyen", label: "20–40 min", emoji: "⏱️" },
  { id: "confortable", label: "≥ 40 min", emoji: "🕰️" },
];

function Step11Practical({ onOpenPantry }: { onOpenPantry: () => void }) {
  const [equipment, setEquipment] = useFoyer<string[]>("equipment", ["four", "plaque"]);
  const [timeMode, setTimeMode] = useFoyer<string | null>("timeMode", "moyen");
  const toggle = (id: string) =>
    setEquipment(equipment.includes(id) ? equipment.filter((c) => c !== id) : [...equipment, id]);

  return (
    <View>
      <SectionCard>
        <Text style={styles.cardLabel}>Matériel disponible</Text>
        <View style={{ height: spacing.sm }} />
        <ChipMulti options={EQUIPMENT} values={equipment} onToggle={toggle} testIDPrefix="foyer-equipment" />
      </SectionCard>
      <SectionCard>
        <Text style={styles.cardLabel}>Temps préféré pour cuisiner</Text>
        <View style={{ height: spacing.sm }} />
        <ChipSingle options={TIMES} value={timeMode} onSelect={setTimeMode} testIDPrefix="foyer-time" />
      </SectionCard>
      <SectionCard>
        <Text style={styles.cardLabel}>Nos réserves</Text>
        <Text style={styles.cardHint}>Consultez ce que vous avez déjà chez vous.</Text>
        <View style={{ height: spacing.sm }} />
        <PrimaryButton
          testID="btn-open-pantry"
          label="Ouvrir mes réserves"
          variant="secondary"
          onPress={onOpenPantry}
          icon={<Ionicons name="basket-outline" size={18} color={colors.onBrandSecondary} />}
        />
      </SectionCard>
    </View>
  );
}

// -- Step 12 : Résumé -------------------------------------------------------

function Step12Summary() {
  const { answers } = useMenoo();
  const f = answers["pour-foyer"] ?? {};
  const members: HouseholdMember[] = f.members ?? [];
  const priority = PRIORITIES.find((p) => p.id === f.priority)?.label ?? "—";
  const meals = f.meals ?? "—";
  const budget = BUDGET_OPTIONS.find((b) => b.id === f.budget)?.label ?? "—";
  const cuisines = (f.cuisines as string[] | undefined) ?? [];
  const vibe = VIBES.find((v) => v.id === f.vibe)?.label ?? "—";
  const equipment = (f.equipment as string[] | undefined) ?? [];
  const timeMode = TIMES.find((t) => t.id === f.timeMode)?.label ?? "—";

  const SummaryLine = ({ icon, label, value }: { icon: any; label: string; value: string }) => (
    <View style={styles.summaryLine}>
      <View style={styles.summaryIcon}>
        <Ionicons name={icon} size={18} color={colors.brandPrimary} />
      </View>
      <View style={{ flex: 1 }}>
        <Text style={styles.summaryLabel}>{label}</Text>
        <Text style={styles.summaryValue}>{value}</Text>
      </View>
    </View>
  );

  return (
    <View>
      <SectionCard>
        <Text style={styles.cardLabel}>Foyer ({members.length} personne{members.length > 1 ? "s" : ""})</Text>
        <View style={{ height: spacing.sm }} />
        {members.length === 0 ? (
          <Text style={styles.cardHint}>Aucun membre renseigné.</Text>
        ) : (
          members.map((m) => (
            <View key={m.id} style={styles.memberLine}>
              <Ionicons
                name={m.type === "adulte" ? "person" : m.type === "enfant" ? "happy" : "people"}
                size={16}
                color={colors.brandPrimary}
              />
              <Text style={styles.memberLineText}>
                {m.name}
                {m.type === "enfant" && m.age !== undefined ? ` · ${m.age} ans` : ""}
                {m.diet ? ` · ${DIETS.find((d) => d.id === m.diet)?.label ?? m.diet}` : ""}
              </Text>
            </View>
          ))
        )}
      </SectionCard>
      <SectionCard>
        <SummaryLine icon="flag-outline" label="Priorité" value={priority} />
        <SummaryLine icon="calendar-outline" label="Repas / semaine" value={String(meals)} />
        <SummaryLine icon="wallet-outline" label="Budget" value={budget} />
        <SummaryLine
          icon="restaurant-outline"
          label="Cuisines"
          value={cuisines.length ? cuisines.map((c) => CUISINES.find((x) => x.id === c)?.label ?? c).join(", ") : "—"}
        />
        <SummaryLine icon="sparkles-outline" label="Vibe" value={vibe} />
        <SummaryLine
          icon="hardware-chip-outline"
          label="Matériel"
          value={equipment.length ? equipment.map((e) => EQUIPMENT.find((x) => x.id === e)?.label ?? e).join(", ") : "—"}
        />
        <SummaryLine icon="time-outline" label="Temps de cuisson" value={timeMode} />
      </SectionCard>
      <View style={styles.finalNote}>
        <Ionicons name="checkmark-circle" size={20} color={colors.brandPrimary} />
        <Text style={styles.finalNoteText}>
          Prêt à créer la semaine de repas de votre foyer. Tout pourra être modifié plus tard.
        </Text>
      </View>
    </View>
  );
}

// -- Common empty state -----------------------------------------------------

function EmptyMembers() {
  return (
    <View style={styles.emptyBanner}>
      <Ionicons name="information-circle-outline" size={18} color={colors.onBrandTertiary} />
      <Text style={styles.emptyText}>
        Aucun membre du foyer renseigné. Revenez à l'étape 3 pour en ajouter.
      </Text>
    </View>
  );
}

// -- Validators (returns null if OK, or a warning string) --------------------

export function foyerCanContinue(step: number, foyerAnswers: any): true | string {
  switch (step) {
    case 3:
      return (foyerAnswers?.members?.length ?? 0) >= 1 || "Ajoutez au moins un membre du foyer.";
    case 4:
      return foyerAnswers?.priority ? true : "Choisissez une priorité.";
    case 5:
      return typeof foyerAnswers?.meals === "number" ? true : true; // default fallback
    case 6:
      return foyerAnswers?.budget ? true : "Sélectionnez une fourchette de budget.";
    case 10:
      return foyerAnswers?.vibe ? true : "Choisissez une vibe pour vos repas.";
    default:
      return true;
  }
}

// -- Router ------------------------------------------------------------------

export default function FoyerStep({ step, onOpenPantry }: { step: number; onOpenPantry: () => void }) {
  switch (step) {
    case 3: return <Step3Members />;
    case 4: return <Step4Priority />;
    case 5: return <Step5Meals />;
    case 6: return <Step6Budget />;
    case 7: return <Step7Diet />;
    case 8: return <Step8Allergies />;
    case 9: return <Step9Tastes />;
    case 10: return <Step10Vibe />;
    case 11: return <Step11Practical onOpenPantry={onOpenPantry} />;
    case 12: return <Step12Summary />;
    default: return null;
  }
}

// -- Styles -----------------------------------------------------------------

const styles = StyleSheet.create({
  card: {
    backgroundColor: colors.surfaceSecondary,
    borderRadius: radius.lg,
    padding: spacing.lg,
    marginBottom: spacing.md,
    ...shadow.soft,
  },
  cardLabel: { ...typography.h3, color: colors.onSurface },
  cardHint: { ...typography.small, color: colors.muted, marginTop: 4 },
  rowBetween: { flexDirection: "row", alignItems: "center", justifyContent: "space-between" },
  addRow: { flexDirection: "row", flexWrap: "wrap", gap: 8, marginTop: spacing.sm },
  addBtn: {
    flexDirection: "row",
    alignItems: "center",
    gap: 6,
    paddingHorizontal: 14,
    paddingVertical: 10,
    borderRadius: radius.pill,
    borderWidth: 1.5,
    borderColor: colors.brandPrimary,
    backgroundColor: colors.surfaceSecondary,
  },
  addBtnText: { ...typography.small, color: colors.brandPrimary, fontWeight: "700" },
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
  inputLabel: { ...typography.caption, color: colors.muted, marginTop: spacing.sm, marginBottom: 4 },
  input: {
    backgroundColor: colors.surfaceTertiary,
    borderRadius: radius.md,
    paddingHorizontal: spacing.md,
    paddingVertical: 10,
    ...typography.body,
    color: colors.onSurface,
    borderWidth: 1,
    borderColor: colors.border,
  },
  ageRow: {
    marginTop: spacing.sm,
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    gap: spacing.md,
  },
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
  subLabel: { ...typography.small, color: colors.onSurface, fontWeight: "700", marginBottom: 8 },
  emptyBanner: {
    flexDirection: "row",
    gap: 6,
    padding: spacing.md,
    backgroundColor: colors.brandTertiaryMuted,
    borderRadius: radius.md,
    alignItems: "center",
  },
  emptyText: { flex: 1, ...typography.small, color: colors.onBrandTertiary, lineHeight: 19 },
  memberLine: { flexDirection: "row", alignItems: "center", gap: 6, paddingVertical: 4 },
  memberLineText: { flex: 1, ...typography.body, color: colors.onSurface },
  summaryLine: {
    flexDirection: "row",
    gap: spacing.md,
    paddingVertical: spacing.sm,
    alignItems: "center",
    borderBottomWidth: 1,
    borderBottomColor: colors.divider,
  },
  summaryIcon: {
    width: 32, height: 32, borderRadius: radius.md,
    backgroundColor: colors.brandSecondaryMuted,
    justifyContent: "center", alignItems: "center",
  },
  summaryLabel: { ...typography.caption, color: colors.muted },
  summaryValue: { ...typography.bodyMd, color: colors.onSurface, marginTop: 2 },
  finalNote: {
    flexDirection: "row",
    gap: 8,
    padding: spacing.lg,
    backgroundColor: colors.brandSecondaryMuted,
    borderRadius: radius.md,
    alignItems: "center",
    marginTop: spacing.sm,
  },
  finalNoteText: { flex: 1, ...typography.body, color: colors.onBrandSecondary, lineHeight: 21, fontWeight: "600" },
});
