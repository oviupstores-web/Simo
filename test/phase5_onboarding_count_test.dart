import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menoo/l10n/app_localizations.dart';
import 'package:menoo/onboarding/onboarding_data.dart';
import 'package:menoo/onboarding/onboarding_flow.dart';
import 'package:menoo/onboarding/onboarding_scope.dart';
import 'package:menoo/screens/onboarding/cover_household_screen.dart';
import 'package:menoo/screens/onboarding/cover_solo_screen.dart';
import 'package:menoo/screens/pantry/pantry_hub_onboarding_screen.dart';
import 'package:menoo/theme/theme.dart';
import 'package:menoo/widgets/widgets.dart';

void main() {
  setUpAll(() async {
    for (final family in ['PlusJakartaSans', 'ReadexPro']) {
      final loader = FontLoader(family);
      for (final w in [400, 500, 600, 700, 800]) {
        final f = File('assets/fonts/$family-$w.ttf');
        if (f.existsSync()) loader.addFont(Future.value(ByteData.sublistView(f.readAsBytesSync())));
      }
      await loader.load();
    }
  });
  test(
    'Solo : ordre validé des 11 étapes, Réserve hors liste',
    () => expect(OnboardingFlow.solo, [
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
    ]),
  );
  test(
    'Famille : ordre validé des 9 étapes, Réserve hors liste',
    () => expect(OnboardingFlow.foyer, [
      OnbStep.household,
      OnbStep.members,
      OnbStep.grid,
      OnbStep.budget,
      OnbStep.constraints,
      OnbStep.management,
      OnbStep.cuisines,
      OnbStep.kitchen,
      OnbStep.summary,
    ]),
  );
  Future<void> show(WidgetTester t, OnboardingData d, String lang, double width, Widget home) async {
    t.view.physicalSize = Size(width, 2400);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    addTearDown(d.dispose);
    await t.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: Locale(lang),
        supportedLocales: L.supportedLocales,
        localizationsDelegates: L.localizationsDelegates,
        builder: (_, child) => OnboardingScope(data: d, child: child!),
        home: home,
      ),
    );
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
  }

  for (final lang in ['fr', 'en', 'de', 'es', 'it', 'ar']) {
    for (final width in [320.0, 390.0]) {
      for (final mode in AppMode.values) {
        testWidgets('$lang $width couverture $mode : nombre issu du parcours', (t) async {
          final d = OnboardingData()..startMode(mode);
          final count = mode == AppMode.foyer ? 9 : 11;
          final l = lookupL(Locale(lang));
          await show(t, d, lang, width, mode == AppMode.foyer ? const CoverHouseholdScreen() : const CoverSoloScreen());
          expect(find.text('${l.commonQuickSteps(count)} · ${l.commonEditableAnytime}'), findsOneWidget);
          expect(find.byType(OnboardingStepScaffold), findsNothing);
        });
      }
    }
  }
  void journey(String lang, double width, AppMode mode, ManagementMode management) {
    testWidgets('$lang $width $mode $management : parcours, retours et récapitulatif', (t) async {
      final d = OnboardingData()
        ..startMode(mode)
        ..goal = HealthGoal.maintien
        ..management = management;
      d.restoreBudget(amount: 87, currency: 'CAD');
      d.diets.addAll({'vegan', 'sans_lactose'});
      d.allergens.addAll({'crustaces', 'gluten'});
      d.excludedFoods.add('Historique');
      final order = mode == AppMode.foyer ? OnboardingFlow.foyer : OnboardingFlow.solo;
      final members = {
        for (final m in d.members) m.id: (m.firstName, m.role, (m.allergens.toList()..sort()).join('|')),
      };
      final slots = {...d.slots};
      final pantry = [...d.pantry];
      final l = lookupL(Locale(lang));
      await show(t, d, lang, width, mode == AppMode.foyer ? const CoverHouseholdScreen() : const CoverSoloScreen());
      final start = find.text(mode == AppMode.foyer ? l.coverHouseholdStart : l.coverSoloStart);
      await t.ensureVisible(start);
      await t.tap(start);
      await t.pumpAndSettle();
      OnboardingStepScaffold scaffold() => t.widget<OnboardingStepScaffold>(find.byType(OnboardingStepScaffold));
      Future<void> forward() async {
        final isManagement = order[scaffold().step! - 1] == OnbStep.management;
        final callback = scaffold().onContinue;
        expect(callback, isNotNull);
        callback!();
        await t.pumpAndSettle();
        if (isManagement) {
          expect(
            find.byType(PantryHubOnboardingScreen),
            management == ManagementMode.courses ? findsNothing : findsOneWidget,
          );
        }
        if (find.byType(PantryHubOnboardingScreen).evaluate().isNotEmpty) {
          expect(find.byType(OnboardingStepScaffold), findsNothing);
          final skip = find.text(l.pantryHubSkip);
          await t.ensureVisible(skip);
          await t.tap(skip);
          await t.pumpAndSettle();
        }
        expect(t.takeException(), isNull);
      }

      for (var i = 0; i < order.length; i++) {
        expect((scaffold().step, scaffold().totalSteps), (i + 1, order.length));
        if (i == order.length - 1) break;
        final previous = i + 1;
        await forward();
        expect((scaffold().step, scaffold().totalSteps), (i + 2, order.length));
        if (order[i] == OnbStep.management) {
          expect(
            management == ManagementMode.courses ||
                order[i + 1] == (mode == AppMode.foyer ? OnbStep.cuisines : OnbStep.constraints),
            isTrue,
          );
        }
        Navigator.of(t.element(find.byType(OnboardingStepScaffold))).pop();
        await t.pumpAndSettle();
        expect(scaffold().step, previous);
        await forward();
      }
      final context = t.element(find.byType(OnboardingStepScaffold));
      OnboardingFlow.open(context, OnbStep.budget, fromSummary: true);
      await t.pumpAndSettle();
      expect(scaffold().step, order.indexOf(OnbStep.budget) + 1);
      await forward();
      expect(scaffold().step, order.length);
      OnboardingFlow.open(t.element(find.byType(OnboardingStepScaffold)), OnbStep.management, fromSummary: true);
      await t.pumpAndSettle();
      await forward();
      expect(scaffold().step, order.length);
      expect((d.budgetEuros, d.budgetCurrencyCode), (87, 'CAD'));
      expect(d.diets, {'vegan', 'sans_lactose'});
      expect(d.allergens, {'crustaces', 'gluten'});
      expect(d.excludedFoods, ['Historique']);
      expect({
        for (final m in d.members) m.id: (m.firstName, m.role, (m.allergens.toList()..sort()).join('|')),
      }, members);
      expect(d.slots, slots);
      expect(d.pantry, orderedEquals(pantry));
      expect(t.takeException(), isNull);
    });
  }

  for (final lang in ['fr', 'en', 'de']) {
    for (final width in [320.0, 390.0]) {
      for (final mode in AppMode.values) {
        journey(lang, width, mode, ManagementMode.mixte);
      }
    }
  }
  for (final mode in AppMode.values) {
    for (final management in [ManagementMode.courses, ManagementMode.reserves]) {
      journey('fr', 390, mode, management);
    }
  }
}
