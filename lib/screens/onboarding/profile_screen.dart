import 'package:flutter/material.dart';

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
      error = 'Indiquez un âge entre 14 et 100 ans.';
    } else if (height == null || height < 120 || height > 230) {
      error = 'Indiquez une taille entre 120 et 230 cm.';
    } else if (weight == null || weight < 35 || weight > 250) {
      error = 'Indiquez un poids entre 35 et 250 kg.';
    }
    final targetError = error == null ? d.targetError(target: target, current: weight!, heightCm: height!) : null;
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
    final d = OnboardingScope.of(context);
    return OnboardingStepScaffold(
      step: OnboardingFlow.number(context, OnbStep.profile),
      totalSteps: OnboardingFlow.total(context),
      title: 'Parlez-nous de vous',
      subtitle: 'Ces informations nous aident à calculer vos besoins et à personnaliser vos menus.',
      onContinue: _continue,
      decor: const [
        Positioned(
          right: AppSpace.x2,
          top: AppSpace.x2,
          child: BasilDecor(leafWidth: 40, mirror: true, peppers: false),
        ),
        Positioned(left: AppSpace.x2, bottom: 0, child: BasilDecor(leafWidth: 54)),
      ],
      textRightInset: AppSpace.x10,
      below: const SizedBox(height: AppSizes.leafFooterH),
      children: [
        Text('Votre sexe', style: AppText.of(AppFont.s15, weight: AppFont.semibold, lineHeight: 22)),
        const SizedBox(height: AppSpace.x2_5),
        Row(
          children: [
            Expanded(
              child: SegmentButton(
                label: 'Homme',
                icon: AppIcons.male,
                selected: d.sex == Sex.homme,
                onTap: () => d.update(() => d.sex = Sex.homme),
              ),
            ),
            const SizedBox(width: AppSpace.x3),
            Expanded(
              child: SegmentButton(
                label: 'Femme',
                icon: AppIcons.female,
                selected: d.sex == Sex.femme,
                onTap: () => d.update(() => d.sex = Sex.femme),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpace.x6),
        UnitFieldRow(label: 'Votre âge', unit: 'ans', controller: _age),
        const SizedBox(height: AppSpace.x4),
        UnitFieldRow(label: 'Votre taille', unit: 'cm', controller: _height),
        const SizedBox(height: AppSpace.x4),
        UnitFieldRow(label: 'Votre poids actuel', unit: 'kg', controller: _weight),
        FormError(message: _error),
        const SizedBox(height: AppSpace.x6),
        if (d.needsTarget) ..._targetSection(d) else _maintainNote(),
        const SizedBox(height: AppSpace.x6),
        const InfoBanner(
          icon: AppIcons.leaf,
          iconTopOffset: AppSpace.x0_5,
          text: 'Ces informations restent confidentielles et ne servent qu\'à personnaliser votre expérience.',
        ),
      ],
    );
  }

  Widget _maintainNote() => const InfoBanner(
    icon: AppIcons.lotus,
    title: 'Objectif maintien & équilibre',
    text: 'Pas de poids à viser : Menoo stabilise votre poids actuel et varie vos menus.',
    background: AppColors.leafySoft,
  );

  List<Widget> _targetSection(OnboardingData d) {
    final losing = d.goal != HealthGoal.priseMasse;
    final height = int.tryParse(_height.text.trim());
    final current = _num(_weight.text);
    final target = _num(_target.text);
    final liveError = (height == null || current == null)
        ? null
        : d.targetError(target: target, current: current, heightCm: height);
    final showError = liveError != null && (_showTargetError || (target != null && _target.text.length >= 2));
    final weeks = liveError == null ? d.weeksToTarget(target: target, current: current) : null;
    final date = liveError == null ? d.targetDate(target: target, current: current) : null;

    return [
      StepSectionTitle(
        'Votre objectif de poids',
        icon: losing ? AppIcons.trendDown : AppIcons.trend,
        tint: switch (d.goal) {
          HealthGoal.priseMasse => Tint.peach,
          HealthGoal.seche => Tint.lavender,
          _ => Tint.mint,
        },
      ),
      UnitFieldRow(label: 'Poids visé', unit: 'kg', controller: _target),
      if (d.rateOptions.length > 1) ...[
        const SizedBox(height: AppSpace.x4),
        Text('Rythme', style: AppText.of(AppFont.s15, weight: AppFont.semibold, lineHeight: 22)),
        const SizedBox(height: AppSpace.x2_5),
        Row(
          children: [
            for (final (i, r) in d.rateOptions.indexed) ...[
              if (i > 0) const SizedBox(width: AppSpace.x2),
              Expanded(
                child: _RateTile(
                  rate: r,
                  caption: switch (r) {
                    0.25 => 'Progressif',
                    0.5 => 'Recommandé',
                    _ => 'Soutenu',
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
              ? 'Pour votre santé, Menoo ne propose jamais plus d\'1 kg de perte par semaine.'
              : 'Une prise lente favorise le muscle plutôt que la masse grasse.',
          style: AppText.meta,
        ),
      ],
      if (d.goal == HealthGoal.seche) ...[
        const SizedBox(height: AppSpace.x4),
        const InfoBanner(
          icon: AppIcons.dumbbell,
          title: 'Masse musculaire préservée',
          text: 'Déficit modéré de 0,5 kg par semaine et apport en protéines renforcé (2 g par kg) pour perdre du gras, pas du muscle.',
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
                '${OnboardingData.formatRate(rate)} kg',
                style: AppText.of(AppFont.s16, weight: AppFont.extrabold, color: fg, lineHeight: 22),
              ),
              Text('par semaine', style: AppText.of(AppFont.s11, color: AppColors.ink2)),
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
                  Text('${OnboardingData.formatKg(current)} kg', style: big(AppColors.ink)),
                  Text('aujourd\'hui', style: AppText.meta),
                ],
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(AppSpace.x3, 0, AppSpace.x3, AppSpace.x4),
                child: AppIcon(AppIcons.arrowRight, size: 22, color: AppColors.primary),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${OnboardingData.formatKg(target)} kg', style: big(AppColors.primaryDark)),
                  Text('visés', style: AppText.meta),
                ],
              ),
              const Spacer(),
              const TintBadge(icon: AppIcons.flag, size: AppSizes.iconTile, circle: true),
            ],
          ),
          const SizedBox(height: AppSpace.x2),
          Text(
            'Environ $weeks semaine${weeks > 1 ? 's' : ''} à ${OnboardingData.formatRate(rate)} kg/semaine',
            style: AppText.of(AppFont.s14, weight: AppFont.bold, lineHeight: 20),
          ),
          Text('Objectif estimé vers le ${OnboardingData.formatDate(date)}', style: AppText.caption),
        ],
      ),
    );
  }
}
