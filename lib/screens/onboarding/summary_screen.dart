import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../navigation.dart';
import '../../onboarding/onboarding_data.dart';
import '../../onboarding/onboarding_scope.dart';
import '../../onboarding/onboarding_flow.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import '../entry/signup_screen.dart';
import 'constraints_screen.dart';
import 'onboarding_cuisines_screen.dart';
import 'kitchen_screen.dart';
import 'supermarket_screen.dart';

/// onboarding_summary (Solo 12/12) et onboarding_summary_household (Foyer 10/10) — récapitulatif
/// + bloc « Ma cuisine » (SPEC §2-3). « Générer mon / notre menu » → création du compte (c03_auth_signup, SPEC §5).
class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  static Map<HealthGoal, (String, String)> goals(L l) => {
    HealthGoal.pertePoids: (l.goalLossTitle, AppIcons.trendDown),
    HealthGoal.priseMasse: (l.goalGainTitle, AppIcons.dumbbell),
    HealthGoal.seche: (l.goalCutTitle, AppIcons.bolt),
    HealthGoal.maintien: (l.goalMaintainTitle, AppIcons.lotus),
  };
  static const activities = {
    ActivityLevel.sedentaire: 'Sédentaire',
    ActivityLevel.modere: 'Activité modérée',
    ActivityLevel.actif: 'Actif',
    ActivityLevel.tresActif: 'Très actif',
  };
  static const modes = {
    ManagementMode.courses: ('Courses uniquement', 'Liste de courses complète chaque semaine.'),
    ManagementMode.reserves: ('Réserves uniquement', 'Vos menus partent de ce que vous avez déjà.'),
    ManagementMode.mixte: ('Mixte', 'Vos réserves d\'abord, complétées par une liste de courses.'),
  };
  static const levels = {
    CookingLevel.debutant: 'Débutant',
    CookingLevel.intermediaire: 'Intermédiaire',
    CookingLevel.confirme: 'Confirmé',
  };
  static const mealNames = {
    MealType.petitDejeuner: 'petits-déjeuners',
    MealType.dejeuner: 'déjeuners',
    MealType.diner: 'dîners',
  };

  @override
  Widget build(BuildContext context) {
    final d = OnboardingScope.of(context);
    final goal = goals(L.of(context))[d.goal]!;
    final m = d.macros;
    void edit(OnbStep step) => OnboardingFlow.open(context, step, fromSummary: true);
    final weight = d.weightKg == d.weightKg.roundToDouble()
        ? '${d.weightKg.round()}'
        : '${d.weightKg}'.replaceAll('.', ',');
    final mealsByType = [
      for (final t in MealType.values)
        if (d.slots.any((s) => s.$2 == t)) '${d.slots.where((s) => s.$2 == t).length} ${mealNames[t]}',
    ].join(', ');
    final dietLabels = [
      for (final diet in ConstraintsScreen.diets(L.of(context)))
        if (d.diets.contains(diet.$1)) diet.$2,
    ];
    // Foyer : allergènes partagés + ceux des profils (avec les prénoms concernés)
    final byMember = d.isFoyer ? d.memberAllergens : const <String, List<String>>{};
    final allergenLabels = [
      for (final a in ConstraintsScreen.allergenChoices(L.of(context)))
        if (a.$1.any(d.allAllergens.contains))
          a.$1.any(byMember.containsKey) && !a.$1.any(d.allergens.contains)
              ? '${a.$2} (${{for (final c in a.$1) ...?byMember[c]}.join(', ')})'
              : a.$2,
    ];
    final equipmentLabels = [
      for (final e in KitchenScreen.equipment(L.of(context)))
        if (d.equipment.contains(e.$1)) e.$2,
    ];
    final channel = SupermarketScreen.channels(L.of(context)).firstWhere((c) => c.$1 == d.channel).$2;
    final foyer = d.isFoyer;
    final cook = d.members.where((m) => m.id == d.mainCookId).firstOrNull;
    String plural(int n, String word) => '$n $word${n > 1 ? 's' : ''}';
    final composition = [
      if (d.count(MemberRole.adulte) > 0) plural(d.count(MemberRole.adulte), 'adulte'),
      if (d.count(MemberRole.enfant) > 0) plural(d.count(MemberRole.enfant), 'enfant'),
      if (d.count(MemberRole.bebe) > 0) plural(d.count(MemberRole.bebe), 'bébé'),
    ].join(', ');

    return OnboardingStepScaffold(
      step: OnboardingFlow.number(context, OnbStep.summary),
      totalSteps: OnboardingFlow.total(context),
      eyebrow: 'RÉCAPITULATIF',
      eyebrowIcon: AppIcons.checkCircle,
      title: foyer ? 'Le menu de votre foyer est prêt à être composé !' : 'Votre profil est prêt !',
      subtitle: foyer
          ? 'Vérifiez vos choix avant de générer les ${d.plannedMeals} repas de la semaine.'
          : 'Vérifiez vos choix avant de générer votre premier menu personnalisé.',
      continueLabel: foyer ? 'Générer notre menu' : 'Générer mon menu',
      onContinue: () => push(context, const SignupScreen()),
      below: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AppIcon(AppIcons.lock, size: 14, color: AppColors.ink2),
          const SizedBox(width: AppSpace.x1_5),
          Text('Vous créerez votre compte juste avant la génération', style: AppText.meta),
        ],
      ),
      children: [
        if (foyer)
          _SummaryCard(
            icon: AppIcons.people,
            title: 'Composition du foyer',
            onEdit: () => edit(OnbStep.members),
            children: [
              _Line(
                icon: AppIcons.people,
                text: '${plural(d.peopleCount, 'personne')} : $composition',
                strong: true,
                onTap: () => edit(OnbStep.household),
              ),
              for (final m in d.members)
                _Line(
                  icon: switch (m.role) {
                    MemberRole.adulte => AppIcons.user,
                    MemberRole.enfant => AppIcons.child,
                    MemberRole.bebe => AppIcons.baby,
                  },
                  text: [
                    '${d.displayName(m)}, ${m.ageLabel}',
                    if (m.role == MemberRole.adulte) goals(L.of(context))[m.goal]!.$1,
                  ].join(' · '),
                  onTap: () => edit(OnbStep.members),
                ),
            ],
          )
        else
          _SummaryCard(
            icon: AppIcons.target,
            title: 'Objectif & profil',
            onEdit: () => edit(OnbStep.goal),
            children: [
              _Line(icon: goal.$2, text: goal.$1, strong: true),
              _Line(
                icon: AppIcons.user,
                text: '${d.sex == Sex.homme ? 'Homme' : 'Femme'}, ${d.age} ans · ${d.heightCm} cm · $weight kg',
                onTap: () => edit(OnbStep.profile),
              ),
              if (d.needsTarget && d.targetWeightKg != null)
                _Line(
                  icon: AppIcons.flag,
                  text:
                      'Objectif : ${OnboardingData.formatKg(d.targetWeightKg!)} kg · environ ${d.weeksToTarget()} semaines '
                      'à ${OnboardingData.formatRate(d.effectiveRate)} kg/semaine (vers le ${OnboardingData.formatDate(d.targetDate()!)})',
                  onTap: () => edit(OnbStep.profile),
                ),
              _Line(icon: AppIcons.walk, text: activities[d.activity]!, onTap: () => edit(OnbStep.activity)),
              _Line(
                icon: AppIcons.scale,
                text: d.wantsScale ? 'Balance via Health Connect' : 'Sans balance (saisie manuelle)',
                onTap: () => edit(OnbStep.scale),
              ),
            ],
          ),
        const SizedBox(height: AppSpace.x3),
        _SummaryCard(
          icon: AppIcons.calendar,
          title: 'Rythme & budget',
          tint: Tint.peach,
          onEdit: () => edit(OnbStep.budget),
          children: [
            _Line(
              icon: AppIcons.week,
              text: '${d.plannedMeals} repas / semaine : $mealsByType',
              onTap: () => edit(OnbStep.grid),
            ),
            _Line(
              icon: AppIcons.wallet,
              text: foyer
                  ? '${d.budgetEuros} € / semaine · ~${d.budgetPerPortion.toStringAsFixed(2).replaceAll('.', ',')} € par portion (${d.weeklyPortions} portions)'
                  : '${d.budgetEuros} € / semaine · ~${d.budgetPerMeal.toStringAsFixed(2).replaceAll('.', ',')} € par repas',
              strong: true,
            ),
          ],
        ),
        const SizedBox(height: AppSpace.x3),
        _SummaryCard(
          icon: AppIcons.fridge,
          title: 'Mode de gestion',
          tint: Tint.sky,
          onEdit: () => edit(OnbStep.management),
          children: [
            _Line(icon: AppIcons.balance, text: modes[d.management]!.$1, strong: true),
            _Line(icon: AppIcons.info, text: modes[d.management]!.$2),
            if (d.management != ManagementMode.courses)
              _Line(
                icon: AppIcons.checkCircle,
                text: d.pantry.isEmpty
                    ? 'Onglet Réserve activé · réserve à remplir plus tard'
                    : 'Onglet Réserve activé · ${d.pantry.length} produit${d.pantry.length > 1 ? 's' : ''} en réserve',
              ),
          ],
        ),
        const SizedBox(height: AppSpace.x3),
        _SummaryCard(
          icon: AppIcons.block,
          title: 'Régimes & exclusions',
          tint: Tint.lavender,
          onEdit: () => edit(OnbStep.constraints),
          children: [
            _Line(
              icon: AppIcons.leaf,
              text: dietLabels.isEmpty ? 'Régime : omnivore' : 'Régimes : ${dietLabels.join(', ')}',
            ),
            if (allergenLabels.isNotEmpty)
              _Line(icon: AppIcons.shield, text: 'Allergènes : ${allergenLabels.join(', ')}'),
            if (d.excludedFoods.isNotEmpty) _Line(icon: AppIcons.block, text: 'Exclus : ${d.excludedFoods.join(', ')}'),
            _Line(
              icon: AppIcons.cutlery,
              text: d.cuisinePreferences.isEmpty
                  ? 'Cuisines : toutes'
                  : 'Cuisines : ${[for (final c in OnboardingCuisinesScreen.cuisines(L.of(context)))
                      if (d.cuisinePreferences.contains(c.$1)) c.$2].join(', ')}',
              onTap: () => edit(OnbStep.cuisines),
            ),
          ],
        ),
        const SizedBox(height: AppSpace.x3),
        _SummaryCard(
          icon: AppIcons.chefHat,
          title: 'Ma cuisine',
          tint: Tint.leafy,
          onEdit: () => edit(OnbStep.kitchen),
          children: [
            if (foyer)
              _Line(
                icon: AppIcons.user,
                text: cook == null ? 'Cuisine : à tour de rôle' : 'Cuisine le plus souvent : ${d.displayName(cook)}',
              ),
            _Line(icon: AppIcons.skillet, text: 'Niveau : ${levels[d.cookingLevel]}', strong: true),
            _Line(
              icon: AppIcons.clock,
              text:
                  'Semaine : ${KitchenScreen.timeLabel(L.of(context), d.weekdayMinutes)} · week-end : ${KitchenScreen.timeLabel(L.of(context), d.weekendMinutes)}',
            ),
            _Line(icon: AppIcons.oven, text: equipmentLabels.join(', ')),
          ],
        ),
        const SizedBox(height: AppSpace.x3),
        _SummaryCard(
          icon: AppIcons.store,
          title: 'Supermarché',
          tint: Tint.sand,
          onEdit: () => edit(OnbStep.supermarket),
          children: [
            _Line(icon: AppIcons.car, text: channel, strong: true),
            if (d.store != null) _Line(icon: AppIcons.store, text: d.store!),
            if (d.postalCode.isNotEmpty) _Line(icon: AppIcons.mapPin, text: d.postalCode),
          ],
        ),
        // Cible calculée à partir du profil (Solo ; en Foyer, chaque profil a la sienne au jalon 6)
        if (!foyer) ...[
          const SizedBox(height: AppSpace.x4),
          Container(
            padding: const EdgeInsets.all(AppSpace.x4),
            decoration: const BoxDecoration(color: AppColors.mint, borderRadius: AppRadius.cardR),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cible journalière calculée',
                  style: AppText.of(AppFont.s13, weight: AppFont.bold, color: AppColors.primary),
                ),
                const SizedBox(height: AppSpace.x1),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: _thousands(d.dailyKcal),
                        style: AppText.of(AppFont.s28, weight: AppFont.extrabold, color: AppColors.primaryDark),
                      ),
                      TextSpan(
                        text: ' kcal / jour',
                        style: AppText.of(AppFont.s14, color: AppColors.ink2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpace.x2),
                Wrap(
                  spacing: AppSpace.x3,
                  runSpacing: AppSpace.x1,
                  children: [
                    _Macro(color: AppColors.primary, text: '${m.protein} g protéines'),
                    _Macro(color: AppColors.orange, text: '${m.carbs} g glucides'),
                    _Macro(color: AppColors.fat, text: '${m.fat} g lipides'),
                  ],
                ),
                const SizedBox(height: AppSpace.x2),
                Text(
                  d.needsTarget
                      ? 'Estimation selon votre profil et votre activité, avec un écart calculé pour ${d.goal == HealthGoal.priseMasse ? 'prendre' : 'perdre'} ${OnboardingData.formatRate(d.effectiveRate)} kg par semaine ; ajustée ensuite selon votre progression.'
                      : 'Estimation selon votre profil et votre activité pour stabiliser votre poids ; ajustée ensuite selon votre progression.',
                  style: AppText.of(AppFont.s12, color: AppColors.ink2, lineHeight: 17),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  static String _thousands(int v) {
    final s = '$v';
    return s.length > 3 ? '${s.substring(0, s.length - 3)} ${s.substring(s.length - 3)}' : s;
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.onEdit,
    required this.children,
    this.tint = Tint.mint,
  });

  final Tint tint;

  final String icon;
  final String title;
  final VoidCallback onEdit;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              TintBadge(icon: icon, tint: tint, size: AppSizes.iconTileSm),
              const SizedBox(width: AppSpace.x2_5),
              Expanded(child: Text(title, style: AppText.sectionTitle)),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onEdit,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpace.x1),
                  child: Row(
                    children: [
                      Text(
                        'Éditer',
                        style: AppText.of(AppFont.s13, weight: AppFont.bold, color: AppColors.primary),
                      ),
                      const SizedBox(width: AppSpace.x1),
                      const AppIcon(AppIcons.edit, size: 15, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.x2),
          ...children,
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.icon, required this.text, this.strong = false, this.onTap});

  final String icon;
  final String text;
  final bool strong;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpace.x1),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: AppSpace.x0_5),
              child: AppIcon(icon, size: 16, color: strong ? AppColors.primary : AppColors.ink3),
            ),
            const SizedBox(width: AppSpace.x2_5),
            Expanded(
              child: Text(
                text,
                style: AppText.of(
                  AppFont.s14,
                  weight: strong ? AppFont.bold : AppFont.regular,
                  color: strong ? AppColors.ink : AppColors.ink2,
                  lineHeight: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Macro extends StatelessWidget {
  const _Macro({required this.color, required this.text});

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Dot(color),
      const SizedBox(width: AppSpace.x1_5),
      Text(text, style: AppText.of(AppFont.s13, weight: AppFont.semibold)),
    ],
  );
}
