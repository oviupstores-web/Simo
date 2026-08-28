import React from "react";
import { View, Text, StyleSheet, ScrollView, Pressable } from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { useRouter } from "expo-router";
import { Ionicons } from "@expo/vector-icons";
import FlowHeader from "@/src/components/FlowHeader";
import StepProgress from "@/src/components/StepProgress";
import PrimaryButton from "@/src/components/PrimaryButton";
import { useMenoo } from "@/src/store/menoo";
import { colors, radius, spacing, typography, shadow } from "@/src/theme/tokens";

const REASONS: { id: string; label: string; icon: any }[] = [
  { id: "gagner-temps", label: "Gagner du temps", icon: "time-outline" },
  { id: "budget", label: "Respecter mon budget", icon: "wallet-outline" },
  { id: "mieux-manger", label: "Mieux manger", icon: "leaf-outline" },
  { id: "cuisiner-reserves", label: "Cuisiner mes réserves", icon: "basket-outline" },
];

export default function EntryScreen() {
  const insets = useSafeAreaInsets();
  const router = useRouter();
  const { entryReason, setEntryReason, setCurrentStep } = useMenoo();

  const onContinue = () => {
    setCurrentStep(2);
    router.push("/parcours/path");
  };

  return (
    <View style={styles.container}>
      <FlowHeader title="Bienvenue" />
      <StepProgress step={1} total={12} />
      <ScrollView
        contentContainerStyle={{
          paddingHorizontal: spacing.lg,
          paddingBottom: spacing.xxxl + insets.bottom,
        }}
      >
        <Text style={styles.title}>Ce qui m'amène aujourd'hui</Text>
        <Text style={styles.subtitle}>
          Choisissez une raison — vous pourrez tout changer plus tard.
        </Text>

        <View style={{ gap: spacing.sm, marginBottom: spacing.xl }}>
          {REASONS.map((r) => {
            const active = entryReason === r.id;
            return (
              <Pressable
                key={r.id}
                testID={`reason-${r.id}`}
                onPress={() => setEntryReason(r.id)}
                style={[styles.card, active && styles.cardActive]}
              >
                <View
                  style={[
                    styles.iconWrap,
                    { backgroundColor: active ? colors.brandPrimary : colors.brandSecondaryMuted },
                  ]}
                >
                  <Ionicons
                    name={r.icon}
                    size={22}
                    color={active ? colors.onBrandPrimary : colors.brandPrimary}
                  />
                </View>
                <Text style={styles.label}>{r.label}</Text>
                <View style={styles.radio}>{active && <View style={styles.radioDot} />}</View>
              </Pressable>
            );
          })}
        </View>

        <PrimaryButton
          testID="btn-entry-continue"
          label="Continuer"
          onPress={onContinue}
          disabled={!entryReason}
        />
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: colors.surface },
  title: { ...typography.h1, color: colors.onSurface, marginBottom: spacing.xs },
  subtitle: { ...typography.body, color: colors.muted, lineHeight: 22, marginBottom: spacing.lg },
  card: {
    flexDirection: "row",
    alignItems: "center",
    gap: spacing.md,
    backgroundColor: colors.surfaceSecondary,
    borderRadius: radius.lg,
    padding: spacing.lg,
    borderWidth: 2,
    borderColor: "transparent",
    ...shadow.soft,
  },
  cardActive: { borderColor: colors.brandPrimary },
  iconWrap: {
    width: 44, height: 44, borderRadius: radius.md,
    justifyContent: "center", alignItems: "center",
  },
  label: { flex: 1, ...typography.bodyMd, color: colors.onSurface },
  radio: {
    width: 22, height: 22, borderRadius: 11,
    borderWidth: 2, borderColor: colors.brandPrimary,
    justifyContent: "center", alignItems: "center",
  },
  radioDot: { width: 10, height: 10, borderRadius: 5, backgroundColor: colors.brandPrimary },
});
