import 'package:flutter/material.dart';

import '../screens/onboarding/activity_screen.dart';
import '../screens/onboarding/budget_screen.dart';
import '../screens/onboarding/constraints_screen.dart';
import '../screens/onboarding/cuisine_types_screen.dart';
import '../screens/onboarding/goal_screen.dart';
import '../screens/onboarding/household_size_screen.dart';
import '../screens/onboarding/kitchen_screen.dart';
import '../screens/onboarding/management_mode_screen.dart';
import '../screens/onboarding/member_profiles_screen.dart';
import '../screens/onboarding/profile_screen.dart';
import '../screens/onboarding/smart_scale_screen.dart';
import '../screens/onboarding/summary_screen.dart';
import '../screens/onboarding/supermarket_screen.dart';
import '../screens/onboarding/weekly_grid_screen.dart';
import '../screens/pantry/pantry_onboarding_hub_screen.dart';
import 'onboarding_data.dart';
import 'onboarding_scope.dart';

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
  supermarket,
  summary,
}

/// Enchaînement des parcours (et retour au récapitulatif après « Éditer »).
abstract final class OnboardingFlow {
  /// Solo, 12 étapes : ordre SPEC §2 + « Types de cuisine » après les contraintes (Simo, 2026-09-24).
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
    OnbStep.supermarket,
    OnbStep.summary,
  ];

  /// Foyer, 10 étapes : ordre modifié de SPEC §3 (contraintes avant le mode de gestion).
  static const foyer = [
    OnbStep.household,
    OnbStep.members,
    OnbStep.grid,
    OnbStep.budget,
    OnbStep.constraints,
    OnbStep.management,
    OnbStep.cuisines,
    OnbStep.kitchen,
    OnbStep.supermarket,
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
    OnbStep.cuisines => const CuisineTypesScreen(),
    OnbStep.kitchen => const KitchenScreen(),
    OnbStep.supermarket => const SupermarketScreen(),
    OnbStep.summary => const SummaryScreen(),
  };

  static Route<void> _route(Widget screen, {bool fromSummary = false}) => MaterialPageRoute(
    settings: RouteSettings(arguments: fromSummary),
    builder: (_) => screen,
  );

  /// Ouvre une étape (depuis le récapitulatif : le « Continuer » y ramènera).
  static Future<void> open(BuildContext context, OnbStep step, {bool fromSummary = false}) =>
      Navigator.of(context).push(_route(screenFor(step), fromSummary: fromSummary));

  /// Première étape du parcours choisi.
  static Future<void> start(BuildContext context) => open(context, steps(context).first);

  /// Vrai si l'écran a été ouvert depuis « Éditer » du récapitulatif.
  static bool isEditing(BuildContext context) => ModalRoute.of(context)?.settings.arguments == true;

  /// Étape suivante. SPEC §4 : après le mode de gestion, détour Réserve si
  /// « Réserves uniquement » ou « Mixte », puis retour à l'étape qui suit le mode de gestion
  /// (Solo : contraintes ; Foyer : types de cuisine).
  static void next(BuildContext context, OnbStep step) {
    final editing = isEditing(context);
    final nav = Navigator.of(context);
    final order = steps(context);
    if (step == OnbStep.management && OnboardingScope.read(context).management != ManagementMode.courses) {
      final after = order[order.indexOf(OnbStep.management) + 1];
      nav.push(
        _route(
          PantryOnboardingHubScreen(onFinish: (hub) => finishPantryDetour(hub, editing, after)),
          fromSummary: editing,
        ),
      );
      return;
    }
    if (editing && step == OnbStep.goal) {
      // Nouvel objectif depuis le récapitulatif : le poids visé doit rester cohérent.
      final d = OnboardingScope.read(context);
      if (!d.needsTarget) {
        d.update(() => d.targetWeightKg = null);
      } else if (d.targetError(target: d.targetWeightKg, current: d.weightKg, heightCm: d.heightCm) != null) {
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
      // Ferme le hub et l'écran du mode de gestion : retour au récapitulatif.
      nav.pop();
      nav.pop();
    } else {
      nav.pushReplacement(_route(screenFor(after)));
    }
  }
}
