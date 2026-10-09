# DECISIONS.md — Choix validés

## Révision scientifique de phase 2 — instructions de Simo, 2026-10-09

- 250 kg n'est pas une limite médicale universelle. Les bornes actuelles restent provisoires et aucun nouveau seuil de poids/IMC n'est ajouté. Un IMC élevé ne suffit pas à rejeter un profil ni à inférer sa masse grasse.
- Les protections techniques R01 restent autorisées. Toute modification des limites métier, formules, règles nutritionnelles et politiques de santé nécessite un accord distinct.
- Audit demandé des adultes, sportifs, 14–17 ans et profils familiaux, avec sources primaires identifiables. Les recommandations du rapport scientifique restent des propositions, pas des décisions validées.
- Aucun changement de design, Supabase, commit, push ou installation. Les phases 3 à 7 restent en attente.

## Phase 2 R01 — corrections autorisées par Simo, 2026-10-09

- Refuser NaN, Infinity et les dépassements dans les champs et le modèle, sans remplacer silencieusement les réponses. Bornes Solo inchangées : 14–100 ans, 120–230 cm, 35–250 kg. Règles familiales par rôle et corrections de phase 1 conservées.
- Cible maximale **provisoire de 250 kg** validée ; obligation hors Maintien, direction et IMC minimal conservés. Message traduit pour le dépassement. Pas de plafond métier arbitraire de durée.
- Formules BMR et règles de répartition conservées. Une répartition négative ou non calculable devient indisponible ; les calories valides restent affichées indépendamment. Aucun résultat inventé ni nouvelle formule.
- Projections et conversions protégées contre les valeurs non finies et les dépassements. Les réponses anciennes invalides restent présentes et sont signalées ; elles ne sont ni supprimées ni ramenées automatiquement à une borne.
- B09 explicitement réservé à la phase 4 ; aucune modification de sa conversion finie. Références visuelles non remplacées. Aucune modification Supabase, du design validé ou des illustrations ; aucune installation Android, commit ou push.
- Résultat technique : 115 régressions R01 passent ; suite complète 346 réussites, 13 échecs visuels préexistants, 1 test B09 différé. Analyse sans problème. Résultat à présenter à Simo ; phase 3 interdite avant son autorisation.

## Phase 1 des corrections après audit — accord de Simo, 2026-10-09

- B02 : seul un adulte peut être cuisinier principal. Si ce membre devient enfant ou bébé, retour à « À tour de rôle ». Attribution conservée lorsqu'il reste adulte ; changement reflété dans Ma cuisine et le récapitulatif.
- B01 : sans prénom, afficher le rôle traduit et son numéro ; préserver les prénoms, identifiants, allergies et exclusions. Les codes d'allergènes ne sont pas refactorisés : seule la traduction des noms affichés est corrigée.
- B03 : conserver PROVISOIREMENT 8 adultes, 8 enfants et 4 bébés. Ces limites ne sont pas des décisions produit définitives. Validation centralisée dans le modèle, refus des dépassements et protection du dernier adulte ; message compréhensible en FR/EN/DE ; aucune modification silencieuse des réponses existantes.
- Méthode validée : tests en échec avant correction, changements minimaux, contrôles des parcours, analyse Flutter et responsive 320/390 px. Pas de changement de design, Supabase, illustrations, installation Android, commit ou push. Les phases 2 à 7 attendent leurs validations successives.
- Résultat technique de phase 1 : 213 tests pertinents réussis, aucun échec ; analyse sans problème. Validation du résultat par Simo encore attendue.

- **2026-10-02 — Icones Mode de gestion validees et installees** : SVG sac de courses, placard et mixte, taille 36 px, trait 1.0, pastilles centrees verticalement. APK release compile puis installe sur Xiaomi autorise via adb install -r avec conservation des donnees. Demarrage verifie sur telephone, logs sans erreur. Autres elements du mode de gestion conserves ; harmonisation generale proposee non appliquee. Rendu sur telephone a verifier par Simo en poursuivant le parcours. Aucune publication.

- **2026-10-02 — Mode de gestion : icones centrees** : option centerIcon activee uniquement sur les trois cartes ManagementModeScreen a la demande de Simo. Trait 1.0, taille 36 px, autres elements conserves. Apercu Flutter et six tests de debordement reussis. Aucune installation.

- **2026-10-02 — Mode de gestion : trait affine** : sur demande de Simo, epaisseur des trois SVG reduite de 1.4 a 1.0. Formes, taille 36 px et autres elements conserves. Apercu Flutter reussi. Aucune installation.

- **2026-10-02 — Mode de gestion : proposition icones premium** : trio approuve pour preparation par Simo, sac avec baguette/feuille, placard ouvert avec provisions, sac et bocal avec deux fleches courbes. SVG trait 1.4, taille 36 px, limite aux trois icones de cartes. Textes, couleurs, marges, alignements et navigation conserves ; harmonisation generale non appliquee. Apercu Flutter reussi, a valider. Aucune installation.

- **2026-10-02 — Budget valide et installe** : apercu valide par Simo, APK release compile puis installe sur Xiaomi autorise via adb install -r sans effacer les donnees. Demarrage verifie sur telephone et logs sans erreur. Marges 14 px, textes secondaires bleu sombre, badge rayon 10 px et icones portefeuille/tirelire affinees ; photo, valeurs, curseur et logique conserves. Rendu Budget sur telephone a verifier par Simo en poursuivant le parcours. Aucune publication.

- **2026-10-02 — Budget : apercu harmonise a valider** : ajustements approuves, marges carte/champ/CTA 14 px, textes secondaires bleu sombre, badge photo rayon 10 px, icones portefeuille et tirelire detaillees au trait fin. Photo, montants, curseur, textes et fonctionnement conserves. Apercu Flutter, six tests de debordement et analyse reussis. Aucune installation ; attendre validation du visuel.

- **2026-10-02 — Grille des repas validee et installee** : apercu et icone assiette/couverts valides par Simo, APK release compile puis installe sur Xiaomi autorise via adb install -r, donnees conservees. Demarrage verifie sur telephone et logs sans erreur. Marges 14 px, textes secondaires bleu sombre et icone dediee ; cases, selections et navigation conservees. Rendu de la grille sur telephone a verifier par Simo en poursuivant le parcours. Aucune publication.

- **2026-10-02 — Icone Dej + Diner clarifiee** : premiere modification trop discrete selon Simo ; pictogramme remplace par assiette avec fourchette et couteau. Uniquement le SVG de cette action change, taille et bouton conserves. Apercu Flutter reussi ; aucune installation.

- **2026-10-02 — Grille des repas : apercu propose** : demande de visuel avant installation ; marges 14 px, introduction/en-tetes/compteur secondaire/conseil en bleu sombre et icone couverts au trait fin. Structure, cellules, selections et textes conserves. Apercu Flutter, six tests de debordement et analyse reussis. Aucune installation ; attendre validation de Simo.

- **2026-10-02 — Balance validee et installee** : apercu valide puis APK release compile et installe sur demande de Simo via adb install -r sur Xiaomi autorise. Donnees conservees. Demarrage sur telephone verifie, logs sans erreur. Marges 14 px et textes introduction/info bleu sombre ; autres elements conserves. Rendu Balance sur telephone a verifier par Simo en poursuivant le parcours. Aucune publication.

