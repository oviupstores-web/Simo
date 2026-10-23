# Brouillons techniques — menoo.guest-import V1

Date : 22 octobre 2026. Base documentaire : commit `e4fd62587e8e770df2adb91343b94d2a65a582c0` et état local préexistant préservé.

Révision locale du 23 octobre 2026, à partir du checkpoint `113d5d96e95fefbc9256459300a0f0ef4be9a9de` : corrections autorisées de M2/M3/M4 et des deux documents techniques seulement. M1, le contrat V1, Flutter, SQLite et les migrations historiques restent inchangés. Aucun SQL ni test exécuté ; aucune sauvegarde Git autorisée pour cette révision.

**STATUT : NON EXÉCUTABLE EN L'ÉTAT — préparation locale uniquement.**

Les quatre fichiers SQL contiennent du SQL candidat, sans pseudo-code de remplacement. Ils commencent par `BEGIN` et une exception volontaire qui invalide toute leur transaction. Aucun script n'a été exécuté, parsé par PostgreSQL ou testé. Ils ne constituent pas des migrations adoptées. Ne pas retirer les gardes, copier un extrait dans une console SQL ou déplacer ces fichiers dans `supabase/migrations` sans nouvelle autorisation. Aucun déploiement n'est autorisé.

Le contrat fonctionnel [V1](../../contracts/menoo_guest_import_v1.md) reste prioritaire. Les noms de transport, signatures et limites de ressources ci-dessous sont des propositions techniques précises, pas de nouvelles décisions produit validées.

## 1. Références et niveau de preuve

Sources recoupées : `CLAUDE.md`, entrées actuelles et historiques pertinentes de `PLAN.md` et `DECISIONS.md`, contrat V1 complet, sept migrations, `supabase/config.toml`, `OnboardingData`, `MemberDraft`, `LocalDraft`, sessions/dépôts Solo/Famille, `PantryProductRecord`, `PantryCodec`, `PantryDraftSection`, enums Réserve, `NumericSafety`, grille/budget/récapitulatif et codes cuisines. Les deux rapports de conception et de correction sont des échanges conversationnels, dont les corrections sont consolidées ici ; aucun fichier de rapport SQL antérieur n'est présenté comme une migration existante.

Repères principaux dans le dépôt :

- `lib/onboarding/onboarding_data.dart` : rôles/facteurs au début du fichier ; `exportFamilyAnswers`, `exportSoloAnswers`, `budgetCurrencies`, `memberInputViolation`, `minHealthyWeight`, `targetError`.
- `lib/local_storage/local_draft.dart` : `DraftJourney`, `DraftManagement`, format 1, `localOnly`.
- `lib/local_storage/pantry_codec.dart` : champs persistés et version 1 ; ancien contenu vide reconnu seulement.
- `lib/models/pantry_product_record.dart` : quantités finies non négatives, dates civiles, identités de lots.
- `lib/models/pantry_values.dart` : six unités, neuf `QuickCategory`, `QuickStock`, `ExpiryOrigin`.
- `lib/screens/onboarding/weekly_grid_screen.dart` : au moins un créneau pour continuer.
- `supabase/migrations/20260923120000_schema.sql` : tables, enums, contraintes, vue invoker, déclencheurs d'inscription.
- `supabase/migrations/20260923120100_rls.sql` : anciens `FOR ALL`, permissions de colonne, détails de recettes lisibles sans filtre de publication.
- `supabase/migrations/20260924090000_target_weight_equipment.sql` : cibles/rythmes, seuil historique arrondi, trois équipements supplémentaires, fonction démo remplacée.

Éléments **prouvés localement** : `family` ≠ `foyer` ; unité Réserve historique partagée avec ingrédients ; poids/quantités SQL à précision limitée ; absence de devise du budget ; absence des déclarations communes du foyer et des exclusions textuelles ; ancienne RLS des détails de recettes permissive ; grants de colonne sur le profil ; aucune séquence dans les sept migrations.

Éléments **non vérifiés** : version effective du serveur distant, schéma réellement déployé, ACL héritées/defaults, propriétaires des objets, éventuelles fonctions/vues supplémentaires, données historiques présentes, compatibilité effective des brouillons et performances. Aucun accès Supabase distant n'a été effectué.

Les mentions anciennes « phase 2 non commencée / sauvegarde non autorisée » en tête des documents datent de la clôture documentaire précédente. L'autorisation initiale permettait la création des six brouillons ; celle du 23 octobre est limitée aux cinq fichiers indiqués ci-dessus. L'ancienne formulation « conserver les contraintes calculées » n'impose pas une troisième copie permanente : le contrat V1 §6 retient leur calcul à partir des sources. Les anciennes conventions EUR, six langues ou anciennes étapes ne justifient aucune réécriture des données.

## 2. Ordre et contenu

| Ordre | Fichier | Contenu candidat | Conditions avant adoption |
|---|---|---|---|
| M1 | `M1_business_schema.sql` | Schéma privé de fonctions ; devises et budgets exacts ; tableaux du foyer ; exclusions Solo ; mensurations élargies ; Réserve fidèle | Comparaison du schéma exact et des dépendances ; lecture avant/après sur données historiques |
| M2 | `M2_integrity_registry.sql` | Clés composites ; identifiants locaux uniques ; seule nouvelle table privée `guest_imports` ; verrou de propriétaire ; intégrité du cuisinier | Diagnostic préalable des liens historiques incohérents ; cascades et concurrence |
| M3 | `M3_security_rls.sql` | Rôle sans connexion/BYPASSRLS ; révocations de table et de colonne ; anciennes politiques remplacées ; recettes publiées ; droits minimaux | Inventaire complet ACL/rôles/fonctions et chemins service/admin |
| M4 | `M4_transactional_import.sql` | Projection typée V1 ; validation ; canonical-1 ; SHA-256 ; import transactionnel ; reçu/reprise ; ownership sécurisé des RPC | Tests PostgreSQL 17, vecteurs communs Flutter/PG, injection d'échecs et tests de sécurité |

