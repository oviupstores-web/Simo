# Phase 6A — Diagnostic visuel et documentaire

Date : 2026-10-09. Projet : C:\Users\simos\Menoo-Flutter-V2. Branche **master**, commit **4f569a0**. Mission en lecture seule : seul ce rapport est créé ; aucune correction de phase 6B ou 7.

## Méthode, reproduction et limites

Lecture des tests, sources réelles, cinq documents produit, décisions datées, maîtres HTML et références visuelles. Comparaison visuelle des **13 paires référence/rendu**, et mesure exacte des pixels RGBA différents avec Pillow/NumPy fournis par le runtime Codex (aucun téléchargement). Images comparatives temporaires hors Git : `C:/Users/simos/.codex/visualizations/2026/10/09/01a12009-4207-7b53-b4c3-391375738980/phase6a/`.

Commande exécutée, sans `--update-goldens` :

`flutter test --no-pub test/golden_ar_test.dart test/golden_pantry_test.dart test/phase5_onboarding_count_test.dart --reporter json`

**57 tests : 40 réussites / 17 échecs / 0 ignoré**, code 1. Deux Golden connexion FR/AR passent, 13 autres échouent ; les 42 contrôles phase 5 donnent 38 réussites et 4 débordements ES/IT. Journal temporaire Windows : `C:/Users/simos/AppData/Local/Temp/menoo_phase6a/tests.jsonl`. Aucun APK compilé ni installation.

Les 13 comparaisons portent sur **1080 × 2400 pixels physiques**, DPR **2,75**, soit environ **392,73 × 872,73 pixels logiques**. Le test capture le viewport de MaterialApp, pas toute la page déroulante. Les pourcentages ci-dessous sont des pixels différents, pas une note de qualité ni une gravité fonctionnelle. Les rectangles englobants sont en pixels physiques, extrémités droites/basses exclusives.

Les images maîtres PNG ont parfois un cadre iPhone et un contenu différent des maîtres HTML. Elles servent à la revue qualitative, sans prétendre à une comparaison pixel à pixel avec le viewport Flutter. DESIGN_V2 et les décisions postérieures doivent être lus ensemble : les ajustements explicitement validés ne doivent pas être annulés au nom d’un ancien Golden.

## A. Les 13 Golden

Tous les noms de référence ci-dessous sont sous `test/goldens/`. Le rendu correspondant est sous `test/failures/`, suffixe `_testImage.png` ; `_masterImage`, `_isolatedDiff` et `_maskedDiff` existent aussi. Les copies de référence des sorties ont été rapprochées des références réelles utilisées.

