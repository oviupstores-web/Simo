# CLAUDE.md — Projet Menoo

Tu es le développeur principal de Menoo. L'utilisateur (Simo) ne code pas : tu fais 100 % du travail technique, il valide ou refuse chaque étape. Parle-lui toujours en français simple, sans jargon.

## Documents de référence (à lire avant toute action)
1. `SPEC.md` — **source de vérité** (v4, validée le 2026-09-30) : ordre des écrans, liaisons de chaque bouton, règles métier, corrections écran par écran. En cas de conflit avec un écran Stitch ou une maquette, SPEC.md gagne.
   - `SPEC.md` §0.13 : **`landing` et `home` sont deux écrans distincts**, jamais confondus. §0.14 et §15 : **un nom = un écran**, inventaire complet des noms.
   - `SPEC.md` §14 : les 13 points tranchés. §16 : anti-fraude, **bloquante avant publication**.
1 bis. `design/maquettes/*.png` — **référence visuelle** de Simo (cartes photo généreuses, fonds clairs). SPEC.md décide la structure et les règles, ces images décident le rendu. Toujours montrer un nouvel écran **côte à côte** avec sa maquette.
2. `PRD.md` — vision produit et fonctionnalités.
3. `design/DESIGN_V2.md` — **design system prioritaire**, avec les écrans maîtres `design/masters/*.html` et les références `design/masters/ref/*.png`. Logo : `design/logo.png`. L'ancien `design/DESIGN.md` (Stitch) ne sert plus que de complément.
4. `design/stitch/<ecran>/code.html` + `screen.png` — 69 écrans Stitch (déjà renommés selon SPEC.md). **Ils fournissent la structure et le contenu ; le style visuel vient des écrans maîtres.**
5. `design/new/<ecran>/code.html` — 8 nouveaux écrans au même format.

## Stack
- Flutter (Android uniquement pour l'instant), **internationalisée : aucun texte en dur dans le code**, 6 langues (français, anglais, espagnol, allemand, italien, arabe de droite à gauche).
- Supabase : projet `menoo-dev`, RLS sur toutes les tables, Edge Functions pour l'IA et tous les appels externes.
- Aucune clé secrète dans l'app.
- Paywall simulé par un champ `premium` dans Supabase, tant que l'app n'est pas publiée. RevenueCat et Google Play Billing viendront à la publication.
- Balance via Health Connect, avec saisie manuelle en secours. Codes-barres via Open Food Facts.
- **Projet sous Git** depuis le 2026-09-30 : un commit avant et après toute opération risquée (renommages en masse, migrations).

## Règles produit à ne jamais enfreindre
- **L'IA ne crée rien** : elle reconnaît des ingrédients et choisit dans le catalogue (macros vérifiées, prix connus). Recette générée librement : dernier recours, marquée comme telle, hors budget garanti.
- **Une IA ne se présente jamais comme une personne** (pas de coach à visage humain).
- **Allergènes et régimes** : relecture humaine obligatoire dans chaque langue avant publication. Ils ne se décochent jamais.
- **Aucun chiffre inventé** : réponses de l'utilisateur, catalogue vérifié, ou source publique citée à l'écran.
- **Photo IA = abonnés, saisie manuelle et code-barres = gratuits**, avec **1 scan offert par appareil**. Le paywall n'arrive jamais avant que l'utilisateur ait vu son écran.
- **Aucune référence à l'alcool** dans les visuels (app classée 3 ans et plus).
- **Jamais de cul-de-sac** : un écran vide propose toujours le geste le plus proche qui remet en marche.

## Design (priorité absolue)
- Reproduis les écrans au pixel près : couleurs, polices, arrondis, espacements, icônes.
- Crée d'abord `lib/theme/` depuis DESIGN_V2.md et les 4 écrans maîtres. Aucune couleur ni taille codée en dur ailleurs.
- Vert `#0B6B43` pour les actions principales, orange `#F58A1F` en accent uniquement. Boutons en rectangle arrondi 14 px (pas en pilule). Rendu premium et doux, jamais agressif.
- Chaque écran Stitch et chaque écran de `design/new/` est « rhabillé » avec le gabarit maître de son type (formulaire, dashboard, recette, opérationnel).
- Composants réutilisables : en-tête, bouton principal, carte sélectionnable, puce, curseur, barre de progression, barre de navigation unique, cartes d'extrait de suivi.
- **Contrôle qualité de chaque écran** (règle allégée le 2026-09-24 : plus de captures automatiques du téléphone ; j'installe l'app et j'indique quoi tester, Simo vérifie lui-même) :
  - compare avec la maquette de `design/maquettes/` et le gabarit maître du type d'écran ;
  - corrige les écarts toi-même ;
  - puis montre-moi le résultat **côte à côte avec la maquette** avant de demander ma validation.
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
0. Environnement : Flutter, Android SDK, détection de mon téléphone, projet Supabase connecté. ✅
1. App vide installée sur mon téléphone. ✅
2. Design system (`lib/theme/`) + écrans maîtres. ✅
3. Base Supabase : tables, RLS, données de démo de SPEC.md §12, avec des cas pièges. ✅
4. Entrée + onboarding Solo (12 étapes), avec le détour Réserve. ✅
5. Onboarding Foyer (10 étapes), avec le détour Réserve. ✅
5b. Visuels générés par API + pictogrammes des régimes. ✅
5i. **International, socle** : textes sortis du code, 6 langues, arabe de droite à gauche, tables de traduction, unités, devises, dates.
5d. **Entrée et réassurance** : Landing déroulante, 5 écrans de réassurance, onglet « Menus », étape Enseigne sans drive.
5c. Recettes des 8 cuisines (≈ 120 au lancement, 96 au jalon 5c), créées dans les tables de traduction ; photos par API après un essai de 5.
6. Compte invité converti à l'inscription + génération des menus sous budget et sous contraintes « Ma cuisine ».
6b. **Improvisation (6 étapes) + paywall de la fiche recette**, construits ensemble.
7. Menu flouté (réutilise le paywall du 6b).
8. Onglet Menus : grille, liste, fiche recette, pas-à-pas, confirmation.
9. Onglet Courses **sans drive** : liste (réserve déduite), mode magasin, partage, impression A4, PDF, texte ; prix en 3 niveaux.
10. Onglet Réserve : ajout manuel, scan code-barres, photo IA, alertes, recette anti-gaspi.
11. Accueil (avec le cercle d'improvisation) + onglet Suivi : Budget, Nutrition, Performance ; Health Connect.
12. Réglages (langue, pays, unités, abonnement), états vides et erreurs, suppression du compte.
12b. 🔴 **Anti-fraude — bloquant avant publication** : App Set ID vérifié côté serveur dans une Edge Function avant l'appel à l'IA.
13. APK de test partageable via Firebase App Distribution.

Reprends toujours à partir de `PLAN.md`, qui indique en haut où on en est et quelle est la prochaine action.