Un seul nouveau stockage technique : `menoo_private.guest_imports`. Les fonctions privées ne sont pas de nouvelles tables. Aucun nouveau menu, aucune table de contraintes effectives, aucune migration historique modifiée.

## 3. Correspondances explicites

| Source réelle | Valeur importée | Destination / règle |
|---|---|---|
| `DraftJourney.solo` | `solo` | `app_mode.solo` |
| `DraftJourney.family` | `family` | `app_mode.foyer` ; conserver `family` dans l'empreinte/reçu de transport |
| `DraftManagement.shopping / pantry / mixed` | Code de l'enveloppe | Vérifié contre `courses / reserves / mixte` des réponses acceptées |
| `ManagementMode.courses / reserves / mixte` | Même code | `households.management_mode` |
| `HealthGoal.pertePoids / priseMasse` | Même code Dart à l'entrée | `perte_poids / prise_masse` dans SQL |
| `seche / maintien` | Même code | Enum historique conservé |
| `ActivityLevel.tresActif` | `tresActif` | `tres_actif` ; `leger` historique demeure lisible, non créé par import |
| `Sex.homme / femme` | Même code | Solo seulement ; sexe Famille non collecté laissé NULL |
| `MemberRole.adulte / enfant / bebe` | Même code | Rôle original ; facteur calculé par version 1, sans champ de facteur individuel |
| `MealType.petitDejeuner` | `petitDejeuner` | `petit_dejeuner` |
| `dejeuner / diner` | Même code | Créneaux seulement ; `collation` historique conservé, hors import |
| `PantryLocation.fruitBasket` | Codec : `fruit_basket` | Enum SQL `fruit_basket` |
| `piece / gram / kilogram / milliliter / liter / pack` | Codes PantryCodec | Texte SQL `piece / g / kg / ml / l / pack` |
| `ExpiryOrigin` | `unknown / estimated / userProvided` | Préservation exacte |
| `QuickStock` | `present / some` ou NULL | Préservation qualitative, sans quantité fictive |
| `QuickCategory.id` | Les neuf codes réels du codec ou NULL | `declared_category` ; ce n'est pas `FoodCategory` |

`FoodCategory`, `category`, `proposedCategory` d'un formulaire provisoire ne sont pas importés. Leur persistance future est reportée, conformément à la validation utilisateur. Aucune reconstitution des anciens produits.

### Correspondance des champs métier

| Champ source admissible | Destination |
|---|---|
| Identité explicitement confirmée du foyer | `households.name` |
| Prénom Solo confirmé à l'inscription | `household_members.first_name` du bénéficiaire Solo |
| `budgetAmount`, `budgetCurrency` | `weekly_budget_cents` exact en unités mineures et `budget_currency` |
| `slots[].day / meal` | `meal_plan_slots.day_of_week / meal_type` |
| `cuisinePreferences` | `households.cuisine_preferences` ; préférence, pas interdiction |
| `cookingLevel`, `weekdayMinutes`, `weekendMinutes` | `kitchen_settings` |
| `equipment` | `household_equipment` |
| Régimes/allergies Solo | `member_diets`, `member_allergens` |
| Exclusions textuelles Solo | `household_members.excluded_foods`, ordre et répétitions conservés |
| Contraintes générales Famille | `households.diet_codes / allergen_codes / excluded_foods` |
| Allergies d'un membre Famille | `member_allergens` de ce membre uniquement |
| `members[].id` | `source_local_id`, correspondance UUID dans le reçu, pas le prénom comme clé |
| `firstName / role / age / heightCm / weightKg` Famille | Champs correspondants de `household_members` ; ordre via `position` |
| `mainCookId` | UUID du membre adulte du même foyer, ou NULL |
| Profil Solo : sexe, âge, taille, poids, objectif, activité | Colonnes correspondantes de `household_members` |
| Cible/rythme Solo actifs | `target_weight_kg / weekly_rate_kg` ; maintien : NULL, valeurs inactives locales conservées |
| `wantsScale` Solo | `household_members.wants_scale` ; aucun historique de balance créé |
| Version/facteurs portions Famille | Version 1 stockée au foyer ; facteurs reçus strictement vérifiés, pas dupliqués |
| Produit `id / name / quantity / unit / unitLabel` | `source_local_id / name / quantity / unit / unit_label` |
| Produit `location / expiresOn / expiryOrigin / source` | `location / expires_on / expiry_origin / source` |
| Produit `foodId` | `local_food_id` textuel ; `ingredient_id` reste NULL, aucune résolution au nom |
| Produit `declaredCategory / declaredStock` | `declared_category / declared_stock`, NULL compris |
| Identité d'origine, versions, empreinte, opération | Registre privé, reçu minimal, pas d'instantané métier complet supplémentaire |

Solo stocke ses contraintes sur son membre ; les tableaux du foyer technique sont vides. Famille stocke les sources générales sur le foyer et les allergies individuelles sur leurs membres. Les colonnes SQL historiques non collectées ne sont pas remplies artificiellement : sexe/objectif/activité d'un membre Famille, `wants_scale` Famille, identifiants catalogue, barcode, magasins, drive, avatar. Les valeurs techniques par défaut déjà présentes en SQL ne constituent pas des déclarations utilisateur ; par exemple `opened=false` ne prouve pas que l'utilisateur a confirmé un emballage fermé.

## 4. Projection de transport proposée

La RPC candidate prend quatre arguments :

`import_guest_v1(p_expected_user_id uuid, p_operation_id uuid, p_payload text, p_expected_hash text)`.

`p_expected_user_id` est une **assertion de session**, jamais l'autorité de propriété. `auth.uid()` est la seule autorité. L'opération et le compte attendu sont figés dans un futur journal client avant le premier envoi ; ce journal est distinct de `LocalDraft`.

Objet racine strict : `contract`, `version`, `canonicalVersion`, `originId`, `journey`, `sourceVersions`, `sourceCurrency`, `sourceManagement`, `identity`, `answers`, `pantry`. Toute clé manquante ou inconnue est refusée. Les extensions locales inconnues restent locales avec information préalable, sans suppression.

