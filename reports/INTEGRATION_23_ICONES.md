# Intégration des 23 icônes autorisées

Date : 2026-10-09. Projet : C:\Users\simos\Menoo-Flutter-V2. Branche master, référence 4f569a0. Intervention distincte de la phase 6B ; phases 6B/7 non commencées.

## Inventaire réel et correspondances finales

23 PNG présents, aucun autre fichier source ni doublon identique. Les fichiers renommé « Prise de masse » et ajouté « Réserves uniquement » ont été lus sous leurs noms réels. Tous les originaux sont **1254 × 1254 px, PNG RGB, opaques**. Tous restent conservés, byte pour byte.

Copies : **256 × 256 px, PNG RGB opaques**, proportions carrées conservées, redimensionnement Lanczos et compression PNG sans quantification de palette. Noms techniques ASCII uniquement pour les copies ; aucune source renommée par cette intervention.

Dans le tableau, les tailles sont **image / pastille**, en pixels logiques. Chemins des copies relatifs au projet ; sources sous design/nouvelles_icones/.

| Original exact | Copie optimisée | Élément | Écran / portée finale | Taille image / pastille | Poids copie |
|---|---|---|---|---|---|
| `icone perte de poids.png` | `assets/images/new_icons/goal_loss.png` | Perte de poids | Objectif Solo | 40 / 56 px | 74830 octets |
| `icone prise de masse.png` | `assets/images/new_icons/goal_gain.png` | Prise de masse | Objectif Solo | 40 / 56 px | 93736 octets |
| `icone sèche et définition.png` | `assets/images/new_icons/goal_definition.png` | Sèche et définition | Objectif Solo | 40 / 56 px | 99726 octets |
| `icone maintien et équilibre.png` | `assets/images/new_icons/goal_balance.png` | Maintien et équilibre | Objectif Solo | 40 / 56 px | 93301 octets |
| `icone sédentaire .png` | `assets/images/new_icons/activity_desk.png` | Sédentaire | Activité Solo | 40 / 56 px | 85313 octets |
| `icone modéré.png` | `assets/images/new_icons/activity_walk.png` | Modéré | Activité Solo | 40 / 56 px | 101128 octets |
| `icone actif.png` | `assets/images/new_icons/activity_run.png` | Actif | Activité Solo | 40 / 56 px | 90894 octets |
| `icone tres actif.png` | `assets/images/new_icons/activity_training.png` | Très actif | Activité Solo | 40 / 56 px | 92016 octets |
| `icone courses uniquement.png` | `assets/images/new_icons/management_shopping.png` | Courses uniquement | Gestion Solo/Famille | 36 / 56 px | 93100 octets |
| `icone reserve uniquement.png` | `assets/images/new_icons/management_pantry.png` | Réserves uniquement | Gestion Solo/Famille, carte uniquement | 36 / 56 px | 106828 octets |
| `icone mixte.png` | `assets/images/new_icons/management_mixed.png` | Mixte | Gestion Solo/Famille | 36 / 56 px | 107132 octets |
| `Icone Adapté à votre temps.png` | `assets/images/new_icons/solo_time.png` | Adapté à votre temps | Couverture Solo | 36 / 56 px | 51895 octets |
| `Icone Calories et macros calculés.png` | `assets/images/new_icons/solo_nutrition.png` | Calories et macros | Couverture Solo exclusivement | 36 / 56 px | 56699 octets |
| `icone Zero gaspillage.png` | `assets/images/new_icons/solo_waste.png` | Zéro gaspillage | Couvertures Solo et Famille | 36 / 56 Solo ; 28 / 56 Famille px | 62611 octets |
| `icone omnivore.png` | `assets/images/new_icons/diet_omnivore.png` | Omnivore | Contraintes Solo/Famille | 40 / 40 px | 112934 octets |
| `icone végétarien.png` | `assets/images/new_icons/diet_vegetarian.png` | Végétarien | Contraintes Solo/Famille | 40 / 40 px | 107315 octets |
| `icone végan.png` | `assets/images/new_icons/diet_vegan.png` | Vegan | Contraintes Solo/Famille | 40 / 40 px | 114719 octets |
| `icone pescétarien.png` | `assets/images/new_icons/diet_pescatarian.png` | Pescétarien | Contraintes Solo/Famille | 40 / 40 px | 116555 octets |
| `icone sans porc.png` | `assets/images/new_icons/diet_no_pork.png` | Sans porc | Restrictions Solo/Famille | 40 / 40 px | 101416 octets |
| `icone sans lactose.png` | `assets/images/new_icons/diet_no_lactose.png` | Sans lactose, pas allergène Lait | Restrictions Solo/Famille | 40 / 40 px | 84323 octets |
| `icone sans gluten.png` | `assets/images/new_icons/diet_no_gluten.png` | Sans gluten, pas allergène gluten | Restrictions Solo/Famille | 40 / 40 px | 100385 octets |
| `icone ma reserve.png` | `assets/images/new_icons/pantry_reserve.png` | Ma réserve | Hub, carte titre uniquement | 26 / 56 px | 106458 octets |
| `icone vérification rapide.png` | `assets/images/new_icons/pantry_quick_check.png` | Vérification rapide | Hub, carte ouverture uniquement | 24 / 48 px | 78585 octets |

