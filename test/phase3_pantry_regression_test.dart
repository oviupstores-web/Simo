import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menoo/l10n/app_localizations.dart';
import 'package:menoo/models/food_catalog.dart';
import 'package:menoo/models/food_images.dart';
import 'package:menoo/models/pantry_values.dart';
import 'package:menoo/onboarding/onboarding_data.dart';
import 'package:menoo/onboarding/onboarding_scope.dart';
import 'package:menoo/screens/pantry/pantry_add_manual_screen.dart';
import 'package:menoo/screens/pantry/pantry_hub_onboarding_screen.dart';
import 'package:menoo/screens/pantry/pantry_quick_check_screen.dart';
import 'package:menoo/theme/theme.dart';
import 'package:menoo/widgets/widgets.dart';

void main() {
  setUpAll(() async {
    final loader = FontLoader('PlusJakartaSans');
    for (final w in [400, 500, 600, 700, 800]) {
      loader.addFont(Future.value(ByteData.sublistView(File('assets/fonts/PlusJakartaSans-$w.ttf').readAsBytesSync())));
    }
    await loader.load();
  });

  for (final language in pantryLanguages) {
    final l = lookupL(Locale(language));
    test('$language unités héritées et suggestions : identités stables, valeurs intactes', () {
      final suggestions = FoodCatalog.suggestions(l);
      expect(suggestions.map((s) => FoodCatalog.match(s.$2)?.id), [
        'avocat',
        'saumon',
        'oeuf',
        'pate',
        'yaourt',
        'lait',
      ]);
      for (final s in suggestions) {
        expect(FoodImages.forName(s.$2), s.$1.photo);
      }
      for (final unit in PantryUnit.values) {
        for (final label in [unit.label(l), unit.display(l, 1), unit.display(l, 2), unit.id]) {
          final old = PantryDraft(name: 'nom libre', quantity: 2.75, unitLabel: label, location: PantryLocation.fridge);
          expect(old.unit, unit, reason: '$language $label');
          expect((old.name, old.quantity, old.unitLabel), ('nom libre', 2.75, label));
          for (final target in ['fr', 'en', 'de']) {
            expect(old.displayUnit(lookupL(Locale(target))), unit.display(lookupL(Locale(target)), 2.75));
          }
        }
      }
    });
    test('$language ancienne déclaration : statut modifié sans perdre quantité/unité/date/nom', () {
      final d = OnboardingData();
      addTearDown(d.dispose);
      final date = DateTime(2027, 1, 1);
      final name = QuickCategory.pastaRice.label(l);
      final old = PantryDraft(
        name: name,
        quantity: 3.25,
        unitLabel: QuickStock.present.label(l),
        location: PantryLocation.pantry,
        source: 'verification_rapide',
        expiresOn: date,
      );
      d.pantry.add(old);
      expect(
        d.declareQuickStock(
          QuickCategory.pastaRice,
          PantryLocation.pantry,
          QuickStock.present,
          lookupL(const Locale('de')),
        ),
        isTrue,
      );
      expect(d.pantry.single, same(old));
      for (final stock in [QuickStock.some, QuickStock.present]) {
        expect(
          d.declareQuickStock(QuickCategory.pastaRice, PantryLocation.pantry, stock, lookupL(const Locale('en'))),
          isTrue,
        );
        final updated = d.pantry.single;
        expect(updated.quickStock, stock);
        expect(
          (updated.name, updated.quantity, updated.unitLabel, updated.expiresOn),
          (name, 3.25, old.unitLabel, date),
        );
      }
    });
    test('$language doublons historiques : aucune fusion, suppression ou notification', () {
      final d = OnboardingData();
      addTearDown(d.dispose);
      final first = PantryDraft(
        name: QuickCategory.pastaRice.label(l),
        quantity: 1,
        unitLabel: l.quickCheckInStock,
        location: PantryLocation.pantry,
        source: 'verification_rapide',
      );
      final second = PantryDraft(
        name: QuickCategory.pastaRice.label(lookupL(const Locale('en'))),
        quantity: 2,
        unitLabel: 'in stock',
        location: PantryLocation.pantry,
        source: 'verification_rapide',
      );
      d.pantry.addAll([first, second]);
      var notifications = 0;
      d.addListener(() => notifications++);
      expect(d.declareQuickStock(QuickCategory.pastaRice, PantryLocation.pantry, QuickStock.some, l), isFalse);
      expect(d.pantry, [first, second]);
      expect(notifications, 0);
    });
  }

  test('Réserve : dates civiles au passage heure été/hiver, sans décaler les durées', () {
    for (final start in [DateTime(2026, 10, 24), DateTime(2027, 3, 27)]) {
      final end = DateTime(start.year, start.month, start.day + 30);
      expect(PantryDraft.calendarDaysBetween(start, end), 30);
      expect(PantryDraft.calendarDaysBetween(end, start), -30);
      expect(PantryDraft.calendarDaysBetween(start, start), 0);
    }
  });

  test('stock qualitatif nouveau : pas de quantité ni unité physique inventée', () {
    final d = OnboardingData();
    addTearDown(d.dispose);
    final l = lookupL(const Locale('fr'));
    expect(d.declareQuickStock(QuickCategory.pastaRice, PantryLocation.pantry, QuickStock.present, l), isTrue);
    final first = d.pantry.single;
    expect(first.quantity, isNull);
    expect(first.unit, isNull);
    expect(first.unitLabel, isEmpty);
    expect(d.declareQuickStock(QuickCategory.pastaRice, PantryLocation.pantry, QuickStock.some, l), isTrue);
    expect(d.pantry.length, 1);
    expect(d.pantry.single.quickStock, QuickStock.some);
  });
  test('catégorie rapide dans deux lieux et produits manuels : toujours distincts', () {
    final d = OnboardingData();
    addTearDown(d.dispose);
    final l = lookupL(const Locale('fr'));
    final manual = PantryDraft(
      name: l.quickCheckPastaRice,
      quantity: 2,
      unitLabel: 'kg',
      location: PantryLocation.pantry,
    );
    d.pantry.add(manual);
    for (final location in [PantryLocation.pantry, PantryLocation.freezer]) {
      expect(d.declareQuickStock(QuickCategory.pastaRice, location, QuickStock.present, l), isTrue);
    }
    expect(d.pantry.length, 3);
    expect(d.pantry.first, same(manual));
    expect(d.declareQuickStock(QuickCategory.pastaRice, PantryLocation.pantry, QuickStock.some, l), isTrue);
    expect(d.quickMatches(QuickCategory.pastaRice, PantryLocation.freezer).single.quickStock, QuickStock.present);
  });
  test('unité inconnue : aucun remplacement deviné', () {
    final old = PantryDraft(
      name: 'produit personnel',
      quantity: 7.4,
      unitLabel: 'mon ancien contenant',
      location: PantryLocation.pantry,
    );
    expect(old.unit, isNull);
    expect(old.displayUnit(lookupL(const Locale('de'))), old.unitLabel);
    expect(old.quantity, 7.4);
  });
  test('termes inconnus, mélanges ambigus et préparations : choix manuel', () {
    for (final name in [
      'Tahini',
      'poireau pomme',
      'apple pie',
      'sweet potatoes',
      'milk chocolate',
      'lait d’avoine',
      'oat milk',
      'pommes de terre cuites',
      'pommeau',
    ]) {
      expect(FoodCatalog.match(name), isNull, reason: name);
    }
    final potato = FoodCatalog.match('pommes de terre')!;
    expect(
      (potato.category, potato.suggestedLocation, potato.suggestedDays),
      (FoodCategory.legumes, PantryLocation.pantry, null),
    );
    expect(FoodImages.forName('Yaourt grec'), 'assets/images/ingredients/yaourt_grec.jpg');
  });

  Future<void> tap(WidgetTester t, String text) async {
    await t.ensureVisible(find.text(text).last);
    await t.tap(find.text(text).last);
    await t.pumpAndSettle();
  }

  Future<GlobalKey<NavigatorState>> show(
    WidgetTester t,
    OnboardingData data,
    ValueNotifier<Locale> locale,
    Widget screen,
    double width,
  ) async {
    t.view.physicalSize = Size(width, 1500);
    t.view.devicePixelRatio = 1;
    final nav = GlobalKey<NavigatorState>();
    await t.pumpWidget(
      ValueListenableBuilder<Locale>(
        valueListenable: locale,
        builder: (_, value, _) => MaterialApp(
          navigatorKey: nav,
          theme: AppTheme.light,
          locale: value,
          supportedLocales: L.supportedLocales,
          localizationsDelegates: L.localizationsDelegates,
          builder: (_, child) => OnboardingScope(data: data, child: child!),
          home: Scaffold(
            body: TextButton(
              onPressed: () => nav.currentState!.push(MaterialPageRoute<void>(builder: (_) => screen)),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    await tap(t, 'open');
    return nav;
  }

  testWidgets('Quantité préremplie conservée lors du choix suivant, sans conversion implicite', (t) async {
    final d = OnboardingData();
    final locale = ValueNotifier(const Locale('fr'));
    final l = lookupL(locale.value);
    addTearDown(d.dispose);
    addTearDown(locale.dispose);
    addTearDown(t.view.reset);
    await show(t, d, locale, const PantryAddManualScreen(), 390);
    await tap(t, l.pantrySuggestFreshSalmon);
    expect(t.widget<QuantityStepper>(find.byType(QuantityStepper)).value, '200');
    await tap(t, l.pantrySuggestMilk);
    expect(t.widget<QuantityStepper>(find.byType(QuantityStepper)).value, '200');
    await tap(t, l.pantryAddSubmit);
    expect((d.pantry.single.quantity, d.pantry.single.unit), (200.0, PantryUnit.liter));
  });

  for (final language in ['fr', 'en', 'de']) {
    for (final width in [320.0, 390.0]) {
      final l = lookupL(Locale(language));
      testWidgets('$language $width ambiguïté historique : message traduit, aucun ajout partiel', (t) async {
        final d = OnboardingData();
        final locale = ValueNotifier(Locale(language));
        addTearDown(d.dispose);
        addTearDown(locale.dispose);
        addTearDown(t.view.reset);
        final old = [
          for (var i = 0; i < 2; i++)
            PantryDraft(
              name: l.quickCheckPastaRice,
              quantity: i + 1,
              unitLabel: l.quickCheckInStock,
              location: PantryLocation.pantry,
              source: 'verification_rapide',
            ),
        ];
        d.pantry.addAll(old);
        await show(t, d, locale, const PantryQuickCheckScreen(), width);
        await tap(t, l.quickCheckFruit);
        await tap(t, l.quickCheckPastaRice);
        await tap(t, l.quickCheckAddCount(2));
        expect(find.text(l.quickCheckAmbiguousStock(l.quickCheckPastaRice)), findsOneWidget);
        expect(d.pantry, old);
        expect(t.takeException(), isNull);
      });
      testWidgets('$language $width pomme de terre : placard, aucune date ; date explicite préservée', (t) async {
        final d = OnboardingData();
        final locale = ValueNotifier(Locale(language));
        addTearDown(d.dispose);
        addTearDown(locale.dispose);
        addTearDown(t.view.reset);
        await show(t, d, locale, const PantryAddManualScreen(), width);
        await t.enterText(find.byType(TextField).first, 'pommes de terre');
        await t.pumpAndSettle();
        expect(find.text(l.pantryAddPickDate), findsOneWidget);
        expect(
          find.byWidgetPredicate((w) => w is OptionTile && w.label == l.locationPantry && w.selected),
          findsOneWidget,
        );
        await tap(t, l.pantryAdd1Week);
        await t.enterText(find.byType(TextField).first, 'laitue');
        await t.pumpAndSettle();
        await t.enterText(find.byType(TextField).first, 'pommes de terre');
        await t.pumpAndSettle();
        await tap(t, l.pantryAddSubmit);
        final saved = d.pantry.single;
        expect(saved.name, 'pommes de terre');
        expect(saved.foodId, 'potato');
        expect(saved.expiryOrigin, ExpiryOrigin.userProvided);
        expect(saved.daysLeft, 7);
        expect(saved.location, PantryLocation.pantry);
        expect(t.takeException(), isNull);
      });
      testWidgets('$language $width date estimée : origine et affichage conservés', (t) async {
        final d = OnboardingData();
        final locale = ValueNotifier(Locale(language));
        addTearDown(d.dispose);
        addTearDown(locale.dispose);
        addTearDown(t.view.reset);
        final nav = await show(t, d, locale, const PantryAddManualScreen(), width);
        await t.enterText(find.byType(TextField).first, 'poireau');
        await t.pumpAndSettle();
        await tap(t, l.pantryAddSubmit);
        expect(d.pantry.single.expiryOrigin, ExpiryOrigin.estimated);
        expect(d.pantry.single.daysLeft, 5);
        nav.currentState!.push(MaterialPageRoute<void>(builder: (_) => PantryHubOnboardingScreen(onFinish: (_) {})));
        await t.pumpAndSettle();
        expect(find.text(l.pantryAddExpiryEstimated), findsOneWidget);
        expect(find.text(l.freshnessFresh), findsNothing);
        expect(t.takeException(), isNull);
      });
      testWidgets('$language $width changements de statut réels : Présent, restes, Présent sans doublon', (t) async {
        final d = OnboardingData();
        final locale = ValueNotifier(Locale(language));
        addTearDown(d.dispose);
        addTearDown(locale.dispose);
        addTearDown(t.view.reset);
        await show(t, d, locale, const PantryQuickCheckScreen(), width);
        await tap(t, l.quickCheckPastaRice);
        await tap(t, l.quickCheckAddCount(1));
        for (final clicks in [2, 1]) {
          await tap(t, 'open');
          for (var i = 0; i < clicks; i++) {
            await tap(t, l.quickCheckPastaRice);
          }
          await tap(t, l.quickCheckAddCount(1));
          expect(d.pantry.length, 1);
          expect(d.pantry.single.quickStock, clicks == 2 ? QuickStock.some : QuickStock.present);
          expect(d.pantry.single.quantity, isNull);
        }
        expect(t.takeException(), isNull);
      });
      testWidgets('$language $width unités et langue : quantité inchangée, nom libre conservé', (t) async {
        final d = OnboardingData();
        final locale = ValueNotifier(Locale(language));
        addTearDown(d.dispose);
        addTearDown(locale.dispose);
        addTearDown(t.view.reset);
        await show(t, d, locale, const PantryAddManualScreen(), width);
        await t.enterText(find.byType(TextField).first, 'mon aliment personnel');
        await t.pumpAndSettle();
        await tap(t, l.locationPantry);
        t.widget<QuantityStepper>(find.byType(QuantityStepper)).onPlus();
        await t.pumpAndSettle();
        expect(t.widget<QuantityStepper>(find.byType(QuantityStepper)).value, '2');
        await tap(t, 'g');
        locale.value = Locale(language == 'en' ? 'de' : 'en');
        await t.pumpAndSettle();
        expect(t.widget<QuantityStepper>(find.byType(QuantityStepper)).value, '2');
        await tap(t, lookupL(locale.value).pantryAddSubmit);
        final saved = d.pantry.single;
        expect(
          (saved.name, saved.quantity, saved.unit, saved.unitLabel),
          ('mon aliment personnel', 2.0, PantryUnit.gram, 'gram'),
        );
        expect(saved.foodId, isNull);
        expect(t.takeException(), isNull);
      });
      testWidgets('$language $width emplacement manuel conservé lors du changement d’aliment', (t) async {
        final d = OnboardingData();
        final locale = ValueNotifier(Locale(language));
        addTearDown(d.dispose);
        addTearDown(locale.dispose);
        addTearDown(t.view.reset);
        await show(t, d, locale, const PantryAddManualScreen(), width);
        await t.enterText(find.byType(TextField).first, 'pomme');
        await t.pumpAndSettle();
        await tap(t, l.locationFreezer);
        await tap(t, l.pantryAdd1Month);
        await t.enterText(find.byType(TextField).first, 'pommes de terre');
        await t.pumpAndSettle();
        await tap(t, l.pantryAddSubmit);
        expect(d.pantry.single.location, PantryLocation.freezer);
        expect(d.pantry.single.daysLeft, 30);
        expect(d.pantry.single.expiryOrigin, ExpiryOrigin.userProvided);
        expect(t.takeException(), isNull);
      });
      testWidgets('$language $width Non : aucun stock supprimé', (t) async {
        final d = OnboardingData();
        final locale = ValueNotifier(Locale(language));
        addTearDown(d.dispose);
        addTearDown(locale.dispose);
        addTearDown(t.view.reset);
        d.declareQuickStock(QuickCategory.pastaRice, PantryLocation.pantry, QuickStock.present, l);
        final old = d.pantry.single;
        await show(t, d, locale, const PantryQuickCheckScreen(), width);
        for (var i = 0; i < 3; i++) {
          await tap(t, l.quickCheckPastaRice);
        }
        await tap(t, l.quickCheckSkip);
        expect(d.pantry.single, same(old));
        expect(t.takeException(), isNull);
      });
    }
    testWidgets('$language calendrier annulé : aucune date ou donnée créée', (t) async {
      final l = lookupL(Locale(language));
      final d = OnboardingData();
      final locale = ValueNotifier(Locale(language));
      addTearDown(d.dispose);
      addTearDown(locale.dispose);
      addTearDown(t.view.reset);
      await show(t, d, locale, const PantryAddManualScreen(), 390);
      await tap(t, l.pantryAddPickDate);
      final cancel = MaterialLocalizations.of(t.element(find.byType(DatePickerDialog))).cancelButtonLabel;
      await tap(t, cancel);
      expect(find.text(l.pantryAddPickDate), findsOneWidget);
      expect(d.pantry, isEmpty);
      expect(t.takeException(), isNull);
    });
  }
}
