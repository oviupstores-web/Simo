import React from "react";
import { View, Text, StyleSheet, ScrollView, Pressable } from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { useRouter } from "expo-router";
import { Ionicons } from "@expo/vector-icons";
import FlowHeader from "@/src/components/FlowHeader";
import PrimaryButton from "@/src/components/PrimaryButton";
import { useMenoo } from "@/src/store/menoo";
import { Cuisine, PurchaseRule } from "@/src/services/mockData";
import { colors, radius, spacing, typography, shadow } from "@/src/theme/tokens";

const cuisines: { id: Cuisine; label: string; emoji: string }[] = [
  { id: "italienne", label: "Italienne", emoji: "🇮🇹" },
  { id: "française", label: "Française", emoji: "🇫🇷" },
  { id: "méditerranéenne", label: "Méditerranéenne", emoji: "🫒" },
  { id: "asiatique", label: "Asiatique", emoji: "🥢" },
];

const rules: { id: PurchaseRule; label: string; hint: string; icon: any }[] = [
  { id: "none", label: "Aucun achat", hint: "Uniquement ce que j'ai", icon: "checkmark-done-outline" },
  { id: "one_or_two", label: "1 ou 2 compléments", hint: "J'accepte quelques achats", icon: "add-circle-outline" },
  { id: "anti_waste", label: "Priorité anti-gaspillage", hint: "Utiliser d'abord ce qui périme", icon: "leaf-outline" },
];

function Counter({
  value,
  min,
  max,
  onChange,
  testID,
}: {
  value: number;
  min: number;
  max: number;
  onChange: (v: number) => void;
  testID: string;
}) {
  return (
    <View style={styles.counter}>
      <Pressable
        testID={`${testID}-dec`}
        onPress={() => onChange(Math.max(min, value - 1))}
        style={[styles.counterBtn, value <= min && styles.counterBtnDisabled]}
        disabled={value <= min}
      >
        <Ionicons name="remove" size={22} color={value <= min ? colors.muted : colors.onBrandPrimary} />
      </Pressable>
      <Text testID={`${testID}-value`} style={styles.counterValue}>
        {value}
      </Text>
      <Pressable
        testID={`${testID}-inc`}
        onPress={() => onChange(Math.min(max, value + 1))}
        style={[styles.counterBtn, value >= max && styles.counterBtnDisabled]}
        disabled={value >= max}
      >
        <Ionicons name="add" size={22} color={value >= max ? colors.muted : colors.onBrandPrimary} />
      </Pressable>
    </View>
  );
}

