import React from "react";
import { View, Text, StyleSheet, ScrollView, Dimensions } from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import Svg, { Polygon, Circle, Line, Text as SvgText, Path } from "react-native-svg";
import { Ionicons } from "@expo/vector-icons";
import { nutritionRadar, weeklyCurve } from "@/src/services/mockData";
import { colors, radius, spacing, typography, shadow } from "@/src/theme/tokens";

const { width: SCREEN_W } = Dimensions.get("window");

function RadarChart({ size = 240 }: { size?: number }) {
  const cx = size / 2;
  const cy = size / 2;
  const radiusR = size * 0.38;
  const n = nutritionRadar.length;
  const angleStep = (Math.PI * 2) / n;

  const pointFor = (i: number, r: number) => {
    const a = -Math.PI / 2 + i * angleStep;
    return { x: cx + Math.cos(a) * r, y: cy + Math.sin(a) * r };
  };

  const rings = [0.25, 0.5, 0.75, 1];
  const outerPoints = Array.from({ length: n }, (_, i) => pointFor(i, radiusR));
  const dataPoints = nutritionRadar.map((d, i) => pointFor(i, radiusR * d.value));

  return (
    <Svg width={size} height={size}>
      {rings.map((r, i) => {
        const pts = Array.from({ length: n }, (_, k) => pointFor(k, radiusR * r));
        return (
          <Polygon
            key={i}
            points={pts.map((p) => `${p.x},${p.y}`).join(" ")}
            fill="none"
            stroke={colors.border}
            strokeWidth={1}
          />
        );
      })}
      {outerPoints.map((p, i) => (
        <Line key={i} x1={cx} y1={cy} x2={p.x} y2={p.y} stroke={colors.border} strokeWidth={1} />
      ))}
      <Polygon
        points={dataPoints.map((p) => `${p.x},${p.y}`).join(" ")}
        fill={colors.brandPrimary}
        fillOpacity={0.25}
        stroke={colors.brandPrimary}
        strokeWidth={2}
      />
      {dataPoints.map((p, i) => (
        <Circle key={i} cx={p.x} cy={p.y} r={4} fill={colors.brandPrimary} />
      ))}
      {nutritionRadar.map((d, i) => {
        const p = pointFor(i, radiusR + 18);
        return (
          <SvgText
            key={i}
            x={p.x}
            y={p.y}
            fontSize={11}
            fontWeight="600"
            fill={colors.onSurface}
            textAnchor="middle"
            alignmentBaseline="middle"
          >
            {d.label}
          </SvgText>
        );
      })}
    </Svg>
  );
}

function WeeklyCurve() {
  const w = SCREEN_W - spacing.lg * 2 - spacing.xl * 2;
  const h = 140;
  const values = weeklyCurve.map((d) => d.value);
  const maxV = Math.max(...values);
  const minV = Math.min(...values);
  const range = maxV - minV || 1;
  const step = w / (values.length - 1);
  const points = values.map((v, i) => {
    const x = i * step;
    const y = h - ((v - minV) / range) * (h - 20) - 10;
    return { x, y };
  });
  const path = points.map((p, i) => (i === 0 ? `M ${p.x} ${p.y}` : `L ${p.x} ${p.y}`)).join(" ");
  const areaPath = `${path} L ${points[points.length - 1].x} ${h} L 0 ${h} Z`;

  return (
    <Svg width={w} height={h}>
      <Path d={areaPath} fill={colors.brandSecondary} fillOpacity={0.25} />
      <Path d={path} stroke={colors.brandPrimary} strokeWidth={2.5} fill="none" />
      {points.map((p, i) => (
        <Circle key={i} cx={p.x} cy={p.y} r={3.5} fill={colors.brandPrimary} />
      ))}
      {weeklyCurve.map((d, i) => (
        <SvgText
          key={i}
          x={points[i].x}
          y={h + 12}
          fontSize={10}
          fill={colors.muted}
          textAnchor="middle"
        >
          {d.day}
        </SvgText>
      ))}
    </Svg>
  );
}

