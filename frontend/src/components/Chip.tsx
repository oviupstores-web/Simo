import React from "react";
import { View, Text, StyleSheet, Pressable } from "react-native";
import { colors, radius, spacing, typography } from "../theme/tokens";

interface ChipMultiProps {
  options: { id: string; label: string; emoji?: string }[];
  values: string[];
  onToggle: (id: string) => void;
  testIDPrefix?: string;
}

export function ChipMulti({ options, values, onToggle, testIDPrefix }: ChipMultiProps) {
  return (
    <View style={styles.wrap}>
      {options.map((o) => {
        const active = values.includes(o.id);
        return (
          <Pressable
            key={o.id}
            testID={testIDPrefix ? `${testIDPrefix}-${o.id}` : undefined}
            onPress={() => onToggle(o.id)}
            style={[styles.chip, active && styles.chipActive]}
          >
            {o.emoji ? <Text style={styles.emoji}>{o.emoji}</Text> : null}
            <Text style={[styles.label, active && styles.labelActive]}>{o.label}</Text>
          </Pressable>
        );
      })}
    </View>
  );
}

interface ChipSingleProps {
  options: { id: string; label: string; emoji?: string }[];
  value: string | null | undefined;
  onSelect: (id: string) => void;
  testIDPrefix?: string;
}

export function ChipSingle({ options, value, onSelect, testIDPrefix }: ChipSingleProps) {
  return (
    <View style={styles.wrap}>
      {options.map((o) => {
        const active = value === o.id;
        return (
          <Pressable
            key={o.id}
            testID={testIDPrefix ? `${testIDPrefix}-${o.id}` : undefined}
            onPress={() => onSelect(o.id)}
            style={[styles.chip, active && styles.chipActive]}
          >
            {o.emoji ? <Text style={styles.emoji}>{o.emoji}</Text> : null}
            <Text style={[styles.label, active && styles.labelActive]}>{o.label}</Text>
          </Pressable>
        );
      })}
    </View>
  );
}

const styles = StyleSheet.create({
  wrap: { flexDirection: "row", flexWrap: "wrap", gap: 8 },
  chip: {
    flexDirection: "row",
    alignItems: "center",
    gap: 6,
    paddingHorizontal: 14,
    paddingVertical: 10,
    borderRadius: radius.pill,
    backgroundColor: colors.surfaceTertiary,
    borderWidth: 1.5,
    borderColor: "transparent",
  },
  chipActive: {
    backgroundColor: colors.brandSecondaryMuted,
    borderColor: colors.brandPrimary,
  },
  emoji: { fontSize: 15 },
  label: { ...typography.small, color: colors.onSurfaceTertiary, fontWeight: "500" },
  labelActive: { color: colors.onBrandSecondary, fontWeight: "700" },
});
