// Titres des 12 étapes par parcours (3 à 12)
import { ParcoursType } from '../store/menoo';

export const STEP_TITLES: Record<ParcoursType, Record<number, { title: string; hint?: string }>> = {
  'pour-moi': {
    3: { title: 'Mon profil essentiel', hint: 'Quelques informations rapides sur vous.' },
    4: { title: 'Mon objectif et mon rythme', hint: 'Ce que vous cherchez à améliorer, sans pression.' },
    5: { title: 'Mes repas pour la semaine', hint: 'Combien de repas Menoo doit prévoir ?' },
    6: { title: 'Mes courses et mon budget', hint: 'Un budget indicatif, ajustable à tout moment.' },
    7: { title: 'Mon alimentation et mes allergies', hint: 'Régime, intolérances ou allergies éventuelles.' },
    8: { title: 'Mes goûts et cuisines préférées', hint: 'Ce qui vous fait plaisir au quotidien.' },
    9: { title: 'Mes repères nutritionnels', hint: 'Des repères doux, jamais un diagnostic médical.' },
    10: { title: 'Mon matériel, mon temps et mon niveau', hint: 'Pour proposer des recettes réalistes.' },
    11: { title: 'Mes réserves actuelles', hint: 'Facultatif — vous pourrez le faire plus tard.' },
    12: { title: 'Résumé et création de ma semaine', hint: 'Vérifions ensemble avant de générer votre semaine.' },
  },
  'pour-foyer': {
    3: { title: 'Qui mange à la maison', hint: 'Adultes, enfants, invités réguliers.' },
    4: { title: 'Notre priorité commune', hint: "Ce qui compte le plus pour votre foyer." },
    5: { title: 'Nos repas pour la semaine', hint: 'Combien de repas à préparer ensemble ?' },
    6: { title: 'Nos courses et notre budget', hint: 'Un budget global, ajustable.' },
    7: { title: "L'alimentation de chacun", hint: "Régimes de tous les membres du foyer." },
    8: { title: 'Les allergies de chacun', hint: 'Signaler ce qui doit être évité.' },
    9: { title: 'Les goûts de chacun', hint: 'Aimés et non-aimés — sans jugement.' },
    10: { title: 'Nos cuisines et la vibe des repas', hint: 'Ambiance familiale, découverte, réconfort.' },
    11: { title: 'Notre matériel, notre temps et nos réserves', hint: 'Un aperçu pratique pour cuisiner sereinement.' },
    12: { title: 'Résumé du foyer et création de la semaine', hint: 'Un dernier coup d\u2019œil avant de lancer.' },
  },
  'avec': {
    3: { title: 'Choisir une méthode de saisie', hint: 'Écrire, parler, photographier ou scanner.' },
    4: { title: 'Identifier les produits', hint: 'Menoo lit votre saisie et repère les produits.' },
    5: { title: 'Consolider les informations produit', hint: 'Croisement Open Food Facts + Open Prices + Moteur Menoo.' },
    6: { title: 'Confirmer contenants et quantités', hint: 'Ajustez ce qu\u2019il reste réellement.' },
    7: { title: 'Choisir le nombre de personnes', hint: 'De 1 à 6 personnes.' },
    8: { title: 'Choisir les repas de la semaine', hint: 'De 1 à 4 repas.' },
    9: { title: 'Cuisines, temps et matériel', hint: 'Type de cuisine et contraintes pratiques.' },
    10: { title: "Règle d'achat et compatibilité", hint: 'Vérifions ce qui est réalisable sans achat.' },
    11: { title: 'Choisir et consulter une recette', hint: 'Votre recette adaptée à vos réserves.' },
    12: { title: 'Confirmer le repas et mettre à jour', hint: 'Vos réserves seront mises à jour automatiquement.' },
  },
};

export const PARCOURS_LABELS: Record<ParcoursType, string> = {
  'pour-moi': 'Pour moi',
  'pour-foyer': 'Pour mon foyer',
  'avec': 'Avec ce que j\u2019ai',
};

// Écrans détaillés existants (réutilisables sans les modifier)
export const AVEC_DETAILED_ROUTE: Record<number, string | null> = {
  3: null,
  4: null,
  5: '/flow/consolidation',
  6: '/flow/confirmation',
  7: null,
  8: null,
  9: null,
  10: '/flow/compatibility',
  11: '/flow/recipe',
  12: '/flow/stock-update',
};
