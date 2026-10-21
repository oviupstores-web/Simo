# PLAN.md — Suivi des jalons Menoo

## 21 octobre 2026 — jalon produit 6, étape 3 locale : saisies provisoires et reprise Réserve

- Formulaires manuels et vérification rapide enregistrés dans une section `pantryForms` version 1 du brouillon chiffré de leur propriétaire (`guest.solo` ou `guest.family`), dans la même transaction que réponses et produits validés. Les brouillons antérieurs sans cette section restent lisibles ; versions inconnues et contenus corrompus sont refusés sans remplacement. Champs compatibles inconnus conservés.
- Saisie manuelle : nom et quantité brute même incomplète, valeur numérique précédente, unité, catégorie/emplacement choisis et proposés, date civile et origine, choix manuels et contexte de champ sont restaurés sans recalcul au chargement. Une quantité brute incomplète n'est pas validée comme produit. Les choix rapides restent provisoires jusqu'au bouton final ; application par lot en une notification, sans suppression pour « Non ».
- Checkpoint de navigation : détour hub, ajout manuel ou vérification rapide, et retour après édition depuis le récapitulatif sont restaurés sur le sous-écran exact. Choix de reprise initiale corrigé : comparer les dates seulement entre parcours encore demandés à la reprise, pour éviter le retour Landing lorsqu'un brouillon Famille plus récent est inactif et Solo encore actif.
- Contrôles locaux sur données fictives : 25 nouveaux tests et 396 régressions ciblées réussis (421 au total), dont stockage chiffré, interruption transactionnelle, cinq langues et 320/390 px. Les débordements révélés sur indice de section, CTA long et badges de vérification rapide ont été corrigés dans ce périmètre. Analyse Dart ciblée sans problème et `git diff --check` réussi.
- Aucune installation Xiaomi, migration réelle, opération Supabase, staging, commit ou push. Clés/base existantes, produits Solo/Famille du téléphone, 50 icônes, images, catalogue, 17 suppressions historiques et autres modifications locales préservés. Validation sur Xiaomi soumise à autorisation distincte ; arrêt après tests locaux.

## 20 octobre 2026 — validation utilisateur du jalon produit 6 et fin de journée

- Modèle et codec Réserve, raccordement de la persistance indépendante Solo/Famille, 480 tests locaux et essais Android du jour validés par l'utilisateur.
- Sauvegarde autorisée uniquement pour les fichiers du jalon 6 et leur documentation. Travaux graphiques antérieurs, archives, rapports techniques, captures, APK et 17 suppressions historiques conservés localement hors de ce commit.
- Aucun nouveau développement ni changement de données Xiaomi. Prochaine action : attendre les instructions de reprise ; aucune autre étape commencée.


## 20 octobre 2026 — jalon produit 6, Réserve contrôlée sur Xiaomi

- Compilation debug réussie (108,4 s), package com.menoo.app et certificat identique vérifiés ; mise à jour adb install -r réussie. UID/date de première installation et 12 empreintes de fichiers conservés avant premier lancement. Anciennes Réserves chargées vides et reconnues, sans écriture en attente, vérifiées avant installation via inspection debug temporaire autorisée.
- Produits fictifs Solo/Famille ajoutés et retrouvés après arrêts forcés ; deux sections indépendantes, identifiants et contenus inchangés. Stock rapide Présent → Quelques restes à identité stable, puis suppression explicite de cette seule ligne fictive, confirmée après relance hors connexion.
- Reprise Famille observée sans réseau ; deux brouillons contrôlés. Réponses et saisies précédentes identiques en fin d'essai, éditions membres inchangées ; mode Famille Courses uniquement rétabli. Stockage sécurisé et préférence linguistique inchangés, réseau restauré ; inspection debug fermée et redirection temporaire retirée.
- Deux produits TEST_SOLO_20261020 et TEST_FAMILLE_20261020 conservés pour validation. Écrans en FR ~393 px ; pas de passage Android 320 px/autres langues. Aucun code, catalogue, image, clé, Supabase ou Git modifié ; 17 suppressions et index vide préservés.
- Rapport : reports/pantry_android_20261020/REPORT.md. Validation technique observée ; validation visuelle utilisateur en attente. Prochaine action : attendre, sans autre intervention.


## 20 octobre 2026 — jalon produit 6, persistance Réserve raccordée localement

- Produits validés raccordés aux sessions et dépôts SQLite chiffrés existants : deux Réserves indépendantes guest.solo / guest.family, lots identifiés une fois, ajouts/modifications/suppressions capturés avec leurs réponses. Le détour et les formulaires incomplets restent inchangés.
- Quantités num conservées sans conversion/arrondi, unités/libellés, foodId, dates civiles et origines, extensions compatibles conservés. Réponses et Réserve écrites dans une transaction ; checkpoint plus ancien refusé. Formats historiques inconnus/corrompus et versions futures refusés sans réinitialisation ni effacement.
- 480 tests finaux réussis : 21 nouveaux tests Réserve, 118 tests codec et 341 non-régressions. Arrêt forcé pendant transaction et lecture par nouveau processus sur bases fictives temporaires validés ; cinq langues couvertes par les régressions Solo/Famille. Analyse ciblée : aucune anomalie.
- Trois références de tests adaptées à la persistance désormais active, versions précédentes archivées. Premiers échecs et journaux conservés ; deux échecs de processus au passage parallèle ne se reproduisent pas au passage séquentiel, cause exacte non établie.
- Catalogue, images, SQLite/chiffrement/clés, Supabase, navigation et onglet Réserve de démonstration inchangés. 579 fichiers préexistants contrôlés : seuls les six fichiers applicatifs et deux tests prévus ont changé ; aucun fichier disparu. Les 17 suppressions historiques et l’index Git vide sont préservés.
- Rapport : reports/pantry_persistence_20261020/REPORT.md. Validation Android non effectuée. Prochaine action : validation utilisateur, puis autorisation distincte avant tout essai Xiaomi. Aucun commit/push, dépendance, migration utilisateur ou installation.


## 20 octobre 2026 — jalon produit 6, raccordement Réserve autorisé

- Étape 2 autorisée : produits validés, identifiants stables, deux Réserves guest.solo/guest.family et écritures atomiques avec leurs réponses. Réutilisation du codec versionné et de SQLite chiffré ; clés inchangées.
- Tests uniquement sur données fictives et bases temporaires. Aucun changement des formulaires incomplets, navigation, onglet Réserve de démonstration, catalogue ou images. Aucun Android, Supabase ou Git.
- Travail en cours ; prochaine action : tests et rapport avant validation utilisateur. Historique conservé.


## 20 octobre 2026 — résultat du codec Réserve isolé

- Nouveau modèle de stockage autonome avec identifiant stable et codec JSON pantryVersion 1, propriétaire Solo/Famille obligatoire, quantités/unités sans conversion, dates civiles et origines conservées, extensions compatibles immuables. PantryDraft et LocalDraft existants inchangés ; aucun branchement.
- Anciens brouillons à Réserve vide reconnus sans mutation. Contenu non vide non versionné, version inconnue ou corruption refusés intact, sans liste vide de remplacement. Aucune migration utilisateur exécutée.
- 118 tests codec finaux et 341 non-régressions distinctes réussis (455 lors du passage groupé, puis quatre cas supplémentaires du codec). Analyse ciblée sans anomalie ; 585 fichiers préexistants vérifiés inchangés. Rapport : reports/pantry_codec_20261020/REPORT.md.
- Les 17 suppressions et autres modifications locales sont préservées. Aucun raccordement aux écrans/sessions/dépôts, chiffrement, clé, dépendance, navigation, Android, Git ou Supabase modifié. Prochaine action : validation avant raccordement au stockage réel.


## 20 octobre 2026 — jalon produit 6, codec Réserve seul autorisé

- Première étape autorisée : identifiants stables et codec versionné autonome, validation complète et tests ; aucun raccordement aux écrans, sessions ou dépôts.
- Deux propriétaires Solo/Famille explicites, quantités/unités sans conversion, dates civiles et origine conservées. Versions inconnues et anciens contenus non identifiables refusés sans écriture.
- Chiffrement, clés, réponses et navigation existants inchangés ; aucune migration réelle, Supabase, installation Android ou opération Git. Prochaine action : résultats techniques puis validation avant raccordement.


## 19 octobre 2026 — validation finale des 50 icônes et clôture

- Collection de 50 PNG premium officiellement validée : traits fins, accents pastel, tailles 32/36 et pastilles décoratives #EAF6EB. Illustrations historiques et états fonctionnels conservés.
- Compilation debug finale réussie (48,5 s), package com.menoo.app et signature identique vérifiés ; mise à jour -r réussie sans désinstallation. Empreintes des données identiques avant/après installation avant lancement. Brouillons Solo et Famille retrouvés, membres et allergies conservés ; bouclier observé dans le récapitulatif Solo et les badges/encart Famille. Aucun nouveau débordement manifeste ni erreur bloquante dans le journal contrôlé. Navigation de contrôle seulement, aucune réponse modifiée.
- Sauvegarde autorisée sur master officiel oviupstores-web/Simo : 50 PNG applicatifs, registre et composants, adaptations des écrans, test premium, pubspec et suivi. Les 50 sources graphiques validées utilisées par les tests de comparaison sont incluses ; variantes, planches, APK et rapports volumineux/personnels restent locaux. Liste exacte locale : reports/final_backup_20261019/commit_manifest.json.
- Les 17 suppressions anciennes sont exclues. Aucun changement métier, stockage, authentification ou Supabase. Défauts connus laissés pour la prochaine session : « 1 ans », connexion IT 320 (14 px), Landing transitoire avant reprise Famille.
- Prochaine action : nouvelle instruction uniquement, après vérification du commit et du push autorisés. Les rapports locaux référencés dans l’historique ne sont pas tous présents sur GitHub.


## 19 octobre 2026 — bouclier premium intégré, validation visuelle en attente

- Proposition shield.png validée ; copie identique ajoutée au registre premium (50 motifs), dix usages de confidentialité/protection convertis à 32/36 px. Deux couvertures Solo/Famille gardent explicitement leur SVG ; captures identiques.
- Aucun PNG existant, donnée, stockage ou logique métier modifié. Lignes de confidentialité connexion/inscription adaptatives ; pastilles décoratives #EAF6EB, fonds fonctionnels conservés.
- Tests après : 200 réussis et un échec déjà présent connexion IT 320 (14 px) ; contrôle allergies supplémentaire 129 réussis et même échec. Analyse sans anomalie. Captures cinq langues à 320/390 et détails disponibles : reports/shield_integration_20261019/REPORT.md.
- 17 suppressions Git préexistantes conservées, index vide. Aucun commit/push, Android ou Supabase. Prochaine action : validation des captures par l’utilisateur, aucune installation autorisée à ce stade.


## 19 octobre 2026 — validation Xiaomi des tailles 32/36 autorisée

- Tailles premium et fond décoratif #EAF6EB validés par l'utilisateur. Compilation debug et mise à jour sans désinstallation autorisées, sous réserve de signature identique et conservation des données.
- Contrôle terminé sans modification de code ni d'illustration : compilation debug réussie (46,4 s), signature identique et mise à jour -r réussie. Empreintes de toutes les données identiques avant/après installation avant lancement ; trois fichiers de préférences inchangés après contrôle. Brouillons Solo/Famille retrouvés ; composition, récapitulatif, membres, gestion et Profil contrôlés, sans débordement manifeste. Choix Famille Courses rétabli après essai Mixte. 17 suppressions Git inchangées et index vide.
- Preuves : reports/premium_icons_size32_android_20261019/REPORT.md, captures et comparaison Xiaomi avant/après. Pastilles #EAF6EB et dessins agrandis observés ; CTA/états sélectionnés et images existantes conservés. Profil Solo laissé ouvert. Aucun commit/push, Supabase ou correctif automatique. Validation finale en attente.


## 19 octobre 2026 — taille premium 32/36 et fond décoratif uniforme

- Demande validée pour préparation locale : dessins premium au minimum 32 px, 36 dans les grands supports/encarts ; pastilles décoratives #EAF6EB via AppColors.mint. Supports et capsules adaptés ; aucune pastille ajoutée aux icônes sans fond.
- CTA, verts sélectionnés, navigation et autres icônes fonctionnelles conservés ; sources des 49 PNG, anciennes images, photos, données et stockage inchangés par empreintes.
- Captures avant/après 320/390 FR/EN/ES/IT/DE, états composants contrôlés. 478 tests réussis / un échec connu connexion IT 320 (14 px), analyse ciblée sans anomalie. Aucun nouveau débordement détecté.
- Rapport : reports/premium_icons_size32_20261019/REPORT.md. Aucun commit/push, Android ou Supabase. Version 32/36 non installée sur Xiaomi ; attente de validation visuelle.


## 19 octobre 2026 — contrôle Xiaomi des icônes autorisé

- Autorisation explicite : compilation debug et mise à jour com.menoo.app sans désinstallation ni effacement. Vérifier signature et conservation des données avant lancement.
- Contrôle visuel uniquement, sans correction du code/design, sans Supabase ou Git. Brouillons Solo/Famille à préserver, sans réinitialisation.
- Compilation debug et installation -r réussies, signature identique. Empreintes des données identiques avant/après installation avant lancement ; Solo et Famille retrouvés. Landing, étapes Solo/Famille, Profil, Gestion et encart Réserve contrôlés en FR ~393 px, sans débordement manifeste. Choix Famille Courses rétabli après essais Réserves/Mixte. Recette non accessible par le parcours actuel, donc non validée sur téléphone. « 1 ans », faible contraste de certains motifs pastel et affichage transitoire Landing avant reprise Famille signalés, sans correction. Sources/illustrations/configuration Android inchangées, aucun Git/Supabase. Rapport : reports/premium_icons_android_20261019/REPORT.md. Validation utilisateur en attente.


## 19 octobre 2026 — SVG secondaires et encart Réserve

- Consigne explicite : inclure l'ancien réfrigérateur de l'encart Onglet Réserve activé et les petits SVG équivalents. Registre complété pour les dessins secondaires de rangement, checklist et couverts ; images PNG/photo existantes conservées.
- Navigation garde son empreinte 26 px en PNG ; autres illustrations au minimum 28 px. Masque blanc sur états demandant du blanc, couleurs originales sur fond clair.
- Huit captures FR 320/390 contrôlées ; 465 tests réussis / un échec connu connexion IT 320 (14 px). Analyse sans anomalie. Assets, données et stockage inchangés ; aucun commit/push ou Android.
- Deux correspondances supplémentaires Activité/Équilibre rejetées par le contrôle automatique et non appliquées ; leurs PNG existants restent affichés. Rapport : reports/premium_icons_secondary_20261019/REPORT.md. Validation visuelle en attente.


## 19 octobre 2026 — règle finale : SVG uniquement, adaptation aux composants

