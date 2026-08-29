import React from "react";
import { View, Text, StyleSheet } from "react-native";
import Svg, { Rect, Path, Circle, G } from "react-native-svg";
import { colors, spacing, typography } from "../theme/tokens";

interface Props {
  size?: number; // mark size
  showWordmark?: boolean;
  variant?: "primary" | "inverse"; // primary = green mark on light, inverse = light mark on green
  testID?: string;
}

/**
 * Logo Menoo — marque en forme de "M" épuré évoquant une feuille et une assiette,
 * touche dorée en accent. Utilisé sur Accueil, Ouverture et écrans d'onboarding.
 */
export default function Logo({
  size = 40,
  showWordmark = true,
  variant = "primary",
  testID,
}: Props) {
  const isInverse = variant === "inverse";
  const bgColor = isInverse ? colors.surfaceSecondary : colors.brandPrimary;
  const markColor = isInverse ? colors.brandPrimary : colors.surfaceSecondary;
  const wordColor = isInverse ? colors.onSurfaceInverse : colors.brandPrimary;

  return (
    <View testID={testID} style={styles.wrap}>
      <Svg width={size} height={size} viewBox="0 0 48 48">
        <Rect x="0" y="0" width="48" height="48" rx="14" fill={bgColor} />
        {/* Stylised M with a leaf curve on the top-right */}
        <G>
          <Path
            d="M12 34 L12 16 Q12 14 14 14 L16 14 L23 23 Q24 24.5 25 23 L32 14 L34 14 Q36 14 36 16 L36 34 L31 34 L31 21 L27 26 Q24.5 29 21 26 L17 21 L17 34 Z"
            fill={markColor}
          />
          {/* Small leaf accent */}
          <Path
            d="M34 10 Q38 8 40 12 Q38 15 34 13 Z"
            fill={colors.brandTertiary}
          />
          <Circle cx="37" cy="11.5" r="0.8" fill={bgColor} opacity={0.5} />
        </G>
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