- `contract = menoo.guest-import`, `version = 1`, `canonicalVersion = canonical-1`.
- `originId` : UUID durable, texte minuscule à tirets. Ne pas utiliser `guest.solo` comme identité mondiale. L'UUID doit être alloué et persisté côté client une seule fois pour une origine ; une nouvelle tentative ne le change pas.
- `journey` : `solo` ou `family`.
- `sourceVersions` : objet exact `{localDraft:1, answers:1, pantry:1}`. `pantry:0` désigne uniquement l'ancien contenu vide explicitement reconnu par `readLegacyDraft` ; il impose un tableau Réserve vide. Ce marqueur ne prétend pas qu'un ancien produit non versionné aurait été décodé.
- `sourceCurrency` : devise de l'enveloppe locale, à confronter à `answers.budgetCurrency`. Une contradiction bloque ; aucune devise inférée.
- `sourceManagement` : code de l'enveloppe `shopping/pantry/mixed`, confronté à la réponse métier `courses/reserves/mixte`.
- `identity` : objet exact `householdName`, `soloFirstName`, `confirmed`. Confirmation vraie requise ; prénom Solo non vide ; prénom Solo NULL en Famille. Ce sont des confirmations à recueillir dans le futur parcours d'inscription, pas de nouveaux champs SQLite.
- `answers` commun : `slots`, `budgetAmount`, `budgetCurrency`, `management`, `diets`, `allergens`, `excludedFoods`, `cuisinePreferences`, `cookingLevel`, `weekdayMinutes`, `weekendMinutes`, `equipment`.
- Solo ajoute : `goal`, `sex`, `age`, `heightCm`, `weightKg`, `targetWeightKg`, `weeklyRateKg`, `activity`, `wantsScale`.
- Famille ajoute : `members`, `mainCookId`, `portionRulesVersion`, `portionFactors`. Chaque membre comprend exactement `id`, `role`, `firstName`, `age`, `heightCm`, `weightKg`, `allergens`. Les anciens `goal/activity` Famille sont inactifs et restent locaux.
- `pantry` contient les 12 clés réelles de chaque produit du codec, toutes présentes même NULL. Deux noms identiques avec des id différents restent deux lots.

Tous les **nombres métier** sont transportés en chaînes décimales, même âge, jour, temps et identifiant numérique local. Seules les versions restent des nombres JSON. Les facteurs Famille arrivent comme chaînes `"1"`, `"0.65"`, `"0.3"`. La projection serveur reconvertit uniquement les chemins numériques connus en `numeric` exact pour l'empreinte ; elle ne transforme jamais une chaîne de nom ou d'exclusion en nombre. `mainCookId` et les mensurations facultatives peuvent être JSON NULL.

La projection d'import est distincte de `exportSoloAnswers/exportFamilyAnswers`. Elle exclut `budgetEdited`, `budgetInherited`, `nextMemberId`, `completedSteps`, `rawInputs`, `familyMemberEdits`, `routeStack`, `pantryForms`, navigation et champs historiques inactifs. Pour maintien, le rythme résiduel local ne devient pas un objectif distant : le snapshot admissible porte cible et rythme NULL. Aucun changement du brouillon original.

Préconditions futures client : attendre une sauvegarde locale réussie, relire le parcours choisi, contrôler la complétude, prévenir pour les formulaires provisoires, confirmer l'identité, figer l'opération et l'instantané. Le serveur ne peut pas prouver qu'un utilisateur humain a réellement confirmé une identité ni que toutes les données locales ont été présentées par un client modifié ; le drapeau de confirmation est une déclaration contrôlée, pas une preuve d'identité civile.

## 5. Nombres, devises et historique

| Devise autorisée par Dart | Exposant | Exemple exact de budget actuel |
|---|---:|---|
| EUR, GBP, USD, CAD, AUD, CHF, MAD, DZD | 2 | 65 → 6500 unités mineures |
| TND | 3 | 65 → 65000 millimes |

Le montant Dart actuel est entier et au moins 20 unités majeures ; le brouillon refuse un budget majeur fractionnaire, même représentable par la devise, pour rester conforme au modèle existant. La limite technique de l'entier natif Android est int64 (`9223372036854775807`), pas un plafond commercial ajouté au budget. Une future saisie de budgets fractionnaires demanderait un contrat adapté. Aucun change. Devise absente, `XXX`, inconnue, conflit enveloppe/réponses ou manque de précision : arrêt explicite.

La colonne historique garde son nom `weekly_budget_cents` mais devient `numeric` entier exact. Choix proposé : préférer `numeric` à `bigint`, car un entier Dart valide multiplié par 1000 peut dépasser `bigint`. Le contrôle impose entier, fini et minimum monétaire ; aucun arrondi ou cast flottant. Les anciennes valeurs numériques restent identiques et leur nouvelle devise reste NULL. Ne pas déclarer EUR à partir du commentaire historique du schéma.

Quantités/poids passent à `numeric` sans précision imposée. Quantité absente reste NULL ; zéro reste zéro ; pack reste pack. Mensurations bébé facultatives positives jusqu'à `9007199254740991` ; `height_cm` devient bigint, pour ne pas interdire une valeur acceptée par le modèle actuel. C'est un garde-fou technique du code existant, pas une recommandation de mesure plausible.

Validation des nouveaux profils : Solo âge 18–100, taille 120–230, poids 35–250 ; adulte Famille âge 14–100 et mêmes bornes taille/poids ; enfant 4–13, taille 80–190, poids 12–100 ; bébé 0–3, mesures facultatives positives. Composition Famille : 1–8 adultes, 0–8 enfants, 0–4 bébés. Les identifiants membres natifs positifs sont représentés exactement jusqu'au maximum int64.