- Nouvelle consigne prioritaire : ne remplacer que les anciens SVG disposant d'un PNG premium exact. Les images/illustrations PNG déjà déclarées et les photos restent affichées ; leur priorité a été rétablie dans IconTile et les allergènes.
- Sur fond vert sélectionné, rendu premium teinté blanc via son masque alpha, sans fond clair supplémentaire. Sur fond clair, couleurs originales. Aucun fichier PNG modifié.
- Huit vues demandées FR 320/390 (Landing, Mode de gestion Solo, Profil, Recette) contrôlées sans débordement. 456 tests réussis / un échec connu connexion IT 320 (14 px), analyse ciblée sans anomalie.
- Stockage et données Solo/Famille, traductions, assets et 17 suppressions préexistantes conservés. Aucun commit/push, Android ou Supabase. Rapport : reports/premium_icons_ui_20261019/REPORT.md. Validation visuelle en attente.


## 19 octobre 2026 — correction du rendu : collection finale exclusivement

- Consigne utilisateur prioritaire : tout emplacement correspondant aux 49 motifs doit afficher le PNG final exact, sans exception de taille ou couleur au profit du SVG. Aucune nouvelle icône, aucun changement métier.
- Reprendre les anciens visuels prioritaires dans les composants lorsqu’une correspondance exacte existe ; conserver les fichiers sources et les fonctions sans équivalent. Adapter localement la disposition si nécessaire.
- Confirmation utilisateur : calendar à quatre cases, comme sur la planche finale. Version deux cases archivée, puis source principale et copie applicative remplacées par la version quatre cases existante.
- Contrôles terminés : 207 emplacements/scénarios en PNG, 49 motifs observés, zéro SVG pour les 49 constantes ; 140 captures FR/EN/ES/IT/DE 320/390. 675 tests réussis / un échec historique connexion IT 320 (14 px), puis dernier contrôle premium+rendus 455 réussites / même échec. Calendar quatre cases confirmé ; 48 autres PNG applicatifs inchangés. Correspondances supplémentaires des autres dessins Réserve refusées par le contrôle automatique, donc non appliquées. Données/stockage/langues, anciens fichiers et 17 suppressions préservés ; index vide, aucun commit/push, Android ou Supabase. Rapport : reports/premium_icons_strict_20261019/REPORT.md. Validation utilisateur en attente.

## 19 octobre 2026 — 49 icônes premium intégrées, validation utilisateur en attente

- Collection finale validée au trait fin ; calendrier à deux cases et Réserve agrandie finalisés.
- Périmètre : copies dédiées, correspondance SVG/PNG, adaptation locale à 28 px et contrôles FR/EN/ES/IT/DE à 320/390 px. Préserver les 23 PNG existants, les icônes fonctionnelles et le stockage Solo/Famille.
- Petits emplacements ou contraste incompatibles : conserver provisoirement le SVG et les signaler. Alias pantryReserve/managementPantry traité explicitement.
- Aucun Supabase, commit/push, nettoyage Git ni installation Android. Les 17 suppressions locales restent intactes. Validation visuelle de cette intervention en attente ; anciens bilans conservés.
- Résultat : 49 copies dédiées, correspondance explicite et repli SVG. 173 emplacements/scénarios convertis, 46 motifs observés dans les écrans ; 14 emplacements restent en SVG. Minimum 28 px pour les PNG, couleurs et proportions conservées.
- Contrôles : matrice 5 langues × 320/390 px = 399 réussites / 1 débordement sur connexion IT 320 hors conversions ; 57 tests premium réussis ; 277 régressions finales réussies, dont Solo/Famille et interruptions hors connexion. Suite complète : 1 556 réussites / 11 écarts aux références visuelles historiques, non remplacées. Analyse finale lib et test premium sans anomalie.
- Intégrité : 292 anciens assets, 49 sources design et 33 fichiers de données/stockage/traductions inchangés. Les 17 suppressions locales et l’index sont préservés. HEAD reste 5ee6c6564595851d6e1e2b308d39a9fb4d9ba0f9.
- Rapport et preuves : reports/premium_icons_20261019/REPORT.md, FILES.md et captures/. Le jalon produit 6 reste en cours ; aucun travail métier supplémentaire.
- Prochaine action : validation utilisateur des captures et des exceptions SVG ; aucune installation Android ou sauvegarde Git sans autorisation supplémentaire.

## État de reprise — 15 octobre 2026 — jalon produit 6

- **Solo : validé sur Xiaomi**, 11 étapes raccordées au stockage SQLite chiffré ; sauvegarde progressive, saisies incomplètes et restauration après fermeture forcée et hors connexion vérifiées.
- **Famille : validé sur Xiaomi**, 9 étapes raccordées au même socle, brouillon indépendant de Solo ; membres, allergies, budget/devise, éditions et reprise vérifiés. L'intégration Famille totalise **505 tests PC réussis** ; ce nombre ne désigne pas une nouvelle suite exécutée le 15 octobre.
- **Icônes : 17 remplacements validés**, sources conservées dans `design/nouvelles_icones`, copies PNG RGBA transparentes optimisées à 256 × 256 dans les chemins existants. **124 tests réussis** (dont les rendus des cinq langues à 320/390 px) et contrôle Xiaomi du 15 octobre, en français à environ 393 px. Signature identique et base chiffrée conservée à l'installation ; Solo/Famille retrouvés. Rapports : `reports/icons_20261015/REPORT.md` et `reports/icons_20261015/android/REPORT.md`.
- **Restent à faire :** six icônes sans nouvelle source (Sans porc, Sans lactose, Sans gluten, Calories et macros calculés, Adapté à votre temps, Zéro gaspillage) ; raccordement Réserve au stockage chiffré ; correction autorisée séparément du libellé « 1 ans » ; contrôle Android réel à 320 px. Aucun de ces travaux n'est commencé par cette actualisation.
- **Supabase :** audit distant validé, corrections obligatoires toujours non appliquées avant toute connexion métier : permissions SQL, relations entre foyers, confidentialité des recettes non publiées et de leurs détails, validation métier serveur. Authentification métier, transfert distant et génération des menus ne sont pas déclarés terminés.
- Le jalon produit 6 reste **en cours** ; la phase corrective 6B reste distincte. Les validations du stockage et des icônes ne valent pas validation de toutes les fonctionnalités de Menoo.
- **Prochaine action :** présenter l'audit Git et la liste explicite des fichiers proposés pour sauvegarde, puis attendre l'autorisation avant tout ajout à l'index, commit ou push. Aucun nouveau développement, nettoyage ou installation autorisé par cette mise à jour documentaire.

### Préparation de sauvegarde Git — audit du 15 octobre 2026, aucune sauvegarde exécutée

- Branche `master`, HEAD `488ee2314dfdd4b38d47ab418bf49036820ee4d8`, suivi local `origin/master` au même commit (0/0). Aucun accès distant/fetch : cela ne certifie pas l'état du serveur à cet instant. Index vide.
- Inventaire Git : 37 fichiers suivis modifiés, aucun ajout/suppression indexé, 920 fichiers non suivis (~307,5 Mo), 5 332 fichiers ignorés signalés. Git avertit de chemins trop longs dans les caches du projet technique ; le nombre ignoré est celui retourné par Git, pas une certification exhaustive du disque.
- Les 13 nouveaux fichiers Dart de stockage/navigation sont importés par l'application : les oublier produirait une sauvegarde incomplète. Les cinq ARB n'ajoutent que deux messages d'erreur ; les dépendances et le hook sqlite3mc doivent accompagner le code. La Landing et la persistance des cinq langues de référence sont déjà dans HEAD.
- Verrou de dépendances examiné : six dépendances directes/de développement ajoutées avec leurs dépendances transitives, aucune suppression de paquet ; `meta` passe de 1.18.3 à 1.19.0. `pubspec.yaml` et `pubspec.lock` doivent être conservés ensemble. Aucun paquet installé ou mis à jour pendant cet audit ; les nombres de tests cités restent ceux des validations précédentes.
- Contrôles en lecture seule : différences de code/configuration examinées, imports locaux non suivis identifiés, scan de signatures de secrets sans alerte sur les fichiers proposés, aucun fichier de base/clé privée repéré par son nom parmi les suivis/non suivis. Les clés synthétiques de tests ne sont pas des clés du téléphone. Ce scan n'est pas une preuve mathématique d'absence de secret. Aucune clé du téléphone ni aucun brouillon exporté pour cet audit.
- **Confidentialité à arbitrer avant commit :** des entrées historiques de `PLAN.md` contiennent l'identifiant technique unique du téléphone. Il n'est pas recopié dans cette actualisation, mais reste dans le fichier afin de préserver intégralement l'historique demandé. Ce n'est pas un secret d'authentification ; c'est néanmoins une information identifiante. Ne pas présenter le fichier entier comme dépourvu de telles informations. Toute anonymisation ou exclusion différente doit être autorisée ; aucun effacement d'historique réalisé.
- `.gitignore` reste intact. Les fichiers locaux ignorés, notamment `local.properties`, APK, caches et sorties générées, ne sont pas proposés. Aucune référence visuelle historique à remplacer. Avertissements LF/CRLF observés ; `git diff --check` sans erreur.
- Proposition : un commit fonctionnel atomique de **59 fichiers** ci-dessous, puis un commit d'archivage des **17 sources validées**. Aucun git add/commit/push exécuté. Les listes sont explicites ; ne pas employer d'ajout global ou de joker récursif.

Fichiers proposés pour le commit fonctionnel (chemins relatifs à la racine) :

```text
DECISIONS.md
PLAN.md
android/app/src/main/AndroidManifest.xml
android/app/src/main/res/xml/draft_backup_rules.xml
android/app/src/main/res/xml/draft_data_extraction_rules.xml
assets/images/new_icons/activity_desk.png
assets/images/new_icons/activity_run.png
assets/images/new_icons/activity_training.png
assets/images/new_icons/activity_walk.png
assets/images/new_icons/diet_omnivore.png
assets/images/new_icons/diet_pescatarian.png
assets/images/new_icons/diet_vegan.png
assets/images/new_icons/diet_vegetarian.png
assets/images/new_icons/goal_balance.png
assets/images/new_icons/goal_definition.png
assets/images/new_icons/goal_gain.png
assets/images/new_icons/goal_loss.png
assets/images/new_icons/management_mixed.png
assets/images/new_icons/management_pantry.png
assets/images/new_icons/management_shopping.png
assets/images/new_icons/pantry_quick_check.png
assets/images/new_icons/pantry_reserve.png
lib/l10n/app_de.arb
lib/l10n/app_en.arb
lib/l10n/app_es.arb
lib/l10n/app_fr.arb
lib/l10n/app_it.arb
lib/local_storage/android_draft_storage.dart
lib/local_storage/draft_checkpoint_clock.dart
lib/local_storage/draft_database.dart
lib/local_storage/draft_key.dart
lib/local_storage/draft_key_store.dart
lib/local_storage/family_draft_repository.dart
lib/local_storage/local_draft.dart
lib/local_storage/shared_draft_database.dart
lib/local_storage/solo_draft_repository.dart
lib/main.dart
lib/onboarding/family_draft_navigation.dart
lib/onboarding/family_draft_session.dart
lib/onboarding/onboarding_data.dart
lib/onboarding/onboarding_flow.dart
lib/onboarding/onboarding_scope.dart
lib/onboarding/solo_draft_navigation.dart
lib/onboarding/solo_draft_session.dart
lib/screens/entry/startup_screen.dart
lib/screens/onboarding/budget_screen.dart
lib/screens/onboarding/constraints_screen.dart
lib/screens/onboarding/member_profiles_screen.dart
lib/screens/onboarding/profile_screen.dart
pubspec.lock
pubspec.yaml
test/family_draft_persistence_test.dart
test/i18n_test.dart
test/local_storage_foundation_test.dart
test/solo_draft_persistence_test.dart
test/support/draft_process_probe.dart
test/support/family_draft_process_probe.dart
test/support/solo_draft_process_probe.dart
reports/icons_20261015/render_test.dart
```

Sources proposées pour un commit d'archivage distinct (~28,48 Mo), sans inclure les anciennes sources déjà suivies ni générer de doublons :

```text
design/nouvelles_icones/actif.png
design/nouvelles_icones/courses uniquement.png
design/nouvelles_icones/ma reserve.png
design/nouvelles_icones/maintien et équilibre.png
design/nouvelles_icones/mixte.png
design/nouvelles_icones/modéré.png
design/nouvelles_icones/omnivore.png
design/nouvelles_icones/perte de poids.png
design/nouvelles_icones/pescétarien.png
design/nouvelles_icones/prise de masse.png
design/nouvelles_icones/reserve uniquement.png
design/nouvelles_icones/sèche et définition.png
design/nouvelles_icones/sédentaire .png
design/nouvelles_icones/tres actif.png
design/nouvelles_icones/végan.png
design/nouvelles_icones/végétarien.png
design/nouvelles_icones/vérification rapide.png
```

Exclusions du futur commit, sans suppression locale :

- Tous les autres fichiers `reports/` : captures Android/Flutter, XML/JSON de contrôles, empreintes, logs, APK, ZIP, anciens essais et copies de code ; seule exception proposée ci-dessus : le pilote reproductible `reports/icons_20261015/render_test.dart`. Les comptes rendus courts restent locaux également pour éviter d'inclure les identifiants du téléphone et les détails des données de test. Leurs conclusions validées sont sauvegardées dans les documents officiels ; les liens vers les preuves locales ne deviendront pas tous disponibles sur le dépôt distant.
- Les 16 PNG non suivis de `assets/images/landing/` : aucune référence directe à leurs chemins dans le code actuel ; versions intermédiaires/variantes, non nécessaires aux visuels référencés. Le dossier complet est déclaré dans pubspec : ces fichiers locaux peuvent être embarqués par une compilation locale même sans usage ; exclusion Git proposée, sans modification du packaging ou suppression ici.
- Tout `tools/storage_android_probe/` : application technique isolée et fichiers générés, non requis par Menoo. Une archive de ses seules sources pourrait faire l'objet d'une sélection séparée après validation ; aucun dossier complet à ajouter.
- Tous les fichiers ignorés : `build/`, `.dart_tool/`, `.gradle/`, sorties de plugins/localisations, configurations machine, APK/AAB, échecs visuels et logs. Aucun forçage d'ajout des ignorés.
- Toute future base, clé, export de brouillon, capture personnelle ou donnée sensible, même si non couverte par les règles actuelles. Aucun assouplissement de ces règles n'est proposé.

Doublons : 17 groupes d'images/ZIP non suivis ont la même empreinte, notamment les captures FR/DE 320/390 recopiées dans plusieurs rapports. Le ZIP de prévisualisation fait ~11,56 Mo ; les APK ignorés de contrôle font ~209 à 249 Mo. Ces fichiers sont conservés sur disque, exclus de la proposition. Aucune déduplication effectuée.

Avant exécution future : obtenir l'autorisation explicite, relire l'état Git et les listes, ajouter uniquement les chemins approuvés, vérifier le diff indexé (y compris binaires, tailles et secrets), créer les commits autorisés, puis pousser seulement après autorisation et vérifier le résultat. Aucune validation d'une publication Android ou d'une connexion Supabase n'est déduite de cette proposition.

### Historique des contrôles et réalisations du 14 octobre 2026

