import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../l10n/formats.dart';import 'package:flutter/services.dart';

import '../../onboarding/onboarding_scope.dart';
import '../../onboarding/onboarding_flow.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

/// onboarding_budget (Solo 6/12) et onboarding_budget_household (Foyer 4/10).
/// SPEC §6 : curseur 20 € → 350 € (pas de 5 €) + « Budget personnalisé » au-delà ;
/// valeur de départ Solo ≈ 65 € ; plus de cartes prédéfinies ni de « 22 € économisés ».
class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  static const min = 20;
  static const max = 350;
  static const step = 5;

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final _custom = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _custom.dispose();
    super.dispose();
  }

  void _applyCustom(String text) {
    final value = int.tryParse(text.trim());
    final d = OnboardingScope.read(context);
    if (text.trim().isEmpty) {
      setState(() => _error = null);
      return;
    }
    if (value == null || value < BudgetScreen.min) {
      setState(() => _error = L.of(context).budgetMinError(Formats.of(context).priceRounded(BudgetScreen.min * 100)));
      return;
    }
    setState(() => _error = null);
    d.update(() {
      d.budgetEuros = value;
      d.budgetEdited = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final d = OnboardingScope.of(context);
    final perMeal = d.budgetPerMeal.toStringAsFixed(2).replaceAll('.', ',');
    return OnboardingStepScaffold(
      step: OnboardingFlow.number(context, OnbStep.budget),
      totalSteps: OnboardingFlow.total(context),
      eyebrow: l.budgetEyebrow,
      eyebrowIcon: AppIcons.wallet,
      title: d.isFoyer ? l.budgetTitleHousehold : l.budgetTitleSolo,
      subtitle: d.isFoyer
          ? l.budgetSubtitleHousehold
          : l.budgetSubtitleSolo,
      onContinue: _error != null ? null : () => OnboardingFlow.next(context, OnbStep.budget),
      children: [
        AppCard(
          padding: EdgeInsets.zero,
          clip: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: AppSizes.budgetPhotoH,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset('assets/images/budget_marche.jpg', fit: BoxFit.cover, excludeFromSemantics: true),
                    PositionedDirectional(
                      start: AppSpace.x3,
                      bottom: AppSpace.x3,
                      child: PillBadge(
                        l.budgetBadge,
                        icon: AppIcons.checkCircle,
                        background: AppColors.overlayCard,
                        size: AppFont.s12,
                        padding: EdgeInsets.symmetric(horizontal: AppSpace.x2_5, vertical: AppSpace.x1),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpace.x4, AppSpace.x4, AppSpace.x4, AppSpace.x3),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        AnimatedSwitcher(
                          duration: AppMotion.fast,
                          child: Text(
                            '${d.budgetEuros}',
                            key: ValueKey(d.budgetEuros),
                            style: AppText.of(AppFont.s44, weight: AppFont.extrabold, color: AppColors.primaryDark),
                          ),
                        ),
                        Text(
                          ' € ',
                          style: AppText.of(AppFont.s22, weight: AppFont.extrabold, color: AppColors.primaryDark),
                        ),
                        Text(l.budgetPerWeek, style: AppText.of(AppFont.s14, color: AppColors.ink2)),
                      ],
                    ),
                    Text(
                      d.isFoyer
                          ? l.budgetPerPortion(Formats.of(context).price((d.budgetPerPortion * 100).round()), d.weeklyPortions)
                          : l.budgetPerMeal(Formats.of(context).price((d.budgetPerMeal * 100).round()), d.plannedMeals),
                      style: AppText.of(AppFont.s13, color: AppColors.ink2),
                    ),
                    const SizedBox(height: AppSpace.x2),
                    MenooSlider(
                      value: d.budgetEuros.clamp(BudgetScreen.min, BudgetScreen.max).toDouble(),
                      min: BudgetScreen.min.toDouble(),
                      max: BudgetScreen.max.toDouble(),
                      divisions: (BudgetScreen.max - BudgetScreen.min) ~/ BudgetScreen.step,
                      semanticLabel: l.budgetSliderLabel(Formats.of(context).priceRounded(d.budgetEuros * 100)),
                      onChanged: (v) {
                        _custom.clear();
                        setState(() => _error = null);
                        d.update(() {
                          d.budgetEuros = v.round();
                          d.budgetEdited = true;
                        });
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpace.x4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(Formats.of(context).priceRounded(BudgetScreen.min * 100), style: AppText.meta),
                          Text(Formats.of(context).priceRounded(BudgetScreen.max * 100), style: AppText.meta),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpace.x5),
        Text(l.budgetCustomTitle, style: AppText.of(AppFont.s15, weight: AppFont.semibold, lineHeight: 22)),
        const SizedBox(height: AppSpace.x1),
        Text(l.budgetCustomText(Formats.of(context).priceRounded(BudgetScreen.max * 100)), style: AppText.caption),
        const SizedBox(height: AppSpace.x2_5),
        IconTextField(
          icon: AppIcons.piggy,
          hint: l.budgetCustomHint,
          controller: _custom,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          suffix: l.budgetCustomSuffix,
          onChanged: _applyCustom,
        ),
        FormError(message: _error),
        if (d.isFoyer) ...[
          const SizedBox(height: AppSpace.x4),
          InfoBanner(
            icon: AppIcons.people,
            title: l.budgetAdvisedTitle(Formats.of(context).priceRounded(d.recommendedBudget * 100)),
            text: l.budgetAdvisedText(d.peopleCount),
            background: AppColors.leafySoft,
          ),
        ],
        const SizedBox(height: AppSpace.x4),
        InfoBanner(
          icon: AppIcons.shield,
          title: l.budgetLimitTitle,
          text: l.budgetLimitText,
        ),
      ],
    );
  }
}