export default function MealChoiceScreen() {
  const insets = useSafeAreaInsets();
  const router = useRouter();
  const { meal, setMeal } = useMenoo();

  return (
    <View style={styles.container}>
      <FlowHeader title="Votre repas" step={4} totalSteps={6} />
      <ScrollView
        contentContainerStyle={{
          paddingHorizontal: spacing.lg,
          paddingBottom: spacing.xxxl + insets.bottom,
        }}
      >
        <Text style={styles.title}>Pour combien de personnes ?</Text>
        <View style={styles.card}>
          <View style={styles.rowBetween}>
            <View>
              <Text style={styles.rowLabel}>Nombre de personnes</Text>
              <Text style={styles.rowHint}>De 1 à 6</Text>
            </View>
            <Counter value={meal.people} min={1} max={6} onChange={(v) => setMeal({ people: v })} testID="people" />
          </View>
        </View>

        <View style={styles.card}>
          <View style={styles.rowBetween}>
            <View>
              <Text style={styles.rowLabel}>Nombre de repas</Text>
              <Text style={styles.rowHint}>De 1 à 4</Text>
            </View>
            <Counter value={meal.meals} min={1} max={4} onChange={(v) => setMeal({ meals: v })} testID="meals" />
          </View>
        </View>

        <Text style={styles.title}>Type de cuisine</Text>
        <View style={styles.grid}>
          {cuisines.map((c) => {
            const active = meal.cuisine === c.id;
            return (
              <Pressable
                key={c.id}
                testID={`cuisine-${c.id}`}
                onPress={() => setMeal({ cuisine: c.id })}
                style={[styles.pill, active && styles.pillActive]}
              >
                <Text style={styles.pillEmoji}>{c.emoji}</Text>
                <Text style={[styles.pillLabel, active && styles.pillLabelActive]}>{c.label}</Text>
              </Pressable>
            );
          })}
        </View>

        <Text style={styles.title}>Règle d'achat</Text>
        <View style={{ gap: spacing.sm }}>
          {rules.map((r) => {
            const active = meal.purchaseRule === r.id;
            return (
              <Pressable
                key={r.id}
                testID={`rule-${r.id}`}
                onPress={() => setMeal({ purchaseRule: r.id })}
                style={[styles.ruleCard, active && styles.ruleCardActive]}
              >
                <View
                  style={[
                    styles.ruleIcon,
                    { backgroundColor: active ? colors.brandPrimary : colors.brandSecondaryMuted },
                  ]}
                >
                  <Ionicons
                    name={r.icon}
                    size={18}
                    color={active ? colors.onBrandPrimary : colors.brandPrimary}
                  />
                </View>
                <View style={{ flex: 1 }}>
                  <Text style={styles.rowLabel}>{r.label}</Text>
                  <Text style={styles.rowHint}>{r.hint}</Text>
                </View>
                <View style={styles.radio}>
                  {active && <View style={styles.radioDot} />}
                </View>
              </Pressable>
            );
          })}
        </View>

        <View style={{ height: spacing.xl }} />
        <PrimaryButton
          testID="btn-check-compat"
          label="Vérifier la compatibilité"
          onPress={() => router.push("/flow/compatibility")}
        />
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: colors.surface },
  title: { ...typography.h3, color: colors.onSurface, marginBottom: spacing.sm, marginTop: spacing.md },
  card: {
    backgroundColor: colors.surfaceSecondary,
    borderRadius: radius.lg,
    padding: spacing.lg,
    marginBottom: spacing.sm,
    ...shadow.soft,
  },
  rowBetween: { flexDirection: "row", alignItems: "center", justifyContent: "space-between" },
  rowLabel: { ...typography.bodyMd, color: colors.onSurface },
  rowHint: { ...typography.small, color: colors.muted, marginTop: 2 },
  counter: {
    flexDirection: "row",
    alignItems: "center",
    backgroundColor: colors.surfaceTertiary,
    borderRadius: radius.pill,
    padding: 4,
    gap: 8,
  },
  counterBtn: {
    width: 36, height: 36, borderRadius: 18,
    backgroundColor: colors.brandPrimary,
    justifyContent: "center", alignItems: "center",
  },
  counterBtnDisabled: { backgroundColor: colors.border },
  counterValue: { ...typography.h3, color: colors.onSurface, minWidth: 24, textAlign: "center" },
  grid: { flexDirection: "row", flexWrap: "wrap", gap: spacing.sm, marginBottom: spacing.sm },
  pill: {
    flexBasis: "47%",
    flexGrow: 1,
    flexDirection: "row",
    alignItems: "center",
    gap: 8,
    backgroundColor: colors.surfaceSecondary,
    paddingHorizontal: spacing.md,
    paddingVertical: spacing.md,
    borderRadius: radius.pill,
    borderWidth: 2,
    borderColor: "transparent",
    ...shadow.soft,
  },
  pillActive: { borderColor: colors.brandPrimary, backgroundColor: colors.brandSecondaryMuted },
  pillEmoji: { fontSize: 20 },
  pillLabel: { ...typography.bodyMd, color: colors.onSurface },
  pillLabelActive: { color: colors.onBrandSecondary, fontWeight: "700" },
  ruleCard: {
    flexDirection: "row",
    alignItems: "center",
    gap: spacing.md,
    backgroundColor: colors.surfaceSecondary,
    borderRadius: radius.lg,
    padding: spacing.lg,
    borderWidth: 2,
    borderColor: "transparent",
    ...shadow.soft,
  },
  ruleCardActive: { borderColor: colors.brandPrimary },
  ruleIcon: {
    width: 36, height: 36, borderRadius: radius.md,
    justifyContent: "center", alignItems: "center",
  },
  radio: {
    width: 22, height: 22, borderRadius: 11,
    borderWidth: 2, borderColor: colors.brandPrimary,
    justifyContent: "center", alignItems: "center",
  },
  radioDot: { width: 10, height: 10, borderRadius: 5, backgroundColor: colors.brandPrimary },
});