Les bilans suivants sont conservés intégralement dans leur état daté. Leurs mentions « en attente », « non connecté » ou « non testé » décrivent leur instant de rédaction ; l'état de reprise du 15 octobre ci-dessus prévaut pour le statut actuel.

### Contrôle Android Famille — 14 octobre 2026, résultat en attente de validation

- Compilation ARM64 debug et installation de mise à jour autorisées réussies sur Xiaomi 2201117PG (Android 13). Signature identique ; base chiffrée strictement identique avant/après installation, avant lancement ; UID et répertoire de données conservés. Aucun effacement ou suppression de brouillon.
- Neuf étapes Famille parcourues jusqu'au récapitulatif, deux membres de démonstration modifiés en fictifs et deux membres fictifs ajoutés, allergies individuelles conservées. Fiche incomplète, ajout non validé, budget incomplet et édition depuis le récapitulatif restaurés après arrêts forcés ; reprises hors connexion au budget et au récapitulatif, dont absence de réseau par défaut confirmée.
- Indépendance visible des réponses vérifiée dans les deux sens : Solo 38/180/75, 21 repas, 385 EUR, Sans gluten, Italienne, Blender ; Famille six personnes, 14 repas, 450 EUR, Sans lactose, Méditerranéenne, Air fryer, TestMaman responsable. Aucun raccordement Réserve ni opération Supabase.
- Français à environ 393 px contrôlé ; aucun débordement manifeste dans les captures examinées. Libellé « 1 ans » relevé pour le bébé, non corrigé. Identifiants internes non inspectés directement sur le téléphone ; contrôle direct de cinq langues/320 px non rejoué ici.
- Téléphone laissé sur Famille 9/9, Wi-Fi rétabli, données mobiles inchangées. Les deux brouillons fictifs restent conservés. Aucun fichier applicatif/design/traduction/dépendance modifié, aucun commit/push. Rapport et preuves : `reports/family_android/REPORT.md`. Attendre la validation avant toute suite du jalon produit 6 ; anciens bilans ci-dessous conservés.

### Brouillons Solo et Famille — résultat technique actuel

- Les contrôles Android Solo ont été validés. Le brouillon fictif Solo du téléphone reste conservé : aucune suppression ciblée ni installation réalisée pendant cette intervention.
- Raccordement autorisé et réalisé des neuf étapes Famille à `guest.family`, distinct de `guest.solo`, avec une connexion chiffrée unique et un verrou unique. Enveloppe et schéma existants version 1 conservés ; section Famille version 1 et règles de portions version 1. Sources acceptées, champs bruts et fiches membres de travail séparés ; identifiants et prochain identifiant conservés.
- Reprise après le splash, y compris fiche membre ouverte et édition depuis le récapitulatif. Le dernier parcours enregistré est choisi sans réécrire le brouillon de l'autre parcours ; ordre des checkpoints protégé contre un recul de l'horloge. Aucune individualisation des régimes/préférences ni activation d'objectifs physiques Famille.
- Tests sur PC : 87 nouveaux contrôles Famille, 88 contrôles Solo et 330 régressions existantes réussis (505 contrôles distincts). Base native chiffrée sur les neuf étapes, interruption forcée d'une transaction et restauration dans un nouveau processus, saisies réelles, cinq langues, erreurs, devises et indépendance des enregistrements. Analyse statique ciblée et contrôle de diff sans erreur. Aucune nouvelle référence visuelle créée.
- Réserve non connectée : une interruption de son détour reprend au mode de gestion, sans persistance des produits de ce détour ; éventuelles données pantry déjà enregistrées conservées sans raccordement. Android Famille non testé : aucune compilation APK ni installation. Pas de Supabase, nouvelle dépendance, commit/push ou nettoyage.
- Rapport et liste exacte des fichiers : `reports/family_draft/REPORT.md`. Arrêt après cette intégration ; validation et toute installation Android attendues. Les bilans Solo et anciens états ci-dessous sont historiques et restent intégralement conservés. Phase corrective 6B distincte et inchangée.

### Brouillon Solo connecté — résultat technique, validation Android en attente

- Branchement autorisé du seul onboarding Solo (11 étapes) au socle SQLite chiffré. Sources acceptées et saisies brutes séparées ; étape et pile de retour conservées ; reprise après le splash, sans changement de sa séquence ni du design. Deux messages d'erreur traduits autorisés séparément, affichés dans l'alerte existante.
- Tests finaux sur PC : 88 nouveaux contrôles Solo réussis (87 ensemble et un contrôle ciblé du détour Réserve), dont les onze écrans dans les cinq langues, erreurs de stockage, champs incomplets, devise et restauration multi-processus après interruption forcée. 272 tests existants de régression réussis ; analyse ciblée sans problème et diff check réussi. Disque plein lors d'une relance intermédiaire, contourné par les tests en série sans nettoyage des fichiers.
- Famille non connectée : identifiant indépendant réservé, fichiers exclusifs inchangés et données Famille témoins préservées. Un brouillon Solo inactif ne préremplit pas Famille. Réserve inchangée : une interruption du détour reprend à l'étape Solo « Mode de gestion » ; les produits de ce détour ne sont pas encore persistés et son branchement reste soumis à autorisation distincte.
- Aucun fichier asset/thème/Landing/Android/Supabase modifié pendant cette intervention, aucune nouvelle dépendance, aucun test historique supprimé/modifié, aucun ancien fichier non suivi supprimé. L'application technique Android a été désinstallée avec succès lors du nettoyage précédemment autorisé ; Menoo et ses données ont été préservés.
- Rapport : `reports/solo_draft/REPORT.md`. Aucun APK compilé ou installé pour l'intégration Solo actuelle ; contrôle réel sur Xiaomi et toute suite du jalon produit 6 en attente de validation. Les états antérieurs « aucun onboarding connecté » ci-dessous restent historiques. Phase corrective 6B inchangée et distincte.

### Validation Android du socle chiffré — résultat courant

- Validation technique effectuée après autorisation sur Xiaomi 2201117PG, Android 13, avec une application isolée `com.menoo.storageprobe` et des données fictives. Installation de Menoo existante, signature et données conservées ; seul le paquet technique a été installé.
- Compilations ARM64 debug du test et de Menoo réussies. Même bibliothèque sqlite3mc dans les deux APK ; APK Menoo inspecté mais non installé. Clé protégée par Android Keystore matériel, non exportable ; chiffrement effectif et lecture sans clé refusée vérifiés.
- Création/lecture exactes Solo/Famille et Réserve, fermeture forcée et restauration dans de nouveaux processus réussies ; interruption d'une transaction restaure le dernier brouillon validé. Test sans permission INTERNET, sans changement des réseaux du téléphone. Mauvaise clé et clé indisponible simulée : refus sans effacement et restauration finale exacte.
- Exclusions de la base et de ses clés vérifiées dans le manifeste fusionné et les ressources compilées de Menoo. Métadonnées d'algorithmes non secrètes du plugin non exclues ; aucun backup cloud ou transfert réel déclenché. Rapport : `reports/local_draft_foundation/ANDROID_REPORT.md`.
- 430 empreintes applicatives/Android/assets/Supabase identiques ; aucun ancien fichier non suivi supprimé. Seuls projet technique, preuves et suivi documentaire ajoutés. Aucun onboarding branché, aucun design/langue/navigation/Supabase modifié, aucun commit/push. Suite du jalon produit 6 en attente de validation ; états antérieurs ci-dessous conservés comme historique.

### Résultat courant du socle local chiffré — 14 octobre 2026

- Moteur officiel sqlite3mc téléchargé après autorisation ; dépendances existantes réutilisées sans changement de version. Socle implémenté sans branchement aux écrans ou au démarrage.
- Tests techniques sur PC : 13 réussites, 0 échec, dont chiffrement réel, refus des bases en clair/clés perdues et restauration dans un nouveau processus après interruption forcée d'une transaction. Contrôle combiné avec langues/i18n/parcours Solo-Famille : 28 réussites, 0 échec. Fausses alertes du détecteur i18n sur les commandes SQL déclarées précisément, sans exclusion de dossier ou modification des traductions.
- Analyse ciblée sans erreur du socle ; analyse globale non verte (1 110 diagnostics incluant les archives locales sous reports/, conservées hors périmètre). Aucun nettoyage automatique.
- Android : configuration de clé sécurisée et exclusions de sauvegarde présentes, mais Keystore physique, APK et restauration sur téléphone non validés. Installation et intégration aux onboardings en attente de validation.
- Rapport : `reports/local_draft_foundation/REPORT.md`. Les états « non implémenté » et « tests en attente » ci-dessous sont conservés comme historique avant cette réalisation. Aucun écran, design, langue, navigation ou SQL Supabase modifié ; aucun commit, push ou installation Android.

### Socle local chiffré — développement autorisé, validation technique en attente

- Reprise limitée autorisée : code ajouté dans `lib/local_storage/`, sans branchement à `main.dart`, Solo, Famille ou Réserve. Le hook officiel `sqlite3mc` est configuré avec les dépendances existantes, sans réinstallation ni changement de version.
- Enveloppe JSON version 1, parcours et étape, modes de gestion, devise explicite, réponses et Réserve conservées ; clé aléatoire de 256 bits protégée par `flutter_secure_storage` sur Android, namespace dédié et réinitialisation automatique désactivée.
- Ouverture refusée sans moteur chiffré, avec une base en clair, une clé absente/invalide, un format inconnu ou des journaux orphelins. Aucun effacement ou repli automatique. Transactions Drift et verrouillage ; exclusions de la base et de sa clé pour sauvegarde cloud et transfert Android.
- Analyse statique ciblée : aucune erreur. Treize tests écrits, dont chiffrement natif, restauration dans un nouveau processus après interruption forcée et annulation transactionnelle ; ils ne sont pas encore exécutés. L'autorisation du téléchargement éventuel du moteur par la commande de tests est en attente. La vérification physique du stockage sécurisé et de la restauration Android reste à faire après autorisation distincte d'installation.
- Aucun écran, design, langue, navigation ou fichier Supabase modifié ; aucun commit, push ou installation. Les paragraphes d'audit ci-dessous décrivent l'état avant cette reprise ; les fonctionnalités écrites restent non validées tant que leurs tests ne sont pas exécutés.

Cette entrée constitue l'état courant de reprise. Les décisions et bilans datés ci-dessous sont conservés intégralement comme historique ; leurs statuts ne doivent pas être confondus avec l'état présent. Aucune nouvelle numérotation de phases ou de sous-phases n'est créée.

### Audit Supabase validé et corrections obligatoires

- Projet distant officiel confirmé : `menoo-dev` (`pqdreuptzhenowqucvbl`). Audit réalisé en lecture seule : aucune migration, insertion, suppression ou modification Auth appliquée.
- Les sept migrations locales et distantes concordent. Les 28 tables, colonnes, types, contraintes, relations, politiques RLS, permissions des rôles et paramètres Auth ont été examinés. La présence des tables et des politiques ne prouve pas une connexion métier opérationnelle dans Flutter.
- Corrections obligatoires avant toute connexion métier Flutter ↔ Supabase : permissions SQL des rôles (droits métier manquants et privilèges excessifs), cohérence des relations entre foyers, confidentialité des recettes non publiées et de leurs détails, validation métier côté serveur. Elles restent identifiées, non appliquées ; les anciennes migrations sont conservées intactes.
- Auth observée pendant l'audit : connexion par email activée avec confirmation ; téléphone, Google, Apple et comptes anonymes désactivés. La configuration de retour vers l'application et les exigences de sécurité devront être préparées avant une authentification mobile réelle. Aucun secret ni donnée personnelle n'est consigné ici.

### Architecture validée et état réellement implémenté

- Architecture cible : invité entièrement local, brouillon durable chiffré et reprise hors connexion pour Solo (11 étapes) et Famille (9 étapes). Courses, Réserve et Mixte restent des modes de gestion ; Famille ne comporte aucun objectif de perte de poids ou de prise de masse.
- Le brouillon doit conserver parcours, étape courante, réponses, préférences, allergies, exclusions, équipements, budget et devise, composition du foyer, portions, produits de Réserve avec quantités/unités/dates/emplacements, version du format et état de synchronisation.
- Dépendances installées et conservées : `drift 2.35.2`, `sqlite3 3.7.1`, `flutter_secure_storage 11.2.0`, `path_provider 2.1.6`, `drift_dev 2.35.1`, `build_runner 2.16.2`. Leur intégration est suspendue. Le moteur `sqlite3mc` n'est pas encore configuré ni testé.
- Aucune base locale chiffrée, clé sécurisée, sauvegarde durable du brouillon, restauration ou connexion des écrans au stockage n'est implémentée. Les réponses d'onboarding restent en mémoire. `shared_preferences` reste réservé à la langue.
- L'authentification réelle, le transfert vers Supabase et la génération des menus sous budget et contraintes ne sont pas opérationnels. L'audit terminé et l'architecture validée ne constituent pas une validation de ces fonctionnalités.

| Travail restant au jalon produit 6 | État réel | Condition de reprise |
|---|---|---|
| Socle local chiffré : clé, format versionné, transactions, restauration et exclusions des sauvegardes Android | Dépendances présentes ; intégration suspendue | En attente de validation |
| Branchement Solo/Famille et Réserve ; reprise exacte après fermeture forcée et redémarrage hors connexion | Non implémenté | Socle vérifié, puis en attente de validation |
| Permissions SQL, relations entre foyers, confidentialité et validation serveur | Écarts audités ; aucune correction appliquée | Proposition de nouvelles migrations, en attente de validation |
| Inscription et transfert transactionnel sans doublons ni écrasement silencieux | Non implémentés | Sécurité distante corrigée et tests validés ; en attente de validation |
| Catalogue compatible et génération des menus sous budget, allergies, préférences, portions et équipements | Non opérationnels | Données compatibles et chaîne fonctionnelle testée ; en attente de validation |

### Phase corrective 6B — périmètre distinct

La phase corrective 6B demeure séparée du jalon produit 6. Le diagnostic 6A est terminé ; les références visuelles historiques et divergences documentaires restant ouvertes sont à examiner dans leur périmètre, en attente de validation. La consolidation documentaire et des tests réalisée le 13 octobre est conservée sans déclarer automatiquement toute la phase 6B terminée. Cette phase ne comprend ni stockage, ni authentification, ni génération des menus et n'autorise aucune modification automatique de la Landing validée.

**Arrêt :** seule cette mise à jour documentaire est autorisée. La reprise du développement du jalon produit 6 est en attente de validation. Aucun code, SQL, dépendance, design, traduction, commit, push ou installation Android n'est modifié par ce jalon documentaire.


## État final validé — 13 octobre 2026, arrêt de la journée

