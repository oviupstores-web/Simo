import 'package:flutter/widgets.dart';

import 'onboarding_data.dart';

/// Rend les réponses de l'onboarding accessibles à tous les écrans du parcours.
class OnboardingScope extends InheritedNotifier<OnboardingData> {
  const OnboardingScope({super.key, required OnboardingData data, required super.child}) : super(notifier: data);

  /// Lit les réponses et reconstruit l'écran quand elles changent.
  static OnboardingData of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<OnboardingScope>()!.notifier!;

  /// Lit les réponses sans s'abonner (pour les actions).
  static OnboardingData read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<OnboardingScope>()!.notifier!;
}
