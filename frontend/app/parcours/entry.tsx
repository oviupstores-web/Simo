import { useEffect } from "react";
import { useRouter } from "expo-router";

// L'écran « Ce qui m'amène » a été retiré selon l'organigramme officiel :
// l'ouverture Menoo mène directement au choix du parcours.
export default function DeprecatedEntry() {
  const router = useRouter();
  useEffect(() => {
    router.replace("/parcours/path");
  }, [router]);
  return null;
}
