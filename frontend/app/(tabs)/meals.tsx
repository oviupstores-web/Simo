import React, { useMemo, useState } from "react";
import { View, Text, StyleSheet, ScrollView, Pressable } from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { useRouter } from "expo-router";
import { Ionicons } from "@expo/vector-icons";
import { weeklyPlan, shoppingList, PlannedMeal, ShoppingItem } from "@/src/services/mockData";
import { colors, radius, spacing, typography, shadow } from "@/src/theme/tokens";

type Tab = "calendar" | "shopping" | "prep";

const RAYON_COLORS: Record<ShoppingItem["rayon"], string> = {
  "Frais": "#7DB88E",
  "Sec": "#D4AF37",
  "Fruits & Légumes": "#A3CBAF",
  "Boucherie": "#CC5A47",
  "Épicerie": "#E0B647",
};

export default function MealsScreen() {
  const insets = useSafeAreaInsets();
  const router = useRouter();
  const [tab, setTab] = useState<Tab>("calendar");

  const confirmedCount = useMemo(
    () => weeklyPlan.reduce((s, d) => s + d.meals.filter((m) => m.confirmed).length, 0),
    []
  );
  const totalPlanned = useMemo(
    () => weeklyPlan.reduce((s, d) => s + d.meals.length, 0),
    []
  );
  const totalBudget = useMemo(
    () => shoppingList.reduce((s, i) => s + (i.price ?? 0), 0),
    []
  );
  const byStore = useMemo(() => {
    const map: Record<string, ShoppingItem[]> = {};
    for (const it of shoppingList) {
      (map[it.store] = map[it.store] || []).push(it);
    }
    return map;
  }, []);

  const openPrep = (meal: PlannedMeal) => {
    router.push("/flow/recipe" as any);
  };

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
          Votre semaine générée après l'étape 12. Calendrier, achats et préparation.
        </Text>

        <View style={styles.demoBadge}>
          <Ionicons name="information-circle-outline" size={14} color={colors.onBrandTertiary} />
          <Text style={styles.demoBadgeText}>Données de démonstration</Text>
        </View>

        {/* Résumé */}
        <View style={styles.summaryRow}>
          <View style={styles.summaryCard}>
            <Text style={styles.summaryLabel}>Repas planifiés</Text>
            <Text style={styles.summaryValue}>{totalPlanned}</Text>
          </View>
          <View style={styles.summaryCard}>
            <Text style={styles.summaryLabel}>Confirmés</Text>
            <Text style={[styles.summaryValue, { color: colors.brandPrimary }]}>
              {confirmedCount}/{totalPlanned}
            </Text>
          </View>
          <View style={styles.summaryCard}>
            <Text style={styles.summaryLabel}>Achat prévu</Text>
            <Text style={[styles.summaryValue, { color: colors.brandTertiary }]}>
              {totalBudget.toFixed(2)} €
            </Text>
          </View>
        </View>

        {/* Tabs */}
        <View style={styles.tabs}>
          {(
            [
              { id: "calendar", label: "Calendrier", icon: "calendar-outline" },
              { id: "shopping", label: "Manquants", icon: "cart-outline" },
              { id: "prep", label: "Préparation", icon: "flame-outline" },
            ] as { id: Tab; label: string; icon: any }[]
          ).map((t) => {
            const active = tab === t.id;
            return (
              <Pressable
                key={t.id}
                testID={`meals-tab-${t.id}`}
                onPress={() => setTab(t.id)}
                style={[styles.tab, active && styles.tabActive]}
              >
                <Ionicons name={t.icon} size={16} color={active ? colors.onBrandPrimary : colors.brandPrimary} />
                <Text style={[styles.tabText, active && styles.tabTextActive]}>{t.label}</Text>
              </Pressable>
            );
          })}
        </View>

        {tab === "calendar" && (
          <View>
            {weeklyPlan.map((d) => (
              <View key={d.day} testID={`day-${d.day}`} style={styles.dayBlock}>
                <View style={styles.dayHeader}>
                  <Text style={styles.dayTitle}>{d.day}</Text>
                  <Text style={styles.dayCount}>{d.meals.length} repas</Text>
                </View>
                {d.meals.map((m) => (
                  <Pressable
                    key={m.id}
                    testID={`meal-${m.id}`}
                    onPress={() => openPrep(m)}
                    style={({ pressed }) => [styles.mealCard, pressed && { opacity: 0.85 }]}
                  >
                    <Text style={styles.mealEmoji}>{m.emoji}</Text>
                    <View style={{ flex: 1 }}>
                      <View style={styles.slotRow}>
                        <Text style={styles.slotBadgeText}>{m.slot}</Text>
                        <Text style={styles.timeText}>· {m.time} min</Text>
                        {m.noPurchase && (
                          <View style={styles.noPurchaseBadge}>
                            <Text style={styles.noPurchaseText}>0 € achat</Text>
                          </View>
                        )}
                        {m.confirmed && (
                          <View style={styles.confirmedBadge}>
                            <Ionicons name="checkmark-circle" size={12} color={colors.onSuccess} />
                          </View>
                        )}
                      </View>
                      <Text style={styles.mealTitle}>{m.title}</Text>
                    </View>
                    <Ionicons name="chevron-forward" size={18} color={colors.muted} />
                  </Pressable>
                ))}
              </View>
            ))}
          </View>
        )}

        {tab === "shopping" && (
          <View>
            <View style={styles.helperBanner}>
              <Ionicons name="information-circle-outline" size={16} color={colors.onBrandTertiary} />
              <Text style={styles.helperText}>Trié par magasin et rayon. Les prix viennent d'Open Prices.</Text>
            </View>
            {Object.entries(byStore).map(([store, items]) => {
              const storeTotal = items.reduce((s, i) => s + (i.price ?? 0), 0);
              return (
                <View key={store} testID={`store-${store}`} style={styles.storeBlock}>
                  <View style={styles.storeHeader}>
                    <View style={styles.storeIcon}>
                      <Ionicons name="storefront" size={16} color={colors.onBrandSecondary} />
                    </View>
                    <Text style={styles.storeName}>{store}</Text>
                    <Text style={styles.storeTotal}>{storeTotal.toFixed(2)} €</Text>
                  </View>
                  {items.map((it) => (
                    <View key={it.id} style={styles.shopRow}>
                      <View style={[styles.rayonDot, { backgroundColor: RAYON_COLORS[it.rayon] }]} />
                      <View style={{ flex: 1 }}>
                        <Text style={styles.itemLabel}>{it.label}</Text>
                        <Text style={styles.itemMeta}>
                          {it.qty} · Rayon {it.rayon}
                        </Text>
                      </View>
                      {typeof it.price === "number" && (
                        <Text style={styles.itemPrice}>{it.price.toFixed(2)} €</Text>
                      )}
                    </View>
                  ))}
                </View>
              );
            })}
          </View>
        )}

        {tab === "prep" && (
          <View>
            <View style={styles.helperBanner}>
              <Ionicons name="information-circle-outline" size={16} color={colors.onBrandTertiary} />
              <Text style={styles.helperText}>
                Préparation intuitive : une instruction à la fois, minuteurs et mains libres.
              </Text>
            </View>
            {weeklyPlan
              .flatMap((d) => d.meals.map((m) => ({ ...m, day: d.day })))
              .filter((m) => !m.confirmed)
              .slice(0, 4)
              .map((m) => (
                <Pressable
                  key={m.id}
                  testID={`prep-${m.id}`}
                  onPress={() => openPrep(m)}
                  style={({ pressed }) => [styles.prepCard, pressed && { opacity: 0.85 }]}
                >
                  <Text style={styles.mealEmoji}>{m.emoji}</Text>
                  <View style={{ flex: 1 }}>
                    <Text style={styles.slotBadgeText}>
                      {m.day} · {m.slot}
                    </Text>
                    <Text style={styles.mealTitle}>{m.title}</Text>
                    <Text style={styles.itemMeta}>{m.time} min · préparation guidée</Text>
                  </View>
                  <View style={styles.playBtn}>
                    <Ionicons name="play" size={16} color={colors.onBrandPrimary} />
                  </View>
                </Pressable>
              ))}
          </View>
        )}
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: colors.surface },
  pageTitle: { ...typography.display, color: colors.onSurface, marginBottom: spacing.xs },
  pageSubtitle: { ...typography.body, color: colors.muted, lineHeight: 22, marginBottom: spacing.md },
  demoBadge: {
    alignSelf: "flex-start",
    flexDirection: "row",
    alignItems: "center",
    gap: 4,
    backgroundColor: colors.brandTertiaryMuted,
    paddingHorizontal: 10,
    paddingVertical: 5,
    borderRadius: radius.pill,
    marginBottom: spacing.lg,
  },
  demoBadgeText: { ...typography.caption, color: colors.onBrandTertiary },
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
  tabs: {
    flexDirection: "row",
    backgroundColor: colors.surfaceSecondary,
    borderRadius: radius.pill,
    padding: 4,
    marginBottom: spacing.lg,
    ...shadow.soft,
  },
  tab: {
    flex: 1,
    flexDirection: "row",
    justifyContent: "center",
    alignItems: "center",
    gap: 6,
    paddingVertical: 10,
    borderRadius: radius.pill,
  },
  tabActive: { backgroundColor: colors.brandPrimary },
  tabText: { ...typography.small, color: colors.brandPrimary, fontWeight: "700" },
  tabTextActive: { color: colors.onBrandPrimary },
  dayBlock: { marginBottom: spacing.md },
  dayHeader: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    marginBottom: spacing.sm,
  },
  dayTitle: { ...typography.h3, color: colors.brandPrimary, fontWeight: "800" },
  dayCount: { ...typography.caption, color: colors.muted },
  mealCard: {
    flexDirection: "row",
    alignItems: "center",
    gap: spacing.md,
    backgroundColor: colors.surfaceSecondary,
    borderRadius: radius.lg,
    padding: spacing.md,
    marginBottom: spacing.sm,
    ...shadow.soft,
  },
  mealEmoji: { fontSize: 28 },
  slotRow: { flexDirection: "row", alignItems: "center", gap: 6, flexWrap: "wrap" },
  slotBadgeText: { ...typography.caption, color: colors.brandPrimary, fontWeight: "700" },
  timeText: { ...typography.caption, color: colors.muted },
  noPurchaseBadge: {
    backgroundColor: colors.brandSecondaryMuted,
    paddingHorizontal: 8,
    paddingVertical: 2,
    borderRadius: radius.pill,
  },
  noPurchaseText: { fontSize: 10, color: colors.onBrandSecondary, fontWeight: "700" },
  confirmedBadge: {
    backgroundColor: colors.success,
    width: 20, height: 20, borderRadius: 10,
    alignItems: "center", justifyContent: "center",
  },
  mealTitle: { ...typography.bodyMd, color: colors.onSurface, marginTop: 2 },
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
  storeBlock: {
    backgroundColor: colors.surfaceSecondary,
    borderRadius: radius.lg,
    padding: spacing.lg,
    marginBottom: spacing.md,
    ...shadow.soft,
  },
  storeHeader: { flexDirection: "row", alignItems: "center", gap: spacing.sm, marginBottom: spacing.sm },
  storeIcon: {
    width: 28, height: 28, borderRadius: 14,
    backgroundColor: colors.brandSecondaryMuted,
    alignItems: "center", justifyContent: "center",
  },
  storeName: { flex: 1, ...typography.h3, color: colors.onSurface },
  storeTotal: { ...typography.bodyMd, color: colors.brandTertiary, fontWeight: "800" },
  shopRow: {
    flexDirection: "row",
    alignItems: "center",
    gap: spacing.md,
    paddingVertical: spacing.sm,
    borderBottomWidth: 1,
    borderBottomColor: colors.divider,
  },
  rayonDot: { width: 10, height: 10, borderRadius: 5 },
  itemLabel: { ...typography.bodyMd, color: colors.onSurface },
  itemMeta: { ...typography.caption, color: colors.muted, marginTop: 2 },
  itemPrice: { ...typography.bodyMd, color: colors.brandPrimary, fontWeight: "700" },
  prepCard: {
    flexDirection: "row",
    alignItems: "center",
    gap: spacing.md,
    backgroundColor: colors.surfaceSecondary,
    borderRadius: radius.lg,
    padding: spacing.md,
    marginBottom: spacing.sm,
    ...shadow.soft,
  },
  playBtn: {
    width: 36, height: 36, borderRadius: 18,
    backgroundColor: colors.brandPrimary,
    alignItems: "center", justifyContent: "center",
  },
});
