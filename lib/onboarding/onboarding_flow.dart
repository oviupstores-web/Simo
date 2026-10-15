import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../l10n/formats.dart';
import '../screens/onboarding/activity_screen.dart';
import '../screens/onboarding/budget_screen.dart';
import '../screens/onboarding/constraints_screen.dart';
import '../screens/onboarding/onboarding_cuisines_screen.dart';
import '../screens/onboarding/goal_screen.dart';
import '../screens/onboarding/household_size_screen.dart';
import '../screens/onboarding/kitchen_screen.dart';
import '../screens/onboarding/management_mode_screen.dart';
import '../screens/onboarding/member_profiles_screen.dart';
import '../screens/onboarding/profile_screen.dart';
import '../screens/onboarding/smart_scale_screen.dart';
import '../screens/onboarding/summary_screen.dart';
import '../screens/onboarding/weekly_grid_screen.dart';
import '../screens/pantry/pantry_hub_onboarding_screen.dart';
import 'onboarding_data.dart';
import 'onboarding_scope.dart';
import 'solo_draft_navigation.dart';
import 'family_draft_navigation.dart';

/// Toutes les étapes possibles de l'onboarding (Solo et Foyer partagent la plupart des écrans).
enum OnbStep {
  goal,
  profile,
  activity,
  scale,
  household,
  members,
  grid,
  budget,
  management,
  constraints,
  cuisines,
  kitchen,
  summary,
}

/// Enchaînement des parcours (et retour au récapitulatif après « Éditer »).
abstract final class OnboardingFlow {
  /// Solo, 11 étapes : ordre SPEC §2 + « Types de cuisine » après les contraintes (Simo, 2026-09-24).
  /// Plus d'étape Enseigne (Menoo internationale, décision du 2026-09-30).
  static const solo = [
    OnbStep.goal,
    OnbStep.profile,
    OnbStep.activity,
    OnbStep.scale,
    OnbStep.grid,
    OnbStep.budget,
    OnbStep.management,
    OnbStep.constraints,
    OnbStep.cuisines,
    OnbStep.kitchen,
    OnbStep.summary,
  ];

  /// Foyer, 9 étapes : ordre modifié de SPEC §3 (contraintes avant le mode de gestion).
  /// Plus d'étape Enseigne (Menoo internationale, décision du 2026-09-30).
  static const foyer = [
    OnbStep.household,
    OnbStep.members,
    OnbStep.grid,
    OnbStep.budget,
    OnbStep.constraints,
    OnbStep.management,
    OnbStep.cuisines,
    OnbStep.kitchen,
    OnbStep.summary,
  ];

  static List<OnbStep> steps(BuildContext context) => OnboardingScope.read(context).isFoyer ? foyer : solo;

  static int number(BuildContext context, OnbStep step) => steps(context).indexOf(step) + 1;

  static int total(BuildContext context) => steps(context).length;

  static Widget screenFor(OnbStep step) => switch (step) {
    OnbStep.goal => const GoalScreen(),
    OnbStep.profile => const ProfileScreen(),
    OnbStep.activity => const ActivityScreen(),
    OnbStep.scale => const SmartScaleScreen(),
    OnbStep.household => const HouseholdSizeScreen(),
    OnbStep.members => const MemberProfilesScreen(),
    OnbStep.grid => const WeeklyGridScreen(),
    OnbStep.budget => const BudgetScreen(),
    OnbStep.management => const ManagementModeScreen(),
    OnbStep.constraints => const ConstraintsScreen(),
    OnbStep.cuisines => const OnboardingCuisinesScreen(),
    OnbStep.kitchen => const KitchenScreen(),
    OnbStep.summary => const SummaryScreen(),
  };

  static Route<void> _route(Widget screen, {bool fromSummary = false, bool family = false}) => MaterialPageRoute(
    settings: RouteSettings(
      arguments: fromSummary,
      name: screen is PantryHubOnboardingScreen
          ? pantryDetourRoute
          : _stepFor(screen) == null
          ? null
          : '${family ? familyRoutePrefix : soloRoutePrefix}${_stepFor(screen)!.name}',
    ),
    builder: (_) => screen,
  );

  static OnbStep? _stepFor(Widget screen) => switch (screen) {
    GoalScreen() => OnbStep.goal,
    ProfileScreen() => OnbStep.profile,
    ActivityScreen() => OnbStep.activity,
    SmartScaleScreen() => OnbStep.scale,
    WeeklyGridScreen() => OnbStep.grid,
    BudgetScreen() => OnbStep.budget,
    ManagementModeScreen() => OnbStep.management,
    ConstraintsScreen() => OnbStep.constraints,
    OnboardingCuisinesScreen() => OnbStep.cuisines,
    KitchenScreen() => OnbStep.kitchen,
    SummaryScreen() => OnbStep.summary,
    HouseholdSizeScreen() => OnbStep.household,
    MemberProfilesScreen() => OnbStep.members,
    _ => null,
  };