| Test / écran / langue | Référence exacte | Mesure et zones différentes | Cause et confiance | Décision minimale recommandée |
|---|---|---|---|---|
| golden_ar_test.dart — Landing FR | fr_1_landing.png | **2 581 316 px, 99,588 %** ; bbox (0,0)-(1080,2400). Ancienne photo pleine largeur, introduction et cartes remplacées par composition latérale et nouveaux aperçus | Ancienne structure différente de la maquette landing.png et du checkpoint actuel ; **élevée** pour l’obsolescence structurelle. Le lien de connexion manque aussi dans l’app | Revoir le lien manquant et les éléments non couverts par les validations, puis valider le nouveau rendu avant actualisation. Ne pas revenir à l’ancienne structure uniquement pour passer le Golden |
| golden_ar_test.dart — Landing AR | ar_1_landing.png | **2 591 207 px, 99,969 %** ; bbox plein viewport. Même restructuration ; illustrations actuelles absentes de cette capture | Référence ancienne **et** préparation d’images inadéquate dans le test ; **élevée** pour la liste d’assets obsolète, **moyenne/élevée** pour l’explication des images manquantes | Stabiliser d’abord le chargement du test ; jamais enregistrer une référence avec illustrations absentes. Revue RTL puis référence humaine |
| golden_ar_test.dart — Choix du mode FR | fr_2_path_choice.png | **1 439 391 px, 55,532 %** ; bbox (38,349)-(1042,2400). Cartes rose/crème, texte bleu, marges et lien rééquilibrés | PathChoiceTokens et décision **DECISIONS.md:67** autorisent précisément palette pastel, bleu sombre et espacements ; **élevée** | Référence dépassée pour ces changements validés ; conserver l’app, confirmer les paires puis actualiser uniquement cette référence |
| golden_ar_test.dart — Choix du mode AR | ar_2_path_choice.png | **1 354 931 px, 52,274 %** ; bbox (38,342)-(1042,2400). Mêmes couleurs, décalages verticaux et retours à la ligne du lien RTL | Même cause validée, pas de disparition de contenu démontrée ; **élevée** pour palette, **moyenne** pour le lien au bas du viewport | Conserver palette approuvée ; contrôler le lien complet après défilement en RTL avant nouvelle référence |
| golden_ar_test.dart — Couverture Solo FR | fr_3_cover_solo.png | **310 141 px, 11,965 %** ; bbox (38,935)-(1042,2400). Badge moins arrondi, nouvelles icônes, bleu sombre et cartes réespacées ; photo/en-tête stables | DECISIONS.md:61,63,65 : cartes blanches finales, marges 14, écarts 10, bleu sombre et nouvelles icônes ; **élevée** | Garder les modifications approuvées ; nouvelle référence après revue. Ne pas restaurer les anciens pictogrammes |
| golden_ar_test.dart — Couverture Solo AR | ar_3_cover_solo.png | **404 113 px, 15,591 %** ; bbox (38,932)-(1042,2400). Changements identiques ; cartes plus hautes, CTA descend | Icônes plus grandes et typographie/espacement validés ; effets de longueur RTL ; **élevée** pour cause, **moyenne** pour validation finale RTL | Vérifier le CTA et la mention complète en défilant, conserver les décisions validées puis actualiser |
| golden_ar_test.dart — Couverture Famille FR | fr_4_cover_household.png | **94 831 px, 3,659 %** ; bbox (93,1446)-(928,2134). Taille des pastilles/icônes dans les trois cartes ; haut/photo/titres stables | TintBadge utilise iconTileMd=56 ; ancien rendu plus petit. **Élevée** pour cause, **moyenne** pour conformité finale : aucune décision ciblée aussi explicite que pour Solo trouvée | Faire confirmer les tailles Famille ; si approuvées, référence à actualiser, sinon correction locale de taille avant référence. Le compteur validé 9 ne doit jamais revenir à 10 |
| golden_ar_test.dart — Couverture Famille AR | ar_4_cover_household.png | **512 442 px, 19,770 %** ; bbox (54,1357)-(1026,2377). Cartes plus hautes, CTA descend ; **10 → 9** visible dans la mention basse | Tailles des pastilles + texte RTL ; B11 rend la mention 10 obsolète avec certitude. **Élevée** pour B11, **moyenne** pour tailles | Conserver 9 ; décider les tailles avec FR, contrôler défilement/CTA puis référence validée |
| golden_ar_test.dart — Inscription FR | fr_6_signup.png | **7 521 px, 0,290 %** ; bbox (294,1875)-(790,1915). Uniquement la ligne « Déjà inscrit ? Se connecter » ; champs, boutons et décor identiques | LayoutBuilder passe en Wrap quand largeur intérieure <360, avec spacing=12 ; ancien espacement plus serré. **Élevée** | Confirmer cet espacement responsive, puis actualiser la référence si retenu. Aucune justification pour changer polices ou tout l’écran |
| golden_ar_test.dart — Inscription AR | ar_6_signup.png | **8 130 px, 0,314 %** ; bbox (273,1835)-(804,1878). Même ligne, ordre RTL conservé | Même Wrap et espacement ; **élevée** | Même décision FR/AR ; garder les mots complets et le lien accessible, puis référence après validation |
| golden_pantry_test.dart — Réserve FR | fr_pantry_home.png | **657 365 px, 25,361 %** ; bbox (54,242)-(1080,2363). Icônes/en-têtes plus grands, sections décalées vers le bas, Code-barres sur deux lignes, navigation plus grande | Tailles partagées iconTile=48, iconTileMd=56 ; _QuickAction Text 13/Flexible ; répercussion verticale, pas de changement des neuf produits montré. **Élevée** pour cause ; conformité **non tranchée** | Revue contre master_operationnel.html et décisions de tailles avant de corriger localement ou actualiser. Ne pas déclarer automatiquement le Golden obsolète |
| golden_pantry_test.dart — Réserve DE | de_pantry_home.png | **647 475 px, 24,980 %** ; bbox (54,242)-(1080,2363). Mêmes décalages ; contenu de bas de carte repoussé sous la navigation fixe | Même cause partagée ; **élevée** ; pas de nouvelle perte de données établie | Même décision de tailles ; vérifier les lignes par défilement et les longueurs allemandes avant référence |
| golden_pantry_test.dart — Réserve AR | ar_pantry_home.png | **663 492 px, 25,598 %** ; bbox (0,242)-(1027,2376). Action Photo IA auparavant comprimée, désormais sur deux lignes ; sections plus basses, RTL conservé | Texte Flexible 13 px et tailles partagées ; **élevée** pour cause ; choix final des dimensions **à valider** | Conserver texte complet et RTL ; ne pas revenir à la réduction de texte uniquement pour retrouver les pixels anciens. Valider tailles/hauteurs puis référence |

