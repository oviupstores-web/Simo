import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menoo/l10n/app_localizations.dart';
import 'package:menoo/l10n/app_languages.dart';
import 'package:menoo/l10n/locale_scope.dart';
import 'package:menoo/local_storage/draft_database.dart';
import 'package:menoo/local_storage/draft_key.dart';
import 'package:menoo/local_storage/local_draft.dart';
import 'package:menoo/local_storage/solo_draft_repository.dart';
import 'package:menoo/onboarding/onboarding_data.dart';
import 'package:menoo/onboarding/onboarding_flow.dart';
import 'package:menoo/onboarding/onboarding_scope.dart';
import 'package:menoo/onboarding/solo_draft_session.dart';
import 'package:menoo/onboarding/solo_draft_navigation.dart';
import 'package:menoo/screens/entry/landing_screen.dart';
import 'package:menoo/screens/onboarding/profile_screen.dart';
import 'package:menoo/screens/onboarding/budget_screen.dart';
import 'package:menoo/screens/onboarding/constraints_screen.dart';
import 'package:menoo/theme/theme.dart';
import 'package:menoo/main.dart';

class FakeSoloStore implements SoloDraftRepository {
  LocalDraft? value;
  bool failLoad = false;
  bool failSave = false;
  @override
  Future<LocalDraft?> load() async {
    if (failLoad) throw const DraftStorageException('synthetic_failure');
    return value;
  }

  @override
  Future<void> save(LocalDraft draft) async {
    if (failSave) throw const DraftStorageException('synthetic_failure');
    value = LocalDraft.decode(draft.encode());
  }

  @override
  Future<void> close() async {}
}

class FixtureKeys implements DraftKeyStore {
  String? value;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String key) async {
    value = key;
  }
}

OnboardingData source() {
  final d = OnboardingData();
  d.initializeBudgetCurrency('CAD');
  d.update(() {
    d.goal = HealthGoal.maintien;
    d.sex = Sex.femme;
    d.age = 37;
    d.heightCm = 168;
    d.weightKg = 67.25;
    d.weeklyRateKg = 0.25;
    d.activity = ActivityLevel.actif;
    d.wantsScale = true;
    d.slots
      ..clear()
      ..addAll({(2, MealType.diner), (5, MealType.dejeuner)});
    d.budgetEuros = 190;
    d.budgetEdited = true;
    d.management = ManagementMode.courses;
    d.diets.addAll({'vegan', 'sans_gluten', 'future_restriction'});
    d.allergens.addAll({'crustaces', 'mollusques', 'future_allergen'});
    d.excludedFoods.addAll(['Synthetic exclusion']);
    d.cuisinePreferences.addAll({'italienne', 'japonaise'});
    d.cookingLevel = CookingLevel.confirme;
    d.weekdayMinutes = 15;
    d.weekendMinutes = 60;
    d.equipment
      ..clear()
      ..addAll({'four', 'robot', 'future_equipment'});
  });
  d.soloInputs.addAll({
    'profile.age': '3',
    'profile.height': '',
    'profile.weight': '67,',
    'profile.target': '-',
    'budget.custom': '65,',
    'constraints.food': 'synthetic unfinished',
  });
  return d;
}

List<Map<String, Object?>> stackFor(int step) => [
  for (final name in soloStepNames.take(step)) {'step': name, 'editing': false},
];

Future<LocalDraft> snapshot(FakeSoloStore store, int step) async {
  final session = SoloDraftSession(source(), store);
  await session.initialize();
  session.checkpoint(stackFor(step), visibleSolo: true, pantryDetour: false);
  session.markCompleted(soloStepNames[step - 1]);
  expect(await session.flush(), isTrue);
  await session.close();
  session.data.dispose();
  session.dispose();
  return store.value!;
}