export default function TrackingScreen() {
  const insets = useSafeAreaInsets();
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
        <Text style={styles.pageTitle}>Suivi</Text>
        <Text style={styles.pageSubtitle}>
          Un regard doux sur votre semaine. Aucune donnée médicale, juste des repères utiles.
        </Text>

        <View style={styles.demoBadge}>
          <Ionicons name="information-circle-outline" size={14} color={colors.onBrandTertiary} />
          <Text style={styles.demoBadgeText}>Données de démonstration</Text>
        </View>

        {/* Radar nutritionnel */}
        <View testID="card-radar" style={styles.card}>
          <Text style={styles.cardTitle}>Équilibre nutritionnel</Text>
          <Text style={styles.cardHint}>Vue d'ensemble sur les 7 derniers jours.</Text>
          <View style={{ alignItems: "center", marginTop: spacing.md }}>
            <RadarChart />
          </View>
        </View>

        {/* Weekly curve */}
        <View testID="card-weekly" style={styles.card}>
          <Text style={styles.cardTitle}>Évolution hebdomadaire</Text>
          <Text style={styles.cardHint}>Apport énergétique journalier estimé (kcal).</Text>
          <View style={{ alignItems: "center", marginTop: spacing.md, paddingBottom: spacing.lg }}>
            <WeeklyCurve />
          </View>
        </View>

        {/* Budget saved */}
        <View testID="card-budget" style={[styles.card, { backgroundColor: colors.brandPrimary }]}>
          <View style={{ flexDirection: "row", alignItems: "center", gap: 8 }}>
            <Ionicons name="wallet-outline" size={20} color={colors.onSurfaceInverse} />
            <Text style={[styles.cardTitle, { color: colors.onSurfaceInverse }]}>Budget</Text>
          </View>
          <Text style={styles.savedAmount}>13,50 €</Text>
          <Text style={styles.savedLabel}>Cette semaine, vous avez économisé 13,50 €</Text>
        </View>

        {/* Énergie */}
        <View testID="card-energy" style={styles.card}>          <View style={{ flexDirection: "row", alignItems: "center", gap: 8 }}>
            <Ionicons name="flame-outline" size={20} color={colors.brandTertiary} />
            <Text style={styles.cardTitle}>Énergie de cuisson</Text>
          </View>
          <Text style={styles.energyAmount}>2,1 kWh</Text>
          <Text style={styles.cardHint}>Estimation basée sur vos temps et modes de cuisson.</Text>
        </View>

        {/* Trajets évités (kilomètres économisés) */}
        <View testID="card-trajets" style={styles.card}>
          <View style={{ flexDirection: "row", alignItems: "center", gap: 8 }}>
            <Ionicons name="car-outline" size={20} color={colors.brandPrimary} />
            <Text style={styles.cardTitle}>Trajets évités</Text>
          </View>
          <Text style={styles.cardHint}>Grâce à vos réserves et au mode « sans achat ».</Text>
          <View style={styles.trajetsRow}>
            <View style={styles.trajetItem}>
              <Text style={styles.trajetValue}>3</Text>
              <Text style={styles.trajetLabel}>allers-retours</Text>
            </View>
            <View style={styles.trajetItem}>
              <Text style={[styles.trajetValue, { color: colors.brandTertiary }]}>12,4 km</Text>
              <Text style={styles.trajetLabel}>économisés</Text>
            </View>
            <View style={styles.trajetItem}>
              <Text style={[styles.trajetValue, { color: colors.brandSecondary }]}>1,8 kg</Text>
              <Text style={styles.trajetLabel}>CO₂ évité</Text>
            </View>
          </View>
        </View>

        {/* Objectif progression */}
        <View testID="card-objectif" style={styles.card}>
          <View style={{ flexDirection: "row", alignItems: "center", gap: 8 }}>
            <Ionicons name="flag-outline" size={20} color={colors.brandPrimary} />
            <Text style={styles.cardTitle}>Objectif</Text>
          </View>
          <Text style={styles.cardHint}>Progression et régularité de la semaine.</Text>
          <View style={styles.progressRow}>
            <Text style={styles.progressLabel}>Progression</Text>
            <Text style={styles.progressValue}>68 %</Text>
          </View>
          <View style={styles.progressTrack}>
            <View style={[styles.progressFill, { width: "68%" }]} />
          </View>
          <View style={styles.streakRow}>
            <View style={styles.streakBadge}>
              <Ionicons name="checkmark-circle" size={14} color={colors.onBrandSecondary} />
              <Text style={styles.streakText}>5 jours suivis d'affilée</Text>
            </View>
          </View>
        </View>

        {/* Diversité */}
        <View testID="card-diversite" style={styles.card}>          <View style={{ flexDirection: "row", alignItems: "center", gap: 8 }}>
            <Ionicons name="color-palette-outline" size={20} color={colors.brandTertiary} />
            <Text style={styles.cardTitle}>Diversité</Text>
          </View>
          <Text style={styles.cardHint}>Rotation des recettes — séparée de la nutrition.</Text>
          <View style={{ marginTop: spacing.md, gap: 10 }}>
            {[
              { label: "Italienne", pct: 0.35 },
              { label: "Méditerranéenne", pct: 0.25 },
              { label: "Française", pct: 0.2 },
              { label: "Asiatique", pct: 0.15 },
              { label: "Autre", pct: 0.05 },
            ].map((r) => (
              <View key={r.label}>
                <View style={styles.diversityRow}>
                  <Text style={styles.diversityLabel}>{r.label}</Text>
                  <Text style={styles.diversityValue}>{Math.round(r.pct * 100)} %</Text>
                </View>
                <View style={styles.diversityTrack}>
                  <View
                    style={[
                      styles.diversityFill,
                      { width: `${Math.round(r.pct * 100)}%` },
                    ]}
                  />
                </View>
              </View>
            ))}
          </View>
        </View>
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: colors.surface },
  pageTitle: { ...typography.display, color: colors.onSurface, marginBottom: spacing.xs },
  pageSubtitle: { ...typography.body, color: colors.muted, marginBottom: spacing.md, lineHeight: 22 },
  demoBadge: {
    alignSelf: "flex-start",
    flexDirection: "row",
    alignItems: "center",
    gap: 4,
    backgroundColor: colors.brandTertiaryMuted,
    paddingHorizontal: 10,
    paddingVertical: 5,
    borderRadius: radius.pill,
    marginBottom: spacing.lg,
  },
  demoBadgeText: { ...typography.caption, color: colors.onBrandTertiary },
  card: {
    backgroundColor: colors.surfaceSecondary,
    borderRadius: radius.lg,
    padding: spacing.xl,
    marginBottom: spacing.md,
    ...shadow.soft,
  },
  cardTitle: { ...typography.h3, color: colors.onSurface },
  cardHint: { ...typography.small, color: colors.muted, marginTop: 4 },
  savedAmount: { fontSize: 40, fontWeight: "800", color: colors.brandTertiary, marginTop: spacing.md },
  savedLabel: { ...typography.body, color: colors.onSurfaceInverse, opacity: 0.9, marginTop: 4 },
  energyAmount: { fontSize: 32, fontWeight: "700", color: colors.brandPrimary, marginTop: spacing.md },
  progressRow: { flexDirection: "row", justifyContent: "space-between", marginTop: spacing.md, marginBottom: 6 },
  progressLabel: { ...typography.small, color: colors.muted },
  progressValue: { ...typography.h3, color: colors.brandPrimary },
  progressTrack: { height: 10, borderRadius: radius.pill, backgroundColor: colors.brandSecondaryMuted, overflow: "hidden" },
  progressFill: { height: "100%", backgroundColor: colors.brandPrimary, borderRadius: radius.pill },
  streakRow: { marginTop: spacing.md, flexDirection: "row" },
  streakBadge: {
    flexDirection: "row", alignItems: "center", gap: 6,
    backgroundColor: colors.brandSecondaryMuted,
    paddingHorizontal: 10, paddingVertical: 6, borderRadius: radius.pill,
  },
  streakText: { ...typography.caption, color: colors.onBrandSecondary, fontWeight: "700" },
  diversityRow: { flexDirection: "row", justifyContent: "space-between", marginBottom: 4 },
  diversityLabel: { ...typography.small, color: colors.onSurface },
  diversityValue: { ...typography.caption, color: colors.muted },
  diversityTrack: { height: 8, borderRadius: radius.pill, backgroundColor: colors.brandSecondaryMuted, overflow: "hidden" },
  diversityFill: { height: "100%", backgroundColor: colors.brandTertiary, borderRadius: radius.pill },
  trajetsRow: {
    flexDirection: "row",
    marginTop: spacing.md,
    gap: spacing.sm,
  },
  trajetItem: {
    flex: 1,
    backgroundColor: colors.surfaceTertiary,
    borderRadius: radius.md,
    padding: spacing.md,
    alignItems: "center",
  },
  trajetValue: { ...typography.h2, color: colors.brandPrimary, fontWeight: "800" },
  trajetLabel: { ...typography.caption, color: colors.muted, marginTop: 4, textAlign: "center" },
});
