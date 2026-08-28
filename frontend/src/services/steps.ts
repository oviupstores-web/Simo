import { ParcoursType } from '../store/menoo';

// Titres/sous-titres des 12 étapes par parcours (selon organigramme Menoo v1)
export const STEP_TITLES: Record<ParcoursType, Record<number, { title: string; hint?: string }>> = {
  'pour-moi': {
    1: { title: 'Mon objectif', hint: 'Vous pourrez le modifier à tout moment.' },
    2: { title: 'Mon profil', hint: 'Quelques données personnelles pour adapter vos repères.' },
    3: { title: 'Mon activité', hint: 'Votre niveau d\u2019activité au quotidien.' },
    4: { title: 'Mon rythme et mes repères', hint: 'Repères informatifs, jamais un diagnostic médical.' },
    5: { title: 'Mes repas de la semaine', hint: 'Choisissez les repas et les jours à planifier.' },
    6: { title: 'Mon budget', hint: 'Un budget indicatif, ajustable à tout moment.' },
    7: { title: 'Mes courses et/ou réserves', hint: 'Magasins préférés et ce qui reste déjà chez vous.' },
    8: { title: 'Mon régime alimentaire', hint: 'Distinct des allergies et des simples préférences.' },
    9: { title: 'Mes allergies', hint: 'Aucune recette incompatible ne passera.' },
    10: { title: 'Mes goûts et cuisines', hint: 'Ce qui vous fait plaisir au quotidien.' },
    11: { title: 'Mon organisation', hint: 'Matériel, temps, niveau, gestion des restes.' },
    12: { title: 'Mon résumé', hint: 'Tout reste modifiable avant de créer votre semaine.' },
  },
  'pour-famille': {
    1: { title: 'Notre priorité', hint: 'Ce qui guide vos arbitrages en famille.' },
    2: { title: 'Qui mange à la maison', hint: 'Adultes, enfants et invités.' },
    3: { title: 'Profil et besoins de chacun', hint: 'Chaque personne garde ses propres contraintes.' },
    4: { title: 'Notre rythme', hint: 'Semaine et week-end, présences par contexte.' },
    5: { title: 'Nos repas de la semaine', hint: 'Combien de repas et quels jours planifier.' },
    6: { title: 'Notre budget', hint: 'Budget global du foyer, ajustable.' },
    7: { title: 'Nos courses et/ou réserves', hint: 'Magasins et ce que vous avez déjà.' },
    8: { title: 'Le régime de chaque personne', hint: 'La contrainte reste attachée à la bonne personne.' },
    9: { title: 'Les allergies de chacun', hint: 'Aucune fusion entre les personnes.' },
    10: { title: 'Goûts, cuisines et ambiance', hint: 'Compromis possibles sans ignorer un refus.' },
    11: { title: 'Notre organisation', hint: 'Matériel, temps, niveau, gestion des restes.' },
    12: { title: 'Résumé du foyer', hint: 'Tout reste modifiable avant de créer votre semaine.' },
  },
};

export const PARCOURS_LABELS: Record<ParcoursType, string> = {
  'pour-moi': 'Pour moi',
  'pour-famille': 'Pour la famille',
};

export const PARCOURS_DESC: Record<ParcoursType, string> = {
  'pour-moi': 'Une personne, un accompagnement adapté à votre rythme et à vos objectifs.',
  'pour-famille': 'Adultes, enfants et invités configurés séparément, avec leurs propres contraintes.',
};
