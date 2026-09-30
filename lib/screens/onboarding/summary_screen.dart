import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../l10n/formats.dart';
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
  static Map<ActivityLevel, String> activities(L l) => {
    ActivityLevel.sedentaire: l.activitySedentaryShort,
    ActivityLevel.modere: l.activityModerateShort,
    ActivityLevel.actif: l.activityActiveShort,
    ActivityLevel.tresActif: l.activityVeryActiveShort,
  };
  static Map<ManagementMode, (String, String)> modes(L l) => {
    ManagementMode.courses: (l.modeShoppingOnlyTitle, l.modeShoppingOnlyText),
    ManagementMode.reserves: (l.modePantryOnlyTitle, l.modePantryOnlyText),
    ManagementMode.mixte: (l.modeMixedTitle, l.modeMixedText),
  };
  static Map<CookingLevel, String> levels(L l) => {
    CookingLevel.debutant: l.levelBeginnerShort,
    CookingLevel.intermediaire: l.levelIntermediateShort,
    CookingLevel.confirme: l.levelAdvancedShort,
  };
  static Map<MealType, String> mealNames(L l) => {
    MealType.petitDejeuner: l.mealBreakfastPlural,
    MealType.dejeuner: l.mealLunchPlural,
    MealType.diner: l.mealDinnerPlural,
  };

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final d = OnboardingScope.of(context);
    final fmt = Formats.of(context);
    final goal = goals(l)[d.goal]!;
    final m = d.macros;
    void edit(OnbStep step) => OnboardingFlow.open(context, step, fromSummary: true);
    final weight = fmt.weight(l, d.weightKg);
    final mealsByType = [
      for (final t in MealType.values)
        if (d.slots.any((s) => s.$2 == t)) l.mealCountOfType(d.slots.where((s) => s.$2 == t).length, mealNames(l)[t]!),
    ].join(', ');
    final dietLabels = [
      for (final diet in ConstraintsScreen.diets(l))
        if (d.diets.contains(diet.$1)) diet.$2,
    ];
    // Foyer : allergènes partagés + ceux des profils (avec les prénoms concernés)
    final byMember = d.isFoyer ? d.memberAllergens : const <String, List<String>>{};
    final allergenLabels = [
      for (final a in ConstraintsScreen.allergenChoices(l))
        if (a.$1.any(d.allAllergens.contains))
          a.$1.any(byMember.containsKey) && !a.$1.any(d.allergens.contains)
              ? '${a.$2} (${{for (final c in a.$1) ...?byMember[c]}.join(', ')})'
              : a.$2,
    ];
    final equipmentLabels = [
      for (final e in KitchenScreen.equipment(l))
        if (d.equipment.contains(e.$1)) e.$2,
    ];
    final channel = SupermarketScreen.channels(l).firstWhere((c) => c.$1 == d.channel).$2;
    final foyer = d.isFoyer;
    final cook = d.members.where((m) => m.id == d.mainCookId).firstOrNull;
    final composition = [
      if (d.count(MemberRole.adulte) > 0) l.summaryAdultCount(d.count(MemberRole.adulte)),
      if (d.count(MemberRole.enfant) > 0) l.summaryChildCount(d.count(MemberRole.enfant)),
      if (d.count(MemberRole.bebe) > 0) l.summaryBabyCount(d.count(MemberRole.bebe)),
    ].join(', ');

    return OnboardingStepScaffold(
      step: OnboardingFlow.number(context, OnbStep.summary),
      totalSteps: OnboardingFlow.total(context),
      eyebrow: l.summaryEyebrow,
      eyebrowIcon: AppIcons.checkCircle,
      title: foyer ? l.summaryTitleHousehold : l.summaryTitleSolo,
      subtitle: foyer
          ? l.summarySubtitleHousehold(d.plannedMeals)
          : l.summarySubtitleSolo,
      continueLabel: foyer ? l.summaryGenerateHousehold : l.summaryGenerateSolo,
      onContinue: () => push(context, const SignupScreen()),
      below: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AppIcon(AppIcons.lock, size: 14, color: AppColors.ink2),
          const SizedBox(width: AppSpace.x1_5),
          Text(l.summaryAccountNote, style: AppText.meta),
        ],
      ),
      children: [
        if (foyer)
          _SummaryCard(
            icon: AppIcons.people,
            title: l.summaryHouseholdCompositionTitle,
            onEdit: () => edit(OnbStep.members),
            children: [
              _Line(
                icon: AppIcons.people,
                text: l.summaryPersonCount(d.peopleCount, composition),
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
                    l.summaryMemberLine(d.displayName(m), m.ageLabel(l)),
                    if (m.role == MemberRole.adulte) goals(l)[m.goal]!.$1,
                  ].join(' · '),
                  onTap: () => edit(OnbStep.members),
                ),
            ],
          )
        else
          _SummaryCard(
            icon: AppIcons.target,
            title: l.summaryGoalProfileTitle,
            onEdit: () => edit(OnbStep.goal),
            children: [
              _Line(icon: goal.$2, text: goal.$1, strong: true),
              _Line(
                icon: AppIcons.user,
                text: l.summarySexAge(d.sex == Sex.homme ? l.profileSexMale : l.profileSexFemale, d.age, fmt.height(l, d.heightCm.toDouble()), weight),
                onTap: () => edit(OnbStep.profile),
              ),
              if (d.needsTarget && d.targetWeightKg != null)
                _Line(
                  icon: AppIcons.flag,
                  text: l.summaryTargetLine(fmt.weight(l, d.targetWeightKg!), d.weeksToTarget() ?? 0, fmt.rate(l, d.effectiveRate), fmt.date(d.targetDate()!)),
                  onTap: () => edit(OnbStep.profile),
                ),
              _Line(icon: AppIcons.walk, text: activities(l)[d.activity]!, onTap: () => edit(OnbStep.activity)),
              _Line(
                icon: AppIcons.scale,
                text: d.wantsScale ? l.summaryScaleYes : l.summaryScaleNo,
                onTap: () => edit(OnbStep.scale),
              ),
            ],
          ),
        const SizedBox(height: AppSpace.x3),
        _SummaryCard(
          icon: AppIcons.calendar,
          title: l.summaryPaceBudgetTitle,
          tint: Tint.peach,
          onEdit: () => edit(OnbStep.budget),
          children: [
            _Line(
              icon: AppIcons.week,
              text: l.summaryMealsPerWeek(d.plannedMeals, mealsByType),
              onTap: () => edit(OnbStep.grid),
            ),
            _Line(
              icon: AppIcons.wallet,
              text: foyer
                  ? l.summaryBudgetPortion(fmt.priceRounded(d.budgetEuros * 100), fmt.price((d.budgetPerPortion * 100).round()), d.weeklyPortions)
                  : l.summaryBudgetMeal(fmt.priceRounded(d.budgetEuros * 100), fmt.price((d.budgetPerMeal * 100).round())),
              strong: true,
            ),
          ],
        ),
        const SizedBox(height: AppSpace.x3),
        _SummaryCard(
          icon: AppIcons.fridge,
          title: l.summaryManagementTitle,
          tint: Tint.sky,
          onEdit: () => edit(OnbStep.management),
          children: [
            _Line(icon: AppIcons.balance, text: modes(l)[d.management]!.$1, strong: true),
            _Line(icon: AppIcons.info, text: modes(l)[d.management]!.$2),
            if (d.management != ManagementMode.courses)
              _Line(
                icon: AppIcons.checkCircle,
                text: d.pantry.isEmpty
                    ? l.summaryPantryEmptyLater
                    : l.summaryPantryCount(d.pantry.length),
              ),
          ],
        ),
        const SizedBox(height: AppSpace.x3),
        _SummaryCard(
          icon: AppIcons.block,
          title: l.summaryDietExclusionsTitle,
          tint: Tint.lavender,
          onEdit: () => edit(OnbStep.constraints),
          children: [
            _Line(
              icon: AppIcons.leaf,
              text: dietLabels.isEmpty ? l.summaryDietOmnivore : l.summaryDietsList(dietLabels.join(', ')),
            ),
            if (allergenLabels.isNotEmpty)
              _Line(icon: AppIcons.shield, text: l.summaryAllergensList(allergenLabels.join(', '))),
            if (d.excludedFoods.isNotEmpty) _Line(icon: AppIcons.block, text: l.summaryExcludedList(d.excludedFoods.join(', '))),
            _Line(
              icon: AppIcons.cutlery,
              text: d.cuisinePreferences.isEmpty
                  ? l.summaryCuisinesAll
                  : l.summaryCuisinesList([for (final c in OnboardingCuisinesScreen.cuisines(l))
                      if (d.cuisinePreferences.contains(c.$1)) c.$2].join(', ')),
              onTap: () => edit(OnbStep.cuisines),
            ),
          ],
        ),
        const SizedBox(height: AppSpace.x3),
        _SummaryCard(
          icon: AppIcons.chefHat,
          title: l.summaryKitchenTitle,
          tint: Tint.leafy,
          onEdit: () => edit(OnbStep.kitchen),
          children: [
            if (foyer)
              _Line(
                icon: AppIcons.user,
                text: cook == null ? l.summaryCookRotating : l.summaryCookName(d.displayName(cook)),
              ),
            _Line(icon: AppIcons.skillet, text: l.summaryLevel(levels(l)[d.cookingLevel]!), strong: true),
            _Line(
              icon: AppIcons.clock,
              text:
                  l.summaryTimes(KitchenScreen.timeLabel(l, d.weekdayMinutes), KitchenScreen.timeLabel(l, d.weekendMinutes)),
            ),
            _Line(icon: AppIcons.oven, text: equipmentLabels.join(', ')),
          ],
        ),
        const SizedBox(height: AppSpace.x3),
        _SummaryCard(
          icon: AppIcons.store,
          title: l.summarySupermarketTitle,
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
                  l.summaryDailyTargetTitle,
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
                        text: l.summaryKcalPerDaySuffix,
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
                    _Macro(color: AppColors.primary, text: l.summaryProteinG(m.protein)),
                    _Macro(color: AppColors.orange, text: l.summaryCarbsG(m.carbs)),
                    _Macro(color: AppColors.fat, text: l.summaryFatG(m.fat)),
                  ],
                ),
                const SizedBox(height: AppSpace.x2),
                Text(
                  d.needsTarget
                      ? l.summaryEstimateTarget(d.goal == HealthGoal.priseMasse ? l.summaryGain : l.summaryLose, fmt.rate(l, d.effectiveRate))
                      : l.summaryEstimateMaintain,
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
    final l = L.of(context);
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
                        l.summaryEdit,
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
