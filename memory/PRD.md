# Menoo — Prototype mobile (Expo React Native + TypeScript)

## Objectif
Prototype interactif d'une application mobile française qui aide les foyers à organiser leurs repas à partir de ce qu'ils ont déjà chez eux, pour réduire le budget et limiter le gaspillage.

## Architecture — organigramme officiel v1
**2 parcours** en 12 étapes chacun. Indicateur « Étape X sur 12 », boutons Retour / Continuer, réponses persistées (AsyncStorage v2), reprise depuis l'accueil.

### Ouverture Menoo
Chooser à 2 cartes : Pour moi · Pour la famille. Aucune étape « raison » avant.

### Parcours « Pour moi » (12 étapes réelles)
1. Mon objectif (4 chips)
2. Mon profil (âge, sexe, taille, poids actuel, poids visé)
3. Mon activité (5 chips)
4. Mon rythme et mes repères (rythme + repères informatifs 1–3 pour énergie, protéines, glucides, lipides, fibres)
5. Mes repas de la semaine (4 types × compteur 0–7, 7 jours à cocher, total live)
6. Mon budget (période + montant)
7. Mes courses et/ou réserves (mode courses/réserves/mixte, magasins multi, CP, passerelle vers /flow/input)
8. Mon régime alimentaire (7 chips : omnivore, flexi, végétarien, végan, pescetarien, sans porc, halal)
9. Mes allergies (9 chips multi)
10. Mes goûts et cuisines (aime/n'aime pas ingrédients + cuisines, exclusion mutuelle)
11. Mon organisation (matériel, temps semaine/WE, niveau, gestion restes)
12. Mon résumé (tout affiché, modifiable)

### Parcours « Pour la famille » (12 étapes réelles)
1. Notre priorité (6 chips)
2. Qui mange à la maison (compteurs adultes/enfants/invités, total live)
3. Profil et besoins de chacun (par personne : nom, âge enfant, taille de portion, objectif individuel)
4. Notre rythme (6 contextes × présence par membre)
5. Nos repas de la semaine
6. Notre budget
7. Nos courses et/ou réserves (idem « pour moi »)
8. Le régime de chaque personne (par membre)
9. Les allergies de chacun (par membre, aucune fusion)
10. Goûts, cuisines et ambiance (goûts par membre, cuisines foyer, 5 ambiances)
11. Notre organisation
12. Résumé du foyer

### Écrans détaillés existants (préservés, ré-utilisés via étape 7)
`/flow/input`, `/flow/consolidation`, `/flow/confirmation`, `/flow/meal-choice`, `/flow/compatibility`, `/flow/recipe`, `/flow/stock-update`

## Onglets
Accueil, Mes repas (aperçu), Réserves (interactif), Suivi (radar + courbe + budget + énergie), Profil (aperçu).

## Technique
- Expo SDK 54, React Native, TypeScript, expo-router
- State : React Context + AsyncStorage v2 (reprise / migration propre)
- Composants réutilisables : Chip (single/multi), Counter, PrimaryButton, StepProgress, FlowHeader
- Charts : react-native-svg
- Design tokens : crème, vert profond, vert menthe, doré

## Intégrations futures (préparées, non branchées)
- Supabase PostgreSQL
- Open Food Facts + Open Prices + Ciqual/Anses
- Moteur menus et recettes (AI)
- RevenueCat pour l'abonnement
