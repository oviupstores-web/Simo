// Génère les visuels manquants de Menoo avec l'API OpenAI (jalon 5b).
//
// Lit tools/visuals.json (miroir de design/stitch_images/A_FOURNIR.md), génère chaque image avec
// la consigne de style de sa famille, garde l'original dans design/originals/generated/<dossier>/
// et écrit la version finale au bon nom dans assets/images/<dossier>/.
// Les fichiers déjà présents sont sautés (sauf --force).
//
// La clé est lue dans la variable d'environnement OPENAI_API_KEY (déposée par Simo) ;
// elle n'est jamais affichée ni écrite nulle part. Ce script tourne sur le PC, jamais dans l'app.
//
// Usage (depuis la racine du projet) :
//   node --use-system-ca tools/generate_images.mjs --trial        essai de 10 images + planche
//   node --use-system-ca tools/generate_images.mjs                tout ce qui manque
//   options : --only <fichier.jpg>  --force  --dry-run  --model <nom>

import { execFileSync } from 'node:child_process';
import { existsSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const args = process.argv.slice(2);
const flag = (name) => args.includes(`--${name}`);
const option = (name) => (args.includes(`--${name}`) ? args[args.indexOf(`--${name}`) + 1] : undefined);

const model = option('model') ?? 'gpt-image-2';
const quality = 'medium';
// Estimation (tarifs relevés le 2026-09-24) pour le récapitulatif de fin.
const estimatedCostPerImage = 0.05;

function apiKey() {
  let key = process.env.OPENAI_API_KEY;
  if (!key && process.platform === 'win32') {
    // Variable déposée après le démarrage de l'app : on la relit dans le registre utilisateur.
    key = execFileSync(
      'powershell',
      ['-NoProfile', '-Command', '[Environment]::GetEnvironmentVariable("OPENAI_API_KEY","User")'],
      { encoding: 'utf8' },
    ).trim();
  }
  if (!key) {
    console.error('Clé introuvable : la variable OPENAI_API_KEY n\'existe pas sur ce PC.');
    process.exit(1);
  }
  return key;
}

async function generate(key, style, subject) {
  const body = {
    model,
    prompt: style.prompt.replace('{subject}', subject),
    size: style.size,
    quality,
    n: 1,
    output_format: style.transparent ? 'png' : 'jpeg',
    background: style.transparent ? 'transparent' : 'opaque',
  };
  for (let attempt = 1; ; attempt++) {
    const res = await fetch('https://api.openai.com/v1/images/generations', {
      method: 'POST',
      headers: { Authorization: `Bearer ${key}`, 'Content-Type': 'application/json' },
      body: JSON.stringify(body),
    });
    if (res.ok) {
      const json = await res.json();
      return Buffer.from(json.data[0].b64_json, 'base64');
    }
    const text = await res.text();
    // Trop de requêtes ou erreur serveur : on réessaie avec une attente croissante.
    if ((res.status === 429 || res.status >= 500) && attempt < 4) {
      const wait = 10 * attempt;
      console.log(`   … statut ${res.status}, nouvel essai dans ${wait} s`);
      await new Promise((r) => setTimeout(r, wait * 1000));
      continue;
    }
    throw new Error(`statut ${res.status} : ${text.slice(0, 300)}`);
  }
}

function resize(src, dst, [w, h], png) {
  execFileSync('powershell', [
    '-NoProfile',
    '-ExecutionPolicy',
    'Bypass',
    '-File',
    join(root, 'tools', 'resize.ps1'),
    src,
    dst,
    String(w),
    String(h),
    png ? 'png' : 'jpg',
  ]);
}

const manifest = JSON.parse(readFileSync(join(root, 'tools', 'visuals.json'), 'utf8'));
let items = manifest.items;
if (flag('trial')) items = items.filter((i) => i.trial);
if (option('only')) items = items.filter((i) => i.file === option('only'));

const todo = items.filter((i) => flag('force') || !existsSync(join(root, 'assets', 'images', i.folder, i.file)));
console.log(`${items.length} visuel(s) demandé(s), ${todo.length} à générer (modèle ${model}, qualité ${quality}).`);

if (flag('dry-run')) {
  for (const i of todo) {
    console.log(`\n[${i.family}] ${i.folder}/${i.file}\n${manifest.styles[i.style].prompt.replace('{subject}', i.subject)}`);
  }
  process.exit(0);
}

const key = apiKey();
const done = [];
const failed = [];
for (const [n, item] of todo.entries()) {
  const style = manifest.styles[item.style];
  const png = !!style.transparent;
  const original = join(root, 'design', 'originals', 'generated', item.folder, item.file.replace(/\.jpg$/, png ? '.png' : '.jpg'));
  const final = join(root, 'assets', 'images', item.folder, item.file);
  console.log(`(${n + 1}/${todo.length}) ${item.family} : ${item.folder}/${item.file}`);
  try {
    const image = await generate(key, style, item.subject);
    mkdirSync(dirname(original), { recursive: true });
    writeFileSync(original, image);
    resize(original, final, style.output, png);
    done.push(item);
  } catch (e) {
    console.log(`   ÉCHEC : ${e.message}`);
    failed.push(item);
  }
}

console.log(`\nTerminé : ${done.length} réussie(s), ${failed.length} échec(s).`);
console.log(`Coût estimé : environ ${(done.length * estimatedCostPerImage).toFixed(2)} $ (voir le tableau de bord OpenAI pour le montant exact).`);
if (failed.length) console.log(`À relancer : ${failed.map((i) => i.file).join(', ')}`);

// Planche de l'essai, pour que Simo juge le style de chaque famille d'un coup d'œil.
if (flag('trial') && done.length) {
  const sheet = join(root, 'design', 'qa', 'images_essai.jpg');
  const list = items
    .filter((i) => existsSync(join(root, 'assets', 'images', i.folder, i.file)))
    .map((i) => `${join(root, 'assets', 'images', i.folder, i.file)}|${i.family} · ${i.file.replace('.jpg', '')}`);
  execFileSync('powershell', [
    '-NoProfile',
    '-ExecutionPolicy',
    'Bypass',
    '-File',
    join(root, 'tools', 'contact_sheet.ps1'),
    sheet,
    ...list,
  ]);
  console.log(`Planche : ${sheet}`);
}
