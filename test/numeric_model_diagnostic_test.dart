import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menoo/l10n/app_localizations.dart';
import 'package:menoo/l10n/formats.dart';
import 'package:menoo/onboarding/onboarding_data.dart';

/// Régressions R01 : les entrées invalides sont signalées sans résultat inventé.
void main() {
  final l = lookupL(const Locale('fr'));
  final fmt = Formats(const Locale('fr', 'FR'));
  late OnboardingData data;
  setUp(() => data = OnboardingData());
  tearDown(() => data.dispose());

  test('valeurs de référence : calories, macros, projection et IMC inchangés', () {
    expect(data.dailyKcal, 1940);
    expect(data.macros, (protein: 135, carbs: 229, fat: 54));
    expect(data.weeksToTarget(target: 70), 10);
    expect(OnboardingData.bmi(75, 180), closeTo(23.148148, 0.000001));
    expect(OnboardingData.minHealthyWeight(180), 60);
  });

  test('cible absente, nulle, négative et sous IMC minimum rejetées', () {
    for (final target in <double?>[null, 0, -1, 59.9]) {
      expect(data.targetError(l, fmt, target: target, current: 75, heightCm: 180), isNotNull);
    }
    expect(data.targetError(l, fmt, target: 60, current: 75, heightCm: 180), isNull);
    expect(data.weeksToTarget(), isNull);
    expect(data.targetDate(), isNull);
  });

  test('maintien : pas de projection, même avec cible absente', () {
    data.goal = HealthGoal.maintien;
    expect(data.weeksToTarget(), isNull);
    expect(data.targetDate(), isNull);
    for (final invalid in [double.nan, double.infinity, 10000.0]) {
      expect(data.targetError(l, fmt, target: invalid, current: 75, heightCm: 180), isNotNull);
    }
  });

  for (final target in [double.nan, double.infinity]) {
    test('R01 cible non finie $target : validation doit refuser', () {
      data.goal = HealthGoal.priseMasse;
      expect(data.targetError(l, fmt, target: target, current: 75, heightCm: 180), isNotNull);
    });
    test('R01 cible non finie $target : projection ne doit pas crasher', () {
      data.goal = HealthGoal.priseMasse;
      expect(() => data.weeksToTarget(target: target), returnsNormally);
    });
  }

  for (final current in [double.nan, 0.0, -1.0]) {
    test('R01 poids actuel invalide $current : validation doit refuser', () {
      data.goal = HealthGoal.priseMasse;
      expect(data.targetError(l, fmt, target: 80, current: current, heightCm: 180), isNotNull);
    });
  }

  for (final height in [0, -180, 1000000000000]) {
    test('R01 taille invalide $height : validation doit refuser', () {
      data.goal = HealthGoal.priseMasse;
      expect(data.targetError(l, fmt, target: 80, current: 75, heightCm: height), isNotNull);
    });
  }

  test('R01 IMC : taille nulle ne doit pas produire une valeur infinie', () {
    expect(OnboardingData.bmi(75, 0), isNull);
  });

  for (final weight in [double.nan, double.infinity, double.negativeInfinity, 1e307]) {
    test('R01 calories : poids $weight ne doit pas provoquer une exception', () {
      data.weightKg = weight;
      expect(() => data.dailyKcal, returnsNormally);
      expect(data.dailyKcal, isNull);
    });
  }

  test('R01 date : cible 1000000000000 kg refusée avant toute durée', () {
    data.goal = HealthGoal.priseMasse;
    expect(data.weeksToTarget(target: 1e12), isNull);
    expect(data.targetDate(target: 1e12), isNull);
  });

  test('R01 cible de 10000 kg : plafond provisoire et absence de projection', () {
    data.goal = HealthGoal.priseMasse;
    expect(
      data.targetError(l, fmt, target: 10000, current: 75, heightCm: 180),
      l.targetErrorMaximum(fmt.weight(l, 250)),
    );
    expect(data.weeksToTarget(target: 10000), isNull);
    expect(data.targetDate(target: 10000), isNull);
  });

  test('R01 macros : aucun glucide négatif dans les limites actuelles des champs', () {
    data
      ..sex = Sex.femme
      ..age = 100
      ..heightCm = 120
      ..weightKg = 250
      ..goal = HealthGoal.seche
      ..activity = ActivityLevel.sedentaire;
    expect(data.dailyKcal, 2590);
    expect(data.macros, isNull);
    expect(data.dailyKcal, 2590, reason: 'les calories valides restent disponibles');
  });

  test('rythmes injectés invalides : refus sans remplacement silencieux', () {
    for (final rate in [double.nan, double.infinity, 0.0, -1.0, 0.1, 1.0, 100.0]) {
      data.weeklyRateKg = rate;
      expect(data.effectiveRate, isNull);
      expect(data.weeksToTarget(target: 70), isNull);
      expect(data.dailyKcal, isNull);
      if (rate.isNaN) {
        expect(data.weeklyRateKg.isNaN, isTrue);
      } else {
        expect(data.weeklyRateKg, rate);
      }
    }
  });

  test('conversions usuelles : kg/lb et cm/pieds-pouces', () {
    final us = Formats(const Locale('en', 'US'));
    expect(us.weight(l, 75), l.unitPounds('165.3'));
    expect(us.height(l, 180), l.unitFeetInches(5, 11));
    expect(fmt.weight(l, 75), l.unitKilograms('75'));
  });

  test('B09 déjà identifié : 182 cm doivent donner 6 pieds et 0 pouce', () {
    expect(Formats(const Locale('en', 'US')).height(l, 182), l.unitFeetInches(6, 0));
  });

  test('R01 conversion impériale : taille infinie ne doit pas crasher', () {
    expect(() => Formats(const Locale('en', 'US')).height(l, double.infinity), returnsNormally);
  });

  test('bornes existantes : calculs et projections finis', () {
    for (final height in [120, 230]) {
      for (final age in [18, 100]) {
        for (final weight in [35.0, 250.0]) {
          data
            ..heightCm = height
            ..age = age
            ..weightKg = weight;
          expect(data.dailyKcal, greaterThan(0));
          expect(OnboardingData.bmi(weight, height)!.isFinite, isTrue);
        }
      }
    }
    data.goal = HealthGoal.priseMasse;
    data.weightKg = 35;
    data.weeklyRateKg = 0.25;
    expect(data.weeksToTarget(target: 250), 860);
    expect(() => data.targetDate(target: 250), returnsNormally);
  });

  test('observation des grandes valeurs et des limites du modèle', () {
    data.weightKg = 1e307;
    expect(data.dailyKcal, isNull);
    data.weightKg = double.negativeInfinity;
    expect(data.dailyKcal, isNull);
    data
      ..weightKg = 75
      ..goal = HealthGoal.priseMasse;
    for (final height in [0, -180]) {
      expect(data.targetError(l, fmt, target: 80, current: 75, heightCm: height), isNotNull);
    }
  });

  test('R01 poids extrême fini : aucun total calorique négatif par dépassement entier', () {
    data.weightKg = 1e307;
    expect(data.dailyKcal, isNull);
  });

  test('cible minuscule : sous-débordement refusé sans exception', () {
    expect(data.targetError(l, fmt, target: double.minPositive, current: 75, heightCm: 180), isNotNull);
    expect(data.weeksToTarget(target: double.minPositive), isNull);
  });

  test('calculs aux bornes : calories disponibles et aucune macro incohérente exposée', () {
    for (final sex in Sex.values) {
      for (final age in [18, 100]) {
        for (final height in [120, 230]) {
          for (final weight in [35.0, 250.0]) {
            for (final goal in HealthGoal.values) {
              for (final activity in ActivityLevel.values) {
                data
                  ..sex = sex
                  ..age = age
                  ..heightCm = height
                  ..weightKg = weight
                  ..goal = goal
                  ..activity = activity
                  ..weeklyRateKg = 0.5;
                final calories = data.dailyKcal;
                expect(calories, isNotNull);
                expect(calories, greaterThan(0));
                final macros = data.macros;
                if (macros != null) {
                  expect(macros.protein, greaterThanOrEqualTo(0));
                  expect(macros.carbs, greaterThanOrEqualTo(0));
                  expect(macros.fat, greaterThanOrEqualTo(0));
                  expect(
                    (macros.protein * 4 + macros.carbs * 4 + macros.fat * 9 - calories!).abs(),
                    lessThanOrEqualTo(2),
                  );
                }
              }
            }
          }
        }
      }
    }
  });

  for (final role in MemberRole.values) {
    test('Famille ${role.name} : valeur non finie refusée dans le modèle, données conservées', () {
      data.startMode(AppMode.foyer);
      if (role == MemberRole.bebe) data.setCount(role, 1);
      final original = data.members.firstWhere((m) => m.role == role);
      final before = [...data.members];
      var notifications = 0;
      data.addListener(() => notifications++);
      final invalid = original.copy()..weightKg = double.nan;
      expect(data.saveMember(invalid), isNotNull);
      expect(data.members, orderedEquals(before));
      expect(notifications, 0);
      expect(original.weightKg?.isNaN, isNot(true));
    });
  }

  test('Famille : bornes enfants et mensurations absentes du bébé conservées', () {
    data.startMode(AppMode.foyer);
    final child = data.members.firstWhere((m) => m.role == MemberRole.enfant).copy()
      ..age = 4
      ..heightCm = 80
      ..weightKg = 12;
    expect(data.saveMember(child), isNull);
    final baby = data.newMember(MemberRole.bebe)..age = 0;
    expect(data.saveMember(baby), isNull);
    expect(baby.weightKg, isNull);
    expect(baby.heightCm, isNull);
  });

  test('conversions : valeurs non finies et dépassements signalés', () {
    final us = Formats(const Locale('en', 'US'));
    for (final value in [double.nan, double.infinity, double.negativeInfinity, 1e307]) {
      expect(us.height(l, value), l.numericValueUnavailable);
      expect(us.weight(l, value), l.numericValueUnavailable);
      expect(us.rate(l, value), l.numericValueUnavailable);
      expect(fmt.height(l, value), l.numericValueUnavailable);
    }
  });
}
