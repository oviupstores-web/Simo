import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:menoo/l10n/app_languages.dart';
import 'package:menoo/l10n/app_localizations.dart';
import 'package:menoo/l10n/formats.dart';
import 'package:menoo/l10n/locale_scope.dart';
import 'package:menoo/main.dart';
import 'package:menoo/screens/entry/startup_screen.dart';
import 'package:menoo/onboarding/onboarding_data.dart';
import 'package:menoo/onboarding/onboarding_scope.dart';
import 'package:menoo/screens/onboarding/budget_screen.dart';
import 'package:menoo/screens/onboarding/weekly_grid_screen.dart';
import 'package:menoo/theme/theme.dart';

/// Diagnostic seulement : aucune politique de conversion monétaire imposée.
void main() {
  setUpAll(() async {
    await initializeDateFormatting();
    final loader = FontLoader('PlusJakartaSans');
    for (final weight in [400, 500, 600, 700, 800]) {
      loader.addFont(
        Future.value(ByteData.sublistView(File('assets/fonts/PlusJakartaSans-$weight.ttf').readAsBytesSync())),
      );
    }
    await loader.load();
  });
  const regions = <(String, String, String)>[
    ('fr', 'FR', 'EUR'), ('de', 'DE', 'EUR'), ('en', 'GB', 'GBP'), ('en', 'US', 'USD'),
    // Phase 4 : CAD/AUD explicitement validés pour les nouveaux budgets.
    ('en', 'CA', 'CAD'), ('en', 'AU', 'AUD'), ('de', 'CH', 'CHF'),
  ];
  Future<void> show(WidgetTester t, OnboardingData data, Locale locale, Widget screen, double width) async {
    t.view.physicalSize = Size(width, 1500);
    t.view.devicePixelRatio = 1;
    await t.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: locale,
        supportedLocales: L.supportedLocales,
        localizationsDelegates: L.localizationsDelegates,
        localeResolutionCallback: (preferred, _) => AppLanguages.resolve(preferred, preferred),
        builder: (_, child) => OnboardingScope(data: data, child: child!),
        home: screen,
      ),
    );
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
  }

  for (final region in regions) {
    final locale = Locale(region.$1, region.$2);
    final l = lookupL(locale);
    final fmt = Formats(locale);
    test('état actuel ${region.$2} : pays conservé, devise/format/unités observés', () {
      expect(AppLanguages.resolve(locale, locale), locale);
      expect(fmt.currency, region.$3);
      expect(fmt.units, region.$2 == 'US' ? UnitSystem.imperial : UnitSystem.metric);
      // Aucune valeur n'est convertie : le formateur n'est pas un taux de change.
      expect(fmt.price(6550), contains(fmt.number(65.5, decimals: 2)));
      debugPrint(
        '${locale.toLanguageTag()} | ${fmt.currency} | ${fmt.price(6550)} | ${fmt.number(8 / 7, decimals: 1)} | ${fmt.units.name}',
      );
    });
    for (final width in [320.0, 390.0]) {
      for (final part in ['montant principal', 'suffixe personnalisé', 'conseil foyer']) {
        testWidgets('B08 ${locale.toLanguageTag()} $width $part : cohérence avec la devise déjà affichée', (t) async {
          final d = OnboardingData();
          if (part == 'conseil foyer') d.startMode(AppMode.foyer);
          final amount = d.budgetEuros;
          addTearDown(d.dispose);
          addTearDown(t.view.reset);
          await show(t, d, locale, const BudgetScreen(), width);
          expect(d.budgetEuros, amount);
          final observedLocale = Localizations.localeOf(t.element(find.byType(BudgetScreen)));
          expect(observedLocale, locale);
          if (fmt.currency != 'EUR') {
            if (part == 'montant principal') {
              expect(find.text(' € '), findsNothing);
            } else if (part == 'suffixe personnalisé') {
              expect(l.budgetCustomSuffix(fmt.currencySymbol), isNot(contains('€')));
            } else {
              expect(
                l.budgetAdvisedText(d.peopleCount, fmt.priceWhole(30), fmt.priceWhole(20), fmt.priceWhole(25)),
                isNot(contains('€')),
              );
            }
          } else {
            expect(find.text(' € '), findsOneWidget);
          }
        });
      }
    }
  }

  for (final country in ['US', 'GB', 'CH']) {
    testWidgets('B08 application réelle : changer la langue conserve le pays $country', (t) async {
      t.view.physicalSize = const Size(390, 1500);
      t.view.devicePixelRatio = 1;
      t.platformDispatcher.localesTestValue = [Locale('en', country)];
      addTearDown(t.platformDispatcher.clearLocalesTestValue);
      addTearDown(t.view.reset);
      await t.pumpWidget(const MenooApp());
      await t.pump();
      final before = Localizations.localeOf(t.element(find.byType(MenooStartup)));
      expect(before.countryCode, country);
      LocaleScope.of(t.element(find.byType(MaterialApp))).value = const Locale('fr');
      await t.pump();
      await t.pump();
      final after = Localizations.localeOf(t.element(find.byType(MenooStartup)));
      expect(after.countryCode, country);
    });
  }

  test('budget déjà saisi : changer pays/langue n’en convertit pas la valeur', () {
    final d = OnboardingData()
      ..budgetEuros = 87
      ..budgetEdited = true;
    addTearDown(d.dispose);
    for (final region in regions) {
      final locale = AppLanguages.resolve(const Locale('fr'), Locale(region.$1, region.$2));
      Formats(locale).price(d.budgetEuros * 100);
      expect(d.budgetEuros, 87);
      expect(d.budgetEdited, isTrue);
    }
    // Ce contrôle ne prouve pas la devise de la valeur stockée : aucun champ de devise n'existe.
  });

  for (final entry in <(Locale, String)>[
    (const Locale('fr', 'FR'), '65,50'),
    (const Locale('en', 'US'), '65.50'),
    (const Locale('de', 'DE'), '65,50'),
  ]) {
    testWidgets('B08 collage ${entry.$2} en ${entry.$1.toLanguageTag()} : pas de concaténation des chiffres', (
      t,
    ) async {
      final d = OnboardingData();
      addTearDown(d.dispose);
      addTearDown(t.view.reset);
      await show(t, d, entry.$1, const BudgetScreen(), 390);
      await t.enterText(find.byType(TextField).first, entry.$2);
      await t.pumpAndSettle();
      // Un choix de précision monétaire est requis ; aucun ne peut justifier 65,50 devenant 6550.
      expect(d.budgetEuros, isNot(6550));
    });
  }

  final en = lookupL(const Locale('en'));
  final imperial = Formats(const Locale('en', 'US'));
  for (final cm in [0.1, 2.54, 30.47, 30.48, 30.49, 120.0, 152.4, 180.0, 181.60, 181.61, 182.0, 182.88, 230.0]) {
    test('B09 $cm cm : arrondi entier du total et pouces normalisés', () {
      final roundedTotal = (cm / 2.54).round();
      final expected = en.unitFeetInches(roundedTotal ~/ 12, roundedTotal % 12);
      expect(imperial.height(en, cm), expected);
    });
  }
  test('B09 balayage 120–230 cm : jamais 12 pouces', () {
    final invalid = <String>[];
    for (var tenth = 1200; tenth <= 2300; tenth++) {
      final cm = tenth / 10;
      final text = imperial.height(en, cm);
      final match = RegExp(r'^(\d+) ft (\d+) in$').firstMatch(text)!;
      if (int.parse(match.group(2)!) >= 12) invalid.add('$cm cm => $text');
    }
    expect(invalid, isEmpty, reason: invalid.take(10).join('\n'));
  });
  for (final cm in [double.nan, double.infinity, double.negativeInfinity, 0.0, -1.0, 1e20]) {
    test('B09 entrée technique invalide $cm : protection R01 conservée', () {
      expect(imperial.height(en, cm), en.numericValueUnavailable);
    });
  }
  test('B09 affichage impérial : référence métrique du modèle intacte', () {
    final d = OnboardingData()..heightCm = 182;
    addTearDown(d.dispose);
    imperial.height(en, d.heightCm.toDouble());
    expect(d.heightCm, 182);
  });

  for (final language in ['fr', 'en', 'de']) {
    final l = lookupL(Locale(language));
    for (final cm in [120.0, 180.0, 182.0, 230.0]) {
      test('métrique $language $cm : référence et libellé conservés', () {
        final fmt = Formats(Locale(language, 'FR'), units: UnitSystem.metric);
        expect(fmt.height(l, cm), l.unitCentimeters(fmt.number(cm)));
      });
    }
    for (final region in regions) {
      final locale = Locale(language, region.$2);
      final fmt = Formats(locale);
      for (final width in [320.0, 390.0]) {
        testWidgets('B10 ${locale.toLanguageTag()} $width : moyenne affichée selon Formats sans modifier les repas', (
          t,
        ) async {
          final d = OnboardingData();
          d.slots
            ..clear()
            ..addAll({for (var day = 1; day <= 7; day++) (day, MealType.diner), (1, MealType.dejeuner)});
          final before = {...d.slots};
          addTearDown(d.dispose);
          addTearDown(t.view.reset);
          await show(t, d, locale, const WeeklyGridScreen(), width);
          expect(d.plannedMeals, 8);
          expect(d.slots, before);
          expect(find.text(l.gridPerDay(fmt.number(8 / 7, decimals: 1))), findsOneWidget);
        });
      }
    }
  }
}
