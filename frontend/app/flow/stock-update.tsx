import React from "react";
import { View, Text, StyleSheet, ScrollView } from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { useRouter } from "expo-router";
import { Ionicons } from "@expo/vector-icons";
import FlowHeader from "@/src/components/FlowHeader";
import PrimaryButton from "@/src/components/PrimaryButton";
import { useMenoo } from "@/src/store/menoo";
import { colors, radius, spacing, typography, shadow } from "@/src/theme/tokens";

export default function StockUpdateScreen() {
  const insets = useSafeAreaInsets();
  const router = useRouter();
  const { pantry } = useMenoo();

  return (
    <View style={styles.container}>
      <FlowHeader title="Stock mis à jour" />
      <ScrollView
        contentContainerStyle={{
          paddingHorizontal: spacing.lg,
          paddingBottom: spacing.xxxl + insets.bottom,
        }}
      >
        <View style={styles.hero}>
          <View style={styles.check}>
            <Ionicons name="checkmark" size={44} color={colors.onBrandPrimary} />
          </View>
          <Text style={styles.title}>C'est fait, vos réserves sont à jour</Text>
          <Text style={styles.subtitle}>
            Vous n'aurez pas à tout renseigner la prochaine fois. Menoo garde vos quantités en mémoire.
          </Text>
        </View>

        <View style={styles.card}>
          <Text style={styles.sectionTitle}>Réserves restantes</Text>
          <View style={{ marginTop: spacing.sm }}>
            {pantry.map((p) => (
              <View key={p.id} testID={`stock-${p.id}`} style={styles.row}>
                <Text style={styles.emoji}>{p.emoji}</Text>
                <View style={{ flex: 1 }}>
                  <Text style={styles.name}>{p.name}</Text>
                  <Text style={styles.qty}>
                    {p.available} {p.unit} restants sur {p.containerSize} {p.unit}
                  </Text>
                </View>
                <View style={styles.track}>
                  <View
                    style={[
                      styles.fill,
                      {
                        width: `${Math.round((p.available / p.containerSize) * 100)}%`,
                        backgroundColor: p.available === 0 ? colors.error : colors.brandPrimary,
                      },
                    ]}
                  />
                </View>
              </View>
            ))}
          </View>
        </View>

        <PrimaryButton
          testID="btn-back-pantry"
          label="Retour à mes réserves"
          onPress={() => router.replace("/(tabs)/pantry")}
        />
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: colors.surface },
  hero: { alignItems: "center", paddingVertical: spacing.xl },
  check: {
    width: 88, height: 88, borderRadius: 44,
    backgroundColor: colors.brandPrimary,
    justifyContent: "center", alignItems: "center",
    marginBottom: spacing.lg,
    ...shadow.card,
  },
  title: { ...typography.h1, color: colors.onSurface, textAlign: "center", marginBottom: spacing.sm },
  subtitle: {
    ...typography.body, color: colors.muted, textAlign: "center", lineHeight: 22,
    paddingHorizontal: spacing.md,
  },
  card: {
    backgroundColor: colors.surfaceSecondary,
    borderRadius: radius.lg,
    padding: spacing.lg,
    marginBottom: spacing.lg,
    ...shadow.soft,
  },
  sectionTitle: { ...typography.h3, color: colors.onSurface, marginBottom: spacing.sm },
  row: {
    flexDirection: "column",
    gap: 6,
    paddingVertical: spacing.md,
    borderBottomWidth: 1,
    borderBottomColor: colors.divider,
  },
  emoji: { fontSize: 22, position: "absolute", top: spacing.md },
  name: { ...typography.bodyMd, color: colors.onSurface, marginLeft: 34 },
  qty: { ...typography.small, color: colors.muted, marginLeft: 34 },
  track: {
    height: 8,
    borderRadius: radius.pill,
    backgroundColor: colors.brandSecondaryMuted,
    overflow: "hidden",
    marginTop: 4,
    marginLeft: 34,
  },
  fill: { height: "100%", borderRadius: radius.pill },
});