Cible Solo : >0 et ≤250, direction de l'objectif respectée ; seuil minimal `ceil(18.5*(taille/100)^2*10)/10`. Perte : 0.25/0.5/0.75 ; prise : 0.25/0.5 ; sèche : 0.5 ; maintien : aucune cible/aucun rythme. Comparer les 111 tailles entières 120–230 avec le calcul binaire Dart avant validation : l'expression exacte SQL n'est pas une preuve de parité d'exécution. Exemple de divergence avec l'ancien arrondi SQL : 180 cm → seuil actuel 60.0, ancien `round` 59.9. Ne pas corriger les anciens poids/cibles automatiquement.

Contraintes élargies M1 : elles préservent les valeurs admises par les contraintes historiques, y compris mensurations et cibles des démos. Les validations strictes par rôle/parcours concernent les nouveaux imports, pas un reclassement rétrospectif (l'enfant historique de 14 ans n'est pas déplacé en adulte).

Les colonnes monétaires de menus/courses et le catalogue de prix historique restent en convention EUR et avec leurs limites antérieures. **Importer un budget TND n'autorise pas à utiliser les prix EUR pour générer un menu TND.** Le futur générateur devra vérifier la disponibilité de prix comparables, la devise de chaque coût et la capacité numérique des tables dérivées. Aucun menu n'est créé ici.

## 6. Canonical-1 et SHA-256

Algorithme proposé entièrement décrit et transcrit dans les fonctions `project_payload`, `canonical_node`, `payload_hash` ; **parité Flutter/PostgreSQL non démontrée**, aucun vecteur SHA exécuté ni résultat inventé.

1. Recevoir le JSON brut en texte. PostgreSQL 17 requis ; vérifier `IS JSON OBJECT WITH UNIQUE KEYS` avant tout cast jsonb. Les clés dupliquées dans les objets imbriqués sont également refusées.
2. Vérifier les clés/types/versions, convertir les seuls chemins numériques de la projection, vérifier les codes et contraintes. Champs absents et NULL sont distincts ; absence d'une clé requise refusée.
3. Trier les ensembles de codes par octets UTF-8 et refuser les doublons. Trier les créneaux par jour puis code de repas UTF-8 ; trier les lots par id UTF-8. Préserver l'ordre des membres et la liste d'exclusions, répétitions comprises.
4. Encoder récursivement la projection avec les balises suivantes. Les longueurs de texte sont des **octets UTF-8**, pas des caractères UTF-16. Les comptes d'objets/tableaux sont des nombres d'éléments.

| Type sémantique | Encodage |
|---|---|
| NULL | `N` |
| Booléen | `B0` ou `B1` |
| Texte | `S` + longueur ASCII + `:` + texte UTF-8 |
| Nombre | `D` + longueur ASCII + `:` + décimal normalisé |
| Tableau | `A` + nombre d'éléments ASCII + `:` + enfants |
| Objet | `O` + nombre de paires ASCII + `:` + paires clé/valeur ; clés triées par octets UTF-8 et encodées comme textes |

Exemple d'encodage de nœud, hors préfixe : `{"a":null}` → `O1:S1:aN`. Ce n'est pas un vecteur de hash validé.

Nombres : pas de notation exponentielle à l'entrée de transport, pas de `+`, pas de zéros de tête inutiles ; zéros décimaux finaux supprimés lors de la normalisation ; -0 devient 0. Les entrées `"1"`, `"1.0"`, `"1.000"` sur un chemin numérique deviennent le même nombre. Une chaîne libre `"1"` reste de type texte et diffère du nombre 1.

Flutter devra partir de la représentation round-trip de la valeur réellement stockée (`double.toString()` pour un double), puis développer l'exposant avec des opérations textuelles exactes. Ne pas utiliser `toStringAsFixed`, `double.parse` intermédiaire ni une multiplication flottante pour la monnaie. Un entier natif est sérialisé directement en chiffres, sans passer par double. On conserve la valeur représentée par le modèle ; on ne récupère pas une précision déjà perdue avant sauvegarde.

Préfixe exact UTF-8 : `menoo.guest-import/v1/canonical-1` suivi d'un unique LF (`0A`), puis le nœud canonique. Hash natif PostgreSQL 17 `pg_catalog.sha256(bytea)`, 32 octets, transport hexadécimal minuscule de 64 caractères ; aucune extension pgcrypto nécessaire pour ce calcul.

Inclus : identité d'origine, parcours, versions, confirmations nécessaires, données métier admissibles, devise et mode de gestion de source pour détecter les contradictions. Exclus : `operation_id`, compte attendu, jeton, hash annoncé, dates de transport, navigation. Le passage family→foyer intervient après l'empreinte.

Aucune normalisation Unicode/NFC implicite, aucune modification du texte des noms/libellés/exclusions. JSON échappé et JSON littéral désignant les mêmes caractères donnent les mêmes octets après décodage. U+0000, séquences Unicode invalides et formes que PostgreSQL ne peut pas conserver sont refusés ; pas de remplacement silencieux.

Limites techniques candidates : requête ≤8 Mio, texte décimal ≤1024 octets, récursion canonique ≤32 niveaux. Elles couvrent les représentations ordinaires et extrêmes des nombres Dart finis ; les lots et textes cumulés peuvent dépasser 8 Mio, auquel cas refus explicite sans perte locale. Ces limites ne sont pas un plafond produit adopté : confirmer leur compatibilité sur les fixtures maximales. La quantité est bornée au plus grand double fini représenté par Dart ; aucune quantité négative, NaN ou infinie.

## 7. Intégrité et historique

Les clés candidates composites sont non différables ; les FK peuvent être différables. Syntaxe candidate : `FOREIGN KEY (main_cook_member_id,id) REFERENCES household_members(id,household_id) DEFERRABLE INITIALLY DEFERRED NOT VALID`. Ce motif est autorisé par PostgreSQL 17. Ne pas le remplacer par une troisième table.

Relations ajoutées : profil actif/propriétaire du foyer ; cuisinier/même foyer ; liste/menu/même foyer ; commande/liste/même foyer ; registre/foyer/même propriétaire. Le cuisinier doit aussi être adulte, vérifié par déclencheurs différables dans les deux directions.