- Landing et cinq langues FR/EN/ES/IT/DE validées sur le Xiaomi 2201117PG ; compilation et installation debug réussies.
- Sauvegarde de chacune des cinq langues confirmée par fermeture forcée et relance sur Android. Application laissée sur la Landing française.
- Landing complète et présentations Solo/Famille contrôlées dans les cinq langues, sans débordement de texte/CTA observé sur environ 393 px logiques. Les formulaires complets n'ont pas été rejoués.
- Les chevauchements du héros à 320 px issus des captures Flutter restent à arbitrer ; aucune correction automatique. Les 11 écarts visuels historiques hors Landing restent ouverts.
- Simo autorise la sauvegarde Git finale des modifications validées et l'arrêt. Les essais, journaux volumineux et ressources non validées restent uniquement locaux.
- Aucun travail Supabase commencé. Attendre les prochaines instructions ; ne pas reprendre l'étape 2 automatiquement.


## État de reprise prioritaire — 13 octobre 2026, étape 1

L'utilisateur autorise uniquement la consolidation des tests et de la documentation. Landing installée (icônes de bénéfices échelle 1,45), conservée comme référence **provisoire**. Aucun changement de code applicatif, PNG, règles métier, installation, commit/push ou Supabase dans cette étape. Les bilans datés ci-dessous restent historiques et ne constituent pas le résultat courant des tests.

Référence : [reports/step1_landing_review/REFERENCE.md](reports/step1_landing_review/REFERENCE.md). Rapport et preuves : [reports/step1_landing_review/REPORT.md](reports/step1_landing_review/REPORT.md). L'étape 2 reste soumise à validation après ce rapport. Ne pas confondre les phases de correction 6A/6B/7 et les jalons produit de génération/IA/paywall.


### Bilan de l'étape 1 terminée

- Documentation et tests consolidés, historique conservé ; application et ressources identiques (398 empreintes).
- Ciblés : 51 réussites ; suite complète : 1 214 réussites et 15 échecs hors Landing (11 écarts de références à diagnostiquer, 4 débordements ES/IT réels).
- Captures complètes FR/DE/EN à 320/390 enregistrées ; chevauchement du héros anglais à 320 signalé sans correction.
- Aucun travail Supabase, aucune installation, aucun commit/push. Arrêt pour validation avant étape 2.

## Fin de session — 9 octobre 2026 — état de reprise prioritaire

Cet état remplace les bilans intermédiaires historiques ci-dessous pour la reprise.

- Phases 1, 2, 3, 4, 4 bis et 5 : terminées dans leurs périmètres validés.
- Phase 6A : diagnostic visuel et documentaire terminé ; rapport conservé. Phase 6B : non commencée. Phase 7 : non commencée.
- Les 23 nouvelles icônes 3D sont intégrées ; copies PNG RGBA transparentes, originaux intacts. Pastilles agrandies : Objectif/Activité/Gestion/couverture Solo et Zéro gaspillage Famille à 64 px avec images de 60 px ; régimes/restrictions à 48/44 px ; Vérification rapide à 56/52 px. « Ma réserve » reste à 56/52 px conformément à la demande de Simo.
- Dimensions provisoirement validées par Simo. **Validation personnelle du rendu sur Xiaomi : retour utilisateur encore attendu**, ne pas la déclarer terminée.
- **Installation Android effectuée et prouvée le 9 octobre 2026** sur le seul appareil ADB Xiaomi autorise, Xiaomi 2201117PG. Compilation debug des modifications locales réussie ; les 23 assets RGBA de l'APK sont identiques aux copies locales. `adb install -r` : `Success`, sans désinstallation ni effacement des données. Identifiant `com.menoo.app` et configuration de signature debug inchangés.
- Dernier lancement vérifié : `am start -W` → `Status: ok`, activité `com.menoo.app/.MainActivity`, processus 16704 toujours actif et application au premier plan. Aucun crash ni erreur Flutter bloquante observé dans ce contrôle de démarrage ; messages Android/Xiaomi non bloquants présents. Aucune capture automatique du téléphone.
- Dernier bilan de tests : **935 réussites et 17 échecs identifiés**, soit 13 Golden historiques et 4 débordements de couverture ES/IT à 320 px. Aucun nouvel échec lié à l'agrandissement ; 114 tests ciblés réussis. `flutter analyze --no-pub` sans problème ; `git diff --check` réussi. Tests non relancés pour cette sauvegarde.
- Rapports actuels : `reports/AGRANDISSEMENT_PASTILLES_3D.md`, `reports/CORRECTION_ICONES_3D.md`, `reports/PHASE6A_DIAGNOSTIC_VISUEL_DOCUMENTAIRE.md`.
- Git : branche `master`, dernier commit `4f569a0`. Corrections locales, tests, documentation, assets et originaux encore non commités. Les six images provisoires non suivies de `assets/images/landing/` restent locales ; elles sont incluses dans la sauvegarde complète, sans ajout à Git.
- Sauvegarde de fin de session : copie complète distincte hors du projet, incluant `.git`, les fichiers ignorés, tous les assets et modifications locales ; emplacement et contrôle SHA-256 consignés dans le rapport de sauvegarde externe et la réponse de fin de session. Aucun commit ni push.

### Prochaine intervention

1. Recueillir le retour visuel de Simo sur la version déjà installée : Objectif, Activité, Gestion, couvertures Solo/Famille, contraintes alimentaires et Réserve. Ne pas réinstaller automatiquement ; si une nouvelle installation devient nécessaire, obtenir une nouvelle autorisation.
2. Reprendre la phase 6B uniquement après validation et autorisation explicites.
3. Réserver la phase 7 pour la suite, sans l'anticiper.

Session arrêtée à la demande de Simo. Aucune modification de code applicatif, image, Supabase, installation Android ou nouvelle phase pendant la sauvegarde.

## Intégration des 23 icônes — 2026-10-09

- Affectations finales autorisées : quatre objectifs Solo, quatre activités Solo, trois modes de gestion Solo/Famille, trois avantages Solo, Zéro gaspillage Famille, sept régimes/restrictions, deux cartes du hub Réserve. Ma réserve et Réserves uniquement distincts. Aucun allergène, autre pictogramme familial ou navigation basse remplacé.
- 23 originaux conservés ; copies PNG RGB 256 px dans assets/images/new_icons/. 41 059 971 → 2 131 899 octets (−94,81 %). Fonds opaques conservés faute de détourage garanti ; cadres clairs visibles à valider.
- Tailles existantes conservées : 40 px Objectif/Activité/régimes, 36 Gestion/avantages Solo, 28 Zéro gaspillage Famille, 26/24 hub. ChoiceCard reçoit un paramètre de taille optionnel, défaut 40 inchangé ; Gestion utilise 36.
- 90 rendus avant réussis ; 113 contrôles ciblés après réussis. Dix comparatifs et planche des tailles dans reports/INTEGRATION_23_ICONES.md. Suite complète : **934 réussites / 17 échecs préexistants / 0 ignoré** ; analyse et diff check sans problème. Références Golden non modifiées.
- Phases 1–5 conservées. Aucune correction 6B/7, nouveau dessin, suppression d’ancienne icône, changement métier, commit/push, Supabase ou installation. Arrêt et validation visuelle attendue.

## Corrections après audit — 2026-10-09

Mission validée par Simo : sept phases successives, validation entre chaque phase.
Aucune installation Android, intervention Supabase, suppression, commit ou push sans accord.

| Phase | Périmètre | Statut |
|---|---|---|
| 1 | B01/B02/B03 : noms, cuisinier principal et limites familiales | Validée techniquement par Simo ; corrections conservées |
| 2 | R01 : entrées numériques, calculs et dates | R01 conservé ; Solo 18+ et Famille sans transformation appliqués ; autres propositions scientifiques en attente |
| 3 | B04/B05/B06/B07 et R02 : Réserve et calendrier | Résultats validés par Simo dans le périmètre testé ; corrections conservées |
| 4 | B08/B09/B10 : formats régionaux | Terminée selon Simo ; corrections conservées |
| 4 bis | Restructuration de l’étape 8 « Contraintes alimentaires » | Corrections autorisées appliquées ; 65 tests ciblés réussis ; validation du résultat attendue |
| 5 | B11 : compteur Famille, Solo et 7A | B11 corrigé ; compteurs/navigation FR/EN/DE vérifiés ; validation du résultat attendue |
| 6 | Q01 : références visuelles et divergences documentaires | À faire ; aucune référence remplacée |
| 7 | D01–D04 et R03 : doublons, nettoyage et textes longs | À faire ; aucune suppression |

### Phase 5 — compteur Famille corrigé et vérifié, 2026-10-09

- Source réelle inchangée : OnboardingFlow.solo 11 étapes, foyer 9. Couverture Famille : nombre fixe 10 remplacé par foyer.length ; aucune étape ni navigation modifiée. Assert de parcours obsolète 10 remplacé par 9 dans solo_flow_test.dart.
- 42 nouveaux contrôles : avant 28 réussites / 14 échecs (10 de compteur et 4 débordements ES/IT préexistants) ; après 38 réussites / 4 échecs ES/IT à 320 px. Les 33 contrôles FR/EN/DE, ordres et parcours existants passent. Retours, trois modes de gestion, Réserve hors compteur et retour au récapitulatif vérifiés ; réponses conservées.
- Suite complète finale : **821 réussites / 17 échecs / 0 ignoré**. Échecs : 13 golden historiques + 4 débordements de couvertures ES/IT 320 px révélés par les nouveaux tests ; aucun nouveau défaut dans le périmètre de lancement. FR/EN/DE 320/390 et six langues à 390 passent. Aucun golden modifié ; les débordements hors périmètre restent à traiter après autorisation.
- Analyse Flutter et diff check sans problème. 127 fichiers source/localisations/tests/migrations/PNG Landing identiques au snapshot ; phases 1–4 bis préservées. Rapport : `reports/PHASE5_CORRECTIONS_ET_TESTS.md`.
- Aucun changement Supabase, nutrition, Solo 18+, contraintes, devises, Réserve, design/illustrations, commit/push ou build/installation Android. **Arrêt après phase 5 ; phases 6–7 non commencées.**

### Phase 4 bis — restructuration autorisée de l’étape 8, 2026-10-09

- Quatre sections dans le même écran : régime principal unique, restrictions indépendantes, allergies/problèmes alimentaires, aliments non aimés. Composants et illustrations existants conservés.
- Omnivore retire uniquement les codes principaux ; les restrictions et codes inconnus restent intacts. Anciennes combinaisons multiples conservées jusqu’au choix explicite ; poursuite bloquée, y compris depuis un accès direct au récapitulatif.
- Crustacés et mollusques séparés, 14 codes uniques au total. Code gluten conservé, libellé céréales contenant du gluten, sans assimilation au blé ou à la maladie cœliaque. Sept autres allergènes restent dans le déroulant. Grille impaire protégée.
- Allergies des adultes/enfants/bébés conservées indépendamment des choix communs ; inconnus signalés et préservés. Saisie libre inchangée ; anciennes exclusions toujours contraignantes, aucune conversion en préférence facultative.
- Six langues conservées ; nouvelles formulations médicales et allergènes à relire humainement avant publication. Promesse de compatibilité médicale/cœliaque retirée des textes concernés ; aucun moteur ni Supabase modifié.
- Avant : 42 tests de reproduction, 42 échecs attendus. Après : 42 réussites + 23 contrôles supplémentaires = **65 réussites / 0 échec**. Contrôles FR/EN/DE à 320/390 px, six langues, récapitulatif et rôles familiaux inclus. Suite complète finale : **783 réussites / 13 échecs visuels historiques / 0 ignoré**, soit **772 réussites / 0 échec** dans le sous-ensemble pertinent. Analyse finale et diff check sans erreur. Trois débordements familiaux révélés par la première suite ont été corrigés sans modifier les assertions existantes. Rapport : `reports/PHASE4BIS_CORRECTIONS_ET_TESTS.md`.
- 168 fichiers préexistants du snapshot lib/test/Landing sont identiques, dont formats régionaux, Budget, Réserve et tests des phases précédentes. Seuls les fichiers de ce périmètre et localisations générées ont changé.
- Arrêt après phase 4 bis ; validation du résultat attendue. **Phases 5–7 non commencées.** Aucun changement nutrition/Solo 18+/règles Famille, illustration, Supabase, commit/push ou installation.

### Phase 4 — corrections autorisées et vérifiées, 2026-10-09

- Référence conservée : master / 4f569a0. Corrections locales de phase 3 et six images provisoires Landing préservées ; aucun commit/push ni installation.
- B08 : budget entier associé à un code ISO explicite ; FR/DE/BE EUR, GB GBP, US USD, CA CAD, AU AUD, CH CHF. Tous les montants du Budget et du récapitulatif suivent ce code. Langue et pays séparés ; aucune conversion de change.
- Anciens budgets : montant exact conservé, devise inconnue explicitement identifiée, confirmation sans présélection sur le Budget existant. Aucune déduction depuis la région ; retour à cette étape depuis le récapitulatif si nécessaire. Budget ancien sous 20 conservé, à corriger explicitement avant de poursuivre.
- Saisie entière stricte : 65,50 et 65.50 refusés avec message traduit, dernier montant valide conservé. Paramètres nominaux 65, curseur 20–350/pas 5 et coefficients familiaux inchangés ; indications provisoires non vérifiées localement. Prix de démo/abonnement inchangés.
- B09 : arrondi des pouces totaux puis division/modulo ; 182 cm = 6 ft 0 in. Centimètres de référence et protections R01 conservés ; test auparavant différé réactivé.
- B10 : moyenne de grille via Formats.number et locale complète ; aucune quantité interne changée.
- Avant : 131 diagnostics = 87 réussites / 44 échecs. Après : **131 réussites / 0 échec**, plus **38 nouveaux contrôles / 0 échec**. Suite complète : **718 réussites / 13 échecs visuels historiques / 0 test différé** ; sous-ensemble pertinent hors fichiers golden/démarrage : **707 réussites / 0 échec**. FR/EN/DE à 320/390 px et régressions phases 1–3 passent ; analyse sans problème et diff check sans erreur.
- Rapport : `reports/PHASE4_CORRECTIONS_ET_TESTS.md`. Validation du résultat attendue. **Phase 4 bis et phases 5–7 non commencées.** Supabase, nutrition, Solo 18+, règles Famille, design et illustrations préservés.

### Phase 3 — corrections autorisées et vérifiées, 2026-10-09

- B04/B05 : identités alimentaires stables et aliases précis ; suggestions et photos existantes cohérentes dans les six langues ; noms libres conservés, choix manuel pour inconnus/ambiguïtés. Pommes de terre crues : légumes/placard/aucune date automatique.
- B06 : clé source + catégorie rapide stable + emplacement ; validation identique sans ajout ; statut modifié actualisé. Produits manuels, lieux distincts et doublons historiques préservés ; ambiguïté traduite avant toute mutation. Non ne supprime rien.
- B07 : unités stables, traduction à l’affichage ; unités et quantités héritées des six langues conservées. Statuts qualitatifs séparés ; aucun poids/volume mesuré inventé. Quantités choisies/préremplies non remplacées par langue, unité ou suggestion suivante.
- Provenance des dates estimées/choisies/inconnues ; aucune date manuelle écrasée. R02 protégé par mounted après calendrier. Un décalage civil de date au changement d’heure, révélé par les nouveaux tests, est corrigé dans la Réserve seulement ; aucune durée ni formule nutritionnelle changée.
- Reproductions avant : 31 réussites / 49 échecs sur 80 tests. Après : 80 réussites ; 69 régressions supplémentaires passent. Contrôle pertinent : **537 réussites, 0 échec, 1 B09 différé** ; analyse sans problème et diff check sans erreur. Suite complète finale : **548 réussites, 13 échecs visuels historiques, 1 B09 différé**, code 1 dû uniquement aux références visuelles.
- Rapport détaillé : `reports/PHASE3_CORRECTIONS_ET_TESTS.md`. Les 13 références visuelles historiques sont laissées intactes, B09 reste en phase 4. Aucun commit/push, Supabase, installation Android, design, illustration ou suppression. **Arrêt après phase 3 ; attendre la validation de Simo. Phases 4 à 7 non commencées.**

