import React, { useEffect, useMemo, useRef, useState } from "react";
import { View, Text, StyleSheet, ScrollView, Pressable, AppState } from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { useLocalSearchParams, useRouter } from "expo-router";
import { Image } from "expo-image";
import { Ionicons } from "@expo/vector-icons";
import FlowHeader from "@/src/components/FlowHeader";
import PrimaryButton from "@/src/components/PrimaryButton";
import { weeklyPlan, prepSteps } from "@/src/services/mockData";
import { useMenoo } from "@/src/store/menoo";
import { colors, radius, spacing, typography, shadow } from "@/src/theme/tokens";

function fmt(sec: number) {
  const m = Math.floor(sec / 60);
  const s = sec % 60;
  return `${String(m).padStart(2, "0")}:${String(s).padStart(2, "0")}`;
}

export default function PrepScreen() {
  const insets = useSafeAreaInsets();
  const router = useRouter();
  const { mealId } = useLocalSearchParams<{ mealId: string }>();
  const { weekOverrides, confirmMeal } = useMenoo();

  const meal = useMemo(() => {
    const all = weeklyPlan.flatMap((d) => d.meals);
    const base = all.find((m) => m.id === mealId) ?? all[0];
    const o = weekOverrides[base.id];
    return o ? { ...base, ...o } : base;
  }, [mealId, weekOverrides]);

  const steps = prepSteps.default;
  const [idx, setIdx] = useState(0);
  const step = steps[idx];
  const isLast = idx === steps.length - 1;

  const [remaining, setRemaining] = useState<number | null>(step?.timerSec ?? null);
  const [running, setRunning] = useState(false);
  const timerRef = useRef<any>(null);

  // Reset timer when the step changes.
  useEffect(() => {
    setRemaining(step?.timerSec ?? null);
    setRunning(false);
  }, [idx]);

  // Tick.
  useEffect(() => {
    if (!running) return;
    timerRef.current = setInterval(() => {
      setRemaining((r) => {
        if (r === null) return null;
        if (r <= 1) {
          clearInterval(timerRef.current);
          setRunning(false);
          return 0;
        }
        return r - 1;
      });
    }, 1000);
    return () => clearInterval(timerRef.current);
  }, [running]);

  // Pause the timer when the screen loses focus (safety).
  useEffect(() => {
    const sub = AppState.addEventListener("change", (state) => {
      if (state !== "active") setRunning(false);
    });
    return () => sub.remove();
  }, []);

  const onConfirm = () => {
    confirmMeal(meal.id);
    router.replace("/(tabs)/meals" as any);
  };

  return (
    <View style={styles.container}>
      <FlowHeader title="Préparation" />
      <ScrollView
        contentContainerStyle={{
          paddingHorizontal: spacing.lg,
          paddingBottom: spacing.xxxl + insets.bottom,
        }}
      >
        <View style={styles.hero}>
          <Image source={{ uri: meal.image }} style={styles.heroImg} contentFit="cover" />
          <View style={styles.heroOverlay}>
            <Text style={styles.heroTitle}>{meal.title}</Text>
            <View style={styles.heroMeta}>
              <View style={styles.metaChip}>
                <Ionicons name="time" size={12} color={colors.onSurfaceInverse} />
                <Text style={styles.metaChipText}>{meal.time} min</Text>
              </View>
              <View style={styles.metaChip}>
                <Ionicons name="restaurant" size={12} color={colors.onSurfaceInverse} />
                <Text style={styles.metaChipText}>{meal.slot}</Text>
              </View>
            </View>
          </View>
        </View>

        <View testID="prep-progress" style={styles.progressWrap}>
          <View style={styles.progressHeader}>
            <Text style={styles.progressText}>
              Étape <Text style={{ color: colors.brandPrimary, fontWeight: "800" }}>{idx + 1}</Text> sur {steps.length}
            </Text>
            <Text style={styles.progressPct}>{Math.round(((idx + 1) / steps.length) * 100)}%</Text>
          </View>
          <View style={styles.trackBg}>
            <View style={[styles.trackFill, { width: `${((idx + 1) / steps.length) * 100}%` }]} />
          </View>
        </View>

        <View style={styles.stepCard}>
          <View style={styles.stepNum}>
            <Text style={styles.stepNumText}>{idx + 1}</Text>
          </View>
          <Text testID="prep-step-text" style={styles.stepText}>{step.text}</Text>
        </View>

        {step.timerSec !== undefined && (
          <View testID="prep-timer" style={styles.timerCard}>
            <Text style={styles.timerLabel}>Minuteur</Text>
            <Text style={styles.timerValue}>{fmt(remaining ?? step.timerSec)}</Text>
            <View style={styles.timerRow}>
              <Pressable
                testID={running ? "timer-pause" : "timer-start"}
                onPress={() => setRunning((v) => !v)}
                style={[styles.timerBtn, { backgroundColor: colors.brandPrimary }]}
              >
                <Ionicons
                  name={running ? "pause" : "play"}
                  size={18}
                  color={colors.onBrandPrimary}
                />
                <Text style={styles.timerBtnText}>{running ? "Pause" : "Démarrer"}</Text>
              </Pressable>
              <Pressable
                testID="timer-reset"
                onPress={() => {
                  setRemaining(step.timerSec ?? null);
                  setRunning(false);
                }}
                style={[styles.timerBtn, { backgroundColor: colors.surfaceTertiary }]}
              >
                <Ionicons name="refresh" size={18} color={colors.onSurface} />
              </Pressable>
            </View>
          </View>
        )}

        <View style={styles.actions}>
          <PrimaryButton
            testID="prep-prev"
            label="Étape précédente"
            variant="ghost"
            onPress={() => setIdx((v) => Math.max(0, v - 1))}
            disabled={idx === 0}
          />
          <View style={{ height: spacing.sm }} />
          {!isLast ? (
            <PrimaryButton
              testID="prep-next"
              label="Étape suivante"
              onPress={() => setIdx((v) => Math.min(steps.length - 1, v + 1))}
            />
          ) : (
            <PrimaryButton
              testID="prep-confirm"
              label="Repas confirmé"
              onPress={onConfirm}
              icon={<Ionicons name="checkmark-circle" size={20} color={colors.onBrandPrimary} />}
            />
          )}
        </View>
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: colors.surface },
  hero: {
    height: 200,
    borderRadius: radius.lg,
    overflow: "hidden",
    marginBottom: spacing.md,
    ...shadow.card,
  },
  heroImg: { width: "100%", height: "100%" },
  heroOverlay: {
    position: "absolute",
    left: spacing.md,
    right: spacing.md,
    bottom: spacing.md,
    backgroundColor: "rgba(0,0,0,0.35)",
    padding: spacing.md,
    borderRadius: radius.md,
  },
  heroTitle: { ...typography.h2, color: colors.onSurfaceInverse, marginBottom: 6 },
  heroMeta: { flexDirection: "row", gap: 6 },
  metaChip: {
    flexDirection: "row",
    alignItems: "center",
    gap: 4,
    backgroundColor: "rgba(0,0,0,0.35)",
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: radius.pill,
  },
  metaChipText: { color: colors.onSurfaceInverse, fontSize: 11, fontWeight: "700" },
  progressWrap: { marginBottom: spacing.md },
  progressHeader: { flexDirection: "row", justifyContent: "space-between", marginBottom: 6 },
  progressText: { ...typography.small, color: colors.muted },
  progressPct: { ...typography.caption, color: colors.brandPrimary, fontWeight: "700" },
  trackBg: { height: 6, borderRadius: radius.pill, backgroundColor: colors.brandSecondaryMuted, overflow: "hidden" },
  trackFill: { height: "100%", backgroundColor: colors.brandPrimary, borderRadius: radius.pill },
  stepCard: {
    flexDirection: "row",
    gap: spacing.md,
    backgroundColor: colors.surfaceSecondary,
    borderRadius: radius.lg,
    padding: spacing.lg,
    marginBottom: spacing.md,
    ...shadow.soft,
    alignItems: "flex-start",
  },
  stepNum: {
    width: 36, height: 36, borderRadius: 18,
    backgroundColor: colors.brandPrimary,
    alignItems: "center", justifyContent: "center",
  },
  stepNumText: { ...typography.h3, color: colors.onBrandPrimary },
  stepText: { flex: 1, ...typography.body, color: colors.onSurface, lineHeight: 24 },
  timerCard: {
    backgroundColor: colors.surfaceSecondary,
    borderRadius: radius.lg,
    padding: spacing.lg,
    marginBottom: spacing.lg,
    alignItems: "center",
    ...shadow.soft,
  },
  timerLabel: { ...typography.caption, color: colors.muted },
  timerValue: {
    fontSize: 48,
    fontWeight: "800",
    color: colors.brandPrimary,
    marginTop: 4,
    letterSpacing: 1,
  },
  timerRow: { flexDirection: "row", gap: spacing.sm, marginTop: spacing.md },
  timerBtn: {
    flexDirection: "row",
    alignItems: "center",
    gap: 6,
    paddingHorizontal: spacing.lg,
    paddingVertical: 12,
    borderRadius: radius.pill,
  },
  timerBtnText: { ...typography.bodyMd, color: colors.onBrandPrimary, fontWeight: "700" },
  actions: { marginTop: spacing.md },
});