Correction M2 du 23 octobre : `check_main_cook` utilise OLD/NEW uniquement pour identifier les foyers concernés, puis relit leur état courant quand le contrôle différé se déclenche. Un déplacement H1→H2→H1 ne doit pas échouer à cause d'un état intermédiaire disparu. Pour un changement de foyer du membre, les deux foyers sont contrôlés ; pour un changement de rôle, le cuisinier final doit toujours être adulte. La suppression d'un membre conserve le SET NULL historique ; un foyer supprimé par cascade n'a plus de cuisinier à valider. Aucun lien n'est réparé, aucun membre déplacé ni historique supprimé par ce contrôle. Les FK composites et leur caractère différé restent inchangés. Leur interaction avec suppressions, RLS, verrous et cascades n'est pas démontrée sans essai isolé.

`NOT VALID` évite de réécrire/refuser d'emblée l'historique, mais s'applique aux nouvelles écritures ; un ancien lien incohérent peut empêcher une mise à jour future. Les triggers de cuisinier ne disposent pas d'un équivalent NOT VALID : tout conflit existant doit être diagnostiqué avant adoption. Aucun correctif de données n'est automatique. Les index uniques de provenance sont partiels sur les valeurs non NULL ; les UUID historiques restent intacts.

Ne pas ajouter UNIQUE(owner_id) : plusieurs anciens foyers d'un compte sont conservés. Un seul foyer actif est désigné par le profil. Cela ne dit rien du nombre de menus : Solo personnalisé, Famille commun. Aucune table de menu n'est écrite par l'import.

Le contrôle des tableaux du foyer utilise un trigger, les sous-requêtes de catalogue n'étant pas adaptées à un CHECK. Les suppressions/modifications administratives de codes de régimes/allergènes doivent être encadrées avant utilisation réelle : ces tableaux n'ont pas de FK élémentaire native. Les catalogues sont sans écriture client ; les futures opérations administratives devront vérifier leurs références. L'import et les FK historiques sont à tester face à une mutation concurrente du catalogue.

Conversion `pantry_items.unit` : uniquement cette colonne vers texte contrôlé, `USING unit::text`, sans défaut SQL historique à convertir. Le type `public.unit` des ingrédients ne change pas. Les fonctions démo des migrations 4/6 utilisent encore `i.unit` (enum) dans un INSERT vers Réserve : vérifier leur résolution/assignation après conversion. Aucune dépendance distante n'est présumée absente. Une incompatibilité bloque l'adoption ; les migrations historiques ne sont jamais réécrites.

## 8. Matrice des droits cibles

`E` ci-dessous = rôle `menoo_import_executor`, sans connexion, superuser, héritage, création de rôle/base, réplication, BYPASSRLS, propriété de table ou appartenance client. Les droits sont cumulatifs dans PostgreSQL : retirer un GRANT de table ne retire pas un GRANT de colonne ou hérité.

| Objet | PUBLIC / anon | authenticated | E |
|---|---|---|---|
| Schéma public | Aucun CREATE client | USAGE, aucun CREATE | USAGE ; CREATE uniquement transitoire pendant changement de propriétaire des RPC |
| Schéma auth | Aucun nouvel accès aux tables Auth | Fonction uid selon contexte gateway | USAGE + EXECUTE auth.uid(), aucun accès auth.users |
| Schéma privé | Aucun USAGE/CREATE | Aucun USAGE/CREATE | USAGE, aucun CREATE |
| Profils | Aucun droit métier | SELECT propriétaire ; UPDATE(display_name) seulement | SELECT propriétaire + UPDATE(mode, active_household_id, onboarding_completed_at) |
| Foyers | Aucun | SELECT propriétaire | SELECT propriétaire ; INSERT colonnes explicitement listées ; UPDATE(main_cook_member_id) |
| Membres | Aucun | SELECT du propriétaire | SELECT et INSERT colonnes explicitement listées ; aucun UPDATE/DELETE |
| Cuisine/équipements du foyer | Aucun | SELECT du propriétaire | SELECT + INSERT des colonnes métier |
| Régimes/allergènes membres | Aucun | SELECT du propriétaire | SELECT + INSERT ; aucun recopiage entre membres |
| Exclusions catalogue historiques | Aucun | SELECT du propriétaire | Aucun droit d'import, non utilisé pour les exclusions textuelles |
| Créneaux | Aucun | SELECT du propriétaire | SELECT + INSERT |
| Produits Réserve | Aucun | SELECT du propriétaire | SELECT + INSERT colonnes métier/provenance ; pas de lien catalogue arbitraire |
| Registre privé | Aucun | Aucun accès direct | SELECT/INSERT owner via RLS ; aucun UPDATE/DELETE |
| Catalogues régimes/allergènes/équipements | Aucun | SELECT existant | SELECT nécessaire aux validations et FK |
| Autres catalogues | Aucun | SELECT selon RLS ; recettes/détails publiés seulement | Aucun droit ajouté |
| Menus/listes/événements/commandes/poids | Aucun | SELECT propriétaire ; seules UPDATE(cooked_at) et UPDATE(checked) maintenues | Aucun droit d'import |
| premium | Aucun | Lecture de son profil ; aucune écriture | Aucune écriture |
| owns_household / owns_member | Aucun EXECUTE public/anon | EXECUTE historique | EXECUTE explicite |
| owns_menu / owns_shopping_list | Aucun EXECUTE public/anon | EXECUTE historique | Aucun besoin, aucun nouveau GRANT |
| Fonctions privées métier/canonical | Aucun EXECUTE | Aucun EXECUTE | Liste explicite M3/M4 |
| RPC import / reçu | Aucun EXECUTE | EXECUTE sur les deux signatures exactes | Propriétaire des deux fonctions uniquement |
| Fonctions trigger | Pas de RPC client | Aucun appel direct | Invocation des triggers existants ; exécution avec droits invoker pour nos triggers |
| load_demo_data | Aucun | Aucun | Aucun |
| Séquences | Aucun ajout | Aucun ajout | Aucun GRANT, aucune séquence utilisée |