### Phase 3 — diagnostic et plan, 2026-10-09

- Référence vérifiée : master, commit GitHub 4f569a0 ; seuls les six assets Landing provisoires sont non suivis au début. Aucun fichier applicatif modifié.
- Test ajouté : `test/phase3_pantry_diagnostic_test.dart`, 80 cas, 31 réussites / 49 échecs attendus reproduisant B04/B05/B06/B07 et R02. Classification par sous-chaînes, suggestions/images françaises, répétitions du stock rapide, unités traduites persistées et setState après fermeture confirmés.
- Commande avec régressions existantes : **275 réussites / 49 échecs phase 3 / 1 B09 différé**. Les 244 contrôles existants passent. Les 18 rendus Réserve FR/EN/DE à 320/390 passent ; analyse Flutter sans problème. Tests de reproduction laissés en échec jusqu’à correction autorisée.
- Plan précis : `reports/PHASE3_DIAGNOSTIC_ET_PLAN.md`. Déduplication proposée uniquement pour source + catégorie rapide stable + emplacement, sans fusion manuelle ni suppression historique. Politique « statut modifié » à valider ; pommes de terre : Placard proposé sans durée automatique inventée.
- Attendre l’accord de Simo sur ces règles avant toute correction. Aucun changement nutritionnel, Famille, design, illustrations ou Supabase ; aucun commit/push, installation ou suppression. Phases 4 à 7 non commencées.

### Rectification produit après audit scientifique — 2026-10-09

- Décisions validées par Simo : Individuel 18+ (jusqu’à 100 ans, borne existante) ; Famille = repas/budget/contraintes, sans transformation physique.
- Champs et modèle Solo refusent les moins de 18 ans ; calculs, récapitulatif et navigation protégés pour les accès directs et anciens profils. Aucun remplacement silencieux. Un âge corrigé explicitement à 18 ans permet de reprendre le parcours.
- Objectifs physiques et choix d’activité retirés des fiches familiales et de leurs résumés ; calculs Solo indisponibles en mode Famille. Données héritées conservées et inactives, profils enfants/bébés et contraintes préservés.
- Catégories du foyer inchangées : « adulte » dès 14 ans, indépendant de Solo. Incohérence de vocabulaire signalée, sans reclassification arbitraire.
- Régressions 17/18, accès directs et conservation des réponses en FR/EN/DE à 320/390 px. Tests de bornes Solo anciennement 14 ans adaptés à 18 ; fixtures responsive utilisent le bon mode pour les écrans physiques.
- Vérification finale : **386 réussites, 0 échec, 1 B09 différé** ; `flutter analyze --no-pub` sans problème ; `git diff --check` sans erreur. Résultats et fichiers : `reports/RECTIFICATION_REGLES_PRODUIT.md`. Audit B actualisé ; formules inchangées, autres politiques en attente. Aucun changement Supabase, illustrations, installation, commit ou push. **Arrêt après cette correction ; phases 3 à 7 non commencées.**

### Phase 1 — preuves et validation technique

- Avant correction : `family_profiles_regression_test.dart`, 12 tests, 10 échecs attendus et 2 réussites. B01 : nom affiché comme référence de fonction ; B02 : identifiant du cuisinier conservé après passage en enfant/bébé ; B03 : dépassements, dernier adulte et compteur excessif non protégés.
- Corrections : validation de composition centralisée dans le modèle ; refus sans mutation ni notification ; retour à « À tour de rôle » pour le cuisinier devenant enfant/bébé ; noms traduits dans les profils, Ma cuisine, récapitulatif et rappels d'allergies ; messages de refus traduits.
- Les limites 8 adultes / 8 enfants / 4 bébés restent PROVISOIRES. Les prénoms, identifiants, codes d'allergènes, exclusions et budget personnalisé sont conservés. Aucun changement des parcours ou illustrations.
- Tests ajoutés : `family_profiles_regression_test.dart` (22 cas) et `family_profiles_ui_test.dart` (36 cas : FR/EN/DE × 320/390 px, édition réelle, retour, messages de limites et affichages).
- Vérification finale : 213 tests réussis, 0 échec, pour ces deux fichiers plus `solo_flow_test.dart`, `overflow_320_regression_test.dart`, `overflow_sweep_test.dart`, `pantry_hub_i18n_test.dart`, `language_picker_test.dart`, `i18n_test.dart`. `flutter analyze --no-pub` : aucun problème.
- Les 13 échecs visuels de l'audit ne sont pas traités ni relancés ici : ils restent au périmètre de la phase 6. Pas d'APK produit ou installé. Prochaine action : attendre la validation de Simo ; ne pas commencer la phase 2 sans accord.

### Phase 2 — diagnostic uniquement, 2026-10-09

- Simo a autorisé le diagnostic et les tests de reproduction de R01, mais demande un accord distinct avant correction. Aucun fichier de `lib/` modifié pendant ce diagnostic (empreintes SHA-256 comparées).
- Tests ajoutés : `test/numeric_model_diagnostic_test.dart` (28 cas) et `test/numeric_fields_diagnostic_test.dart` (63 cas FR/EN/DE). Les attentes de sécurité restent volontairement en échec jusqu'à correction autorisée.
- Résultat final de la commande ciblée incluant les contrôles de phase 1, navigation Solo/Foyer et formats : 157 cas, 125 réussites et 32 échecs reproduisant les anomalies. Les 66 contrôles existants passent ; diagnostic seul : 59 réussites / 32 échecs. Analyse Flutter : aucun problème. `git diff --check` : aucune erreur. La suite complète n'est pas relancée à ce stade.
- Reproductions : cible NaN/Infinity/1e309 collée = exception dans l'aperçu ; poids NaN accepté en maintien et dans une fiche familiale ; validation du modèle acceptant certains poids/taille invalides ; calories NaN/Infinity en exception, poids injecté 1e307 produisant -10 kcal ; cible 10000 kg acceptée et projection de 19850 semaines ; cible 1e12 donnant une durée débordée et une date de l'année -262550 ; glucides -15 g pour femme, 100 ans, 120 cm, 250 kg, sèche et activité sédentaire (valeurs dans les limites des champs).
- Conversions usuelles inchangées. B09 (182 cm donnant 5 ft 12 in) reproduit, reste au périmètre initial de phase 4. La conversion d'une taille infinie doit être protégée techniquement en phase 2.
- Proposition soumise à Simo : validation finie et bornes existantes centralisées ; protection des calculs et de l'aperçu avant conversions ; vérification de la capacité réelle des durées/dates ; pas de modification BMR ni de correction silencieuse des réponses. Plafond éventuel de poids cible à 250 kg et traitement d'un calcul de macros incohérent restent des choix à approuver. Aucun horizon arbitraire en années proposé.
- Phases 3 à 7 conservées, non commencées. Aucun accès au téléphone, changement Supabase, commit ou push. Prochaine action : rapport de diagnostic et attente de l'autorisation de Simo.

### Phase 2 — correction R01 autorisée et vérifiée, 2026-10-09

- Accord de Simo : rejet NaN/Infinity/dépassements ; bornes Solo existantes conservées et règles familiales par rôle préservées ; cible maximale PROVISOIRE de 250 kg ; aucun plafond arbitraire de durée ; formules BMR et macros conservées ; calories valides toujours visibles même si la répartition des macros est indisponible. B09 reste en phase 4.
- Protection des champs et du modèle avant calcul/enregistrement. Résultats numériques non calculables renvoyés comme indisponibles, sans correction ni suppression des réponses stockées. Durées/dates vérifiées avant multiplication avec les capacités réelles de Duration et DateTime. Conversions non finies protégées ; formule pieds/pouces finie inchangée.
- Rythme incompatible : pas de repli silencieux vers 0,5 ; choix explicite dans les options existantes. En Sèche, la sélection unique est accessible lorsqu'un ancien rythme est incompatible. Les écrans valides gardent leur présentation.
- Tests du diagnostic adaptés aux refus approuvés (null = indisponible, jamais 0 inventé) ; B09 marqué explicitement hors périmètre. Test B02 de phase 1 : fixture enfant/bébé rendue cohérente avec l'âge et les mensurations du rôle, assertions sur le cuisinier conservées.
- Régressions R01 : 115 cas réussis, 0 échec, dont vérification de 512 combinaisons de profils aux bornes et affichage calories/macros indépendants à 320/390 px en FR/EN/DE. Contrôle ciblé avec phase 1, parcours Solo/Foyer et formats : 181 réussites, 0 échec, 1 test B09 différé explicitement.
- Suite complète finale : **346 réussites, 13 échecs de comparaisons visuelles déjà présents à l'audit, 1 test B09 différé**, code de sortie 1 dû uniquement aux références visuelles. Les mêmes écrans échouent : Landing, choix du mode, couvertures Solo/Foyer, inscription en FR/AR, et Réserve principale FR/DE/AR. Aucune référence remplacée ; leur analyse reste en phase 6.
- `flutter analyze --no-pub` : aucun problème, code 0. `git diff --check` : aucune erreur. Aucun APK installé, changement Supabase, commit ou push ; branche master et commit f37797b inchangés.
- Risques résiduels : B09 connu, références visuelles à examiner, cible maximale encore provisoire. Les anciennes valeurs invalides sont conservées et doivent être corrigées explicitement par l'utilisateur ; les futurs consommateurs de calculs doivent gérer l'indisponibilité.
- Prochaine action : présenter le résultat à Simo et attendre sa validation. **Ne pas commencer la phase 3 sans son autorisation.** Phases 3 à 7 maintenues dans le plan.

### Phase 2 — révision de sécurité scientifique, 2026-10-09

- Simo demande de conserver provisoirement les bornes actuelles sans les considérer comme seuils médicaux ; aucun rejet sur le seul IMC élevé. Aucun changement de formule, limite métier ou politique de santé sans autorisation distincte.
- Livrables séparés : `reports/PHASE2_A_R01_TECHNIQUE.md` et `reports/PHASE2_B_AUDIT_SCIENTIFIQUE.md`. Références primaires : NICE NG246, CDC, NIDDK, Mifflin 1990, revue Sports Medicine 2023 demandée, CIO REDs 2023, ISSN, National Academies et Hall 2011.
- Aucun nouveau défaut purement technique R01 confirmé. Corrections conservées, commentaires clarifiant leur portée, nouveau test de caractérisation (29 cas). Profils forts/musclés fictifs acceptés ; tests ne constituant pas une validation clinique.
- Vérification finale pertinente : **343 réussites, 0 échec, 1 test B09 différé** ; analyse sans problème ; diff check sans erreur. Les 115 tests R01 et 58 tests phase 1 passent. La suite complète précédente reste à 346 réussites / 13 échecs visuels préexistants / 1 B09 différé ; elle n'est pas relancée pour cette révision documentaire et de caractérisation.
- Risques santé documentés et NON corrigés sans accord : application des calculs adultes aux 14–17 ans ; projection linéaire malgré adaptations et plancher énergétique ; risques de disponibilité énergétique chez sportifs ; généralisation des macros ; absence de moteur pédiatrique par membre ; informations familiales insuffisantes pour celui-ci ; annonce d'un ajustement ultérieur non codé.
- Constat reproductible : femme 40 ans, 160 cm, 60 kg, sédentaire, 0,75 kg/semaine, cible 50 kg : 1 240 kcal et 14 semaines malgré un déficit initial réduit par le plancher. Aucune correction de cette hypothèse métier sans décision.
- Aucun seuil supplémentaire, avertissement médical automatique, changement d'écran, Supabase, commit, push ou installation Android. Phases 3 à 7 non commencées. Attendre l'autorisation sur les propositions du livrable B.

- **2026-10-02 — Arret pour aujourd hui, sauvegarde de fin de session** : demande de Simo, aucune nouvelle modification fonctionnelle. Derniere version compilee et installee : Mode de gestion, trois icones 36 px au trait 1.0 centrees verticalement ; demarrage et logs controles sans erreur. Ecrans Activite, Balance, Grille et Budget egalement corriges et installes pendant cette session. Demain : reprendre depuis le Mode de gestion puis auditer l ecran suivant affiche sur le telephone (detour Reserve si Mixte ou Reserves uniquement). Ne pas modifier les choix personnels pour avancer. Respecter audit reel, corrections ciblees, apercu, validation puis installation sur demande. Attention : les marges 14 px, ecarts 10 px et textes bleus proposes pour Mode de gestion n ont pas ete appliques ; seuls ses icones et leur centrage ont ete valides. Sauvegarde complete hors projet dans le dossier backups de la session Codex, label fin-session.

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

- **2026-10-02 — Profil valide et installe** : APK release compile et installe sur demande de Simo, donnees conservees. Controle reel : marges contenu/CTA 14 px, textes bleu sombre, pastille balance 56 px, titre Parlez-nous sans glyphe parasite, textes complets et CTA visible apres defilement. Demarrage normal et aucune erreur Flutter detectee. Aucune publication. Prochaine action : attendre les instructions de Simo.

- **2026-10-02 — Pastille balance Profil agrandie** : sur demande de Simo, pastille de la balance 48 vers 56 px, icone proportionnellement 24 vers 28 px. Titre et autres sections conserves. Taille optionnelle StepSectionTitle par defaut inchangee ailleurs. Apercu Flutter regenere. Aucune installation.

- **2026-10-02 — Profil harmonise, apercu a valider** : sur accord de Simo, marges contenu et CTA 14 px, textes secondaires bleu sombre et icone balance pour objectif de perte. Champs blancs, selections vertes, textes et logique conserves. Le gabarit expose subtitleColor avec defaut inchange ; trait insécable du titre remplace par trait standard protege contre les coupures pour supprimer le glyphe parasite dans Parlez-nous. Apercu Flutter verifie, analyse sans erreur, tests profile et member_profiles dans les six langues reussis. Aucune installation. Prochaine action : validation de apercu puis installation sur demande.

- **2026-10-02 — Objectif valide et installe** : APK release compile et installe sur demande de Simo sans effacer les donnees. Verification sur le telephone : quatre icones vectorielles 36 px centrees verticalement, descriptions concises completes, cartes blanches avec marges 14 px, CTA visible apres defilement. Aucun debordement observe ni erreur Flutter detectee. Aucune publication. Prochaine action : attendre les instructions de Simo.

