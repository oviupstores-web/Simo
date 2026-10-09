import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../navigation.dart';
import '../../onboarding/onboarding_data.dart';
import '../../onboarding/onboarding_flow.dart';
import '../../onboarding/onboarding_scope.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import 'constraints_screen.dart';

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
    final l = L.of(context);
    final d = OnboardingScope.of(context);
    return OnboardingStepScaffold(
      step: OnboardingFlow.number(context, OnbStep.members),
      totalSteps: OnboardingFlow.total(context),
      eyebrow: l.membersEyebrow,
      eyebrowIcon: AppIcons.people,
      title: l.membersTitle,
      subtitle: l.membersSubtitle,
      onContinue: () => OnboardingFlow.next(context, OnbStep.members),
      children: [
        for (final (i, m) in d.members.indexed) ...[
          if (i > 0) const SizedBox(height: AppSpace.x3),
          _MemberCard(
            member: m,
            name: d.displayName(m, l),
            onTap: () => push(context, MemberEditScreen(member: m.copy())),
          ),
        ],
        const SizedBox(height: AppSpace.x3),
        Pressable(
          onTap: () {
            final role = MemberRole.values.where((r) => d.count(r) < OnboardingData.maxPerRole[r]!).firstOrNull;
            if (role == null) {
              showMenooMessage(
                context,
                HouseholdLimitViolation(
                  MemberRole.adulte,
                  minimum: false,
                  limit: OnboardingData.maxPerRole[MemberRole.adulte]!,
                ).message(l),
              );
              return;
            }
            push(context, MemberEditScreen(member: d.newMember(role), isNew: true));
          },
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
                  l.membersAdd,
                  style: AppText.of(AppFont.s15, weight: AppFont.bold, color: AppColors.primary),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpace.x4),
        InfoBanner(icon: AppIcons.shield, title: l.membersAllergyInfoTitle, text: l.membersAllergyInfoText),
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
    final l = L.of(context);
    final m = member;
    final allergies = ConstraintsScreen.allergenLabels(l, m.allergens);
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
                  Text(l.membersRoleAndAge(m.role.label(l), m.ageLabel(l)), style: AppText.caption),
                  const SizedBox(height: AppSpace.x2),
                  Wrap(
                    spacing: AppSpace.x1_5,
                    runSpacing: AppSpace.x1,
                    children: [
                      if (allergies.isEmpty)
                        PillBadge(l.membersNoAllergy, icon: AppIcons.checkCircle)
                      else
                        for (final a in allergies)
                          PillBadge(
                            l.membersAllergyChip(a),
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
/// contraintes alimentaires et allergies, sans objectif physique.
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
    final error = OnboardingScope.read(context).validateMember(m.copy()..role = r);
    if (error != null) {
      setState(() => _error = error.message(L.of(context)));
      return;
    }
    final blank = MemberDraft.blank(m.id, r);
    setState(() {
      _error = null;
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
      error = L.of(context).memberNameError;
    } else if (age == null || age < r.minAge || age > r.maxAge) {
      error = r == MemberRole.bebe
          ? L.of(context).memberBabyAgeError
          : L.of(context).memberAgeRangeError(r.label(L.of(context)).toLowerCase(), r.minAge, r.maxAge);
    } else if (r != MemberRole.bebe && (height == null || height < hMin || height > hMax)) {
      error = L.of(context).memberHeightError(hMin, hMax);
    } else if (r != MemberRole.bebe && !OnboardingData.inRange(weight, wMin, wMax)) {
      error = L.of(context).memberWeightError(wMin, wMax);
    }
    setState(() => _error = error);
    if (error != null) return;
    m
      ..firstName = _name.text.trim()
      ..age = age!
      ..heightCm = r == MemberRole.bebe ? null : height
      ..weightKg = r == MemberRole.bebe ? null : weight;
    final limitError = d.saveMember(m);
    if (limitError != null) {
      setState(() => _error = limitError.message(L.of(context)));
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final d = OnboardingScope.of(context);
    final existing = d.members.any((x) => x.id == m.id);
    return OnboardingStepScaffold(
      eyebrow: widget.isNew ? l.memberEyebrowNew : l.memberEyebrowEdit,
      eyebrowIcon: _roleIcons[m.role],
      title: widget.isNew || _name.text.trim().isEmpty ? l.memberTitleNew : l.memberTitleEdit(_name.text.trim()),
      subtitle: l.memberSubtitle,
      continueLabel: l.memberSave,
      showArrow: false,
      onContinue: _save,
      below: existing && d.canRemove(m)
          ? Center(
              child: TextLink(
                l.memberRemove,
                weight: AppFont.bold,
                onTap: () {
                  final error = d.removeMember(m);
                  if (error != null) {
                    setState(() => _error = error.message(l));
                    return;
                  }
                  Navigator.of(context).pop();
                },
              ),
            )
          : null,
      children: [
        Text(l.memberFirstNameLabel, style: AppText.of(AppFont.s15, weight: AppFont.semibold, lineHeight: 22)),
        const SizedBox(height: AppSpace.x2_5),
        IconTextField(
          icon: AppIcons.user,
          hint: l.memberFirstNameHint,
          controller: _name,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppSpace.x5),
        Text(l.memberAgeGroupLabel, style: AppText.of(AppFont.s15, weight: AppFont.semibold, lineHeight: 22)),
        const SizedBox(height: AppSpace.x2_5),
        Row(
          children: [
            for (final (i, r) in MemberRole.values.indexed) ...[
              if (i > 0) const SizedBox(width: AppSpace.x2),
              Expanded(
                child: OptionTile(
                  vertical: true,
                  label: r.label(l),
                  icon: _roleIcons[r],
                  tint: MemberProfilesScreen.tintFor(r),
                  selected: m.role == r,
                  onTap: () => _setRole(r),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpace.x4),
        UnitFieldRow(label: l.memberAgeLabel, unit: l.profileAgeUnit, controller: _age),
        if (m.role != MemberRole.bebe) ...[
          const SizedBox(height: AppSpace.x4),
          UnitFieldRow(label: l.memberHeightLabel, unit: 'cm', controller: _height),
          const SizedBox(height: AppSpace.x4),
          UnitFieldRow(label: l.memberWeightLabel, unit: 'kg', controller: _weight),
        ],
        FormError(message: _error),
        const SizedBox(height: AppSpace.x6),
        StepSectionTitle(
          l.memberAllergySection,
          hint: l.constraintsAllergensHint,
          icon: AppIcons.shield,
          tint: Tint.peach,
          adaptiveHint: true,
        ),
        Wrap(
          spacing: AppSpace.x2,
          runSpacing: AppSpace.x2,
          children: [
            for (final a in ConstraintsScreen.allergenChoices(l))
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
