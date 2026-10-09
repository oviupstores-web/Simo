# Phase 4 — Diagnostic des formats régionaux B08/B09/B10

Date : 9 octobre 2026. Dossier : C:\Users\simos\Menoo-Flutter-V2. Branche master ; dernier commit 4f569a0. Modifications locales de phase 3 conservées. Diagnostic seulement, aucune correction applicative.

## Résultats confirmés et décisions distinctes

| ID | Fichier / ligne | Preuve | Cause | Plan minimal après autorisation |
|---|---|---|---|---|
| B08.1 | lib/screens/onboarding/budget_screen.dart:115, :169 ; lib/l10n/app_*.arb budgetCustomSuffix/budgetAdvisedText | US/GB/CH : montant principal, suffixe et conseil en euros alors que curseur, bornes et coût par repas utilisent USD/GBP/CHF | Symbole fixe et monnaie incluse dans des traductions ; appels Formats.price ailleurs | Afficher une seule devise explicite du budget sur toutes les occurrences ; traductions avec montants formatés en paramètres. Ne pas remplacer EUR par USD sur un montant de source incertaine |
| B08.2 | lib/main.dart:63 ; lib/l10n/app_languages.dart:11–18 | MenooApp réel : appareil US/GB/CH, sélection Français → countryCode null au lieu du pays initial | Flutter transmet la locale préférée à localeResolutionCallback ; le paramètre appelé device n’est plus nécessairement la locale du téléphone | Conserver le pays réel indépendamment de la langue ; pas de nouvel écran de réglages, pas de conversion de données |
| B08.3 | lib/onboarding/onboarding_data.dart:265–266 ; lib/l10n/formats.dart:29–36 | budgetEuros = 87 reste 87 tandis que Formats peut le présenter en USD, GBP ou CHF | Montant en mémoire sans code devise ; nom/commentaires EUR, code d’affichage régional différent | Décider devise du nouveau budget et gestion des anciens montants ambigus avant ajout d’un code devise local. Aucune migration Supabase proposée dans cette phase |
| B08.4 | lib/screens/onboarding/budget_screen.dart:170 et :37–49 | Coller 65,50 FR/DE ou 65.50 US enregistre 6550 | digitsOnly retire le séparateur avant int.tryParse | Ne pas concaténer les chiffres d’un montant. Proposition : garder les budgets entiers actuels et refuser clairement les décimales ; accepter des centimes demanderait une autre décision produit |
| B09 | lib/l10n/formats.dart:89–94 | 182 cm → 5 ft 12 in ; 181,61 cm idem ; 30,47 cm → 0 ft 12 in. Balayage 1101 tailles de 120 à 230 cm reproduit plusieurs reports manquants | Pieds calculés avant l’arrondi des pouces, sans report lorsque le reste arrondit à 12 | Arrondir le total de pouces une seule fois, puis pieds = total ~/ 12, pouces = total % 12. Préserver cm dans le modèle et les protections R01 |
| B10 | lib/screens/onboarding/weekly_grid_screen.dart:34 | 8 repas / 7 : badge 1,1 en anglais, alors que Formats donne 1.1 ; même défaut pour de-CH. FR/de-DE restent cohérents | Virgule imposée par replaceAll('.', ',') | Formats.of(context).number(n / 7, decimals: 1), sans changer n, les créneaux ou les règles Solo/Famille |

Ces anomalies ne sont pas des erreurs ADB/Flutter de l’environnement. Les tests échouent sur leurs assertions de comportement, pas sur leur compilation ou leur chargement.

## Régions et formats réellement observés

| Locale testée | Devise configurée | Affichage de 6550 centimes | Moyenne 8/7 selon Formats | Unités par défaut |
|---|---|---|---|---|
| fr-FR | EUR | 65,50 € | 1,1 | métriques |
| de-DE | EUR | 65,50 € | 1,1 | métriques |
| en-GB | GBP | £65.50 | 1.1 | métriques |
| en-US | USD | $65.50 | 1.1 | impériales |
| en-CA | EUR (repli actuel) | €65.50 | 1.1 | métriques |
| en-AU | EUR (repli actuel) | €65.50 | 1.1 | métriques |
| de-CH | CHF | CHF 65.50 | 1.1 | métriques |

Les espaces monétaires peuvent être insécables ; le tableau les rend lisibles sans les présenter comme des espaces ASCII obligatoires.

CA et AU conservent correctement leur code pays quand Formats reçoit une locale complète, mais ne figurent pas dans la table de devises : repli EUR. CAD/AUD sont des fonctionnalités manquantes à décider, déjà signalées dans PLAN.md/DECISIONS.md, pas une preuve de conversion ratée. Les marchés sont documentés ; tous les prix et devises régionaux ne sont pas encore implémentés.