- **2026-10-02 — Marges Objectif harmonisees** : sur demande de Simo, marges horizontales du contenu, des cartes et du CTA passees de 20 a 14 px. Gabarit commun parametrable, valeur par defaut 20 px conservee ailleurs. Apercu Flutter regenere sans erreur. Aucune installation.

- **2026-10-02 — Objectif : descriptions concises et icones centrees** : quatre formulations validees raccourcies dans les six langues, sans changer les titres. Pastilles centrees verticalement dans les quatre cartes, indicateurs de selection conserves en haut. Option centerIcon activee uniquement sur GoalScreen et false par defaut ailleurs. Apercu Flutter verifie, six tests de debordement reussis. Aucune installation. Prochaine action : validation du visuel puis installation sur demande.

- **2026-10-02 — Icones Objectif integrees, apercu a valider** : quatre icones vectorielles concretes validees par Simo (balance avec fleche descendante, biceps, torse defini, balance equilibree), taille 36 px. Remplacement limite aux pictogrammes et leur taille ; textes, cartes blanches, marges, couleurs et navigation conserves. ChoiceCard accepte une taille optionnelle dont la valeur par defaut reste 24 px ailleurs. Apercu Flutter reussi et analyse sans erreur. Aucune installation. Prochaine action : validation du visuel puis installation sur demande.

- **2026-10-02 — Pour moi valide et installe** : APK release compile et installe sur demande de Simo, donnees conservees. Verification sur telephone : cartes blanches, trois icones vectorielles 36 px, titre sur-mesure sans caractere parasite, textes complets, CTA visible et 11 etapes annoncees. Demarrage normal, aucune erreur Flutter detectee. Aucune publication. Prochaine action : attendre les instructions de Simo.

- **2026-10-02 — Pour moi : cartes blanches restaurees et titre corrige** : sur demande de Simo, retour au fond blanc sans bordure coloree ; pastilles pastel et icones 36 px conservees. Le trait insécable U+2011 du titre avait un rendu parasite : remplace localement par un trait standard encadre de caracteres U+2060 pour conserver le mot sans coupure. Apercu verifie, six tests de debordement reussis. Aucune installation. Prochaine action : validation puis installation sur demande.

- **2026-10-02 — Ecran Pour moi harmonise, apercu a valider** : corrections confirmees par Simo : icones vectorielles 36 px, marges et CTA 14 px, ecart cartes 10 px, fonds pastel et bordures plus soutenues, descriptions 13 px bleu sombre, badge rayon 10 px. Nombre annonce derive du parcours Solo : 11 etapes. Photo, titres, coches et navigation conserves. Parametre de rayon optionnel dans PillBadge avec valeur par defaut inchangee ailleurs. Analyse sans erreur et 6 tests de debordement cibles reussis. Aucune installation. Prochaine action : validation du visuel puis installation sur demande.

- **2026-10-02 — Icones Solo remplacees, apercu pret** : trois pictogrammes vectoriels au trait fin, agrandis de 28 a 36 px sur demande de Simo, selon le visuel valide (assiette, horloge avec feuille, feuilles avec fleche circulaire). Uniquement les trois icones changees ; textes, couleurs, coches, photo et disposition conserves. Apercu Flutter et analyse sans erreur. Aucune installation. Prochaine action : validation du rendu puis installation sur demande.

- **2026-10-02 — Choix du mode harmonisé, validé et installé** : après audit réel et accord de Simo, marges cartes/CTA 14 px, écart cartes 10 px, fonds menthe/pêche, bordures pastel hors sélection et bordure verte sélectionnée, textes secondaires bleu sombre et descriptions 13 px. Lien improvisation centré avec séparation après la question dans les six langues. Photos, titres, structure et navigation conservés. Analyse sans erreur, 6 tests de débordement ciblés et test i18n réussis, aperçu Flutter généré. Visuel validé par Simo puis APK release compilé et installé sur son téléphone avec conservation des données. Contrôle réel : textes complets, défilement naturel, CTA et lien visibles, aucune erreur Flutter détectée. Prochaine action : attendre les nouvelles instructions.

- **2026-10-02 — Carte Suivi validée et installée** : illustration dézoomée, fond transparent exact #F0EDFF et trois indicateurs agrandis de 12 %. Visuel et installation autorisés par Simo. APK release compilé puis installé avec conservation des données. Contrôle téléphone : trois indicateurs complets, fond uniforme et aucun overflow ou erreur Flutter détecté. Aucun autre élément modifié, aucune publication. Prochaine action : attendre les nouvelles instructions.

- **2026-10-02 — Fond Courses validé et installé** : illustration transparente montrant le fond exact de la carte #EAF7F0, validation visuelle puis installation autorisée par Simo. APK release compilé et installé sans effacer les données. Vérification réelle : fond uniforme, téléphone et sac complets, démarrage normal et aucune erreur Flutter détectée. Aucun autre élément modifié, aucune publication. Prochaine action : attendre les nouvelles instructions.

- **2026-10-02 — Carte Courses validée et installée** : Simo a validé le visuel dézoomé et demandé son installation. APK release compilé et installé avec conservation des données. Contrôle téléphone : téléphone et sac entièrement visibles, carte conforme au rendu approuvé, aucune erreur Flutter ou overflow détecté. Aucun autre élément modifié ; aucune publication. Prochaine action : attendre les nouvelles instructions de Simo.

- **2026-10-02 — Démarrage corrigé et vérifié sur téléphone** : écran Android natif vert/Menoo avant Flutter (Android 12+ et versions antérieures configurés), suppression du fondu natif, accueil construit après la première frame puis révélé après précache des images. Analyse sans erreur et 10 tests réussis. APK debug compilé/testé puis APK release signé localement avec la clé debug installé sans effacer les données ni publier. Deux lancements release : Menoo visible à 0,6–0,7 s dans les premières captures, landing visible à 3,4–4,2 s animation comprise ; pixels de la landing identiques hors barres système. Aucun crash, erreur Flutter ou overflow détecté ; avertissement PerfDebugMonitor MIUI sans impact applicatif. Prochaine action : validation par Simo du démarrage sur téléphone. Sauvegarde avant optimisation conservée ; aucun push ni publication.

- **2026-10-02 — Images externalisées, APK installé et vérifié** : 12 PNG identiques, chargement par Image.asset, dossier déclaré ; source passée de 1,54 Mo à 15 Ko. Analyse sans erreurs, 9 tests réussis, pixels de l’accueil identiques hors barres système sur téléphone. Second démarrage : animation visible vers 4,2 s, landing vers 6,9 s, donc aucune amélioration nette face aux 4,25 s / 6,92 s précédents. Blanc natif et blocage initial persistants (164 frames sautées). Prochaine action : corriger le démarrage natif et investiguer le travail avant la première frame sans changer le design. Aucun push ni publication.

Pour reprendre dans une nouvelle session : « Reprends à partir de PLAN.md ».

## 📍 Où on en est
- **Slogan validé le 2026-10-02** : « Bien manger, simplement. » ajouté en texte Flutter sous le logo 3D, avec fondu final et pause de lecture de 600 ms (démarrage prêt ≈ 2,6 s). Traductions dans les 6 langues ; 10 tests passent, dont lisibilité à 200 % sur petit écran. Les 69 images précédant le slogan sont identiques. Nouvel aperçu : `C:/Users/simos/Documents/Codex/2026-10-01/1-acc-s-au-projet-ouvre/outputs/menoo-demarrage-flutter-slogan.gif`. Aucune publication ni installation ; validation de Simo attendue avant test téléphone.
- **Correction du 2026-10-02** : carottes et basilic de l'animation redessinés en courbes de Bézier, sans segments polygonaux. 9 tests au vert ; début et logo 3D final identiques (39 images comparées). Nouvel aperçu local : `C:/Users/simos/Documents/Codex/2026-10-01/1-acc-s-au-projet-ouvre/outputs/menoo-demarrage-flutter-courbes.gif`. Aucune installation ou publication.
- **2026-10-02 — animation de démarrage intégrée en local** : Flutter natif (Menoo → M → liste/fourchette → carottes/basilic → logo 3D fourni), textes traduits dans les 6 langues, animations réduites respectées, sortie accélérée à environ 2 s quand prête. 9 tests réussis (dont navigation Landing), analyse sans problème, APK debug compilé. Aperçu réel : `C:/Users/simos/Documents/Codex/2026-10-01/1-acc-s-au-projet-ouvre/outputs/menoo-demarrage-flutter-apercu.gif`. Aucune publication ni installation ; aucune modification de la Landing pendant cette tâche. Prochaine action : validation de l'aperçu par Simo, puis test téléphone uniquement sur sa demande.
- **État actuel (2026-10-01)** : jalons 0 à 5i **validés**. **Jalon 5d terminé** : corrections UI critiques appliquées (supermarché supprimé, 5 écrans de réassurance supprimés, landing nettoyée, cartes interactives, équipements en 3 colonnes, arrondis et tailles uniformisés sur contraintes + global). `flutter analyze` sans problème, 206 tests au vert. APK à builder et installer.
- **Corrections du 2026-10-01 (jalon 5d)** :
  1. **Écran supermarché supprimé** du flow (il avait déjà été retiré de la liste des étapes ; reste : clés de traduction nettoyées dans les 6 langues).
  2. **5 écrans de réassurance supprimés** (poids, métabolisme, budget, anti-gaspi, prêt) — fichier `reassurance_screens.dart` supprimé, logique retirée de `onboarding_flow.dart`, clés de traduction supprimées. Les infos redondantes étaient déjà affichées aux étapes correspondantes.
  3. **Stepper** inchangé (les réassurances étaient déjà hors compteur ; Solo 11 étapes, Foyer 9 étapes).
  4. **Phrase manuscrite retirée** de la landing (« Une vie plus saine au quotidien ! »).
  5. **Cartes de la landing interactives** avec ombrage ; Scan IA navigue vers l'écran d'improvisation ; carte Suivi passe de lavande à menthe (thème vert) ; previews améliorées (quantités dans les courses, barres de macros dans le suivi).
  6. **Équipements en 3 colonnes** sur l'écran « Ma cuisine » (nouveau token `equipmentTileAspect3Col`).
  7. Tests mis à jour (flow Solo/Foyer sans réassurance, goldens regénérés, overflow sweep sans les 5 écrans supprimés).
  8. **Écran Contraintes + global** : icônes de section agrandies (34→40px), chips régime passées de pilule à arrondi 12px, photos d'allergènes agrandies (34→40px), badges de chips agrandis (24→28px). Border-radius cohérent dans toute l'app : cartes 14px, tuiles/chips 12px, pastilles 10px.
- **Git** : projet sous version depuis le 2026-09-30.
- **Prochaine action** : builder l'APK, l'installer sur le téléphone, puis attendre la validation de Simo. Ensuite : jalon 5c (recettes des 8 cuisines).
- **Visuels du 5b** : tous validés. Pas encore affichés (écrans à venir) : 6 recettes, `famille_table`.
- **Maquette 6b** : v4 en attente du retour de Simo.

| # | Jalon | Statut |
|---|---|---|
| 0 | Environnement (Flutter, Android SDK, téléphone, Supabase) | ✅ Validé |
| 1 | App vide installée sur le téléphone | ✅ Validé |
| 2 | Design system + 9 écrans maîtres | ✅ Validé (après corrections) |
| 3 | Base Supabase (tables, RLS, démo, cas pièges) | ✅ Validé |
| 4 | Entrée + onboarding Solo (11 étapes) + détour Réserve 7A | ✅ Validé |
| 5 | Onboarding Foyer (9 étapes) + détour Réserve | ✅ Validé |
| 5b | Images par API OpenAI (125 visuels) + pictogrammes régimes + branchement | ✅ Validé |
| 5i | **International, socle** : textes sortis du code, 6 langues, arabe de droite à gauche, unités / devises / dates | ✅ Validé (2026-09-30) — tables de traduction Supabase pour les contenus restent au 5c |
| 5d | **Corrections UI critiques** : supermarché et réassurance supprimés, landing nettoyée, cartes interactives, équipements 3 colonnes, arrondis uniformisés | 🔨 En cours (APK à installer) |
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
- [x] Téléphone détecté : Xiaomi 2201117PG (série Xiaomi autorise)
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
- [x] Parcours unique : lib/onboarding/onboarding_flow.dart (OnbStep, listes Solo 11 étapes / Foyer 9 étapes) remplace solo_flow.dart ; le détour Réserve revient à l'étape qui suit le mode de gestion (Solo : contraintes ; Foyer : cuisines).
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

## Convention du détour Réserve — 2026-10-08
- Dans le parcours Individuel, « Remplissage de la Réserve » est l'écran conditionnel **7A** : il ne compte pas dans les 11 étapes principales.
- Après 7/11 « Mode de gestion » : « Courses uniquement » mène directement à 8/11 « Contraintes » ; « Réserves uniquement » et « Mixte » passent par 7A, puis rejoignent 8/11.
- L'écran 7A ne porte actuellement aucun compteur d'étape ni barre de progression ; ne pas ajouter de numéro au compteur principal.

## Stratégie de lancement des langues — 2026-10-08
- Version initiale commercialisée : English, Français, Deutsch.
- Marchés visés : USA, UK, Canada, Ireland, Australia, Germany, Austria, Switzerland, France et Belgium.
- Spanish, Italian et Arabic restent dans le repository pour une phase ultérieure ; l’application ne les propose pas au lancement.
- Les traductions restent génériques (`en`, `fr`, `de`) ; conserver le pays de l’appareil pour les formats régionaux.
- Regional pricing / currencies to be implemented before commercial launch if required: USD, GBP, CAD, AUD, EUR, CHF.


### 2026-10-09 - Correction visuelle des 23 icones

Copies RGBA transparentes, cadrage et tailles internes corriges localement ; originaux et pastilles preserves. Rapport : reports/CORRECTION_ICONES_3D.md. Tests : 113 cibles reussis ; suite complete 934 reussites / 17 echecs historiques ; analyse sans probleme. Validation visuelle utilisateur attendue ; phases 6B et 7 en attente. Aucun commit, push ou installation Android.


### 2026-10-09 - Agrandissement local des pastilles 3D

Pastilles concernees : 64 px (images 60), alimentaires 48 px (images 44), verification rapide 56 px (image 52). Ma reserve reste a 56/52 px ; proposition 64/60 en attente. Rapport : reports/AGRANDISSEMENT_PASTILLES_3D.md. Tests : 114 cibles reussis ; suite complete 935 reussites et 17 echecs historiques ; analyse sans probleme. Aucun asset modifie ni installation Android. Validation visuelle attendue ; phases 6B et 7 en attente.


### 2026-10-10 - Padding local des cartes Objectif

Plan autorise par Simo : gauche/haut/bas 8 px, compensation a 7 px quand selectionne ; droite 16/15 px conservee. Pastille 64 px, image 60 px, ecart texte 12 px et centrage conserves. Parametre facultatif de ChoiceCard utilise uniquement dans GoalScreen ; autres cartes inchangees. Tests concernes : 143 reussites, analyse sans probleme, diff check reussi. Rapport : reports/OBJECTIF_PADDING_CARTES.md. Validation visuelle attendue, aucune installation Android, aucun commit/push ; phases 6B/7 non commencees.


