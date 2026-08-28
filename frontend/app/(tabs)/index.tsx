import React from "react";
import { View, Text, StyleSheet, ScrollView, Pressable } from "react-native";
import { useRouter } from "expo-router";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { Ionicons } from "@expo/vector-icons";
import { useMenoo } from "@/src/store/menoo";
import { PARCOURS_LABELS } from "@/src/services/steps";
import { colors, radius, spacing, typography, shadow } from "@/src/theme/tokens";

export default function AccueilScreen() {
  const insets = useSafeAreaInsets();
  const router = useRouter();
  const { parcours, currentStep, entryReason, resetOnboarding, hydrated } = useMenoo();

  const hasProgress = hydrated && !!parcours && currentStep >= 3 && currentStep <= 12;
  const startedButNotChosen = hydrated && !parcours && !!entryReason;

  const goStart = () => router.push("/parcours/entry");
  const resumeRoute = () =>
    hasProgress
      ? router.push(`/parcours/${parcours}/${currentStep}` as any)
      : startedButNotChosen
      ? router.push("/parcours/path")
      : goStart();

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
        {/* Header */}
        <View style={styles.headerRow}>
          <Text style={styles.logo}>Menoo</Text>
          <View testID="badge-no-account" style={styles.badge}>
            <Ionicons name="sparkles" size={14} color={colors.onBrandTertiary} />
            <Text style={styles.badgeText}>Sans compte pour commencer</Text>
          </View>
        </View>

        <Text style={styles.title}>Bonjour</Text>
        <Text style={styles.subtitle}>
          Menoo simplifie l'organisation des repas et vous aide à cuisiner ce que vous avez déjà.
        </Text>

        {/* Start or resume */}
        {hasProgress || startedButNotChosen ? (
          <View style={styles.resumeCard}>
            <View style={styles.resumeBadge}>
              <Ionicons name="play-circle" size={14} color={colors.onBrandSecondary} />
              <Text style={styles.resumeBadgeText}>Reprise possible</Text>
            </View>
            <Text style={styles.resumeTitle}>
              {hasProgress ? "Reprendre votre parcours" : "Continuer où vous étiez"}
            </Text>
            <Text style={styles.resumeHint}>
              {hasProgress
                ? `${PARCOURS_LABELS[parcours!]} · Étape ${currentStep} sur 12`
                : "Choisissez votre parcours pour continuer."}
            </Text>
            <Pressable
              testID="btn-resume"
              onPress={resumeRoute}
              style={({ pressed }) => [styles.resumeBtn, pressed && { opacity: 0.85 }]}
            >
              <Text style={styles.resumeBtnText}>
                {hasProgress
                  ? `Reprendre à l'étape ${currentStep}`
                  : "Continuer"}
              </Text>
              <Ionicons name="arrow-forward" size={18} color={colors.onBrandPrimary} />
            </Pressable>
            <Pressable
              testID="btn-restart"
              onPress={() => {
                resetOnboarding();
                router.push("/parcours/entry");
              }}
              style={styles.restartLink}
            >
              <Ionicons name="refresh-outline" size={14} color={colors.muted} />
              <Text style={styles.restartText}>Recommencer depuis le début</Text>
            </Pressable>
          </View>
        ) : (
          <Pressable
            testID="btn-start"
            onPress={goStart}
            style={({ pressed }) => [styles.cardFeatured, pressed && { opacity: 0.9 }]}
          >
            <View style={styles.featuredBadge}>
              <Ionicons name="star" size={12} color={colors.onBrandTertiary} />
              <Text style={styles.featuredBadgeText}>12 étapes guidées</Text>
            </View>
            <Text style={styles.cardFeaturedTitle}>Commencer avec Menoo</Text>
            <Text style={styles.cardFeaturedDesc}>
              Un parcours en 12 étapes, à votre rythme. Répondez à ce qui vous ressemble, tout peut être modifié plus tard.
            </Text>
            <View style={styles.featuredCta}>
              <Text style={styles.featuredCtaText}>Commencer</Text>
              <Ionicons name="arrow-forward" size={18} color={colors.brandPrimary} />
            </View>
          </Pressable>
        )}

        {/* Quick access to pantry (kept to preserve existing functionality) */}
        <Pressable
          testID="quick-pantry"
          onPress={() => router.push("/(tabs)/pantry")}
          style={({ pressed }) => [styles.card, pressed && { opacity: 0.85 }]}
        >
          <View style={styles.quickIcon}>
            <Ionicons name="basket-outline" size={22} color={colors.brandPrimary} />
          </View>
          <View style={{ flex: 1 }}>
            <Text style={styles.cardTitle}>Voir mes réserves</Text>
            <Text style={styles.cardDesc}>Accès rapide à vos quantités actuelles.</Text>
          </View>
          <Ionicons name="chevron-forward" size={22} color={colors.muted} />
        </Pressable>
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: colors.surface },
  headerRow: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    marginBottom: spacing.xl,
  },
  logo: { fontSize: 30, fontWeight: "800", color: colors.brandPrimary, letterSpacing: -0.5 },
  badge: {
    flexDirection: "row",
    alignItems: "center",
    gap: 6,
    backgroundColor: colors.brandTertiaryMuted,
    paddingHorizontal: 10,
    paddingVertical: 6,
    borderRadius: radius.pill,
  },
  badgeText: { ...typography.caption, color: colors.onBrandTertiary },
  title: { ...typography.display, color: colors.onSurface, marginBottom: spacing.sm },
  subtitle: { ...typography.body, color: colors.muted, lineHeight: 22, marginBottom: spacing.xl },
  cardFeatured: {
    backgroundColor: colors.brandPrimary,
    borderRadius: radius.lg,
    padding: spacing.xl,
    marginBottom: spacing.md,
    ...shadow.card,
  },
  featuredBadge: {
    flexDirection: "row",
    alignItems: "center",
    gap: 4,
    alignSelf: "flex-start",
    backgroundColor: colors.brandTertiary,
    paddingHorizontal: 10,
    paddingVertical: 5,
    borderRadius: radius.pill,
    marginBottom: spacing.md,
  },
  featuredBadgeText: { ...typography.caption, color: colors.onBrandTertiary, fontWeight: "700" },
  cardFeaturedTitle: { ...typography.h1, color: colors.onSurfaceInverse, marginTop: spacing.sm, marginBottom: spacing.xs },
  cardFeaturedDesc: { ...typography.body, color: colors.onSurfaceInverse, opacity: 0.9, lineHeight: 22, marginBottom: spacing.lg },
  featuredCta: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    gap: 8,
    backgroundColor: colors.surfaceSecondary,
    paddingVertical: 14,
    borderRadius: radius.pill,
  },
  featuredCtaText: { ...typography.bodyMd, color: colors.brandPrimary, fontWeight: "700" },
  card: {
    flexDirection: "row",
    alignItems: "center",
    gap: spacing.md,
    backgroundColor: colors.surfaceSecondary,
    borderRadius: radius.lg,
    padding: spacing.lg,
    marginTop: spacing.sm,
    ...shadow.soft,
  },
  quickIcon: {
    width: 44, height: 44, borderRadius: radius.md,
    backgroundColor: colors.brandSecondaryMuted,
    justifyContent: "center", alignItems: "center",
  },
  cardTitle: { ...typography.h3, color: colors.onSurface, marginBottom: 2 },
  cardDesc: { ...typography.small, color: colors.muted, lineHeight: 20 },
  resumeCard: {
    backgroundColor: colors.surfaceSecondary,
    borderRadius: radius.lg,
    padding: spacing.xl,
    marginBottom: spacing.md,
    borderWidth: 2,
    borderColor: colors.brandPrimary,
    ...shadow.card,
  },
  resumeBadge: {
    flexDirection: "row",
    alignItems: "center",
    gap: 4,
    alignSelf: "flex-start",
    backgroundColor: colors.brandSecondaryMuted,
    paddingHorizontal: 10,
    paddingVertical: 5,
    borderRadius: radius.pill,
    marginBottom: spacing.md,
  },
  resumeBadgeText: { ...typography.caption, color: colors.onBrandSecondary, fontWeight: "700" },
  resumeTitle: { ...typography.h2, color: colors.onSurface, marginBottom: 4 },
  resumeHint: { ...typography.body, color: colors.muted, marginBottom: spacing.lg },
  resumeBtn: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    gap: 8,
    backgroundColor: colors.brandPrimary,
    paddingVertical: 14,
    borderRadius: radius.pill,
  },
  resumeBtnText: { ...typography.bodyMd, color: colors.onBrandPrimary, fontWeight: "700" },
  restartLink: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    gap: 6,
    paddingVertical: spacing.md,
  },
  restartText: { ...typography.small, color: colors.muted },
});
