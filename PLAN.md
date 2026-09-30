# PLAN.md — Suivi des jalons Menoo

Pour reprendre dans une nouvelle session : « Reprends à partir de PLAN.md ».

## 📍 Où on en est
- **État actuel (2026-09-30)** : jalons 0 à 5b **validés**. **SPEC.md v4 validée par Simo dans son ensemble.** Les 14 renommages d'écrans et les 13 points ouverts sont tranchés (SPEC §14-15). **Jalon 5i (International) terminé** : socle technique, police arabe Readex Pro, et **28 écrans + les widgets partagés traduits dans les 6 langues, sans aucun texte en dur restant** (`test/i18n_test.dart` passe sans exclusion). Détail complet dans la section « Jalon 5i » plus bas.
- **Git** : projet sous version depuis le 2026-09-30. 807+ fichiers suivis, `build/`, `.dart_tool/` et les fichiers `app_localizations*.dart` générés exclus.
- **Prochaine action** : jalon 5d (Entrée et réassurance : landing déroulante, 5 écrans de réassurance, étape Enseigne sans drive), puis 5c (recettes des 8 cuisines, avec l'essai de 5 photos avant le lot). Voir « Ordre recommandé » plus bas.
- **À faire au fil de l'eau** : mettre `CLAUDE.md` en accord au prochain jalon qui touche la Landing/le drive (déjà partiellement à jour depuis le 2026-09-30).
- **Visuels du 5b** : tous validés. Pour en refaire un : `node --use-system-ca tools/generate_images.mjs --only <fichier> --force`. Pas encore affichés (écrans à venir) : 6 recettes, `famille_table`.
- **Maquette 6b** (`design/maquettes/maquette_6b_cercle_et_cuisines.html`) : v4 en attente du retour de Simo — page de comparaison côte à côte, Scan IA en deux états (repos/caméra), choix de cuisine, cercle de l'Accueil (variante A frigo retenue). Pas de blocage : le 6b vient après 5d, 5c et 6 de toute façon.

| # | Jalon | Statut |
|---|---|---|
| 0 | Environnement (Flutter, Android SDK, téléphone, Supabase) | ✅ Validé |
| 1 | App vide installée sur le téléphone | ✅ Validé |
| 2 | Design system + 9 écrans maîtres | ✅ Validé (après corrections) |
| 3 | Base Supabase (tables, RLS, démo, cas pièges) | ✅ Validé |
| 4 | Entrée + onboarding Solo (12 étapes) + détour Réserve | ✅ Validé |
| 5 | Onboarding Foyer (10 étapes) + détour Réserve | ✅ Validé |
| 5b | Images par API OpenAI (125 visuels) + pictogrammes régimes + branchement | ✅ Validé |
| 5i | **International, socle** : textes sortis du code, 6 langues, arabe de droite à gauche, unités / devises / dates | ✅ Validé (2026-09-30) — tables de traduction Supabase pour les contenus restent au 5c |
| 5d | **Entrée et réassurance** : landing déroulante, 5 écrans de réassurance, onglet « Menus », étape Enseigne sans drive, photo IA verrouillée dans le détour Réserve | ⏳ Prochain |
| 5c | Recettes des 8 cuisines (96 recettes, première tranche vers 500), créées dans les tables de traduction ; photos par API après essai de 5 | ⏳ (après 5i) |
| 6 | Compte invité converti à l'inscription + génération des menus sous budget / Ma cuisine | ⏳ |
| 6b | **Improvisation (6 étapes) + paywall de la fiche recette**, à construire ensemble | 🆕 Proposé |
| 7 | Menu flouté (réutilise le paywall du 6b) | ⏳ |
| 8 | Onglet Menus (ex-Semaine) | ⏳ |
| 9 | Onglet Courses **sans drive** : mode magasin, partage, impression A4, PDF, texte ; prix en 3 niveaux | ⏳ |
| 10 | Onglet Réserve | ⏳ |
| 11 | Accueil (avec cercle d'improvisation) + Suivi + Health Connect | ⏳ |
| 12 | Réglages (langue, pays, unités, abonnement), états vides/erreurs, suppression du compte | ⏳ |
| 12b | **Anti-fraude** — App Set ID vérifié côté serveur dans une Edge Function avant l'appel à l'IA | 🔴 **BLOQUANT AVANT PUBLICATION** (validé par Simo le 2026-09-30). Pas codé maintenant |
| 13 | APK de test (Firebase App Distribution) | ⏳ |
| — | Catalogue : ≈ **120 recettes** au lancement (12 à 15 × 8 cuisines) ; les 500 **après le lancement**, une fois qu'il y a des utilisateurs | 🆕 En continu |

## Jalon 5i — International (✅ socle et 28 écrans traduits, 2026-09-30)

**Socle technique :**
- `l10n.yaml`, `generate: true`, paquet `intl`. Classe générée `L` (`L.of(context)`), branchée dans `main.dart` (`L.supportedLocales`, `L.localizationsDelegates`).
- **6 langues** dans `lib/l10n/` : `app_fr.arb` (référence) + en, es, de, it, ar. Les fichiers `app_localizations*.dart` sont générés, donc exclus de Git (regénérés par `flutter gen-l10n` ou `flutter pub get`).
- **Changement de langue** : appui long sur le logo Menoo, en haut de n'importe quel écran (provisoire, jusqu'à l'écran Réglages du jalon 12). Une langue non choisie suit celle du téléphone ; **langue non proposée → repli sur l'anglais**, jamais le français (SPEC §0.10).
- **Police arabe : Readex Pro** (SIL Open Font License, choisie par Simo — même esprit géométrique que Frutiger Arabic, sans le coût d'une police Monotype), déclarée en police de secours dans `AppText`. Plus Jakarta Sans reste la police principale, donc « Menoo » garde son dessin au milieu d'un texte arabe.
- **Sens de lecture** : positions `start`/`end` partout (jamais `left`/`right`), icônes directionnelles retournées (`AppIcon` teste `Directionality`), décor de basilic inversé, bloc de marque gardé dans l'ordre (logo à gauche de « Menoo »).
- **Unités, devises, dates** : `lib/l10n/formats.dart`. Métrique partout, impérial aux États-Unis ; devise et format de date selon le pays ; les prix partent des centimes de la base ; les nombres arrondis enlèvent les zéros inutiles (75 kg, jamais 75,0 kg). Couvert par `test/formats_test.dart`.
- **Détecteur automatique** `test/i18n_test.dart` : scanne tout `lib/`, signale fichier + ligne + texte pour tout texte d'interface resté en dur. **Passe sans aucune exclusion.**
- Captures de contrôle en arabe (Readex Pro) : `design/qa/arabe_6_ecrans.jpg`, régénérables par `flutter test test/golden_ar_test.dart --update-goldens`.

**Les 29 écrans/fichiers traduits dans les 6 langues** (recherche exhaustive, plus aucun texte en dur dans `lib/`) :
landing, login, signup, path_choice, cover_solo, cover_household, goal, activity, management_mode, household_size, smart_scale, supermarket, weekly_grid, budget, profile, constraints, kitchen, onboarding_cuisines, member_profiles, summary, home, recipe_sheet, shopping_list, pantry_add_manual, pantry_home, pantry_hub_onboarding, pantry_quick_check, pantry_scan, onboarding_data (dont `targetError`) — plus les widgets partagés (`menoo_header`, `menoo_nav_bar`, `step_progress`, `onboarding_step`, `list_section`/`FreshnessStatus`, `pantry_location`/`PantryLocation`).

**23/23 tests au vert, `flutter analyze` sans aucun problème, APK compilé et installé sur le téléphone.**

**Reste (hors du socle i18n, pour plus tard) :**
1. **Tables de traduction Supabase** pour les contenus (recettes, ingrédients, catégories, allergènes, régimes, cuisines, équipements), français en référence. Migration à montrer à Simo **avant envoi**. À faire avec le jalon 5c.
2. **Relecture humaine des allergènes et des régimes** dans les 5 autres langues, avant publication (SPEC §10) — **bloquant, non négociable**. Volume modeste (≈ 105 termes par langue).
3. Brancher `Formats` plus largement à mesure que de nouveaux écrans affichent poids/prix/dates (déjà fait partout où c'est affiché aujourd'hui).

## Changements de structure du 2026-09-30 — chiffrage et ordre proposés
Unité : **1 séance** = un bloc de travail de la taille du jalon 5 (construction + installation + test par Simo). Ce sont des estimations, à ±30 %.

| Bloc | Contenu | Effort | Coût externe | Dépend de |
|---|---|---|---|---|
| 1. Barre de navigation | « Semaine » → « Menus », barre absente avant le compte | 0,25 séance | 0 | — |
| 7. International | Textes de ~35 écrans sortis du code et traduits en 6 langues ; arabe de droite à gauche + police ; tables de traduction et reprise du catalogue existant ; unités, devises, dates ; enseignes en champ libre ; prix en 3 niveaux (structure) | 5 séances | Traductions par IA : quelques dollars. Relecture humaine des allergènes et régimes : à décider | — (à faire en premier) |
| 4. Landing déroulante | Page, 4 cartes, 4 aperçus d'écran, bouton collé | 1 séance | ≈ 0,20 $ si les aperçus sont générés | 7 (textes écrits une seule fois) |
| 5. Réassurance | 5 écrans, courbes existantes réutilisées, sources ADEME / INSEE à relever et citer | 1,5 séance | 0 | 7 |
| 3. Courses sans drive | Retrait du choix Drive / Livraison (étape Enseigne + base) : 0,5 séance maintenant. Mode magasin, partage, impression, PDF, texte : 1,5 séance au jalon 9, à la place du paiement et de la confirmation | 2 séances (dont 1,5 déjà prévue au jalon 9) | 0 | — |
| 6. Photo IA = Premium | Verrou sur les entrées photo, saisie et code-barres libres | 0,25 séance | 0 | 6b pour le paywall |
| 2. Jalon 6b | 5 écrans d'improvisation, reconnaissance par photo, correspondance catalogue, mise à jour de la réserve, 3 portes d'accès, cercle animé, fiche recette à 3 onglets avec flou, options d'achat simulées, compte invité et sauvegarde Google | 4 à 5 séances | Reconnaissance photo : de l'ordre de 0,01 à 0,03 $ par scan, à mesurer | 6, 5c, 7 |
| 8. Anti-fraude | Planifié seulement (jalon 12b) | 1 séance plus tard | 0 | avant publication |
| Catalogue ≈ 120 recettes (lancement) | Recettes, macros vérifiées, prix, 6 langues, photos | 1 à 1,5 séance en plus du 5c | Photos ≈ 6 $ ; rédaction et traduction par IA ≈ 3 à 5 $ | 7, 5c |
| Relecture humaine des allergènes et régimes | 14 allergènes + 7 régimes × 5 langues | hors développement | à chiffrer avec un traducteur (volume très faible : ≈ 105 termes par langue) | 7 |
| Catalogue vers 500 recettes | Après le lancement, par tranches | 3 à 4 séances | Photos ≈ 25 $ ; rédaction et traduction ≈ 10 à 20 $ | utilisateurs réels |

**Total des nouveautés : environ 14 à 17 séances**, en plus des jalons déjà prévus.

**Ordre recommandé** : 5i International → 5d Entrée et réassurance → 5c Recettes → 6 Compte et génération → 6b Improvisation et paywall → 7 → 8 → 9 → 10 → 11 → 12 → 12b → 13.
- International d'abord : sinon chaque écran et chaque recette créés ensuite seraient à reprendre.
- Entrée et réassurance juste après : elles touchent l'onboarding déjà construit et leurs textes naissent directement traduits.
- Le 6b après le 6 et le 5c : il a besoin du compte, du catalogue et de la fiche recette. **Il ne vaut que si le catalogue est assez large** : avec 96 recettes, beaucoup de frigos ne donneront aucune correspondance.

## Risque : l'improvisation cannibalise-t-elle la planification ?
Avis de Claude (2026-09-30) : risque **réel mais modéré**, et l'improvisation peut au contraire alimenter la planification si ces garde-fous sont en place.
- **Pont** : après une recette improvisée, proposer « Planifier le reste de ma semaine » ; le repas improvisé entre dans Menus et dans le Suivi.
- **Place** : le cercle n'apparaît que lorsqu'aucun repas n'est prévu ; la porte de `path_choice` reste une ligne légère.
- **Prix** : après 3 recettes achetées à l'unité dans le mois, montrer que l'abonnement revient moins cher.
- **Mesure** : part des utilisateurs d'improvisation qui génèrent un menu sous 14 jours (cible > 30 %) ; part de l'abonnement dans le revenu.
- **Vrai danger** : un catalogue trop petit, qui rendrait l'improvisation décevante dès le premier essai.

## Phase 2 (notée, non codée)
- **Liste de courses partagée en temps réel** entre les membres du foyer.

## 🔴 Jalon 12b — anti-fraude : BLOQUANT AVANT PUBLICATION
Validé par Simo le 2026-09-30. À ne pas coder maintenant, mais **l'app ne peut pas être publiée sans lui** : le scan offert (§0.8 de SPEC.md) se compte côté serveur, sinon une réinstallation le remet à zéro.
But : empêcher qu'on recrée des comptes pour consommer gratuitement les appels à l'IA.
- **App Set ID**, vérifié côté serveur. Pas le Firebase Installations ID (il disparaît à la désinstallation), pas l'ANDROID_ID (usage restreint).
- **Play Integrity** pour écarter les émulateurs et les apps modifiées.
- **Vérification dans une Edge Function avant l'appel à l'IA** (quota par appareil et par compte).
- **Déclaration obligatoire** dans la politique de confidentialité et le formulaire Sécurité des données de Google Play.

## Jalon 0 — détail
- [x] Flutter 3.47.5 stable dans `C:\src\flutter` (Dart 3.13.4)
- [x] Android SDK existant (`%LOCALAPPDATA%\Android\Sdk`, plateformes 34–37, build-tools 36) + cmdline-tools `latest`
- [x] Java : JBR d'Android Studio (OpenJDK 25) → `JAVA_HOME`
- [x] PATH utilisateur : flutter, platform-tools (adb), cmdline-tools, JBR, `C:\src\supabase`
- [x] `flutter doctor` : Flutter ✅, Android toolchain ✅
- [x] Supabase CLI 2.117.0 dans `C:\src\supabase`
- [x] Téléphone détecté : Xiaomi 2201117PG (série CEUGAIC6AEVGWCNF)
- [x] `supabase login` (Simo) + `supabase init` + lien vers `menoo-dev` (ref `pqdreuptzhenowqucvbl`, eu-central-1 Francfort, org Menoo-dev)

## Jalon 1 — détail
- [x] Projet Flutter `menoo` (Android seul), identifiant `com.menoo.app`, nom affiché « Menoo »
- [x] Icône de l'app générée depuis `design/logo.png` (mipmap mdpi → xxxhdpi)
- [x] `lib/theme/app_colors.dart` (couleurs DESIGN_V2) + écran provisoire logo + « Menoo »
- [x] `flutter analyze` sans erreur, test de démarrage OK
- [x] NDK 28.2.13676358 installé (exigé par Flutter 3.47)
- [x] APK debug installé et lancé sur le Xiaomi (« Installer via USB » activé par Simo)

## Notes techniques pour reprendre
- Norton 360 (PC) intercepte le HTTPS → Gradle utilise `C:\src\certs\menoo-truststore.jks` (cacerts JBR + racine Norton), réglé dans `android/gradle.properties`. Pour sdkmanager : `JAVA_OPTS=-Djavax.net.ssl.trustStore=C:/src/certs/menoo-truststore.jks -Djavax.net.ssl.trustStorePassword=changeit`.
- Commandes : `flutter build apk --debug` puis `adb install -r build\app\outputs\flutter-apk\app-debug.apk`.

## Jalon 2 — détail
- [x] `lib/theme/` : couleurs, espacements, rayons, ombres, tailles, typo (Plus Jakarta Sans + Caveat embarquées), icônes SVG des maîtres, thème + transition d'écran
- [x] `lib/widgets/` : en-tête (+ retour, avatar, feuille déco), progression d'étapes, boutons (principal animé, secondaire, social, lien), carte à choix, indicateur de sélection, puces/badges/filtres, champs (icône, unité, segment, case à cocher), cartes, encarts info/alerte, jauge, anneau, mini-courbe, barre de navigation, section de liste
- [x] 9 écrans : landing, connexion, choix du mode, objectif (1/11), profil (2/11, gabarit formulaire), accueil Solo, fiche recette, réserve par emplacement, courses gratuit
- [x] Menu provisoire `screens/dev/masters_gallery_screen.dart` (à retirer au jalon 4)
- [x] Contrôle qualité : comparaisons maître HTML / référence / téléphone dans `design/qa/jalon2/`
- Images décoratives nettoyées (copies dans `assets/images/`, originaux intacts) : feuilles (barre d'état iPhone, bord noir, fond blanc → transparent), bol landing (texte parasite), photo saumon (trait noir)
- Rendu HTML des maîtres : Edge headless dans une iframe 393 px (voir historique de session) ; captures téléphone via `adb exec-out screencap -p` + `uiautomator dump` pour trouver les boutons

### Jalon 2 — corrections après retours (2026-09-23)
- 114 photos HD des écrans Stitch téléchargées en taille originale (1408×768) dans design/stitch_images/ (plats, ingredients, decors, portraits, enseignes, autres) + INDEX.md ; 6 liens expirés ; ancien logo Stitch gardé en 1 exemplaire.
- Remplacées dans l'app : bol landing, photo recette, 3 repas de l'accueil, carte « Pour la famille », logo (512 px).
- Cartes avec photo latérale : photo ≥ 50 % de la largeur, hauteur min 232 (AppSizes.photoCardMinRatio / photoCardMinH) ; indicateur de sélection posé sur la photo.
- Photos du haut des cartes repas : 104 px ; photo recette : 250 px.
- Landing : tient sur un écran (visuel flexible, min 130 px), 4 points visibles.
- Comparaisons à 4 colonnes (maître HTML, référence, téléphone haut, téléphone bas).
- Visuels sans équivalent HD : design/stitch_images/A_FOURNIR.md.

## Jalon 3 — détail
- [x] 20260923120000_schema.sql : 17 types, 28 tables, vue recipe_catalog, triggers updated_at, profil créé à l'inscription
- [x] 20260923120100_rls.sql : RLS sur 28 tables, fonctions owns_*, premium non modifiable par l'app, menus/listes en lecture (écriture par Edge Function)
- [x] 20260923120200_catalog.sql : 6 rayons, 9 équipements, 6 régimes (sans porc / halal fusionnés), 14 allergènes, 80 ingrédients, 30 recettes (étapes de 3 recettes), 3 enseignes fictives
- [x] 20260923120300_demo_data.sql : load_demo_data(owner) → Karim, famille Martin, 4 pièges (budget impossible, allergies cumulées, réserve couvrant tout, foyer de 7)
- [x] Vérification locale PGlite 0.5.8 : 41/41 contrôles (migrations, profil auto, démo, catalogue, règles métier, RLS, pièges, suppression en cascade)
- [x] supabase db push vers menoo-dev (accord de Simo) + 20260923120400_backfill_profiles.sql (profil du compte créé avant la base)
- [x] Compte de test créé par Simo ; supabase/seed.sql appelle load_demo_data ; contrôle distant : 6 foyers, 21 membres, 89 produits en réserve, 93 créneaux, 30 recettes, 80 ingrédients ; db lint : 2 variables inutilisées (sans effet)
- Test local réutilisable : script PGlite (voir historique) — à ranger dans le projet au jalon 6 pour tester la génération

## Jalon 4 — détail
- [x] Parcours : landing → choix du mode → couverture Solo → 11 étapes → inscription (UI ; compte réel au jalon 6). Foyer : message « jalon 5 ». Connexion : message « jalon 6 ».
- [x] lib/onboarding/ : OnboardingData (réponses + calcul kcal/macros Mifflin-St Jeor), OnboardingScope, SoloFlow (ordre SPEC §2, détour Réserve SPEC §4, « Éditer » du récap qui y ramène)
- [x] Étapes : objectif, profil (validation), activité, balance (Health Connect au jalon 11, « Passer »), grille repas, budget (curseur 20→350 pas 5 + budget personnalisé), mode de gestion, contraintes (6 régimes, 14 allergènes, exclusions libres), Ma cuisine (niveau, temps 15/30/45/60+, 12 équipements), supermarché, récapitulatif (+ Ma cuisine + cible kcal)
- [x] Détour Réserve : hub sans compteur ni barre (regroupé par emplacement, filtres), vérification rapide, ajout manuel (catégorie détectée → emplacement + péremption proposés), code-barres et photo IA = écrans « bientôt disponible » (jalon 10)
- [x] Menu provisoire des maîtres supprimé ; l'app démarre sur la landing
- [x] test/solo_flow_test.dart : parcours complet (vraies polices) — 2/2 tests OK
- [x] Migration 20260924090000 : poids cible + rythme (+ garde-fous en base), 3 équipements ajoutés, démo mise à jour — testée PGlite 10/10 + 43/43, envoyée
- Script de contrôle téléphone : scratchpad qa_j4.ps1 (uiautomator + captures) ; comparaisons design/qa/jalon4/

## Jalon 5 — détail
- [x] Parcours unique : lib/onboarding/onboarding_flow.dart (OnbStep, listes Solo 12 étapes / Foyer 10 étapes) remplace solo_flow.dart ; le détour Réserve revient à l'étape qui suit le mode de gestion (Solo : contraintes ; Foyer : cuisines).
- [x] OnboardingData : mode (solo/foyer), membres (MemberDraft, famille Martin par défaut), qui cuisine, budget conseillé (30 € adulte, 20 € enfant, 10 € bébé, recalculé tant que le budget n'a pas été touché), portions, allergies par membre.
- [x] Écrans : couverture Foyer (photo recadrée 16:10 de decor_famille_repas_convivial), composition (adultes/enfants/bébés), profils des membres + fiche d'édition (prénom, tranche d'âge, sexe, âge, taille, poids, objectif et activité pour les adultes, allergies), variantes Foyer de la grille, du budget, des contraintes, du mode de gestion, des cuisines, de Ma cuisine (+ « Qui cuisine le plus souvent ? ») et du récapitulatif.
- [x] test/solo_flow_test.dart : 4/4 (Solo, garde-fous, Foyer complet avec détour, démarrage) ; flutter analyze : aucun problème ; formateur réglé à 120 colonnes (analysis_options.yaml).

## Jalon 5b — images par API (bilan 2026-09-28)
- Modèle OpenAI gpt-image (qualité « medium »), 125 images générées en 2 passes (10 essai + 112 lot ; 3 déjà présents avant lot). **0 échec, coût réel ≈ 6 $** (0,50 $ essai + 5,60 $ lot).
- Clé OPENAI_API_KEY : créée par Simo, déposée dans une variable d'environnement Windows (portée Utilisateur, 164 caractères) ; jamais dans la conversation ni dans l'app.
- Script `tools/generate_images.mjs` + manifeste `tools/visuals.json` (6 styles : ingredient, theme, recipe, decor, portrait, scene) ; sortie dans `assets/images/<dossier>/`, originaux dans `design/originals/generated/`.
- Planches de contrôle par famille : `design/qa/images_par_famille/*.jpg` (script scratchpad `build_sheets.ps1`).
- **Validé par Simo** : 80 ingrédients (fond blanc, packshots propres), 11 catégories (scènes cuisine claires), 3 emplacements (fridge, fruit_basket, freezer).
- **Non validé, à refaire** :
  - `leaf_b.png` (décor) : rendu tronqué, 2 feuilles au lieu d'une seule.
  - `mode_solo.jpg` : rendu incohérent (le modèle a mis un homme, hors sujet pour la carte).
  - **7 régimes** : approche photo abandonnée (le sens ne se lit pas — sans_lactose contient du yaourt qui lit « lait », sans_porc contient de la viande sans indice « pas de porc »). **Cible = pictogramme** stylisé sur pastille, à faire comme les objectifs (concepts abstraits).
- **Rien branché dans l'app** : ni déclaration dans `pubspec.yaml`, ni câblage des écrans (à faire à la reprise, après avoir fait les pictogrammes régimes et les 2 régénérations).

## Jalon 5c — recettes des 8 cuisines (plan chiffré, à ne pas créer avant le jalon)
Objectif : 12 plats principaux (déjeuner / dîner) par cuisine, dans la fourchette 10 à 15 voulue par Simo. Les petits-déjeuners et collations restent communs à toutes les cuisines.

| Cuisine | Plats existants | Cible | À créer | Exemples |
|---|---|---|---|---|
| Française | ~9 | 12 | 3 | blanquette, ratatouille, hachis parmentier |
| Italienne | 2 | 12 | 10 | lasagnes, pâtes pesto, minestrone, osso buco de dinde, gnocchis |
| Méditerranéenne | 3 | 12 | 9 | moussaka, falafels, souvlaki de poulet, shakshuka, taboulé |
| Maghrébine | 0 | 12 | 12 | tajine de poulet au citron, couscous légumes, chorba, kefta, zaalouk |
| Japonaise | 1 | 12 | 11 | poulet teriyaki, ramen, donburi, curry japonais, onigiri, saumon miso |
| Asiatique (Chine, Thaïlande, Vietnam) | 0 | 12 | 12 | pad thaï, bò bún, curry vert, riz cantonais, bœuf aux oignons |
| Mexicaine | 1 | 12 | 11 | chili sin carne, fajitas, tacos de poisson, enchiladas, bowl burrito |
| Américaine | 0 | 12 | 12 | burger maison, mac & cheese, poulet BBQ, chowder, salade Cobb |
| **Total** | | **96** | **80** | |

- Chaque cuisine : au moins 4 plats végétariens, 2 plats à moins de 2 € la portion, 3 plats en moins de 20 min, niveaux débutant / intermédiaire / confirmé, et des plats sans porc (pour que les régimes et le budget ne vident pas une cuisine).
- Base : nouvelle colonne recipes.cuisines (text[]) + étiquetage des 30 recettes existantes ; environ 45 nouveaux ingrédients (semoule, ras el hanout, lait de coco, pâte de curry, gingembre, miso, nori, haricots rouges, maïs, cheddar…).
- Photos : **les 80 photos de recettes seront générées par API** (décision Simo 2026-09-30, annule celle du 2026-09-28), ≈ 4 à 6 $. Les ~45 nouveaux ingrédients pourront réutiliser le style packshot IA validé (fond blanc), à la même consigne que le lot du jalon 5b.
- Vérifié en local (PGlite) : chaque cuisine × chaque régime garde assez de recettes, puis migration montrée à Simo avant l'envoi.

## Jalon 10 — idée d'architecture notée par Simo (2026-09-28, pas encore implémentée)
Détection de catégorie à l'ajout manuel en réserve, à faire une fois les ≈ 45 ingrédients du jalon 5c ajoutés :
- Aujourd'hui : liste de mots-clés en dur (`FoodCategory._keywords` dans `lib/screens/pantry/pantry_add_manual_screen.dart`), testée par `test/detect_test.dart`.
- Cible : le nom tapé est cherché dans la table `ingredients` de Supabase ; la catégorie vient de la base. La table porte déjà `aisle_code` (rayon), `default_location` (emplacement) et `shelf_life_days` (durée de conservation) : l'emplacement et la date de péremption proposés peuvent venir directement de l'ingrédient trouvé.
- La liste de mots-clés reste en secours pour les produits hors catalogue.
- Point à trancher : correspondance entre les 6 rayons (`aisles`) et les 7 catégories de l'écran (`FoodCategory`).