Les INSERT de E sont limités aux colonnes listées dans M3. Les valeurs UUID sont allouées côté serveur. Le client ne fournit pas d'UUID propriétaire, de statut premium ou de booléen demo. La permission UPDATE du profil permet également le verrou `FOR UPDATE` ; SELECT seul ne suffirait pas.

Les droits SQL des fonctions système intégrées (conversion JSON, sha256, UUID, temps) doivent être disponibles dans la base cible ; aucun nouveau privilège sur une table système n'est requis. Inventorier les éventuelles révocations de fonctions pg_catalog, pas seulement les rôles applicatifs.

RLS : remplacer les anciennes politiques FOR ALL par SELECT ; ne pas simplement ajouter des politiques en espérant qu'elles restreignent un ancien OR permissif. Retirer les droits de colonnes historiques de mode/foyer actif/onboarding. Les détails de recettes exigent l'existence d'un parent publié ; la vue `recipe_catalog` reste security_invoker.

M3 refuse les memberships ascendants des rôles clients/technique. Un inventaire plus général reste obligatoire : fonctions SECURITY DEFINER publiques et toutes leurs surcharges, vues, rôles hérités, options SET ROLE/INHERIT, defaults par créateur, ownership, SQL dynamique et fonctions service. Les noms de politiques inattendus des tables réécrites arrêtent le script ; le catalogue de politiques complet doit aussi être comparé avant adoption.

Durcissement M3 du 23 octobre : un contrôle final refuse les attributs superuser, BYPASSRLS, CREATEROLE, CREATEDB ou REPLICATION pour `anon`, `authenticated` et E. Il refuse également, sur les 28 tables publiques historiques et le registre privé, une RLS désactivée ou des droits de propriétaire disponibles pour ces rôles (propriété directe, héritée ou accessible par SET ROLE). Le registre doit en plus conserver FORCE ROW LEVEL SECURITY. Les propriétaires administratifs habituels de Supabase ne sont pas interdits : la cible du contrôle est l'accès client/technique à leurs droits. Aucune permission nouvelle ni modification automatique de rôle n'est introduite.

