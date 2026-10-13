# Historique des tests de Landing

Les neuf anciens tests expérimentaux sont déplacés hors de la découverte automatique test/ vers archived_tests/, sans modification de leur contenu. Les chemins d'origine et justifications sont dans archived_tests.json ; une deuxième copie exacte de chaque fichier avant correction se trouve dans history/test/.

Ce déplacement ne masque pas une règle métier valide : ces fichiers testaient des versions abandonnées (colonnes horizontales, anciennes ressources, CTA courts sur une ligne, hauteur28, marges14/24, espaces10/20) ou des copies de la page dans reports/. Les tests actifs landing_cta_test.dart, caliscan_targeted_test.dart et landing_replacement_1258_test.dart reprennent navigation, contenu, images, marges, CTA, centrage et protection du contour. landing_responsive_test.dart conserve les défauts responsive en échec s'ils sont reproductibles.

Les anciens imports relatifs sont conservés byte pour byte : les archives sont des sources historiques, pas une suite déplacée à exécuter directement. Pour reproduire une ancienne expérience, utiliser son contexte et ses chemins d'origine dans une copie isolée ; ne pas la restaurer dans l'application courante.

Les tests de parcours, modèle, budget, contraintes, réserve et autres écrans restent inchangés. Aucune mise à jour globale des références historiques n'est effectuée.
