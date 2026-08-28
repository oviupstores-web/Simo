import React from "react";
import { View, Text, StyleSheet, ScrollView } from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { Ionicons } from "@expo/vector-icons";
import { colors, radius, spacing, typography, shadow } from "@/src/theme/tokens";

const rows: { icon: any; label: string; hint: string }[] = [
  { icon: "person-circle-outline", label: "Mon foyer", hint: "2 adultes" },
  { icon: "leaf-outline", label: "Préférences alimentaires", hint: "Aucune allergie signalée" },
  { icon: "cart-outline", label: "Magasins préférés", hint: "Carrefour Market, Monoprix" },
  { icon: "notifications-outline", label: "Rappels doux", hint: "Activés" },
  { icon: "lock-closed-outline", label: "Confidentialité", hint: "Données locales uniquement" },
];

export default function ProfileScreen() {
  const insets = useSafeAreaInsets();
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
          <View style={styles.avatar}>
            <Text style={styles.avatarText}>M</Text>
          </View>
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
  avatar: {
    width: 72,
    height: 72,
    borderRadius: 36,
    backgroundColor: colors.brandSecondaryMuted,
    alignItems: "center",
    justifyContent: "center",
    marginBottom: spacing.md,
  },
  avatarText: { fontSize: 32, fontWeight: "700", color: colors.brandPrimary },
  heroName: { ...typography.h2, color: colors.onSurface },
  heroSub: { ...typography.small, color: colors.muted, marginTop: 2 },
  list: {
    backgroundColor: colors.surfaceSecondary,
    borderRadius: radius.lg,
    ...shadow.soft,
    overflow: "hidden",
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
});