Ce contrôle repose sur les catalogues et `pg_has_role(..., 'USAGE'/'SET')` de [PostgreSQL 17](https://www.postgresql.org/docs/17/functions-info.html#FUNCTIONS-INFO-ACCESS-TABLE). La documentation établit la disponibilité de ces tests, pas leur réussite dans la configuration Supabase réelle, inconnue ici. Rôles absents, objets supplémentaires, permissions des fonctions système et chemins privilégiés nécessitent l'inventaire préalable. Un refus doit conduire à un diagnostic, jamais au retrait du contrôle pour continuer. Ce garde-fou n'établit pas à lui seul l'isolation complète, la sûreté de toutes les fonctions SECURITY DEFINER ou celle des accès administratifs.

Les DEFAULT PRIVILEGES ne sont pas rétroactifs. Le brouillon ne prétend pas corriger ceux de créateurs distants inconnus ; l'administrateur devra préparer des révocations ciblées à partir de l'inventaire. Le rôle service/admin reste une autorité de confiance pouvant contourner RLS ou désactiver des triggers : aucune garantie d'isolation contre un administrateur malveillant n'est revendiquée.

Les CHECK privés M1 et triggers invoker exigent les permissions de leurs appelants réels. E dispose des helpers nécessaires. Les futurs chemins service/admin de génération, édition, suppression et maintenance doivent être recensés ; ne pas supposer qu'un rôle service dispose déjà d'USAGE/EXECUTE sur le nouveau schéma privé. Des GRANT ciblés pourront être nécessaires après justification, sans exposer ce schéma au client.

## 9. Transaction, concurrence, récupération

Ordre candidat :

1. Vérifier session non vide et égalité avec le compte attendu ; opération non NULL.
2. Vérifier taille/JSON unique ; projeter/valider le format V1 ; recalculer l'empreinte ; comparer le hash annoncé.
3. Verrouiller `profiles(id=auth.uid()) FOR UPDATE`. Profil absent : échec récupérable, pas de création partielle d'un profil arbitraire.
4. Retrouver d'abord le reçu par propriétaire/opération : contenu identique → même reçu ; différent → refus.
5. Retrouver ensuite propriétaire/origine/parcours : contenu identique → reçu initial ; différent → refus. Une origine attribuée à un autre compte est cachée par RLS et rejetée par l'unicité globale avec erreur générique.
6. Contrôler le compte sous verrou : aucun foyer, même inactif, ni marqueur actif/onboarding/mode préexistant. `display_name` Auth et premium seuls ne déclenchent pas de remplacement ni ne sont modifiés. Le traitement conservateur d'un `mode` isolé nécessite confirmation lors des essais de compatibilité ; en attendant, refus plutôt qu'écrasement.
7. Vérifier les catalogues actuels puis insérer foyer, membres, déclarations, cuisine, créneaux, lots ; conserver la portée et l'ordre des données.
8. Renseigner le cuisinier si déclaré, puis le profil actif. Contrôler les compteurs et la relecture des valeurs sensibles Réserve ; insérer le reçu minimal dans la même transaction.
9. Forcer les contraintes différées pertinentes, puis relire toutes les données métier admissibles, le profil et le registre avant retour du reçu ; le gateway doit encore réussir COMMIT avant que le client ne considère le succès comme acquis.

Correction M4 du 23 octobre : le contrôle final porte sur les lignes SQL visibles au rôle E, pas uniquement sur les variables préparées ou le nombre de lignes. Les insertions, allocations d'UUID, mappings, construction/enregistrement du reçu et handlers de rollback existants sont conservés.

| Groupe relu après les contraintes différées | Comparaison candidate |
|---|---|
| Foyer et identité | UUID, propriétaire, nom confirmé, mode SQL, cuisinier issu du mapping ou NULL ; budget mineur exact et devise ; gestion ; cuisines ; contraintes communes ; version de portions |
| Membres et provenance | Cardinalité et taille du mapping ; chaque UUID relu à partir de son id local ; foyer, id source, prénom, rôle, ordre, propriétaire ; champs Solo collectés et correspondances d'enums ; mesures Famille et NULL non collectés |
| Déclarations individuelles | Allergènes de chaque membre, sans duplication dans les autres profils ; régimes Solo ; exclusions Solo avec ordre et répétitions ; aucune déclaration de régime individuel Famille inventée |
| Cuisine et planning | Niveau, temps semaine/week-end ; ensemble exact d'équipements ; nombre et présence de tous les couples jour/type de repas, sans catégories entrée/plat/dessert ajoutées |
| Réserve | Nombre et mapping des lots ; foyer, id source, nom, quantité, unité convertie, libellé brut, emplacement, date civile, origine de date, source, foodId local, declaredCategory, declaredStock ; ingredient_id reste NULL |
| Profil | Compte, mode, foyer actif, date de fin d'onboarding ; premium et display_name identiques aux valeurs verrouillées avant import |
| Registre et reçu | Compte/opération, origine, parcours SQL, versions, versions source, empreinte, foyer, date transactionnelle ; reçu enregistré identique au reçu retourné, avec les mappings relus ci-dessus |

Les comparaisons utilisent `IS [NOT] DISTINCT FROM` pour distinguer correctement SQL NULL, zéro, chaînes vides et listes vides. Maintien Solo : cible/rythme NULL ; bébé : mesures facultatives NULL ; Famille : sexe/objectif/activité/cible/rythme/exclusions individuelles/balance non collectés restent NULL. Aucun champ absent du parcours Famille n'est exigé comme une nouvelle réponse. Un cuisinier à tour de rôle, une date ou une quantité absente et des déclarations qualitatives NULL restent admissibles. Les ensembles de codes sont comparés triés ; les exclusions sont comparées comme listes ordonnées, répétitions incluses. Les textes libres comparés en SQL utilisent la collation C afin de ne pas accepter une différence de contenu sous une collation non déterministe.

L'assertion de confirmation de l'identité reste validée dans la projection et couverte par l'empreinte, sans nouvelle colonne de confirmation. Les contrôles réutilisent la conversion budgétaire et les correspondances déjà définies ; ils ne démontrent pas indépendamment leur justesse métier ni la parité de l'encodeur Flutter absent. Aucun arrondi, nouvelle catégorie, modification du protocole canonique ou des facteurs Famille 1 / 0.65 / 0.3 n'est introduit.

Tout écart déclenche une exception avant le retour du nouveau reçu et doit annuler métier, profil et registre ensemble. Les retours anticipés d'un reçu déjà validé restent inchangés : une modification métier ultérieure légitime ne doit pas empêcher de récupérer ce reçu historique. Le coût de ces relectures supplémentaires, leur exécution réelle avec ACL/RLS, les effets des triggers et la concurrence restent à démontrer (B1, B3, B5, B7, B9).

Le RPC n'écrit ni menu, ni poids historique, ni courses. Aucun COMMIT interne ; toute exception annule l'ensemble. Les erreurs de contrainte prévues sont traduites en codes génériques sans détails d'un autre compte. Les erreurs inattendues annulent également la transaction et doivent rester diagnostiquées côté serveur sans journaliser le contenu personnel.

Le trigger propriétaire de M2 impose le même verrou aux INSERT/UPDATE/DELETE ordinaires de foyers. Les futurs chemins de maintenance doivent prendre le profil avant le foyer ; tout transfert administratif de propriétaire est bloqué par le candidat et réclamerait une opération dédiée validée. Auditer TRUNCATE, triggers désactivés, `session_replication_role`, RPC existantes et service_role : les rôles de confiance ne sont pas protégés contre leurs propres pouvoirs.

L'unicité registre `(owner_id,operation_id)`, `(source_origin_id,journey)` et `household_id` constitue un second filet. Les lots/membres ont leur identité locale unique par foyer ; le nom ne sert jamais de clé. Deux origines concurrentes pour un compte ne peuvent pas créer deux foyers : la deuxième rencontre le compte rempli après le verrou.

`get_guest_import_receipt_v1(expected_user, operation, origin optionnelle, journey optionnel)` vérifie le compte puis prend le même verrou avant lecture. L'origine est un secours lorsqu'une autre opération a retrouvé le reçu initial. Le client conserve l'opération originale renvoyée et vérifie propriétaire, origine, parcours, versions, hash et mappings. NULL signifie aucun reçu visible à cet instant ; réessayer la même opération, jamais générer un nouvel id pour contourner un résultat inconnu.

Le journal client devra rester attaché au compte initial, à l'origine et au snapshot. Un callback de A arrivé après connexion B ne marque rien comme importé pour B ; cette protection locale n'est pas remplacée par le contrôle serveur. Toute édition locale ultérieure demeure non transférée. `LocalDraft.syncState` reste `localOnly`, aucun brouillon n'est effacé.

Compte rempli : utiliser les données distantes en gardant le local, ou annuler. Aucune fusion ni suppression. Compte Auth créé mais import échoué : compte conservé, même opération rejouable après correction explicite. Reçu/registre non mis à jour pour faire passer un contenu différent sous une ancienne opération.

## 10. Blocages et décisions restantes avant exécution

| Identifiant | Point à lever | Nature |
|---|---|---|
| B1 | Compiler/appliquer réellement ces candidats sur PostgreSQL 17 isolé, vérifier DDL/ACL/RLS/SECURITY DEFINER et transactions | Vérification technique non effectuée, pas une erreur SQL confirmée |
| B2 | Implémenter plus tard l'encodeur Flutter de projection/canonical-1 et produire des vecteurs de bytes/hash identiques | Dépendance client absente aujourd'hui, aucune modification Flutter autorisée ici |
| B3 | Inventorier schéma/ACL/defaults/fonctions/rôles réels dans un environnement ultérieurement autorisé | État distant inconnu ; aucune permission ou version distante supposée |
| B4 | Vérifier dépendances de unit→text, notamment la fonction démo remplacée en migration 6 ; adaptation additive éventuelle après preuve | Risque de compatibilité, pas panne exécutée/confirmée |
| B5 | Diagnostiquer liens historiques incohérents, effet NOT VALID sur futures mises à jour, cuisinier adulte et cascades compte/registre | Aucun nettoyage arbitraire autorisé |
| B6 | Vérifier toutes les tailles/cibles et bornes numériques contre Dart, ressources max et dates extrêmes | Conformité non démontrée par une simple lecture |
| B7 | Vérifier les chemins service/admin, mutations concurrentes de catalogues et permissions nécessaires des CHECK privés | Durcissement à compléter si l'inventaire révèle des chemins supplémentaires |
| B8 | Confirmer classification conservatrice du profil mode isolé et stratégie explicite de reprise d'un compte partiellement rempli | Arbitrage de récupération, aucune fusion introduite |
| B9 | Mesurer temps/mémoire des grands payloads, boucles/concaténations JSON et encodage canonique ; fixer timeout/limitation des appels à partir de preuves | Risque de coût et déni de service, limite de taille seule insuffisante |

Aucun composant n'est remplacé par du pseudo-code dans les fichiers SQL. Les corps candidats d'import, projection, hash et reprise sont rédigés. Cela ne lève pas B1/B2 : leur conformité réelle reste inconnue avant essais. Les candidats ne doivent jamais être vendus comme « prêts à déployer » parce qu'ils contiennent des CREATE FUNCTION complets.

Décisions produit déjà closes : menu Famille commun, compte à un foyer actif V1, seul parcours choisi transféré, autres brouillons/formulaires intacts, absence de fusion/écrasement, quatre choix d'architecture validés, catégorie manuelle reportée. Pas de nouvel arbitrage demandé sur entrée/plat/dessert, substitutions ou menus individuels : hors périmètre.

Suppression du compte (jalon ultérieur) : définir explicitement le devenir du reçu et de la provenance, les obligations de suppression et les possibilités de réimport après suppression intentionnelle. Le registre candidat suit la cascade du profil ; ce n'est pas un identifiant personnel conservé éternellement. L'anti-changement de compte de cette V1 couvre les reprises d'une opération liée à son compte, pas une promesse de tombstone intercomptes après effacement autorisé.

## 11. Récupération et retour arrière futurs

- DDL avant COMMIT : toute erreur annule le script entier, y compris création du rôle si elle appartient à la transaction. L'exception de garde assure cette propriété dans chaque fichier livré.
- Avant adoption M1–M4 : sauvegarde/snapshot de la base isolée et inventaire reproductible. Une restauration d'une base réelle exige une autorisation distincte ; aucune commande de restauration destructive fournie ici.
- Après M1/M2 : garder les ajouts non exposés ; diagnostiquer sans effacer ni réduire la précision. Ne pas revenir automatiquement à integer, numeric(5,1), numeric(10,2) ou NOT NULL : les nouvelles données pourraient ne plus y tenir.
- M3 sans M4 : état non destiné aux utilisateurs. Maintenir une fenêtre de maintenance et aucun import client activé avant validation de l'ensemble. Ne pas restaurer une RLS permissive pour contourner une panne.
- Import échoué : rollback de toutes les lignes et du reçu, compte Auth conservé ; snapshot local inchangé. Après perte réseau : résultat inconnu, interrogation du reçu puis même opération.
- Après un import déjà validé : retour arrière applicatif par désactivation des nouveaux envois, pas par suppression du foyer ou du registre. Les données importées restent récupérables ; toute évolution se fait par correction additive validée.

## 12. Références PostgreSQL primaires

- [PostgreSQL 17 — JSON, IS JSON et UNIQUE KEYS](https://www.postgresql.org/docs/17/functions-json.html).
- [PostgreSQL 17 — contraintes et clés étrangères](https://www.postgresql.org/docs/17/sql-createtable.html).
- [PostgreSQL 17 — fonctions, SECURITY DEFINER et permissions d'exécution](https://www.postgresql.org/docs/17/sql-createfunction.html).
- [PostgreSQL 17 — SHA-256 natif sur bytea](https://www.postgresql.org/docs/17/functions-binarystring.html).
- [PostgreSQL 17 — GRANT et droits de colonnes](https://www.postgresql.org/docs/17/sql-grant.html).
- [PostgreSQL 17 — ALTER TABLE et NOT VALID](https://www.postgresql.org/docs/17/sql-altertable.html).
- [Supabase — RLS et auth.uid()](https://supabase.com/docs/guides/database/postgres/row-level-security).
- [Banque centrale de Tunisie — dinar et millimes](https://musee.bct.gov.tn/en/collections).

Consultation documentaire publique uniquement ; aucune connexion à un projet Supabase. La préparation s'arrête aux six fichiers de ce dossier ; PLAN, DECISIONS, CLAUDE, contrat, Flutter, SQLite, Xiaomi et migrations historiques inchangés.

## 13. Empreintes des migrations relues

SHA-256 des fichiers locaux au début de cette préparation, pour vérifier une future base de comparaison. Ce ne sont pas des preuves de leur présence sur un serveur distant.

| Fichier | SHA-256 |
|---|---|
| 20260923120000_schema.sql | `56d7d77a8d983b07f66473cb503d6c62a1067e46377287ec64be5cac54776730` |
| 20260923120100_rls.sql | `bfea26298586f24a84247de838773dc9f807a88d790ef679c66d629ab67e0429` |
| 20260923120200_catalog.sql | `b43fdba798c2d25fe3fae022c4aa5e5bcb13dd6be1f44aada46be7d9c8aeb462` |
| 20260923120300_demo_data.sql | `db9de2eb5a41b98a3b1a757e81fe2c75a02865b4ec23a5d90b0004777b210640` |
| 20260923120400_backfill_profiles.sql | `e0d67c3eb9ab1bc2eb9079254d1803e877e53eefc3800bd6e2180ea1de366159` |
| 20260924090000_target_weight_equipment.sql | `4e6a18dedb487b64f5e277fc6aeb3669932131e9aaeb2cf320391f1fbf59e56c` |
| 20260924120000_diet_label_sans_porc.sql | `0a032bb2391fe87b23550ca97a28050bd9c2a0e5adc626d2071ea21fb0e58800` |
