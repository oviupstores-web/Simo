# CTA — animation continue, cercles entre la pastille et le doigt

Correction de la demande précédente : répétition continue de cycles de 600 ms, sans pause de trois secondes. Les quatre mains restent décalées par leurs phases. Les préférences système de réduction des animations arrêtent la boucle.

Ordre des couches : fond de la pastille → trois ondes concentriques → libellé protégé → main blanche. Les cercles sont donc entre le bouton et le doigt ; la main masque naturellement leur centre. Le texte est peint une seule fois au-dessus des ondes. La silhouette de 38 px, sa pression de 3 px et les diamètres maximaux 12/20/28 px sont conservés. Aucun trait de clic.

Le fond et le texte de la pastille sont séparés dans le composant local sans changer leurs tailles, paddings, couleurs, textes ni bordures. Les cartes, smartphone et indicateurs CaliScan, PNG, navigations et Commencer ne sont pas modifiés. Suivi conserve sa pastille informative sans main ni animation.

22 tests ciblés réussis à 320/390 px, dont les contrôles de non-masquage des lettres, les 24 phases des quatre CTA, CaliScan et les navigations. L'ancien test de pause a été remplacé par un contrôle de boucle continue ; les captures historiques utilisent désormais les vrais contrôleurs sans progression imposée. flutter analyze --no-pub : No issues found!. git diff --check : réussi.

Fichiers : lib/screens/entry/landing_badge_cta.dart, test/landing_cta_test.dart, test/cta_38_animation_test.dart et ce rapport. Aucun commit, push ou installation Android. Validation visuelle attendue.

[Aperçu animé réel](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\cta_continu\animation_continue.gif>).
[Gros plan CaliScan à 320 px](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\cta_continu\caliscan_320.png>) · [390 px](<C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\cta_continu\caliscan_390.png>).
