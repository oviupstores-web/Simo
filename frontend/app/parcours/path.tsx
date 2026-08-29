import React from "react";
import { View, Text, StyleSheet, ScrollView, Pressable } from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { useRouter } from "expo-router";
import { Ionicons } from "@expo/vector-icons";
import FlowHeader from "@/src/components/FlowHeader";
import Logo from "@/src/components/Logo";
import { useMenoo, ParcoursType } from "@/src/store/menoo";
import { PARCOURS_LABELS, PARCOURS_DESC } from "@/src/services/steps";
import { colors, radius, spacing, typography, shadow } from "@/src/theme/tokens";

const CARDS: { id: ParcoursType; icon: any }[] = [
  { id: "pour-moi", icon: "person-outline" },
  { id: "pour-famille", icon: "people-outline" },
];

export default function PathScreen() {
  const insets = useSafeAreaInsets();
  const router = useRouter();
  const { setParcours, setCurrentStep } = useMenoo();

  const onSelect = (id: ParcoursType) => {
    setParcours(id);
    setCurrentStep(1);
    router.push(`/parcours/${id}/1` as any);
  };

  return (
    <View style={styles.container}>
      <FlowHeader title="Ouverture Menoo" />
      <ScrollView
        contentContainerStyle={{
          paddingHorizontal: spacing.lg,
          paddingBottom: spacing.xxxl + insets.bottom,
          paddingTop: spacing.sm,
        }}
      >
        <View style={styles.brand}>
          <Logo size={44} />
        </View>
        <Text style={styles.title}>Comment Menoo doit m'accompagner</Text>
        <Text style={styles.subtitle}>
          Deux parcours en 12 étapes. Tout reste modifiable plus tard.
        </Text>

        {CARDS.map((c) => (
          <Pressable
            key={c.id}
            testID={`path-${c.id}`}
            onPress={() => onSelect(c.id)}
            style={({ pressed }) => [styles.card, pressed && { opacity: 0.9 }]}
          >
            <View style={styles.iconWrap}>
              <Ionicons name={c.icon} size={28} color={colors.brandPrimary} />
            </View>
            <View style={{ flex: 1 }}>
              <Text style={styles.cardTitle}>{PARCOURS_LABELS[c.id]}</Text>
              <Text style={styles.cardDesc}>{PARCOURS_DESC[c.id]}</Text>
            </View>
            <Ionicons name="chevron-forward" size={22} color={colors.muted} />
          </Pressable>
        ))}

        <View style={styles.note}>
          <Ionicons name="information-circle-outline" size={16} color={colors.onBrandTertiary} />
          <Text style={styles.noteText}>
            À l'étape 7, vous choisirez entre courses, réserves ou mixte. « Avec ce que j'ai » se pilote depuis là.
          </Text>
        </View>
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: colors.surface },
  brand: { alignItems: "flex-start", marginBottom: spacing.lg },
  title: { ...typography.h1, color: colors.onSurface, marginBottom: spacing.xs },
  subtitle: { ...typography.body, color: colors.muted, lineHeight: 22, marginBottom: spacing.lg },
  card: {
    flexDirection: "row",
    alignItems: "center",
    gap: spacing.md,
    backgroundColor: colors.surfaceSecondary,
    borderRadius: radius.lg,
    padding: spacing.lg,
    marginBottom: spacing.md,
    ...shadow.soft,
  },
  iconWrap: {
    width: 56, height: 56, borderRadius: radius.md,
    backgroundColor: colors.brandSecondaryMuted,
    justifyContent: "center", alignItems: "center",
  },
  cardTitle: { ...typography.h2, color: colors.onSurface, marginBottom: 4 },
  cardDesc: { ...typography.small, color: colors.muted, lineHeight: 20 },
  note: {
    flexDirection: "row",
    gap: 6,
    padding: spacing.md,
    backgroundColor: colors.brandTertiaryMuted,
    borderRadius: radius.md,
    alignItems: "center",
    marginTop: spacing.sm,
  },
  noteText: { flex: 1, ...typography.caption, color: colors.onBrandTertiary, lineHeight: 17 },
});