  /// Ouvre une étape (depuis le récapitulatif : le « Continuer » y ramènera).
  static Future<void> open(BuildContext context, OnbStep step, {bool fromSummary = false}) {
    final d = OnboardingScope.read(context);
    if (d.isFoyer && !foyer.contains(step)) step = OnbStep.household;
    if (!d.isFoyer && step != OnbStep.profile && !d.isEligibleForIndividual) step = OnbStep.profile;
    return Navigator.of(context).push(_route(screenFor(step), fromSummary: fromSummary, family: d.isFoyer));
  }

  static Future<void> openMember(BuildContext context, MemberDraft member, {bool isNew = false}) {
    if (OnboardingScope.family(context) != null) {
      final d = OnboardingScope.read(context);
      if (!d.familyMemberEdits.containsKey(member.id)) {
        d.saveFamilyMemberEdit(member, {
          'name': member.firstName,
          'age': '${member.age}',
          'height': member.heightCm?.toString() ?? '',
          'weight': member.weightKg == null ? '' : OnboardingData.formatKg(member.weightKg!),
        }, isNew: isNew);
      }
    }
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        settings: RouteSettings(name: familyMemberRoute, arguments: {'memberId': member.id, 'isNew': isNew}),
        builder: (_) => MemberEditScreen(member: member, isNew: isNew),
      ),
    );
  }

  /// Première étape du parcours choisi.
  static Future<void> start(BuildContext context) async {
    final family = OnboardingScope.family(context);
    if (OnboardingScope.read(context).isFoyer && family != null) {
      if (!await family.enter()) {
        if (context.mounted) {
          final l = L.of(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.soloDraftLoadError)));
        }
        return;
      }
      if (!context.mounted) return;
      if (family.routeStack.isNotEmpty) {
        final observer = Navigator.of(context).widget.observers.whereType<FamilyDraftRouteObserver>().firstOrNull;
        if (observer != null) {
          resumeFamilyRoutes(context, family, observer, includeEntry: false);
          return;
        }
      }
    }
    final session = OnboardingScope.solo(context);
    if (!OnboardingScope.read(context).isFoyer && session != null) {
      if (!await session.enter()) {
        if (context.mounted) {
          final l = L.of(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.soloDraftLoadError)));
        }
        return;
      }
      if (!context.mounted) return;
      if (session.routeStack.isNotEmpty) {
        final observer = Navigator.of(context).widget.observers.whereType<SoloDraftRouteObserver>().firstOrNull;
        if (observer != null) {
          resumeSoloRoutes(context, session, observer, includeEntry: false);
          return;
        }
      }
    }
    if (context.mounted) await open(context, steps(context).first);
  }

  /// Vrai si l'écran a été ouvert depuis « Éditer » du récapitulatif.
  static bool isEditing(BuildContext context) => ModalRoute.of(context)?.settings.arguments == true;

  /// Étape suivante. SPEC §4 : après le mode de gestion, détour Réserve si
  /// « Réserves uniquement » ou « Mixte », puis retour à l'étape qui suit le mode de gestion
  /// (Solo : contraintes ; Foyer : types de cuisine).
  static void next(BuildContext context, OnbStep step) {
    final d = OnboardingScope.read(context);
    if (d.isFoyer && !foyer.contains(step)) {
      open(context, OnbStep.household);
      return;
    }
    if (!d.isFoyer && !d.isEligibleForIndividual) {
      open(context, OnbStep.profile);
      return;
    }
    final editing = isEditing(context);
    if (!d.isFoyer) OnboardingScope.solo(context)?.markCompleted(step.name);
    if (d.isFoyer) OnboardingScope.family(context)?.markCompleted(step.name);
    final nav = Navigator.of(context);
    final order = steps(context);
    if (step == OnbStep.management && OnboardingScope.read(context).management != ManagementMode.courses) {
      final after = order[order.indexOf(OnbStep.management) + 1];
      nav.push(
        _route(
          PantryHubOnboardingScreen(onFinish: (hub) => finishPantryDetour(hub, editing, after)),
          fromSummary: editing,
          family: d.isFoyer,
        ),
      );
      return;
    }
    if (editing && step == OnbStep.goal) {
      final d = OnboardingScope.read(context);
      if (!d.needsTarget) {
        d.update(() => d.targetWeightKg = null);
      } else if (d.targetError(
            L.of(context),
            Formats.of(context),
            target: d.targetWeightKg,
            current: d.weightKg,
            heightCm: d.heightCm,
          ) !=
          null) {
        nav.pushReplacement(_route(screenFor(OnbStep.profile), fromSummary: true));
        return;
      }
    }
    if (editing) {
      nav.pop();
      return;
    }
    open(context, order[order.indexOf(step) + 1]);
  }

  /// Fin du détour Réserve (« Terminer et continuer » ou « Passer pour l'instant »).
  static void finishPantryDetour(BuildContext hubContext, bool fromSummary, OnbStep after) {
    final nav = Navigator.of(hubContext);
    if (fromSummary) {
      nav.pop();
      nav.pop();
    } else {
      nav.pushReplacement(_route(screenFor(after), family: OnboardingScope.read(hubContext).isFoyer));
    }
  }
}
