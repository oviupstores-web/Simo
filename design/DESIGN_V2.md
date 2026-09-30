# Design system v2 — Menoo (prioritaire sur DESIGN.md)

Source : écrans maîtres (`design/masters/*.html`) et références (`design/masters/ref/*.png`), validés par Simo.
DESIGN.md (Stitch) ne sert plus que pour la structure et le contenu des écrans ; le rendu visuel suit ce fichier.

## Couleurs
| Jeton | Valeur | Usage |
|---|---|---|
| primary | #0B6B43 | Boutons principaux, onglet actif, anneaux, courbes |
| primary-dark | #06502F | Logotype « Menoo », titres verts |
| mint | #EAF6EB | Fonds de pastilles, badges « En réserve ✓ », encarts info |
| mint-2 | #DCEFE0 | Pistes de jauges |
| leaf | #3F8F5F | Statut « Frais », textes positifs |
| orange | #F58A1F | Accent seulement : glucides, icône courses, flèche du CTA landing |
| orange-soft | #FFEBD6 | Fonds d'alertes et badges « À acheter / Populaire » |
| warn | #E67A12 | Statut « À consommer » |
| bg | #FAFBF8 | Fond d'écran |
| card | #FFFFFF | Cartes |
| line | #E7ECE8 | Bordures et séparateurs |
| ink / ink2 / ink3 | #17231C / #5B6660 / #8D9690 | Textes |

## Formes
- Cartes : rayon 14 px, ombre très douce `0 2px 10px rgba(16,40,28,.05)`.
- Boutons : rayon 14 px (rectangle arrondi, **pas en pilule**), hauteur 54 px, ombre verte légère.
- Champs : rayon 12 px, bordure `line`, bordure `primary` au focus.
- Badges / puces : pilule.

## Typographie
Plus Jakarta Sans. Titre d'écran 26–28 px extra-gras ; titre de section 16–18 px extra-gras ; texte 14–15 px ; légendes 11–12 px.

## Éléments de marque
- En-tête : logo carré arrondi (`design/logo.png`) + « Menoo » en primary-dark.
- Photos culinaires réalistes et lumineuses ; feuilles de basilic en décor discret sur les écrans d'onboarding.
- Progression d'onboarding : segments + « ÉTAPE X SUR N ».
- Barre de navigation : Accueil · Menus · Courses · Réserve · Suivi (icônes fines, actif en primary et gras). Jamais affichée avant la création du compte.
- Seule forme ronde de l'app : le cercle d'improvisation de l'Accueil (pulsation lente de 3 à 4 s), voir SPEC.md §7.

## Les 4 gabarits maîtres
1. `master_formulaire` → tous les écrans d'onboarding à saisie.
2. `master_dashboard` → Accueil Solo et Foyer (menu du jour, puis indicateurs Budget, Nutrition, Performance, puis alerte).
3. `master_recette` → toutes les fiches repas et recettes.
4. `master_operationnel` → Réserve (regroupée par emplacement), Courses, tableaux de Suivi.
5. `master_courses_gratuit` → liste de courses en version gratuite (premier rayon en clair, le reste flouté), Solo et Foyer.
Écrans d'entrée maîtres, à reproduire à l'identique : `master_landing`, `master_login` (et son équivalent inscription), `master_path_choice`, `master_onboarding_goal` (modèle de toutes les étapes à choix).
