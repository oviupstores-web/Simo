// Voix douce (Web Speech API) — sans dépendance native.
// Sur iOS/Android, ceci ne parlera pas ; le prototype reste 100 % silencieux.
import { Platform } from "react-native";

export function speakFr(text: string) {
  if (Platform.OS !== "web") return;
  try {
    // @ts-ignore
    const synth = typeof window !== "undefined" ? window.speechSynthesis : null;
    if (!synth) return;
    synth.cancel();
    // @ts-ignore
    const u = new window.SpeechSynthesisUtterance(text);
    u.lang = "fr-FR";
    u.rate = 0.95;
    u.pitch = 1.05;
    u.volume = 0.9;
    // Choisir une voix française si disponible.
    const voices = synth.getVoices?.() ?? [];
    const fr = voices.find((v: any) => (v.lang || "").toLowerCase().startsWith("fr"));
    if (fr) u.voice = fr;
    synth.speak(u);
  } catch {}
}
