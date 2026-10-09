# B — Audit scientifique des règles nutritionnelles de Menoo

Date : 9 octobre 2026. Statut : règles produit Solo 18+ et Famille sans transformation physique validées et appliquées ; autres propositions scientifiques en attente.

## Conclusion

Le moteur est protégé contre les erreurs numériques R01. Sa validité nutritionnelle individuelle n'est pas établie pour tous les profils admis. Un IMC élevé ne doit pas être assimilé automatiquement à une masse grasse élevée, et 250 kg n'est pas une limite médicale universelle.

Les calculs Solo des moins de 18 ans sont désormais bloqués, y compris pour les données préexistantes. Le mode Famille ne propose plus d’objectifs physiques et ne produit ni calories personnalisées, ni macros, ni projections de poids. Restent à valider : le contexte des objectifs adultes, la disponibilité énergétique des sportifs et la cohérence méthodologique des projections.

## Méthode et limites

Lecture du moteur Flutter, des écrans, des traductions et des migrations SQL locales, sans intervention Supabase. Comparaison avec les sources primaires ci-dessous, leurs recommandations et passages accessibles. Certains accès au texte intégral ont rencontré une protection de navigateur ; les sections indexées et résumés consultables ont alors été utilisés. Aucun protocole clinique, aucune mesure de composition corporelle, calorimétrie ou suivi longitudinal de personnes réelles n'a été réalisé.

Il s'agit d'un audit documentaire du produit, pas d'une nouvelle revue systématique ni d'une validation médicale. Les populations et limites de chaque source sont conservées ; les seuils d'un outil ou d'une étude ne sont pas transformés en règles universelles.

## 1. Quatre types de limites à séparer

| Type | Exemple | Conséquence |
|---|---|---|
| Capacité technique | Nombre non fini, entier non représentable, durée/date impossible | Refus ou résultat indisponible, sans remplacer les réponses |
| Domaine d'une équation | Population dans laquelle une équation a été développée ou évaluée | Résultat estimatif ; extrapolation à documenter, pas exclusion automatique d'une personne |
| Vigilance nutritionnelle | Croissance, entraînement exigeant, déficit, grossesse/allaitement | Évaluation contextualisée ; aucune garantie fournie par un simple seuil calorique |
| Choix produit | Solo 18–100 ans, bornes 35–250 kg, cible maximale 250 kg ; rôle familial « adulte » dès 14 ans indépendant de Solo | Âge minimal Solo validé ; bornes de poids provisoires ; catégories familiales conservées, sans les qualifier de limites médicales |

Ces bornes de saisie sont conservées comme demandé. Elles limitent encore l'accès à certains profils atypiques ; les élargir est une décision produit distincte. Aucun plafond supplémentaire d'IMC ou de poids n'est proposé ici.

## 2. Repos : Mifflin–St Jeor

Code : [onboarding_data.dart](/C:/Users/simos/Menoo-Flutter-V2/lib/onboarding/onboarding_data.dart), getter `dailyKcal`.

Formule : `10 × poids + 6,25 × taille − 5 × âge + 5` pour le sexe homme, ou `−161` pour le sexe femme. C'est la forme simplifiée de Mifflin–St Jeor. La publication porte sur la dépense au repos (REE) ; le nom `bmr` dans le code ne transforme pas ce résultat en mesure stricte de métabolisme basal.

