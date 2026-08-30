import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const store = fs.readFileSync(path.join(root, "src/store/menoo.tsx"), "utf8");

test("la sauvegarde v3 migre depuis la clé v2", () => {
  assert.match(store, /STORAGE_KEY\s*=\s*['"]menoo:storage:v3['"]/);
  assert.match(store, /LEGACY_STORAGE_KEY\s*=\s*['"]menoo:onboarding:v2['"]/);
  assert.match(store, /current\s*\?\s*null\s*:\s*await AsyncStorage\.getItem\(LEGACY_STORAGE_KEY\)/);
});

test("tous les états utilisateur attendus sont persistés", () => {
  const requiredFields = [
    "pantry",
    "meal",
    "cooked",
    "weekOverrides",
    "confirmedMeals",
    "weekVersion",
    "purchased",
    "pinned",
    "voiceEnabled",
    "parcours",
    "currentStep",
    "answers",
  ];

  const serializedBlock = store.match(/JSON\.stringify\(\{([\s\S]*?)\}\)\s*\n\s*\)\.catch/)?.[1] ?? "";
  for (const field of requiredFields) {
    assert.match(serializedBlock, new RegExp(`\\b${field}\\b`), `Champ non persisté: ${field}`);
  }
});

test("l'application s'affiche pendant l'hydratation sans écraser les données", () => {
  assert.match(store, /<MenooContext\.Provider value=\{value\}>\{children\}<\/MenooContext\.Provider>/);
  assert.match(store, /if \(!hydrated\) return;/);
  assert.match(store, /sanitizedPantry\(parsed\.pantry\)/);
  assert.match(store, /sanitizedMeal\(parsed\.meal\)/);
  assert.match(store, /sanitizedOverrides\(parsed\.weekOverrides\)/);
  assert.match(store, /sanitizedPinned\(parsed\.pinned\)/);
  assert.match(store, /finally\s*\{\s*setHydrated\(true\)/);
});