### 2026-10-10 - Agrandissement Objectif avec padding reduit

Essai 72/68 px : titre allemand Abnehmen coupe a 320 px. Repli autorise 70/66 px retenu, titre entier et tests reussis. Padding 8/7 px, droite 16/15 px, ecart texte 12 px et centrage conserves. Les autres ecrans et PNG sont inchanges. Tests concernes : 143 reussites ; analyse et diff check reussis. Rapport : reports/OBJECTIF_AGRANDISSEMENT_PASTILLES.md. Validation visuelle attendue, aucune installation Android ni commit/push ; phases 6B/7 non commencees.


### 2026-10-10 - Harmonisation locale des cartes avec icones 3D

Activite, Gestion, couvertures concernees et Reserve : pastilles 70 / images 66 px, padding gauche/haut/bas 8 px (7 avec compensation de bordure). Regimes/restrictions : 50/46 px, hauteur des puces 56 conservee et grille preservee. Objectif, PNG et autres pictogrammes inchanges. Rapport : reports/HARMONISATION_CARTES_ICONES_3D.md. 200 tests cibles reussis ; suite complete 1161 reussites et 17 echecs historiques ; analyse sans probleme. Validation visuelle attendue. Aucune installation Android ni commit/push ; phases 6B/7 non commencees.


### 2026-10-10 - Landing : mains animees locales

Quatre pastilles avec dessin Flutter blanc et animation 600 ms / pause 4200 ms ; Suivi sans main. Menus et Courses conservent la route PathChoiceScreen. Instant Recipe AI et CaliScan restent visuels sans destination fonctionnelle connectee. RTL : main en miroir pour eviter la coupure. 17 tests CTA et 430 regressions reussis ; analyse sans probleme. Rapport : reports/LANDING_CTA_MAIN_ANIMEE.md. Validation visuelle attendue, aucune installation Android ni commit/push ; phases 6B/7 non commencees.


### 2026-10-10 - Correction de la main CTA sur reference fournie

Silhouette de la reference retracee, taille proche de 23 px, inclinaison 25 degres ; trois cercles concentriques ancres au contact. 17 tests reussis : FR/EN/ES/IT/DE a 320/390 ; dimensions des cartes/pastilles identiques et PNG/navigation preserves. Gros plans et pages entieres dans reports/LANDING_CTA_MAIN_ANIMEE.md. Validation visuelle attendue ; aucune installation ni commit/push, phases 6B/7 non commencees.


### 2026-10-10 - CTA : suppression finale des traits de clic

Les quatre mains partagent trois cercles concentriques, sans traits de clic. Captures de comparaison a 60 % pour 320/390 px ; decalages reels conserves. 17 tests reussis ; cartes, images, textes et navigation inchanges. Validation visuelle attendue ; aucune installation, commit ou push.


### 2026-10-10 - Landing : mains agrandies et pression visible

Main environ 30 px, tap de 3 px, cercles jusqu a 15 px de diametre ; pauses et decalages preserves. Espacement local sous les quatre pastilles de 14 px, hauteurs augmentees d environ 11 px. Photos en contain sans recadrage ; Suivi purement informatif. 10 tests FR320/390 reussis, analyse et diff check reussis. Captures et GIF dans reports/LANDING_CTA_MAIN_ANIMEE.md. Validation attendue ; aucune installation, commit/push ni phase 6B/7.

### 2026-10-11 - Splash C : transitions completes
Choix C confirme par Simo, priorite Menoo -> M -> logo. Acceleration a la preparation de la Landing supprimee ; sequence 4440 ms et slogan 1100 ms, selon le GIF C (5540 ms). 8 tests du splash reussis. Landing non modifiee. Validation visuelle sur telephone en attente ; aucune installation, commit ou push.

2026-10-11 : APK debug compile avec succes, installe sur XIAOMI_TEST_DEVICE (adb install -r : Success), puis ouverture de Menoo. Validation utilisateur des transitions Menoo -> M -> logo en attente.

### 2026-10-11 - Remplacement effectif par le GIF C complet
La correction precedente du rythme a ete refusee. Le splash lit maintenant assets/images/startup_c.gif, copie identique du GIF C (SHA256 D92E0499C57C70965018B95A211B4A082061372BF08F66E22C8F22E9D116FDEC), 68 images, 5540 ms, slogan inclus. Demarrage de la duree apres la premiere image ; image finale conservee si la Landing attend encore. 8 tests reussis, dont verification du GIF utilise. Landing inchangee par empreinte SHA256. Compilation et installation en cours.

GIF C complet : APK debug compile et installe avec succes sur XIAOMI_TEST_DEVICE, app ouverte. Capture reports/splash_c_phone.png. Validation Simo en attente.

### 2026-10-11 - Apercu C nettoye, avant installation
Candidat separe dans reports/splash_c_clean_visual.dart : fourchette redessinee en courbes, arrivee alignee sans silhouette double, M et traits de liste nets. Apercu reports/splash_c_clean_preview.gif : 1080x2340, 68 images, 5540 ms. Rendu Flutter verifie, aucune installation et aucune modification du splash actif ni de la Landing pour cette preparation. Attendre le choix de Simo.

2026-10-11 : apres les trois captures de Simo, nouvel apercu reports/splash_c_clean_preview_v3.gif. Fourchette redessinee selon le logo final (dents fines, creux arrondis, manche et base), une seule silhouette pour arrivee et etapes intermediaires ; ancien fondu entre deux silhouettes supprime. 68 images, 5540 ms, rendu Flutter reussi. Apercu uniquement, aucune installation. Validation utilisateur attendue.

2026-10-11 : apercu C nettoye v3 valide par Simo ; integration des deux ressources realisee. SHA256 GIF 63726512DEC5BAAAE30B6619A480DF358946B612F88945717A5C09A06E293F82 identique a l'apercu valide. Landing inchangee. Compilation et installation demandees en cours.

2026-10-11 : APK debug avec C nettoye v3 compile avec succes ; installation sur XIAOMI_TEST_DEVICE reussie (Success), puis app ouverte pour verification par Simo. Aucune modification de la Landing.

2026-10-11 : Simo confirme OK apres installation de C nettoye v3 sur telephone. Splash valide ; correction terminee. Landing preservee.

### 2026-10-12 - Landing : quatre CTA avec contour
Ajout limite aux quatre cartes Instant Recipe AI, CaliScan AI, Menus et Courses, sans mains ni cercles. Choix Simo : les deux scans restent inactifs ; Menus/Courses gardent PathChoiceScreen. Images, cadrages et textes originaux conserves par comparaison de geometrie a 320/390 ; quatre cartes +56 px, Suivi inchange. 36 tests reussis et analyse ciblee sans probleme. Captures completes et rapport : reports/landing_outline_cta/README.md. Attendre validation visuelle explicite avant installation ; aucun commit, push ou APK, splash et Commencer preserves.

### 2026-10-12 - CTA responsive, libelles courts a 320
Version francaise corrigee : courts a 320, complets a 390 ; une seule ligne, limite a la zone texte et a la colonne gauche. Police 12 et icones 18 preserves, espacements 4 px. Captures : reports/landing_cta_responsive/. Geometrie de la zone droite identique et tests francais reussis. Controle six langues : blocage allemand a 390 (texte +6,15 px). Arret selon garde-fou, 36 tests reussis / 1 echec allemand ; aucune correction improvisee. Attendre validation visuelle francaise et accord sur ce cas allemand, aucune installation ni commit/push.

### 2026-10-12 - Landing : phase 1 sur les deux nouvelles references
Implementation limitee a landing_screen.dart et aux jetons propres a la Landing, avec cinq nouveaux PNG derives du ZIP ; originaux, splash, autres ecrans et navigation preserves. Captures Flutter 320/390 et comparaisons dans reports/landing_phase1/. Espacement local de 10 px conserve : phase 2 non commencee. Deux tests de capture/navigation reussis et analyse ciblee sans probleme. Differences restantes documentees (cadrages, retours a la ligne, Suivi plus petit, dates du visuel Menus). Validation visuelle explicite de Simo attendue ; aucun APK, installation Android, commit ou push.

### 2026-10-12 - Landing : correction ciblee des mains et CTA
Quatre CTA a 16 px mesures sous les descriptions, style/taille/libelles et colonnes preserves. Deux illustrations avec mains dezoomees par marge Flutter de 10 px, aucun PNG modifie. Les sources tronquent deja les poignets : extensions proposees separement dans reports/landing_phase1_targeted/proposal_scan.png et proposal_meal_scan.png, non integrees et a valider. Captures Flutter 320/390 et comparaisons dans ce dossier. Deux tests reussis, analyse ciblee sans probleme. Suivi, Commencer, splash, navigation et espacement de 10 px preserves. Phase 2 non commencee ; aucun commit, push ou installation. Validation visuelle explicite attendue.

### 2026-10-12 - Landing : structure unique et PNG originaux
Cartes en conteneur unique avec Stack/Positioned.fill et image entiere en contain, sans decoupage en colonnes. Cinq nouveaux assets original_*.png copies binaires identiques au ZIP ; aucun detourage, generation ou modification des anciens PNG. Quatre CTA a 24 px sous les descriptions, style/libelles/couleurs preserves. Captures et comparaisons dans reports/landing_structure/, deux tests reussis, analyse ciblee sans probleme. Limites : poignets deja tronques et fonds opaques dans les PNG sources ; non corriges par recreation interdite. Reste de la Landing, Commencer, splash, navigation et espacements globaux preserves. Phase 2 non commencee ; aucun commit, push ou installation. Validation visuelle explicite attendue.

### 2026-10-13 - Instant Recipe AI uniquement : validation attendue
PNG fourni copie identique, fond menthe continu, interieur 40 % texte/CTA et 60 % image en contain. CTA multiligne, ecart description 24 px, scans inactifs preserves. Quatre captures Flutter FR/DE 320/390 : reports/landing_instant_phase2/. Quatre tests reussis, proportions et absence de debordement controles. Autres cartes, header, Commencer, splash et espacements preserves. Coupure source de l avant-bras visible. Aucun commit, push, APK, installation ni dependance. Attendre validation explicite de Simo.

2026-10-13 : nouvel essai demande par Simo, Instant Recipe AI uniquement en 50/50. Quatre captures trial50_FR/DE_320/390 dans reports/landing_instant_phase2/, quatre tests reussis. PNG et autres cartes preserves ; aucun commit, push ni installation. Validation attendue.

2026-10-13 : essai 50/50 ajuste sur demande de Simo : illustration alignee au bord inferieur sans recadrage, contenu du CTA centre horizontalement et verticalement. Quatre captures bottom_center_FR/DE_320/390, quatre tests reussis (image au bord inferieur incluse). PNG et autres cartes inchanges. Validation attendue ; aucun commit, push ni installation.

2026-10-13 : CTA Instant Recipe AI court sous 390 px (Scanner en FR, traduction existante dans les autres langues), complet a 390 px. Quatre captures short320_FR/DE_320/390 et quatre controles Flutter reussis. Alignement inferieur et 50/50 preserves. Validation attendue. Aucun commit, push ni installation.

2026-10-13 : variante verticale demandee par Simo sur Instant Recipe AI seulement : texte et CTA en haut pleine largeur, PNG entier centre en bas (75 % de la largeur interieure), avant-bras au bord inferieur. CTA court a 320, complet a 390. Quatre captures vertical_FR/DE_320/390 et quatre controles Flutter reussis, image sous CTA sans chevauchement. Autres cartes et espacements preserves, aucune retouche PNG, commit, push ni installation. Variante en attente de validation.

2026-10-13 : variante verticale avec le meme CTA complet a 320 et 390 px, Scanner mon frigo en francais et traductions existantes. Quatre captures vertical_fullcta_FR/DE_320/390 ; quatre controles Flutter reussis. Aucun autre changement visuel ni comportemental. Validation attendue.

2026-10-13 : correction de l alignement du header demandee sur image annotee : retrait gauche uniformise a 14 px a 320/390, aligne sur le bord des cartes. Logo, titre et avantages deplaces ensemble ; photo et cartes preserves. Quatre captures aligned_header_FR/DE_320/390 et quatre controles Flutter reussis. Validation attendue ; aucun commit, push ni installation.

2026-10-13 : aeration demandee : header logo/titre 14 px, titre/avantages 18 px, avantages espaces de 10 px et interligne 16. Instant Recipe AI : badge/titre 8 px, titre/description 10 px, interlignes titre 20 et description 17 ; description/CTA conserve a 24 px. Autres cartes et espacements entre cartes inchanges. Quatre captures airy_FR/DE_320/390, quatre controles Flutter reussis. Validation attendue, aucune installation ni commit/push.

2026-10-13 : bouton Instant Recipe AI entier reduit a 85 % de la largeur interieure et centre a 320/390. Quatre captures narrow_cta_FR/DE_320/390, quatre controles Flutter reussis dont largeur et centrage. Autres boutons inchanges, validation attendue. Aucun commit, push ni installation.

2026-10-13 : modèle vertical Instant Recipe AI validé par Simo et appliqué aux quatre autres cartes avec les derniers PNG fournis, copies identiques. Quatre CTA centrés à 85 %, images entières sous les textes, Suivi sans CTA, couleurs/bordures et espacements préservés. Captures FR/DE 320/390 dans reports/landing_all_vertical/. Quatre tests réussis, analyse ciblée sans anomalie ; header et Instant Recipe AI identiques pixel par pixel aux captures validées. Limites des PNG inchangées (bras coupés, inscriptions incorporées, franges). Aucun commit, push, APK, installation ni dépendance. Attendre validation des quatre cartes.

2026-10-13 : padding interieur uniforme demande par Simo : 20 px gauche, droite, haut et bas sur les cinq cartes a 320/390. Image conservee entiere, desormais a 20 px du bord inferieur ; CTA a 85 % de la nouvelle largeur interieure. Quatre captures padding20_FR/DE_320/390 et quatre controles Flutter reussis. Marge exterieure et espacement entre cartes inchanges. Validation attendue ; aucun commit, push ni installation.

2026-10-13 : Simo demande aussi 20 px ENTRE les cartes. LandingTokens.cardGap passe a 20 px ; padding interieur 20 px conserve. Quatre tests Flutter reussis, quatre ecarts mesures a 20 px en FR/DE 320/390. Captures gap20 dans reports/landing_all_vertical/. Validation attendue, aucun commit, push ni installation.

2026-10-13 : cartes raccourcies sur demande de Simo : padding bas retire et lignes transparentes inferieures des PNG exclues de la hauteur du cadre Flutter, sans modifier les pixels ni couper un objet. Avant-bras des scans au bord inferieur ; autres images alignees sur leur derniere ligne non transparente. Marges haut/gauche/droite 20 px et espaces inter-cartes 20 px preserves. Quatre captures compact_FR/DE_320/390, quatre controles Flutter reussis. Aucun commit, push ni installation, validation attendue.

