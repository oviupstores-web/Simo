# Étape 1 — documentation et tests — 13 octobre 2026

Étape terminée dans son périmètre. La Landing reste une référence provisoire. La suite complète n'est pas verte. Aucun changement applicatif, aucune installation Android, aucun commit/push, aucun travail Supabase.

## Résultats

Les nombres excluent chargement des fichiers, setUpAll et tearDownAll.

| Contrôle | Avant | Après |
|---|---|---|
| Tests Landing ciblés | 16 réussites, 53 échecs (1 failure, 52 error) | 51 réussites, 0 échec |
| Références pleine page FR/DE/EN, 320/390 | Pas de référence consolidée | 6 captures et comparaisons réussies |
| Références Landing de golden_ar_test | Anciennes captures conservées | 2 nouvelles références séparées, réussies |
| Suite complète | Non relancée avant cette étape | 1 214 réussites, 15 échecs |
| Intégrité application/ressources | 398 empreintes sauvegardées | 398 identiques, 0 changement |

Les ensembles ciblés avant/après diffèrent : neuf expériences anciennes ont été archivées et une couverture responsive ajoutée. Les chiffres ne représentent donc pas 53 corrections applicatives. Les attentes obsolètes concernaient notamment les anciennes ressources, colonnes horizontales, hauteurs de CTA et espacements. Navigation et règles métier valides sont conservées.

Logs : before_targeted.jsonl, after_targeted.jsonl, full_after.jsonl. Commandes exécutées avec `flutter test --no-pub --reporter json`, ciblées puis complètes. `--update-goldens` a servi uniquement à créer les nouvelles références Landing dans test/goldens/landing_provisional ; jamais sur la suite complète ou les autres écrans.

## Fichiers concernés

- Documentation : PLAN.md, DECISIONS.md, SPEC.md, PRD.md, design/DESIGN_V2.md. Ajouts datés conservant les anciens contenus et décisions ; les divergences fonctionnelles restent explicites.
- Notices historiques ajoutées aux README des dossiers reports/landing_all_vertical, landing_alpha_preview, landing_cta_responsive, landing_image_adaptations, landing_new_zip_previews, landing_outline_cta, landing_phase1, landing_phase1_targeted, landing_structure, landing_taller_originals.
- Tests ajustés : test/landing_cta_test.dart, test/caliscan_targeted_test.dart, test/golden_ar_test.dart, test/landing_replacement_1258_test.dart (déjà présent non suivi par Git au début).
- Test ajouté : test/landing_responsive_test.dart, 12 cas FR/DE/EN à 320/390 avec texte agrandi à 1,3 et 2,0.
- Références ajoutées : test/goldens/landing_provisional/full_{fr,de,en}_{320,390}.png et viewport_{fr,ar}.png. Les anciennes références suivies par Git ne présentent aucun diff.
- Neuf tests expérimentaux déplacés sans altération dans archived_tests ; détails dans ARCHIVE_INDEX.md et archived_tests.json. Comparaison avec history/test : neuf copies identiques. Aucun test métier supprimé.
- Preuves et rapport : ce dossier, dont history, captures, manifestes et logs. Les fichiers de diagnostic test/failures sont produits automatiquement par les comparaisons échouées.

## Captures Flutter complètes

| Langue | 320 px | 390 px |
|---|---|---|
| Français | [Capture](captures/full_fr_320.png) | [Capture](captures/full_fr_390.png) |
| Allemand | [Capture](captures/full_de_320.png) | [Capture](captures/full_de_390.png) |
| Anglais | [Capture](captures/full_en_320.png) | [Capture](captures/full_en_390.png) |

Rendus du véritable widget Flutter, avec polices et images chargées, pas des maquettes générées. Captures pleine page sous test Flutter ; aucune capture de téléphone physique durant cette étape. Les nouvelles références décrivent l'état figé, elles ne valident pas automatiquement sa qualité graphique.

## Problèmes restants, sans correction

| Problème | Nature et preuve | Priorité |
|---|---|---|
| Héros anglais à 320 : feuilles du plat sur les premiers bénéfices | Défaut visuel observé dans full_en_320.png ; aucune erreur RenderFlex nécessaire pour produire ce chevauchement | Haute, validation design requise |
| Héros français à 320 : feuilles très proches des premiers bénéfices et contact visuel avec leur zone | Tension visuelle dans full_fr_320.png ; aucune retouche appliquée | Moyenne |
| Colonnes de bénéfices et cartes | Origine de la zone icônes à 24 px contre bord de carte à 20 px, soit 4 px ; le PNG contient aussi ses propres marges transparentes | Basse, validation requise |
| Texte allemand plus long et CTA parfois sur deux lignes à 320 | Comportement prévu, sans débordement détecté dans les contrôles ; hauteur totale 2 772 px contre 2 670 en FR à 320, et 2 878 contre 2 788 à 390 | Information |
| Coupure source des avant-bras | Conservée et visible au bas des illustrations ; CaliScan reste contenue par son contour arrondi | Information, aucune retouche autorisée |
| 4 débordements hors Landing | phase5_onboarding_count_test.dart : ES Solo 21 px / Foyer 31 px ; IT Solo 4,1 px / Foyer 14 px, à 320. Défauts réels, pas des références obsolètes | Haute, chantier séparé |
| 11 différences aux anciennes images hors Landing | golden_pantry_test : FR/DE/AR Réserve ; golden_ar_test : choix parcours, couvertures Solo/Foyer, inscription en FR/AR. Écarts confirmés ; cause visuelle ou obsolescence de référence à vérifier séparément | À diagnostiquer |
| Divergences fonctionnelles historiques Landing | Lien connexion absent et Commencer non fixé en bas, documentés dans REFERENCE.md ; aucun comportement changé | À arbitrer |

Les 15 échecs hors Landing ne sont pas corrigés ou neutralisés. Aucune nouvelle régression applicative introduite par cette étape : les 398 fichiers contrôlés sont identiques. L'absence de suite complète avant interdit toutefois d'affirmer une comparaison globale avant/après pour ces échecs.

Les tests passent avec texte agrandi à 1,3 et 2,0 pour absence d'erreur Flutter et maintien des CTA dans les cartes. Ils ne prouvent pas l'absence de chevauchement de pixels transparents dans le héros ; ce contrôle reste visuel.

## Arrêt

Étape 2 non commencée. Attendre la validation de Simo avant toute intervention suivante, y compris correction des défauts signalés. Les modifications applicatives déjà visibles dans git status proviennent des sessions précédentes : application_before.json et integrity_after.json prouvent qu'elles n'ont pas changé pendant cette étape.