### Preuves visuelles et décisions

Treize comparatifs sont disponibles hors Git : [dossier de diagnostic](C:/Users/simos/.codex/visualizations/2026/10/09/01a12009-4207-7b53-b4c3-391375738980/phase6a). Dans chaque fichier `*_pair.png`, référence à gauche, rendu actuel à droite. Ils sont réduits à 50 % pour lecture ; les mesures utilisent les images originales sans redimensionnement.

- **Landing** : design/maquettes/landing.png ressemble structurellement au rendu actuel (hero latéral, cartes illustrées), contrairement à l’ancien Golden. Décisions de Landing interactive et images : DECISIONS.md:196,201–204,209–214. Il reste des différences avec la maquette : copie/titre raccourci, badge Instant Recipe AI et ajout CaliScan AI, en-tête. Le checkpoint eb92dd2 (2026-10-07) les présente comme validés, mais le rapport ne prend pas un message de commit comme une validation humaine de chaque pixel. À vérifier avant référence.
- **Défaut applicatif confirmé à examiner en 6B** : le lien « J’ai déjà un compte » est visible dans l’ancienne Landing et demandé par SPEC.md:35,331 et DECISIONS.md:181. LandingScreen affiche MenooBrand, sans lien ni navigation LoginScreen. Sa restauration minimale vers l’écran existant doit être validée ; le conserver absent en actualisant le Golden masquerait une divergence produit.
- **Test Landing non représentatif de son chargement réel** : golden_ar_test.dart:55–68 prépare bowl_landing/leaf_a, mais pas les providers actuels assets/images/landing/hero, branch, sprig, etc., ni meal_scan-v3-transparent. L’app réelle passe par MenooStartup(prepare:LandingScreen.prepareImages) dans main.dart:70 ; le Golden monte directement LandingScreen. La capture AR s’exécute avant FR, ses images sont absentes ; FR profite vraisemblablement du cache. Cause probable de harnais, pas preuve d’une régression sur téléphone. Avant toute actualisation, prévoir les providers réellement utilisés et une attente de décodage déterministe.
- **Choix du mode** : master_path_choice.html:4–9 et ref/03_path_choice.png montrent l’ancien style ; DECISIONS.md:67 valide ensuite palette pastel/bleu sombre. La décision postérieure justifie les couleurs actuelles ; DESIGN_V2 doit documenter cette exception locale.
- **Couverture Solo** : DECISIONS.md:61 préfère les cartes blanches, :63 fixe marges/espacements/bleu et :65 valide les nouvelles icônes. Le rendu actuel respecte les cartes blanches finales ; ne pas interpréter la mention plus ancienne « cartes pastel » comme ordre de repeindre les cartes.
- **Famille/Réserve** : les tailles des jetons actuels (app_tokens.dart:144–147 : 44/48/56/56) diffèrent de tailles historiques et de DECISIONS.md:206 (40 pour iconTile). master_operationnel.html utilise notamment des pastilles w-11/h-11 et des icônes SVG plus petites ; le PNG ref/08_type_operationnel.png a aussi un contenu antérieur, donc son organisation ne doit pas écraser la Réserve actuelle. Vérifier les exceptions approuvées avant une décision globale ; les tailles partagées toucheraient les phases déjà validées.
- **Inscription** : signup_screen.dart:112–133, branche Wrap spacing AppSpace.x3 à largeur intérieure <360. À ce viewport, la largeur intérieure vaut environ 352,73 px, ce qui active cette branche. Le maître login est un gabarit, pas une référence exacte pour cette ligne d’inscription. Aucun changement généralisé de police ou de rendu moteur suspecté : les deux Golden connexion passent et l’inscription est identique sur plus de 99,6 % des pixels.

