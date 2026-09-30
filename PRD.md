# PRD — Menoo, planificateur de repas intelligent
**Version :** 1.2 (proposée le 2026-09-30, en attente de validation) · **Statut :** pré-lancement, en développement
**Référence d'implémentation :** `SPEC.md` (flux, liaisons et corrections écran par écran)

---

## 1. Vision

Menoo répond à deux moments :
- **« Que mange-t-on cette semaine ? »** — la planification : un menu sous contraintes (budget, régimes, niveau en cuisine, temps, équipement), puis la liste de courses, réserve déduite.
- **« Que mange-t-on ce soir ? »** — l'improvisation : une recette du catalogue faisable tout de suite avec ce qu'il y a dans le frigo et les placards.

**Promesse :** « Mangez mieux, dépensez moins, sans prise de tête. »
**Règle d'or :** le budget de la semaine n'est jamais dépassé.
**Règle de confiance :** l'IA ne crée rien. Elle reconnaît des ingrédients et choisit dans un catalogue aux macros vérifiées, aux prix connus et aux photos existantes.

Aucun chiffre d'économie, de note ou de nombre d'utilisateurs n'est affiché sans donnée réelle ou source publique citée.

## 2. Objectifs et KPIs (cibles à 6 mois après lancement)

| Objectif | KPI | Cible |
|---|---|---|
| Activation | Première valeur obtenue (1re recette improvisée ou 1er menu généré) | > 60 % |
| Pont improvisation → planification | Utilisateurs d'improvisation qui génèrent un menu de semaine sous 14 jours | > 30 % |
| Engagement | Rétention J30 | > 25 % |
| Budget | Semaines dans le budget | > 90 % |
| Anti-gaspi | Alertes de péremption traitées | > 70 % |
| Monétisation | Conversion gratuit → payant (abonnement ou achat à l'unité) | > 5 % |
| Monétisation | Part de l'abonnement dans le revenu (contre l'achat à l'unité) | à suivre |

## 3. Personas

- **Camille (Solo)** : végétarienne, sans lactose, sportive, peu de temps le soir, budget 65 €/semaine.
- **Famille Martin (Foyer)** : Thomas, Sarah, Lucas et Emma, goûts différents, budget 110 €/semaine, courses le week-end.
- **Le pressé du soir** : ouvre l'app à 19 h, frigo à moitié plein, ne veut ni s'inscrire ni répondre à 12 questions. Entre par l'improvisation.

## 4. Parcours

### 4.1 Entrée
Landing déroulante (la promesse, 4 avantages, 4 cartes de fonctions sans bouton, un seul bouton « Commencer ») → Choix du mode (Solo / Foyer), avec une ligne légère « Improviser avec ce que j'ai ».

### 4.2 Onboarding Solo (12 étapes)
Objectif → Profil → Activité → Balance (option) → Grille des repas → **Budget** → Mode de gestion (*détour Réserve si Mixte ou Réserves*) → Contraintes → Types de cuisine → **Ma cuisine** → Enseigne → Récapitulatif.

### 4.3 Onboarding Foyer (10 étapes)
Composition du foyer → Profils des membres → Grille des repas → **Budget** → Contraintes → Mode de gestion (*détour Réserve*) → Types de cuisine → **Ma cuisine** (+ qui cuisine) → Enseigne → Récapitulatif.

### 4.4 Écrans de réassurance
5 écrans hors compteur, intercalés : trajectoire de poids, métabolisme, économies, gaspillage évité, plan prêt. Ils ne montrent que les réponses de l'utilisateur ou une source publique citée. Jamais de silhouette avant/après.

### 4.5 Le compte après la valeur
L'utilisateur obtient sa recette ou son menu **avant** qu'on lui demande un compte. Le bouton Google est une sauvegarde (« Gardez cette recette et votre réserve »), « Plus tard » reste toujours visible. Ce qui a été créé avant le compte est conservé à sa création.

### 4.6 Improvisation (6 étapes)
Scan ou sélection manuelle → convives → condiments (6 à 8 cases) → équipement → choix de cuisine (disponible / presque / indisponible) → la recette.
Trois portes : ligne sous le choix du mode, cercle animé de l'Accueil quand aucun repas n'est prévu, onglet Réserve en permanence.

### 4.7 App — 5 onglets
- **Accueil :** carte du jour (ou cercle d'improvisation), puis extraits Budget, Nutrition et Performance, puis une alerte.
- **Menus :** grille ou liste des repas → fiche recette → mode cuisine pas-à-pas → validation.
- **Courses :** liste par rayon (réserve déduite) → mode magasin, partage, impression, PDF, texte.
- **Réserve :** stock, ajout manuel / code-barres / photo IA, alertes de péremption, recettes anti-gaspi, improvisation.
- **Suivi :** sous-onglets Budget | Nutrition | Performance.

Les réglages sont accessibles via l'avatar. La barre de navigation n'apparaît qu'après la création du compte.

## 5. Fonctionnalités clés

### 5.1 Budget
- Curseur de 20 € à 350 €, avec un champ « budget personnalisé » au-delà.
- Valeur de départ calculée selon le foyer (30 € par adulte, 20 € par enfant, 25 € par bébé).
- Coût estimé du menu affiché en permanence, avec le badge « Dans le budget ✓ », ou « Estimation dans votre budget » quand les prix sont estimés.

### 5.2 Ma cuisine
- Niveau en cuisine, temps disponible (semaine et week-end), équipements disponibles.
- En Foyer : la personne qui cuisine le plus souvent.
- Ces choix filtrent strictement les recettes proposées.

### 5.3 Génération du menu
- **Pré-filtrage en base :** régimes, allergènes, équipement, temps et niveau.
- **Composition de la semaine par l'IA,** sur la liste pré-filtrée du catalogue.
- **Vérification du coût total,** avec regénération si le budget est dépassé.

### 5.4 Improvisation
- **Reconnaissance** des ingrédients par photo (Premium) ou sélection manuelle (gratuite).
- **Correspondance dans le catalogue** selon ingrédients, condiments, équipement et convives.
- **Trois états par cuisine :** disponible, presque (1 ou 2 éléments manquants, affichés), indisponible (raison affichée).
- **Dernier recours :** recette générée librement, marquée comme telle, hors budget garanti.
- **Réserve mise à jour** par le scan : ajouts, retraits confirmés, périmés en rouge d'après les dates en base.

### 5.5 Réserve et anti-gaspillage
- **Ajout de produits :** manuel et code-barres (gratuits), photo analysée par l'IA (Premium).
- **Alertes :** péremption à J-1, J-2 et J-3.
- **Recettes anti-gaspi :** basées sur les produits urgents.

### 5.6 Courses
- **Liste de la semaine :** calculée à partir des besoins, réserve déduite, triée par rayon.
- **Mode magasin :** cases à cocher, total qui se met à jour, écran qui reste allumé.
- **Sorties :** partager, imprimer en A4, exporter en PDF, copier en texte.
- **Enseigne :** sert aux prix et au tri par rayon, rien d'autre.
- **Prix en trois niveaux, origine toujours affichée :** estimation (référence France ajustée par un indice public cité), communautaire (Open Prices), réel (tickets scannés).

### 5.7 Suivi
- **Budget :** dépenses prévues vs réelles.
- **Nutrition :** calories et macros, par membre en mode Foyer.
- **Régime (Solo) :** courbe de poids, balance via Health Connect, saisie manuelle.
- **Anti-gaspillage (Foyer) :** part de la réserve valorisée, euros épargnés.

### 5.8 Monétisation
- **Principe :** l'abonnement achète du confort, pas l'accès. Saisie manuelle et code-barres gratuits ; photo IA réservée aux abonnés, **après un scan offert par appareil** — sans lui, la promesse « Scan IA » de la Landing serait trompeuse.
- **Gratuit :** un scan photo offert par appareil ; un repas offert par semaine ; ingrédients et ustensiles de chaque recette ; les 3 premières lignes des instructions ; le premier rayon de la liste de courses. Le paywall n'arrive jamais avant que l'utilisateur ait vu son écran.
- **Payant :** 0,90 € la recette ; lots de 5 et 15 recettes ; 9,99 €/mois résiliable à tout moment ; 49,99 €/an.
- **Jamais de carte bancaire pour essayer**, donc **pas d'essai de 7 jours** : le scan offert et le repas offert tiennent ce rôle. Résiliation simple dans l'app, via Google Play Billing (RevenueCat).

### 5.9 International
- 6 langues au lancement : français, anglais, espagnol, allemand, italien, arabe (écriture de droite à gauche).
- Textes de l'app et contenus (recettes, ingrédients, catégories, allergènes, régimes, cuisines, équipements) traduits ; français en référence.
- **Allergènes et régimes : relecture obligatoire par une personne dont c'est la langue** avant publication (risque de santé). Traduction automatique pour tout le reste.
- Unités métriques par défaut, impériales aux États-Unis ; devises et dates selon le pays.
- Enseignes : liste en France, champ libre ailleurs.

## 6. Design
Design system v2 (voir `design/DESIGN_V2.md` et les écrans maîtres). Le rendu est premium et doux :
- **fond et surfaces :** fond ivoire, cartes blanches arrondies, pastilles pastel ;
- **couleurs :** vert #0B6B43 pour les actions, orange #F58A1F en accent uniquement ;
- **typographie :** Plus Jakarta Sans (et une police compatible pour l'arabe) ;
- **navigation :** une seule barre, Accueil · Menus · Courses · Réserve · Suivi ;
- **une seule forme ronde :** le cercle d'improvisation de l'Accueil.

## 7. Technique
- **Application :** Flutter (Android en premier), internationalisée.
- **Back-end :** Supabase (Postgres, RLS, Edge Functions, pg_cron), compte invité converti à l'inscription.
- **IA :** API LLM, appelée via les Edge Functions ; reconnaissance d'ingrédients et composition dans le catalogue.
- **Services tiers :** Open Food Facts et Open Prices, Health Connect, RevenueCat, Firebase Analytics.
- **Anti-fraude (avant publication) :** identifiant d'appareil côté serveur et Play Integrity, vérifiés avant tout appel à l'IA.
- **Conformité :** RGPD (données de santé), suppression du compte dans l'app, formulaire Sécurité des données de Google Play, politique de confidentialité à jour.

## 8. Roadmap
- **Phase 1 :** MVP Android international : les deux parcours, l'improvisation, la génération sous budget, la réserve, les courses (mode magasin et exports) et le paywall. Catalogue de départ : **12 à 15 recettes par cuisine sur 8 cuisines, soit environ 120**.
- **Phase 2 :** liste de courses partagée en temps réel au sein du foyer ; montée du catalogue vers 500 recettes, une fois qu'il y a des utilisateurs.
- **Phase 3 :** version iOS et assistant vocal en cuisine.
