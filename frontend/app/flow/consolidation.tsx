import React, { useEffect, useState } from "react";
import { View, Text, StyleSheet, ScrollView, ActivityIndicator } from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { useRouter } from "expo-router";
import { Ionicons } from "@expo/vector-icons";
import FlowHeader from "@/src/components/FlowHeader";
import PrimaryButton from "@/src/components/PrimaryButton";
import { colors, radius, spacing, typography, shadow } from "@/src/theme/tokens";

const sources = [
  {
    id: "off",
    name: "Open Food Facts",
    role: "Identification des produits, contenance totale, unité, portions et données nutritionnelles.",
    icon: "pricetag-outline" as const,
    color: colors.brandPrimary,
  },
  {
    id: "op",
    name: "Open Prices",
    role: "Uniquement pour les prix observés, leur date et leur magasin.",
    icon: "wallet-outline" as const,
    color: colors.brandTertiary,
    note: "Open Prices ne fournit jamais la contenance ni le volume du produit.",
  },
  {
    id: "menoo",
    name: "Moteur Menoo",
    role: "Calcul des quantités disponibles et vérification de compatibilité avec le repas demandé.",
    icon: "sparkles-outline" as const,
    color: colors.brandSecondary,
  },
];

export default function ConsolidationScreen() {
  const insets = useSafeAreaInsets();
  const router = useRouter();
  const [progress, setProgress] = useState(0); // 0..3

  useEffect(() => {
    const timers = [
      setTimeout(() => setProgress(1), 500),
      setTimeout(() => setProgress(2), 1100),
      setTimeout(() => setProgress(3), 1700),
    ];
    return () => timers.forEach(clearTimeout);
  }, []);

  return (
    <View style={styles.container}>
      <FlowHeader title="Consolidation" step={2} totalSteps={6} />
      <ScrollView
        contentContainerStyle={{
          paddingHorizontal: spacing.lg,
          paddingBottom: spacing.xxxl + insets.bottom,
        }}
      >
        <Text style={styles.title}>Menoo croise plusieurs sources</Text>
        <Text style={styles.subtitle}>
          Nous identifions vos produits, la contenance et calculons vos quantités. Vos données restent chez vous.
        </Text>

        <View style={styles.list}>
          {sources.map((s, i) => {
            const done = progress > i;
            const loading = progress === i;
            return (
              <View key={s.id} testID={`source-${s.id}`} style={styles.card}>
                <View style={[styles.iconWrap, { backgroundColor: s.color + "22" }]}>
                  <Ionicons name={s.icon} size={22} color={s.color} />
                </View>
                <View style={{ flex: 1 }}>
                  <Text style={styles.cardName}>{s.name}</Text>
                  <Text style={styles.cardRole}>{s.role}</Text>
                  {s.note && (
                    <View style={styles.noteRow}>
                      <Ionicons name="alert-circle-outline" size={14} color={colors.warning} />
                      <Text style={styles.noteText}>{s.note}</Text>
                    </View>
                  )}
                </View>
                <View style={styles.status}>
                  {done ? (
                    <Ionicons name="checkmark-circle" size={26} color={colors.brandPrimary} />
                  ) : loading ? (
                    <ActivityIndicator color={colors.brandPrimary} />
                  ) : (
                    <View style={styles.dot} />
                  )}
                </View>
              </View>
            );
          })}
        </View>

        <PrimaryButton
          testID="btn-continue-confirm"
          label="Continuer"
          onPress={() => router.push("/flow/confirmation")}
          disabled={progress < 3}
        />
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: colors.surface },
  title: { ...typography.h1, color: colors.onSurface, marginBottom: spacing.xs },
  subtitle: { ...typography.body, color: colors.muted, marginBottom: spacing.lg, lineHeight: 22 },
  list: { gap: spacing.md, marginBottom: spacing.lg },
  card: {
    flexDirection: "row",
    alignItems: "flex-start",
    gap: spacing.md,
    backgroundColor: colors.surfaceSecondary,
    borderRadius: radius.lg,
    padding: spacing.lg,
    ...shadow.soft,
  },
  iconWrap: {
    width: 44, height: 44, borderRadius: radius.md,
    justifyContent: "center", alignItems: "center",
  },
  cardName: { ...typography.h3, color: colors.onSurface, marginBottom: 4 },
  cardRole: { ...typography.small, color: colors.muted, lineHeight: 19 },
  noteRow: { flexDirection: "row", gap: 6, marginTop: spacing.sm, alignItems: "flex-start" },
  noteText: { flex: 1, ...typography.caption, color: colors.warning, lineHeight: 16 },
  status: { width: 32, alignItems: "center", justifyContent: "center", paddingTop: 6 },
  dot: { width: 12, height: 12, borderRadius: 6, backgroundColor: colors.border },
});
