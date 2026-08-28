import { Stack } from "expo-router";
import { colors } from "@/src/theme/tokens";

export default function FlowLayout() {
  return (
    <Stack
      screenOptions={{
        headerShown: false,
        contentStyle: { backgroundColor: colors.surface },
        animation: "slide_from_right",
      }}
    />
  );
}
