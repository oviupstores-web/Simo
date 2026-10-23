# Plan de validation isolée — menoo.guest-import V1

Date : 22 octobre 2026. **PLAN UNIQUEMENT — AUCUN TEST EXÉCUTÉ.**

Compléments du 23 octobre 2026 : corrections locales M2/M3/M4 depuis le checkpoint `113d5d96e95fefbc9256459300a0f0ef4be9a9de`. Les scénarios ajoutés ci-dessous ne constituent ni des tests réalisés ni une autorisation de les préparer ou de les lancer.

Les quatre brouillons sont NON EXÉCUTABLES EN L'ÉTAT et possèdent une garde bloquante. Ce document ne donne pas l'autorisation de la retirer, de lancer PostgreSQL/Supabase, d'installer un outil, d'utiliser le téléphone ou d'appliquer une migration. Une nouvelle autorisation sera nécessaire.

## 1. Environnement et preuves attendues

Utiliser exclusivement une base PostgreSQL 17/Supabase de test isolée, sans données ni clés du projet réel. Créer deux comptes Auth fictifs A/B par le flux de test adapté, ainsi que deux sessions JWT distinctes via le gateway. Ne pas utiliser service_role pour prétendre avoir testé la RLS d'un utilisateur ; couvrir aussi le comportement réel des sessions sous SECURITY DEFINER.

Le lancement futur doit être explicitement autorisé et relever versions serveur/gateway, encodage UTF-8, collation, propriétaires, grants, DEFAULT PRIVILEGES par créateur, pg_auth_members, fonctions et surcharges, tables/vues/triggers/contraintes/index, schémas exposés. Aucun secret, jeton, contenu personnel ou mot de passe dans les rapports.

Conserver le SHA du dépôt, les empreintes des fichiers SQL, les résultats attendus/obtenus et les échecs initiaux. Chaque vérification ci-dessous doit disposer de son résultat propre. Les 421 tests locaux et les validations Xiaomi antérieures ne prouvent rien sur ces nouveaux scripts SQL.

## 2. Compatibilité avec les sept migrations

Reconstituer leur chaîne exacte dans l'ordre chronologique sur la base isolée. La migration catalogue et les fonctions démo ne doivent utiliser que des comptes fictifs. Ne jamais appeler `load_demo_data` sur un compte réel ; elle supprime les foyers is_demo du propriétaire ciblé.

| Migration existante | Vérification obligatoire après les candidats |
|---|---|
| `20260923120000_schema.sql` | 28 tables et enums inchangés hors adaptations listées ; triggers d'inscription/updated_at ; vue recipe_catalog ; public.unit des ingrédients conservé |
| `20260923120100_rls.sql` | Politiques FOR ALL remplacées ; droits de colonne réellement retirés ; aucune fuite par vue ou détails de recette ; profil premium protégé |
| `20260923120200_catalog.sql` | Codes réels : 6 régimes, 14 allergènes, équipements complétés ensuite ; intégrité recettes/ingrédients/prix inchangée ; catalogue EUR non utilisé comme TND |
| `20260923120300_demo_data.sql` | Données historiques de plusieurs foyers, budgets/pièges, anciens rôles et lots conservés ; aucun appel du chargeur dans l'import |
| `20260923120400_backfill_profiles.sql` | Profil existant non remplacé ; nouveaux comptes correctement provisionnés ; profil absent donne un échec récupérable |
| `20260924090000_target_weight_equipment.sql` | Cibles/rythmes et contraintes historiques conservés ; fonction démo remplacée utilisant i.unit testée après unit→text ; 12 équipements accessibles |
| `20260924120000_diet_label_sans_porc.sql` | Code sans_porc conservé ; absence de restriction ≠ nouveau régime omnivore ; aucun libellé retraduit/modifié par import |

