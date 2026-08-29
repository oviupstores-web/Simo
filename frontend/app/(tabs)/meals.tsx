import React, { useMemo, useState } from "react";
import { View, Text, StyleSheet, ScrollView, Pressable, Modal, Dimensions } from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { useRouter } from "expo-router";
import { Image } from "expo-image";
import { Ionicons } from "@expo/vector-icons";
import { weeklyPlan, swapAlternatives, PlannedMeal } from "@/src/services/mockData";
import { useMenoo } from "@/src/store/menoo";
import { colors, radius, spacing, typography, shadow } from "@/src/theme/tokens";

const SCREEN_W = Dimensions.get("window").width;
const CARD_W = (SCREEN_W - spacing.lg * 2 - 8 * 2) / 3;

export default function MenusScreen() {
  const insets = useSafeAreaInsets();
  const router = useRouter();
  const { weekOverrides, swapMeal, confirmedMeals, regenerateWeek, weekVersion } = useMenoo();
  const [swapFor, setSwapFor] = useState<PlannedMeal | null>(null);

  const merged = useMemo(
    () =>
      weeklyPlan.map((d) => ({
        ...d,
        meals: d.meals.map((m) => {
          const o = weekOverrides[m.id];
          return o
            ? { ...m, title: o.title, emoji: o.emoji, image: o.image, time: o.time, noPurchase: o.noPurchase }
            : m;
        }),
      })),
    [weekOverrides, weekVersion]
  );

  const total = merged.reduce((s, d) => s + d.meals.length, 0);
  const confirmedCount = merged.reduce(
    (s, d) => s + d.meals.filter((m) => confirmedMeals[m.id] || m.confirmed).length,
    0
  );

  const openMeal = (meal: PlannedMeal) => router.push(`/prep/${meal.id}` as any);

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
        <Text style={styles.pageTitle}>Ma semaine</Text>
        <Text style={styles.pageSubtitle}>
          7 jours, 3 repas par jour. Tapez sur un repas pour lancer la préparation, ou sur ↔ pour proposer une alternative.
        </Text>

        <View style={styles.summaryRow}>
          <View style={styles.summaryCard}>
            <Text style={styles.summaryLabel}>Repas</Text>
            <Text style={styles.summaryValue}>{total}</Text>
          </View>
          <View style={styles.summaryCard}>
            <Text style={styles.summaryLabel}>Confirmés</Text>
            <Text style={[styles.summaryValue, { color: colors.brandPrimary }]}>
              {confirmedCount}/{total}
            </Text>
          </View>
          <Pressable
            testID="btn-regen-week"
            onPress={regenerateWeek}
            style={({ pressed }) => [styles.regenCard, pressed && { opacity: 0.85 }]}
          >
            <Ionicons name="refresh" size={16} color={colors.onBrandPrimary} />
            <Text style={styles.regenText}>Semaine suivante</Text>
          </Pressable>
        </View>

        {merged.map((d) => (
          <View key={d.day} testID={`day-${d.day}`} style={styles.dayBlock}>
            <View style={styles.dayHeader}>
              <Text style={styles.dayTitle}>{d.day}</Text>
              <Text style={styles.dayCount}>{d.meals.length} repas</Text>
            </View>
            <View style={styles.mealRow}>
              {d.meals.map((m) => {
                const isConfirmed = confirmedMeals[m.id] || m.confirmed;
                return (
                  <View key={m.id} testID={`meal-${m.id}`} style={[styles.mealCard, { width: CARD_W }]}>
                    <Pressable onPress={() => openMeal(m)} style={styles.imgWrap}>
                      <Image source={{ uri: m.image }} style={styles.img} contentFit="cover" />
                      {isConfirmed && (
                        <View style={styles.confirmDot}>
                          <Ionicons name="checkmark" size={12} color={colors.onSuccess} />
                        </View>
                      )}
                      <Pressable
                        testID={`swap-${m.id}`}
                        onPress={() => setSwapFor(m)}
                        style={styles.swapBtn}
                        hitSlop={6}
                      >
                        <Ionicons name="swap-horizontal" size={14} color={colors.onBrandPrimary} />
                      </Pressable>
                    </Pressable>
                    <Text style={styles.slotBadge}>{m.slot}</Text>
                    <Text numberOfLines={2} style={styles.mealTitle}>
                      {m.title}
                    </Text>
                    <View style={styles.metaRow}>
                      <Ionicons name="time-outline" size={11} color={colors.muted} />
                      <Text style={styles.metaText}>{m.time} min</Text>
                      {m.noPurchase && (
                        <View style={styles.noPurchaseBadge}>
                          <Text style={styles.noPurchaseText}>0 €</Text>
                        </View>
                      )}
                    </View>
                  </View>
                );
              })}
            </View>
          </View>
        ))}
      </ScrollView>

      {/* Swap modal */}
      <Modal visible={!!swapFor} transparent animationType="fade" onRequestClose={() => setSwapFor(null)}>
        <Pressable style={styles.modalBg} onPress={() => setSwapFor(null)}>
          <Pressable style={styles.modalSheet} onPress={() => {}}>
            <View style={styles.modalHandle} />
            <Text style={styles.modalTitle}>Remplacer par…</Text>
            <Text style={styles.modalHint}>
              {swapFor?.slot} · Menoo propose 3 alternatives compatibles avec vos réserves.
            </Text>
            <View style={{ gap: spacing.sm, marginTop: spacing.md }}>
              {swapAlternatives.map((alt, idx) => (
                <Pressable
                  key={idx}
                  testID={`swap-option-${idx}`}
                  onPress={() => {
                    if (swapFor) {
                      swapMeal(swapFor.id, alt);
                      setSwapFor(null);
                    }
                  }}
                  style={({ pressed }) => [styles.altCard, pressed && { opacity: 0.85 }]}
                >
                  <Image source={{ uri: alt.image }} style={styles.altImg} contentFit="cover" />
                  <View style={{ flex: 1 }}>
                    <Text style={styles.altTitle}>{alt.title}</Text>
                    <View style={styles.metaRow}>
                      <Ionicons name="time-outline" size={11} color={colors.muted} />
                      <Text style={styles.metaText}>{alt.time} min</Text>
                      {alt.noPurchase && (
                        <View style={styles.noPurchaseBadge}>
                          <Text style={styles.noPurchaseText}>0 €</Text>
                        </View>
                      )}
                    </View>
                  </View>
                  <Ionicons name="arrow-forward" size={18} color={colors.brandPrimary} />
                </Pressable>
              ))}
            </View>
            <Pressable
              testID="swap-cancel"
              onPress={() => setSwapFor(null)}
              style={styles.cancelBtn}
            >
              <Text style={styles.cancelText}>Annuler</Text>
            </Pressable>
          </Pressable>
        </Pressable>
      </Modal>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: colors.surface },
  pageTitle: { ...typography.display, color: colors.onSurface, marginBottom: spacing.xs },
  pageSubtitle: { ...typography.body, color: colors.muted, lineHeight: 22, marginBottom: spacing.md },
  summaryRow: { flexDirection: "row", gap: spacing.sm, marginBottom: spacing.lg },
  summaryCard: {
    flex: 1,
    backgroundColor: colors.surfaceSecondary,
    borderRadius: radius.md,
    padding: spacing.md,
    ...shadow.soft,
  },
  summaryLabel: { ...typography.caption, color: colors.muted },
  summaryValue: { ...typography.h2, color: colors.onSurface, marginTop: 2 },
  regenCard: {
    flex: 1.2,
    backgroundColor: colors.brandPrimary,
    borderRadius: radius.md,
    padding: spacing.md,
    alignItems: "center",
    justifyContent: "center",
    gap: 4,
    ...shadow.soft,
  },
  regenText: { ...typography.caption, color: colors.onBrandPrimary, fontWeight: "700" },
  dayBlock: { marginBottom: spacing.lg },
  dayHeader: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    marginBottom: spacing.sm,
  },
  dayTitle: { ...typography.h2, color: colors.brandPrimary, fontWeight: "800" },
  dayCount: { ...typography.caption, color: colors.muted },
  mealRow: { flexDirection: "row", gap: 8 },
  mealCard: {
    backgroundColor: colors.surfaceSecondary,
    borderRadius: radius.md,
    overflow: "hidden",
    padding: 8,
    ...shadow.soft,
  },
  imgWrap: {
    position: "relative",
    borderRadius: radius.sm,
    overflow: "hidden",
    marginBottom: 6,
  },
  img: { width: "100%", height: 84 },
  confirmDot: {
    position: "absolute",
    top: 6,
    left: 6,
    width: 20,
    height: 20,
    borderRadius: 10,
    backgroundColor: colors.success,
    alignItems: "center",
    justifyContent: "center",
  },
  swapBtn: {
    position: "absolute",
    top: 6,
    right: 6,
    width: 24,
    height: 24,
    borderRadius: 12,
    backgroundColor: "rgba(25,83,59,0.85)",
    alignItems: "center",
    justifyContent: "center",
  },
  slotBadge: { ...typography.caption, color: colors.brandPrimary, fontWeight: "700", fontSize: 10 },
  mealTitle: { ...typography.small, color: colors.onSurface, fontWeight: "600", marginTop: 2, minHeight: 34 },
  metaRow: { flexDirection: "row", alignItems: "center", gap: 4, marginTop: 4, flexWrap: "wrap" },
  metaText: { ...typography.caption, color: colors.muted, fontSize: 10 },
  noPurchaseBadge: {
    backgroundColor: colors.brandSecondaryMuted,
    paddingHorizontal: 6,
    paddingVertical: 1,
    borderRadius: radius.pill,
  },
  noPurchaseText: { fontSize: 9, color: colors.onBrandSecondary, fontWeight: "700" },
  modalBg: {
    flex: 1,
    backgroundColor: "rgba(0,0,0,0.4)",
    justifyContent: "flex-end",
  },
  modalSheet: {
    backgroundColor: colors.surface,
    borderTopLeftRadius: radius.lg,
    borderTopRightRadius: radius.lg,
    padding: spacing.lg,
    paddingBottom: spacing.xxl,
  },
  modalHandle: {
    width: 40, height: 4, borderRadius: 2, backgroundColor: colors.border,
    alignSelf: "center", marginBottom: spacing.md,
  },
  modalTitle: { ...typography.h2, color: colors.onSurface, marginBottom: 4 },
  modalHint: { ...typography.small, color: colors.muted, lineHeight: 19 },
  altCard: {
    flexDirection: "row",
    alignItems: "center",
    gap: spacing.md,
    backgroundColor: colors.surfaceSecondary,
    borderRadius: radius.md,
    padding: spacing.sm,
    ...shadow.soft,
  },
  altImg: { width: 56, height: 56, borderRadius: radius.sm },
  altTitle: { ...typography.bodyMd, color: colors.onSurface, marginBottom: 2 },
  cancelBtn: { paddingVertical: spacing.md, alignItems: "center", marginTop: spacing.sm },
  cancelText: { ...typography.bodyMd, color: colors.muted, fontWeight: "600" },
});
