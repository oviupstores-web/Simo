import React from "react";
import { View, Text, StyleSheet, Pressable } from "react-native";
import { Ionicons } from "@expo/vector-icons";
import { colors, radius, spacing, typography } from "../theme/tokens";

interface Props {
  value: number;
  min: number;
  max: number;
  step?: number;
  onChange: (n: number) => void;
  testID?: string;
}

export default function Counter({ value, min, max, step = 1, onChange, testID }: Props) {
  return (
    <View style={styles.wrap}>
      <Pressable
        testID={testID ? `${testID}-dec` : undefined}
        onPress={() => onChange(Math.max(min, value - step))}
        style={[styles.btn, value <= min && styles.btnDisabled]}
        disabled={value <= min}
      >
        <Ionicons name="remove" size={20} color={value <= min ? colors.muted : colors.onBrandPrimary} />
      </Pressable>
      <Text testID={testID ? `${testID}-value` : undefined} style={styles.value}>
        {value}
      </Text>
      <Pressable
        testID={testID ? `${testID}-inc` : undefined}
        onPress={() => onChange(Math.min(max, value + step))}
        style={[styles.btn, value >= max && styles.btnDisabled]}
        disabled={value >= max}
      >
        <Ionicons name="add" size={20} color={value >= max ? colors.muted : colors.onBrandPrimary} />
      </Pressable>
    </View>
  );
}

const styles = StyleSheet.create({
  wrap: {
    flexDirection: "row",
    alignItems: "center",
    backgroundColor: colors.surfaceTertiary,
    borderRadius: radius.pill,
    padding: 4,
    gap: 8,
  },
  btn: {
    width: 34, height: 34, borderRadius: 17,
    backgroundColor: colors.brandPrimary,
    justifyContent: "center", alignItems: "center",
  },
  btnDisabled: { backgroundColor: colors.border },
  value: { ...typography.h3, color: colors.onSurface, minWidth: 24, textAlign: "center" },
});