## Optimisation et traitement des fonds

- Avant : **41 059 971 octets**, soit 41,06 Mo / 39,16 Mio.
- Après : **2 131 899 octets**, soit 2,13 Mo / 2,03 Mio.
- Réduction : **94,81 %**. Aucun original supprimé ou écrasé ; les PNG historiques et SVG de l’app restent disponibles pour retour arrière.
- **23 fonds opaques conservés**. Les contours, rehauts et ombres 3D se fondent dans un fond blanc/gris clair ; un alpha exact n’est pas reconstructible avec certitude depuis ces RGB seuls. Aucun seuil automatique de blanc, effacement, quantification ou génération d’icône n’a été appliqué. C’est le repli autorisé par l’utilisateur lorsque le détourage n’est pas garanti.
- **Limite visuelle explicite** : les cadres clairs restent visibles sur certaines pastilles pastel, notamment Objectif, Activité et les trois avantages Solo. L’intégration n’a donc pas supprimé tout effet de carré clair. Un détourage professionnel ou des sources avec véritable alpha seraient nécessaires pour le retirer sans risque ; ceci reste à valider, pas réalisé silencieusement.
- Les couleurs des pastilles sont conservées dans le code ; les couleurs propres aux PNG sont naturellement présentes au centre. Aucun recoloriage des images ni des cartes.
- À 24/26/28 px, la silhouette générale est visible mais les petits ingrédients/détails des scènes 3D ne le sont pas tous. À 36/40 px, la forme et les interdictions sont plus identifiables. Aucun agrandissement de carte ou de pastille pour compenser. 256 px fournit une marge suffisante pour ces affichages sur écran haute densité ; aucun fichier 1254 px nouvellement chargé dans l’app.

## Emplacements Flutter et adaptations minimales

- goal_screen.dart : quatre références compare_goal_* remplacées par les copies autorisées ; sélection, objectifs et images de secours SVG conservés. Dimensions **40 px** (images déjà affichées avant), pas 36 des SVG de secours.
- activity_screen.dart : quatre compare_activity_* remplacés selon les noms exactement, y compris Actif et Très actif ; ordre, coefficients et sélections inchangés.
- management_mode_screen.dart : trois illustrationAsset locaux ; **Réserves uniquement** utilise management_pantry, exclusivement dans sa carte. Le SVG historique reste transmis comme avant.
- cover_solo_screen.dart : trois illustrationAsset locaux, **36 px**, pastilles **56 px** ; aucune modification du texte, des marges, du compteur ou du retour.
- cover_household_screen.dart : seul l’avantage Zéro gaspillage reçoit le PNG ; les icônes menus et budget restent intactes. Image **28 px**, pastille **56 px**, mêmes teintes et rayon.
- constraints_screen.dart : uniquement les sept chemins des régimes/restrictions ; images **40 px**. Les quatre sections, IDs, conflits historiques, saisies, allergies communes/individuelles et illustrations allergènes restent identiques.
- pantry_hub_onboarding_screen.dart : Ma réserve **26 px** dans la carte titre, Vérification rapide **24 px** dans sa carte ; pastilles 56/48 px. Eyebrow, état vide, actions, emplacements et navigation basse restent historiques.
- ChoiceCard : ajout du seul paramètre optionnel illustrationSize, défaut **40 px** identique à l’ancienne valeur fixe. Gestion fournit **36 px** pour conserver sa taille de dessin avant conversion SVG→PNG. Aucun nouveau moteur ni refactorisation générale ; IconTile est réutilisé.
- pubspec.yaml : ajout explicite du dossier assets/images/new_icons/. Aucun package ou dépendance ajouté.