Il n’existe actuellement pas de choix de pays dans l’interface : les réglages sont prévus ultérieurement. Les tests injectent les locales régionales et vérifient aussi le vrai MenooApp avec un pays d’appareil simulé. Le helper AppLanguages.resolve conserve le pays lorsqu’on lui passe le vrai appareil ; son utilisation dans le callback réel le perd après sélection d’une langue générique.

Les traductions sont FR/EN/DE au lancement ; ES/IT/AR restent conservées. Les tests grille croisent ces trois langues avec les sept pays, à 320 et 390 px. Les formats numériques suivent les données intl de la locale complète, avec repli de langue si une combinaison n’a pas de variante régionale. En particulier fr-CH conserve une virgule dans le formateur actuel ; de-CH utilise un point. Aucune règle simpliste « toute la Suisse = même séparateur » n’est proposée.

## Devises : ce qui est un bug et ce qui doit être décidé

Bugs techniques : plusieurs devises dans le même écran, perte de pays après changement de langue, séparateur de saisie détruit. Ils peuvent être corrigés après accord sur le format attendu.

Décisions produit nécessaires :

1. Les nouveaux budgets sont-ils déclarés nativement dans la devise du pays (EUR FR/DE, GBP GB, USD US, CAD CA, AUD AU, CHF CH) ? Ajouter CAD/AUD ne doit pas devenir une conversion fictive des anciens montants.
2. Comment traiter les valeurs déjà saisies sans devise ? Le nom budgetEuros et les anciens textes suggèrent EUR, mais un utilisateur pouvait voir des prix annexes en USD/GBP/CHF. Leur origine n’est donc pas déductible avec certitude. Ne pas attribuer automatiquement une devise aux valeurs ambiguës ; pas de réinterprétation silencieuse.
3. Les valeurs initiales, bornes 20–350, pas 5 et contributions 30/20/25 du foyer sont aujourd’hui des nombres associés historiquement à EUR. Les afficher identiquement dans une autre devise serait une décision de valeurs nominales locales, pas un taux de change. Ne pas modifier les règles Foyer ni recalibrer ces nombres dans ce diagnostic.
4. Le budget reste-t-il entier ? Proposition minimale : conserver le modèle entier et refuser les décimales collées avec un message traduit. La gestion de centimes pour le budget nécessite une décision distincte, sans arrondi automatique ni suppression de séparateur.

Solution transitoire possible à valider : budgets explicitement en EUR partout, sans conversion, jusqu’à définition des devises locales. Elle réduit l’ambiguïté mais diffère de la cible produit « devise selon pays » ; elle ne sera pas appliquée sans accord.

Aucun taux de change n’est inventé, recherché ou appliqué. Formats.price est une opération d’affichage : 6550 est affiché comme 65,50 unités de la devise passée, pas converti depuis EUR. Les prix de démonstration et d’abonnement doivent garder leur devise source tant qu’une tarification régionale n’est pas validée ; ne pas les relabeller arbitrairement.

Migrations SQL locales examinées en lecture seule : weekly_budget_cents, budget_cents et price_cents_per_unit ne suffisent pas à porter une identité monétaire régionale. Aucun accès distant ou changement Supabase. Le futur branchement des montants à leur devise doit être traité avant utilisation commerciale ; aucune migration demandée ici.

## Inventaire des symboles monétaires codés en dur

Toutes les occurrences visibles trouvées dans les sources Dart non générées et les ARB sont ci-dessous. Les commentaires, les constantes ISO légitimes de Formats et les sélecteurs de records Dart .$1/.$2 ne sont pas des symboles monétaires affichés.

