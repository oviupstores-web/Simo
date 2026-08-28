import React from "react";
import { View, Text, StyleSheet } from "react-native";
import { colors, radius, spacing, typography } from "../theme/tokens";

export default function StepProgress({ step, total = 12 }: { step: number; total?: number }) {
  const ratio = Math.max(0, Math.min(1, step / total));
  return (
    <View testID="step-progress" style={styles.wrap}>
      <View style={styles.headerRow}>
        <Text style={styles.text}>
          Étape <Text style={styles.strong}>{step}</Text> sur {total}
        </Text>
        <Text style={styles.pct}>{Math.round(ratio * 100)}%</Text>
      </View>
      <View style={styles.trackBg}>
        <View style={[styles.trackFill, { width: `${ratio * 100}%` }]} />
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  wrap: { paddingHorizontal: spacing.lg, marginBottom: spacing.md },
  headerRow: { flexDirection: "row", justifyContent: "space-between", marginBottom: 6 },
  text: { ...typography.small, color: colors.muted },
  strong: { color: colors.brandPrimary, fontWeight: "700" },
  pct: { ...typography.caption, color: colors.brandPrimary, fontWeight: "700" },
  trackBg: {
    height: 6,
    borderRadius: radius.pill,
    backgroundColor: colors.brandSecondaryMuted,
    overflow: "hidden",
  },
  trackFill: { height: "100%", backgroundColor: colors.brandPrimary, borderRadius: radius.pill },
});
