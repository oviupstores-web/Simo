import React from "react";
import { View, Text, StyleSheet, ScrollView, Pressable } from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { Ionicons } from "@expo/vector-icons";
import Logo from "@/src/components/Logo";
import { useMenoo } from "@/src/store/menoo";
import { getRecipe } from "@/src/services/recipes";
import { colors, radius, spacing, typography, shadow } from "@/src/theme/tokens";

const rows: { icon: any; label: string; hint: string }[] = [
  { icon: "person-circle-outline", label: "Mon profil / mon foyer", hint: "Modifiable à tout moment" },
  { icon: "leaf-outline", label: "Préférences alimentaires", hint: "Régimes, allergies, goûts" },
  { icon: "cart-outline", label: "Magasins préférés", hint: "Carrefour Market, Monoprix" },
  { icon: "notifications-outline", label: "Rappels doux", hint: "Activés" },
  { icon: "lock-closed-outline", label: "Confidentialité", hint: "Données locales uniquement" },
];

const sources: { icon: any; label: string; role: string; color: string }[] = [
  { icon: "pricetag-outline", label: "Open Food Facts", role: "Identification produits, contenance, portions, nutrition", color: colors.brandPrimary },
  { icon: "wallet-outline", label: "Open Prices", role: "Prix observés, date, magasin (jamais la contenance)", color: colors.brandTertiary },
  { icon: "nutrition-outline", label: "Ciqual / Anses", role: "Composition nutritionnelle des aliments génériques", color: colors.success },
  { icon: "sparkles-outline", label: "Moteur menus & recettes", role: "Explique et reformule (aucun calcul de prix ni de nutrition)", color: colors.brandSecondary },
  { icon: "server-outline", label: "Consolidation Menoo", role: "Croisement produit + réserves + repas + portions", color: colors.brandPrimary },
  { icon: "shield-checkmark-outline", label: "Supabase", role: "Vos profils, réserves, recettes et historique", color: colors.muted },
];

export default function ProfileScreen() {
  const insets = useSafeAreaInsets();
  const { pinned, togglePinned } = useMenoo();
  const pinnedList = Object.entries(pinned)
    .filter(([, v]) => v)
    .map(([recipeId]) => ({ recipeId, recipe: getRecipe(recipeId) }))
    .filter((item) => item.recipe !== null);
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
        <Text style={styles.pageTitle}>Profil</Text>
        <Text style={styles.pageSubtitle}>Menoo s'adapte à vous. Ajustez tout ce qui vous ressemble.</Text>

        <View style={styles.hero}>
          <Logo size={56} showWordmark={false} />
          <Text style={styles.heroName}>Bonjour</Text>
          <Text style={styles.heroSub}>Compte invité — sans inscription</Text>
        </View>

        <View style={styles.list}>
          {rows.map((r, i) => (
            <View key={i} testID={`profile-row-${i}`} style={styles.row}>
              <View style={styles.rowIcon}>
                <Ionicons name={r.icon} size={22} color={colors.brandPrimary} />
              </View>
              <View style={{ flex: 1 }}>
                <Text style={styles.rowLabel}>{r.label}</Text>
                <Text style={styles.rowHint}>{r.hint}</Text>
              </View>
              <Ionicons name="chevron-forward" size={18} color={colors.muted} />
            </View>
          ))}
        </View>

        <Text style={styles.sectionTitle}>Historique épinglés</Text>
        <Text style={styles.sectionHint}>
          Vos plats préférés qui reviennent automatiquement toutes les 2–3 semaines.
        </Text>
        <View testID="pinned-list" style={styles.list}>
          {pinnedList.length === 0 ? (
            <View style={styles.emptyRow}>
              <Ionicons name="heart-outline" size={22} color={colors.muted} />
              <Text style={styles.emptyText}>
                Aucun plat épinglé. Tapez sur le cœur d'un repas depuis Menus pour l'ajouter.
              </Text>
            </View>
          ) : (
            pinnedList.map(({ recipeId, recipe }, i) => (
              <View key={recipeId} testID={`pinned-item-${i}`} style={styles.row}>
                <View style={[styles.rowIcon, { backgroundColor: colors.brandTertiaryMuted }]}>
                  <Ionicons name="heart" size={20} color={colors.brandTertiary} />
                </View>
                <View style={{ flex: 1 }}>
                  <Text style={styles.rowLabel}>{recipe?.title}</Text>
                  <Text style={styles.rowHint}>Reviendra automatiquement dans 2–3 semaines</Text>
                </View>
                <Pressable
                  testID={`unpin-${i}`}
                  onPress={() => togglePinned(recipeId)}
                  hitSlop={8}
                  style={styles.unpinBtn}
                >
                  <Ionicons name="close" size={16} color={colors.muted} />
                </Pressable>
              </View>
            ))
          )}
        </View>

        <Text style={styles.sectionTitle}>Sources & moteurs</Text>
        <Text style={styles.sectionHint}>
          Transparence complète sur les sources utilisées par Menoo.
        </Text>
        <View style={styles.list}>
          {sources.map((s, i) => (
            <View key={i} testID={`source-${i}`} style={styles.row}>
              <View style={[styles.rowIcon, { backgroundColor: s.color + "22" }]}>
                <Ionicons name={s.icon} size={22} color={s.color} />
              </View>
              <View style={{ flex: 1 }}>
                <Text style={styles.rowLabel}>{s.label}</Text>
                <Text style={styles.rowHint}>{s.role}</Text>
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
  pageSubtitle: { ...typography.body, color: colors.muted, marginBottom: spacing.lg },
  hero: {
    backgroundColor: colors.surfaceSecondary,
    borderRadius: radius.lg,
    padding: spacing.xl,
    alignItems: "center",
    marginBottom: spacing.lg,
    ...shadow.soft,
  },
  heroName: { ...typography.h2, color: colors.onSurface, marginTop: spacing.md },
  heroSub: { ...typography.small, color: colors.muted, marginTop: 2 },
  list: {
    backgroundColor: colors.surfaceSecondary,
    borderRadius: radius.lg,
    ...shadow.soft,
    overflow: "hidden",
    marginBottom: spacing.lg,
  },
  row: {
    flexDirection: "row",
    alignItems: "center",
    gap: spacing.md,
    padding: spacing.lg,
    borderBottomWidth: 1,
    borderBottomColor: colors.divider,
  },
  rowIcon: {
    width: 40,
    height: 40,
    borderRadius: radius.md,
    backgroundColor: colors.brandSecondaryMuted,
    alignItems: "center",
    justifyContent: "center",
  },
  rowLabel: { ...typography.bodyMd, color: colors.onSurface },
  rowHint: { ...typography.small, color: colors.muted, marginTop: 2 },
  sectionTitle: { ...typography.h2, color: colors.onSurface, marginBottom: 4 },
  sectionHint: { ...typography.small, color: colors.muted, marginBottom: spacing.md, lineHeight: 19 },
  emptyRow: { flexDirection: "row", alignItems: "center", gap: spacing.md, padding: spacing.lg },
  emptyText: { flex: 1, ...typography.small, color: colors.muted, lineHeight: 19 },
  unpinBtn: {
    width: 28, height: 28, borderRadius: 14,
    backgroundColor: colors.surfaceTertiary,
    alignItems: "center", justifyContent: "center",
  },
});
