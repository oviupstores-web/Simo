# MENOO — JALON 6
## Contrat définitif SQLite → Supabase
**Contrat :** `menoo.guest-import`  
**Version :** 1  
**Date :** 22 octobre 2026  
**Statut :** Spécification validée sur le plan fonctionnel — implémentation et conformité SQL à vérifier en phase 2

---

## 1. Objectif

Permettre à un utilisateur Menoo de terminer son onboarding, créer ou utiliser un compte authentifié et transférer ses données métier locales vers Supabase.

Le transfert doit être fidèle, sécurisé, transactionnel, reproductible sans doublons et récupérable après interruption.

Aucune donnée locale ne doit être supprimée, réinitialisée ou écrasée automatiquement.

## 2. Organisation des comptes et des menus

### Parcours Solo

- Un compte utilise un foyer technique de type Solo.
- Le profil Solo est le bénéficiaire du menu personnalisé.
- Le menu respecte ses contraintes alimentaires, son budget et ses paramètres.

### Parcours Famille

- Un compte possède un foyer actif pour la V1.
- Le foyer comporte plusieurs membres.
- Un seul planning hebdomadaire commun est généré pour le foyer.
- Une seule recette par catégorie de repas est retenue pour tous les convives concernés.
- Les portions peuvent varier selon la composition du foyer.
- Les allergies individuelles sont prises en compte dans les contraintes du repas commun.
- Les régimes, restrictions et exclusions actuellement collectés au niveau du foyer s'appliquent à tous.

Les allergies restent attachées à leurs membres d'origine. Elles ne sont jamais recopiées artificiellement dans les profils des autres membres.

Le nombre de foyers historiquement présents dans la base ne doit pas être réduit par une suppression ou une contrainte destructive. La V1 autorise un seul foyer actif et n'ajoute pas automatiquement de foyer à un compte déjà rempli.

## 3. Parcours importé

Les brouillons locaux sont indépendants :

- `guest.solo`
- `guest.family`

À l'inscription, seul le parcours explicitement choisi est importé.

L'autre brouillon est conservé localement, avec ses réponses, produits et formulaires provisoires.

Les identifiants `guest.solo` et `guest.family` ne sont ni des identifiants de comptes Supabase ni des identifiants uniques entre appareils.

## 4. Données métier à importer

### Solo

- Mode de parcours et mode de gestion.
- Données du profil nécessaires au service.
- Objectifs et paramètres nutritionnels applicables.
- Régimes, allergies et exclusions.
- Budget et devise.
- Créneaux hebdomadaires sélectionnés.
- Préférences culinaires.
- Niveau, temps et équipements de cuisine.
- Préférence déclarée de connexion à une balance.
- Produits Réserve validés.

### Famille

- Mode de parcours et de gestion.
- Composition du foyer.
- Membres enregistrés et leurs attributs réellement collectés.
- Allergies individuelles avec identité du membre concerné.
- Régimes, restrictions, allergies communes et exclusions déclarés pour le foyer.
- Cuisinier principal, s'il est défini.
- Budget et devise.
- Créneaux hebdomadaires.
- Préférences culinaires et équipements.
- Règles de portions versionnées.
- Produits Réserve validés.

Aucun attribut non collecté ne doit être inventé.

Les données métier enregistrées doivent passer une validation de complétude et de cohérence avant l'import. Leur simple présence dans un brouillon ne prouve pas que l'onboarding est terminé.

## 5. Données restant locales

Ne sont pas importés automatiquement :

- Historique et pile de navigation.
- Étape courante et indicateurs de reprise.
- Champs bruts incomplets.
- Membre en cours d'édition.
- Formulaire manuel Réserve incomplet.
- Sélections rapides non confirmées.
- Compteurs et identifiants techniques de navigation.
- Valeurs historiques devenues inactives.
- Extensions inconnues ne disposant pas d'un contrat de transfert validé.

L'utilisateur est averti avant import lorsque des saisies provisoires existent.

Seules les données métier admissibles sont transférées. Les travaux provisoires restent disponibles localement et ne sont pas considérés comme transférés.

## 6. Contraintes alimentaires

Le modèle logique distingue :

1. Les allergies propres à chaque membre.
2. Les régimes, restrictions, allergies communes et exclusions du foyer.
3. Les contraintes effectives calculées pour le repas commun.

Les contraintes effectives sont calculées à partir des déclarations sources. Il n'est pas nécessaire de stocker une troisième copie permanente susceptible de devenir incohérente.

Toute restriction obligatoire doit être respectée. Si aucune recette compatible n'est disponible, Menoo signale cette impossibilité.

Pour la V1, aucune interface supplémentaire de régimes ou d'interdictions individuels par membre n'est créée. Ces données ne sont pas actuellement collectées de manière complète dans le parcours Famille.

## 7. Entrées, plats et desserts

