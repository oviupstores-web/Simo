# A — Phase 2 : protections techniques R01

Date : 9 octobre 2026. Périmètre : logiciel Flutter, sans validation clinique des recommandations.

## État des corrections

Les protections R01 appliquées lors de la phase précédente sont conservées :

| Entrée ou résultat | Traitement actuel |
|---|---|
| NaN, Infinity, -Infinity, dépassement numérique | Refus avant enregistrement ou calcul ; aucune valeur de remplacement |
| Profil Solo hors bornes de saisie | Message traduit ; réponses enregistrées conservées |
| Valeur familiale invalide | Refus dans le champ et dans le modèle, avec règles propres au rôle |
| Cible non calculable | Projection indisponible, sans date inventée ni exception |
| Durée ou date dépassant la capacité du logiciel | Vérification avant conversion et multiplication |
| Calories non calculables | Calories indisponibles |
| Macros négatives ou non calculables | Répartition indisponible ; calories valides conservées |
| Collage de texte non fini | Même validation que les autres entrées |

Les bornes Solo 14–100 ans, 120–230 cm et 35–250 kg sont des règles de saisie provisoires. La cible maximale actuelle de 250 kg reste également provisoire. Aucune nouvelle borne n'est ajoutée. Une valeur admise n'est pas automatiquement une recommandation médicalement appropriée.

Le code ne rejette pas un profil sur la seule base d'un IMC élevé. Les contrôles de cible fondés sur l'IMC minimal adulte restent une politique existante à examiner dans le livrable B, particulièrement pour les mineurs.

## Changements de cette révision

- Précision des commentaires du modèle : distinction entre borne produit, repère d'IMC adulte et diagnostic médical.
- Ajout des [tests de caractérisation](/C:/Users/simos/Menoo-Flutter-V2/test/nutrition_profile_characterization_test.dart) : profils ordinaires, forte corpulence, sportif musclé fictif, limites, FR/EN/DE et 320/390 px.
- Caractérisation explicite des comportements scientifiques à revoir : calculs adultes chez les 14–17 ans et décalage entre plancher calorique et projection. Ces tests constatent le comportement existant ; ils ne le certifient pas médicalement.
- Aucun nouveau défaut purement technique confirmé pendant cette révision. Les corrections de formule, limites métier et politiques de santé restent soumises à autorisation.

## Exemples vérifiés

| Profil fictif | Résultat logiciel actuel | Interprétation du test |
|---|---|---|
| Homme, 32 ans, 180 cm, 75 kg, Maintien, activité modérée | Calcul disponible | Cas ordinaire ; aucune preuve de précision individuelle |
| Homme, 45 ans, 170 cm, 190 kg, Maintien, sédentaire | 3 290 kcal ; 304 g protéines, 314 g glucides, 91 g lipides | Profil de forte corpulence admis ; pertinence des macros à revoir |
| Homme, 30 ans, 185 cm, 120 kg, Maintien, très actif | 4 090 kcal | Profil sportif fictif admis malgré un IMC élevé ; masse musculaire non mesurée par l'app |
| Profil dans les limites, cible 250 kg | Admis si direction et autres contrôles respectés | Borne produit, pas seuil médical |
| Femme, 100 ans, 120 cm, 250 kg, Sèche, sédentaire | 2 590 kcal affichables ; macros indisponibles | Les glucides négatifs ne sont plus exposés |

## Vérification

Commande finale : `flutter test --no-pub --reporter expanded` avec les fichiers numériques, caractérisation, phase 1, parcours Solo/Foyer, formats, i18n et responsive existants.

Résultat final : **343 réussites, aucun échec, 1 test B09 explicitement différé à la phase 4**. Cette sélection comprend les 115 régressions R01, 58 contrôles de phase 1, 29 caractérisations et les tests de parcours, formats, i18n et responsive. `flutter analyze --no-pub` : aucun problème, code 0. `git diff --check` : aucune erreur. Résultats consignés dans [PLAN.md](/C:/Users/simos/Menoo-Flutter-V2/PLAN.md).

La suite complète précédente avait 346 réussites, 13 échecs visuels déjà présents à l'audit et 1 test B09 différé. Elle n'est pas relancée pour cette révision de documentation et de caractérisation ; aucune référence visuelle n'est remplacée.

## Limites

Les tests prouvent la robustesse, la conservation des données et les comportements décrits. Ils ne prouvent ni la précision du besoin calorique chez un individu, ni l'absence de REDs, ni l'adéquation d'un déficit chez un adolescent.

Aucune modification Supabase, formule nutritionnelle, interface, illustration, installation Android, commit ou push. Les phases 3 à 7 restent en attente.