2026-10-13 : marges exterieures ecran/cartes passees a 24 px gauche/droite sur demande de Simo, espaces entre cartes maintenus a 20 px. Padding interieur haut/gauche/droite 20 px, bas compact conserve. Quatre captures inset24_FR/DE_320/390, quatre controles Flutter reussis dont marges externes 24 et espaces inter-cartes 20. Validation attendue ; aucun commit, push ni installation.

2026-10-13 : remplacement des cinq visuels par les fichiers fournis 12_57_20/28/41/52 et 12_58_05. Copies binaires identiques, anciennes images conservees. Dimensions et lignes transparentes inferieures des nouveaux PNG prises en compte par Flutter, sans retouche ni recadrage des objets. Design, CTA, navigation, header et marges 24 px / ecarts 20 px preserves. Quatre captures replacement_FR/DE_320/390 dans reports/landing_replacement_1258/, quatre tests reussis. Frigo et Suivi visuellement plus petits a cause des nouveaux cadrages. Aucune installation Android, commit ni push ; attendre validation visuelle avant installation.

2026-10-13 : agrandissement demande de la premiere illustration uniquement : cadre Instant Recipe AI a 100 % de la largeur interieure au lieu de 75 %, soit +33 %. Image entiere sans retouche ni recadrage ; autres cartes conservees. Quatre captures zoom_scan_FR/DE_320/390 et quatre controles Flutter reussis. Aucune installation, commit ni push ; validation attendue.

2026-10-13 : zoom supplementaire demande sur Instant Recipe AI uniquement : echelle 1,20 de la largeur interieure, +20 % par rapport a l essai precedent. Le cadre PNG deborde uniquement dans ses marges transparentes ; objets entiers preserves. Quatre captures zoom_scan120_FR/DE_320/390 et quatre controles Flutter reussis. Autres cartes inchangees ; aucune installation, commit ni push. Validation attendue.

2026-10-13 : premiere illustration centree horizontalement sur la silhouette principale frigo/main (centre x819 dans PNG 1448 px) par translation Flutter, sans retouche. Zoom 1,20 preserve ; autres cartes inchangees. Quatre captures zoom_scan_centered_FR/DE_320/390 et quatre controles Flutter reussis incluant centrage mesure. Aucune installation, commit ni push ; validation attendue.

2026-10-13 : CaliScan agrandi et centre sur demande de Simo. Echelle cible 1,20 comme Instant Recipe AI, limitee a 390 pour garder la silhouette et les badges dans la carte (centre source x727/1448). Image entiere en contain, PNG intact, autres cartes preservees. Quatre captures zoom_cali_centered_FR/DE_320/390 et quatre tests reussis. Aucune installation, commit ni push ; validation attendue.

CaliScan : limite finale du zoom ajustee aux deux largeurs pour que meme les pixels du bord du PNG restent dans la carte ; quatre controles Flutter reussis (PNG entier contenu inclus). Captures zoom_cali_centered remplacees par cette version finale.

2026-10-13 : Menus, Courses et Suivi agrandis et centres sur demande de Simo, echelle cible 1,20 limitee pour contenir tout le PNG dans la carte. Aucun chevauchement avec CTA (cadre image 12 px sous bouton), Suivi sans CTA. Premiere carte et CaliScan preserves. Quatre captures zoom_all_centered_FR/DE_320/390, quatre controles Flutter reussis incluant limites horizontales, centrage et espaces CTA. PNG intacts ; aucune installation, commit ni push, validation attendue.

2026-10-13 : variante de fonds demandee par Simo pour visualisation : Instant Recipe D5E4DA, CaliScan D2DFEA, Menus D3E3E5, Courses D8E6DC, Suivi D9D5EB. Captures contrast_palette_FR/DE_320/390, quatre controles Flutter reussis. Dimensions, images et CTA preserves ; aucune installation, commit ni push. Palette en attente de validation.

2026-10-13 : palette G tres claire validee et appliquee : E4F7ED/E6F3FE/FFF0E2/FFEDF3/F1EBFC pour Instant Recipe/CaliScan/Menus/Courses/Suivi. Quatre captures palette_g_light_FR/DE_320/390, quatre controles Flutter reussis. Images, CTA et espacements inchanges. Aucune installation, commit ni push.

2026-10-13 : fonds fortement eclaircis sur demande de Simo : F4FCF8/F5FAFF/FFF9F3/FFF8FA/FAF7FE. Quatre captures palette_g_faint_FR/DE_320/390 et quatre tests Flutter reussis. Images, CTA et espacements preserves. Aucune installation, commit ni push ; validation du rendu attendue.

2026-10-13 : bordures legerement plus colorees demandees par Simo, epaisseur conservee : B5DFCC/B4D5F2/F0CEAE/F0BFD0/D6C5EF. Fonds presque blancs preserves, ainsi que dimensions/CTA/images. Quatre captures soft_color_borders_FR/DE_320/390 et quatre tests Flutter reussis. Aucune installation, commit ni push ; validation attendue.

2026-10-13 : typographie Landing agrandie sur demande de Simo : titres cartes 17 px, descriptions 13, CTA 13 et icones 18 (hauteur mini 38), capsules 14 et icones 16 (padding 10/4), titre header 23/25 et avantages 12. Interlignes adaptes 24/20, Commencer 16 px hauteur44. Largeurs et espaces icone/texte des avantages adaptes aux mots allemands. Quatre captures larger_type_FR/DE_320/390 et quatre tests reussis (CTA >=38, limites et navigation). Fonds/bordures/PNG intacts, espaces entre cartes20 et marges ecran24 preserves. Aucune installation, commit ni push ; validation attendue.

2026-10-13 : description Suivi enrichie sur demande de Simo (budget/calories/apports, evolution poids/habitudes, objectifs) et adaptee en six langues existantes. Traductions Flutter regenerees localement. Quatre captures tracking_description_FR/DE_320/390 et quatre tests reussis ; Suivi sans CTA preserve. Aucune installation, commit ni push ; validation attendue.

2026-10-13 : description Suivi remplacee par le texte exact fourni par Simo, traductions adaptees. Graphiques rapproches : espace Flutter 6 px au lieu de12, 103 lignes entierement transparentes du haut du PNG exclues du cadre de mise en page, sans retouche ni coupe visible. Quatre captures tracking_final_FR/DE_320/390 et quatre tests reussis. Autres cartes preservees ; aucune installation, commit ni push. Validation attendue.

2026-10-13 : Suivi resserre en haut/bas autour du visuel sur demande de Simo : cadre Flutter limite aux lignes235..840 du PNG (graphiques principaux et ombres conserves), sans toucher au fichier ni a l echelle. Texte et autres cartes preserves ; quatre captures tracking_tighter_FR/DE_320/390 et quatre tests reussis. Aucune installation, commit ni push ; validation attendue.

2026-10-13 : description Suivi remplacee par le dernier texte exact fourni (Suivez votre poids...), traductions mises a jour. Mise en page resserree conservee ; quatre captures tracking_short_FR/DE_320/390 et quatre tests Flutter reussis. Aucune installation, commit ni push.

2026-10-13 : descriptions des quatre cartes hors Suivi raccourcies et organisees en trois lignes, traductions adaptees dans les six langues existantes. Quatre captures descriptions_three_lines_FR/DE_320/390 et quatre controles Flutter reussis avec mesure exacte de trois lignes dans les quatre descriptions. Suivi et mise en page preserves ; aucune installation, commit ni push. Validation attendue.

2026-10-13 : clarification Simo : descriptions enrichies, sans retours a la ligne imposes, priorite390. Quatre descriptions francaises mesurees exactement sur trois lignes a390, retours naturels et hauteur libre a320 ; traductions naturelles mises a jour. Suivi preserve. Quatre captures descriptions_natural_FR/DE_320/390 et quatre tests reussis. Aucune installation, commit ni push ; validation attendue.

2026-10-13 : arrondi des cinq cartes Landing passe de9 a12 px sur demande de Simo, identique a320/390. Aucun autre changement, aucune installation ni commit/push.

2026-10-13 : debordement de l avant-bras CaliScan dans le coin inferieur gauche signale par Simo : contenu de cette carte limite a son contour arrondi12 via clip antiAlias, PNG intact. Quatre captures cali_clip12_FR/DE_320/390 et quatre controles Flutter reussis. Autres cartes preservees ; aucune installation, commit ni push. Validation attendue.

2026-10-13 : espace vertical entre cartes Landing passe de20 a16 px sur demande de Simo. Marges exterieures et padding interieur preserves. Aucune installation, commit ni push.

2026-10-13 : fond global Landing F2F3F6 demande par Simo ; fonds des cartes, espacements16 et autres ecrans preserves. Aucune installation, commit ni push.

2026-10-13 : fond global Landing eclairci deF2F3F6 aF8F9FB sur demande de Simo. Cartes et mise en page preservees. Aucune installation, commit ni push.

2026-10-13 : hero Landing sans marge droite (end0), abaisse de8 px (top44). Icones avantages alignees sur le bord gauche cartes24 px par retrait local10, logo et titre preserves. Quatre captures hero_alignment_FR/DE_320/390 et quatre tests Flutter reussis. Aucune installation, commit ni push ; validation attendue.

2026-10-13 : hero Landing remplace par Bol de saumon grille et quinoa frais.png fourni par Simo, copie binaire identique dans hero_salmon_20261013.png. Position actuelle preservee (top44, end0), autres elements inchanges. Quatre captures hero_salmon_FR/DE_320/390 et quatre tests Flutter reussis. Aucune installation, commit ni push ; validation attendue.

2026-10-13 : branche decorative du coin superieur droit Landing retiree sur demande de Simo. PNG hero et ses feuilles integrees preserves. Aucune installation, commit ni push.

2026-10-13 : hero saumon agrandi (180/220 px FR a320/390), ancien ShaderMask supprime pour afficher tout le PNG sans coupure haut/bas. Position droite0/top44 preservee ; taille allemande150/200 pour eviter les feuilles sur les textes plus longs. Quatre captures hero_zoom_full_FR/DE_320/390 et quatre tests reussis. Aucune installation, commit ni push ; validation attendue.

2026-10-13 : marges exterieures gauche/droite Landing passees de24 a20 px sur demande de Simo. Espace entre cartes16 px preserve, aucune installation ni commit/push.

2026-10-13 : banane detouree generee avec imagegen et ajoutee sous le bol, ressource banana_20261013.png dans assets/images/landing. Largeur84, retrait droit24, espace avant premiere carte8 px mesure en FR/DE320/390. Quatre captures hero_banana et quatre tests reussis. Aucun chevauchement avec cartes ; aucune installation, commit ni push. Validation attendue.

2026-10-13 : banane agrandie84 a100 px et remontee (distance carte8 a16), filtrage Flutter high au lieu de low pour lisser la reduction du PNG haute definition. PNG intact. Quatre captures banana_sharp_FR/DE_320/390 et quatre tests reussis. Aucune installation, commit ni push ; validation attendue.

2026-10-13 : banane remplacee par PNG fourni Banane mure isolee sur fond transparent.png (1254x1254, copie identique). Taille80 px, retrait droit12, ecart premiere carte16 px, filtrehigh ; position adaptee pres du bord inferieur du plat. Quatre captures banana_supplied_FR/DE_320/390 et quatre tests reussis. Autres elements preserves, aucune installation, commit ni push ; validation attendue.

2026-10-13 : quatre bullets de benefices remplaces par la planche PNG fournie (assiette/tirelire/courses/progres). Copie identique benefit_icons_supplied_20261013.png, zones de chaque icone affichees via Flutter sans regeneration ni alteration des pixels. Tailles et alignements preserves, filtrehigh. Quatre captures benefit_icons_supplied_FR/DE_320/390 et quatre tests reussis. Aucune installation, commit ni push ; validation attendue.

2026-10-13 : installation demandee par Simo : APK debug compile avec succes, installation adb --no-streaming -r Success sur Xiaomi XIAOMI_TEST_DEVICE (2201117PG), lancement Status ok. Capture android_installed_current.png. Aucun changement du design durant cette operation, aucun commit/push. Attendre retour visuel de Simo.

2026-10-13 : quatre icones benefices agrandies de20 % sur demande de Simo. PNG source preserve, autres visuels inchanges. Quatre captures benefit_icons_larger_FR/DE_320/390 et quatre tests reussis. Aucune nouvelle installation, commit ni push ; validation attendue.

2026-10-13 : installation demandee apres agrandissement des icones benefices20 % : APK debug compile avec succes, adb install --no-streaming -r Success sur Xiaomi XIAOMI_TEST_DEVICE, lancement Status ok. Capture android_icons_larger_installed.png. Aucun changement du design durant installation, aucun commit/push. Attendre retour visuel de Simo.

2026-10-13 : textes benefices13 px et CTA14 px appliques sur demande de Simo, autres tailles preservees. Quatre captures benefits13_cta14_FR/DE_320/390 et quatre tests Flutter reussis. Aucune nouvelle installation, commit ni push ; validation attendue.

2026-10-13 : installation demandee de la version benefices13 / CTA14 : compilation APK debug reussie, installation adb -r Success sur Xiaomi XIAOMI_TEST_DEVICE, lancement Status ok et capture android_benefits13_cta14.png. Design preserve, aucun commit/push ; attendre retour de Simo.

2026-10-13 : icones benefices encore agrandies sur demande de Simo, echelle1,45 au lieu de1,20 (+21 % par rapport a la version installee). Quatre captures benefit_icons145_FR/DE_320/390 et quatre tests Flutter reussis. Aucune installation, commit ni push ; validation attendue.

2026-10-13 : installation demandee de la version icones benefices echelle1,45 : compilation debug reussie, adb install -r Success sur Xiaomi XIAOMI_TEST_DEVICE, lancement Status ok, capture android_benefit_icons145.png. Aucun changement de design pendant installation ni commit/push ; attendre retour Simo.


## Langues — 13 octobre 2026, correction autorisée

Cinq langues actives : FR, EN, ES, IT, DE. Persistance locale via shared_preferences autorisée explicitement ; quatre débordements ES/IT de couvertures corrigés sans réduire les polices. Landing/ressources/ARB inchangés (300 empreintes) et six captures FR/EN/DE identiques. 93 tests ciblés réussis, reprise et i18n contrôlés ; 11 écarts visuels historiques hors Landing restent. Rapport détaillé : reports/languages_five/REPORT.md. Validation native de reprise en attente d’une installation autorisée. Étape 2 Supabase toujours en attente.

## Jalon produit 6 — contrôle Android Solo, 14 octobre 2026

Mise à jour Android autorisée et réussie sur Xiaomi 2201117PG, signature identique et répertoire de données conservé, sans désinstallation. Onze étapes Solo parcourues avec données fictives ; reprises après arrêt forcé aux étapes 2, 6, 8 et 11, dont budget et récapitulatif hors connexion. Langue allemande persistante, français et Wi-Fi rétablis. Entrée Famille 1/9 contrôlée sans modification des membres ; parcours complet Famille et largeur 320 px non rejoués. Aucun raccordement Réserve/Famille ni Supabase. Rapport : reports/solo_android/REPORT.md. Validation finale en attente ; arrêt du développement.