Le planning actuel enregistre les jours et les moments de repas : petit-déjeuner, déjeuner et dîner.

Le choix détaillé des catégories entrée, plat principal et dessert sera défini lors du développement du générateur.

Le transfert V1 conserve uniquement les créneaux réellement enregistrés.

Il ne crée aucune sélection de catégorie fictive.

Le futur schéma de composition des repas devra pouvoir représenter plusieurs recettes distinctes au sein d'un même créneau, tout en conservant un menu commun au foyer.

## 8. Quantités et portions

Les règles Famille existantes sont préservées :

- Adulte : facteur 1.
- Enfant : facteur 0,65.
- Bébé : facteur 0,3.
- Version des règles : 1.

Deux notions restent distinctes :

- Le nombre de repas servis aux membres.
- La quantité de portions pondérées servant au dimensionnement des recettes.

Aucun arrondi implicite ne doit convertir l'une en l'autre.

## 9. Budget et devise

Le montant et sa devise forment une seule donnée métier.

Règles :

- La devise n'est jamais déduite de la langue.
- Aucune conversion de change pendant l'import.
- Les montants sont transformés exactement selon les unités monétaires applicables.
- Les valeurs absentes, inconnues ou contradictoires bloquent l'import jusqu'à clarification.
- Aucun montant non représentable n'est arrondi ou tronqué silencieusement.

Le schéma Supabase devra disposer d'une représentation monétaire complète.

## 10. Réserve alimentaire

Chaque produit validé conserve :

- Son identité locale de lot.
- Son nom.
- Sa quantité, si présente.
- Son unité et son libellé.
- Son emplacement.
- Sa date civile de péremption, si présente.
- L'origine de cette date.
- Sa provenance.
- Son identifiant alimentaire local éventuel.
- Ses informations de stock qualitatif.

### Catégories réellement enregistrées

Le produit validé `PantryProductRecord` ne possède pas de champ dédié à la catégorie du formulaire manuel (`FoodCategory`). Les champs `category` et `proposedCategory` appartiennent au checkpoint provisoire du formulaire ; ils ne constituent pas une catégorie persistée dans le produit validé et ne doivent pas être utilisés pour lui en attribuer une lors du transfert.

`declaredCategory` (`QuickCategory?`) et `declaredStock` (`QuickStock?`) sont, en revanche, persistés par `PantryCodec`. Lorsqu'ils sont effectivement renseignés dans le produit enregistré, leurs valeurs doivent être transférées et préservées exactement. Lorsqu'ils sont nuls, ils restent nuls.

Une catégorie manuelle absente du produit enregistré ne peut pas être transférée. Aucune catégorie manquante ne doit être inventée ou déduite arbitrairement du nom, de l'emplacement, d'un identifiant alimentaire ou d'un formulaire provisoire.

**Décision à prendre en phase 2 :** déterminer si la catégorie manuelle doit être persistée à l'avenir dans les produits validés. Toute évolution éventuelle nécessitera un périmètre et une compatibilité explicitement validés ; elle ne doit pas reconstituer fictivement la catégorie des anciens produits. Cette précision documentaire n'autorise aucune modification Flutter, SQLite ou SQL.

Une quantité absente ne devient pas zéro.

Un paquet ne devient pas automatiquement une pièce.

Un stock indiqué comme présent ou partiel ne devient pas une quantité mesurée inventée.

Les dates civiles sont transférées sans conversion UTC susceptible de changer le jour.

Deux produits portant le même nom peuvent représenter deux lots distincts.

Les identifiants alimentaires locaux ne deviennent pas automatiquement des UUID du catalogue Supabase.

## 11. Compte déjà rempli

Si le compte possède déjà des données métier :

- Aucun import supplémentaire automatique.
- Aucun remplacement.
- Aucune fusion.
- Aucune création automatique d'un second foyer.

L'utilisateur peut :

1. Utiliser les données déjà présentes dans son compte, en conservant le brouillon local.
2. Annuler l'opération et revenir à son parcours local.

Cette décision s'applique même si le compte contient des données mais n'a pas actuellement de foyer actif.

## 12. Identité et inscription

Les informations d'identité nécessaires doivent être confirmées explicitement par l'utilisateur.

Aucun prénom de démonstration ne doit être transféré comme identité réelle.

Le nom du foyer est modifiable et ne doit pas être déduit arbitrairement du prénom du compte.

La création du compte Auth et l'import des données métier sont deux opérations distinctes.

Un compte créé alors que l'import a échoué reste un état récupérable.

## 13. Protocole d'import

Le contrat porte le nom :

`menoo.guest-import`

Version : `1`.

Il comprend au minimum :

- Une identité d'origine locale durable et non ambiguë.
- Le parcours choisi.
- Un identifiant d'opération stable.
- Les versions des modèles sources.
- Un instantané immuable des données métier admissibles.
- Une empreinte canonique du contenu.
- Les données métier à transférer.