## B. Quatre débordements ES/IT à 320 px

Tous reproduits dans phase5_onboarding_count_test.dart. Viewport physique/logique 320 × 2400, DPR=1 ; mesures en pixels logiques.

Widget responsable : Row de la mention sous le bouton de départ, cover_solo_screen.dart:111–123 et cover_household_screen.dart:99–108. Enfants : icône 15 px, espace 6 px, Text non flexible. La Row mesure le Text sans lui imposer la largeur restante ; mainAxisAlignment.center ne réduit ni ne fait revenir le texte à la ligne.

| Cas | Largeur Row | Largeur disponible au texte | Dépassement reproduit | Correction minimale proposée |
|---|---:|---:|---:|---|
| ES Solo | 292 px (marges 14 × 2) | 271 px | **21 px** | Flexible autour du Text, softWrap, alignement centré, hauteur naturelle |
| IT Solo | 292 px | 271 px | **4,1 px** | Idem |
| ES Famille | 280 px (marges 20 × 2) | 259 px | **31 px** | Idem |
| IT Famille | 280 px | 259 px | **14 px** | Idem |

Texte : commonQuickSteps(11 ou 9) + séparateur + commonEditableAnytime. AppText.meta conserve Plus Jakarta Sans **12 px**, ligne 16 px. Les textes mesurés nécessitent approximativement 292 / 275,1 / 290 / 273 px ; mesures déduites de l’espace restant et de l’overflow arrondi signalé par Flutter.

Proposition : **Flexible en ajustement lâche** afin de garder la largeur naturelle et le centrage du groupe quand le texte tient, puis deux lignes ou plus sans coupure quand nécessaire. Ne pas ajouter ellipsis/maxLines, réduire la police, supprimer le séparateur ou raccourcir les traductions. La Column déroule déjà la page et n’impose pas une hauteur fixe à cette mention. Tester les six langues, 320/390 px, puis les grandes tailles de texte. Aucune application de cette correction dans cette phase.

## C. Divergences documentaires

Les anciennes entrées datées de PLAN/DECISIONS peuvent être conservées comme historique ; elles ne doivent pas être supprimées ni réappliquées. Le besoin est de distinguer explicitement règle actuelle et règle remplacée. Les comptes de tests historiques ne sont pas des erreurs lorsqu’ils sont datés.

