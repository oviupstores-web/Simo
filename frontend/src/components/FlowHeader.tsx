import React from "react";
import { View, Text, StyleSheet, Pressable } from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { useRouter } from "expo-router";
import { Ionicons } from "@expo/vector-icons";
import { colors, radius, spacing, typography } from "@/src/theme/tokens";

export default function FlowHeader({ title, step, totalSteps }: { title: string; step?: number; totalSteps?: number }) {
  const insets = useSafeAreaInsets();
  const router = useRouter();
  return (
    <View style={[styles.header, { paddingTop: insets.top + spacing.sm }]}>
      <View style={styles.row}>
        <Pressable
          testID="header-back"
          onPress={() => router.back()}
          style={styles.backBtn}
          hitSlop={8}
        >
          <Ionicons name="chevron-back" size={22} color={colors.onSurface} />
        </Pressable>
        <Text style={styles.title}>{title}</Text>
        {step && totalSteps ? (
          <View style={styles.stepBadge}>
            <Text style={styles.stepText}>{step}/{totalSteps}</Text>
          </View>
        ) : (
          <View style={{ width: 44 }} />
        )}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  header: {
    paddingHorizontal: spacing.lg,
    paddingBottom: spacing.md,
    backgroundColor: colors.surface,
  },
  row: { flexDirection: "row", alignItems: "center", justifyContent: "space-between" },
  backBtn: {
    width: 44, height: 44, borderRadius: radius.pill,
    backgroundColor: colors.surfaceSecondary,
    justifyContent: "center", alignItems: "center",
  },
  title: { ...typography.h3, color: colors.onSurface, flex: 1, textAlign: "center" },
  stepBadge: {
    minWidth: 44, height: 30, paddingHorizontal: 10,
    borderRadius: radius.pill,
    backgroundColor: colors.brandSecondaryMuted,
    justifyContent: "center", alignItems: "center",
  },
  stepText: { ...typography.caption, color: colors.onBrandSecondary, fontWeight: "700" },
});
