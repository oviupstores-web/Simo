# MENOO — Checkpoint de fin de session — Jalon 6, phase 2

Date : 22 octobre 2026. Périmètre : sauvegarde documentaire autorisée, sans développement ni exécution SQL.

**LES SCRIPTS SQL NE SONT PAS PRÊTS À ÊTRE EXÉCUTÉS.** Les brouillons n'ont pas reçu de revue indépendante, n'ont pas été validés par PostgreSQL et ne constituent pas des migrations adoptées. Le jalon 6, la phase 2 dans son ensemble et l'application ne sont pas terminés.

## 1. État réel du jalon 6

| Travail | État et limites |
|---|---|
| Réserve, étape 1 : modèle et codec | Terminée : produits validés, identité de lot stable, codec versionné Solo/Famille, quantités/unités/dates préservées. |
| Réserve, étape 2 : persistance des produits | Terminée : produits Solo/Famille enregistrés séparément dans SQLite chiffré, avec les réponses de leur parcours. |
| Réserve, étape 3 : formulaires et navigation | Terminée : saisies manuelles incomplètes, choix rapides provisoires, restauration des sous-écrans et retour de navigation. Commit fonctionnel validé : `c994191337fa78901b10a7ab364bcd9944e71afb`. |
| Phase 1 : contrat SQLite → Supabase | Terminée sur le plan fonctionnel ; contrat officiel `docs/contracts/menoo_guest_import_v1.md`, version 1 du 22 octobre 2026, avec correction du §10 sur les catégories Réserve. Commit validé : `e4fd62587e8e770df2adb91343b94d2a65a582c0`. |
| Phase 2 : conception et revue corrective | Architecture et revue corrective conversationnelle effectuées ; choix techniques validés comme cible sous réserve des vérifications restantes. Six brouillons locaux préparés. **Aucune revue indépendante des six fichiers achevée.** |
| Compte réel, transfert, génération de menus | Non opérationnels à ce checkpoint. Les corps SQL candidats rédigés ne prouvent pas un import fonctionnel, sécurisé ou déployé. |

Les 421 tests ciblés de l'étape 3 et les validations Xiaomi de la session précédente sont des preuves historiques de ce périmètre local. Aucun test, build, essai Android ou contrôle de données sur téléphone n'a été effectué pendant la préparation SQL ou cette sauvegarde. Ne pas les présenter comme une validation des nouveaux brouillons SQL ou de toute l'application.

## 2. Référence fonctionnelle et décisions à préserver

Le contrat V1 est prioritaire dans le périmètre du transfert. Les entrées anciennes de PLAN/DECISIONS sont un historique daté ; les mentions antérieures « phase 2 non commencée » ne décrivent plus la préparation documentaire actuelle. Aucun de ces documents n'est modifié par ce checkpoint.

- V1 : un compte avec un seul foyer actif, sans suppression des foyers historiques.
- Solo : un bénéficiaire et un menu personnalisé ; Famille : un menu commun au foyer, aucun menu individuel.
- Seul le parcours explicitement choisi est transféré ; l'autre brouillon, les données provisoires et tous les contenus locaux restent intacts.
- Allergies individuelles et contraintes communes conservées séparément avec leur provenance. Les contraintes effectives sont calculées, sans troisième copie permanente.
- Portions Famille version 1 : adulte 1, enfant 0,65, bébé 0,3.
- Aucune fusion, suppression ou écrasement automatique ; compte déjà rempli : utiliser l'existant ou annuler.
- Budget et devise indissociables, sans change ni arrondi silencieux ; TND à trois décimales.
- Catégorie manuelle Réserve reportée ; aucune catégorie manquante inventée. declaredCategory et declaredStock réels préservés, NULL compris.
- Catégories entrée/plat/dessert réservées au futur générateur, pas à développer dans cet import.

## 3. Liste exacte des six fichiers créés pendant la phase 2

