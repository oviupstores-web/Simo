import React from "react";
import { View, Text, StyleSheet, ScrollView, Pressable } from "react-native";
import { useRouter } from "expo-router";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { Ionicons } from "@expo/vector-icons";
import { useMenoo } from "@/src/store/menoo";
import { colors, radius, spacing, typography, shadow } from "@/src/theme/tokens";
import PrimaryButton from "@/src/components/PrimaryButton";

export default function PantryScreen() {
  const insets = useSafeAreaInsets();
  const router = useRouter();
  const { pantry, resetPantry, cooked } = useMenoo();

  return (
    <View style={styles.container}>
      <ScrollView
        contentContainerStyle={{
          paddingTop: insets.top + spacing.lg,
          paddingHorizontal: spacing.lg,
          paddingBottom: spacing.xxxl,
        }}
        showsVerticalScrollIndicator={false}
      >
        <Text style={styles.pageTitle}>Mes réserves</Text>
        <Text style={styles.pageSubtitle}>
          Suivez ce qu'il reste chez vous. Menoo utilise ces quantités pour vous proposer des repas réalisables.
        </Text>

        {cooked && (
          <View testID="pantry-updated-banner" style={styles.banner}>
            <Ionicons name="checkmark-circle" size={20} color={colors.brandPrimary} />
            <Text style={styles.bannerText}>
              Vos réserves ont été mises à jour après votre dernier repas.
            </Text>
          </View>
        )}

        <View style={styles.list}>
          {pantry.map((item) => {
            const ratio = item.available / item.containerSize;
            const pct = Math.round(ratio * 100);
            return (
              <View key={item.id} testID={`pantry-item-${item.id}`} style={styles.itemCard}>
                <View style={styles.itemHeader}>
                  <Text style={styles.itemEmoji}>{item.emoji}</Text>
                  <View style={{ flex: 1 }}>
                    <Text style={styles.itemName}>{item.name}</Text>
                    <Text style={styles.itemQty}>
                      {item.available} {item.unit} disponibles sur {item.containerSize} {item.unit}
                    </Text>
                  </View>
                  <Text style={styles.itemPct}>{pct}%</Text>
                </View>
                <View style={styles.itemTrack}>
                  <View style={[styles.itemFill, { width: `${pct}%` }]} />
                </View>
              </View>
            );
          })}
        </View>

        <PrimaryButton
          testID="btn-add-reserves"
          label="Ajouter des réserves"
          onPress={() => router.push("/flow/input")}
          icon={<Ionicons name="add-circle-outline" size={20} color={colors.onBrandPrimary} />}
        />
        <View style={{ height: spacing.md }} />
        <Pressable testID="btn-reset-pantry" onPress={resetPantry} style={styles.resetBtn}>
          <Ionicons name="refresh-outline" size={16} color={colors.muted} />
          <Text style={styles.resetText}>Réinitialiser la démo</Text>
        </Pressable>
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: colors.surface },
  pageTitle: { ...typography.display, color: colors.onSurface, marginBottom: spacing.xs },
  pageSubtitle: { ...typography.body, color: colors.muted, lineHeight: 22, marginBottom: spacing.lg },
  banner: {
    flexDirection: "row",
    alignItems: "center",
    gap: spacing.sm,
    backgroundColor: colors.brandSecondaryMuted,
    padding: spacing.md,
    borderRadius: radius.md,
    marginBottom: spacing.lg,
  },
  bannerText: { flex: 1, ...typography.small, color: colors.onBrandSecondary },
  list: { gap: spacing.md, marginBottom: spacing.xl },
  itemCard: {
    backgroundColor: colors.surfaceSecondary,
    borderRadius: radius.lg,
    padding: spacing.lg,
    ...shadow.soft,
  },
  itemHeader: { flexDirection: "row", alignItems: "center", gap: spacing.md, marginBottom: spacing.md },
  itemEmoji: { fontSize: 32 },
  itemName: { ...typography.h3, color: colors.onSurface },
  itemQty: { ...typography.small, color: colors.muted, marginTop: 2 },
  itemPct: { ...typography.h3, color: colors.brandPrimary },
  itemTrack: { height: 10, borderRadius: radius.pill, backgroundColor: colors.brandSecondaryMuted, overflow: "hidden" },
  itemFill: { height: "100%", backgroundColor: colors.brandPrimary, borderRadius: radius.pill },
  resetBtn: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    gap: 6,
    paddingVertical: spacing.md,
  },
  resetText: { ...typography.small, color: colors.muted },
});
