import 'package:flutter/widgets.dart';

import 'onboarding_data.dart';
import 'solo_draft_session.dart';
import 'family_draft_session.dart';

/// Rend les réponses de l'onboarding accessibles à tous les écrans du parcours.
class OnboardingScope extends InheritedNotifier<OnboardingData> {
  const OnboardingScope({
    super.key,
    required OnboardingData data,
    required super.child,
    this.soloDraft,
    this.familyDraft,
  }) : super(notifier: data);
  final SoloDraftSession? soloDraft;
  final FamilyDraftSession? familyDraft;
  static FamilyDraftSession? family(BuildContext context) =>
      context.getInheritedWidgetOfExactType<OnboardingScope>()?.familyDraft;
  static SoloDraftSession? solo(BuildContext context) =>
      context.getInheritedWidgetOfExactType<OnboardingScope>()?.soloDraft;

  /// Lit les réponses et reconstruit l'écran quand elles changent.
  static OnboardingData of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<OnboardingScope>()!.notifier!;

  /// Lit les réponses sans s'abonner (pour les actions).
  static OnboardingData read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<OnboardingScope>()!.notifier!;
}
