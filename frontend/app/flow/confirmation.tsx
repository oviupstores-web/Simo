import React from "react";
import { View, Text, StyleSheet, ScrollView } from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { useRouter } from "expo-router";
import { Ionicons } from "@expo/vector-icons";
import FlowHeader from "@/src/components/FlowHeader";
import PrimaryButton from "@/src/components/PrimaryButton";
import MenooSlider from "@/src/components/MenooSlider";
import { useMenoo } from "@/src/store/menoo";
import { colors, radius, spacing, typography, shadow } from "@/src/theme/tokens";

export default function ConfirmationScreen() {
  const insets = useSafeAreaInsets();
  const router = useRouter();
  const { pantry, setPantryItem } = useMenoo();

  return (
    <View style={styles.container}>
      <FlowHeader title="Confirmez vos réserves" step={3} totalSteps={6} />
      <ScrollView
        contentContainerStyle={{
          paddingHorizontal: spacing.lg,
          paddingBottom: spacing.xxxl + insets.bottom,
        }}
      >
        <View style={styles.reassure}>
          <Ionicons name="shield-checkmark-outline" size={20} color={colors.brandPrimary} />
          <Text style={styles.reassureText}>
            Menoo a reconnu les contenants. Vous confirmez simplement ce qu'il reste.
          </Text>
        </View>

        {pantry.map((item) => {
          const pct = Math.round((item.available / item.containerSize) * 100);
          return (
            <View key={item.id} testID={`confirm-item-${item.id}`} style={styles.card}>
              <View style={styles.cardHeader}>
                <Text style={styles.emoji}>{item.emoji}</Text>
                <View style={{ flex: 1 }}>
                  <Text style={styles.name}>{item.name}</Text>
                  <View style={styles.badges}>
                    <View style={styles.sourceBadge}>
                      <Ionicons name="pricetag" size={10} color={colors.onBrandTertiary} />
                      <Text style={styles.sourceBadgeText}>Open Food Facts</Text>
                    </View>
                    {item.priceInfo && (
                      <View style={[styles.sourceBadge, { backgroundColor: colors.brandSecondaryMuted }]}>
                        <Ionicons name="wallet" size={10} color={colors.onBrandSecondary} />
                        <Text style={[styles.sourceBadgeText, { color: colors.onBrandSecondary }]}>
                          {item.priceInfo.amount.toFixed(2)} € · Open Prices
                        </Text>
                      </View>
                    )}
                  </View>
                </View>
              </View>

              <View style={styles.qtyRow}>
                <Text style={styles.qtyMain}>
                  {item.available} {item.unit}
                </Text>
                <Text style={styles.qtyTotal}>
                  disponibles sur {item.containerSize} {item.unit}
                </Text>
              </View>

              <MenooSlider
                testID={`slider-${item.id}`}
                value={item.available}
                max={item.containerSize}
                min={0}
                step={item.unit === "cl" ? 1 : 5}
                onChange={(v) => setPantryItem(item.id, { available: v })}
              />

              <View style={styles.sliderRange}>
                <Text style={styles.rangeText}>0 {item.unit}</Text>
                <Text style={styles.rangePct}>{pct}%</Text>
                <Text style={styles.rangeText}>
                  {item.containerSize} {item.unit}
                </Text>
              </View>
            </View>
          );
        })}

        <PrimaryButton
          testID="btn-continue-meal-choice"
          label="Choisir le repas"
          onPress={() => router.push("/flow/meal-choice")}
        />
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: colors.surface },
  reassure: {
    flexDirection: "row",
    gap: spacing.sm,
    alignItems: "center",
    backgroundColor: colors.brandSecondaryMuted,
    padding: spacing.md,
    borderRadius: radius.md,
    marginBottom: spacing.lg,
  },
  reassureText: { flex: 1, ...typography.small, color: colors.onBrandSecondary, lineHeight: 19 },
  card: {
    backgroundColor: colors.surfaceSecondary,
    borderRadius: radius.lg,
    padding: spacing.lg,
    marginBottom: spacing.md,
    ...shadow.soft,
  },
  cardHeader: { flexDirection: "row", gap: spacing.md, marginBottom: spacing.md, alignItems: "flex-start" },
  emoji: { fontSize: 32 },
  name: { ...typography.h3, color: colors.onSurface, marginBottom: 4 },
  badges: { flexDirection: "row", flexWrap: "wrap", gap: 6 },
  sourceBadge: {
    flexDirection: "row",
    alignItems: "center",
    gap: 4,
    backgroundColor: colors.brandTertiaryMuted,
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: radius.pill,
  },
  sourceBadgeText: { ...typography.caption, color: colors.onBrandTertiary, fontSize: 11 },
  qtyRow: { flexDirection: "row", alignItems: "baseline", gap: 6, marginBottom: spacing.sm },
  qtyMain: { fontSize: 26, fontWeight: "800", color: colors.brandPrimary },
  qtyTotal: { ...typography.small, color: colors.muted },
  sliderRange: { flexDirection: "row", justifyContent: "space-between", marginTop: 6 },
  rangeText: { ...typography.caption, color: colors.muted },
  rangePct: { ...typography.caption, color: colors.brandPrimary, fontWeight: "700" },
});
