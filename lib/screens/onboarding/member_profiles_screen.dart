import 'package:flutter/material.dart';

import '../../navigation.dart';
import '../../onboarding/onboarding_data.dart';
import '../../onboarding/onboarding_flow.dart';
import '../../onboarding/onboarding_scope.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import 'constraints_screen.dart';
import 'summary_screen.dart';

/// onboarding_memberprofiles (Foyer, étape 2/10) — un profil par membre.
/// SPEC §3 : les prénoms de démo (Thomas, Sarah, Lucas, Emma) remplacent « Chloé » et « Émilie ».
/// Photos de personnes non utilisées : pastille avec l'initiale (le foyer de l'utilisateur n'a pas de photo).
class MemberProfilesScreen extends StatelessWidget {
  const MemberProfilesScreen({super.key});

  static Tint tintFor(MemberRole r) => switch (r) {
    MemberRole.adulte => Tint.mint,
    MemberRole.enfant => Tint.peach,
    MemberRole.bebe => Tint.lavender,
  };

  @override
  Widget build(BuildContext context) {
    final d = OnboardingScope.of(context);
    return OnboardingStepScaffold(
      step: OnboardingFlow.number(context, OnbStep.members),
      totalSteps: OnboardingFlow.total(context),
      eyebrow: 'PROFILS DES MEMBRES',
      eyebrowIcon: AppIcons.people,
      title: 'Qui sont les membres de votre foyer ?',
      subtitle: 'Complétez chaque profil pour adapter les portions, les besoins et les allergies de chacun.',
      onContinue: () => OnboardingFlow.next(context, OnbStep.members),
      children: [
        for (final (i, m) in d.members.indexed) ...[
          if (i > 0) const SizedBox(height: AppSpace.x3),
          _MemberCard(
            member: m,
            name: d.displayName(m),
            onTap: () => push(context, MemberEditScreen(member: m.copy())),
          ),
        ],
        const SizedBox(height: AppSpace.x3),
        Pressable(
          onTap: () => push(context, MemberEditScreen(member: d.newMember(MemberRole.adulte), isNew: true)),
          child: Container(
            padding: const EdgeInsets.all(AppSpace.x3_5),
            decoration: BoxDecoration(
              borderRadius: AppRadius.cardR,
              border: Border.all(color: AppColors.primary, width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppIcon(AppIcons.plus, size: 18, color: AppColors.primary),
                const SizedBox(width: AppSpace.x2),
                Text(
                  'Ajouter un membre',
                  style: AppText.of(AppFont.s15, weight: AppFont.bold, color: AppColors.primary),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpace.x4),
        const InfoBanner(
          icon: AppIcons.shield,
          title: 'Allergies protégées',
          text: 'Une allergie déclarée pour un membre est exclue de tous les repas partagés du foyer.',
        ),
      ],
    );
  }
}

class _MemberCard extends StatelessWidget {
  const _MemberCard({required this.member, required this.name, required this.onTap});

  final MemberDraft member;
  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final m = member;
    final allergies = ConstraintsScreen.allergenLabels(m.allergens);
    return Pressable(
      onTap: onTap,
      child: AppCard(
        padding: const EdgeInsets.all(AppSpace.x3_5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MemberAvatar(name: name, tint: MemberProfilesScreen.tintFor(m.role)),
            const SizedBox(width: AppSpace.x3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppText.of(AppFont.s16, weight: AppFont.extrabold, lineHeight: 22)),
                  Text('${m.role.label}, ${m.ageLabel}', style: AppText.caption),
                  const SizedBox(height: AppSpace.x2),
                  Wrap(
                    spacing: AppSpace.x1_5,
                    runSpacing: AppSpace.x1,
                    children: [
                      if (m.role == MemberRole.adulte)
                        PillBadge(
                          SummaryScreen.goals[m.goal]!.$1,
                          icon: SummaryScreen.goals[m.goal]!.$2,
                          background: AppColors.neutralSoft,
                          foreground: AppColors.ink2,
                        ),
                      if (allergies.isEmpty)
                        const PillBadge('Aucune allergie', icon: AppIcons.checkCircle)
                      else
                        for (final a in allergies)
                          PillBadge(
                            'Allergie : $a',
                            icon: AppIcons.shield,
                            background: Tint.peach.soft,
                            foreground: Tint.peach.ink,
                          ),
                    ],
                  ),
                ],
              ),
            ),
            const AppIcon(AppIcons.edit, size: 18, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

/// Pastille ronde avec l'initiale du membre.
class MemberAvatar extends StatelessWidget {
  const MemberAvatar({super.key, required this.name, required this.tint, this.size = AppSizes.memberAvatar});

  final String name;
  final Tint tint;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: tint.soft, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        name.isEmpty ? '?' : name.characters.first.toUpperCase(),
        style: AppText.of(
          size >= AppSizes.memberAvatar ? AppFont.s18 : AppFont.s14,
          weight: AppFont.extrabold,
          color: tint.ink,
        ),
      ),
    );
  }
}

/// Fiche d'un membre (hors compteur d'étapes) : prénom, rôle, âge, mensurations,
/// objectif et activité (adultes), allergies.
class MemberEditScreen extends StatefulWidget {
  const MemberEditScreen({super.key, required this.member, this.isNew = false});

  final MemberDraft member;
  final bool isNew;

  @override
  State<MemberEditScreen> createState() => _MemberEditScreenState();
}

class _MemberEditScreenState extends State<MemberEditScreen> {
  late final MemberDraft m = widget.member;
  late final _name = TextEditingController(text: m.firstName);
  late final _age = TextEditingController(text: '${m.age}');
  late final _height = TextEditingController(text: m.heightCm?.toString() ?? '');
  late final _weight = TextEditingController(text: m.weightKg == null ? '' : OnboardingData.formatKg(m.weightKg!));
  String? _error;

  static const _roleIcons = {
    MemberRole.adulte: AppIcons.user,
    MemberRole.enfant: AppIcons.child,
    MemberRole.bebe: AppIcons.baby,
  };

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _height.dispose();
    _weight.dispose();
    super.dispose();
  }

  void _setRole(MemberRole r) {
    if (r == m.role) return;
    final blank = MemberDraft.blank(m.id, r);
    setState(() {
      m.role = r;
      m.age = blank.age;
      m.heightCm = blank.heightCm;
      m.weightKg = blank.weightKg;
      m.activity = blank.activity;
      if (r != MemberRole.adulte) m.goal = HealthGoal.maintien;
      _age.text = '${m.age}';
      _height.text = m.heightCm?.toString() ?? '';
      _weight.text = m.weightKg == null ? '' : OnboardingData.formatKg(m.weightKg!);
    });
  }

  void _save() {
    final d = OnboardingScope.read(context);
    final age = int.tryParse(_age.text.trim());
    final height = int.tryParse(_height.text.trim());
    final weight = double.tryParse(_weight.text.trim().replaceAll(',', '.'));
    final r = m.role;
    final (hMin, hMax, wMin, wMax) = r == MemberRole.adulte ? (120, 230, 35, 250) : (80, 190, 12, 100);
    String? error;
    if (_name.text.trim().isEmpty) {
      error = 'Indiquez un prénom.';
    } else if (age == null || age < r.minAge || age > r.maxAge) {
      error = r == MemberRole.bebe
          ? 'Un bébé a de 0 à 3 ans (0 = moins d\'un an).'
          : 'Pour un ${r.label.toLowerCase()}, indiquez un âge entre ${r.minAge} et ${r.maxAge} ans.';
    } else if (r != MemberRole.bebe && (height == null || height < hMin || height > hMax)) {
      error = 'Indiquez une taille entre $hMin et $hMax cm.';
    } else if (r != MemberRole.bebe && (weight == null || weight < wMin || weight > wMax)) {
      error = 'Indiquez un poids entre $wMin et $wMax kg.';
    }
    setState(() => _error = error);
    if (error != null) return;
    m
      ..firstName = _name.text.trim()
      ..age = age!
      ..heightCm = r == MemberRole.bebe ? null : height
      ..weightKg = r == MemberRole.bebe ? null : weight;
    d.saveMember(m);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final d = OnboardingScope.of(context);
    final existing = d.members.any((x) => x.id == m.id);
    final adult = m.role == MemberRole.adulte;
    return OnboardingStepScaffold(
      eyebrow: widget.isNew ? 'NOUVEAU MEMBRE' : 'PROFIL',
      eyebrowIcon: _roleIcons[m.role],
      title: widget.isNew || _name.text.trim().isEmpty ? 'Ajouter un membre' : 'Profil de ${_name.text.trim()}',
      subtitle: 'Ces informations servent à calculer ses portions et à protéger ses allergies.',
      continueLabel: 'Enregistrer',
      showArrow: false,
      onContinue: _save,
      below: existing && d.canRemove(m)
          ? Center(
              child: TextLink(
                'Retirer ce membre du foyer',
                weight: AppFont.bold,
                onTap: () {
                  d.removeMember(m);
                  Navigator.of(context).pop();
                },
              ),
            )
          : null,
      children: [
        Text('Prénom', style: AppText.of(AppFont.s15, weight: AppFont.semibold, lineHeight: 22)),
        const SizedBox(height: AppSpace.x2_5),
        IconTextField(icon: AppIcons.user, hint: 'Ex. : Léa', controller: _name, onChanged: (_) => setState(() {})),
        const SizedBox(height: AppSpace.x5),
        Text('Tranche d\'âge', style: AppText.of(AppFont.s15, weight: AppFont.semibold, lineHeight: 22)),
        const SizedBox(height: AppSpace.x2_5),
        Row(
          children: [
            for (final (i, r) in MemberRole.values.indexed) ...[
              if (i > 0) const SizedBox(width: AppSpace.x2),
              Expanded(
                child: OptionTile(
                  vertical: true,
                  label: r.label,
                  icon: _roleIcons[r],
                  tint: MemberProfilesScreen.tintFor(r),
                  selected: m.role == r,
                  // Toujours au moins un adulte dans le foyer
                  onTap: r != MemberRole.adulte && adult && existing && !d.canRemove(m) ? null : () => _setRole(r),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpace.x4),
        Row(
          children: [
            Expanded(
              child: SegmentButton(
                label: 'Garçon / homme',
                icon: AppIcons.male,
                selected: m.sex == Sex.homme,
                onTap: () => setState(() => m.sex = Sex.homme),
              ),
            ),
            const SizedBox(width: AppSpace.x3),
            Expanded(
              child: SegmentButton(
                label: 'Fille / femme',
                icon: AppIcons.female,
                selected: m.sex == Sex.femme,
                onTap: () => setState(() => m.sex = Sex.femme),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpace.x4),
        UnitFieldRow(label: 'Âge', unit: 'ans', controller: _age),
        if (m.role != MemberRole.bebe) ...[
          const SizedBox(height: AppSpace.x4),
          UnitFieldRow(label: 'Taille', unit: 'cm', controller: _height),
          const SizedBox(height: AppSpace.x4),
          UnitFieldRow(label: 'Poids', unit: 'kg', controller: _weight),
        ],
        FormError(message: _error),
        if (adult) ...[
          const SizedBox(height: AppSpace.x6),
          const StepSectionTitle('Objectif', hint: 'Un seul choix', icon: AppIcons.target),
          Wrap(
            spacing: AppSpace.x2,
            runSpacing: AppSpace.x2,
            children: [
              for (final g in HealthGoal.values)
                ToggleChip(
                  label: SummaryScreen.goals[g]!.$1,
                  icon: SummaryScreen.goals[g]!.$2,
                  selected: m.goal == g,
                  onTap: () => setState(() => m.goal = g),
                ),
            ],
          ),
          const SizedBox(height: AppSpace.x5),
          const StepSectionTitle('Activité physique', icon: AppIcons.walk, tint: Tint.sky),
          Wrap(
            spacing: AppSpace.x2,
            runSpacing: AppSpace.x2,
            children: [
              for (final a in ActivityLevel.values)
                ToggleChip(
                  label: SummaryScreen.activities[a]!,
                  selected: m.activity == a,
                  onTap: () => setState(() => m.activity = a),
                ),
            ],
          ),
        ],
        const SizedBox(height: AppSpace.x6),
        const StepSectionTitle('Allergies', hint: 'Exclusion stricte', icon: AppIcons.shield, tint: Tint.peach),
        Wrap(
          spacing: AppSpace.x2,
          runSpacing: AppSpace.x2,
          children: [
            for (final a in ConstraintsScreen.allergenChoices)
              ToggleChip(
                label: a.$2,
                icon: a.$3,
                tint: a.$4,
                selected: m.allergens.containsAll(a.$1),
                onTap: () => setState(
                  () => m.allergens.containsAll(a.$1) ? m.allergens.removeAll(a.$1) : m.allergens.addAll(a.$1),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