Avant/après : comparer valeurs de chaque ligne historique, identifiants, noms, dates, budgets, montants, NULL, poids/cibles, liens et nombre de foyers. Comparaison logique tenant compte du nouveau type numérique, sans considérer un changement de type comme une permission de modifier une valeur. Dates updated_at historiques inchangées par les conversions DDL.

Créer aussi des cas historiques volontairement incohérents dans une copie isolée : cuisinier d'un autre foyer, profil actif appartenant à B, commande/liste croisée, liste/menu croisé. Vérifier le diagnostic et l'effet NOT VALID sans correction de ces lignes ; leur future modification peut être bloquée. Aucune suppression pour « rendre le test vert ».

## 3. DDL, syntaxe et privilèges

Après autorisation de préparer une version de test, enlever les gardes uniquement dans la copie de test explicitement identifiée. Ne pas modifier les migrations historiques. Appliquer M1→M4 à cette base et vérifier chaque transaction. En cas d'échec, consigner instruction/SQLSTATE ; ne pas continuer dans un état intermédiaire.

Vérifier notamment : syntaxe CASE des helpers ; REVOKE de table et de colonne ; FK composite NOT VALID et différable vers UNIQUE non différable ; triggers de cuisinier sur les deux tables ; résolution des contraintes qualifiées dans SET CONSTRAINTS ; changement de propriétaire des RPC ; CREATE temporaire retiré ; invocations des triggers privés et CHECK avec les droits exacts de E.

Exécuter les tests ACL pour PUBLIC, anon, A, B, E et les chemins service réellement utilisés, avec pg_catalog.has_*_privilege et tentatives effectives. Les noms de politique, ACL et memberships réels doivent être comparés à la matrice de TECHNICAL_DECISIONS. Vérifier également les ACL de fonctions pg_catalog/auth requises.

Injecter dans la copie un ancien grant UPDATE(mode), un grant UPDATE(premium), un grant de colonne pantry et un rôle parent donnant des droits supplémentaires : vérifier que les précontrôles ou la révocation les détectent/suppriment, sans supposer qu'une révocation de table suffit. Tester SET ROLE vers E ; refus client obligatoire. Vérifier toutes les surcharges publiques et defaults pour chaque créateur.

### 3.1. Prérequis supplémentaires pour M3 corrigé

Avant tout essai, obtenir une autorisation distincte ; identifier la copie isolée, son snapshot et le contexte d'administration capable de créer le rôle, d'en changer les fonctions propriétaires et de révoquer CREATE temporaire. Confirmer PostgreSQL 17, les versions Supabase/gateway et l'accès aux catalogues et à `pg_has_role` avec USAGE/SET. Relever tous les propriétaires des 28 tables historiques et de guest_imports, les attributs et chemins d'appartenance/SET ROLE des rôles, les activations RLS et FORCE RLS du registre. Ne pas déduire la configuration distante de celle de cette copie.

| Variante injectée dans la copie isolée seulement | Résultat à vérifier |
|---|---|
| Rôles clients sans privilèges critiques, E conforme, tables appartenant à l'administration habituelle, RLS active | Garde M3 acceptée ; aucune exigence de changement des propriétaires administratifs légitimes |
| anon/authenticated avec SUPERUSER, BYPASSRLS, CREATEROLE, CREATEDB ou REPLICATION, un attribut à la fois | MENOO_UNSAFE_ROLE_ATTRIBUTES ; rollback du script, aucune correction automatique du rôle |
| Un des rôles clients ou E propriétaire direct d'une table ciblée | MENOO_UNSAFE_TABLE_SECURITY ; aucun contournement par propriété |
| Droits de propriétaire hérités ou accessibles par SET ROLE | Refus par le précontrôle de membership existant ou le garde-fou complémentaire ; vérifier séparément la vérité des prédicats pg_has_role, sans affaiblir le candidat livré |
| RLS désactivée sur une table publique ciblée ou guest_imports ; FORCE RLS désactivée sur guest_imports | MENOO_UNSAFE_TABLE_SECURITY, sans réactivation automatique |
| Fonction SECURITY DEFINER/vues/defaults ou rôle service additionnels | Inventaire et tests d'accès effectifs indispensables ; garde acceptée ne signifie pas sécurité complète |