L'identité du propriétaire distant est établie depuis la session authentifiée, jamais depuis un identifiant librement fourni par Flutter.

### Séquence obligatoire

1. Confirmer les informations nécessaires à l'inscription.
2. Obtenir une session authentifiée utilisable.
3. Choisir explicitement le parcours à importer.
4. Terminer les sauvegardes locales et vérifier leur réussite.
5. Construire un instantané métier immuable.
6. Vérifier sa complétude et les contraintes obligatoires.
7. Contrôler l'état du compte distant.
8. Effectuer l'import dans une transaction PostgreSQL unique.
9. Enregistrer le reçu d'import dans cette même transaction.
10. Récupérer et vérifier le reçu.
11. Marquer localement cet instantané précis comme importé, sans modifier destructivement son brouillon.

## 14. Sécurité et anti-doublons

Le mécanisme doit garantir :

- Une répétition de la même opération et du même contenu renvoie le même résultat.
- Une opération réutilisée avec un contenu différent est refusée.
- Une autre opération visant à réimporter la même origine ne crée pas de doublon.
- Deux demandes concurrentes ne créent pas deux foyers.
- L'état du compte est revérifié sous protection transactionnelle.
- Aucun transfert vers un autre compte après changement de session.
- Aucune écriture métier partielle.
- Aucune clé privilégiée dans Flutter.
- Permissions SQL et politiques RLS vérifiées avant connexion métier.

La fonction SQL d'import peut suffire si elle garantit correctement l'authentification, les contrôles et la transaction. Une Edge Function n'est ajoutée que si un besoin précis le justifie.

## 15. Reprise après interruption

Si la connexion est perdue après l'envoi, le résultat est considéré comme inconnu jusqu'à confirmation.

Menoo doit retrouver le reçu ou répéter la même opération avec le même identifiant, sans duplication.

Toute modification locale effectuée après la capture de l'instantané reste conservée et ne devient pas automatiquement synchronisée.

Le suivi d'import est distinct du format actuel `LocalDraft`, dont le champ `syncState` reste `localOnly`.

## 16. Préservation des données

Aucune migration destructive de SQLite n'est prévue par ce contrat.

Les brouillons Solo et Famille sont conservés avant, pendant et après l'import.

Aucune suppression automatique des formulaires, produits, membres, archives ou données historiques.

Les deux produits témoins présents sur Xiaomi ne doivent pas être utilisés comme données de test destructives.

## 17. Adaptations Supabase nécessaires

La phase 2 devra concevoir, sans modifier les migrations historiques :

- La devise du budget.
- Une représentation fidèle des produits Réserve.
- Les contraintes alimentaires au niveau du foyer.
- Les exclusions textuelles.
- La provenance des éléments importés.
- Un registre transactionnel anti-doublons.
- Les règles d'intégrité des relations foyer/membres.
- Les validations métier côté serveur.
- Les permissions SQL minimales.
- Les corrections RLS, notamment pour les recettes non publiées.

Les adaptations doivent être non destructives et leurs effets sur les données existantes doivent être contrôlés.

## 18. Validation du contrat

Avant toute intégration Android réelle, les tests devront couvrir :

- Solo et Famille séparément.
- Compte vierge et compte déjà rempli.
- Allergies individuelles et contraintes communes.
- Produits Réserve complets et qualitatifs.
- Quantités, unités, devises et dates exactes.
- Produits et membres possédant des noms identiques.
- Coupure réseau avant, pendant et après l'import.
- Double clic, concurrence et réexécution.
- Changement de compte.
- Échec de lecture ou de déchiffrement.
- Version de stockage inconnue.
- Maintien des formulaires provisoires.
- Refus d'accès entre deux utilisateurs Supabase.

Les essais doivent d'abord utiliser des données fictives dans un environnement isolé.

## 19. Limites explicites de la V1

Ce contrat ne développe pas :

- Une synchronisation permanente entre appareils.
- Une fusion de foyers.
- Plusieurs foyers actifs.
- Des menus différents pour chaque membre.
- Des substitutions individuelles.
- Une sauvegarde distante des formulaires incomplets.
- Le générateur de menus.
- Les catégories détaillées entrée/plat/dessert.
- La facturation ou le paywall.

Ces sujets restent distincts du transfert initial.

## 20. Statut et prochaine phase

**Phase 1 : spécification fonctionnelle finalisée.**

Le contrat constitue la référence proposée pour la préparation technique, mais sa conformité aux migrations SQL devra être confirmée avant implémentation.

**Phase 2 : conception des adaptations Supabase et du plan de sécurité.**

Aucune exécution de migration, aucune modification du code Flutter, aucune intervention Xiaomi et aucun déploiement ne sont autorisés par ce document.

La phase 2 nécessitera une autorisation distincte.