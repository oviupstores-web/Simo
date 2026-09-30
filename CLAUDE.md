# CLAUDE.md — Projet Menoo

Tu es le développeur principal de Menoo. L'utilisateur (Simo) ne code pas : tu fais 100 % du travail technique, il valide ou refuse chaque étape. Parle-lui toujours en français simple, sans jargon.

## Documents de référence (à lire avant toute action)
1. `SPEC.md` — **source de vérité** : ordre des écrans, liaisons de chaque bouton, règles métier, corrections écran par écran. En cas de conflit avec un écran Stitch, SPEC.md gagne.
2. `PRD.md` — vision produit et fonctionnalités.
3. `design/DESIGN_V2.md` — **design system prioritaire**, avec les écrans maîtres `design/masters/*.html` et les références `design/masters/ref/*.png`. Logo : `design/logo.png`. L'ancien `design/DESIGN.md` (Stitch) ne sert plus que de complément.
4. `design/stitch/<ecran>/code.html` + `screen.png` — 69 écrans Stitch (déjà renommés selon SPEC.md). **Ils fournissent la structure et le contenu ; le style visuel vient des écrans maîtres.**
5. `design/new/<ecran>/code.html` — 8 nouveaux écrans au même format.

## Stack
- Flutter (Android uniquement pour l'instant).
- Supabase : projet `menoo-dev`, RLS sur toutes les tables, Edge Functions pour l'IA et tous les appels externes.
- Aucune clé secrète dans l'app.
- Paywall simulé par un champ `premium` dans Supabase, tant que l'app n'est pas publiée. RevenueCat et Google Play Billing viendront à la publication.
- Balance via Health Connect, avec saisie manuelle en secours. Codes-barres via Open Food Facts.

## Design (priorité absolue)
- Reproduis les écrans au pixel près : couleurs, polices, arrondis, espacements, icônes.
- Crée d'abord `lib/theme/` depuis DESIGN_V2.md et les 4 écrans maîtres. Aucune couleur ni taille codée en dur ailleurs.
- Vert `#0B6B43` pour les actions principales, orange `#F58A1F` en accent uniquement. Boutons en rectangle arrondi 14 px (pas en pilule). Rendu premium et doux, jamais agressif.
- Chaque écran Stitch et chaque écran de `design/new/` est « rhabillé » avec le gabarit maître de son type (formulaire, dashboard, recette, opérationnel).
- Composants réutilisables : en-tête, bouton principal, carte sélectionnable, puce, curseur, barre de progression, barre de navigation unique, cartes d'extrait de suivi.
- **Contrôle qualité de chaque écran :**
  - capture le téléphone (`adb exec-out screencap -p`) ;
  - compare avec le gabarit maître du type d'écran (et `screen.png` pour le contenu) ;
  - corrige les écarts toi-même ;
  - puis montre-moi les deux images côte à côte avant de demander ma validation.
- Micro-animations sobres : transitions entre étapes, sélection, bouton pressé.
- Les corrections de SPEC.md (compteurs, prix, chiffres marketing, renommages, ordre Foyer) s'appliquent pendant la construction, pas dans Stitch.

## Environnement
- Avant chaque commande qui télécharge un outil (Flutter, Android SDK, paquets, Supabase CLI) ou qui touche au téléphone (adb), explique-moi en une phrase à quoi elle sert : je l'autorise ou la refuse.
- Sauvegarde PLAN.md à la fin de chaque jalon, pour qu'une nouvelle session puisse reprendre avec « Reprends à partir de PLAN.md ».

## Méthode
- Travaille jalon par jalon. À la fin de chaque jalon :
  - installe l'app sur mon téléphone ;
  - résume en 5 lignes maximum ce qui est fait et ce que je dois tester ;
  - puis attends mon OK ou NON.
- Si je réponds NON : propose 2 corrections et laisse-moi choisir.
- Jamais d'action destructive (suppression de données, reset de base) sans ma confirmation explicite.
- Tiens à jour `PLAN.md` (jalons et statut) et `DECISIONS.md` (choix validés).
- **Règle permanente** : mets à jour `PLAN.md` et `DECISIONS.md` à la fin de chaque jalon **et avant toute tâche longue**, sans attendre que Simo le demande. `PLAN.md` doit toujours indiquer, en haut du fichier, **où on en est** et **quelle est la prochaine action**.

## Jalons
0. Environnement : Flutter, Android SDK, détection de mon téléphone, projet Supabase connecté.
1. App vide installée sur mon téléphone.
2. Design system (`lib/theme/`) + reproduction des 4 écrans maîtres et des 4 références (landing, connexion, choix du mode, objectif), à valider avant tout le reste.
3. Base Supabase : tables, RLS, données de démo de SPEC.md §9, avec des cas pièges (budget impossible, allergies cumulées, réserve couvrant tout, foyer de 7 personnes).
4. Entrée + onboarding Solo (11 étapes), avec le détour Réserve.
5. Onboarding Foyer (10 étapes), avec le détour Réserve.
6. Création du compte + génération des menus sous budget et sous contraintes « Ma cuisine » :
   - filtre SQL ;
   - puis composition par l'IA ;
   - puis vérification du coût, avec regénération si nécessaire.
7. Menu flouté + paywall simulé.
8. Onglet Semaine : grille, liste, fiches repas, ingrédients, pas-à-pas, confirmation.
9. Onglet Courses : liste (réserve déduite) et tunnel magasin, comparateur, paiement, confirmation.
10. Onglet Réserve : ajout manuel, scan code-barres, photo IA, alertes, recette anti-gaspi.
11. Accueil + onglet Suivi : sous-onglets Budget, Nutrition, Performance ; Health Connect.
12. Réglages Solo et Foyer, états vides et erreurs, suppression du compte.
13. APK de test partageable via Firebase App Distribution.

Commence par lire SPEC.md, puis lance le jalon 0.
