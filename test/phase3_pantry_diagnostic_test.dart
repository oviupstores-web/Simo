import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menoo/l10n/app_localizations.dart';
import 'package:menoo/models/food_images.dart';
import 'package:menoo/onboarding/onboarding_data.dart';
import 'package:menoo/onboarding/onboarding_scope.dart';
import 'package:menoo/screens/pantry/pantry_add_manual_screen.dart';
import 'package:menoo/screens/pantry/pantry_hub_onboarding_screen.dart';
import 'package:menoo/screens/pantry/pantry_quick_check_screen.dart';
import 'package:menoo/theme/theme.dart';
import 'package:menoo/widgets/widgets.dart';

/// Attentes de sécurité en échec pendant le diagnostic, avant correction autorisée.
/// Les propositions de durée et de remplacement de stock ne sont pas imposées ici.
void main() {
  setUpAll(() async {
    final loader = FontLoader('PlusJakartaSans');
    for (final w in [400, 500, 600, 700, 800]) {
      loader.addFont(Future.value(ByteData.sublistView(File('assets/fonts/PlusJakartaSans-$w.ttf').readAsBytesSync())));
    }
    await loader.load();
  });

  final foods = <String, FoodCategory>{
    'Poireau': FoodCategory.legumes,
    'Poire': FoodCategory.fruits,
    'Laitue': FoodCategory.legumes,
    'Lait': FoodCategory.laitiers,
    'Pommes de terre': FoodCategory.legumes,
    'Pomme': FoodCategory.fruits,
    'Leek': FoodCategory.legumes,
    'Pear': FoodCategory.fruits,
    'Lettuce': FoodCategory.legumes,
    'Milk': FoodCategory.laitiers,
    'Potatoes': FoodCategory.legumes,
    'Apple': FoodCategory.fruits,
    'Lauch': FoodCategory.legumes,
    'Birne': FoodCategory.fruits,
    'Salat': FoodCategory.legumes,
    'Milch': FoodCategory.laitiers,
    'Kartoffeln': FoodCategory.legumes,
    'Apfel': FoodCategory.fruits,
  };
  for (final entry in foods.entries) {
    test('B04/B05 catégorie : ${entry.key}', () {
      expect(FoodCategory.detect(entry.key), entry.value);
    });
  }
  for (final name in ['Poireau', 'Laitue']) {
    test('B04 $name : suggestions du groupe légumes existant, pas une garantie sanitaire', () {
      final c = FoodCategory.detect(name);
      expect((c?.location, c?.shelfDays), (PantryLocation.fridge, 5));
    });
  }
  test('aliment inconnu : pas de classification inventée', () {
    expect(FoodCategory.detect('Tahini'), isNull);
  });

  Future<void> tapText(WidgetTester t, String text) async {
    final f = find.text(text).last;
    await t.ensureVisible(f);
    await t.tap(f);
    await t.pumpAndSettle();
  }

  Future<void> show(
    WidgetTester t,
    OnboardingData data,
    ValueNotifier<Locale> locale,
    Widget screen, {
    double width = 390,
    GlobalKey<NavigatorState>? nav,
  }) async {
    t.view.physicalSize = Size(width, 1400);
    t.view.devicePixelRatio = 1;
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
          home: screen,
        ),
      ),
    );
    await t.pumpAndSettle();
  }

  for (final language in ['fr', 'en', 'de']) {
    final locale = Locale(language);
    final l = lookupL(locale);
    final suggestions = [
      (l.pantrySuggestAvocado, FoodCategory.fruits),
      (l.pantrySuggestFreshSalmon, FoodCategory.viandes),
      (l.pantrySuggestEggs, FoodCategory.laitiers),
      (l.pantrySuggestPasta, FoodCategory.epicerie),
      (l.pantrySuggestPlainYogurt, FoodCategory.laitiers),
      (l.pantrySuggestMilk, FoodCategory.laitiers),
    ];
    for (final s in suggestions) {
      test('B05 $language suggestion ${s.$1} : catégorie cohérente', () {
        expect(FoodCategory.detect(s.$1), s.$2);
      });
    }
    if (language != 'fr') {
      final fr = lookupL(const Locale('fr'));
      final frenchNames = [
        fr.pantrySuggestAvocado,
        fr.pantrySuggestFreshSalmon,
        fr.pantrySuggestEggs,
        fr.pantrySuggestPasta,
        fr.pantrySuggestPlainYogurt,
        fr.pantrySuggestMilk,
      ];
      for (final (index, suggestion) in suggestions.indexed) {
        test('B05 photo existante de ${suggestion.$1} en $language', () {
          expect(FoodImages.forName(suggestion.$1), FoodImages.forName(frenchNames[index]));
        });
      }
    }
    for (final width in [320.0, 390.0]) {
      for (final entry in <String, Widget>{
        'ajout': const PantryAddManualScreen(),
        'vérification rapide': const PantryQuickCheckScreen(),
        'hub': PantryHubOnboardingScreen(onFinish: (_) {}),
      }.entries) {
        testWidgets('responsive $language $width ${entry.key}', (t) async {
          final d = OnboardingData();
          final languages = ValueNotifier(locale);
          addTearDown(d.dispose);
          addTearDown(languages.dispose);
          addTearDown(t.view.reset);
          await show(t, d, languages, entry.value, width: width);
          expect(t.takeException(), isNull);
        });
      }
    }
  }

  for (final destination in ['fr', 'en', 'de']) {
    testWidgets('B06 vérification répétée fr puis $destination : une seule ligne', (t) async {
      final d = OnboardingData();
      final locale = ValueNotifier(const Locale('fr'));
      final nav = GlobalKey<NavigatorState>();
      addTearDown(d.dispose);
      addTearDown(locale.dispose);
      addTearDown(t.view.reset);
      await show(
        t,
        d,
        locale,
        Scaffold(
          body: TextButton(
            onPressed: () =>
                nav.currentState!.push(MaterialPageRoute<void>(builder: (_) => const PantryQuickCheckScreen())),
            child: const Text('open'),
          ),
        ),
        nav: nav,
      );
      for (final language in ['fr', destination]) {
        locale.value = Locale(language);
        await t.pumpAndSettle();
        final l = lookupL(locale.value);
        await tapText(t, 'open');
        await tapText(t, l.quickCheckPastaRice);
        await tapText(t, l.quickCheckAddCount(1));
      }
      expect(d.pantry.length, 1);
      expect(d.pantry.first.location, PantryLocation.pantry);
    });
  }

  for (final destination in ['en', 'de']) {
    testWidgets('B07 unité héritée française affichée en $destination, quantité conservée', (t) async {
      final d = OnboardingData();
      final locale = ValueNotifier(Locale(destination));
      final l = lookupL(locale.value);
      d.pantry.add(
        PantryDraft(
          name: 'Avocat',
          quantity: 2,
          unitLabel: lookupL(const Locale('fr')).unitPieces2,
          location: PantryLocation.fruitBasket,
        ),
      );
      addTearDown(d.dispose);
      addTearDown(locale.dispose);
      addTearDown(t.view.reset);
      await show(t, d, locale, PantryHubOnboardingScreen(onFinish: (_) {}));
      expect(find.text('2 ${l.unitPieces2.replaceAll('(s)', 's')}'), findsOneWidget);
      expect(d.pantry.first.quantity, 2);
    });
    testWidgets('B07 changement fr vers $destination : unité sélectionnée conservée', (t) async {
      final d = OnboardingData();
      final locale = ValueNotifier(const Locale('fr'));
      addTearDown(d.dispose);
      addTearDown(locale.dispose);
      addTearDown(t.view.reset);
      await show(t, d, locale, const PantryAddManualScreen());
      await tapText(t, lookupL(locale.value).unitPieces2);
      locale.value = Locale(destination);
      await t.pumpAndSettle();
      final l = lookupL(locale.value);
      final selected = find.byWidgetPredicate((w) => w is ToggleChip && w.label == l.unitPieces2 && w.selected);
      expect(selected, findsOneWidget);
    });
  }

  for (final location in [PantryLocation.pantry, PantryLocation.freezer]) {
    testWidgets('B06 préserver un produit manuel distinct situé dans ${location.name}', (t) async {
      final d = OnboardingData();
      final locale = ValueNotifier(const Locale('fr'));
      final nav = GlobalKey<NavigatorState>();
      final l = lookupL(locale.value);
      final original = PantryDraft(name: l.quickCheckPastaRice, quantity: 2, unitLabel: 'kg', location: location);
      d.pantry.add(original);
      addTearDown(d.dispose);
      addTearDown(locale.dispose);
      addTearDown(t.view.reset);
      await show(
        t,
        d,
        locale,
        Scaffold(
          body: TextButton(
            onPressed: () =>
                nav.currentState!.push(MaterialPageRoute<void>(builder: (_) => const PantryQuickCheckScreen())),
            child: const Text('open'),
          ),
        ),
        nav: nav,
      );
      await tapText(t, 'open');
      await tapText(t, l.quickCheckPastaRice);
      await tapText(t, l.quickCheckAddCount(1));
      expect(d.pantry.length, 2);
      expect(d.pantry.first, same(original));
      expect((original.quantity, original.unitLabel, original.location), (2.0, 'kg', location));
    });
  }

  testWidgets('R02 calendrier ordinaire validé : aucun incident', (t) async {
    final d = OnboardingData();
    final locale = ValueNotifier(const Locale('fr'));
    addTearDown(d.dispose);
    addTearDown(locale.dispose);
    addTearDown(t.view.reset);
    await show(t, d, locale, const PantryAddManualScreen());
    await tapText(t, lookupL(locale.value).pantryAddPickDate);
    final ok = MaterialLocalizations.of(t.element(find.byType(DatePickerDialog))).okButtonLabel;
    await tapText(t, ok);
    expect(t.takeException(), isNull);
    expect(find.byType(DatePickerDialog), findsNothing);
    expect(find.text(lookupL(locale.value).pantryAddPickDate), findsNothing);
  });

  testWidgets('R02 fermer le formulaire sous le calendrier puis valider : aucun setState après dispose', (t) async {
    final d = OnboardingData();
    final locale = ValueNotifier(const Locale('fr'));
    final nav = GlobalKey<NavigatorState>();
    addTearDown(d.dispose);
    addTearDown(locale.dispose);
    addTearDown(t.view.reset);
    await show(
      t,
      d,
      locale,
      Scaffold(
        body: TextButton(
          onPressed: () =>
              nav.currentState!.push(MaterialPageRoute<void>(builder: (_) => const PantryAddManualScreen())),
          child: const Text('open'),
        ),
      ),
      nav: nav,
    );
    await tapText(t, 'open');
    final route = ModalRoute.of(t.element(find.byType(PantryAddManualScreen)))!;
    await tapText(t, lookupL(locale.value).pantryAddPickDate);
    expect(find.byType(DatePickerDialog), findsOneWidget);
    nav.currentState!.removeRoute(route);
    await t.pumpAndSettle();
    final ok = MaterialLocalizations.of(t.element(find.byType(DatePickerDialog))).okButtonLabel;
    await tapText(t, ok);
    expect(t.takeException(), isNull);
    expect(d.pantry, isEmpty);
  });
}
