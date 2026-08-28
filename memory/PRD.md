# Menoo — Prototype mobile (Expo React Native + TypeScript)

## Objectif
Prototype interactif d'une application mobile française qui aide les foyers à organiser leurs repas à partir de ce qu'ils ont déjà chez eux, pour réduire le budget et limiter le gaspillage.

## Architecture 12 étapes
Chaque parcours suit une progression claire de 12 étapes avec indicateur « Étape X sur 12 », boutons Retour / Continuer, réponses persistées (AsyncStorage) et reprise possible depuis l'accueil.

**Étapes communes**
1. Ce qui m'amène aujourd'hui (4 choix)
2. Comment Menoo doit m'accompagner (3 cartes cliquables)

**Parcours « Pour moi »** — placeholders soignés pour les 10 étapes.

**Parcours « Pour mon foyer »** — 10 écrans interactifs réels :
- Étape 3 : gestion des membres (adulte / enfant / invité), ajout, suppression, renommage, âge des enfants
- Étape 4 : priorité commune du foyer (temps, budget, santé, gaspillage, partage)
- Étape 5 : nombre de repas de la semaine (1–7)
- Étape 6 : fourchette de budget
- Étape 7 : régime alimentaire par membre (omnivore, flexi, végétarien, végan, pescetarien, sans porc)
- Étape 8 : allergies par membre (multi-sélection : gluten, lactose, œuf, arachide, fruits à coque, poisson, crustacés, soja)
- Étape 9 : goûts par membre (j'aime / je n'aime pas — 10 catégories)
- Étape 10 : cuisines préférées (multi) + vibe des repas (single)
- Étape 11 : matériel + temps de cuisson + passerelle vers les réserves existantes
- Étape 12 : résumé complet du foyer avec CTA « Créer ma semaine »

**Parcours « Avec ce que j'ai »** — chaque étape ouvre l'écran interactif détaillé existant (consolidation, confirmation, compatibilité, recette, mise à jour du stock).

## Écrans interactifs existants (préservés)
- `/flow/input`, `/flow/consolidation`, `/flow/confirmation`, `/flow/meal-choice`, `/flow/compatibility`, `/flow/recipe`, `/flow/stock-update`

## Onglets
Accueil, Mes repas (aperçu), Réserves (interactif), Suivi (radar + courbe + budget + énergie), Profil (aperçu).

## Technique
- Expo SDK 54, React Native, TypeScript, expo-router
- Navigation : Tabs + Stack + route dynamique `[type]/[step]`
- State : React Context (`MenooProvider`) avec persistance AsyncStorage
- Composants réutilisables : `Chip.tsx` (single/multi), `Counter.tsx`, `PrimaryButton`, `StepProgress`, `FlowHeader`
- Charts : `react-native-svg`
- Design tokens : crème, vert profond, vert menthe, doré

## Intégrations futures (préparées, non branchées)
- Supabase PostgreSQL
- Open Food Facts + Open Prices
