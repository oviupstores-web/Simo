import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../l10n/formats.dart';
import '../../onboarding/onboarding_data.dart';
import '../../onboarding/onboarding_scope.dart';
import '../../onboarding/onboarding_flow.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

/// onboarding_profile (Solo, étape 2/12) — maître : design/masters/master_formulaire.html
/// (réf. 05). Gabarit de tous les écrans d'onboarding à saisie.
/// SPEC §2 : pas d'avatar ; le niveau d'activité est l'étape 3.
/// Retours jalon 4 : poids visé + rythme selon l'objectif, avec garde-fous (IMC ≥ 18,5,
/// perte ≤ 1 kg/semaine) et date estimée d'atteinte.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _age = TextEditingController();
  final _height = TextEditingController();
  final _weight = TextEditingController();
  final _target = TextEditingController();
  String? _error;
  bool _showTargetError = false;
  bool _init = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_init) return;
    _init = true;
    final d = OnboardingScope.read(context);
    _age.text = '${d.age}';
    _height.text = '${d.heightCm}';
    _weight.text = OnboardingData.formatKg(d.weightKg);
    if (d.targetWeightKg != null) _target.text = OnboardingData.formatKg(d.targetWeightKg!);
    for (final c in [_height, _weight, _target]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _age.dispose();
    _height.dispose();
    _weight.dispose();
    _target.dispose();
    super.dispose();
  }

  static double? _num(String s) => double.tryParse(s.trim().replaceAll(',', '.'));

  void _continue() {
    final d = OnboardingScope.read(context);
    final age = int.tryParse(_age.text.trim());
    final height = int.tryParse(_height.text.trim());
    final weight = _num(_weight.text);
    final target = _num(_target.text);
    String? error;
    if (age == null || age < 14 || age > 100) {
      error = L.of(context).profileAgeError;
    } else if (height == null || height < 120 || height > 230) {
      error = L.of(context).profileHeightError;
    } else if (weight == null || weight < 35 || weight > 250) {
      error = L.of(context).profileWeightError;
    }
    final targetError = error == null ? d.targetError(L.of(context), Formats.of(context), target: target, current: weight!, heightCm: height!) : null;
    setState(() {
      _error = error;
      _showTargetError = targetError != null;
    });
    if (error != null || targetError != null) return;
    d.update(() {
      d.age = age!;
      d.heightCm = height!;
      d.weightKg = weight!;
      d.targetWeightKg = d.needsTarget ? target : null;
      d.weeklyRateKg = d.effectiveRate;
    });
    OnboardingFlow.next(context, OnbStep.profile);
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final d = OnboardingScope.of(context);
    return OnboardingStepScaffold(
      step: OnboardingFlow.number(context, OnbStep.profile),
      totalSteps: OnboardingFlow.total(context),
      title: l.profileTitle,
      subtitle: l.profileSubtitle,
      onContinue: _continue,
      decor: const [
        PositionedDirectional(
          end: AppSpace.x2,
          top: AppSpace.x2,
          child: BasilDecor(leafWidth: 40, mirror: true, peppers: false),
        ),
        PositionedDirectional(start: AppSpace.x2, bottom: 0, child: BasilDecor(leafWidth: 54)),
      ],
      textRightInset: AppSpace.x10,
      below: const SizedBox(height: AppSizes.leafFooterH),
      children: [
        Text(l.profileSexLabel, style: AppText.of(AppFont.s15, weight: AppFont.semibold, lineHeight: 22)),
        const SizedBox(height: AppSpace.x2_5),
        Row(
          children: [
            Expanded(
              child: SegmentButton(
                label: l.profileSexMale,
                icon: AppIcons.male,
                selected: d.sex == Sex.homme,
                onTap: () => d.update(() => d.sex = Sex.homme),
              ),
            ),
            const SizedBox(width: AppSpace.x3),
            Expanded(
              child: SegmentButton(
                label: l.profileSexFemale,
                icon: AppIcons.female,
                selected: d.sex == Sex.femme,
                onTap: () => d.update(() => d.sex = Sex.femme),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpace.x6),
        UnitFieldRow(label: l.profileAgeLabel, unit: l.profileAgeUnit, controller: _age),
        const SizedBox(height: AppSpace.x4),
        UnitFieldRow(label: l.profileHeightLabel, unit: 'cm', controller: _height),
        const SizedBox(height: AppSpace.x4),
        UnitFieldRow(label: l.profileWeightLabel, unit: 'kg', controller: _weight),
        FormError(message: _error),
        const SizedBox(height: AppSpace.x6),
        if (d.needsTarget) ..._targetSection(context, d) else _maintainNote(l),
        const SizedBox(height: AppSpace.x6),
        InfoBanner(
          icon: AppIcons.leaf,
          iconTopOffset: AppSpace.x0_5,
          text: l.profilePrivacy,
        ),
      ],
    );
  }

  Widget _maintainNote(L l) => InfoBanner(
    icon: AppIcons.lotus,
    title: l.profileMaintainTitle,
    text: l.profileMaintainText,
    background: AppColors.leafySoft,
  );

  List<Widget> _targetSection(BuildContext context, OnboardingData d) {
    final l = L.of(context);
    final losing = d.goal != HealthGoal.priseMasse;
    final height = int.tryParse(_height.text.trim());
    final current = _num(_weight.text);
    final target = _num(_target.text);
    final liveError = (height == null || current == null)
        ? null
        : d.targetError(l, Formats.of(context), target: target, current: current, heightCm: height);
    final showError = liveError != null && (_showTargetError || (target != null && _target.text.length >= 2));
    final weeks = liveError == null ? d.weeksToTarget(target: target, current: current) : null;
    final date = liveError == null ? d.targetDate(target: target, current: current) : null;

    return [
      StepSectionTitle(
        l.profileTargetSection,
        icon: losing ? AppIcons.trendDown : AppIcons.trend,
        tint: switch (d.goal) {
          HealthGoal.priseMasse => Tint.peach,
          HealthGoal.seche => Tint.lavender,
          _ => Tint.mint,
        },
      ),
      UnitFieldRow(label: l.profileTargetLabel, unit: 'kg', controller: _target),
      if (d.rateOptions.length > 1) ...[
        const SizedBox(height: AppSpace.x4),
        Text(l.profileRateLabel, style: AppText.of(AppFont.s15, weight: AppFont.semibold, lineHeight: 22)),
        const SizedBox(height: AppSpace.x2_5),
        Row(
          children: [
            for (final (i, r) in d.rateOptions.indexed) ...[
              if (i > 0) const SizedBox(width: AppSpace.x2),
              Expanded(
                child: _RateTile(
                  rate: r,
                  caption: switch (r) {
                    0.25 => l.profileRateGentle,
                    0.5 => l.commonRecommended,
                    _ => l.profileRateSteady,
                  },
                  selected: d.effectiveRate == r,
                  onTap: () => d.update(() => d.weeklyRateKg = r),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpace.x2),
        Text(
          losing
              ? l.profileLosingNote
              : l.profileGainingNote,
          style: AppText.meta,
        ),
      ],
      if (d.goal == HealthGoal.seche) ...[
        const SizedBox(height: AppSpace.x4),
        InfoBanner(
          icon: AppIcons.dumbbell,
          title: l.profileCutTitle,
          text: l.profileCutText,
          background: AppColors.lavenderSoft,
        ),
      ],
      FormError(message: showError ? liveError : null),
      AnimatedSize(
        duration: AppMotion.normal,
        curve: AppMotion.curve,
        child: (weeks == null || date == null || current == null || target == null)
            ? const SizedBox(width: double.infinity)
            : Padding(
                padding: const EdgeInsets.only(top: AppSpace.x4),
                child: _Projection(current: current, target: target, weeks: weeks, rate: d.effectiveRate, date: date),
              ),
      ),
    ];
  }
}

class _RateTile extends StatelessWidget {
  const _RateTile({required this.rate, required this.caption, required this.selected, required this.onTap});

  final double rate;
  final String caption;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppColors.primary : AppColors.ink;
    return Semantics(
      selected: selected,
      button: true,
      child: Pressable(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppMotion.normal,
          curve: AppMotion.curve,
          padding: const EdgeInsets.symmetric(vertical: AppSpace.x2_5),
          decoration: BoxDecoration(
            color: selected ? AppColors.mintTint : AppColors.card,
            borderRadius: AppRadius.fieldR,
            border: Border.all(color: selected ? AppColors.primary : AppColors.line, width: selected ? 1.5 : 1),
          ),
          child: Column(
            children: [
              Text(
                Formats.of(context).rate(L.of(context), rate),
                style: AppText.of(AppFont.s16, weight: AppFont.extrabold, color: fg, lineHeight: 22),
              ),
              Text(L.of(context).profileRatePerWeek, style: AppText.of(AppFont.s11, color: AppColors.ink2)),
              const SizedBox(height: AppSpace.x1),
              Text(
                caption,
                style: AppText.of(
                  AppFont.s11,
                  weight: AppFont.bold,
                  color: selected ? AppColors.primary : AppColors.ink3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// « 75 kg aujourd'hui → 70 kg visés, environ 10 semaines à 0,5 kg/semaine ».
class _Projection extends StatelessWidget {
  const _Projection({
    required this.current,
    required this.target,
    required this.weeks,
    required this.rate,
    required this.date,
  });

  final double current;
  final double target;
  final int weeks;
  final double rate;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    TextStyle big(Color c) => AppText.of(AppFont.s22, weight: AppFont.extrabold, color: c, lineHeight: 28);
    return Container(
      padding: const EdgeInsets.all(AppSpace.x4),
      decoration: const BoxDecoration(color: AppColors.mint, borderRadius: AppRadius.cardR),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(Formats.of(context).weight(L.of(context), current), style: big(AppColors.ink)),
                  Text(L.of(context).profileToday, style: AppText.meta),
                ],
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(AppSpace.x3, 0, AppSpace.x3, AppSpace.x4),
                child: AppIcon(AppIcons.arrowRight, size: 22, color: AppColors.primary),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(Formats.of(context).weight(L.of(context), target), style: big(AppColors.primaryDark)),
                  Text(L.of(context).profileTargeted, style: AppText.meta),
                ],
              ),
              const Spacer(),
              const TintBadge(icon: AppIcons.flag, size: AppSizes.iconTile, circle: true),
            ],
          ),
          const SizedBox(height: AppSpace.x2),
          Text(
            L.of(context).profileProjection(weeks, Formats.of(context).rate(L.of(context), rate)),
            style: AppText.of(AppFont.s14, weight: AppFont.bold, lineHeight: 20),
          ),
          Text(L.of(context).profileTargetDate(Formats.of(context).date(date)), style: AppText.caption),
        ],
      ),
    );
  }
}