| Fichier | Rôle |
|---|---|
| `docs/sql-drafts/guest_import_v1/M1_business_schema.sql` | Adaptations métier, précision numérique, budget/devise, contraintes du foyer et produits Réserve. |
| `docs/sql-drafts/guest_import_v1/M2_integrity_registry.sql` | Relations composites, provenance, registre privé unique et verrouillage. |
| `docs/sql-drafts/guest_import_v1/M3_security_rls.sql` | Rôle technique, permissions minimales, révocations et politiques RLS. |
| `docs/sql-drafts/guest_import_v1/M4_transactional_import.sql` | Validation/projection candidate, canonical-1, SHA-256, import transactionnel et récupération du reçu. |
| `docs/sql-drafts/guest_import_v1/TECHNICAL_DECISIONS.md` | Correspondances Dart/SQL, protocole proposé, hypothèses, droits, limites et blocages B1–B9. |
| `docs/sql-drafts/guest_import_v1/TEST_PLAN.md` | Protocole futur de validation isolée, deux comptes, historique, accès croisés, concurrence, rollback et reprise. |

Le présent rapport est le septième et seul autre fichier autorisé dans cette sauvegarde. Aucun fichier n'a été créé dans `supabase/migrations` ; les sept migrations historiques sont inchangées.

Chaque script SQL commence par une transaction et une exception volontaire `MENOO_DRAFT_NOT_AUTHORIZED: M1/M2/M3/M4`, avec la mention **NON EXÉCUTABLE EN L'ÉTAT**. Les gardes ont été contrôlées avant sauvegarde et doivent être conservées. Ne pas les retirer, exécuter un extrait ou déplacer les brouillons dans les migrations sans autorisation explicite.

## 4. Points bloquants et contrôles restant à effectuer

1. **B1 — PostgreSQL 17 isolé :** vérifier réellement syntaxe, contraintes, politiques, fonctions, ownership, permissions et comportement transactionnel. Aucun test SQL exécuté à ce stade.
2. **B2 — Empreintes croisées :** l'encodeur Flutter de projection/canonical-1 n'est pas implémenté. Produire et comparer des vecteurs d'octets et de SHA-256 Dart/PostgreSQL, notamment décimaux, int64, Unicode et JSON à clés dupliquées.
3. **B3 — Inventaire effectif :** version, schéma déployé, ACL, droits hérités/defaults, rôles, fonctions et surcharges distantes inconnus. Aucun accès au Supabase distant effectué pendant cette session.
4. **B4 — Unités Réserve :** vérifier les dépendances de enum→texte, notamment la fonction démo historique utilisant l'unité des ingrédients ; ne pas modifier les migrations anciennes pour contourner un échec.
5. **B5 — Historique et intégrité :** diagnostiquer les anciens liens incohérents, les effets de NOT VALID et des triggers de cuisinier, les cascades profil/foyer/registre. Aucune correction arbitraire de données.
6. **B6 — Parité métier :** comparer les bornes et calculs Dart/SQL, dont les 111 tailles Solo et le seuil de cible, devises, quantités exactes, dates civiles et portions.
7. **B7 — Chemins privilégiés :** inventorier les écritures service/admin, mutations de catalogues et permissions des CHECK privés ; tester les contournements possibles et l'isolation effective entre deux comptes.
8. **B8 — Compte partiellement rempli :** confirmer le traitement conservateur d'un profil contenant seulement un mode, sans introduire fusion ou écrasement automatique.
9. **B9 — Ressources :** mesurer temps/mémoire des grands instantanés, concaténations JSON et encodage ; valider limites, timeouts et protection contre les appels coûteux répétés.

Ajouter aux preuves : imports simultanés, même opération/contenu différent, même origine sous deux comptes, rollback à chaque étape, perte de réponse après COMMIT, récupération du reçu et changement de compte. Le plan détaillé est dans TEST_PLAN.md. Les garanties locales futures de flush, choix de parcours, journal et traitement des callbacks devront être vérifiées sur des données fictives, sans intervenir sur les brouillons Xiaomi.

## 5. Prochaine action autorisable

**Faire une revue indépendante des six fichiers, en lecture seule, avant toute correction ou exécution.** Présenter les erreurs prouvées, risques, incohérences et points non résolus ; demander une autorisation distincte pour les corrections, puis pour les tests sur une base isolée.

Aucun accès distant ou déploiement n'est autorisé par ce rapport, même si de futurs tests isolés réussissent. Ne pas commencer le générateur, l'intégration Flutter, la phase suivante ou une installation Android automatiquement.