L'étude initiale utilise 498 adultes en bonne santé, âgés de 19 à 78 ans, dont des personnes de poids normal et présentant une obésité. Elle ne suffit pas à valider l'estimation individuelle pour les mineurs, les 79–100 ans ou toutes les compositions corporelles atypiques. **Classification : équation scientifique, extension du produit non validée pour tous ses utilisateurs.** [Mifflin et al., 1990](https://pubmed.ncbi.nlm.nih.gov/2305711/?format=pubmed).

Proposition : conserver la formule tant qu'aucune alternative n'est approuvée, identifier explicitement l'estimation et proposer un contexte d'incertitude ou un besoin mesuré dans les situations particulières. Pas de changement automatique d'équation.

## 3. Athlètes et IMC

NICE NG246 recommande une interprétation prudente de l'IMC chez les adultes à forte masse musculaire. Le CDC rappelle qu'il ne sépare pas graisse, muscle et os. L'app ne recueille pas une mesure de masse grasse ou de masse maigre : elle ne peut pas inférer la composition corporelle d'un IMC élevé. **Classification : recommandation scientifique ; aucune exclusion par IMC élevé à introduire.** [NICE, identification, §1.9.7](https://www.nice.org.uk/guidance/ng246/chapter/Identifying-and-assessing-overweight-obesity-and-central-adiposity), [CDC, About BMI](https://www.cdc.gov/bmi/about/).

La revue Sports Medicine demandée comprend 29 études et 1 430 participants. L'exactitude moyenne et la précision individuelle varient selon l'équation et la population ; Mifflin–St Jeor présente des biais dans les groupes étudiés. Les performances de Ten-Haaf dans cette revue ne justifient pas son remplacement automatique dans Menoo. La revue concerne des athlètes adultes et comporte des exclusions, une hétérogénéité et des limites de mesure. [O'Neill et al., 2023, DOI 10.1007/s40279-023-01896-z](https://pmc.ncbi.nlm.nih.gov/articles/PMC10687135/).

Proposition : maintenir l'accès au produit, distinguer pratique sportive et composition corporelle, et prévoir une estimation contextualisée ou une valeur mesurée/validée avec un professionnel. Les données nécessaires et le mode de calcul restent à décider.

## 4. Dépense quotidienne et activité

Le repos estimé est multiplié par 1,2 / 1,45 / 1,65 / 1,85 selon quatre catégories d'activité. **Classification : hypothèse produit ; absence de source spécifique documentant cette grille pour les publics de Menoo.** Il n'y a pas de mesure des entraînements, du travail physique ou de l'activité quotidienne permettant de vérifier l'estimation.

Le Body Weight Planner affiche ses propres niveaux d'activité usuels de 1,4 à 2,5. Ces paramètres appartiennent à son modèle et ne doivent pas être copiés mécaniquement dans Menoo. Les DRI Energy 2023 distinguent activité et étapes de vie. [NIDDK, Body Weight Planner](https://www.niddk.nih.gov/bwp), [National Academies, DRI Energy 2023, Summary](https://www.nationalacademies.org/read/26818/chapter/2).

Proposition : faire valider les catégories, les données demandées et la stratégie de suivi. Le texte actuel annonce un ajustement ultérieur selon la progression ; cet ajustement n'est pas implémenté dans le moteur examiné et ne doit pas être présenté comme déjà opérationnel.

## 5. Déficits, surplus et dates

Menoo transforme un rythme en énergie avec `7 700 kcal/kg ÷ 7 jours`. Les options impliquent approximativement 275, 550 ou 825 kcal/jour de déficit ; la prise utilise 275 ou 550 kcal/jour de surplus ; la Sèche utilise 550. **Classification : simplification produit, pas validation d'un rythme sûr pour chaque utilisateur ni promesse de masse musculaire gagnée.**

La projection est linéaire : différence de poids divisée par rythme. Les modèles dynamiques de Hall prennent en compte les adaptations au changement de poids ; l'équivalence fixe ne suffit pas à prédire une trajectoire individuelle. Un surplus ne devient pas automatiquement du muscle. [Hall et al., 2011, DOI 10.1016/S0140-6736(11)60812-X](https://pmc.ncbi.nlm.nih.gov/articles/PMC3880593/).

Constat vérifié par test : femme de 40 ans, 160 cm, 60 kg, sédentaire, rythme 0,75 kg/semaine, cible 50 kg. Le moteur renvoie 1 240 kcal et 14 semaines. Le plancher réduit le déficit initial à environ 247 kcal/jour alors que la projection conserve le rythme demandé. Ce décalage est une incohérence d'hypothèses à corriger après accord, pas une nouvelle règle médicale de perte réelle.

Propositions : préciser l'incertitude, ne pas promettre une date, faire valider le rythme et rendre la projection cohérente avec la stratégie énergétique. Aucun nouveau plafond en années, déficit ou rythme ajouté.

## 6. Planchers et REDs

Le code applique `max(repos estimé, 1 500 homme / 1 200 femme)`. **Classification : garde-fou produit dont la valeur médicale universelle n'est pas démontrée.** Être au-dessus du repos estimé ne garantit pas une disponibilité énergétique suffisante pour un entraînement important.

Le NIDDK limite son Planner aux adultes de 18 ans et plus, hors grossesse/allaitement, et son seuil de 1 000 kcal appartient à cet outil. Il ne doit pas être adopté comme seuil de sécurité général de Menoo. NICE encadre les régimes de 800–1 200 kcal dans une prise en charge spécialisée : cela ne valide pas un plancher automatique de 1 200 pour toutes les personnes. [NIDDK](https://www.niddk.nih.gov/bwp), [NICE, activité et alimentation, §1.16](https://www.nice.org.uk/guidance/ng246/chapter/Physical-activity-and-diet).

Le consensus CIO REDs traite de l'énergie restant disponible après l'exercice, rapportée à la masse maigre, et de conséquences sanitaires et sportives. Il ne fournit pas un seuil universel permettant d'affirmer l'absence de risque. Menoo ne dispose ni de la masse maigre ni d'une estimation spécifique de dépense d'exercice ; il ne peut donc pas dépister ou exclure REDs avec son calcul actuel. [CIO 2023, DOI 10.1136/bjsports-2023-106994, version avec correction 2024](https://bjsm.bmj.com/content/57/17/1073.long).

Proposition : définir avec un professionnel une politique pour les objectifs et situations potentiellement risqués ; signaler l'incertitude et suspendre la recommandation concernée si nécessaire, tout en conservant l'accès aux autres fonctions. Aucun score REDs ou seuil maison à inventer.

## 7. Protéines, lipides et glucides

Règles actuelles : protéines 1,6 g/kg en Maintien, 1,8 en Perte/Prise, 2,0 en Sèche ; lipides 25 % de l'énergie ; glucides comme reste énergétique.

L'ISSN décrit notamment 1,4–2,0 g/kg/jour pour beaucoup d'individus en bonne santé pratiquant de l'exercice. Cela ne valide pas l'application par objectif à toutes les personnes sédentaires, de forte corpulence ou mineures. Le code utilise le poids total et ne distingue pas la masse maigre. **Classification : choix produit compatible avec certains contextes sportifs, généralisation non démontrée.** [ISSN, 2017, DOI 10.1186/s12970-017-0177-8](https://link.springer.com/article/10.1186/s12970-017-0177-8).

Les références AMDR donnent, pour les adultes, lipides 20–35 %, glucides 45–65 %, protéines 10–35 % de l'énergie. 25 % de lipides se situe dans cette plage ; fixer les glucides comme simple reste ne garantit pas une répartition adaptée. Ces plages sont des références de population, pas des critères automatiques d'exclusion ou de diagnostic sportif. [IOM/National Academies, table C-5](https://www.ncbi.nlm.nih.gov/books/NBK208874/).

La même table distingue les lipides à 30–40 % pour les 1–3 ans et 25–35 % pour les 4–18 ans. Cela confirme qu'une répartition adulte uniforme ne constitue pas une règle pédiatrique ; aucun de ces pourcentages n'est ajouté automatiquement à Menoo.

Exemple logiciel vérifié : homme de 45 ans, 170 cm, 190 kg, Maintien, sédentaire : 3 290 kcal et 304 g de protéines, soit environ 37 % de l'énergie. Les nombres sont positifs et cohérents arithmétiquement, mais cela ne suffit pas à valider la répartition clinique. Les protections R01 masquent une répartition impossible, pas tous les risques nutritionnels.

Proposition : faire valider une stratégie tenant compte du public, de l'activité et du contexte médical, sans nouvelle formule ni normalisation automatique à ce stade.

## 8. Mineurs, enfants et bébés

Décision de Simo appliquée : Solo est réservé aux 18 ans et plus (borne maximale existante 100 ans conservée). Les validations de champs, du modèle, des calculs et de la navigation refusent les moins de 18 ans. Un ancien profil de 17 ans est conservé, ses calculs deviennent indisponibles et le récapitulatif renvoie au formulaire pour une correction explicite. Les tests vérifient le refus à 17 ans, l’acceptation à 18 ans et l’absence de calculs aux âges 14–17. **Classification : restriction produit validée ; elle ne garantit pas la précision clinique d’une équation dès 18 ans.**

Le CDC utilise des repères d'IMC selon âge et sexe pour les 2–19 ans ; le NIDDK Planner exclut les moins de 18 ans. Le seuil adulte 18,5 ne doit pas être appliqué automatiquement comme objectif pédiatrique. La croissance et le stade de vie comptent dans les besoins énergétiques. [CDC, BMI enfants/adolescents](https://www.cdc.gov/bmi/child-teen-calculator/bmi-categories.html), [DRI Energy 2023](https://www.nationalacademies.org/read/26818/chapter/2).

Famille : organisation des repas, budget et contraintes alimentaires uniquement. Les choix d’objectif et d’activité nutritionnelle sont retirés des fiches ; les badges et lignes d’objectif disparaissent des profils et du récapitulatif. Les accès directs aux écrans physiques Solo retournent à la composition du foyer. Le modèle refuse les calculs physiques en mode Famille. Les anciens champs `MemberDraft.goal` et `activity` sont conservés en mémoire et dans les copies pour préserver les données, mais ne sont plus proposés ni utilisés pour une recommandation familiale. Les enfants et bébés conservent leurs profils et allergies ; les exclusions communes sont conservées. Aucun moteur nutritionnel familial n’est introduit.

La catégorie familiale « adulte » commence encore à 14 ans (enfant 4–13, bébé 0–3). Ce libellé n’est pas une éligibilité Solo et ne donne plus accès aux objectifs physiques. Son nom et sa plage pourraient être réexaminés comme décision produit ; ils ne sont pas modifiés arbitrairement. Les multiplicateurs de portion 1 / 0,65 / 0,3 restent présents mais non utilisés dans les calculs Flutter examinés : ils ne sont pas des recommandations nutritionnelles validées.

Pour les moins de 2 ans, le CDC recommande les courbes OMS adaptées. Les besoins des enfants ne sont pas une fraction fixe d'une cible d'adulte ; les références énergétiques incluent la croissance. [CDC, courbes OMS](https://www.cdc.gov/growthcharts/who-growth-charts.htm), [National Academies, DRI Energy 2023](https://www.nationalacademies.org/read/26818/chapter/2).

Séparation désormais appliquée entre rôle de composition du foyer et éligibilité Individuel. Aucun parcours de transformation pour mineurs ni moteur pédiatrique familial n’est prévu par cette décision. Les références pédiatriques ci-dessus expliquent pourquoi les calculs adultes ne doivent pas être détournés en prescriptions pour enfants/bébés ; elles ne constituent pas une demande d’ajout de moteur. Les informations et promesses de portions devront rester distinctes de recommandations nutritionnelles individualisées.

## 9. Base de données et présentation

Migrations locales seulement : poids actuel 2–400 kg, cible 30–300 kg, et règle d'IMC adulte appliquée à toutes les cibles sans distinction d'âge. Ces bornes divergent de celles de Flutter. Elles ne prouvent pas une validité médicale et devront être revues avant une future connexion des données Solo et Famille ; Supabase n'est pas modifié.

FR/EN/DE emploient déjà le mot « estimation » pour le résumé et la projection. La formule et ses limites ne sont pas expliquées dans ces textes, et l'ajustement ultérieur est annoncé sans être codé. Proposition : améliorer la transparence scientifique après accord, avec des formulations traduites et une relecture médicale, sans redessiner les écrans.

## Décisions à valider

1. Terminologie des catégories du foyer (« adulte » dès 14 ans), sans changer l’éligibilité Solo 18+ ni introduire de transformation physique familiale. La restriction Solo et le périmètre Famille sont décidés, non en attente.
2. Contexte de sécurité des objectifs : entraînement exigeant, grossesse/allaitement, autres situations nécessitant un accompagnement.
3. Présentation et gestion de l'incertitude pour les sportifs et compositions atypiques, sans rejet sur IMC élevé.
4. Cohérence entre calories réellement proposées, rythme et projection ; transparence sur le suivi non implémenté.
5. Stratégie de macros selon les publics, après expertise ; aucune nouvelle formule automatique.
6. Réexamen futur des bornes produit et SQL, en gardant 250 kg provisoire aujourd'hui.

La poursuite d'un moteur de recommandations nutritionnelles doit attendre ces décisions de santé. Les phases 3 à 7 ne sont pas commencées dans cette mission.

## Vérification de la rectification produit

Avant correction : 9 nouveaux tests de modèle FR/EN/DE, 3 réussites et 6 échecs attendus : âge 17 accepté et calories 3 040 en mode Famille avec objectif de prise de masse hérité. Après correction : voir `reports/RECTIFICATION_REGLES_PRODUIT.md` pour les commandes et résultats vérifiés. Les formules Mifflin, facteurs, déficits/surplus, planchers et répartition des macros restent inchangés pour les adultes Solo éligibles. Aucun changement Supabase, design ou illustration ; phases 3 à 7 non commencées.

Vérification finale : **386 tests réussis, 0 échec, 1 B09 différé** ; analyse Flutter sans problème ; diff check sans erreur. Incohérence documentaire restante : PRD.md §5.7 (ligne 105) annonce encore des calories/macros par membre en Foyer ; cette ancienne proposition est contredite par la décision produit validée et n’est pas implémentée comme moteur familial.