Aucune constante AppIcons partagée remplacée. Les SVG/anciens PNG restent dans le dépôt ; aucun remplacement global de fridge/leaf/pantryReserve. BoxFit.contain conservé et vérifié par test pour chaque nouveau widget image.

## Aperçus avant/après

Captures des widgets réels, chargement des images attendu explicitement, polices réelles. Dix variantes FR à 390 px ont un comparatif avant/après. Viewport de capture **390 × 1500 px logiques**, capture native à DPR 2 ; la page n’est pas entièrement déroulée dans les aperçus Contraintes. Les contrôles responsive supplémentaires sont à 320/390 px. Ce ne sont pas des captures sur téléphone.

- [Objectif Solo — avant/après](C:/Users/simos/.codex/visualizations/2026/10/09/01a12009-4207-7b53-b4c3-391375738980/icons_integration/goal_compare.png)
- [Activité Solo — avant/après](C:/Users/simos/.codex/visualizations/2026/10/09/01a12009-4207-7b53-b4c3-391375738980/icons_integration/activity_compare.png)
- [Gestion Solo — avant/après](C:/Users/simos/.codex/visualizations/2026/10/09/01a12009-4207-7b53-b4c3-391375738980/icons_integration/management_solo_compare.png)
- [Gestion Famille — avant/après](C:/Users/simos/.codex/visualizations/2026/10/09/01a12009-4207-7b53-b4c3-391375738980/icons_integration/management_foyer_compare.png)
- [Couverture Solo — avant/après](C:/Users/simos/.codex/visualizations/2026/10/09/01a12009-4207-7b53-b4c3-391375738980/icons_integration/cover_solo_compare.png)
- [Couverture Famille — avant/après](C:/Users/simos/.codex/visualizations/2026/10/09/01a12009-4207-7b53-b4c3-391375738980/icons_integration/cover_foyer_compare.png)
- [Contraintes Solo — avant/après](C:/Users/simos/.codex/visualizations/2026/10/09/01a12009-4207-7b53-b4c3-391375738980/icons_integration/constraints_solo_compare.png)
- [Contraintes Famille — avant/après](C:/Users/simos/.codex/visualizations/2026/10/09/01a12009-4207-7b53-b4c3-391375738980/icons_integration/constraints_foyer_compare.png)
- [Hub Réserve Solo — avant/après](C:/Users/simos/.codex/visualizations/2026/10/09/01a12009-4207-7b53-b4c3-391375738980/icons_integration/pantry_solo_compare.png)
- [Hub Réserve Famille — avant/après](C:/Users/simos/.codex/visualizations/2026/10/09/01a12009-4207-7b53-b4c3-391375738980/icons_integration/pantry_foyer_compare.png)

[Planche des 23 copies à 28, 36, 40, 48 et 56 px](C:/Users/simos/.codex/visualizations/2026/10/09/01a12009-4207-7b53-b4c3-391375738980/icons_integration/sizes_23.png). Les petits dessins sont montrés à ces dimensions réelles dans la planche ; le zoom du lecteur peut les agrandir.

