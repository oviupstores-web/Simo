import React from "react";
import { View, Text, StyleSheet, ScrollView } from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { Image } from "expo-image";
import { Ionicons } from "@expo/vector-icons";
import { colors, radius, spacing, typography, shadow } from "@/src/theme/tokens";

const previewMeals = [
  {
    title: "Pâtes crémeuses aux champignons",
    time: "22 min",
    people: 2,
    img: "https://images.unsplash.com/photo-1715249792894-43ad23412d3d?crop=entropy&cs=srgb&fm=jpg&w=800&q=70",
  },
  {
    title: "Tarte aux légumes du soleil",
    time: "40 min",
    people: 4,
    img: "https://images.unsplash.com/photo-1761839258803-21515f43190c?crop=entropy&cs=srgb&fm=jpg&w=800&q=70",
  },
];

export default function MealsScreen() {
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
        <Text style={styles.pageTitle}>Mes repas</Text>
        <Text style={styles.pageSubtitle}>Un aperçu des repas récents et à venir.</Text>

        <View style={styles.demoBadge}>
          <Ionicons name="information-circle-outline" size={14} color={colors.onBrandTertiary} />
          <Text style={styles.demoBadgeText}>Aperçu démo</Text>
        </View>

        {previewMeals.map((m, i) => (
          <View key={i} testID={`meal-preview-${i}`} style={styles.card}>
            <Image source={{ uri: m.img }} style={styles.cardImg} contentFit="cover" />
            <View style={styles.cardBody}>
              <Text style={styles.cardTitle}>{m.title}</Text>
              <View style={styles.metaRow}>
                <View style={styles.chip}>
                  <Ionicons name="time-outline" size={14} color={colors.onBrandSecondary} />
                  <Text style={styles.chipText}>{m.time}</Text>
                </View>
                <View style={styles.chip}>
                  <Ionicons name="people-outline" size={14} color={colors.onBrandSecondary} />
                  <Text style={styles.chipText}>{m.people} pers.</Text>
                </View>
              </View>
            </View>
          </View>
        ))}
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: colors.surface },
  pageTitle: { ...typography.display, color: colors.onSurface, marginBottom: spacing.xs },
  pageSubtitle: { ...typography.body, color: colors.muted, marginBottom: spacing.md },
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
    overflow: "hidden",
    marginBottom: spacing.md,
    ...shadow.soft,
  },
  cardImg: { width: "100%", height: 160 },
  cardBody: { padding: spacing.lg },
  cardTitle: { ...typography.h3, color: colors.onSurface, marginBottom: spacing.sm },
  metaRow: { flexDirection: "row", gap: spacing.sm },
  chip: {
    flexDirection: "row",
    alignItems: "center",
    gap: 4,
    backgroundColor: colors.brandSecondaryMuted,
    paddingHorizontal: 10,
    paddingVertical: 5,
    borderRadius: radius.pill,
  },
  chipText: { ...typography.caption, color: colors.onBrandSecondary },
});