| Source | Chaîne / occurrence |
|---|---|
| lib/screens/home/home_screen.dart:305 | `Text.rich(_valueWithUnit('48,20 €', '/ 65 €')),` |
| lib/screens/home/home_screen.dart:308 | `L.of(context).homeRemaining('16,80 €'),` |
| lib/screens/home/home_screen.dart:309 | `'16,80 €',` |
| lib/screens/onboarding/budget_screen.dart:115 | `' € ',` |
| lib/screens/pantry/pantry_home_screen.dart:183 | `'≈ 12,50 €',` |
| lib/screens/shopping/shopping_list_screen.dart:23 | `('f_banane.jpg', l.shopDemoBananas, l.unitKilograms('1'), '1,99 €'),` |
| lib/screens/shopping/shopping_list_screen.dart:24 | `('f_epinards.jpg', l.shopDemoSpinach, l.unitGrams('200'), '1,89 €'),` |
| lib/screens/shopping/shopping_list_screen.dart:25 | `('i_tomates.jpg', l.shopDemoCherryTomatoes, l.unitGrams('250'), '2,29 €'),` |
| lib/screens/shopping/shopping_list_screen.dart:26 | `('i_citron.jpg', l.shopDemoLemons, l.qty2Pieces, '0,98 €'),` |
| lib/screens/shopping/shopping_list_screen.dart:29 | `('i_saumon.jpg', l.shopDemoSalmon, l.qty4Pieces, '16,40 €'),` |
| lib/screens/shopping/shopping_list_screen.dart:30 | `('p_poulet.jpg', l.shopDemoChicken, l.unitGrams('600'), '8,90 €'),` |
| lib/screens/shopping/shopping_list_screen.dart:31 | `('p_yaourt.jpg', l.shopDemoGreekYogurt, l.unitKilograms('1'), '3,20 €'),` |
| lib/screens/shopping/shopping_list_screen.dart:34 | `('f_amandes.jpg', l.shopDemoAlmonds, l.unitGrams('250'), '3,49 €'),` |
| lib/screens/shopping/shopping_list_screen.dart:35 | `('i_quinoa.jpg', l.shopDemoOrganicQuinoa, l.unitGrams('500'), '3,40 €'),` |
| lib/screens/shopping/shopping_list_screen.dart:103 | `TextSpan(text: '52,80 €', style: AppText.bigNumber),` |
| lib/screens/shopping/shopping_list_screen.dart:105 | `text: ' / 65 €',` |
| lib/l10n/app_ar.arb — budgetCustomSuffix | € / أسبوع |
| lib/l10n/app_ar.arb — budgetAdvisedText | محسوبة لـ {people} أشخاص (30 € للبالغ، 20 € للطفل، 25 € للرضيع). عدّلها كما تشاء. |
| lib/l10n/app_ar.arb — shoppingThenPrice | ثم 9.99 € / شهريًا · بلا التزام |
| lib/l10n/app_de.arb — budgetCustomSuffix | € / Woche |
| lib/l10n/app_de.arb — budgetAdvisedText | Berechnet für {people} Personen (30 € pro Erwachsenem, 20 € pro Kind, 25 € pro Baby). Frei anpassbar. |
| lib/l10n/app_de.arb — shoppingThenPrice | Danach 9,99 €/Monat · jederzeit kündbar |
| lib/l10n/app_en.arb — budgetCustomSuffix | € / week |
| lib/l10n/app_en.arb — budgetAdvisedText | Worked out for {people} people (€30 per adult, €20 per child, €25 per baby). Adjust it freely. |
| lib/l10n/app_en.arb — shoppingThenPrice | Then €9.99/month · cancel any time |
| lib/l10n/app_es.arb — budgetCustomSuffix | € / semana |
| lib/l10n/app_es.arb — budgetAdvisedText | Calculado para {people} personas (30 € por adulto, 20 € por niño, 25 € por bebé). Ajústalo libremente. |
| lib/l10n/app_es.arb — shoppingThenPrice | Luego 9,99 €/mes · sin compromiso |
| lib/l10n/app_fr.arb — budgetCustomSuffix | € / semaine |
| lib/l10n/app_fr.arb — budgetAdvisedText | Calculé pour {people} personnes (30 € par adulte, 20 € par enfant, 25 € par bébé). Ajustez-le librement. |
| lib/l10n/app_fr.arb — shoppingThenPrice | Puis 9,99 €/mois · sans engagement |
| lib/l10n/app_it.arb — budgetCustomSuffix | € / settimana |
| lib/l10n/app_it.arb — budgetAdvisedText | Calcolato per {people} persone (30 € per adulto, 20 € per bambino, 25 € per neonato). Modificalo liberamente. |
| lib/l10n/app_it.arb — shoppingThenPrice | Poi 9,99 €/mese · senza vincoli |

Budget constitue le périmètre principal B08. Accueil, Courses, Réserve principale et abonnement contiennent également des montants de démonstration ou de prix produits : ils doivent être documentés comme sources EUR ou recevoir une tarification réelle, pas un remplacement global de caractères. Leur présence n’est pas une autorisation de refaire ces écrans ou leur design.

## B09 : limites et référence métrique

