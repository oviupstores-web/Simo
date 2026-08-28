import React, { useState } from "react";
import { View, Text, StyleSheet, ScrollView, TextInput, Pressable, KeyboardAvoidingView, Platform } from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { useRouter } from "expo-router";
import { Ionicons } from "@expo/vector-icons";
import FlowHeader from "@/src/components/FlowHeader";
import PrimaryButton from "@/src/components/PrimaryButton";
import { colors, radius, spacing, typography, shadow } from "@/src/theme/tokens";

const PREFILL =
  "J'ai un sachet de pâtes de 500 g à moitié, une barquette de champignons de 250 g pleine aux deux tiers et une bouteille de crème liquide de 20 cl non ouverte.";

const methods: { id: string; icon: any; label: string; hint: string }[] = [
  { id: "write", icon: "create-outline", label: "Écrire", hint: "Décrivez librement" },
  { id: "voice", icon: "mic-outline", label: "Parler", hint: "Dictez à voix haute" },
  { id: "photo", icon: "camera-outline", label: "Photographier", hint: "Prenez vos étagères" },
  { id: "barcode", icon: "barcode-outline", label: "Scanner", hint: "Un code-barres" },
];

export default function InputScreen() {
  const insets = useSafeAreaInsets();
  const router = useRouter();
  const [selected, setSelected] = useState("write");
  const [text, setText] = useState(PREFILL);

  return (
    <View style={styles.container}>
      <FlowHeader title="Vos réserves" step={1} totalSteps={6} />
      <KeyboardAvoidingView
        style={{ flex: 1 }}
        behavior={Platform.OS === "ios" ? "padding" : undefined}
        keyboardVerticalOffset={80}
      >
        <ScrollView
          contentContainerStyle={{
            paddingHorizontal: spacing.lg,
            paddingBottom: spacing.xxxl + insets.bottom,
          }}
          keyboardShouldPersistTaps="handled"
        >
          <Text style={styles.title}>Dites-nous simplement ce que vous avez</Text>
          <Text style={styles.subtitle}>
            Choisissez la méthode qui vous convient. Menoo s'occupe du reste.
          </Text>

          <View style={styles.methodsGrid}>
            {methods.map((m) => {
              const isSelected = selected === m.id;
              return (
                <Pressable
                  key={m.id}
                  testID={`method-${m.id}`}
                  onPress={() => setSelected(m.id)}
                  style={[styles.methodCard, isSelected && styles.methodCardActive]}
                >
                  <View
                    style={[
                      styles.methodIcon,
                      { backgroundColor: isSelected ? colors.brandPrimary : colors.brandSecondaryMuted },
                    ]}
                  >
                    <Ionicons
                      name={m.icon}
                      size={22}
                      color={isSelected ? colors.onBrandPrimary : colors.brandPrimary}
                    />
                  </View>
                  <Text style={styles.methodLabel}>{m.label}</Text>
                  <Text style={styles.methodHint}>{m.hint}</Text>
                </Pressable>
              );
            })}
          </View>

          {selected === "write" && (
            <View style={styles.textareaWrap}>
              <Text style={styles.textareaLabel}>Décrivez vos réserves</Text>
              <TextInput
                testID="pantry-text-input"
                value={text}
                onChangeText={setText}
                multiline
                style={styles.textarea}
                placeholder="Par ex. j'ai 500 g de riz et 6 œufs..."
                placeholderTextColor={colors.muted}
              />
            </View>
          )}

          {selected !== "write" && (
            <View style={styles.demoNote}>
              <Ionicons name="information-circle-outline" size={18} color={colors.onBrandTertiary} />
              <Text style={styles.demoNoteText}>
                Fonction {methods.find((m) => m.id === selected)?.label.toLowerCase()} : aperçu démo. Nous utilisons la
                saisie écrite préremplie pour la démonstration.
              </Text>
            </View>
          )}

          <PrimaryButton
            testID="btn-validate-input"
            label="Valider mes réserves"
            onPress={() => router.push("/flow/consolidation")}
          />
        </ScrollView>
      </KeyboardAvoidingView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: colors.surface },
  title: { ...typography.h1, color: colors.onSurface, marginBottom: spacing.xs },
  subtitle: { ...typography.body, color: colors.muted, marginBottom: spacing.lg, lineHeight: 22 },
  methodsGrid: { flexDirection: "row", flexWrap: "wrap", gap: spacing.md, marginBottom: spacing.lg },
  methodCard: {
    flexBasis: "47%",
    flexGrow: 1,
    backgroundColor: colors.surfaceSecondary,
    borderRadius: radius.lg,
    padding: spacing.lg,
    borderWidth: 2,
    borderColor: "transparent",
    ...shadow.soft,
  },
  methodCardActive: { borderColor: colors.brandPrimary },
  methodIcon: {
    width: 44, height: 44, borderRadius: radius.md,
    justifyContent: "center", alignItems: "center",
    marginBottom: spacing.sm,
  },
  methodLabel: { ...typography.h3, color: colors.onSurface },
  methodHint: { ...typography.small, color: colors.muted, marginTop: 2 },
  textareaWrap: { marginBottom: spacing.lg },
  textareaLabel: { ...typography.bodyMd, color: colors.onSurface, marginBottom: spacing.sm },
  textarea: {
    minHeight: 120,
    backgroundColor: colors.surfaceSecondary,
    borderRadius: radius.md,
    padding: spacing.lg,
    ...typography.body,
    color: colors.onSurface,
    textAlignVertical: "top",
    borderWidth: 1,
    borderColor: colors.border,
  },
  demoNote: {
    flexDirection: "row",
    gap: spacing.sm,
    backgroundColor: colors.brandTertiaryMuted,
    padding: spacing.md,
    borderRadius: radius.md,
    marginBottom: spacing.lg,
  },
  demoNoteText: { flex: 1, ...typography.small, color: colors.onBrandTertiary, lineHeight: 19 },
});
