import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menoo/l10n/app_localizations.dart';
import 'package:menoo/onboarding/onboarding_data.dart';
import 'package:menoo/onboarding/onboarding_scope.dart';
import 'package:menoo/screens/onboarding/member_profiles_screen.dart';
import 'package:menoo/screens/onboarding/profile_screen.dart';
import 'package:menoo/screens/onboarding/summary_screen.dart';
import 'package:menoo/theme/theme.dart';
import 'package:menoo/widgets/widgets.dart';

/// Entrées simulées par texte collé : le clavier numérique n'est pas un filtre.
void main() {
  setUpAll(() async {
    final loader = FontLoader('PlusJakartaSans');
    for (final w in [400, 500, 600, 700, 800]) {
      loader.addFont(Future.value(ByteData.sublistView(File('assets/fonts/PlusJakartaSans-$w.ttf').readAsBytesSync())));
    }
    await loader.load();
  });

  for (final language in ['fr', 'en', 'de']) {
    final locale = Locale(language);
    final l = lookupL(locale);

    Future<void> pump(WidgetTester t, OnboardingData data, Widget screen, {double width = 390}) async {
      t.view.physicalSize = Size(width, 1200);
      t.view.devicePixelRatio = 1;
      await t.pumpWidget(
        MaterialApp(
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

    for (final input in ['NaN', 'Infinity', '1e309']) {
      testWidgets('R01 $language cible collée $input : aucun crash de l’aperçu', (t) async {
        final data = OnboardingData()..goal = HealthGoal.priseMasse;
        addTearDown(data.dispose);
        addTearDown(t.view.reset);
        await pump(t, data, const ProfileScreen());
        await t.enterText(find.byType(TextField).at(3), input);
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);
        expect(data.targetWeightKg, isNull);
      });
    }

    testWidgets('R01 $language maintien : poids NaN doit être refusé sans navigation', (t) async {
      final data = OnboardingData()..goal = HealthGoal.maintien;
      addTearDown(data.dispose);
      addTearDown(t.view.reset);
      await pump(t, data, const ProfileScreen());
      await t.enterText(find.byType(TextField).at(2), 'NaN');
      await t.pumpAndSettle();
      await t.ensureVisible(find.text(l.commonContinue));
      await t.tap(find.text(l.commonContinue));
      await t.pumpAndSettle();
      expect(data.weightKg, 75);
      expect(find.byType(ProfileScreen), findsOneWidget);
    });

    for (final sample in <(String, int, String, String)>[
      ('âge vide', 0, '', l.profileAgeError),
      ('âge négatif', 0, '-1', l.profileAgeError),
      ('âge sous minimum', 0, '17', l.profileAgeError),
      ('âge au-dessus du maximum', 0, '101', l.profileAgeError),
      ('taille zéro', 1, '0', l.profileHeightError),
      ('taille sous minimum', 1, '119', l.profileHeightError),
      ('taille au-dessus du maximum', 1, '231', l.profileHeightError),
      ('taille excessive', 1, '1000000', l.profileHeightError),
      ('poids vide', 2, '', l.profileWeightError),
      ('poids zéro', 2, '0', l.profileWeightError),
      ('poids négatif', 2, '-1', l.profileWeightError),
      ('poids sous minimum', 2, '34.9', l.profileWeightError),
      ('poids au-dessus du maximum', 2, '250.1', l.profileWeightError),
      ('poids excessif', 2, '10000', l.profileWeightError),
    ]) {
      testWidgets('$language ${sample.$1} : validation existante et données conservées', (t) async {
        final data = OnboardingData()..goal = HealthGoal.maintien;
        addTearDown(data.dispose);
        addTearDown(t.view.reset);
        await pump(t, data, const ProfileScreen());
        await t.enterText(find.byType(TextField).at(sample.$2), sample.$3);
        await t.pumpAndSettle();
        await t.ensureVisible(find.text(l.commonContinue));
        await t.tap(find.text(l.commonContinue));
        await t.pumpAndSettle();
        expect(find.text(sample.$4), findsOneWidget);
        expect(data.age, 32);
        expect(data.heightCm, 180);
        expect(data.weightKg, 75);
      });
    }

    testWidgets('R01 $language membre familial : poids NaN doit être refusé', (t) async {
      final data = OnboardingData()..startMode(AppMode.foyer);
      addTearDown(data.dispose);
      addTearDown(t.view.reset);
      final original = data.members.first;
      await pump(t, data, MemberEditScreen(member: original.copy()));
      await t.enterText(find.byType(TextField).at(3), 'NaN');
      await t.pumpAndSettle();
      await t.ensureVisible(find.text(l.memberSave));
      await t.tap(find.text(l.memberSave));
      await t.pumpAndSettle();
      expect(data.members.first.weightKg, original.weightKg);
      expect(data.members.first, same(original));
    });

    testWidgets('$language bornes admises : profil conservé et passage à l’activité', (t) async {
      final data = OnboardingData()..goal = HealthGoal.maintien;
      addTearDown(data.dispose);
      addTearDown(t.view.reset);
      await pump(t, data, const ProfileScreen());
      await t.enterText(find.byType(TextField).at(0), '18');
      await t.enterText(find.byType(TextField).at(1), '120');
      await t.enterText(find.byType(TextField).at(2), '35');
      await t.pumpAndSettle();
      await t.ensureVisible(find.text(l.commonContinue));
      await t.tap(find.text(l.commonContinue));
      await t.pumpAndSettle();
      expect(data.age, 18);
      expect(data.heightCm, 120);
      expect(data.weightKg, 35);
      expect(find.byType(ProfileScreen), findsNothing);
      expect(t.takeException(), isNull);
    });

    testWidgets('$language cible 10000 kg saisie avec des chiffres : refus traduit sans perte', (t) async {
      final data = OnboardingData()..goal = HealthGoal.priseMasse;
      addTearDown(data.dispose);
      addTearDown(t.view.reset);
      await pump(t, data, const ProfileScreen());
      await t.enterText(find.byType(TextField).at(3), '10000');
      await t.pumpAndSettle();
      await t.ensureVisible(find.text(l.commonContinue));
      await t.tap(find.text(l.commonContinue));
      await t.pumpAndSettle();
      expect(data.targetWeightKg, isNull);
      expect(find.byType(ProfileScreen), findsOneWidget);
      expect(find.text(l.targetErrorMaximum(l.unitKilograms('250'))), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    for (final width in [320.0, 390.0]) {
      testWidgets('$language $width : macros indisponibles mais calories valides visibles', (t) async {
        final data = OnboardingData()
          ..sex = Sex.femme
          ..age = 100
          ..heightCm = 120
          ..weightKg = 250
          ..targetWeightKg = 249
          ..goal = HealthGoal.seche
          ..activity = ActivityLevel.sedentaire;
        addTearDown(data.dispose);
        addTearDown(t.view.reset);
        await pump(t, data, const SummaryScreen(), width: width);
        expect(find.textContaining('2 590', findRichText: true), findsOneWidget);
        expect(find.text(l.numericMacrosUnavailable), findsOneWidget);
        expect(find.text(l.numericCaloriesUnavailable), findsNothing);
        expect(find.textContaining('-15'), findsNothing);
        expect(data.dailyKcal, 2590);
        expect(data.weightKg, 250);
      });

      testWidgets('$language $width : profil injecté invalide signalé sans modifier les réponses', (t) async {
        final data = OnboardingData()..weightKg = double.nan;
        addTearDown(data.dispose);
        addTearDown(t.view.reset);
        await pump(t, data, const SummaryScreen(), width: width);
        expect(find.text(l.numericCaloriesUnavailable), findsOneWidget);
        await t.ensureVisible(find.text(l.summaryGenerateSolo));
        await t.tap(find.text(l.summaryGenerateSolo));
        await t.pumpAndSettle();
        expect(find.text(l.profileWeightError), findsOneWidget);
        expect(data.weightKg.isNaN, isTrue);
        expect(find.byType(SummaryScreen), findsOneWidget);
        expect(t.takeException(), isNull);
      });
    }

    testWidgets('$language : aperçu calculé avec la taille en cours de saisie', (t) async {
      final data = OnboardingData()
        ..weightKg = 35
        ..targetWeightKg = 30;
      addTearDown(data.dispose);
      addTearDown(t.view.reset);
      // 30 kg est au-dessus de l'IMC minimum pour 120 cm, mais pas pour 180 cm.
      await pump(t, data, const ProfileScreen());
      await t.enterText(find.byType(TextField).at(1), '120');
      await t.pumpAndSettle();
      expect(find.byType(WeightProjectionCard), findsOneWidget);
      expect(data.heightCm, 180, reason: 'le brouillon ne remplace pas le profil avant validation');
      expect(t.takeException(), isNull);
    });

    testWidgets('$language : rythme incompatible signalé et sélection explicite en Sèche', (t) async {
      final data = OnboardingData()
        ..goal = HealthGoal.seche
        ..weeklyRateKg = 0.75
        ..targetWeightKg = 70;
      addTearDown(data.dispose);
      addTearDown(t.view.reset);
      await pump(t, data, const ProfileScreen());
      expect(data.effectiveRate, isNull);
      expect(find.text(l.numericRateError), findsOneWidget);
      await t.ensureVisible(find.text(l.unitKilograms(language == 'en' ? '0.5' : '0,5')));
      await t.tap(find.text(l.unitKilograms(language == 'en' ? '0.5' : '0,5')));
      await t.pumpAndSettle();
      expect(data.weeklyRateKg, 0.5);
      expect(find.byType(WeightProjectionCard), findsOneWidget);
      expect(t.takeException(), isNull);
    });
  }
}
