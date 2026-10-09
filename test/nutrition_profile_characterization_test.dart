import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menoo/l10n/app_localizations.dart';
import 'package:menoo/l10n/formats.dart';
import 'package:menoo/onboarding/onboarding_data.dart';
import 'package:menoo/onboarding/onboarding_scope.dart';
import 'package:menoo/screens/onboarding/profile_screen.dart';
import 'package:menoo/screens/onboarding/summary_screen.dart';
import 'package:menoo/theme/theme.dart';

/// Vérifie la robustesse et l'absence d'exclusion par IMC élevé.
/// Les noms de profils sont fictifs : ces tests ne valident pas une prescription,
/// ni la précision d'une estimation chez les athlètes ou les mineurs.
void main() {
  setUpAll(() async {
    final loader = FontLoader('PlusJakartaSans');
    for (final weight in [400, 500, 600, 700, 800]) {
      loader.addFont(
        Future.value(ByteData.sublistView(File('assets/fonts/PlusJakartaSans-$weight.ttf').readAsBytesSync())),
      );
    }
    await loader.load();
  });

  OnboardingData sample(int age, int height, double weight, ActivityLevel activity) => OnboardingData()
    ..goal = HealthGoal.maintien
    ..age = age
    ..heightCm = height
    ..weightKg = weight
    ..activity = activity;

  final profiles = <String, OnboardingData Function()>{
    'ordinaire': () => sample(32, 180, 75, ActivityLevel.modere),
    'forte corpulence': () => sample(45, 170, 190, ActivityLevel.sedentaire),
    'sportif très musclé fictif': () => sample(30, 185, 120, ActivityLevel.tresActif),
    'borne de saisie provisoire': () => sample(60, 200, 250, ActivityLevel.sedentaire),
  };

  for (final entry in profiles.entries) {
    test('${entry.key} : profil accepté, calculs finis et réponses conservées', () {
      final data = entry.value();
      addTearDown(data.dispose);
      final before = (data.age, data.heightCm, data.weightKg);
      final l = lookupL(const Locale('fr'));
      expect(
        OnboardingData.profileInputError(l, age: data.age, heightCm: data.heightCm, weightKg: data.weightKg),
        isNull,
      );
      expect(
        data.targetError(l, Formats(const Locale('fr')), target: null, current: data.weightKg, heightCm: data.heightCm),
        isNull,
      );
      expect(data.dailyKcal, greaterThan(0));
      final macros = data.macros;
      expect(macros, isNotNull);
      expect(macros!.protein, greaterThanOrEqualTo(0));
      expect(macros.carbs, greaterThanOrEqualTo(0));
      expect(macros.fat, greaterThanOrEqualTo(0));
      if (entry.key == 'forte corpulence') {
        expect(data.dailyKcal, 3290);
        expect(macros, (protein: 304, carbs: 314, fat: 91));
      }
      if (entry.key == 'sportif très musclé fictif') {
        expect(data.dailyKcal, 4090);
      }
      expect((data.age, data.heightCm, data.weightKg), before);
    });
  }

  test('IMC élevé : perte et prise de poids admises sans plafond d’IMC', () {
    final data = sample(30, 185, 120, ActivityLevel.tresActif);
    addTearDown(data.dispose);
    final l = lookupL(const Locale('fr'));
    final fmt = Formats(const Locale('fr'));
    expect(OnboardingData.bmi(data.weightKg, data.heightCm), greaterThan(30));
    data.goal = HealthGoal.pertePoids;
    expect(data.targetError(l, fmt, target: 110, current: 120, heightCm: 185), isNull);
    expect(data.targetDate(target: 110), isNotNull);
    data.goal = HealthGoal.priseMasse;
    expect(data.targetError(l, fmt, target: 125, current: 120, heightCm: 185), isNull);
    expect(data.targetDate(target: 125), isNotNull);
  });

  test('250 kg : borne produit exacte conservée, pas de nouveau seuil', () {
    final l = lookupL(const Locale('fr'));
    expect(OnboardingData.profileInputError(l, age: 30, heightCm: 200, weightKg: 250), isNull);
    expect(OnboardingData.profileInputError(l, age: 30, heightCm: 200, weightKg: 250.1), l.profileWeightError);
    expect(OnboardingData.maxTargetWeightKg, 250);
  });

  test('audit : plancher calorique et date ne suivent pas toujours le même rythme', () {
    final data = sample(40, 160, 60, ActivityLevel.sedentaire)
      ..sex = Sex.femme
      ..goal = HealthGoal.pertePoids
      ..weeklyRateKg = 0.75;
    addTearDown(data.dispose);
    // Constat produit : ni nouvelle formule ni prédiction clinique de perte réelle.
    expect(data.dailyKcal, 1240);
    expect(data.weeksToTarget(target: 50), 14);
    expect(data.weeklyRateKg, 0.75);
  });

  for (final age in [14, 15, 16, 17]) {
    test('audit $age ans : calculs adultes interdits', () {
      final data = sample(age, 180, 75, ActivityLevel.modere)..goal = HealthGoal.pertePoids;
      addTearDown(data.dispose);
      // Politique validée : aucun calcul physique Solo pour un mineur.
      expect(data.hasValidProfile, isFalse);
      expect(data.dailyKcal, isNull);
      expect(data.targetDate(target: 70), isNull);
    });
  }

  for (final language in ['fr', 'en', 'de']) {
    final locale = Locale(language);
    final l = lookupL(locale);
    for (final name in ['ordinaire', 'forte corpulence', 'sportif très musclé fictif']) {
      for (final width in [320.0, 390.0]) {
        testWidgets('$language $width $name : affichage estimé et saisie inchangés', (t) async {
          final data = profiles[name]!();
          addTearDown(data.dispose);
          t.view.physicalSize = Size(width, 1200);
          t.view.devicePixelRatio = 1;
          addTearDown(t.view.reset);

          Future<void> show(Widget screen) async {
            await t.pumpWidget(
              MaterialApp(
                key: UniqueKey(),
                theme: AppTheme.light,
                locale: locale,
                supportedLocales: L.supportedLocales,
                localizationsDelegates: L.localizationsDelegates,
                builder: (_, child) => OnboardingScope(data: data, child: child!),
                home: screen,
              ),
            );
            await t.pumpAndSettle();
            expect(t.takeException(), isNull);
          }

          final weight = data.weightKg;
          await show(const ProfileScreen());
          final weightField = t.widget<TextField>(find.byType(TextField).at(2));
          expect(double.parse(weightField.controller!.text.replaceAll(',', '.')), weight);
          await show(const SummaryScreen());
          expect(find.text(l.summaryEstimateMaintain), findsOneWidget);
          expect(find.text(l.numericCaloriesUnavailable), findsNothing);
          expect(data.weightKg, weight);
        });
      }
    }
  }
}
