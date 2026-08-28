import React from 'react';
import { Pressable, Text, StyleSheet, View, ActivityIndicator } from 'react-native';
import { colors, radius, spacing, typography } from '../theme/tokens';

interface Props {
  label: string;
  onPress: () => void;
  variant?: 'primary' | 'secondary' | 'ghost';
  disabled?: boolean;
  loading?: boolean;
  testID?: string;
  icon?: React.ReactNode;
}

export default function PrimaryButton({ label, onPress, variant = 'primary', disabled, loading, testID, icon }: Props) {
  const isPrimary = variant === 'primary';
  const isSecondary = variant === 'secondary';
  const isGhost = variant === 'ghost';

  const bg = isPrimary ? colors.brandPrimary : isSecondary ? colors.brandSecondaryMuted : 'transparent';
  const fg = isPrimary ? colors.onBrandPrimary : isSecondary ? colors.onBrandSecondary : colors.brandPrimary;
  const border = isGhost ? colors.brandPrimary : 'transparent';

  return (
    <Pressable
      testID={testID}
      onPress={onPress}
      disabled={disabled || loading}
      style={({ pressed }) => [
        styles.btn,
        { backgroundColor: bg, borderColor: border, borderWidth: isGhost ? 1.5 : 0 },
        (pressed || disabled) && { opacity: 0.7 },
      ]}
    >
      {loading ? (
        <ActivityIndicator color={fg} />
      ) : (
        <View style={styles.inner}>
          {icon}
          <Text style={[styles.label, { color: fg }]}>{label}</Text>
        </View>
      )}
    </Pressable>
  );
}

const styles = StyleSheet.create({
  btn: {
    minHeight: 52,
    borderRadius: radius.pill,
    paddingHorizontal: spacing.xl,
    justifyContent: 'center',
    alignItems: 'center',
  },
  inner: { flexDirection: 'row', alignItems: 'center', gap: 8 },
  label: { ...typography.bodyMd, fontSize: 16 },
});
