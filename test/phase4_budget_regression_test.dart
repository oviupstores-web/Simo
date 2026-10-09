import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menoo/l10n/app_languages.dart';
import 'package:menoo/l10n/app_localizations.dart';
import 'package:menoo/l10n/formats.dart';
import 'package:menoo/l10n/locale_scope.dart';
import 'package:menoo/main.dart';
import 'package:menoo/onboarding/onboarding_data.dart';
import 'package:menoo/onboarding/onboarding_scope.dart';
import 'package:menoo/screens/entry/startup_screen.dart';
import 'package:menoo/screens/onboarding/budget_screen.dart';
import 'package:menoo/screens/onboarding/summary_screen.dart';
import 'package:menoo/theme/theme.dart';
import 'package:menoo/widgets/widgets.dart';

void main() {
  setUpAll(() async {
    final fonts = FontLoader('PlusJakartaSans');
    for (final weight in [400, 500, 600, 700, 800]) {
      fonts.addFont(
        Future.value(ByteData.sublistView(File('assets/fonts/PlusJakartaSans-$weight.ttf').readAsBytesSync())),
      );
    }
    await fonts.load();
  });

  const countries = {
    'FR': 'EUR',
    'DE': 'EUR',
    'BE': 'EUR',
    'GB': 'GBP',
    'US': 'USD',
    'CA': 'CAD',
    'AU': 'AUD',
    'CH': 'CHF',
  };
  for (final entry in countries.entries) {
    test('${entry.key} : nouveau budget associé à sa devise, pas de conversion', () {
      final d = OnboardingData();
      addTearDown(d.dispose);
      final fmt = Formats(Locale('fr', entry.key));
      d.initializeBudgetCurrency(fmt.currency);
      expect((d.budgetEuros, d.budgetCurrencyCode), (65, entry.value));
      d.initializeBudgetCurrency('USD');
      expect((d.budgetEuros, d.budgetCurrencyCode), (65, entry.value));
    });
  }
  test('ancien montant sans devise : montant préservé et aucune attribution par région', () {
    final d = OnboardingData();
    addTearDown(d.dispose);
    d.restoreBudget(amount: 87);
    for (final code in ['EUR', 'USD', 'CAD', 'AUD']) {
      d.initializeBudgetCurrency(code);
    }
    expect((d.budgetEuros, d.budgetCurrencyCode, d.budgetCurrencyUnknown), (87, null, true));
    d.startMode(AppMode.foyer);
    d.setCount(MemberRole.enfant, 3);
    expect(d.budgetEuros, 87);
    d.confirmBudgetCurrency('CAD');
    expect((d.budgetEuros, d.budgetCurrencyCode), (87, 'CAD'));
    expect(() => d.confirmBudgetCurrency('USD'), throwsStateError);
    expect((d.budgetEuros, d.budgetCurrencyCode), (87, 'CAD'));
  });
  test('affectation via ancienne API sans devise : pas de réinterprétation silencieuse', () {
    final d = OnboardingData()..budgetEuros = 143;
    addTearDown(d.dispose);
    d.initializeBudgetCurrency('EUR');
    expect(d.budgetCurrencyUnknown, isTrue);
    expect(d.budgetCurrencyCode, isNull);
    expect(d.budgetEuros, 143);
  });
  test('ancien budget connu : changement de région ne change ni montant ni code', () {
    final d = OnboardingData();
    addTearDown(d.dispose);
    d.restoreBudget(amount: 91, currency: 'GBP');
    d.initializeBudgetCurrency('CAD');
    d.startMode(AppMode.foyer);
    expect((d.budgetEuros, d.budgetCurrencyCode), (91, 'GBP'));
    expect(Formats(const Locale('fr', 'CA'), currency: d.budgetCurrencyCode).priceWhole(d.budgetEuros), contains('91'));
  });

  Future<void> tap(WidgetTester t, String value) async {
    await t.ensureVisible(find.text(value).last);
    await t.tap(find.text(value).last);
    await t.pumpAndSettle();
  }

  Future<void> show(WidgetTester t, OnboardingData d, ValueNotifier<Locale> locale, Widget screen, double width) async {
    t.view.physicalSize = Size(width, 1500);
    t.view.devicePixelRatio = 1;
    await t.pumpWidget(
      ValueListenableBuilder<Locale>(
        valueListenable: locale,
        builder: (_, value, _) => MaterialApp(
          theme: AppTheme.light,
          locale: value,
          supportedLocales: L.supportedLocales,
          localizationsDelegates: L.localizationsDelegates,
          localeResolutionCallback: (requested, _) => AppLanguages.resolve(requested, requested),
          builder: (_, child) => OnboardingScope(data: d, child: child!),
          home: screen,
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
  }

  testWidgets('budget hérité sous la borne : conservé, confirmation sans contournement', (t) async {
    final d = OnboardingData()..restoreBudget(amount: 7, currency: 'CAD');
    final locale = ValueNotifier(const Locale('fr', 'CA'));
    addTearDown(d.dispose);
    addTearDown(locale.dispose);
    addTearDown(t.view.reset);
    await show(t, d, locale, const BudgetScreen(), 320);
    expect(d.budgetEuros, 7);
    expect(t.widget<OnboardingStepScaffold>(find.byType(OnboardingStepScaffold)).onContinue, isNull);
    await t.enterText(find.byType(TextField).first, '20');
    await t.pumpAndSettle();
    expect((d.budgetEuros, d.budgetCurrencyCode), (20, 'CAD'));
    expect(t.widget<OnboardingStepScaffold>(find.byType(OnboardingStepScaffold)).onContinue, isNotNull);
  });

  testWidgets('grand entier hérité : montant exact conservé sans exception à 320 px', (t) async {
    const original = 9223372036854775807;
    final d = OnboardingData()..restoreBudget(amount: original, currency: 'CAD');
    final locale = ValueNotifier(const Locale('de', 'CH'));
    addTearDown(d.dispose);
    addTearDown(locale.dispose);
    addTearDown(t.view.reset);
    expect(Formats(locale.value, currency: 'CAD').priceWhole(original), '$original CAD');
    await show(t, d, locale, const BudgetScreen(), 320);
    expect((d.budgetEuros, d.budgetCurrencyCode), (original, 'CAD'));
    expect(t.takeException(), isNull);
  });

  for (final language in ['fr', 'en', 'de']) {
    for (final width in [320.0, 390.0]) {
      final l = lookupL(Locale(language));
      testWidgets('$language $width budget hérité : confirmation explicite, pas de devise présélectionnée', (t) async {
        final d = OnboardingData();
        d.restoreBudget(amount: 87);
        final locale = ValueNotifier(Locale(language, 'CA'));
        addTearDown(d.dispose);
        addTearDown(locale.dispose);
        addTearDown(t.view.reset);
        await show(t, d, locale, const BudgetScreen(), width);
        expect(d.budgetCurrencyCode, isNull);
        expect(find.text(l.budgetInheritedUnknown('87')), findsOneWidget);
        expect(t.widget<OnboardingStepScaffold>(find.byType(OnboardingStepScaffold)).onContinue, isNull);
        await tap(t, l.budgetConfirmCurrency);
        expect(t.widget<DropdownButton<String>>(find.byType(DropdownButton<String>)).value, isNull);
        await tap(t, l.budgetCurrencyCancel);
        expect((d.budgetEuros, d.budgetCurrencyCode), (87, null));
        await tap(t, l.budgetConfirmCurrency);
        await t.tap(find.byType(DropdownButton<String>));
        await t.pumpAndSettle();
        await tap(t, 'CAD');
        await tap(t, l.budgetCurrencyConfirm);
        expect((d.budgetEuros, d.budgetCurrencyCode), (87, 'CAD'));
        locale.value = Locale(language, 'AU');
        await t.pumpAndSettle();
        expect((d.budgetEuros, d.budgetCurrencyCode), (87, 'CAD'));
        expect(t.takeException(), isNull);
      });
      testWidgets('$language $width saisies entières/invalides : dernier budget et code conservés', (t) async {
        final d = OnboardingData();
        final locale = ValueNotifier(Locale(language, 'AU'));
        addTearDown(d.dispose);
        addTearDown(locale.dispose);
        addTearDown(t.view.reset);
        await show(t, d, locale, const BudgetScreen(), width);
        for (final value in ['20', '350', '420', '10000']) {
          await t.enterText(find.byType(TextField).first, value);
          await t.pumpAndSettle();
          expect((d.budgetEuros, d.budgetCurrencyCode), (int.parse(value), 'AUD'));
          expect(t.takeException(), isNull);
        }
        for (final value in ['65,50', '65.50', 'NaN', 'Infinity', '-30', '19', '1,000', '9999999999999999999999999']) {
          await t.enterText(find.byType(TextField).first, value);
          await t.pumpAndSettle();
          expect((d.budgetEuros, d.budgetCurrencyCode), (10000, 'AUD'));
          expect(t.widget<OnboardingStepScaffold>(find.byType(OnboardingStepScaffold)).onContinue, isNull);
          expect(t.takeException(), isNull);
        }
        await t.enterText(find.byType(TextField).first, '87');
        await t.pumpAndSettle();
        expect((d.budgetEuros, d.budgetCurrencyCode), (87, 'AUD'));
        expect(t.widget<OnboardingStepScaffold>(find.byType(OnboardingStepScaffold)).onContinue, isNotNull);
      });
      testWidgets('$language $width récapitulatif hérité : pas de devise inventée', (t) async {
        final d = OnboardingData()..goal = HealthGoal.maintien;
        d.restoreBudget(amount: 87);
        final locale = ValueNotifier(Locale(language, 'US'));
        addTearDown(d.dispose);
        addTearDown(locale.dispose);
        addTearDown(t.view.reset);
        await show(t, d, locale, const SummaryScreen(), width);
        expect(d.budgetCurrencyCode, isNull);
        expect(find.textContaining('87 —'), findsOneWidget);
        await tap(t, l.summaryGenerateSolo);
        expect(find.byType(BudgetScreen), findsOneWidget);
        expect((d.budgetEuros, d.budgetCurrencyCode), (87, null));
        expect(t.takeException(), isNull);
      });
      testWidgets('$language $width devise explicite au récapitulatif malgré une région différente', (t) async {
        final d = OnboardingData()..goal = HealthGoal.maintien;
        d.restoreBudget(amount: 87, currency: 'CAD');
        final locale = ValueNotifier(Locale(language, 'US'));
        addTearDown(d.dispose);
        addTearDown(locale.dispose);
        addTearDown(t.view.reset);
        await show(t, d, locale, const SummaryScreen(), width);
        expect(find.textContaining('CAD'), findsOneWidget);
        expect((d.budgetEuros, d.budgetCurrencyCode), (87, 'CAD'));
        expect(t.takeException(), isNull);
      });
    }
  }

  testWidgets('MenooApp : Canada français, changement de langue/région, montant et devise conservés', (t) async {
    t.view.physicalSize = const Size(390, 1500);
    t.view.devicePixelRatio = 1;
    t.platformDispatcher.localesTestValue = [const Locale('en', 'CA')];
    addTearDown(t.platformDispatcher.clearLocalesTestValue);
    addTearDown(t.view.reset);
    await t.pumpWidget(const MenooApp());
    await t.pump();
    final context = t.element(find.byType(MenooStartup));
    final d = OnboardingScope.read(context);
    d.budgetEuros = 87;
    LocaleScope.of(t.element(find.byType(MaterialApp))).value = const Locale('fr');
    await t.pump();
    await t.pump();
    expect(Localizations.localeOf(context), const Locale('fr', 'CA'));
    expect((d.budgetEuros, d.budgetCurrencyCode), (87, 'CAD'));
    t.platformDispatcher.localesTestValue = [const Locale('en', 'AU')];
    await t.pump();
    await t.pump();
    expect(Localizations.localeOf(context), const Locale('fr', 'AU'));
    expect((d.budgetEuros, d.budgetCurrencyCode), (87, 'CAD'));
  });
}
