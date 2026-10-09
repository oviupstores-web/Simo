import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menoo/l10n/app_localizations.dart';
import 'package:menoo/onboarding/onboarding_data.dart';
import 'package:menoo/onboarding/onboarding_scope.dart';
import 'package:menoo/screens/onboarding/constraints_screen.dart';
import 'package:menoo/screens/onboarding/member_profiles_screen.dart';
import 'package:menoo/screens/onboarding/summary_screen.dart';
import 'package:menoo/theme/theme.dart';
import 'package:menoo/widgets/widgets.dart';

void main() {
  setUpAll(() async {
    for (final family in ['PlusJakartaSans', 'ReadexPro']) {
      final loader = FontLoader(family);
      for (final weight in [400, 500, 600, 700, 800]) {
        final f = File('assets/fonts/$family-$weight.ttf');
        if (f.existsSync()) loader.addFont(Future.value(ByteData.sublistView(f.readAsBytesSync())));
      }
      await loader.load();
    }
  });
  const expectedCodes = {
    'gluten',
    'arachides',
    'fruits_a_coque',
    'oeufs',
    'soja',
    'crustaces',
    'mollusques',
    'poisson',
    'lait',
    'sesame',
    'moutarde',
    'celeri',
    'sulfites',
    'lupin',
  };
  for (final lang in ['fr', 'en', 'de', 'es', 'it', 'ar']) {
    test('$lang : 14 codes uniques et crustacés/mollusques indépendants', () {
      final l = lookupL(Locale(lang));
      final choices = ConstraintsScreen.allergenChoices(l);
      expect(choices.every((a) => a.$1.length == 1), isTrue);
      expect(choices.expand((a) => a.$1).toList(), hasLength(14));
      expect(choices.expand((a) => a.$1).toSet(), expectedCodes);
      expect(ConstraintsScreen.otherAllergens(l).map((a) => a.$1).toSet(), {
        'poisson',
        'lait',
        'sesame',
        'moutarde',
        'celeri',
        'sulfites',
        'lupin',
      });
    });
  }
  for (final code in [null, 'vegetarien', 'vegan', 'pescetarien']) {
    test('modèle régime $code : résolution explicite, restrictions/codes inconnus intacts', () {
      final d = OnboardingData();
      addTearDown(d.dispose);
      d.diets.addAll({'vegetarien', 'vegan', 'pescetarien', 'sans_porc', 'sans_lactose', 'sans_gluten', 'historique'});
      d.allergens.addAll(expectedCodes);
      d.excludedFoods.add('Ancienne exclusion');
      expect(d.hasDietConflict, isTrue);
      d.selectPrincipalDiet(code);
      expect(d.diets, {'sans_porc', 'sans_lactose', 'sans_gluten', 'historique', ?code});
      expect(d.hasDietConflict, isFalse);
      expect(d.allergens, expectedCodes);
      expect(d.excludedFoods, ['Ancienne exclusion']);
    });
  }
  test('modèle : une restriction ne peut pas devenir un régime principal', () {
    final d = OnboardingData()..diets.addAll({'vegan', 'sans_porc'});
    addTearDown(d.dispose);
    expect(() => d.selectPrincipalDiet('sans_lactose'), throwsArgumentError);
    expect(d.diets, {'vegan', 'sans_porc'});
  });

  const restrictionTitles = {
    'fr': 'Restrictions alimentaires',
    'en': 'Dietary restrictions',
    'de': 'Ernährungseinschränkungen',
  };
  const dislikeTitles = {'fr': 'Aliments non aimés', 'en': 'Disliked foods', 'de': 'Nicht gemochte Lebensmittel'};
  for (final lang in ['fr', 'en', 'de']) {
    for (final width in [320.0, 390.0]) {
      final l = lookupL(Locale(lang));
      Future<void> show(WidgetTester t, OnboardingData d, Widget screen) async {
        t.view.physicalSize = Size(width, 2400);
        t.view.devicePixelRatio = 1;
        await t.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            locale: Locale(lang),
            supportedLocales: L.supportedLocales,
            localizationsDelegates: L.localizationsDelegates,
            builder: (_, child) => OnboardingScope(data: d, child: child!),
            home: screen,
          ),
        );
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);
      }

      Future<void> tap(WidgetTester t, String label) async {
        final f = find.text(label).last;
        await t.ensureVisible(f);
        await t.tap(f);
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);
      }

      OnboardingData data(WidgetTester t) {
        final d = OnboardingData()..goal = HealthGoal.maintien;
        addTearDown(d.dispose);
        addTearDown(t.view.reset);
        return d;
      }

      testWidgets('$lang $width : régime unique sans perte de restrictions', (t) async {
        final d = data(t)..diets.addAll({'vegetarien', 'sans_porc', 'sans_lactose', 'sans_gluten', 'ancien_code'});
        await show(t, d, const ConstraintsScreen());
        await tap(t, l.dietVegan);
        expect(d.diets, {'vegan', 'sans_porc', 'sans_lactose', 'sans_gluten', 'ancien_code'});
        await tap(t, l.dietPescatarian);
        expect(d.diets, {'pescetarien', 'sans_porc', 'sans_lactose', 'sans_gluten', 'ancien_code'});
      });
      testWidgets('$lang $width : Omnivore conserve les restrictions et allergies', (t) async {
        final d = data(t)
          ..diets.addAll({'vegan', 'sans_porc', 'sans_gluten'})
          ..allergens.addAll({'lait', 'gluten'});
        await show(t, d, const ConstraintsScreen());
        await tap(t, l.dietOmnivore);
        expect(d.diets, {'sans_porc', 'sans_gluten'});
        expect(d.allergens, {'lait', 'gluten'});
        expect(
          find.byWidgetPredicate((w) => w is ToggleChip && w.label == l.dietOmnivore && w.selected),
          findsOneWidget,
        );
        await tap(t, l.dietNoLactose);
        expect(d.diets, {'sans_porc', 'sans_gluten', 'sans_lactose'});
      });
      testWidgets('$lang $width : conflit historique conservé et résolution explicite', (t) async {
        final d = data(t)..diets.addAll({'vegetarien', 'vegan', 'sans_porc'});
        await show(t, d, const ConstraintsScreen());
        expect(d.diets, {'vegetarien', 'vegan', 'sans_porc'});
        expect(t.widget<OnboardingStepScaffold>(find.byType(OnboardingStepScaffold)).onContinue, isNull);
        await tap(t, l.dietVegetarian);
        expect(d.diets, {'vegetarien', 'sans_porc'});
        expect(t.widget<OnboardingStepScaffold>(find.byType(OnboardingStepScaffold)).onContinue, isNotNull);
      });
      testWidgets('$lang $width : quatre sections, déroulant et saisie libre conservés', (t) async {
        final d = data(t)..excludedFoods.add('Ancienne exclusion');
        await show(t, d, const ConstraintsScreen());
        final titles = t.widgetList<StepSectionTitle>(find.byType(StepSectionTitle)).map((w) => w.title).toList();
        expect(titles, [
          l.constraintsDietsSection,
          restrictionTitles[lang],
          l.constraintsAllergensSection,
          dislikeTitles[lang],
        ]);
        await tap(t, l.constraintsOtherAllergens);
        expect(find.text(l.allergenMilk), findsOneWidget);
        await t.ensureVisible(find.byType(TextField));
        await t.enterText(find.byType(TextField), 'coriandre');
        await t.testTextInput.receiveAction(TextInputAction.done);
        await t.pumpAndSettle();
        expect(d.excludedFoods, ['Ancienne exclusion', 'Coriandre']);
        await t.enterText(find.byType(TextField), 'CORIANDRE');
        await t.testTextInput.receiveAction(TextInputAction.done);
        await t.pumpAndSettle();
        expect(d.excludedFoods, ['Ancienne exclusion', 'Coriandre']);
      });
      testWidgets('$lang $width : allergènes indépendants, historiques et membres préservés', (t) async {
        final d = data(t)
          ..startMode(AppMode.foyer)
          ..allergens.addAll({'crustaces', 'gluten', 'code_inconnu'});
        d.members.first.allergens.add('mollusques');
        final inherited = {...d.members.first.allergens};
        await show(t, d, const ConstraintsScreen());
        final choices = ConstraintsScreen.allergenChoices(l);
        String label(String code) => choices.singleWhere((a) => a.$1.single == code).$2;
        expect(
          find.byWidgetPredicate((w) => w is OptionTile && w.label == label('crustaces') && w.selected),
          findsOneWidget,
        );
        await tap(t, label('mollusques'));
        expect(d.allergens, {'crustaces', 'mollusques', 'gluten', 'code_inconnu'});
        await tap(t, label('crustaces'));
        expect(d.allergens, {'mollusques', 'gluten', 'code_inconnu'});
        expect(d.members.first.allergens, inherited);
        await show(t, d, const SummaryScreen());
        expect(find.textContaining(label('mollusques')), findsWidgets);
        expect(d.allAllergens, containsAll(['mollusques', 'gluten', 'code_inconnu']));
      });
      testWidgets('$lang $width : accès direct au récapitulatif ne contourne pas le conflit', (t) async {
        final d = data(t)..diets.addAll({'vegan', 'vegetarien', 'sans_lactose'});
        await show(t, d, const SummaryScreen());
        await tap(t, l.summaryGenerateSolo);
        expect(find.byType(ConstraintsScreen), findsOneWidget);
        expect(d.diets, {'vegan', 'vegetarien', 'sans_lactose'});
        expect(t.widget<OnboardingStepScaffold>(find.byType(OnboardingStepScaffold)).onContinue, isNull);
      });
      testWidgets('$lang $width : changer de langue conserve tous les codes et exclusions', (t) async {
        final d = data(t)
          ..diets.addAll({'vegan', 'sans_lactose', 'sans_gluten'})
          ..allergens.addAll(expectedCodes)
          ..excludedFoods.add('Texte libre historique');
        await show(t, d, const ConstraintsScreen());
        for (final language in ['fr', 'en', 'de', 'es', 'it', 'ar']) {
          await t.pumpWidget(
            MaterialApp(
              theme: AppTheme.light,
              locale: Locale(language),
              supportedLocales: L.supportedLocales,
              localizationsDelegates: L.localizationsDelegates,
              builder: (_, child) => OnboardingScope(data: d, child: child!),
              home: const ConstraintsScreen(),
            ),
          );
          await t.pumpAndSettle();
          expect(t.takeException(), isNull);
          expect(d.diets, {'vegan', 'sans_lactose', 'sans_gluten'});
          expect(d.allergens, expectedCodes);
          expect(d.excludedFoods, ['Texte libre historique']);
        }
      });
      testWidgets('$lang $width : profils adulte/enfant/bébé restent indépendants', (t) async {
        final d = data(t)..startMode(AppMode.foyer);
        d.setCount(MemberRole.bebe, 1);
        for (final m in d.members) {
          m.allergens.clear();
          m.allergens.add(
            m.role == MemberRole.adulte
                ? 'crustaces'
                : m.role == MemberRole.enfant
                ? 'mollusques'
                : 'gluten',
          );
        }
        final before = {
          for (final m in d.members) m.id: {...m.allergens},
        };
        await show(t, d, const ConstraintsScreen());
        final shell = ConstraintsScreen.allergenChoices(l).singleWhere((a) => a.$1.single == 'crustaces').$2;
        await tap(t, shell);
        await tap(t, shell);
        await show(t, d, const SummaryScreen());
        expect({
          for (final m in d.members) m.id: {...m.allergens},
        }, before);
        expect(d.allAllergens, {'crustaces', 'mollusques', 'gluten'});
      });
      testWidgets('$lang $width : profil membre crustacés seuls, aucune modification implicite', (t) async {
        final d = data(t)..startMode(AppMode.foyer);
        final m = d.members.first.copy();
        m.allergens.clear();
        m.allergens.add('crustaces');
        await show(t, d, MemberEditScreen(member: m));
        final choices = ConstraintsScreen.allergenChoices(l);
        final c = choices.singleWhere((a) => a.$1.length == 1 && a.$1.single == 'crustaces');
        expect(find.byWidgetPredicate((w) => w is ToggleChip && w.label == c.$2 && w.selected), findsOneWidget);
        expect(m.allergens, {'crustaces'});
        await tap(t, l.memberSave);
        expect(d.members.first.allergens, {'crustaces'});
      });
    }
  }
}