- **2026-10-02 — Balance : apercu harmonise a valider** : corrections approuvees par Simo limitees aux marges horizontales carte et CTA 14 px et aux textes introduction/info en bleu sombre. Photo, benefices, boutons et navigation conserves. Apercu Flutter et six tests de debordement reussis, analyse sans erreur. Aucune installation.

- **2026-10-02 — Niveau d activite valide et installe** : icones affinees validees par Simo, APK release compile puis installe via adb install -r sur Xiaomi autorise, sans effacer les donnees. Demarrage verifie sur telephone et logs sans erreur. Apercu et six tests de debordement reussis ; rendu Activite sur telephone a verifier par Simo en poursuivant le parcours (application relancee sur accueil). Aucune publication.

- **2026-10-02 — Icones Activite affinees sur demande** : remplacement des silhouettes schematiques par quatre pictogrammes detailles au trait 1.4 (bureau, empreintes de marche, chaussure de course, haltere). Taille 36 px, couleurs et pastilles conservees ; aucun autre ajustement. Apercu a valider, aucune installation.

- **2026-10-02 — Niveau d activite : corrections validees, apercu verifie** : marges et CTA 14 px, ecart cartes 10 px, quatre icones vectorielles fines 36 px centrees, descriptions 13 px bleu sombre et textes secondaires harmonises. Cartes blanches, pastilles pastel, textes et navigation conserves. Analyse sans erreur, apercu Flutter et six tests de debordement reussis. Aucune installation ; validation du visuel puis installation sur demande.

- 2026-10-02 · Simo autorise harmonisation du Profil : marges 14 px, textes secondaires bleu sombre, nouvelle icone balance pour objectif de poids ; champs blancs, selections vertes et scroll conserves. Apercu avant installation.

- 2026-10-02 · Simo valide les quatre descriptions Objectif plus concises et le centrage vertical des pastilles ; montrer le rendu avant installation.

- 2026-10-02 · Simo valide le visuel des quatre nouvelles icones de la page Objectif. Integration vectorielle avec apercu avant installation ; les autres ajustements de cet ecran restent a confirmer.

- 2026-10-02 · Simo prefere les cartes blanches originales pour Pour moi ; les nouvelles icones agrandies et leurs pastilles pastel restent. Corriger le caractere parasite entre sur et mesure sans changer la phrase.

- 2026-10-02 · Simo confirme les corrections de coherence du seul ecran Pour moi : marges 14 px, ecarts 10 px, textes 13 px bleu sombre, cartes pastel, badge moins arrondi et compte reel de 11 etapes. Apercu avant installation.

- 2026-10-02 · Simo valide les trois icones Solo proposees et autorise leur remplacement uniquement. Pictogrammes vectoriels nets a toutes les tailles, sans nouvel asset bitmap.

- 2026-10-02 · Simo autorise les ajustements de cohérence du choix Solo/Famille après audit : marges et espacements alignés à la landing, palette pastel et textes bleu sombre, lien équilibré. Visuel validé puis installation autorisée et effectuée ; photos, structure et logique conservées.

