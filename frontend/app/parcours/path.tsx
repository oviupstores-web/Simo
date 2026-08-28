import React from "react";
import { View, Text, StyleSheet, ScrollView, Pressable } from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { useRouter } from "expo-router";
import { Ionicons } from "@expo/vector-icons";
import FlowHeader from "@/src/components/FlowHeader";
import StepProgress from "@/src/components/StepProgress";
import { useMenoo, ParcoursType } from "@/src/store/menoo";
import { colors, radius, spacing, typography, shadow } from "@/src/theme/tokens";

const CARDS: {
  id: ParcoursType;
  title: string;
  desc: string;
  icon: any;
  featured?: boolean;
}[] = [
  { id: "pour-moi", title: "Pour moi", desc: "Un accompagnement adapté à mon rythme et à mes objectifs.", icon: "person-outline" },
  { id: "pour-foyer", title: "Pour mon foyer", desc: "Des repas qui prennent soin des goûts et des besoins de chacun.", icon: "people-outline" },
  { id: "avec", title: "Avec ce que j'ai", desc: "Je renseigne mes réserves et Menoo me propose un repas réalisable.", icon: "basket", featured: true },
];

export default function PathScreen() {
  const insets = useSafeAreaInsets();
  const router = useRouter();
  const { setParcours, setCurrentStep } = useMenoo();

  const onSelect = (id: ParcoursType) => {
    setParcours(id);
    setCurrentStep(3);
    router.push(`/parcours/${id}/3` as any);
  };

  return (
    <View style={styles.container}>
      <FlowHeader title="Votre parcours" />
      <StepProgress step={2} total={12} />
      <ScrollView
        contentContainerStyle={{
          paddingHorizontal: spacing.lg,
          paddingBottom: spacing.xxxl + insets.bottom,
        }}
      >
        <Text style={styles.title}>Comment Menoo doit m'accompagner</Text>
        <Text style={styles.subtitle}>
          Trois façons de commencer. Toutes peuvent être modifiées plus tard.
        </Text>

        {CARDS.map((c) =>
          c.featured ? (
            <Pressable
              key={c.id}
              testID={`path-${c.id}`}
              onPress={() => onSelect(c.id)}
              style={({ pressed }) => [styles.cardFeatured, pressed && { opacity: 0.9 }]}
            >
              <View style={styles.featuredBadge}>
                <Ionicons name="star" size={12} color={colors.onBrandTertiary} />
                <Text style={styles.featuredBadgeText}>Recommandé</Text>
              </View>
              <View style={styles.iconWrapFeatured}>
                <Ionicons name={c.icon} size={26} color={colors.onSurfaceInverse} />
              </View>
              <Text style={styles.cardTitleFeatured}>{c.title}</Text>
              <Text style={styles.cardDescFeatured}>{c.desc}</Text>
              <View style={styles.featuredCta}>
                <Text style={styles.featuredCtaText}>Commencer</Text>
                <Ionicons name="arrow-forward" size={18} color={colors.brandPrimary} />
              </View>
            </Pressable>
          ) : (
            <Pressable
              key={c.id}
              testID={`path-${c.id}`}
              onPress={() => onSelect(c.id)}
              style={({ pressed }) => [styles.card, pressed && { opacity: 0.85 }]}
            >
              <View style={styles.iconWrap}>
                <Ionicons name={c.icon} size={26} color={colors.brandPrimary} />
              </View>
              <View style={{ flex: 1 }}>
                <Text style={styles.cardTitle}>{c.title}</Text>
                <Text style={styles.cardDesc}>{c.desc}</Text>
              </View>
              <Ionicons name="chevron-forward" size={22} color={colors.muted} />
            </Pressable>
          )
        )}
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: colors.surface },
  title: { ...typography.h1, color: colors.onSurface, marginBottom: spacing.xs },
  subtitle: { ...typography.body, color: colors.muted, lineHeight: 22, marginBottom: spacing.lg },
  card: {
    flexDirection: "row",
    alignItems: "center",
    gap: spacing.md,
    backgroundColor: colors.surfaceSecondary,
    borderRadius: radius.lg,
    padding: spacing.lg,
    marginBottom: spacing.md,
    ...shadow.soft,
  },
  iconWrap: {
    width: 52, height: 52, borderRadius: radius.md,
    backgroundColor: colors.brandSecondaryMuted,
    justifyContent: "center", alignItems: "center",
  },
  cardTitle: { ...typography.h3, color: colors.onSurface, marginBottom: 2 },
  cardDesc: { ...typography.small, color: colors.muted, lineHeight: 20 },
  cardFeatured: {
    backgroundColor: colors.brandPrimary,
    borderRadius: radius.lg,
    padding: spacing.xl,
    marginTop: spacing.sm,
    ...shadow.card,
  },
  iconWrapFeatured: {
    width: 52, height: 52, borderRadius: radius.md,
    backgroundColor: "rgba(255,255,255,0.15)",
    justifyContent: "center", alignItems: "center",
  },
  featuredBadge: {
    flexDirection: "row",
    alignItems: "center",
    gap: 4,
    alignSelf: "flex-start",
    backgroundColor: colors.brandTertiary,
    paddingHorizontal: 10,
    paddingVertical: 5,
    borderRadius: radius.pill,
    marginBottom: spacing.md,
  },
  featuredBadgeText: { ...typography.caption, color: colors.onBrandTertiary, fontWeight: "700" },
  cardTitleFeatured: { ...typography.h1, color: colors.onSurfaceInverse, marginTop: spacing.md, marginBottom: spacing.xs },
  cardDescFeatured: { ...typography.body, color: colors.onSurfaceInverse, opacity: 0.9, lineHeight: 22, marginBottom: spacing.lg },
  featuredCta: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    gap: 8,
    backgroundColor: colors.surfaceSecondary,
    paddingVertical: 14,
    borderRadius: radius.pill,
  },
  featuredCtaText: { ...typography.bodyMd, color: colors.brandPrimary, fontWeight: "700" },
});
