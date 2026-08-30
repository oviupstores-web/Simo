import React, { useMemo } from "react";
import { View, Text, StyleSheet, ScrollView } from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { useRouter } from "expo-router";
import { Image } from "expo-image";
import { LinearGradient } from "expo-linear-gradient";
import { Ionicons } from "@expo/vector-icons";
import FlowHeader from "@/src/components/FlowHeader";
import PrimaryButton from "@/src/components/PrimaryButton";
import { useMenoo } from "@/src/store/menoo";
import { italianRecipe, italianRecipeNeeds } from "@/src/services/mockData";
import { getRecipeImage } from "@/src/services/recipes";
import { colors, radius, spacing, typography, shadow } from "@/src/theme/tokens";

export default function RecipeScreen() {
  const insets = useSafeAreaInsets();
  const router = useRouter();
  const { meal, pantry, applyRecipeConsumption, setCooked } = useMenoo();
  const recipeImage = getRecipeImage(italianRecipe.recipeId).url;

  const factor = meal.people * meal.meals;
  const ingredients = useMemo(
    () =>
      pantry.map((p) => ({
        ...p,
        needed: ((italianRecipeNeeds as any)[p.id] ?? 0) * factor,
      })),
    [pantry, factor]
  );

  const onCooked = () => {
    const consumption: Record<string, number> = {};
    ingredients.forEach((i) => (consumption[i.id] = i.needed));
    applyRecipeConsumption(consumption);
    setCooked(true);
    router.push("/flow/stock-update");
  };

  return (
    <View style={styles.container}>
      <FlowHeader title="Recette proposée" step={6} totalSteps={6} />
      <ScrollView
        contentContainerStyle={{ paddingBottom: spacing.xxxl + insets.bottom }}
      >
        <View style={styles.heroWrap}>
          <Image source={{ uri: recipeImage }} style={styles.hero} contentFit="cover" />
          <LinearGradient
            colors={["transparent", "rgba(0,0,0,0.55)"]}
            style={StyleSheet.absoluteFill}
          />
          <View style={styles.heroContent}>
            <Text style={styles.heroTitle}>{italianRecipe.title}</Text>
            <View style={styles.heroMeta}>
              <View style={styles.metaChip}>
                <Ionicons name="people" size={14} color={colors.onSurfaceInverse} />
                <Text style={styles.metaText}>{meal.people} pers.</Text>
              </View>
              <View style={styles.metaChip}>
                <Ionicons name="time" size={14} color={colors.onSurfaceInverse} />
                <Text style={styles.metaText}>{italianRecipe.time} min</Text>
              </View>
              <View style={styles.metaChip}>
                <Ionicons name="wallet" size={14} color={colors.onSurfaceInverse} />
                <Text style={styles.metaText}>0 € d'achat</Text>
              </View>
            </View>
          </View>
        </View>

        <View style={{ paddingHorizontal: spacing.lg, marginTop: spacing.lg }}>
          <View style={styles.priorityBadge}>
            <Ionicons name="leaf" size={14} color={colors.onBrandSecondary} />
            <Text style={styles.priorityText}>Produits fragiles utilisés en priorité</Text>
          </View>

          <View style={styles.card}>
            <Text style={styles.sectionTitle}>Ingrédients</Text>
            <View style={{ marginTop: spacing.sm }}>
              {ingredients.map((i) => (
                <View key={i.id} testID={`recipe-ingredient-${i.id}`} style={styles.ingRow}>
                  <Text style={styles.ingEmoji}>{i.emoji}</Text>
                  <Text style={styles.ingName}>{i.name}</Text>
                  <Text style={styles.ingQty}>
                    {i.needed} {i.unit}
                  </Text>
                </View>
              ))}
            </View>
          </View>

          <View style={styles.card}>
            <Text style={styles.sectionTitle}>Préparation</Text>
            {italianRecipe.steps.map((s, idx) => (
              <View key={idx} style={styles.stepRow}>
                <View style={styles.stepNum}>
                  <Text style={styles.stepNumText}>{idx + 1}</Text>
                </View>
                <Text style={styles.stepText}>{s}</Text>
              </View>
            ))}
          </View>

          <PrimaryButton
            testID="btn-cooked"
            label="J'ai préparé ce repas"
            onPress={onCooked}
            icon={<Ionicons name="checkmark-circle" size={20} color={colors.onBrandPrimary} />}
          />
          <View style={{ height: spacing.sm }} />
          <PrimaryButton
            testID="btn-see-other"
            label="Voir une autre proposition"
            variant="ghost"
            onPress={() => router.back()}
          />
        </View>
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: colors.surface },
  heroWrap: {
    height: 260,
    marginHorizontal: spacing.lg,
    borderRadius: radius.lg,
    overflow: "hidden",
    ...shadow.card,
  },
  hero: { width: "100%", height: "100%" },
  heroContent: { position: "absolute", left: spacing.lg, right: spacing.lg, bottom: spacing.lg },
  heroTitle: { fontSize: 26, fontWeight: "800", color: colors.onSurfaceInverse, marginBottom: spacing.sm },
  heroMeta: { flexDirection: "row", gap: 6, flexWrap: "wrap" },
  metaChip: {
    flexDirection: "row",
    alignItems: "center",
    gap: 4,
    backgroundColor: "rgba(0,0,0,0.35)",
    paddingHorizontal: 10,
    paddingVertical: 5,
    borderRadius: radius.pill,
  },
  metaText: { color: colors.onSurfaceInverse, fontSize: 12, fontWeight: "600" },
  priorityBadge: {
    alignSelf: "flex-start",
    flexDirection: "row",
    alignItems: "center",
    gap: 4,
    backgroundColor: colors.brandSecondaryMuted,
    paddingHorizontal: 10,
    paddingVertical: 5,
    borderRadius: radius.pill,
    marginBottom: spacing.md,
  },
  priorityText: { ...typography.caption, color: colors.onBrandSecondary },
  card: {
    backgroundColor: colors.surfaceSecondary,
    borderRadius: radius.lg,
    padding: spacing.lg,
    marginBottom: spacing.md,
    ...shadow.soft,
  },
  sectionTitle: { ...typography.h3, color: colors.onSurface },
  ingRow: {
    flexDirection: "row",
    alignItems: "center",
    gap: spacing.md,
    paddingVertical: spacing.sm,
    borderBottomWidth: 1,
    borderBottomColor: colors.divider,
  },
  ingEmoji: { fontSize: 22 },
  ingName: { flex: 1, ...typography.bodyMd, color: colors.onSurface },
  ingQty: { ...typography.bodyMd, color: colors.brandPrimary, fontWeight: "700" },
  stepRow: {
    flexDirection: "row",
    gap: spacing.md,
    paddingVertical: spacing.md,
    borderBottomWidth: 1,
    borderBottomColor: colors.divider,
    alignItems: "flex-start",
  },
  stepNum: {
    width: 28, height: 28, borderRadius: 14,
    backgroundColor: colors.brandPrimary,
    justifyContent: "center", alignItems: "center",
    marginTop: 2,
  },
  stepNumText: { color: colors.onBrandPrimary, fontWeight: "700", fontSize: 13 },
  stepText: { flex: 1, ...typography.body, color: colors.onSurface, lineHeight: 22 },
});
