import React, { useMemo } from "react";
import { View, Text, StyleSheet, ScrollView } from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { useLocalSearchParams, useRouter } from "expo-router";
import { Ionicons } from "@expo/vector-icons";
import FlowHeader from "@/src/components/FlowHeader";
import StepProgress from "@/src/components/StepProgress";
import PrimaryButton from "@/src/components/PrimaryButton";
import { useMenoo, ParcoursType } from "@/src/store/menoo";
import { STEP_TITLES, PARCOURS_LABELS, AVEC_DETAILED_ROUTE } from "@/src/services/steps";
import { colors, radius, spacing, typography, shadow } from "@/src/theme/tokens";

export default function ParcoursStepScreen() {
  const insets = useSafeAreaInsets();
  const router = useRouter();
  const params = useLocalSearchParams<{ type: string; step: string }>();
  const type = (params.type as ParcoursType) || "pour-moi";
  const step = parseInt(String(params.step ?? "3"), 10);
  const { setCurrentStep } = useMenoo();

  const stepInfo = useMemo(() => STEP_TITLES[type]?.[step] ?? { title: "Étape" }, [type, step]);
  const detailedRoute = type === "avec" ? AVEC_DETAILED_ROUTE[step] : null;

  const goNext = () => {
    if (step < 12) {
      setCurrentStep(step + 1);
      router.push(`/parcours/${type}/${step + 1}` as any);
    } else {
      // Final step: return to home
      router.replace("/(tabs)");
    }
  };

  const openDetailed = () => {
    if (detailedRoute) router.push(detailedRoute as any);
  };

  return (
    <View style={styles.container}>
      <FlowHeader title={PARCOURS_LABELS[type]} />
      <StepProgress step={step} total={12} />
      <ScrollView
        contentContainerStyle={{
          paddingHorizontal: spacing.lg,
          paddingBottom: spacing.xxxl + insets.bottom,
        }}
      >
        <Text style={styles.title}>{stepInfo.title}</Text>
        {stepInfo.hint && <Text style={styles.subtitle}>{stepInfo.hint}</Text>}

        {/* Placeholder card */}
        <View style={styles.card}>
          <View style={styles.placeholderIcon}>
            <Ionicons name="construct-outline" size={22} color={colors.brandPrimary} />
          </View>
          <View style={{ flex: 1 }}>
            <Text style={styles.cardTitle}>Aperçu en préparation</Text>
            <Text style={styles.cardText}>
              Le contenu détaillé de cette étape arrive bientôt. Vos réponses seront conservées.
            </Text>
          </View>
        </View>

        {detailedRoute && (
          <View testID="detailed-screen-block" style={styles.detailedBlock}>
            <View style={styles.detailedHeader}>
              <Ionicons name="sparkles" size={18} color={colors.brandTertiary} />
              <Text style={styles.detailedTitle}>Écran interactif disponible</Text>
            </View>
            <Text style={styles.detailedHint}>
              Cette étape dispose déjà d'un écran interactif complet. Ouvrez-le pour continuer.
            </Text>
            <PrimaryButton
              testID="btn-open-detailed"
              label="Ouvrir l'écran interactif"
              variant="secondary"
              onPress={openDetailed}
              icon={<Ionicons name="arrow-forward" size={18} color={colors.onBrandSecondary} />}
            />
          </View>
        )}

        <View style={styles.actions}>
          <PrimaryButton
            testID="btn-step-back"
            label="Retour"
            variant="ghost"
            onPress={() => router.back()}
          />
          <View style={{ height: spacing.sm }} />
          <PrimaryButton
            testID="btn-step-continue"
            label={step === 12 ? "Terminer" : "Continuer"}
            onPress={goNext}
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
  card: {
    flexDirection: "row",
    gap: spacing.md,
    alignItems: "flex-start",
    backgroundColor: colors.surfaceSecondary,
    borderRadius: radius.lg,
    padding: spacing.lg,
    marginBottom: spacing.md,
    ...shadow.soft,
  },
  placeholderIcon: {
    width: 44, height: 44, borderRadius: radius.md,
    backgroundColor: colors.brandSecondaryMuted,
    justifyContent: "center", alignItems: "center",
  },
  cardTitle: { ...typography.h3, color: colors.onSurface, marginBottom: 4 },
  cardText: { ...typography.small, color: colors.muted, lineHeight: 20 },
  detailedBlock: {
    backgroundColor: colors.brandTertiaryMuted,
    borderRadius: radius.lg,
    padding: spacing.lg,
    marginBottom: spacing.lg,
  },
  detailedHeader: { flexDirection: "row", alignItems: "center", gap: 8, marginBottom: 6 },
  detailedTitle: { ...typography.bodyMd, color: colors.onBrandTertiary },
  detailedHint: { ...typography.small, color: colors.onBrandTertiary, lineHeight: 19, marginBottom: spacing.md },
  actions: { marginTop: spacing.md },
});