- 2026-09-23 · Couleur principale : `#0B6B43` (DESIGN_V2.md), et non `#1E4620` (PRD.md §6, obsolète). DESIGN_V2 est prioritaire.
- 2026-09-23 · Outils installés hors dossier projet : Flutter `C:\src\flutter`, Supabase CLI `C:\src\supabase`. Java = celui d'Android Studio.
- 2026-09-23 · Projet Supabase : `menoo-dev` (ref `pqdreuptzhenowqucvbl`, Francfort). Les autres projets du compte (menoo-rork-sandbox, Menoo-nutrition…) ne sont pas utilisés.
- 2026-09-23 · Identifiant de l'app : `com.menoo.app` (définitif après publication).
- 2026-09-23 · Norton 360 : on ne touche pas à ses réglages ; Gradle utilise un magasin de certificats séparé (`C:\src\certs\menoo-truststore.jks`).
- 2026-09-23 · Design : les images `design/masters/ref/05-08` sont la référence visuelle des 4 types ; les maîtres HTML donnent structure et contenu à jour (9 écrans maîtres au total).
- 2026-09-23 · Progression d'onboarding = segments + « ÉTAPE X SUR N » (DESIGN_V2, maître HTML, réf. 04), pas les points de la réf. 05.
- 2026-09-23 · Réserve : statut « Frais » affiché en toutes lettres (vide dans le maître HTML, présent dans la réf. 08).
- 2026-09-23 · Icône « Perte de poids » descendante (réf. 04) au lieu de montante (maître HTML).
- 2026-09-23 · Micro-animations : rétrécissement 2 % au toucher, transitions glissement + fondu, bascule animée des sélections, jauges/anneaux animés à l'affichage.
- 2026-09-23 · Méthode : PLAN.md et DECISIONS.md sont mis à jour à la fin de chaque jalon et avant toute tâche longue ; PLAN.md indique toujours l'état actuel et la prochaine action (règle ajoutée à CLAUDE.md).
- 2026-09-23 · Onglet Semaine : icône couverts (comme les maîtres), pas calendar_month (validé par Simo).
- 2026-09-23 · Menu provisoire des écrans maîtres : réservé aux tests, supprimé au jalon 4 dès que la vraie navigation existe.
- 2026-09-23 · Cartes avec photo : la photo occupe au moins 50 % de la largeur de la carte, cartes plus hautes pour laisser respirer les photos ; règle appliquée à toutes les cartes à photo.
- 2026-09-23 · Images : priorité aux photos HD des écrans Stitch (design/stitch_images/), redimensionnées à 1080 px max dans l'app ; les manques sont listés dans design/stitch_images/A_FOURNIR.md.
- 2026-09-23 · Landing : tout l'écran visible sans défilement (visuel flexible), avec les 4 points du carrousel.
- 2026-09-23 · Rayons : cartes 14 px (au lieu de 18, DESIGN_V2.md mis à jour), vignettes internes 10 px (pastilles d'icône, macros, jours), boutons 14 px, champs 12 px — tout dans `AppRadius`. Remplace le « rayon 18 px » de SPEC §0.
- 2026-09-23 · Progression d'onboarding : 4 segments fins (4 px) en fenêtre glissante sur les N étapes (l'étape en cours est le 3e segment), remplissage + glissement animés à l'arrivée sur chaque écran ; « ÉTAPE X SUR N » à droite.
- 2026-09-23 · Décor basilic : feuilles entières (leaf_a) + grains de poivre noirs et rouges, toujours à l'intérieur de l'écran (marge 8 px), jamais sous la barre système. leaf_b (tronquée à la source) n'est plus utilisée.
- 2026-09-23 · Landing : photo au format 5:4 non rognée (recadrage 5:4 fait sur l'original HD), à la plus grande taille qui laisse boutons et points visibles ; phrase manuscrite posée sur son coin haut gauche.
- 2026-09-23 · Cartes à photo latérale : photo = exactement la moitié de la carte (2 moitiés égales), pleine hauteur ; bordure dessinée par-dessus la photo (pas de bande).
- 2026-09-23 · Landing (remplace les décisions précédentes sur la landing) : photo 5:4 pleine largeur, bord à bord, sans coins arrondis ; la page peut défiler ; « Commencer gratuitement » visible sans défiler (liste des 4 avantages compacte, pastilles 34 px).
- 2026-09-23 · Régimes : « halal » fusionné avec « sans porc » (un seul régime « Sans porc / halal », code sans_porc).
- 2026-09-23 · Base : Solo = foyer d'un seul membre ; montants en centimes ; RLS sur toutes les tables ; `premium` non modifiable par l'app ; menus et listes écrits uniquement par la génération (Edge Function) ; un menu « prêt » ne peut pas dépasser le budget (contrainte SQL).
- 2026-09-23 · Démo : tous les foyers de démo (Karim, Martin, 4 pièges) appartiennent au compte de test f0d6936f-c874-47e5-9767-eb7756095d72 (créé par Simo) ; Karim est le foyer actif.
- 2026-09-23 · Piège « budget impossible » = foyer de 4 personnes à 20 € (la semaine la moins chère coûte ≈ 63 €) ; en Solo, 20 € restait faisable (≈ 15,68 €).
- 2026-09-23 · Onboarding : réponses gardées en mémoire (OnboardingData) jusqu'à la création du compte (jalon 6), puis enregistrées en base. Aliments exclus saisis librement (rapprochés du catalogue au jalon 6).
- 2026-09-23 · Balance (étape 4) : pas de faux appareils détectés ; l'utilisateur choisit « Associer via Health Connect » (autorisation demandée après la création du compte, jalon 11) ou « Passer ».
- 2026-09-23 · Code-barres et photo IA dans le détour Réserve : écrans « bientôt disponible » avec repli sur l'ajout manuel ; fonctions réelles au jalon 10.
- 2026-09-23 · Équipements (écran « Ma cuisine ») : 12 choix = les 9 de l'écran design/new + wok, grille-pain, cuiseur vapeur (utilisés par des recettes). Autocuiseur, mijoteuse et plancha à ajouter en base (migration à valider).
- 2026-09-23 · Chiffres retirés (SPEC §0.4) : « moins de 20 min », « moins de 3 minutes », « jusqu'à 45 min », « 35 € de réduction », « 22 € par semaine », rayons « synchronisés ». Remplacés par des promesses vérifiables (« Budget respecté chaque semaine », « 11 étapes rapides »).
- 2026-09-23 · Titres : traits d'union insécables (« sur-mesure », « souhaitez-vous » ne se coupent plus).
- 2026-09-24 · Retours jalon 4 (Simo) : poids cible et rythme hebdomadaire sur l'étape Profil (garde-fous IMC ≥ 18,5, ≤ 1 kg/semaine, date estimée) ; icônes sur pastilles pastel par famille ; photos d'aliments partout où elles existent, sinon icône sur pastille ; enseignes = icônes stylisées neutres (jamais de logo officiel sans accord) ; vert dominant, pastels doux.
- 2026-09-24 · Poids cible : saisi à l'étape Profil après le poids actuel. Perte : rythmes 0,25 / 0,5 / 0,75 kg/sem ; prise de masse : 0,25 / 0,5 ; sèche : poids cible + déficit fixe 0,5 kg/sem, protéines 2 g/kg (« masse musculaire préservée ») ; maintien : aucun. Refus si IMC < 18,5 (message expliquant le seuil et le minimum conseillé), si le sens est incohérent ; perte jamais > 1 kg/sem. Projection « X kg → Y kg, environ N semaines », date estimée.
- 2026-09-24 · Calcul calorique : besoin = métabolisme (Mifflin-St Jeor) × activité ± rythme × 7 700 kcal / 7 (0,5 kg/sem ≈ 550 kcal/jour), plancher = max(métabolisme de base, 1 500 kcal homme / 1 200 kcal femme).
- 2026-09-24 · Base : household_members.target_weight_kg et weekly_rate_kg, contraintes SQL (IMC ≥ 18,5, rythme permis, pas de cible en maintien, prise ≤ 0,5 kg/sem). Changer d'objectif depuis le récapitulatif renvoie à l'étape Profil si le poids visé n'est plus cohérent.
- 2026-09-24 · Pastilles : familles menthe / pêche / vert tendre / bleu clair / lavande / sable (enum Tint). Objectifs, activité, mode de gestion, niveaux, régimes, allergènes, équipements, modes de récupération, emplacements et blocs du récapitulatif ont chacun leur teinte ; la sélection reste en vert.
- 2026-09-24 · Photos d'aliments : 18 vignettes carrées (assets/images/food/) tirées de design/stitch_images, associées par mots-clés (FoodImages) ; sinon icône sur pastille de l'emplacement. Photo « flocons d'avoine » écartée (marque visible).
- 2026-09-24 · Enseignes : monogramme (initiales) sur pastille de notre palette, sans logo ni couleur de marque.
- 2026-09-24 · Régimes : « Omnivore » ajouté et choisi par défaut (= aucune restriction, aucune ligne en base) ; « Sans porc / halal » renommé « Sans porc » (migration 20260924120000, remplace la décision « Sans porc / halal » du 2026-09-23).
- 2026-09-24 · Parcours Solo en 12 étapes : nouvelle étape 9 « Types de cuisine appréciés » (méditerranéenne, française, asiatique, orientale/maghrébine, italienne, indienne, mexicaine, africaine ; choix multiple ; aucun choix = toutes), juste après les contraintes. Remplace le compteur 11 de SPEC §2 (validé par Simo).
- 2026-09-24 · Équipements et niveaux de cuisine : tuiles photo produit détourée sur fond blanc (équipements sur 2 colonnes, niveaux sur 3), case verte en haut à droite, bordure verte si sélectionné ; en attendant les photos : cadre gris clair + icône sobre, jamais de pastille colorée sur l'écran « Ma cuisine ». Les pastilles restent sur les autres écrans.
- 2026-09-24 · Enseignes : monogramme neutre + nom + modes de retrait habituels (le mode choisi est mis en avant) ; logos officiels uniquement en cas de partenariat signé.
- 2026-09-24 · Contrôle qualité : plus de captures automatiques du téléphone (demande de Simo, coût et durée). J'installe l'app et j'indique quoi tester ; Simo vérifie lui-même. Remplace la règle « capture + comparaison côte à côte » de CLAUDE.md jusqu'à nouvel ordre.
- 2026-09-24 · Types de cuisine (liste de Simo, remplace celle du matin) : française, italienne, méditerranéenne, maghrébine, japonaise, asiatique (= Chine, Thaïlande, Vietnam), mexicaine, américaine. Indienne, africaine, orientale abandonnées. Choix = préférence (Menoo privilégie), jamais un filtre qui bloquerait la génération.
- 2026-09-24 · Images de Simo : originaux PNG conservés dans design/originals/, versions JPG allégées dans l'app (équipements et niveaux 512 px, cuisines 600 px). Les 3 niveaux sont des photos en scène (fond sombre) : affichés plein cadre, pas détourés.
- 2026-09-24 · Jalon 4 validé par Simo. Migration 20260924120000 (« Sans porc ») envoyée sur menoo-dev avec son accord.
- 2026-09-24 · Images : générées par l'API OpenAI (gpt-image, qualité medium), essai de 10 images validé par Simo avant le reste. La clé est créée et déposée par Simo dans une variable d'environnement de son PC ; elle n'apparaît jamais dans la conversation ni dans l'app.
- 2026-09-24 · Objectifs, niveaux d'activité et modes de gestion : icônes sur pastilles conservées (concepts abstraits, écran Objectif validé). Photos réservées à ce qui se mange : ingrédients, catégories, régimes, allergènes, recettes, cuisines.
- 2026-09-24 · Cuisines peu couvertes : on complète la base (aucune cuisine masquée), 10 à 15 plats principaux par cuisine (cible 12 → 80 recettes à créer), dans un jalon à part (5c).
- 2026-09-24 · Ordre de travail : Foyer (jalon 5) → images par API (5b) → recettes des 8 cuisines (5c) → jalons 6 et suivants, pour valider des écrans complets avec les vraies images.
- 2026-09-24 · Foyer (jalon 5) : 10 étapes dans l'ordre SPEC §3 ; les étapes communes réutilisent les écrans Solo avec des textes « foyer ». Famille Martin (SPEC §9) préremplie comme Karim en Solo. Membres affichés avec une pastille à l'initiale (pas de photos de personnes). Allergies saisies par membre, rappelées aux contraintes partagées et exclues pour tout le foyer.
- 2026-09-24 · Foyer : repas par défaut = tous les dîners + déjeuners du week-end (9) ; budget conseillé = 30 € × adultes + 20 € × enfants + 10 € × bébés (le 10 € bébé est un ajout, SPEC muet) ; prix affiché « par portion ». Pas de cible calorique au récapitulatif Foyer (chaque profil aura la sienne au jalon 6). « À tour de rôle » = aucun cuisinier principal en base.
- 2026-09-24 · Couverture Foyer : « configuration en 3 minutes » remplacé par « 10 étapes rapides » (SPEC §0.4) ; photo 16:10 pour garder les 4 membres de la famille.
- 2026-09-28 · Jalon 5b : 125 visuels générés par l'API OpenAI en 2 passes (0 échec, ≈ 6 $). Validés par Simo : 80 ingrédients, 11 catégories, 3 emplacements. À refaire : `leaf_b.png` (tronquée) et `mode_solo.jpg` (rendu hors sujet).
- 2026-09-28 · **Régimes ne sont pas photographiables** : les 7 photos IA du lot 5b sont écartées (le sens du régime ne se lit pas — sans_lactose contient du yaourt qui lit « lait », sans_porc contient de la viande sans indice « pas de porc »). Cible = pictogramme stylisé sur pastille, même traitement que les objectifs / concepts abstraits (décision 2026-09-24 étendue). Les allergènes en photo restent valides (ce sont des ingrédients, pas des concepts).
- 2026-09-28 · **Photos de recettes : pas d'IA**. Les 80 photos de recettes du jalon 5c seront photographiées ou prises en banque d'images (les textures des plats ratent en génération IA). Les 6 recettes petit-déj + tablée famille du lot 5b passent quand même car acceptables. Réduit la portée de 5c au travail base + recettes + ingrédients ; les photos plats seront traitées à part.
- 2026-09-30 · Jalon 5 (Foyer) validé par Simo.
- 2026-09-30 · Budget conseillé Foyer : **25 € par bébé** (remplace les 10 € du 2026-09-24) ; adulte 30 €, enfant 20 € inchangés.
- 2026-09-30 · Avatars des membres du foyer : pastille avec initiale, validé par Simo (pas de photos de personnes).
- 2026-09-30 · Régimes en pictogrammes sur pastille (validé par Simo) ; les régimes « sans … » montrent l'aliment barré (cochon, bouteille de lait, épi de blé). Les 7 photos de régimes ne sont pas embarquées dans l'app.
- 2026-09-30 · **Photos de recettes : générées par API** comme les 125 autres (annule la décision « pas d'IA » du 2026-09-28). Coût estimé ≈ 4 à 6 $ pour 80 photos. À lancer au jalon 5c, pas avant.
- 2026-09-30 · Photos d'aliments : la photo du catalogue (assets/images/ingredients/) est choisie d'après le nom, la plus précise d'abord ; les 18 anciennes vignettes servent de secours.
- 2026-09-30 · Jalon 5c suspendu : Simo donnera d'abord des changements qui touchent la structure de l'app.
- 2026-09-30 · **Aucune référence à l'alcool dans les visuels** (app classée 3 ans et plus sur Google Play) : le visuel « sulfites » montre uniquement des fruits secs (abricots, raisins, fruits confits). Règle valable pour tous les visuels à venir, recettes comprises.
- 2026-09-30 · Les 125 visuels du jalon 5b sont validés par Simo. leaf_a régénérée (l'ancienne, 60 × 90 px, avait un détourage en escalier) et recadrée au ras des feuilles ; leaf_b validée (PNG transparent).
- 2026-09-30 · Jalon 5b validé par Simo.
- 2026-09-30 · Budget bébé à 25 € confirmé et voulu : lait infantile et petits pots coûtent plus cher au kilo qu'un repas d'enfant, qui mange en partie comme les adultes.
- 2026-09-30 · Photos de recettes (5c) : essai de 5 photos montré à Simo avant de lancer le lot complet de 80.
- 2026-09-30 · **Débordement de texte corrigé** (signalé par Simo sur les 3 boutons de la Réserve) : tout label de bouton/champ à largeur fixe rétrécit désormais plutôt que de déborder (`Flexible` + `FittedBox(scaleDown)`). Vérifié par un test de balayage systématique (`test/overflow_sweep_test.dart`, 30 écrans × 6 langues) qui a trouvé et permis de corriger 3 autres cas (`profile`, `shopping_list`, `constraints`). Ce test reste dans `test/` comme garde-fou permanent contre ce type de régression à chaque nouvel écran.

## Changements de structure du 2026-09-30 (demandés par Simo ; rédaction dans SPEC.md v4 en attente de sa validation)
- 2026-09-30 · Barre de navigation : Accueil · Menus · Courses · Réserve · Suivi. « Semaine » devient « Menus » partout. Réglages par l'avatar. La barre ne s'affiche jamais avant la création du compte.
- 2026-09-30 · Nouveau jalon 6b, improvisation + paywall construits ensemble après le jalon 6. Parcours en 6 étapes : scan ou sélection manuelle, convives, condiments (6 à 8 cases ; sel, poivre et huile supposés présents), équipement, choix de cuisine (disponible / presque / indisponible, liste dépliable, nombre de recettes), recette.
- 2026-09-30 · **L'IA ne crée rien** : elle reconnaît les ingrédients puis cherche dans le catalogue. Recette générée librement en dernier recours seulement, marquée comme telle et hors budget garanti.
- 2026-09-30 · Le scan met la réserve à jour : ajouts, retraits avec confirmation, périmés en rouge d'après les dates en base. L'IA ne lit pas les dates sur une photo.
- 2026-09-30 · Trois portes vers l'improvisation : ligne légère sous les cartes de Path_Choice, cercle animé sur l'Accueil quand aucun repas n'est prévu (pulsation de 3 à 4 s, seule forme ronde de l'app), accès permanent depuis l'onglet Réserve.
- 2026-09-30 · Fiche recette à trois onglets : Ingrédients et Ustensiles visibles, Instructions floutées après 3 lignes. Options : 0,90 € la recette, 9,99 €/mois résiliable, 49,99 €/an. Jamais de carte bancaire pour essayer. Résiliation simple via Google Play Billing. Lots de 5 et 15 recettes à chiffrer.
- 2026-09-30 · Le compte arrive après la valeur : bouton Google formulé comme une sauvegarde, « Plus tard » toujours visible, données d'avant le compte conservées à sa création.
- 2026-09-30 · Drive supprimé : plus de ShoppingList_Checkout ni de ShoppingList_Confirmation, plus de choix Drive / Livraison / En magasin. L'enseigne ne sert qu'aux prix et au tri par rayon. À la place : mode magasin, partager, imprimer en A4, PDF, copier en texte. Liste partagée en temps réel : phase 2.
- 2026-09-30 · Landing : page déroulante (promesse et 4 avantages, puis 4 cartes Scan IA / Menus / Courses / Suivi sans bouton), un seul bouton « Commencer » collé en bas.
- 2026-09-30 · 5 écrans de réassurance hors compteur : trajectoire de poids, métabolisme, économies, gaspillage évité, plan prêt. Jamais de silhouette avant/après. Aucun chiffre inventé : réponses de l'utilisateur ou source publique citée.
- 2026-09-30 · Photo IA = Premium, saisie manuelle et code-barres = gratuits, partout (détour Réserve compris). L'abonnement achète du confort, pas l'accès.
- 2026-09-30 · International avant les 500 recettes : textes sortis du code, tables de traduction (français en référence), 6 langues (français, anglais, espagnol, allemand, italien, arabe), unités métriques sauf États-Unis, devises et dates par pays, arabe de droite à gauche, enseignes en champ libre hors de France, prix en trois niveaux avec origine toujours affichée, badge « Estimation dans votre budget ».
- 2026-09-30 · Anti-fraude planifiée (jalon 12b), non codée : App Set ID côté serveur, Play Integrity, contrôle en Edge Function avant l'IA, déclaration dans la politique de confidentialité.
- 2026-09-30 · Maquettes de `design/maquettes/` : référence visuelle seulement ; SPEC.md fait foi (barre de navigation fausse, écran de cuisines qui mélange deux parcours).

### Propositions de Claude, à valider par Simo (pas encore des décisions)
- Compte invité créé à la première ouverture puis converti en vrai compte à l'inscription : les données d'avant le compte n'ont pas à être recopiées.
- Essai de 7 jours supprimé (il exigerait une carte bancaire).
- Lots : 5 recettes à 3,49 €, 15 recettes à 7,99 €.
- Foyer : 3 écrans de réassurance seulement (pas de trajectoire de poids ni de métabolisme).
- Fiche recette : « 4,3 note » retiré (chiffre inventé) ; « Interrogez le coach » écarté pour l'instant.
- Landing : « J'ai déjà un compte » en lien discret dans l'en-tête.
- Ordre des jalons : 5i → 5d → 5c → 6 → 6b → 7 → 8 → 9 → 10 → 11 → 12 → 12b → 13.
- 2026-09-30 · Écran Scan IA (improvisation, étape 1) : **deux états**. Au repos, la zone photo est un aperçu (illustration `scan_frigo_main.jpg` : une main tient un téléphone devant le frigo ouvert, étiquettes posées par l'app). Un appui sur l'onglet Frigo ou Garde-manger active la **caméra en direct** dans cette même zone, et un bouton **« Scanner »** apparaît pour déclencher la prise de vue.
- 2026-09-30 · Cercle d'improvisation de l'Accueil : **variante A retenue** (photo ronde du frigo). La variante B (assiette de plat préparé) est **abandonnée** : contresens, on scanne son frigo pour savoir quoi cuisiner, pas un plat terminé.
- 2026-09-30 · Règles de maquette (après le refus des versions 1 et 2) : partir des images de `design/maquettes/` pour le rendu et de SPEC.md pour la structure ; n'utiliser que les jetons du thème pour les arrondis, ombres et espacements (aucune valeur en dur, même en HTML) ; présenter chaque écran **côte à côte** avec sa maquette de référence, avec la liste des écarts.
- 2026-09-30 · **Vocabulaire figé** : `landing` = la page déroulante d'avant le compte (4 cartes de fonctions, bouton « Commencer ») ; `home` = l'onglet 1 de l'app après connexion (« Bonjour Karim », repas du jour, indicateurs, cercle d'improvisation). Deux écrans distincts, jamais fusionnés. Le mot « accueil » ne désigne jamais la Landing. Appliqué dans SPEC.md §0.13 et dans le code (`DashboardScreen` → `HomeScreen`).
- 2026-09-30 · **Règle de nommage** : un nom = un écran. Minuscules et tirets bas, pas de numérotation Stitch, suffixe `_household` pour le Foyer (jamais `_foyer`), nom nu = Solo. Les états d'un écran (gratuit/premium, repos/caméra) ne créent pas de nouveau nom. Inventaire complet et 14 corrections proposées en SPEC.md §15.
- 2026-09-30 · Cercle d'improvisation : **photo du frigo seule** (l'illustration avec la main serait illisible à cette taille).
- 2026-09-30 · **14 renommages d'écrans validés et appliqués** (SPEC.md §15). En particulier : « régime » est réservé aux **restrictions alimentaires** (végétarien, sans gluten) et le suivi du poids devient `tracking_weight` ; le préfixe `dashboard_` est remplacé par `tracking_` pour le Suivi et `home` pour l'Accueil ; `settings` = Solo et `settings_household` = Foyer (l'ancien couple inversait la règle).
- 2026-09-30 · **Landing** : les 4 cartes de fonctions restent **inertes**. Une **ligne légère sous le bouton « Commencer »** mène à l'improvisation, la même que sur `path_choice` — ce n'est donc pas une quatrième porte d'entrée. (Option (c) de SPEC §15.4, la carte Scan IA cliquable est écartée.)
- 2026-09-30 · **Projet sous Git**, à la demande de Simo, avec un commit avant et un commit après les renommages. `build/` et `.dart_tool/` exclus ; aucune clé dans les fichiers (la clé OpenAI reste dans une variable d'environnement Windows).
- 2026-09-30 · Maquette `accueil_deroulant.png` renommée `landing.png` (elle montre la Landing, pas l'Accueil).

## Les 13 points tranchés le 2026-09-30 (détail dans SPEC.md §14)
- 2026-09-30 · **1 scan photo offert par appareil**, sans compte. Sans lui, la promesse « Scan IA » de la Landing serait trompeuse. Le paywall n'arrive qu'**après** ce scan, jamais avant : on voit son écran avant qu'on lui demande de payer. Quota tenu côté serveur (jalon 12b), jamais dans l'app.
- 2026-09-30 · **Pas d'essai de 7 jours** : il exigerait une carte bancaire. Le scan offert et le repas offert tiennent ce rôle.
- 2026-09-30 · Menu et liste de courses floutés **conservés**, avec les trois mêmes options d'achat que la fiche recette.
- 2026-09-30 · **Lots : 5 recettes = 3,49 €, 15 recettes = 7,99 €.**
- 2026-09-30 · **Comparateur de prix entre enseignes conservé** : il ne sert qu'aux prix, c'est utile.
- 2026-09-30 · « J'ai déjà un compte » : **lien discret dans l'en-tête** de la Landing.
- 2026-09-30 · **« Interrogez le coach » écarté.** Il vient des maquettes d'Eatr, et une IA présentée comme une personne, photo de femme à l'appui, pose un problème d'honnêteté. La fonction pourra revenir plus tard, **annoncée clairement comme une IA**, sans visage ni prénom humains.
- 2026-09-30 · **Catalogue : 12 à 15 recettes par cuisine sur 8 cuisines, soit ≈ 120 au lancement** (96 au jalon 5c). Les 500 recettes viendront **après le lancement**, une fois qu'il y aura des utilisateurs.
- 2026-09-30 · **Traductions à deux niveaux** : relecture **humaine obligatoire** pour les allergènes et les régimes (risque de santé, non négociable, aucune langue publiée sans elle) ; traduction automatique pour tout le reste.
- 2026-09-30 · Maquette `scan_ia_accueil.png` renommée `scan_ia_ecran1.png` (elle montre l'écran 1 du Scan IA, pas l'Accueil).
- 2026-09-30 · Police arabe : **essai avec Noto Sans Arabic** (Google, licence libre), déclarée en police de secours. **Remplacée le même jour par Readex Pro**, sur choix de Simo : même esprit lisse et géométrique que Frutiger Arabic (police commerciale Monotype, trop chère pour une app distribuée), avec une licence libre SIL. Toujours en police de secours, jamais en police principale — Plus Jakarta Sans reste devant, donc « Menoo » et les mots latins gardent leur dessin au milieu d'un texte arabe.
- 2026-09-30 · Changement de langue **par appui long sur le logo Menoo**, provisoire jusqu'à l'écran Réglages (jalon 12) : aucun changement visuel, rien à défaire plus tard.
- 2026-09-30 · Unités et devises déduites du pays de la langue : métrique partout, **impérial aux États-Unis seulement**. Le séparateur décimal suit le pays du format, pas la langue des libellés.
- 2026-09-30 · **Choix de la langue** : la langue du téléphone est reprise automatiquement à la première ouverture, puis se change dans les Réglages (jalon 12). **Jamais de drapeau** — un drapeau désigne un pays, pas une langue, et l'espagnol ou l'arabe n'appartiennent à aucun pays en particulier. Chaque langue s'écrit dans sa propre écriture : Français · English · Español · Deutsch · Italiano · العربية. Langue et pays restent deux réglages distincts.
- 2026-09-30 · **Vérification automatique des textes en dur** (`test/i18n_test.dart`) : elle échoue en listant fichier, ligne et texte. Un écran annoncé comme traduit doit l'être entièrement — la liste des écrans restants doit finir vide.
- 2026-09-30 · **Sens de lecture** : jamais de position figée à gauche ou à droite (`start` et `end` uniquement) ; seules les icônes qui indiquent un sens se retournent (retour, flèche, chevron, tendance), pas les autres ; le bloc de marque garde son ordre, logo à gauche du mot « Menoo ».
- 2026-09-30 · **Captures d'écran par tests de rendu** (`test/golden_ar_test.dart`) plutôt que par le téléphone : plus rapide, reproductible, et permet de voir une langue sans toucher aux réglages du téléphone.
- 2026-09-30 · **Langue non proposée (japonais, polonais…) → repli sur l'anglais, jamais sur le français.** Le français est la langue de référence des traductions, pas la langue de secours : l'anglais a plus de chances d'être compris par quelqu'un dont la langue n'est pas encore gérée.
- 2026-09-30 · **Jalon 5i terminé** : après le passage en revue de Simo (arrondis, mise en forme arabe, exhaustivité), les 28 écrans restants ont été traduits dans les 6 langues, d'un bloc, sans montrer d'écrans intermédiaires. `test/i18n_test.dart` passe sans aucune exclusion : plus aucun texte d'interface en dur dans `lib/`. Les tables de traduction Supabase pour les contenus (recettes, ingrédients…) restent à faire, au jalon 5c.
- 2026-09-30 · **Plus aucune enseigne de supermarché nulle part dans l'app** (remplace « Comparateur de prix entre enseignes conservé » et les deux décisions du 24/09 sur le monogramme des enseignes, toutes les trois ci-dessus) : Menoo est internationale, une liste d'enseignes par pays n'est pas tenable. Supprimés : l'étape « Enseigne habituelle » de l'onboarding (Solo et Foyer), `shopping_list_supermarketselect`, `shopping_list_pricecompare`. La liste de courses garde une **estimation des prix** (sans enseigne) et un **tri par rayon générique** (fruits et légumes, viandes, crémerie…). SPEC.md mis à jour : onboarding Solo passe à 11 étapes, Foyer à 9.
- 2026-09-30 · Landing : pastilles des 4 avantages remises en **gris neutre uni** (pas d'alternance orange/mint, c'était une liberté prise sans base dans la maquette `design/maquettes/landing.png`) ; les 4 cartes de fonctions reprennent des **aperçus plus fidèles** à la maquette (photos/mockups réalistes) plutôt que des illustrations abstraites.

## Jalon 5d — corrections UI (2026-10-01)
- 2026-10-01 · **Écran supermarché supprimé** : fichier `supermarket_screen.dart` supprimé, clés de traduction `supermarket*`, `channel*` et `summarySupermarketTitle` retirées des 6 langues. L'écran n'était déjà plus dans la liste des étapes du flow.
- 2026-10-01 · **5 écrans de réassurance supprimés** (demande de Simo : redondants avec les écrans précédents). Fichier `reassurance_screens.dart` supprimé, logique d'insertion retirée de `onboarding_flow.dart`, clés `reassurance*` retirées des 6 langues. Le flow va maintenant directement d'une étape à la suivante. Le détour Réserve revient aussi directement à l'étape suivante, sans l'écran anti-gaspi intermédiaire.
- 2026-10-01 · **Landing : phrase manuscrite supprimée** (« Une vie plus saine au quotidien ! ») — pas dans la maquette, ajout créatif non demandé. Clé `landingHandwritten` retirée des 6 langues.
- 2026-10-01 · **Cartes de la landing interactives** : les 4 cartes ont maintenant une ombre (`boxShadow`) et sont cliquables. Scan IA → écran d'improvisation (coming soon) ; Menus, Courses, Suivi → choix du mode. Remplace la décision du 2026-09-30 sur les cartes inertes.
- 2026-10-01 · **Carte Suivi : fond menthe** (était lavande, détonnait avec le thème vert de l'app).
- 2026-10-01 · **Previews des cartes améliorées** : courses avec quantités et rayures sur les items cochés, suivi avec barres de macros P/G/L et chiffres kcal concrets au lieu d'un simple donut + jauge.
- 2026-10-01 · **Équipements en 3 colonnes** sur l'écran « Ma cuisine » (était 2 colonnes). Nouveau token `AppSizes.equipmentTileAspect3Col = 0.75`.
- 2026-10-01 · **Arrondis et tailles uniformisés** (écran Contraintes + global) : icônes des titres de section agrandies de 34 à 40 px (`iconTileSm` → `iconTile`), chips `ToggleChip` passées de pilule (999 px) à arrondi 12 px (`AppRadius.fieldR`) pour un style plus moderne, photos d'allergènes agrandies de 34 à 40 px, badges internes des chips agrandis de 24 à 28 px. Échelle des rayons cohérente dans toute l'app : cartes 14 px, champs/chips 12 px, pastilles 10 px — aucun widget en pilule sauf les éléments explicitement « pill » (badges, jauges, progress bar).
- 2026-10-02 · Animation de démarrage autorisée en local, sans publication : tracés vectoriels Flutter, copie optimisée (436 ko) du logo 3D fourni pour garder la géométrie exacte du fondu, textes de la liste localisés, animation écourtée quand l'app est prête et respect de la réduction des animations. Slogan choisi : « Bien manger, simplement. », traduit dans les 6 langues, affiché sous le logo à la fin avec une pause de lecture de 600 ms (démarrage prêt ≈ 2,6 s). La Landing validée reste inchangée ; pas d'installation pour cette étape.

- 2026-10-02 · Simo autorise l’extraction des images base64 de la landing vers les assets PNG, après sauvegarde locale vérifiée. Aucun changement du design ni de l’animation ; aucune publication.
- 2026-10-02 · Externalisation vérifiée sur téléphone : rendu strictement identique, aucune erreur ; le délai reste comparable avant/après. Les base64 ne sont donc pas démontrés comme cause principale du blanc au lancement.
- 2026-10-02 · Correction du lancement : le premier visuel Flutter approuvé est réutilisé pour l’écran natif Android ; la landing est préparée après la première frame et le chargement attend ses images. APK optimisé uniquement local, signé avec la clé de test existante, installé pour mesurer le démarrage sans publication. Sur deux lancements, accueil atteint vers 3,4–4,2 s contre environ 6,9 s précédemment ; rendu de l’accueil inchangé.
- 2026-10-02 · Simo valide le visuel de la carte Courses dézoomée et autorise son installation. APK optimisé installé et vérifié sur téléphone ; original conservé, aucune autre modification ni publication.
- 2026-10-02 · Fond transparent de la carte Courses validé et installé sur demande de Simo. Couleur uniforme vérifiée sur téléphone ; données conservées, aucune publication.
- 2026-10-02 · Carte Suivi dézoomée et transparente, indicateurs agrandis de 12 % : visuel et installation validés par Simo. APK optimisé installé et vérifié sur téléphone, données conservées, aucune publication.
- 2026-10-08 · **Stratégie de lancement linguistique** : seules les traductions English, Français et Deutsch sont proposées dans la version initiale. Les ARB et l’infrastructure Spanish, Italian et Arabic sont conservés pour une phase ultérieure, avec RTL arabe intact. Les chaînes de traduction restent génériques (`en`, `fr`, `de`) et le pays de l’appareil reste disponible pour les formats régionaux.
- 2026-10-08 · Marchés de lancement : USA, UK, Canada, Ireland, Australia, Germany, Austria, Switzerland, France et Belgium. Regional pricing / currencies to be implemented before commercial launch if required: USD, GBP, CAD, AUD, EUR, CHF.
- 2026-10-08 · **Convention du parcours Individuel : 7A — Remplissage de la Réserve.** Cet écran conditionnel ne compte pas parmi les 11 étapes principales. Depuis 7/11 « Mode de gestion », « Courses uniquement » va directement à 8/11 « Contraintes » ; « Réserves uniquement » et « Mixte » passent par 7A puis rejoignent 8/11. L’écran Réserve n’affiche actuellement aucun numéro d’étape ; aucun changement de navigation ni ajout de compteur demandé.


## 2026-10-09 — Rectification des règles produit après audit scientifique

- Parcours Individuel réservé à 18 ans et plus. Borne Solo 18–100 ans dans les champs, le modèle et les calculs ; poids/taille et formules inchangés. Refus des accès directs avec ancien âge mineur, sans substitution ni suppression de réponses. L’utilisateur corrige explicitement son profil.
- Parcours Famille : organisation des repas, budget, allergies et aliments non aimés. Aucun objectif de perte de poids, prise de masse ou sèche, déficit/surplus individualisé, macros par membre ou projection de poids. Les anciens champs techniques goal/activity restent conservés mais inactifs ; aucun nouveau moteur familial.
- Catégories familiales conservées indépendamment de Solo : adulte 14–100, enfant 4–13, bébé 0–3. Le libellé « adulte » dès 14 ans est signalé ; aucune reclassification arbitraire. Profils, allergies, exclusions et corrections B01/B02/B03 conservés.
- Restriction d’âge = choix produit, pas une preuve de validité médicale des équations pour chaque adulte admis. Autres recommandations de l’audit B restent à valider. Aucun changement des formules, Supabase, design, illustrations, commit, push ou installation Android. Phases 3 à 7 non commencées.


## 2026-10-09 — Phase 3 Réserve : règles autorisées et appliquées

- Classification par identités stables, expressions complètes et mots délimités. Les six suggestions conservent catégories, emplacements, unités et photos dans FR/EN/DE et les traductions ES/IT/AR. Noms libres conservés ; produits inconnus ou ambigus à choisir manuellement.
- B06 : origine verification_rapide + catégorie stable + emplacement. Validation identique sans doublon ; statut Présent/Quelques restes actualisé dans les deux sens. Produits manuels et lieux différents jamais fusionnés. Doublons historiques conservés ; ambiguïté signalée sans sélection arbitraire ni validation partielle. Non = aucune nouvelle déclaration, sans suppression.
- B07 : identifiants d’unités stables, traduction au rendu ; compatibilité des anciens libellés des six langues et conservation des inconnus. Aucun changement silencieux de quantité ou conversion d’unité. Statuts qualitatifs séparés ; aucune quantité alimentaire mesurée inventée pour une nouvelle déclaration rapide.
- Pommes de terre crues : légumes, placard proposé, aucune date automatique. Autres durées estimatives existantes conservées provisoirement. Dates manuelles prioritaires ; provenance estimée/choisie/inconnue explicite ; aucune transformation en DLC/DDM officielle.
- R02 : contrôle mounted après calendrier ; annulation et fermeture sans mutation ; dates Réserve en jours civils pour ne pas perdre un jour au changement d’heure. Aucun changement des projections Solo.
- B01/B02/B03 et R01 conservés ; aucune modification des règles nutritionnelles, Solo 18+ ou Famille. Rapport et preuves : reports/PHASE3_CORRECTIONS_ET_TESTS.md. Validation de ce résultat par Simo attendue ; phases 4 à 7 non commencées. Aucun commit/push, installation, Supabase, changement de design/illustration ou suppression.

- Résultat final phase 3 : 80 reproductions et 69 régressions supplémentaires passent ; 537 tests pertinents réussis, 0 échec, 1 B09 différé. Suite complète : 548 réussites / 13 échecs visuels historiques / 1 B09 différé. Analyse Flutter et diff check sans problème ; aucune référence visuelle remplacée.


## 2026-10-09 — Phase 4 : formats régionaux autorisés et appliqués

- Budget hebdomadaire entier dans sa devise native : FR/DE/BE EUR ; GB GBP ; US USD ; CA CAD ; AU AUD ; CH CHF. Code ISO explicite dans OnboardingData, montant inchangé lors d’un changement de langue/région. API historique budgetEuros conservée pour limiter les modifications ; elle désigne désormais le montant entier associé au code.
- Langue des libellés distincte du pays de l’appareil ; aucun nouvel écran de pays. Formatage uniquement, aucune conversion fictive ni modification des prix de démonstration ou d’abonnement.
- Budget hérité sans devise : montant conservé exactement, statut inconnu ; confirmation explicite sans choix prérempli dans l’écran Budget existant. Aucun nouveau parcours, aucune attribution automatique. Devise déjà connue conservée ; aucun changement automatique de devise.
- Saisie sans centimes : décimales, séparateurs de groupement et texte invalide refusés, sans suppression de caractères ni arrondi. Dernier montant valide conservé. Bornes et coefficients existants restent des paramètres provisoires du prototype, non des recommandations locales vérifiées.
- B09 : arrondir une seule fois les pouces totaux puis diviser/modulo 12 ; conserver les cm et les protections numériques. B10 : Formats.number avec locale complète, de-CH compris. Formules nutritionnelles inchangées.
- Résultats : 131 diagnostics et 38 contrôles supplémentaires réussis ; suite complète 718 réussites / 13 échecs visuels historiques / aucun test différé. Références visuelles inchangées. Rapport : reports/PHASE4_CORRECTIONS_ET_TESTS.md.
- La devise explicite existe dans le brouillon local ; le branchement futur de la persistance devra sauvegarder montant et code ensemble, sans déduire la devise des anciens montants. Aucun changement Supabase dans cette phase.
- Arrêt après phase 4. Prochaine intervention prévue : phase 4 bis, restructuration de l’étape 8 « Contraintes alimentaires », uniquement après accord. Phases 5–7 en attente. Aucun commit/push, installation Android, design ou illustration modifiés.


## 2026-10-09 — Phase 4 bis : quatre sections alimentaires autorisées et appliquées

- Régime principal unique : Omnivore (absence de code principal), vegetarien, vegan ou pescetarien. Restrictions sans_porc, sans_lactose, sans_gluten conservées dans les identifiants existants et cumulables. Anciennes combinaisons de plusieurs codes principaux préservées ; résolution sur choix explicite uniquement, aucune priorité automatique.
- Sept choix principaux d’allergies/problèmes liés aux aliments : arachides, fruits_a_coque, oeufs, soja, crustaces, mollusques, gluten. Crustacés et mollusques indépendants ; photo existante fruits_de_mer réutilisée, aucun nouvel asset. Gluten reste le code historique, affiché « Céréales contenant du gluten », sans diagnostic implicite d’allergie au blé ou de maladie cœliaque.
- Déroulant : poisson, lait, sesame, moutarde, celeri, sulfites, lupin ; aucun doublon. Lait et sans_lactose restent indépendants. Allergènes individuels des membres conservés ; union avec contraintes communes inchangée.
- Section « Aliments non aimés » : même saisie libre, mêmes valeurs dans excludedFoods, toujours contraignantes. Aucun assouplissement silencieux des anciennes exclusions. La future distinction de préférences facultatives et d’exclusions historiques exige une clarification explicite et un moteur adapté.
- Codes inconnus conservés et signalés, jamais traduits en un autre identifiant. Récapitulatif garde les choix précis et ne permet pas de contourner un conflit de régime.
- Textes des six langues adaptés sans promesse de protection médicale ou de compatibilité cœliaque. Relecture humaine des allergènes/restrictions et formulations de santé obligatoire avant publication ; aucune validation médicale nouvelle revendiquée.
- 42 reproductions échouent avant correction, passent après ; 23 contrôles supplémentaires passent (65 au total). Rapport complet : reports/PHASE4BIS_CORRECTIONS_ET_TESTS.md. Composants/style, nutrition, Solo 18+, règles Famille, phases 1–4 conservés. Aucune modification Supabase, commit/push, suppression d’asset ou installation. Phases 5–7 en attente.

- Vérification finale phase 4 bis : 783 tests réussis / 13 échecs visuels historiques / aucun ignoré ; 772 contrôles pertinents réussis. Analyse Flutter et diff check sans erreur. Retour à la ligne autorisé localement sur badges/puces des allergènes familiaux pour les nouveaux libellés ; aucun changement de style ou données.


## 2026-10-09 — Phase 5 B11 : compteur Famille

- La couverture Famille utilise OnboardingFlow.foyer.length (9), comme la couverture Solo utilise solo.length (11). Aucune nouvelle constante, modification d’ordre, étape ou composant partagé.
- Réserve reste un détour hors compteur ; après gestion Solo 7/11 rejoint Contraintes 8/11, après gestion Famille 6/9 rejoint Cuisines 7/9. Retours et édition depuis le récapitulatif conservés.
- Test de parcours Foyer obsolète actualisé pour vérifier 9 étapes rapides. Nouveaux contrôles : 38 réussites / 4 échecs responsive ES/IT 320 px préexistants ; 33 contrôles de lancement/ordres/parcours réussis. Suite complète : 821 réussites / 17 échecs / aucun ignoré, dont 13 golden historiques et 4 débordements hors périmètre. Analyse et diff check sans problème.
- Aucun changement de design pour résoudre ES/IT dans cette phase ; les six traductions restent intactes. Phases 1–4 bis préservées. Rapport : reports/PHASE5_CORRECTIONS_ET_TESTS.md. Arrêt après phase 5, phases 6–7 en attente ; aucun commit/push, Supabase, build ou installation Android.


## 2026-10-09 — Intégration autorisée des 23 icônes

- Prise de masse reprend le fichier renommé réel ; Réserves uniquement reçoit sa propre image, distincte de Ma réserve. Les sept régimes/restrictions remplacent seulement leurs illustrations, jamais Lait ou l’allergène gluten. Zéro gaspillage est autorisé sur les deux couvertures, calories/macros sur Solo seulement. Hub : uniquement Ma réserve et Vérification rapide, pas les actions, emplacements ou navigation.
- Originaux intacts. Copies techniques 256 px, PNG RGB, dans assets/images/new_icons/, déclaré dans pubspec.yaml. Réduction 94,81 %. Aucun alpha artificiel : fonds opaques conservés selon le repli autorisé ; cadres clairs restant visibles signalés pour validation humaine.
- Dimensions/style/animations/textes/sélections/navigation inchangés ; illustrationSize optionnel ajouté à ChoiceCard pour garder Gestion à 36 px, défaut 40 inchangé. SVG et PNG historiques conservés, aucune constante globale AppIcons remplacée.
- 113 contrôles ciblés réussis et dix comparatifs avant/après examinés. Rapport : reports/INTEGRATION_23_ICONES.md. Phases 1–5 conservées, 6B/7 non commencées ; aucun commit/push, Supabase ou installation Android. Validation de Simo requise avant nouvelle intervention.

- Résultat final intégration : 934 réussites / mêmes 17 échecs préexistants / aucun ignoré. Analyse et diff check sans problème. SHA-256 des 23 originaux et anciens assets inchangés ; aucun test préexistant modifié. Les quatre Golden des couvertures ont des différences supplémentaires attendues, sans actualisation de référence.


### 2026-10-09 - Correction visuelle des 23 icones

Copies RGBA transparentes, cadrage et tailles internes corriges localement ; originaux et pastilles preserves. Rapport : reports/CORRECTION_ICONES_3D.md. Tests : 113 cibles reussis ; suite complete 934 reussites / 17 echecs historiques ; analyse sans probleme. Validation visuelle utilisateur attendue ; phases 6B et 7 en attente. Aucun commit, push ou installation Android.


### 2026-10-09 - Agrandissement local des pastilles 3D

Pastilles concernees : 64 px (images 60), alimentaires 48 px (images 44), verification rapide 56 px (image 52). Ma reserve reste a 56/52 px ; proposition 64/60 en attente. Rapport : reports/AGRANDISSEMENT_PASTILLES_3D.md. Tests : 114 cibles reussis ; suite complete 935 reussites et 17 echecs historiques ; analyse sans probleme. Aucun asset modifie ni installation Android. Validation visuelle attendue ; phases 6B et 7 en attente.