| Document / ligne | Passage ancien ou incomplet | Règle actuellement validée / constatée | Correction documentaire proposée |
|---|---|---|---|
| PRD.md:42–43 | Solo 12 et étape Enseigne | Solo **11**, aucune Enseigne | Actualiser titre/liste selon OnboardingFlow.solo |
| PRD.md:45–46 | Foyer 10 et Enseigne | Famille **9**, aucune Enseigne | Actualiser titre/liste selon foyer |
| SPEC.md:52,74,103–113 ; PRD.md:48–49 | Écrans de réassurance encore présents | Supprimés par DECISIONS.md:200 ; pas de nouvelles étapes | Retirer du parcours actuel, conserver trace de décision |
| SPEC.md:93,97–100 | Réserve hors compteur et saut Courses/Mixte/Réserves | **Conforme** ; Solo 7A, Famille après 6/9 | Conserver, préciser retours 8/11 et 7/9 ; ne pas la compter comme 12e/10e étape |
| SPEC.md:58 ; PRD.md:42–43 | Éligibilité adulte non précisée | Solo **18–100 ans**, modèle minAge=18 | Ajouter 18+ explicitement, sans modifier les formules |
| DECISIONS.md:12 | Solo 14–100 dans ancienne phase R01 | Remplacé par :222, Solo 18–100 | Marquer l’entrée historique comme remplacée ; lien vers décision actuelle |
| SPEC.md:92 | Pas d’objectif de poids commun, règle plus étroite | Aucun objectif de transformation ni déficit/surplus/macros individualisés Famille | Préciser le périmètre complet validé en phase 2 |
| PRD.md:105 ; SPEC.md:153,184 | Macros par membre, profils dans leur cible, suivi nutritionnel familial | Famille organise repas/budget/contraintes ; aucun moteur de transformation personnalisé | Corriger les promesses de cibles/macros ; distinguer toute future information alimentaire descriptive, à décider séparément |
| PLAN.md:353 ; DECISIONS.md:121 | Objectif/activité adultes Famille, cible prévue au jalon 6 | Champs historiques conservés mais inactifs ; aucune cible par membre | Marquer l’ancien fonctionnement retiré, garder les profils/allergies |
| SPEC.md:68,84 ; PLAN.md:343 | Régimes/allergènes/exclus mélangés, six régimes | Quatre sections : régime unique, trois restrictions, problèmes alimentaires, aliments non aimés | Décrire la phase 4 bis, ses codes conservés, conflits explicites et anciennes exclusions contraignantes |
| SPEC.md:133 | Tous budgets exprimés en € | Nouveau budget entier associé à EUR/GBP/USD/CAD/AUD/CHF selon pays ; anciens montants sans devise non réinterprétés | Distinguer paramètres nominaux provisoires et code natif ; aucune conversion fictive |
| PLAN.md:233,405 ; DECISIONS.md:188,216 | Prix depuis centimes, devises « à implémenter », pays de la langue | Budget entier + code ISO, pays séparé de langue, CAD/AUD déjà pris en charge | Préciser **budget implémenté**, prix démo/abonnement et regional pricing encore distincts ; ne pas convertir ces prix |
| PLAN.md:352 ; DECISIONS.md:121 | 10 € bébé | Coefficient nominal provisoire **25**, décision :127 ; pas une recommandation locale | Marquer l’ancienne valeur remplacée ; mentionner le caractère provisoire et la devise associée |
| SPEC.md:23,279 | Six langues au lancement | FR/EN/DE proposés ; ES/IT/AR conservés | Mettre à jour la stratégie de lancement, sans supprimer les ARB |
| SPEC.md:287 | Noto Sans Arabic | Readex Pro en secours, DECISIONS.md:186 et fonts du test | Corriger le nom ; préserver RTL et ordre de marque |
| design/DESIGN_V2.md:26 | Toutes puces/badges en pilule | Puces 12 px et cartes 14 px, décision :206 ; certains badges explicitement pill restent | Documenter les exceptions, sans changer tous les badges |
| design/DESIGN_V2.md:20,44 | Gris secondaire/gabarits seuls, pas d’exceptions ultérieures | Bleu/pastels locaux approuvés pour choix du mode et Solo | Ajouter renvois vers décisions :61–67 et maquette Landing ; ne pas remplacer le gris global partout |
| design/DESIGN_V2.md:40 | Dashboard Foyer incluant Nutrition/Performance | Pas de cibles/macros par membre | Ajouter renvoi à la restriction Famille ; ne pas inventer nouveau moteur familial |
| PLAN.md:343,354 | Enseigne, ancien contenu/compte des tests du jalon 4/5 | Parcours actuels sans Enseigne ; test/solo_flow_test.dart contient 3 cas | Identifier le résumé historique, fournir renvoi au statut actuel |
| DECISIONS.md:120 | Foyer 10 étapes | Remplacé par décisions du 30/09 et phase 5, total 9 | Renvoi explicite sans effacer la décision datée |
| SPEC.md:3 | Tout v4 proposé, rien codé | Plusieurs règles déjà mises en œuvre ; d’autres restent futures | Distinguer sections réalisées/proposées ; ne pas déclarer toute la roadmap implémentée |
| PLAN.md:16 ; DECISIONS.md:270 | Phase 6 en attente après phase 5 | Phase **6A** autorisée en lecture seule ; 6B/7 attendent accord | Mise à jour de statut uniquement après autorisation de modification documentaire ; aucun changement ici |