- Cas utilisateur ordinaire dans les bornes Solo : 182 cm, affichage actuel 5 ft 12 in ; arrondi normalisé attendu 6 ft 0 in. La référence métrique reste 182 cm, pas 182,88 cm après aller-retour.
- Voisinage du report : 181,60 cm reste 5 ft 11 in ; 181,61 et 182 donnent un report manquant ; 182,88 affiche déjà 6 ft 0 in.
- Autres contrôles : 0,1 ; 2,54 ; 30,47 ; 30,48 ; 30,49 ; 120 ; 152,4 ; 180 ; 230 cm ; balayage 120–230 par 0,1 cm ; affichage métrique FR/EN/DE inchangé ; NaN, infinis, zéro, négatifs et dépassement technique refusés par les protections R01 existantes.
- Les tailles sous 120 cm sont des tests directs du formateur, pas des profils Solo admis. Aucun changement de bornes, formules nutritionnelles ou unités de saisie des profils proposé.
- Après autorisation : ajouter le report de pouces et retirer le skip du test B09 historique dans numeric_model_diagnostic_test.dart ; ne pas retoucher les autres tests pour masquer une régression.

## Formatage réutilisable et plan minimal

1. Conserver le pays réel indépendamment de la traduction dans main.dart ; utiliser AppLanguages.resolve avec la vraie région de l’appareil ou la région déjà retenue. Aucun nouvel écran de pays.
2. B09 : normalisation dans Formats.height uniquement ; unité affichée traduite par unitFeetInches ; données métriques intouchées.
3. B10 : remplacer le format manuel de moyenne par Formats.number dans la grille ; garder un chiffre décimal et suppression des zéros inutiles conformément aux formats existants. Les compteurs et créneaux ne changent pas.
4. B08 : après décisions monétaires, lier montant et code devise explicite ; formatter chaque montant avec Formats.price/priceRounded dans cette devise. Utiliser des paramètres de traduction pour suffixe et conseils ; préserver le découpage visuel, styles et espace disponibles.
5. Saisie Budget : après validation de la précision entière ou décimale, valider le texte sans concaténer les chiffres. Ne pas appeler un formateur de prix comme convertisseur ni introduire un taux approximatif.
6. Ne pas changer les prix démo/abonnement en prix régionaux fictifs. Signaler les occurrences hors Budget séparément ; une correction plus large requiert un périmètre validé.
7. Relancer les tests régionaux, les régressions phase 3, formats, Solo/Famille et 320/390 ; analyse et diff check. Préserver tous les chiffres internes et les changements antérieurs. Phases 5 à 7 en attente.

Fichiers susceptibles d’être concernés après accord : lib/main.dart, lib/l10n/formats.dart, lib/screens/onboarding/weekly_grid_screen.dart, budget_screen.dart, les ARB pour les paramètres traduits, éventuellement la représentation locale du budget dans onboarding_data.dart selon la décision de devise. Aucun fichier applicatif modifié pendant le diagnostic.

## Tests et état de conservation

Nouveau fichier : test/phase4_regional_diagnostic_test.dart, **131 tests : 87 réussites, 44 échecs attendus**.

Décomposition des échecs : 18 pour les trois occurrences Budget US/GB/CH × 320/390 ; 3 pertes de pays dans MenooApp ; 3 collages de montant ; 4 conversions/normalisations B09 (dont un balayage de 1101 tailles) ; 16 moyennes de grille (14 EN + 2 de-CH). Ils restent en échec avant correction autorisée, sans skip ajouté.

Commande : `flutter test --no-pub test/phase4_regional_diagnostic_test.dart --reporter expanded`, code 1 attendu ; preuves dans reports/phase4_diagnostic.log.

Préservation : `flutter test --no-pub test/phase3_pantry_diagnostic_test.dart test/phase3_pantry_regression_test.dart test/detect_test.dart test/formats_test.dart test/language_picker_test.dart test/solo_flow_test.dart --reporter expanded` : **165 réussites, 0 échec**, code 0 ; reports/phase4_preservation.log. Ces contrôles incluent les 149 tests de phase 3, les conversions existantes et les parcours Solo/Famille.

`flutter analyze --no-pub` : aucun problème, code 0 ; reports/phase4_analyze.log. `git diff --check` : aucune erreur. Empreintes des 118 fichiers applicatifs, traductions, tests existants et images relevées au début : **118 comparaisons SHA-256, aucune différence** (application, traductions, tests existants et assets relevés).

La suite complète et les références visuelles historiques ne sont pas relancées pour ce diagnostic sans changement applicatif. Le B09 anciennement différé est reproduit dans le nouveau fichier ; son skip existant n’est pas retiré avant autorisation de correction.

Seuls le nouveau test, ce rapport et PLAN.md sont créés/modifiés pour cette phase. Les journaux restent locaux et ignorés. Aucun commit/push, installation Android, Supabase, changement de design/illustration ou règle nutritionnelle. Phases 5 à 7 non commencées. Attendre l’autorisation de Simo et les décisions monétaires avant correction.
