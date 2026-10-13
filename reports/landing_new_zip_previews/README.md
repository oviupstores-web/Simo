> Document historique : décrit une version antérieure. Pour la Landing courante provisoire, consulter [REFERENCE](../step1_landing_review/REFERENCE.md). Ne pas réappliquer ses anciennes dimensions ou ressources.

# Landing — nouvelles illustrations du ZIP — prévisualisations seulement

Deux montages statiques : `landing_320.png` (320 × 1716) et `landing_390.png` (390 × 1595).

Base : captures françaises dans `reports/landing_cta_responsive/`. Structure, textes, CTA, couleurs et bordures de la colonne gauche, en-tête et bouton Commencer conservés. Espacement blanc de 10 px entre chaque carte et avant Commencer. Hauteurs des cartes conservées. Ce ne sont pas des captures d'une nouvelle application.

Les cinq illustrations proviennent exclusivement de `MENOO_5_VISUELS_CARRES.zip`. Originaux 1254 × 1254, intacts ; aucune extraction ni remplacement dans les assets de l'application.

| Illustration | Image à 320 | Zone à 320 | Image à 390 | Zone à 390 |
|---|---|---|---|---|
| Instant Recipe AI | 144 × 144 | 144 × 274 | 176 × 176 | 176 × 257 |
| CaliScan AI | 144 × 144 | 144 × 226 | 176 × 176 | 176 × 210 |
| Menus | 147 × 147 | 147 × 253 | 179 × 179 | 179 × 238 |
| Courses | 136 × 136 | 136 × 280 | 166 × 166 | 166 × 238 |
| Suivi | 144 × 144 | 144 × 197 | 176 × 176 | 176 × 155 |

Mise à l'échelle uniforme, centrage vertical. Images complètes sauf Suivi à 390 : 11 px de fond en haut et 10 px en bas hors de la zone, sans coupure des éléments principaux. Les fonds supérieur/inférieur sont prolongés et adoucis dans les montages. Suivi utilise un fond lavande pour éviter de prolonger les coins noirs du fichier RGB. Masque arrondi et raccord léger sur les bords des images, sans modification des originaux.

Vérifications : colonne gauche de chacune des cinq cartes identique pixel pour pixel à sa capture source ; en-tête et bloc Commencer identiques. Empreintes du ZIP, du fichier de Landing, de ses tokens et de tous les assets de Landing inchangées pendant la génération. Mesures et vérifications dans `dimensions_and_verification.json`.

Aucune compilation, installation, modification de code applicatif, commit ou push. Validation utilisateur attendue avant intégration.