Pour les variantes touchant le rôle E créé par M3, utiliser après autorisation une instrumentation de copie explicitement documentée ; aucune suppression de contrôle dans les brouillons de référence. Réaliser les accès A/B après le passage du garde-fou, sous leurs vraies sessions, et vérifier les grants de lecture nécessaires aux nouvelles assertions M4, sans étendre les permissions pour masquer un échec.

## 4. Fixtures Solo et Famille

| Cas | Attendu |
|---|---|
| Solo complet minimal | Un foyer solo, un bénéficiaire ; données exactes ; aucun menu/courses/poids historique créé |
| Famille 2 adultes + 1 enfant + 1 bébé | Un foyer foyer ; membres dans l'ordre ; un planning commun de créneaux ; aucun menu individuel |
| Maximum 8/8/4 et minimum 1 adulte | Limites acceptées ; dépassement, absence d'adulte ou tranche d'âge incohérente refusés |
| Membres homonymes | UUID distincts, allergies rattachées par id local, aucun regroupement au prénom |
| Allergie d'un seul enfant + allergie commune | Sources distinctes en SQL ; aucune copie dans les autres profils ; union calculable sans troisième stockage |
| Régimes/restrictions cumulés | Codes exacts ; deux régimes principaux refusés ; restriction jamais abandonnée |
| Exclusions libres répétées et ordonnées | Liste et Unicode conservés, aucun rapprochement automatique avec ingredients |
| Contraintes inconnues | Refus explicite, données locales conservées ; pas d'effacement du code inconnu |
| Prénoms de démo non confirmés | Export client bloqué avant envoi ; confirmation requise par RPC ; un vrai utilisateur ayant le même prénom ne doit pas être blacklisté |
| Cuisinier adulte choisi / à tour de rôle | UUID du même foyer ou NULL ; enfant/autre foyer refusés |
| Champ historique objectif/activité Famille | Reste local ; pas de cible nutritionnelle individuelle inventée |
| Un seul parcours choisi | Uniquement les réponses et lots de ce parcours ; autres données locales inchangées |

Séparer la vérification SQL de la future préparation client. SQL ne lit pas SQLite ; les garanties de sélection/flush/journal/conservation locales exigent ultérieurement des tests Dart sur des bases temporaires fictives, avec une autorisation dédiée. Aucun test sur les produits témoins Xiaomi.

## 5. Nombres, monnaie et dates

