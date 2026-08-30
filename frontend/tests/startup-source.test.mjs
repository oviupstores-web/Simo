import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const layout = fs.readFileSync(path.join(root, "app/_layout.tsx"), "utf8");

test("le splash screen possède une sortie de secours", () => {
  assert.match(layout, /setTimeout\(\(\) => setFontWaitExpired\(true\), 1500\)/);
  assert.match(layout, /SplashScreen\.hideAsync\(\)\.catch\(\(\) => \{\}\)/);
});
