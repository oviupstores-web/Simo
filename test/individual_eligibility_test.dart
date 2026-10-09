import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menoo/l10n/app_localizations.dart';
import 'package:menoo/l10n/formats.dart';
import 'package:menoo/onboarding/onboarding_data.dart';
import 'package:menoo/onboarding/onboarding_flow.dart';
import 'package:menoo/onboarding/onboarding_scope.dart';
import 'package:menoo/screens/onboarding/profile_screen.dart';
import 'package:menoo/screens/onboarding/cover_solo_screen.dart';
import 'package:menoo/screens/onboarding/cover_household_screen.dart';
import 'package:menoo/screens/onboarding/goal_screen.dart';
import 'package:menoo/screens/onboarding/activity_screen.dart';
import 'package:menoo/screens/onboarding/smart_scale_screen.dart';
import 'package:menoo/screens/onboarding/household_size_screen.dart';
import 'package:menoo/screens/onboarding/member_profiles_screen.dart';
import 'package:menoo/screens/onboarding/summary_screen.dart';
import 'package:menoo/theme/theme.dart';

void main() {
  setUpAll(() async {
    final loader = FontLoader('PlusJakartaSans');
    for (final w in [400, 500, 600, 700, 800]) {
      loader.addFont(Future.value(ByteData.sublistView(File('assets/fonts/PlusJakartaSans-$w.ttf').readAsBytesSync())));
    }
    await loader.load();
  });
  Future<void> show(WidgetTester t, OnboardingData d, Locale locale, Widget screen, double width) async {
    t.view.physicalSize = Size(width, 1200);
    t.view.devicePixelRatio = 1;
    await t.pumpWidget(
      MaterialApp(
        key: UniqueKey(),
        theme: AppTheme.light,
        locale: locale,
        supportedLocales: L.supportedLocales,
        localizationsDelegates: L.localizationsDelegates,
        builder: (_, child) => OnboardingScope(data: d, child: child!),
        home: screen,
      ),
    );
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
  }

  for (final language in ['fr', 'en', 'de']) {
    final locale = Locale(language);
    final l = lookupL(locale);
    for (final width in [320.0, 390.0]) {
      testWidgets('$language $width : saisie 17 refusée puis 18 acceptée, même avec ancien profil mineur', (t) async {
        final d = OnboardingData()
          ..age = 17
          ..targetWeightKg = 70;
        addTearDown(d.dispose);
        addTearDown(t.view.reset);
        for (final screen in <Widget>[
          const CoverSoloScreen(),
          const GoalScreen(),
          const ActivityScreen(),
          const SmartScaleScreen(),
          const SummaryScreen(),
        ]) {
          await show(t, d, locale, screen, width);
          expect(find.byType(ProfileScreen), findsOneWidget);
        }
        expect(find.byType(ProfileScreen), findsOneWidget);
        expect(find.text(l.summaryGenerateSolo), findsNothing);
        await t.ensureVisible(find.text(l.commonContinue));
        await t.tap(find.text(l.commonContinue));
        await t.pumpAndSettle();
        expect(find.text(l.profileAgeError), findsAtLeastNWidgets(1));
        expect(d.age, 17);
        await t.enterText(find.byType(TextField).first, '18');
        await t.pumpAndSettle();
        await t.ensureVisible(find.text(l.commonContinue));
        await t.tap(find.text(l.commonContinue));
        await t.pumpAndSettle();
        expect(d.age, 18);
        expect(find.byType(ActivityScreen), findsOneWidget);
        expect(d.targetWeightKg, 70);
        expect(t.takeException(), isNull);
      });
      testWidgets('$language $width : accès directs Famille sans objectifs ni projections', (t) async {
        final d = OnboardingData()..startMode(AppMode.foyer);
        addTearDown(d.dispose);
        addTearDown(t.view.reset);
        expect(d.setCount(MemberRole.bebe, 1), isNull);
        d.members.first.goal = HealthGoal.priseMasse;
        d.members.first.allergens.add('gluten');
        d.excludedFoods.add('broccoli');
        await show(t, d, locale, const CoverSoloScreen(), width);
        expect(find.byType(CoverHouseholdScreen), findsOneWidget);
        expect(find.text(l.coverSoloFeature1Title), findsNothing);
        final before = d.members
            .map(
              (m) => (
                m.id,
                m.role,
                m.firstName,
                m.age,
                m.heightCm,
                m.weightKg,
                m.goal,
                m.activity,
                (m.allergens.toList()..sort()).join('|'),
              ),
            )
            .toList();
        for (final screen in <Widget>[
          const GoalScreen(),
          const ProfileScreen(),
          const ActivityScreen(),
          const SmartScaleScreen(),
        ]) {
          await show(t, d, locale, screen, width);
          expect(find.byType(HouseholdSizeScreen), findsOneWidget);
          expect(find.text(l.goalLossTitle), findsNothing);
          expect(find.text(l.profileTargetSection), findsNothing);
        }
        for (final screen in <Widget>[
          const MemberProfilesScreen(),
          MemberEditScreen(member: d.members.first),
          const SummaryScreen(),
        ]) {
          await show(t, d, locale, screen, width);
          for (final text in [
            l.goalLossTitle,
            l.goalGainTitle,
            l.goalCutTitle,
            l.goalMaintainTitle,
            l.memberGoalSection,
            l.memberActivitySection,
          ]) {
            expect(find.text(text), findsNothing);
          }
        }
        expect(
          d.members
              .map(
                (m) => (
                  m.id,
                  m.role,
                  m.firstName,
                  m.age,
                  m.heightCm,
                  m.weightKg,
                  m.goal,
                  m.activity,
                  (m.allergens.toList()..sort()).join('|'),
                ),
              )
              .toList(),
          before,
        );
        expect(d.excludedFoods, ['broccoli']);
      });
    }
    testWidgets('$language : navigation directe Solo mineur redirigée vers la correction du profil', (t) async {
      final d = OnboardingData()..age = 17;
      addTearDown(d.dispose);
      addTearDown(t.view.reset);
      await show(
        t,
        d,
        locale,
        Builder(
          builder: (context) =>
              TextButton(onPressed: () => OnboardingFlow.open(context, OnbStep.summary), child: const Text('open')),
        ),
        390,
      );
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
      expect(find.byType(ProfileScreen), findsOneWidget);
      expect(find.text(l.summaryGenerateSolo), findsNothing);
      expect(d.age, 17);
    });
    test('$language : profil Solo préexistant à 17 ans refusé sans altération', () {
      final d = OnboardingData()
        ..age = 17
        ..targetWeightKg = 70;
      addTearDown(d.dispose);
      expect(OnboardingData.profileInputError(l, age: 17, heightCm: 180, weightKg: 75), l.profileAgeError);
      expect(d.hasValidProfile, isFalse);
      expect(d.dailyKcal, isNull);
      expect(d.macros, isNull);
      expect(d.weeksToTarget(target: 70), isNull);
      expect(d.targetDate(target: 70), isNull);
      expect(d.targetError(l, Formats(locale), target: 70, current: 75, heightCm: 180), l.profileAgeError);
      expect((d.age, d.targetWeightKg), (17, 70.0));
    });
    test('$language : Solo accessible dès 18 ans', () {
      final d = OnboardingData()..age = 18;
      addTearDown(d.dispose);
      expect(OnboardingData.profileInputError(l, age: 18, heightCm: 180, weightKg: 75), isNull);
      expect(d.hasValidProfile, isTrue);
      expect(d.dailyKcal, isNotNull);
      expect(d.macros, isNotNull);
      expect(d.targetDate(target: 70), isNotNull);
    });
    test('$language : Foyer ne calcule pas de transformation physique', () {
      final d = OnboardingData()
        ..startMode(AppMode.foyer)
        ..goal = HealthGoal.priseMasse;
      addTearDown(d.dispose);
      expect(d.dailyKcal, isNull);
      expect(d.macros, isNull);
      expect(d.weeksToTarget(target: 80), isNull);
      expect(d.targetDate(target: 80), isNull);
      expect(d.goal, HealthGoal.priseMasse);
      expect(MemberRole.adulte.minAge, 14);
      expect(MemberRole.enfant.maxAge, 13);
      expect(MemberRole.bebe.maxAge, 3);
    });
  }
}
