import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { colors, radius, spacing, typography } from '../theme/tokens';

interface Props {
  available: number;
  needed: number;
  unit: string;
  label: string;
  emoji?: string;
  testID?: string;
}

export default function Gauge({ available, needed, unit, label, emoji, testID }: Props) {
  const ratio = needed === 0 ? 1 : Math.min(1, available / needed);
  const isEnough = available >= needed;
  const barColor = isEnough ? colors.brandPrimary : colors.error;

  return (
    <View testID={testID} style={styles.wrap}>
      <View style={styles.row}>
        <Text style={styles.label}>
          {emoji ? `${emoji}  ` : ''}
          {label}
        </Text>
        <Text style={[styles.qty, { color: isEnough ? colors.onSurface : colors.error }]}>
          {available} {unit} / {needed} {unit}
        </Text>
      </View>
      <View style={styles.trackBg}>
        <View style={[styles.trackFill, { width: `${Math.round(ratio * 100)}%`, backgroundColor: barColor }]} />
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  wrap: { marginBottom: spacing.md },
  row: { flexDirection: 'row', justifyContent: 'space-between', marginBottom: spacing.xs, alignItems: 'center' },
  label: { ...typography.bodyMd, color: colors.onSurface },
  qty: { ...typography.small, color: colors.onSurface },
  trackBg: {
    height: 12,
    borderRadius: radius.pill,
    backgroundColor: colors.brandSecondaryMuted,
    overflow: 'hidden',
  },
  trackFill: { height: '100%', borderRadius: radius.pill },
});
