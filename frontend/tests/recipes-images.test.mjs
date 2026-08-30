import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const read = (relativePath) => fs.readFileSync(path.join(root, relativePath), "utf8");

const recipesSource = read("src/services/recipes.ts");
const mockDataSource = read("src/services/mockData.ts");
const mealsSource = read("app/(tabs)/meals.tsx");
const prepSource = read("app/prep/[mealId].tsx");
const flowRecipeSource = read("app/flow/recipe.tsx");

function extractRecipes() {
  const entries = [];
  const entryPattern = /["']([^"']+)["']:\s*_make\(\{([\s\S]*?)\n\s*\}\),/g;

  for (const match of recipesSource.matchAll(entryPattern)) {
    const [, key, body] = match;
    const field = (name) => body.match(new RegExp(`${name}:\\s*["']([^"']+)["']`))?.[1];
    entries.push({ key, recipeId: field("recipe_id"), title: field("title"), imageUrl: field("image_url") });
  }

  return entries;
}

test("le registre canonique contient 21 recettes valides", () => {
  const recipes = extractRecipes();
  assert.equal(recipes.length, 21);

  for (const recipe of recipes) {
    assert.equal(recipe.key, recipe.recipeId, `Clé et recipe_id différents pour ${recipe.key}`);
    assert.ok(recipe.title, `Titre manquant pour ${recipe.key}`);
    assert.match(recipe.imageUrl ?? "", /^https:\/\//, `Image invalide pour ${recipe.key}`);
  }
});

test("chaque recette possède une URL d'image unique", () => {
  const recipes = extractRecipes();
  const byUrl = new Map();

  for (const recipe of recipes) {
    const owners = byUrl.get(recipe.imageUrl) ?? [];
    owners.push(`${recipe.title} (${recipe.recipeId})`);
    byUrl.set(recipe.imageUrl, owners);
  }

  const duplicates = [...byUrl.entries()].filter(([, owners]) => owners.length > 1);
  assert.deepEqual(
    duplicates,
    [],
    `Images partagées détectées:\n${duplicates.map(([url, owners]) => `- ${url}: ${owners.join(", ")}`).join("\n")}`
  );
});

test("le plan et les swaps référencent le registre par recipeId", () => {
  const ids = new Set(extractRecipes().map((recipe) => recipe.recipeId));
  const planIds = [...mockDataSource.matchAll(/plannedMeal\(['"](?:lun|mar|mer|jeu|ven|sam|dim)-[^'"]+['"],\s*['"]([^'"]+)['"]/g)].map((m) => m[1]);
  const swapIds = [...mockDataSource.matchAll(/plannedMeal\(['"]swap-[^'"]+['"],\s*['"]([^'"]+)['"]/g)].map((m) => m[1]);

  assert.equal(planIds.length, 21, "Le plan hebdomadaire doit contenir exactement 21 repas");
  assert.equal(swapIds.length, 3, "Trois alternatives de swap sont attendues");
  for (const recipeId of [...planIds, ...swapIds]) {
    assert.ok(ids.has(recipeId), `recipeId inconnu dans le plan ou les swaps: ${recipeId}`);
  }

  assert.doesNotMatch(mockDataSource, /const\s+IMG\s*=/, "Le dictionnaire d'images dupliqué IMG ne doit plus exister");
  assert.match(mealsSource, /resolvePlannedMeal\(m,\s*weekOverrides\[m\.id\]\)/);
  assert.match(prepSource, /resolvePlannedMeal\(base,\s*weekOverrides\[base\.id\]\)/);
});

test("l'image héro est résolue depuis la recette affichée", () => {
  assert.doesNotMatch(flowRecipeSource, /const\s+HERO_IMG/);
  assert.doesNotMatch(flowRecipeSource, /images\.(?:unsplash|pexels)\.com/);
  assert.match(flowRecipeSource, /getRecipeImage\(italianRecipe\.recipeId\)\.url/);
  assert.match(flowRecipeSource, /source=\{\{\s*uri:\s*recipeImage\s*\}\}/);
});

