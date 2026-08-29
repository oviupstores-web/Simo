import React, { useMemo } from "react";
import { View, Text, StyleSheet, ScrollView, Pressable } from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { Ionicons } from "@expo/vector-icons";
import { shoppingList, substitutions, ShoppingItem } from "@/src/services/mockData";
import { useMenoo } from "@/src/store/menoo";
import { colors, radius, spacing, typography, shadow } from "@/src/theme/tokens";

const RAYON_COLORS: Record<ShoppingItem["rayon"], string> = {
  "Frais": "#7DB88E",
  "Sec": "#D4AF37",
  "Fruits & Légumes": "#A3CBAF",
  "Boucherie": "#CC5A47",
  "Épicerie": "#E0B647",
};

export default function CoursesScreen() {
  const insets = useSafeAreaInsets();
  const { purchased, togglePurchased } = useMenoo();

  const byStore = useMemo(() => {
    const map: Record<string, ShoppingItem[]> = {};
    for (const it of shoppingList) (map[it.store] = map[it.store] || []).push(it);
    return map;
  }, []);
  const total = shoppingList.reduce((s, i) => s + (i.price ?? 0), 0);
  const remaining = shoppingList.reduce((s, i) => s + (purchased[i.id] ? 0 : i.price ?? 0), 0);
  const boughtCount = shoppingList.filter((i) => purchased[i.id]).length;
  const itemCount = shoppingList.length;

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
        <Text style={styles.pageTitle}>Courses</Text>
        <Text style={styles.pageSubtitle}>
          La liste triée par magasin et rayon, générée à partir de vos menus et de vos réserves.
        </Text>

        <View style={styles.summaryRow}>
          <View style={styles.summaryCard}>
            <Text style={styles.summaryLabel}>Articles</Text>
            <Text style={styles.summaryValue}>{boughtCount}/{itemCount}</Text>
          </View>
          <View style={styles.summaryCard}>
            <Text style={styles.summaryLabel}>Total prévu</Text>
            <Text style={[styles.summaryValue, { color: colors.brandTertiary }]}>{total.toFixed(2)} €</Text>
          </View>
          <View testID="remaining-card" style={[styles.summaryCard, { backgroundColor: colors.brandPrimary }]}>
            <Text style={[styles.summaryLabel, { color: colors.onSurfaceInverse, opacity: 0.8 }]}>Reste à payer</Text>
            <Text style={[styles.summaryValue, { color: colors.onSurfaceInverse }]}>{remaining.toFixed(2)} €</Text>
          </View>
        </View>

        <View style={styles.helperBanner}>
          <Ionicons name="information-circle-outline" size={16} color={colors.onBrandTertiary} />
          <Text style={styles.helperText}>Prix issus d'Open Prices. Aucun rayon inventé — seulement observés.</Text>
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
              {items.map((it) => {
                const isPurchased = purchased[it.id];
                return (
                  <Pressable
                    key={it.id}
                    testID={`item-${it.id}`}
                    onPress={() => togglePurchased(it.id)}
                    style={({ pressed }) => [styles.shopRow, pressed && { opacity: 0.85 }]}
                  >
                    <View style={[styles.checkbox, isPurchased && styles.checkboxOn]}>
                      {isPurchased && (
                        <Ionicons name="checkmark" size={14} color={colors.onBrandPrimary} />
                      )}
                    </View>
                    <View style={[styles.rayonDot, { backgroundColor: RAYON_COLORS[it.rayon] }]} />
                    <View style={{ flex: 1 }}>
                      <Text style={[styles.itemLabel, isPurchased && styles.itemLabelDone]}>
                        {it.label}
                      </Text>
                      <Text style={styles.itemMeta}>
                        {it.qty} · Rayon {it.rayon}
                      </Text>
                    </View>
                    {typeof it.price === "number" && (
                      <Text style={[styles.itemPrice, isPurchased && styles.itemPriceDone]}>
                        {it.price.toFixed(2)} €
                      </Text>
                    )}
                  </Pressable>
                );
              })}
            </View>
          );
        })}

        <View style={styles.subsHeader}>
          <Ionicons name="sparkles" size={16} color={colors.brandTertiary} />
          <Text style={styles.subsTitle}>Substitutions IA</Text>
        </View>
        <Text style={styles.subsHint}>
          Si un ingrédient manque, Menoo propose une alternative compatible avec la recette.
        </Text>
        <View style={styles.subsList}>
          {substitutions.map((s, i) => (
            <View key={i} testID={`sub-${i}`} style={styles.subCard}>
              <View style={styles.subIcon}>
                <Ionicons name="repeat" size={18} color={colors.brandPrimary} />
              </View>
              <View style={{ flex: 1 }}>
                <View style={styles.subRow}>
                  <Text style={styles.subMissing}>{s.missing}</Text>
                  <Ionicons name="arrow-forward" size={14} color={colors.muted} />
                  <Text style={styles.subSuggestion}>{s.suggestion}</Text>
                </View>
                <Text style={styles.subNote}>{s.note}</Text>
              </View>
            </View>
          ))}
        </View>
      </ScrollView>
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
  checkbox: {
    width: 22, height: 22, borderRadius: 6,
    borderWidth: 2, borderColor: colors.brandPrimary,
    alignItems: "center", justifyContent: "center",
    backgroundColor: colors.surfaceSecondary,
  },
  checkboxOn: { backgroundColor: colors.brandPrimary },
  itemLabel: { ...typography.bodyMd, color: colors.onSurface },
  itemLabelDone: { color: colors.muted, textDecorationLine: "line-through" },
  itemMeta: { ...typography.caption, color: colors.muted, marginTop: 2 },
  itemPrice: { ...typography.bodyMd, color: colors.brandPrimary, fontWeight: "700" },
  itemPriceDone: { color: colors.muted, textDecorationLine: "line-through" },
  subsHeader: {
    flexDirection: "row",
    alignItems: "center",
    gap: 8,
    marginTop: spacing.lg,
    marginBottom: 4,
  },
  subsTitle: { ...typography.h2, color: colors.onSurface },
  subsHint: { ...typography.small, color: colors.muted, marginBottom: spacing.md, lineHeight: 19 },
  subsList: { gap: spacing.sm },
  subCard: {
    flexDirection: "row",
    gap: spacing.md,
    padding: spacing.lg,
    backgroundColor: colors.surfaceSecondary,
    borderRadius: radius.md,
    ...shadow.soft,
  },
  subIcon: {
    width: 36, height: 36, borderRadius: radius.md,
    backgroundColor: colors.brandSecondaryMuted,
    alignItems: "center", justifyContent: "center",
  },
  subRow: { flexDirection: "row", alignItems: "center", gap: 6, flexWrap: "wrap" },
  subMissing: { ...typography.bodyMd, color: colors.onSurface, fontWeight: "700" },
  subSuggestion: { ...typography.bodyMd, color: colors.brandPrimary, fontWeight: "700" },
  subNote: { ...typography.small, color: colors.muted, marginTop: 4, lineHeight: 18 },
});
