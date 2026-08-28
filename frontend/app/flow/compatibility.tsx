import React, { useMemo } from "react";
import { View, Text, StyleSheet, ScrollView } from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { useRouter } from "expo-router";
import { Ionicons } from "@expo/vector-icons";
import FlowHeader from "@/src/components/FlowHeader";
import PrimaryButton from "@/src/components/PrimaryButton";
import Gauge from "@/src/components/Gauge";
import { useMenoo } from "@/src/store/menoo";
import { italianRecipeNeeds } from "@/src/services/mockData";
import { colors, radius, spacing, typography, shadow } from "@/src/theme/tokens";

export default function CompatibilityScreen() {
  const insets = useSafeAreaInsets();
  const router = useRouter();
  const { pantry, meal } = useMenoo();

  const { isAsian, needsExtra, computed, allEnough } = useMemo(() => {
    const factor = meal.people * meal.meals;
    const needs = {
      pates: italianRecipeNeeds.pates * factor,
      champignons: italianRecipeNeeds.champignons * factor,
      creme: italianRecipeNeeds.creme * factor,
    };
    const items = pantry.map((p) => ({
      ...p,
      needed: (needs as any)[p.id] ?? 0,
      enough: p.available >= ((needs as any)[p.id] ?? 0),
    }));
    const allEnough = items.every((i) => i.enough);
    const isAsian = meal.cuisine === "asiatique";
    return {
      isAsian,
      needsExtra: isAsian,
      computed: items,
      allEnough,
    };
  }, [pantry, meal]);

  // Recipe blocked when: asian + none rule, OR not enough for italian
  const asianBlocked = isAsian && meal.purchaseRule === "none";
  const stockBlocked = !allEnough && meal.purchaseRule === "none";
  const canProceed = !asianBlocked && !stockBlocked;

  let statusIcon: any = "checkmark-circle";
  let statusColor = colors.brandPrimary;
  let statusBg = colors.brandSecondaryMuted;
  let statusText = "Tout est compatible. Vous avez ce qu'il faut pour préparer ce repas sans achat.";

  if (asianBlocked) {
    statusIcon = "warning-outline";
    statusColor = colors.warning;
    statusBg = colors.brandTertiaryMuted;
    statusText =
      "La cuisine asiatique nécessite un complément (sauce soja). Autorisez un complément ou changez de cuisine.";
  } else if (stockBlocked) {
    statusIcon = "information-circle-outline";
    statusColor = colors.error;
    statusBg = "#F8E1DC";
    statusText =
      "Votre stock permet actuellement 1 repas pour 2 personnes. Réduisez le nombre de repas ou autorisez un complément.";
  }

  return (
    <View style={styles.container}>
      <FlowHeader title="Compatibilité" step={5} totalSteps={6} />
      <ScrollView
        contentContainerStyle={{
          paddingHorizontal: spacing.lg,
          paddingBottom: spacing.xxxl + insets.bottom,
        }}
      >
        <View style={styles.recap}>
          <Text style={styles.recapText}>
            {meal.people} personne{meal.people > 1 ? "s" : ""} · {meal.meals} repas · Cuisine {meal.cuisine}
          </Text>
        </View>

        <View style={styles.card}>
          <Text style={styles.cardTitle}>Ingrédients nécessaires</Text>
          <Text style={styles.cardHint}>Comparaison entre ce que vous avez et ce qu'il faut.</Text>
          <View style={{ marginTop: spacing.md }}>
            {computed.map((i) => (
              <Gauge
                key={i.id}
                testID={`gauge-${i.id}`}
                available={i.available}
                needed={i.needed}
                unit={i.unit}
                label={i.name}
                emoji={i.emoji}
              />
            ))}
            {isAsian && (
              <View style={styles.missingRow}>
                <Ionicons name="alert-circle" size={20} color={colors.warning} />
                <Text style={styles.missingText}>
                  Sauce soja manquante — complément indispensable pour la recette asiatique.
                </Text>
              </View>
            )}
          </View>
        </View>

        <View style={[styles.status, { backgroundColor: statusBg }]}>
          <Ionicons name={statusIcon} size={22} color={statusColor} />
          <Text style={[styles.statusText, { color: statusColor }]}>{statusText}</Text>
        </View>

        <PrimaryButton
          testID="btn-see-recipe"
          label={canProceed ? "Voir la recette" : "Ajuster les choix"}
          onPress={() => (canProceed ? router.push("/flow/recipe") : router.back())}
          variant={canProceed ? "primary" : "ghost"}
        />
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: colors.surface },
  recap: {
    backgroundColor: colors.brandSecondaryMuted,
    padding: spacing.md,
    borderRadius: radius.md,
    marginBottom: spacing.md,
    alignItems: "center",
  },
  recapText: { ...typography.small, color: colors.onBrandSecondary, fontWeight: "600" },
  card: {
    backgroundColor: colors.surfaceSecondary,
    borderRadius: radius.lg,
    padding: spacing.lg,
    marginBottom: spacing.md,
    ...shadow.soft,
  },
  cardTitle: { ...typography.h3, color: colors.onSurface },
  cardHint: { ...typography.small, color: colors.muted, marginTop: 2, marginBottom: spacing.sm },
  missingRow: {
    flexDirection: "row",
    gap: spacing.sm,
    alignItems: "center",
    padding: spacing.md,
    backgroundColor: colors.brandTertiaryMuted,
    borderRadius: radius.md,
    marginTop: spacing.sm,
  },
  missingText: { flex: 1, ...typography.small, color: colors.onBrandTertiary, lineHeight: 19 },
  status: {
    flexDirection: "row",
    gap: spacing.sm,
    padding: spacing.lg,
    borderRadius: radius.md,
    marginBottom: spacing.lg,
    alignItems: "flex-start",
  },
  statusText: { flex: 1, ...typography.body, lineHeight: 21, fontWeight: "600" },
});
