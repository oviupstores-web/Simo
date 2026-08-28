# Menoo — Prototype mobile (Expo React Native + TypeScript)

## Objectif
Prototype interactif d'une application mobile française qui aide les foyers à organiser leurs repas à partir de ce qu'ils ont déjà chez eux, pour réduire le budget et limiter le gaspillage.

## Architecture 12 étapes
Chaque parcours suit une progression claire de 12 étapes avec indicateur « Étape X sur 12 », boutons Retour / Continuer, réponses conservées (AsyncStorage) et reprise possible depuis l'accueil.

**Étapes communes**
1. Ce qui m'amène aujourd'hui (4 choix)
2. Comment Menoo doit m'accompagner (3 cartes)

**Parcours « Pour moi »** — placeholders soignés pour les 10 étapes (profil, objectif, repas, budget, alimentation, goûts, repères nutritionnels, matériel, réserves, résumé).

**Parcours « Pour mon foyer »** — placeholders soignés pour les 10 étapes du foyer.

**Parcours « Avec ce que j'ai »** — chaque étape ouvre l'écran interactif correspondant existant (consolidation, confirmation, compatibilité, recette, mise à jour du stock).

## Écrans interactifs existants (préservés)
- `/flow/input` : saisie des réserves (4 méthodes + texte préremplé)
- `/flow/consolidation` : Open Food Facts + Open Prices + Moteur Menoo
- `/flow/confirmation` : curseurs calibrés par contenant
- `/flow/meal-choice` : personnes / repas / cuisine / règle d'achat
- `/flow/compatibility` : jauges + messages selon règle
- `/flow/recipe` : fiche recette avec hero image et étapes
- `/flow/stock-update` : mise à jour du stock

## Onglets
Accueil, Mes repas (aperçu), Réserves (interactif), Suivi (radar + courbe + budget + énergie), Profil (aperçu).

## Technique
- Expo SDK 54, React Native, TypeScript, expo-router
- Navigation : Tabs + Stack + route dynamique `[type]/[step]`
- State : React Context (`MenooProvider`) avec persistance AsyncStorage (permet quitter/reprendre)
- Charts : `react-native-svg`
- Design tokens : crème, vert profond, vert menthe, doré

## Intégrations futures (préparées, non branchées)
- Supabase PostgreSQL
- Open Food Facts (identification produit + contenance)
- Open Prices (prix uniquement)