Les dix comparatifs ont été examinés : contenu, progression, positions des cartes, boutons et titres stables ; seules les zones d’icônes autorisées diffèrent. Photos, allergènes et autres actions Réserve identiques. La planche sur fond menthe expose les fonds opaques au lieu de les masquer sur fond blanc.

## Tests et résultats

- Avant intégration : **90 rendus/captures responsive réussis**, aucun échec ; aucune assertion de nouvelles références n’était alors attendue.
- Après : **113 tests ciblés réussis**, aucun échec. **90 widgets** : dix variantes × FR/EN/DE à 320/390 + ES/IT/AR à 390 ; noms exacts des assets, dimensions mesurées et BoxFit.contain contrôlés. **23 unités** : chaque copie existe, signature PNG, dimensions 256, mode RGB et référence effective dans les écrans.
- Les nouvelles assertions empêchent notamment l’utilisation de Ma réserve dans Gestion, des PNG de restriction dans les allergènes, ou d’autres icônes familiales nouvelles hors Zéro gaspillage.

- Suite complète `flutter test --no-pub --reporter json` : **934 réussites / 17 échecs / 0 ignoré**, code 1 dû aux mêmes échecs préexistants : 13 Golden et 4 couvertures ES/IT à 320 px. Référence avant intervention : 821 réussites / 17 échecs ; les 113 nouveaux tests passent, aucun nouvel échec fonctionnel observé.
- Phases 1–5 et parcours Solo/Famille : réussis dans cette suite, dont 65 contrôles alimentaires phase 4 bis, 131 diagnostics régionaux + 38 budgets, 149 Réserve, 42 compteurs (38 réussites + 4 ES/IT historiques), éligibilité Solo, profils, numérique, responsive et localisation.
- `flutter analyze --no-pub` final : **aucun problème**, code 0. Un import inutile du nouveau test a été retiré sans changer ses assertions. `git diff --check` : **aucune erreur**, code 0.
- Aucun Golden ignoré, supprimé, régénéré ou tolérance augmentée.

Références visuelles non modifiées. Les remplacements ajoutent des différences **attendues dans les quatre Golden des couvertures Solo/Famille FR/AR**, déjà en échec avant cette intervention. Ce n’est pas une autorisation d’actualiser leurs références. Objectif, Activité, Gestion, Contraintes et hub Réserve n’ont pas de Golden correspondant dans les deux fichiers de comparaison historiques ; ils sont vérifiés par les nouveaux rendus et comparatifs. Les trois Golden Réserve principale ne reçoivent aucune nouvelle icône : seule la Réserve du détour est ciblée.

## Préservation, fichiers et limites

Fichiers de cette intervention : sept écrans ci-dessus, lib/widgets/selectable_card.dart, pubspec.yaml, 23 nouveaux assets, test/icon_preview_test.dart, PLAN.md, DECISIONS.md et ce rapport. Les journaux .log sont locaux ignorés ; captures/planche/inventaire technique sont hors dépôt dans le dossier des visualisations.

Contrôle SHA-256 avant/après : **23 originaux identiques**, **aucun ancien asset modifié**, aucun test préexistant changé. Seuls les sept écrans ciblés, ChoiceCard et pubspec.yaml diffèrent parmi les sources préexistantes inventoriées. Aucun changement d’OnboardingData, OnboardingFlow, formats régionaux, Budget, grille, récapitulatif, profils, traductions ou logique Réserve. Les autres modifications présentes dans git status appartiennent aux phases précédentes et sont conservées.

Limites : fonds clairs visibles, finesse réduite des illustrations aux petites tailles, rendu humain à valider et quatre débordements ES/IT 320 px historiques laissés en place. Aucun détourage ni changement de textes destiné à masquer ces problèmes. Les sources 3D originales restent disponibles pour une éventuelle préparation alpha ultérieure autorisée.

**Arrêt après intégration des 23 icônes. Aucun commit/push, Supabase, build APK, installation Android, modification des règles Solo 18+/Famille/nutrition/devises/contraintes/navigation. Phases 6B et 7 non commencées. Validation de Simo attendue avant installation ou nouvelle modification.**