Phrase de reprise :

> Reprends Menoo depuis reports/MENOO_CHECKPOINT_J6_PHASE2_20261022.md. Vérifie d'abord Git, puis effectue uniquement une revue indépendante en lecture seule des six fichiers docs/sql-drafts/guest_import_v1/, en les confrontant au contrat V1 et aux sept migrations historiques. Ne modifie rien et n'exécute aucun SQL ni test ; présente tes conclusions et attends mon autorisation.

## 6. Git : dernier état distant confirmé et portée du checkpoint

Avant la création de ce rapport, branche `master`, HEAD local et `refs/heads/master` sur origin vérifiés au même SHA complet : **`e4fd62587e8e770df2adb91343b94d2a65a582c0`**, commit `docs: finalize guest import contract v1`. Vérification distante effective par `git ls-remote origin refs/heads/master` le 22 octobre 2026. Aucun changement concurrent constaté à ce contrôle.

Le nouveau commit documentaire autorisé porte le message `docs: checkpoint guest import phase 2 SQL drafts` et doit contenir exclusivement les six fichiers ci-dessus et ce rapport. Son SHA définitif et la vérification distante après push sont à fournir dans le compte rendu de sauvegarde ; ce fichier ne prétend pas connaître à l'avance son propre SHA ou le succès d'un push encore à effectuer.

Lors de la reprise, retrouver le commit portant ce fichier avec `git log -1 --format=fuller -- reports/MENOO_CHECKPOINT_J6_PHASE2_20261022.md`, puis comparer HEAD à `origin/master` et vérifier le dépôt distant si une connexion est autorisée. Le SHA de base e4fd625 ci-dessus est la référence précédente, pas le SHA du checkpoint qui porte ce rapport.

## 7. Travaux locaux restant hors de la sauvegarde GitHub

État initial relevé avant staging : index vide, cinq fichiers suivis modifiés, 17 suppressions historiques, 3 071 fichiers non suivis dont les six nouveaux brouillons. Le rapport ajoute ensuite un septième chemin à sauvegarder. Après inclusion exclusive des sept chemins, les **3 065 anciens fichiers non suivis** doivent rester hors Git.

Les cinq modifications suivies préexistantes, exclues du checkpoint :

| Fichier | Diff local initial, non sauvegardé par ce checkpoint |
|---|---|
| `PLAN.md` | +25 lignes, passages locaux antérieurs conservés. |
| `DECISIONS.md` | +21 lignes, passages locaux antérieurs conservés. |
| `lib/screens/onboarding/constraints_screen.dart` | +46 / -16 lignes, modifications visuelles locales préexistantes. |
| `lib/screens/onboarding/summary_screen.dart` | +5 / -8 lignes, modifications locales préexistantes. |
| `lib/widgets/toggles.dart` | +3 / -1 ligne, modification locale préexistante. |

Les 17 suppressions historiques sous `design/nouvelles_icones/` restent non préparées dans l'index, sans restauration ni suppression supplémentaire. Les 3 065 anciens fichiers non suivis, notamment des assets, rapports, captures, archives et artefacts locaux, ne sont pas ajoutés globalement et restent non protégés par cette sauvegarde distante. Certains rapports historiques cités peuvent donc n'exister que sur cette machine.

Cette sauvegarde ne publie pas les modifications applicatives locales, ne sauvegarde pas les données Xiaomi et ne constitue pas une sauvegarde complète du dossier de travail. Le compte rendu final doit confirmer par comparaison d'empreintes que les contenus préexistants et les absences historiques sont identiques, et que l'index est vide après commit.

## 8. Limites de l'intervention de fin de session

Préparation documentaire et Git exclusivement. Aucun SQL exécuté, aucune migration Supabase déployée pendant cette session, aucun accès au projet Supabase distant, aucune modification Flutter/SQLite, aucun accès Xiaomi, aucun test/build/installation. L'état distant historique de Supabase n'a pas été audité de nouveau.

Ne pas modifier CLAUDE.md, PLAN.md, DECISIONS.md, le contrat V1 ou les six brouillons pour cette sauvegarde. Aucun reset, clean, stash, force push ou ajout global. Après les contrôles finaux du push et de la conservation des données locales : arrêt de toute opération.