**Absence de contradiction à corriger** : DECISIONS.md:224 garde la catégorie familiale « adulte » dès 14 ans, indépendamment de Solo 18+. C’est une règle validée, pas un contournement de l’éligibilité Solo ; aucune reclassification proposée. DESIGN_V2 n’est pas une spécification médicale : les limites d’âge et devises doivent rester dans les documents métier, avec renvois plutôt que duplication de règles.

## D. Plan proposé pour la phase 6B — non exécuté

1. **Valider les arbitrages visuels** : conserver les décisions précises déjà approuvées (palette du choix du mode, cartes blanches/icônes Solo, 9 étapes Famille) ; trancher les tailles Famille/Réserve et l’espacement d’inscription. Lire les paires, pas seulement le taux d’erreur. Confirmer la Landing courante et le lien de connexion.
2. **Fiabiliser le Golden Landing** : golden_ar_test.dart, utiliser les providers actuels et le préchargement réel ; attendre leur décodage avant capture. Tester chaque langue à cache froid et ordre inversé ; ne pas figer un rendu incomplet comme référence.
3. **Corriger les quatre mentions de couverture**, uniquement cover_solo_screen.dart et cover_household_screen.dart : Flexible/retour à la ligne, texte/police/marges inchangés. Faire passer les quatre tests déjà présents sans les ignorer ; couvrir FR/EN/DE à 320/390 et les autres langues, grandes tailles de texte.
4. **Traiter la Landing**, après accord : restaurer le lien de connexion vers LoginScreen existant si la règle SPEC/DECISIONS est maintenue ; aucun nouvel écran, aucune nouvelle illustration. Valider les écarts de copie/branding séparément, pas dans une actualisation automatique de Golden.
5. **Résoudre les écarts Famille/Réserve** suivant l’arbitrage du point 1. Préférer les valeurs locales explicitement validées ; un changement d’AppSizes global affecterait contraintes, profils et autres écrans déjà validés. Aucun changement de données Réserve ou de règles nutritionnelles.
6. **Actualiser la documentation**, seulement les règles courantes et renvois de remplacement ci-dessus ; garder l’historique et ne pas confondre implémentation du budget ISO avec tarification régionale ou future sauvegarde Supabase.
7. **Références Golden**, uniquement après revue humaine du rendu final et après images déterministes : actualiser les seuls écrans approuvés. Garder la comparaison stricte, les 15 tests visuels et tous les tests responsive ; aucun relèvement arbitraire de tolérance.
8. **Validation** : Golden FR/AR et Réserve FR/DE/AR ; 42 tests de compteurs/couvertures ; 65 tests phase 4 bis ; phases 1–5 et parcours complets ; `flutter analyze --no-pub`, suite complète, `git diff --check`. Contrôler Git et les références attendues, sans commit/push ni téléphone sauf autorisation distincte.

Risques : modification de jetons partagés, validation accidentelle d’une capture sans images, perte de spécificité RTL, contenu sous le viewport confondu avec contenu absent, écrasement d’une décision récente par une ancienne maquette, documentation historique interprétée comme règle active. Aucun de ces arbitrages n’est appliqué dans ce diagnostic.

## État Git et préservation

Avant : master/4f569a0, corrections locales des phases 1–5 présentes, six PNG Landing provisoires non suivis. Après : même branche/commit et mêmes modifications locales sur les sources. **Les 882 fichiers inventoriés au départ ont des empreintes SHA-256 identiques**, y compris sources, tests, ARB, documents produit, assets et références Golden. L’audit a créé uniquement ce rapport dans le dépôt. Un dossier non suivi **design/nouvelles_icones/**, contenant 22 chemins PNG supplémentaires au second inventaire, est apparu pendant l’audit : aucune commande de cet audit ne l’a créé ou modifié ; son origine n’est pas attribuée. Il a été conservé intact et n’est pas considéré comme une validation de nouveaux visuels. Le statut Git final comporte donc le rapport et ce dossier supplémentaire, en plus des modifications locales initiales. Les sorties ignorées de test/failures ont seulement été reproduites par les tests ; les paires sont hors Git. Aucun reset, clean, commit/push, Supabase, build APK ou installation Android.

**Arrêt après phase 6A. Aucune correction ni phase 6B/7 commencée. Autorisation explicite de Simo nécessaire pour appliquer le plan.**
