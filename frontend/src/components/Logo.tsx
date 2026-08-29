import React from "react";
import { View, Text, StyleSheet } from "react-native";
import Svg, { Rect, Path, Circle, G, Line } from "react-native-svg";
import { colors, spacing, typography } from "../theme/tokens";

interface Props {
  size?: number;
  showWordmark?: boolean;
  variant?: "primary" | "inverse";
  testID?: string;
}

/**
 * Logo Menoo — marque alimentaire : fourchette + assiette + feuille dorée en garniture.
 * Palette : vert profond (fond), blanc cassé (couverts / assiette), doré (feuille).
 */
export default function Logo({
  size = 44,
  showWordmark = true,
  variant = "primary",
  testID,
}: Props) {
  const isInverse = variant === "inverse";
  const bgColor = isInverse ? colors.surfaceSecondary : colors.brandPrimary;
  const strokeColor = isInverse ? colors.brandPrimary : colors.surfaceSecondary;
  const plateFill = isInverse ? colors.brandPrimary : colors.surfaceSecondary;
  const plateInner = isInverse ? colors.surfaceSecondary : colors.brandPrimary;
  const wordColor = isInverse ? colors.onSurfaceInverse : colors.brandPrimary;

  return (
    <View testID={testID} style={styles.wrap}>
      <Svg width={size} height={size} viewBox="0 0 48 48">
        {/* Fond arrondi vert profond */}
        <Rect x="0" y="0" width="48" height="48" rx="14" fill={bgColor} />

        {/* Fourchette (3 dents + manche) à gauche */}
        <G stroke={strokeColor} strokeWidth={1.8} strokeLinecap="round">
          <Line x1="10" y1="10" x2="10" y2="18" />
          <Line x1="13" y1="10" x2="13" y2="18" />
          <Line x1="16" y1="10" x2="16" y2="18" />
          {/* Base des dents (attache) */}
          <Line x1="10" y1="18" x2="16" y2="18" />
          {/* Manche */}
          <Line x1="13" y1="18" x2="13" y2="39" />
        </G>

        {/* Assiette (cercle) à droite */}
        <Circle cx="31" cy="26" r="10.5" fill={plateFill} />
        {/* Anneau intérieur de l'assiette pour la profondeur */}
        <Circle
          cx="31"
          cy="26"
          r="6.5"
          fill="none"
          stroke={plateInner}
          strokeWidth={0.8}
          opacity={0.25}
        />

        {/* Feuille dorée en garniture (haut-droite de l'assiette) */}
        <Path
          d="M37 12 Q42.5 13 41 18.5 Q35.5 17.5 37 12 Z"
          fill={colors.brandTertiary}
        />
        {/* Nervure de la feuille */}
        <Path
          d="M37.6 13 L40.6 17.5"
          stroke={colors.onBrandTertiary}
          strokeWidth={0.6}
          strokeLinecap="round"
          opacity={0.6}
        />
      </Svg>
      {showWordmark && (
        <Text style={[styles.word, { color: wordColor }]}>Menoo</Text>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  wrap: { flexDirection: "row", alignItems: "center", gap: spacing.sm },
  word: {
    ...typography.h1,
    fontSize: 26,
    letterSpacing: -0.6,
    fontWeight: "800",
  },
});