Widget harness(
  SoloDraftSession session,
  SoloDraftRouteObserver observer,
  ValueNotifier<Locale?> language,
  ValueNotifier<bool> startupDone,
) => LocaleScope(
  controller: language,
  child: ValueListenableBuilder<Locale?>(
    valueListenable: language,
    builder: (_, locale, _) => MaterialApp(
      theme: AppTheme.light,
      locale: locale,
      supportedLocales: AppLanguages.launchLocales,
      localizationsDelegates: L.localizationsDelegates,
      navigatorObservers: [observer],
      builder: (_, child) => OnboardingScope(data: session.data, soloDraft: session, child: child!),
      home: SoloDraftResumeHost(
        session: session,
        observer: observer,
        startupDone: startupDone,
        child: const LandingScreen(),
      ),
    ),
  ),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final loader = FontLoader('PlusJakartaSans');
    for (final weight in [400, 500, 600, 700, 800]) {
      loader.addFont(
        Future.value(ByteData.sublistView(File('assets/fonts/PlusJakartaSans-$weight.ttf').readAsBytesSync())),
      );
    }
    await loader.load();
  });

  for (var step = 1; step <= 11; step++) {
    test('encrypted Solo checkpoint $step restores all accepted and raw sources; Family untouched', () async {
      final dir = await Directory.systemTemp.createTemp('menoo_solo_');
      final file = File('${dir.path}/draft.sqlite');
      final keys = FixtureKeys();
      try {
        final seed = await DraftDatabase.open(file, keys);
        final family = LocalDraft(
          id: SoloDraftRepository.familyId,
          journey: DraftJourney.family,
          step: 3,
          management: DraftManagement.mixed,
          updatedAt: DateTime.utc(2026),
          answers: {'syntheticFamily': true},
          pantry: [],
        );
        await seed.save(family);
        await seed.close();
        final initial = source();
        final expected = initial.exportSoloAnswers();
        final session = SoloDraftSession(initial, EncryptedSoloDraftRepository(() => DraftDatabase.open(file, keys)));
        await session.initialize();
        session.checkpoint(stackFor(step), visibleSolo: true, pantryDetour: false);
        session.markCompleted(soloStepNames[step - 1]);
        expect(await session.flush(), isTrue);
        await session.close();
        session.dispose();
        final restored = SoloDraftSession(
          OnboardingData(),
          EncryptedSoloDraftRepository(() => DraftDatabase.open(file, keys)),
        );
        await restored.initialize();
        expect(restored.errorStage, isNull);
        expect(restored.currentStep, step);
        expect(restored.data.exportSoloAnswers(), expected);
        expect(restored.data.soloInputs, initial.soloInputs);
        expect(restored.completedSteps, contains(soloStepNames[step - 1]));
        await restored.close();
        restored.data.dispose();
        restored.dispose();
        final verify = await DraftDatabase.open(file, keys);
        expect((await verify.load(SoloDraftRepository.familyId))!.encode(), family.encode());
        await verify.close();
        initial.dispose();
      } finally {
        await dir.delete(recursive: true);
      }
    });
  }

  test('load failure never overwrites a draft; retry preserves exact raw inputs', () async {
    final store = FakeSoloStore();
    final original = await snapshot(store, 2);
    store.failLoad = true;
    final session = SoloDraftSession(OnboardingData(), store);
    await session.initialize();
    expect(await session.enter(), isFalse);
    session.data.update(() => session.data.age = 55);
    expect(store.value!.encode(), original.encode());
    expect(session.errorStage, 'load');
    store.failLoad = false;
    expect(await session.enter(), isTrue);
    expect(session.data.age, 37);
    expect(session.data.soloInputs['profile.age'], '3');
    await session.close();
    session.data.dispose();
    session.dispose();
  });

  test('write failure keeps latest pending snapshot and retries without resetting values', () async {
    final store = FakeSoloStore();
    final session = SoloDraftSession(source(), store);
    await session.initialize();
    session.checkpoint(stackFor(2), visibleSolo: true, pantryDetour: false);
    await session.flush();
    final before = store.value!.encode();
    store.failSave = true;
    session.data.setSoloInput('profile.age', '');
    expect(await session.flush(), isFalse);
    expect(session.errorStage, 'save');
    expect(store.value!.encode(), before);
    expect(session.data.age, 37);
    store.failSave = false;
    expect(await session.flush(), isTrue);
    expect(store.value!.answers['rawInputs'], containsPair('profile.age', ''));
    expect(session.errorStage, isNull);
    await session.close();
    session.data.dispose();
    session.dispose();
  });

  test('Family changes never replace Solo answers and return restores Solo', () async {
    final store = FakeSoloStore();
    final session = SoloDraftSession(source(), store);
    await session.initialize();
    session.checkpoint(stackFor(6), visibleSolo: true, pantryDetour: false);
    await session.flush();
    final expected = store.value!.answers['acceptedAnswers'];
    session.data.startMode(AppMode.foyer);
    session.data.update(() {
      session.data.budgetEuros = 300;
      session.data.diets.add('family_only');
    });
    await session.flush();
    expect(store.value!.answers['acceptedAnswers'], expected);
    expect(store.value!.answers['resumeRequested'], isFalse);
    session.data.startMode(AppMode.solo);
    expect(await session.enter(), isTrue);
    expect(session.data.budgetEuros, 190);
    expect(session.data.diets, isNot(contains('family_only')));
    await session.close();
    session.data.dispose();
    session.dispose();
  });

  test('unknown format refuses restoration atomically and preserves bytes', () async {
    final store = FakeSoloStore();
    final draft = await snapshot(store, 4);
    final answer = draft.answers;
    answer['soloPayloadVersion'] = 99;
    store.value = LocalDraft(
      id: draft.id,
      journey: draft.journey,
      step: draft.step,
      management: draft.management,
      currency: draft.currency,
      updatedAt: draft.updatedAt,
      answers: answer,
      pantry: [],
    );
    final before = store.value!.encode();
    final data = OnboardingData();
    final original = data.exportSoloAnswers();
    final session = SoloDraftSession(data, store);
    await session.initialize();
    expect(session.errorStage, 'load');
    expect(data.exportSoloAnswers(), original);
    expect(store.value!.encode(), before);
    await session.close();
    data.dispose();
    session.dispose();
  });

  test('unknown inherited currency is not inferred from a new locale', () async {
    final store = FakeSoloStore();
    final d = OnboardingData();
    d.budgetEuros = 77;
    final s = SoloDraftSession(d, store);
    await s.initialize();
    s.checkpoint(stackFor(6), visibleSolo: true, pantryDetour: false);
    await s.flush();
    await s.close();
    final restart = SoloDraftSession(OnboardingData(), store);
    await restart.initialize();
    restart.data.initializeBudgetCurrency('USD');
    expect(restart.data.budgetEuros, 77);
    expect(restart.data.budgetCurrencyUnknown, isTrue);
    expect(store.value!.currency, 'XXX');
    await restart.close();
    d.dispose();
    s.dispose();
    restart.data.dispose();
    restart.dispose();
  });

  test('fresh process restores full Solo snapshot after a forced interruption offline', () async {
    final directory = await Directory.systemTemp.createTemp('menoo_solo_process_');
    final file = File('${directory.path}/draft.sqlite');
    final keys = FixtureKeys();
    try {
      final session = SoloDraftSession(source(), EncryptedSoloDraftRepository(() => DraftDatabase.open(file, keys)));
      await session.initialize();
      session.checkpoint(stackFor(8), visibleSolo: true, pantryDetour: false);
      await session.flush();
      await session.close();
      session.data.dispose();
      session.dispose();
      final db = await DraftDatabase.open(file, keys);
      final expected = (await db.load(SoloDraftRepository.soloId))!.encode();
      await db.close();
      final keyFile = File('${directory.path}/synthetic-key.txt');
      await keyFile.writeAsString(keys.value!);
      final expectedFile = File('${directory.path}/synthetic-expected.json');
      await expectedFile.writeAsString(expected);
      final dart = Platform.environment['MENOO_TEST_DART'];
      expect(dart, isNotNull);
      final child = await Process.start(dart!, [
        'run',
        'test/support/solo_draft_process_probe.dart',
        file.path,
        keyFile.path,
        'crash',
        expectedFile.path,
      ]);
      final ready = Completer<void>();
      final out = child.stdout.transform(utf8.decoder).transform(const LineSplitter()).listen((line) {
        if (line == 'solo-transaction-pending' && !ready.isCompleted) ready.complete();
      });
      final err = child.stderr.listen((_) {});
      try {
        await ready.future.timeout(const Duration(seconds: 50));
        child.kill();
        await child.exitCode.timeout(const Duration(seconds: 10));
      } finally {
        child.kill();
        await out.cancel();
        await err.cancel();
      }
      final restart = await Process.run(dart, [
        'run',
        'test/support/solo_draft_process_probe.dart',
        file.path,
        keyFile.path,
        'restore',
        expectedFile.path,
      ]);
      expect(restart.exitCode, 0);
      expect(restart.stdout, contains('solo-restored-offline'));
      final restored = SoloDraftSession(
        OnboardingData(),
        EncryptedSoloDraftRepository(() => DraftDatabase.open(file, keys)),
      );
      await restored.initialize();
      expect(restored.currentStep, 8);
      expect(restored.data.soloInputs['profile.age'], '3');
      expect(restored.data.age, 37);
      expect(restored.data.budgetCurrencyCode, 'CAD');
      await restored.close();
      restored.data.dispose();
      restored.dispose();
    } finally {
      await directory.delete(recursive: true);
    }
  }, timeout: const Timeout(Duration(minutes: 2)));

  for (final locale in AppLanguages.launchLocales) {
    for (var step = 1; step <= 11; step++) {
      testWidgets('${locale.languageCode} resume real Solo screen $step with unchanged sources', (t) async {
        t.view.physicalSize = const Size(390, 844);
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.reset);
        final store = FakeSoloStore();
        await snapshot(store, step);
        final session = SoloDraftSession(OnboardingData(), store);
        await session.initialize();
        final observer = SoloDraftRouteObserver(session);
        final language = ValueNotifier<Locale?>(locale);
        final ready = ValueNotifier(true);
        await t.pumpWidget(harness(session, observer, language, ready));
        await t.pumpAndSettle();
        expect(session.currentStep, step);
        expect(find.byType(OnboardingFlow.screenFor(OnboardingFlow.solo[step - 1]).runtimeType), findsOneWidget);
        expect(session.data.budgetCurrencyCode, 'CAD');
        expect(session.data.age, 37);
        if (step == 2) {
          final controllers = t.widgetList<TextField>(find.byType(TextField)).map((w) => w.controller?.text).toList();
          expect(controllers, containsAll(['3', '', '67,']));
        }
        if (step == 6) expect(find.text('65,'), findsOneWidget);
        if (step == 8) expect(find.text('synthetic unfinished'), findsOneWidget);
        expect(t.takeException(), isNull);
        await t.pumpWidget(const SizedBox());
        await session.close();
        session.data.dispose();
        session.dispose();
        language.dispose();
        ready.dispose();
      });
    }
  }

  testWidgets('raw profile survives language changes and back navigation without validating it', (t) async {
    final store = FakeSoloStore();
    await snapshot(store, 2);
    final session = SoloDraftSession(OnboardingData(), store);
    await session.initialize();
    final language = ValueNotifier<Locale?>(const Locale('fr'));
    final ready = ValueNotifier(true);
    await t.pumpWidget(harness(session, SoloDraftRouteObserver(session), language, ready));
    await t.pumpAndSettle();
    final age = find.byType(TextField).first;
    await t.enterText(age, '');
    await t.pump();
    for (final locale in AppLanguages.launchLocales) {
      language.value = locale;
      await t.pumpAndSettle();
      expect(t.widget<TextField>(find.byType(TextField).first).controller!.text, '');
    }
    final context = t.element(find.byType(ProfileScreen));
    Navigator.of(context).pop();
    await t.pumpAndSettle();
    expect(session.currentStep, 1);
    expect(await session.flush(), isTrue);
    expect((store.value!.answers['rawInputs'] as Map)['profile.age'], '');
    expect((store.value!.answers['acceptedAnswers'] as Map)['age'], 37);
    await t.pumpWidget(const SizedBox());
    await session.close();
    session.data.dispose();
    session.dispose();
    language.dispose();
    ready.dispose();
  });

  testWidgets('production MenooApp restores Solo only after the existing splash completes', (t) async {
    t.view.physicalSize = const Size(390, 844);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    final store = FakeSoloStore();
    await snapshot(store, 2);
    final session = SoloDraftSession(OnboardingData(), store);
    await t.pumpWidget(MenooApp(initialLocale: const Locale('fr'), soloDraft: session));
    expect(find.byType(ProfileScreen), findsNothing);
    for (var i = 0; i < 14 && find.byType(ProfileScreen).evaluate().isEmpty; i++) {
      await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
      await t.pump(const Duration(seconds: 1));
    }
    await t.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(t.widget<TextField>(find.byType(TextField).first).controller!.text, '3');
    expect(session.currentStep, 2);
    expect(session.data.age, 37);
    expect(t.takeException(), isNull);
    await t.pumpWidget(const SizedBox());
    await session.close();
    session.dispose();
  });

  test('inactive Solo draft does not prefill the unconnected Family path', () async {
    final store = FakeSoloStore();
    final draft = await snapshot(store, 8);
    final answers = draft.answers;
    answers['resumeRequested'] = false;
    store.value = LocalDraft(
      id: draft.id,
      journey: draft.journey,
      step: draft.step,
      management: draft.management,
      currency: draft.currency,
      updatedAt: draft.updatedAt,
      answers: answers,
      pantry: [],
    );
    final session = SoloDraftSession(OnboardingData(), store);
    await session.initialize();
    final expected = OnboardingData()..startMode(AppMode.foyer);
    session.data.startMode(AppMode.foyer);
    expect(session.data.exportSoloAnswers(), expected.exportSoloAnswers());
    expect(session.data.soloInputs, isEmpty);
    await session.close();
    session.data.dispose();
    session.dispose();
    expected.dispose();
  });

  test('pantry detour keeps its live products without writing or restoring them in Solo', () async {
    final store = FakeSoloStore();
    final data = source();
    data.management = ManagementMode.mixte;
    final session = SoloDraftSession(data, store);
    await session.initialize();
    session.checkpoint(stackFor(7), visibleSolo: true, pantryDetour: false);
    await session.flush();
    final accepted = store.value!.answers['acceptedAnswers'];
    session.checkpoint(stackFor(7), visibleSolo: false, pantryDetour: true);
    final product = PantryDraft(
      name: 'synthetic reserve',
      quantity: 1,
      unitLabel: 'kg',
      location: PantryLocation.values.first,
    );
    data.update(() => data.pantry.add(product));
    await session.flush();
    expect(data.pantry, [product]);
    expect(store.value!.pantry, isEmpty);
    expect(store.value!.answers['acceptedAnswers'], accepted);
    expect(store.value!.answers['resumeRequested'], isTrue);
    await session.close();
    data.dispose();
    session.dispose();
    final restart = SoloDraftSession(OnboardingData(), store);
    await restart.initialize();
    expect(restart.currentStep, 7);
    expect(restart.data.management, ManagementMode.mixte);
    expect(restart.data.pantry, isEmpty);
    await restart.close();
    restart.data.dispose();
    restart.dispose();
  });

  for (final locale in AppLanguages.launchLocales) {
    testWidgets('extra ${locale.languageCode} storage load error is visible and never erases the draft', (t) async {
      final store = FakeSoloStore();
      final original = await snapshot(store, 2);
      store.failLoad = true;
      final session = SoloDraftSession(OnboardingData(), store);
      await session.initialize();
      final language = ValueNotifier<Locale?>(locale);
      final ready = ValueNotifier(true);
      await t.pumpWidget(harness(session, SoloDraftRouteObserver(session), language, ready));
      await t.pumpAndSettle();
      expect(find.text(lookupL(locale).soloDraftLoadError), findsOneWidget);
      expect(await session.enter(), isFalse);
      expect(store.value!.encode(), original.encode());
      await t.pumpWidget(const SizedBox());
      await session.close();
      session.data.dispose();
      session.dispose();
      language.dispose();
      ready.dispose();
    });
    testWidgets('extra ${locale.languageCode} save error keeps incomplete profile and accepted values', (t) async {
      final store = FakeSoloStore();
      await snapshot(store, 2);
      final session = SoloDraftSession(OnboardingData(), store);
      await session.initialize();
      final language = ValueNotifier<Locale?>(locale);
      final ready = ValueNotifier(true);
      await t.pumpWidget(harness(session, SoloDraftRouteObserver(session), language, ready));
      await t.pumpAndSettle();
      await session.flush();
      final original = store.value!.encode();
      store.failSave = true;
      await t.enterText(find.byType(TextField).first, '');
      await t.pumpAndSettle();
      expect(find.text(lookupL(locale).soloDraftSaveError), findsOneWidget);
      expect(session.data.age, 37);
      expect(store.value!.encode(), original);
      store.failSave = false;
      expect(await session.flush(), isTrue);
      expect((store.value!.answers['rawInputs'] as Map)['profile.age'], '');
      await t.pumpWidget(const SizedBox());
      await session.close();
      session.data.dispose();
      session.dispose();
      language.dispose();
      ready.dispose();
    });
  }

  for (final step in [6, 8]) {
    testWidgets('extra incomplete ${soloStepNames[step - 1]} survives a new session and languages', (t) async {
      t.view.physicalSize = const Size(320, 844);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      final store = FakeSoloStore();
      await snapshot(store, step);
      final session = SoloDraftSession(OnboardingData(), store);
      await session.initialize();
      final language = ValueNotifier<Locale?>(const Locale('fr'));
      final ready = ValueNotifier(true);
      await t.pumpWidget(harness(session, SoloDraftRouteObserver(session), language, ready));
      await t.pumpAndSettle();
      final field = find.byType(TextField).first;
      await t.enterText(field, step == 6 ? '19,' : 'synthetic partial exclusion');
      await t.pumpAndSettle();
      for (final locale in AppLanguages.launchLocales) {
        language.value = locale;
        await t.pumpAndSettle();
      }
      expect(session.data.budgetEuros, 190);
      expect(session.data.budgetCurrencyCode, 'CAD');
      expect(session.data.excludedFoods, ['Synthetic exclusion']);
      expect(await session.flush(), isTrue);
      await t.pumpWidget(const SizedBox());
      await session.close();
      session.data.dispose();
      session.dispose();
      language.dispose();
      ready.dispose();
      final restart = SoloDraftSession(OnboardingData(), store);
      await restart.initialize();
      final nextLanguage = ValueNotifier<Locale?>(const Locale('de'));
      final nextReady = ValueNotifier(true);
      await t.pumpWidget(harness(restart, SoloDraftRouteObserver(restart), nextLanguage, nextReady));
      await t.pumpAndSettle();
      expect(find.byType(step == 6 ? BudgetScreen : ConstraintsScreen), findsOneWidget);
      expect(
        t.widget<TextField>(find.byType(TextField).first).controller!.text,
        step == 6 ? '19,' : 'synthetic partial exclusion',
      );
      expect(restart.data.budgetEuros, 190);
      expect(restart.data.excludedFoods, ['Synthetic exclusion']);
      expect(t.takeException(), isNull);
      await t.pumpWidget(const SizedBox());
      await restart.close();
      restart.data.dispose();
      restart.dispose();
      nextLanguage.dispose();
      nextReady.dispose();
    });
  }
}