- Pour chaque devise de l'allowlist : budget majeur 20, 65, montant personnalisé >350 et grande valeur int64 ; vérifier calcul exact et lecture sans passage par double. TND 65→65000 ; devises à deux décimales 65→6500. Un montant dépassant bigint après multiplication doit rester exact en numeric.
- Budget <20, fractionnaire, sans devise, XXX, code non accepté, conflit sourceCurrency/budgetCurrency : refus intégral ; absence de conversion FX ou locale.
- Préserver tous les budgets historiques tels quels, devise NULL ; aucun backfill EUR. Vérifier les CHECK hérités et la future interdiction de génération avec des coûts d'une autre devise.
- Poids avec plusieurs décimales, cibles proches des bornes et quantités <0.01 : valeurs exactes, sans numeric(5,1)/numeric(10,2) réintroduit.
- Tester les 111 tailles Solo 120–230 sur le seuil Dart et SQL, plus juste avant/au/après le seuil (ex. 180 cm : 59.9 refusé, 60.0 admis si cohérent avec l'objectif). Rythmes spécifiques à chaque objectif et maintien avec valeurs inactives encore dans le brouillon.
- Adultes Famille à 14/100 ans, enfants 4/13, bébés 0/3 ; bornes de mesures de chaque rôle ; bébé NULL, zéro refusé, petite valeur positive, maxExactInteger ; ne pas arrondir height_cm en smallint.
- Quantités NULL, zéro, fraction exacte, plus grand double fini et plus petit subnormal ; négatif, NaN, Inf, dépassements : refus explicite. Distinguer représentation locale déjà arrondie et précision arbitrairement inventée.
- Dates civiles : année 0001/9999, année bissextile, 29 février invalide, 31 avril, espaces et heures supplémentaires, fuseaux différents. La même date doit rester le même jour ; aucune conversion UTC. Sans date : origine unknown requise ; date existante d'origine unknown admise.
- Chaînes décimales >1024 octets, payload >8 Mio, profondeur excessive : refus sans donnée métier partielle et sans disparition locale. Vérifier que les fixtures maximales légitimes restent représentables.
- Mesurer les grandes Réserves et payloads proches de la limite : temps, mémoire, concaténations JSON/bytea, coût de validation et appels répétés concurrents. Tester timeouts et limitation effective des appels ; un JWT valide ou une limite de taille ne suffit pas à prévenir un déni de service.

## 6. Réserve et portions

Vérifier les six unités, unit NULL, unitLabel vide/localisé/ancien inconnu, NULL≠0, pack≠piece, trois emplacements stockés plus fruit_basket, sources autorisées et source locale inconnue refusée explicitement.

Tester declaredCategory/declaredStock renseignés et NULL indépendamment ; ils doivent ressortir identiques. Produits qualitatifs sans quantité/unité acceptés. Un id alimentaire local n'est pas utilisé comme UUID catalogue. Deux produits homonymes restent deux lots, doublon d'id refusé.

Envoyer category/proposedCategory ou un formulaire provisoire dans un produit : clés inconnues refusées. Vérifier qu'aucune déduction de FoodCategory n'est faite. Sections inconnues locales conservées, jamais mises à zéro par le refus.

Facteurs Famille exacts 1 / 0.65 / 0.3, version 1. Une mauvaise valeur/version est refusée. Nombre de convives, nombre de repas servis et portions pondérées restent trois calculs distincts ; aucune conversion implicite en servings entier. Aucune écriture dans weekly_menus/menu_meals.

## 7. Canonical-1 : protocole de preuve croisée

À réaliser ultérieurement avec un encodeur Dart dédié et PostgreSQL 17, sans se contenter de comparer deux hashes produits par le même code.

Pour chaque fixture, conserver : JSON brut, projection typée attendue, octets canoniques hexadécimaux, longueur, SHA-256 côté Dart et PG. Vérifier d'abord les octets, puis les empreintes avec un troisième calcul SHA indépendant. Aucun hash attendu n'est fourni comme « validé » avant ces calculs.

| Vecteurs | Attendu |
|---|---|
| 1, 1.0, 1.000 et -0 aux chemins numériques | Même représentation normalisée selon valeur |
| Nom "123" vs quantité numérique 123 | Types/balises distincts |
| 0.1, 0.30000000000000004, 1e-7 et extrêmes issus de double.toString | Développement décimal exact puis mêmes octets ; aucun toStringAsFixed |
| Grands int64 et identifiants >2^53 | Aucun passage par double, identités exactes |
| Échappements JSON, accents, caractères hors BMP, Unicode combiné | Même contenu décodé → mêmes octets ; NFC distinct de NFD si sources distinctes |
| Clés dans un ordre différent, espaces du JSON brut | Même projection et empreinte |
| Ensembles/cases de grille/lots réordonnés | Même hash après normalisation ; doublons refusés |
| Membres/exclusions réordonnés | Hash différent, ordre métier conservé |
| Clé absente, NULL, tableau vide | Types distingués ; manque d'une clé requise refusé |
| Changement opération seulement | Même hash ; reprise par origine possible |
| Changement budget, allergie, devise, id lot, origine ou parcours | Hash différent |
| Clé dupliquée racine, imbriquée ou même nom décodé via échappement | Refus AVANT jsonb |
| Mauvais préfixe/LF/longueur UTF-16/tri locale | Comparaison de bytes doit échouer |

S'assurer que project_payload ne consulte pas de catalogue mutable : un ancien reçu doit rester récupérable après un changement autorisé de catalogue. Versionner sans réécrire le comportement V1 utilisé par des reçus déjà validés.

## 8. Sécurité entre A et B

- A ne lit ni profil, membres, allergies, budget, cuisine, lots, reçu de B par table, RPC, filtres, vue ou mapping ; mêmes tentatives B→A.
- anon sans JWT et utilisateur authentifié avec auth.uid NULL : refus import/reçu et aucune lecture métier.
- A ne peut pas fournir B comme propriétaire. `expected_user=B` sous session A est refusé, aucun foyer créé pour l'un ou l'autre.
- Modifier premium, mode, active_household_id, onboarding_completed_at, owner_id, source_local_id, registre ou tables importées via REST/SQL client : refus. Même avec anciennes autorisations injectées dans une copie, les contrôles doivent détecter l'écart.
- Relation cuisinier/membre d'un autre foyer, y compris deux foyers du même propriétaire : refus composite. Profil actif du compte B : refus. Listes/menus/commandes croisés : refus.
- Recette non publiée : ni parent, ni ingrédients, ni équipements, ni étapes, ni fuite via recipe_catalog. Recette publiée : lecture conforme à la RLS ; ceci ne constitue pas un paywall serveur, qui reste un autre sujet.
- Appeler les helpers privés, load_demo_data ou les triggers comme RPC ; créer une fonction temporaire ou détourner le search_path ; injecter du SQL dans un nom/exclusion ; sélectionner une surcharge non prévue : aucune élévation.
- Sous SECURITY DEFINER : auth.uid demeure A issu du gateway, current_user devient E ; E ne possède aucune table et reste soumis à RLS. Pas de confiance accordée à un identifiant JSON libre.
- Avec un accès administrateur dans la base isolée seulement : inventaire des bypass possibles, jamais présentés comme couverts par RLS. Ne pas exposer de clé service dans un test client.

## 9. Concurrence, rollback et reprise

Lancer de vraies transactions/sessions distinctes sur la base isolée ; une simulation séquentielle ne prouve pas l'absence de course.

| Scénario | Attendu |
|---|---|
| Double clic, même opération/contenu | Un foyer, un registre, même reçu |
| Même opération/contenu différent | Refus ; premier résultat inchangé |
| Deux opérations, même origine/contenu, même compte | Reçu original retrouvé, aucun doublon |
| Deux opérations, même origine/contenu différent | Refus, aucune fusion |
| Deux origines, même compte vierge | Première validation seule ; seconde voit compte rempli sous verrou |
| Même origine/parcours sous A et B simultanément | Un seul propriétaire admis ; autre transaction intégralement annulée, erreur générique |
| A et B, origines indépendantes | Deux imports isolés, sans verrou global inutile |
| Écriture foyer concurrente par chemin service ordinaire | Même verrou de profil ; aucune création passée entre contrôle et import |
| Profil/foyer verrouillés par maintenance en ordre inverse | Détecter deadlock/timeout, retry même opération ; imposer ordre profil→foyer aux chemins supportés |
| Mutation de code catalogue pendant import | Aucune déclaration de restriction perdue ni code invalide validé ; compléter les protections admin si nécessaire |

Injecter un échec : après foyer, après premier membre, après allergies, cuisine, créneau, premier lot, mise à jour profil, insertion reçu et pendant vérification de contrainte différée. Dans chaque cas : pas de nouvelles lignes métier/registre validées, profil antérieur identique, compte Auth conservé. L'allocation d'UUID inutilisée n'est pas une donnée partielle persistée.

Coupures : avant requête ; transaction en cours ; après COMMIT mais avant réponse ; après réception du reçu mais avant marquage local. En cas d'issue inconnue, récupérer le reçu ou rejouer la même opération et le même snapshot. Ne jamais changer l'opération automatiquement pour « débloquer ».

Changement de compte : figer le compte A avant envoi, connexion B avant requête → session_mismatch ; connexion B après requête A → aucun marquage du brouillon pour B ; retour à A → reçu récupérable. Modifier localement des réponses après snapshot : ces changements ne sont jamais marqués synchronisés par le reçu précédent.

Compte déjà rempli : actif, inactif, plusieurs foyers historiques, marker onboarding seul, mode seul. Aucun import/fusion/remplacement/second foyer ; valider le traitement explicite des états partiels. Afficher utiliser l'existant ou annuler, en gardant les brouillons.

### 9.1. Régressions ciblées M2 : état final du cuisinier

Dans une même transaction isolée, tester séparément les cas suivants et déclencher les contraintes différées aux mêmes moments que M4 puis au COMMIT :

- Membre cuisinier déplacé H1→H2→H1 avec liens finaux valides : succès, malgré les événements intermédiaires ; déplacement définitif laissant H1 incohérent : refus. Contrôler les deux foyers concernés, même propriétaire ou propriétaires distincts.
- Adulte→enfant laissé cuisinier : refus ; adulte→enfant→adulte avant contrôle : succès. Changement de rôle d'un autre membre : aucun faux refus ; remplacement du cuisinier par un autre adulte du foyer : succès.
- Suppression du cuisinier : SET NULL historique conservé ; sélection d'un nouvel adulte dans la même transaction : succès si état final valide. Suppression d'un autre membre : cuisinier intact.
- Suppression de foyer et cascade de compte fictif : aucun contrôle sur un foyer final absent ; vérifier aussi les cycles FK et le registre, sans contourner les contraintes existantes. Suppression isolée d'un foyer importé toujours bloquée par son registre.
- Liens historiques incohérents : diagnostic avant adoption, aucune réparation ni suppression automatique. Mesurer verrous et interblocages avec les sessions concurrentes et l'ordre profil→foyer.

### 9.2. Régressions ciblées M4 : relecture exhaustive avant succès

Dans la copie isolée autorisée, vérifier d'abord les imports normaux Solo/Famille avec les droits exacts de E et tous les groupes de la table de relecture de TECHNICAL_DECISIONS §9. Pour chaque champ admissible, prévoir une fixture attendue indépendante des fonctions de conversion candidates ; ne pas valider une formule uniquement en la réutilisant pour calculer l'attendu.

Prévoir ensuite une instrumentation de test locale (par exemple des triggers réservés à la copie) altérant une seule donnée après son écriture. Distinguer les erreurs bloquées plus tôt par une FK/CHECK des écarts détectés par les nouvelles assertions ; aucun code de cette instrumentation n'est créé par la présente intervention.

| Groupe altéré ou scénario | Preuve attendue |
|---|---|
| Foyer/identité, budget/devise/gestion, cuisines, contraintes communes, cuisinier/version portions | Chaque différence admissible est détectée ; ensemble de codes réordonné seul reste équivalent, exclusion réordonnée ou répétition perdue échoue |
| Membres : champ collecté, ordre, source_local_id, foyer, UUID du mapping ; membre absent ou supplémentaire | Échec de correspondance ou de cardinalité ; homonymes jamais fusionnés ; aucun succès avec mapping faux, incomplet ou excédentaire |
| Allergènes individuels et régimes Solo supprimés, ajoutés ou affectés au mauvais membre | Échec ; aucune propagation silencieuse dans les autres profils ; famille sans régime individuel inventé |
| Cuisine et équipement : niveau, temps, code ajouté/supprimé ; créneau jour/repas remplacé à nombre égal | Échec malgré compteurs identiques ; aucun menu individuel ou catégorie de recette créé |
| Chaque champ des lots, y compris source, emplacement, date/origine, foodId local, declaredCategory/declaredStock et lien ingredient_id | Échec pour valeur différente, perte de NULL, lien catalogue inventé ou UUID/id source incohérent ; deux homonymes restent deux lots |
| Profil : mode, foyer actif, date onboarding ; premium/display_name modifiés | Échec et profil d'origine intégralement restauré par rollback |
| Registre : propriétaire/opération, origine/parcours, versions source/contrat/canonique, hash, foyer, date ou reçu différent du retour | Refus par contrainte ou relecture ; aucun reçu de succès incohérent enregistré |
| Écart révélé seulement par un trigger différé du foyer, des membres ou du profil | Nouvelle relecture exécutée après les contrôles différés nommés ; pas de succès fondé sur une lecture intermédiaire |

NULL admissibles à couvrir sans faux refus : cible/rythme Solo maintien, mesures bébé absentes, données individuelles non collectées en Famille, cuisinier à tour de rôle, quantité/unité/date/foodId/declaredCategory/declaredStock absents. Couvrir aussi tableaux vides, libellé d'unité vide, quantité zéro, exclusions répétées/Unicode et noms sensibles à une collation non déterministe. Aucun test ne doit remplacer un NULL source autorisé par une valeur arbitraire pour réussir.

Pour tout échec, comparer l'état avant/après : aucune ligne importée, profil antérieur inchangé, aucun registre/reçu partiel, compte Auth et données locales conservés. Les boucles d'insertion, allocations/mappings UUID et enregistrement du reçu doivent encore être couverts par les fixtures complètes. Mesurer le coût supplémentaire des relectures sur les grandes Réserves et refaire les scénarios concurrents, d'interruption et de changement de compte de §9.

Enfin, après un import validé, effectuer une modification métier légitime par le chemin de test autorisé puis rejouer l'opération et récupérer le reçu : le reçu original doit rester identique. Les nouvelles assertions ne doivent pas réimporter le snapshot ni imposer à des données ultérieurement modifiées de correspondre à l'ancien snapshot.

## 10. Suppression et retour arrière

Base isolée seulement : vérifier que la suppression de compte fictif par la procédure administrative prévue supprime ses dépendances et son registre sans échec des cycles différés ; que supprimer seulement un foyer importé ne contourne pas le registre ; que l'autre compte demeure intact. Ne pas transformer cet essai en autorisation de suppression réelle.

Tester rollback de chaque transaction DDL candidate en injectant une erreur avant COMMIT. Après adoption simulée, ne pas faire de downgrade de précision ni de suppression des nouvelles colonnes pour tester un retour applicatif : désactiver les nouveaux envois en conservant les données. Documenter la restauration de snapshot uniquement pour cette base isolée.

## 11. Critères de sortie

La préparation peut devenir une proposition de migrations à valider uniquement si :

1. La chaîne des sept migrations et M1–M4 passe sur PG17 isolé ; aucune donnée historique modifiée et aucune migration historique réécrite.
2. Les matrices ACL/RLS et les accès croisés effectifs sont conformes, y compris héritage, colonne, SECURITY DEFINER et fonctions service inventoriées.
3. Les octets/hashes Dart et PostgreSQL sont identiques sur les fixtures ; nombres, dates, devises et portions sont fidèles.
4. Concurrence, rollback intégral, reprise après perte de réponse et changement de compte sont démontrés.
5. Toutes les anomalies sont résolues ou présentées pour arbitrage ; aucun blocage B1–B9 n'est caché par une mention « terminé ».
6. Simo autorise explicitement l'étape suivante. Aucune réussite en base isolée n'autorise automatiquement un accès distant ou un déploiement.

Arrêt de l'intervention actuelle après les corrections documentaires locales des cinq fichiers autorisés et vérifications statiques des fichiers/Git. Gardes NON EXÉCUTABLES conservées. Aucun test SQL, build, installation, staging, commit, push, reset ou clean dans cette préparation ; aucune préparation de base de test sans autorisation distincte.
