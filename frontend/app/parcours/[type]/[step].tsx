import React, { useMemo } from "react";
import { View, Text, StyleSheet, ScrollView } from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { useLocalSearchParams, useRouter } from "expo-router";
import { Ionicons } from "@expo/vector-icons";
import FlowHeader from "@/src/components/FlowHeader";
import StepProgress from "@/src/components/StepProgress";
import PrimaryButton from "@/src/components/PrimaryButton";
import { useMenoo, ParcoursType } from "@/src/store/menoo";
import { STEP_TITLES, PARCOURS_LABELS } from "@/src/services/steps";
import { colors, radius, spacing, typography } from "@/src/theme/tokens";
import MoiStep, { moiCanContinue } from "@/src/screens/moi";
import FamilleStep, { familleCanContinue } from "@/src/screens/famille";

export default function ParcoursStepScreen() {
  const insets = useSafeAreaInsets();
  const router = useRouter();
  const params = useLocalSearchParams<{ type: string; step: string }>();
  const type = (params.type as ParcoursType) || "pour-moi";
  const step = parseInt(String(params.step ?? "1"), 10);
  const { setCurrentStep, answers } = useMenoo();

  const stepInfo = useMemo(() => STEP_TITLES[type]?.[step] ?? { title: "Étape" }, [type, step]);

  const validate = type === "pour-moi"
    ? moiCanContinue(step, answers["pour-moi"])
    : familleCanContinue(step, answers["pour-famille"]);
  const canContinue = validate === true;
  const blockingMessage = typeof validate === "string" ? validate : null;

  const goNext = () => {
    if (!canContinue) return;
    if (step < 12) {
      setCurrentStep(step + 1);
      router.push(`/parcours/${type}/${step + 1}` as any);
    } else {
      router.replace("/(tabs)");
    }
  };
  const goBack = () => {
    if (step > 1) {
      setCurrentStep(step - 1);
      router.back();
    } else {
      router.back();
    }
  };
  const onOpenPantry = () => router.push("/flow/input" as any);

  return (
    <View style={styles.container}>
      <FlowHeader title={PARCOURS_LABELS[type]} />
      <StepProgress step={step} total={12} />
      <ScrollView
        contentContainerStyle={{
          paddingHorizontal: spacing.lg,
          paddingBottom: spacing.xxxl + insets.bottom,
        }}
        keyboardShouldPersistTaps="handled"
      >
        <Text style={styles.title}>{stepInfo.title}</Text>
        {stepInfo.hint && <Text style={styles.subtitle}>{stepInfo.hint}</Text>}

        {type === "pour-moi" ? (
          <MoiStep step={step} onOpenPantry={onOpenPantry} />
        ) : (
          <FamilleStep step={step} onOpenPantry={onOpenPantry} />
        )}

        {blockingMessage && (
          <View testID="blocking-msg" style={styles.warnBlock}>
            <Ionicons name="alert-circle-outline" size={18} color={colors.warning} />
            <Text style={styles.warnText}>{blockingMessage}</Text>
          </View>
        )}

        <View style={styles.actions}>
          <PrimaryButton
            testID="btn-step-back"
            label="Retour"
            variant="ghost"
            onPress={goBack}
          />
          <View style={{ height: spacing.sm }} />
          <PrimaryButton
            testID="btn-step-continue"
            label={step === 12 ? (type === "pour-moi" ? "Créer ma semaine" : "Créer notre semaine") : "Continuer"}
            onPress={goNext}
            disabled={!canContinue}
          />
        </View>
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: colors.surface },
  title: { ...typography.h1, color: colors.onSurface, marginBottom: spacing.xs },
  subtitle: { ...typography.body, color: colors.muted, lineHeight: 22, marginBottom: spacing.lg },
  warnBlock: {
    flexDirection: "row",
    gap: 8,
    padding: spacing.md,
    backgroundColor: colors.brandTertiaryMuted,
    borderRadius: radius.md,
    marginTop: spacing.sm,
    alignItems: "center",
  },
  warnText: { flex: 1, ...typography.small, color: colors.warning, lineHeight: 19 },
  actions: { marginTop: spacing.md },
});
