import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../l10n/formats.dart';
import '../../models/numeric_safety.dart';

import '../../onboarding/onboarding_scope.dart';
import '../../onboarding/onboarding_data.dart';
import '../../onboarding/onboarding_flow.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

/// Budget Solo/Foyer : montants hebdomadaires entiers dans la devise du brouillon.
/// Paramètres provisoires du prototype : curseur 20–350 par pas de 5,
/// valeur Solo initiale 65 ; saisie personnalisée au-delà du curseur.
class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  static const min = OnboardingData.minBudget;
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    OnboardingScope.read(context).initializeBudgetCurrency(Formats.of(context).currency);
  }

  Formats get _formats =>
      Formats(Localizations.localeOf(context), currency: OnboardingScope.read(context).budgetCurrencyCode);
  String _money(int amount) => OnboardingScope.read(context).budgetCurrencyUnknown
      ? '${_formats.wholeNumber(amount)} —'
      : _formats.priceWhole(amount);

  String _portion(double amount) {
    final cents = NumericSafety.round(amount * 100);
    if (cents == null) return L.of(context).numericValueUnavailable;
    return OnboardingScope.read(context).budgetCurrencyUnknown
        ? '${_formats.number(amount, decimals: 2)} —'
        : _formats.price(cents);
  }

  Future<void> _confirmCurrency() async {
    final d = OnboardingScope.read(context);
    final l = L.of(context);
    String? selected;
    final code = await showDialog<String>(
      context: context,
      builder: (dialog) => StatefulBuilder(
        builder: (dialog, rebuild) => AlertDialog(
          title: Text(l.budgetCurrencyTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l.budgetCurrencyExplanation),
              DropdownButton<String>(
                isExpanded: true,
                value: selected,
                items: [
                  for (final code in OnboardingData.budgetCurrencies) DropdownMenuItem(value: code, child: Text(code)),
                ],
                onChanged: (value) => rebuild(() => selected = value),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialog).pop(), child: Text(l.budgetCurrencyCancel)),
            TextButton(
              onPressed: selected == null ? null : () => Navigator.of(dialog).pop(selected),
              child: Text(l.budgetCurrencyConfirm),
            ),
          ],
        ),
      ),
    );
    if (!mounted || code == null) return;
    d.confirmBudgetCurrency(code);
  }

  void _applyCustom(String text) {
    final normalized = text.trim();
    final value = RegExp(r'^\d+$').hasMatch(normalized) ? int.tryParse(normalized) : null;
    final d = OnboardingScope.read(context);
    if (text.trim().isEmpty) {
      setState(() => _error = null);
      return;
    }
    if (value == null) {
      setState(() => _error = L.of(context).budgetWholeError);
      return;
    }
    if (value < BudgetScreen.min) {
      setState(() => _error = L.of(context).budgetMinError(_money(BudgetScreen.min)));
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
    return OnboardingStepScaffold(
      horizontalPadding: BudgetTokens.gutter,
      subtitleColor: BudgetTokens.bodyInk,
      step: OnboardingFlow.number(context, OnbStep.budget),
      totalSteps: OnboardingFlow.total(context),
      eyebrow: l.budgetEyebrow,
      eyebrowIcon: AppIcons.budgetWallet,
      title: d.isFoyer ? l.budgetTitleHousehold : l.budgetTitleSolo,
      subtitle: d.isFoyer ? l.budgetSubtitleHousehold : l.budgetSubtitleSolo,
      onContinue: _error != null || d.budgetCurrencyUnknown || !d.hasValidBudgetAmount
          ? null
          : () => OnboardingFlow.next(context, OnbStep.budget),
      children: [
        if (d.budgetCurrencyUnknown) ...[
          FormError(message: l.budgetInheritedUnknown(_formats.wholeNumber(d.budgetEuros))),
          TextLink(l.budgetConfirmCurrency, onTap: _confirmCurrency),
          const SizedBox(height: AppSpace.x4),
        ],
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
                        borderRadius: BudgetTokens.badgeRadius,
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
                        Flexible(
                          child: AnimatedSwitcher(
                            duration: AppMotion.fast,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                _formats.wholeNumber(d.budgetEuros),
                                key: ValueKey(d.budgetEuros),
                                style: AppText.of(AppFont.s44, weight: AppFont.extrabold, color: AppColors.primaryDark),
                              ),
                            ),
                          ),
                        ),
                        Text(
                          ' ${d.budgetCurrencyUnknown ? '—' : _formats.currencySymbol} ',
                          style: AppText.of(AppFont.s22, weight: AppFont.extrabold, color: AppColors.primaryDark),
                        ),
                        Text(l.budgetPerWeek, style: AppText.of(AppFont.s14, color: BudgetTokens.bodyInk)),
                      ],
                    ),
                    Text(
                      d.isFoyer
                          ? l.budgetPerPortion(_portion(d.budgetPerPortion), d.weeklyPortions)
                          : l.budgetPerMeal(_portion(d.budgetPerMeal), d.plannedMeals),
                      style: AppText.of(AppFont.s13, color: BudgetTokens.bodyInk),
                    ),
                    const SizedBox(height: AppSpace.x2),
                    MenooSlider(
                      value: d.budgetEuros.clamp(BudgetScreen.min, BudgetScreen.max).toDouble(),
                      min: BudgetScreen.min.toDouble(),
                      max: BudgetScreen.max.toDouble(),
                      divisions: (BudgetScreen.max - BudgetScreen.min) ~/ BudgetScreen.step,
                      semanticLabel: l.budgetSliderLabel(_money(d.budgetEuros)),
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
                          Text(_money(BudgetScreen.min), style: AppText.meta.copyWith(color: BudgetTokens.bodyInk)),
                          Text(_money(BudgetScreen.max), style: AppText.meta.copyWith(color: BudgetTokens.bodyInk)),
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
        Text(
          l.budgetCustomText(_money(BudgetScreen.max)),
          style: AppText.caption.copyWith(color: BudgetTokens.bodyInk),
        ),
        const SizedBox(height: AppSpace.x2_5),
        IconTextField(
          icon: AppIcons.budgetPiggy,
          hint: l.budgetCustomHint,
          controller: _custom,
          keyboardType: TextInputType.number,
          suffix: l.budgetCustomSuffix(d.budgetCurrencyUnknown ? '—' : _formats.currencySymbol),
          onChanged: _applyCustom,
        ),
        FormError(message: _error ?? (!d.hasValidBudgetAmount ? l.budgetMinError(_money(BudgetScreen.min)) : null)),
        if (d.isFoyer) ...[
          const SizedBox(height: AppSpace.x4),
          InfoBanner(
            icon: AppIcons.people,
            title: l.budgetAdvisedTitle(_money(d.recommendedBudget)),
            text: l.budgetAdvisedText(d.peopleCount, _money(30), _money(20), _money(25)),
            textColor: BudgetTokens.bodyInk,
            background: AppColors.leafySoft,
          ),
        ],
        const SizedBox(height: AppSpace.x4),
        InfoBanner(
          icon: AppIcons.shield,
          title: l.budgetLimitTitle,
          text: l.budgetLimitText,
          textColor: BudgetTokens.bodyInk,
        ),
      ],
    );
  }
}
