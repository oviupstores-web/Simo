import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menoo/l10n/app_languages.dart';
import 'package:menoo/l10n/app_localizations.dart';
import 'package:menoo/l10n/locale_scope.dart';
import 'package:menoo/local_storage/draft_database.dart';
import 'package:menoo/local_storage/draft_checkpoint_clock.dart';
import 'package:menoo/local_storage/draft_key.dart';
import 'package:menoo/local_storage/family_draft_repository.dart';
import 'package:menoo/local_storage/local_draft.dart';
import 'package:menoo/local_storage/pantry_draft_section.dart';
import 'package:menoo/local_storage/shared_draft_database.dart';
import 'package:menoo/local_storage/solo_draft_repository.dart';
import 'package:menoo/main.dart';
import 'package:menoo/onboarding/family_draft_navigation.dart';
import 'package:menoo/onboarding/family_draft_session.dart';
import 'package:menoo/onboarding/onboarding_data.dart';
import 'package:menoo/onboarding/onboarding_flow.dart';
import 'package:menoo/onboarding/onboarding_scope.dart';
import 'package:menoo/onboarding/solo_draft_navigation.dart';
import 'package:menoo/onboarding/solo_draft_session.dart';
import 'package:menoo/screens/entry/landing_screen.dart';
import 'package:menoo/screens/onboarding/member_profiles_screen.dart';
import 'package:menoo/theme/theme.dart';

class FamilyMemory implements FamilyDraftRepository {
  LocalDraft? value;
  bool failRead = false;
  bool failWrite = false;
  int writes = 0;
  @override
  Future<LocalDraft?> load() async {
    if (failRead) throw const DraftStorageException('synthetic_read');
    return value;
  }

  @override
  Future<void> save(LocalDraft draft) async {
    if (failWrite) throw const DraftStorageException('synthetic_write');
    writes++;
    value = LocalDraft.decode(draft.encode());
  }

  @override
  Future<void> close() async {}
}

class SoloMemory implements SoloDraftRepository {
  LocalDraft? value;
  int writes = 0;
  @override
  Future<LocalDraft?> load() async => value;
  @override
  Future<void> save(LocalDraft draft) async {
    writes++;
    value = draft;
  }

  @override
  Future<void> close() async {}
}

class FamilyTestKeys implements DraftKeyStore {
  String? value;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String key) async {
    value = key;
  }
}

OnboardingData familySource() {
  final d = OnboardingData()
    ..startMode(AppMode.foyer)
    ..initializeBudgetCurrency('CAD');
  d.update(() {
    d.members.first.firstName = 'Synthetic member';
    d.members.first.allergens.addAll({'arachides', 'unknown_allergen'});
    d.budgetEuros = 190;
    d.budgetEdited = true;
    d.management = ManagementMode.courses;
    d.slots
      ..clear()
      ..addAll({(1, MealType.diner), (6, MealType.dejeuner)});
    d.diets.addAll({'sans_gluten', 'unknown_restriction'});
    d.allergens.add('soja');
    d.excludedFoods.add('Synthetic food');
    d.cuisinePreferences.add('italienne');
    d.equipment.add('blender');
    d.mainCookId = 2;
    d.weekdayMinutes = 15;
  });
  d.familyInputs.addAll({'budget.custom': '190,', 'constraints.food': 'unfinished food'});
  return d;
}

List<Map<String, Object?>> familyStack(int step) => [
  for (final name in familyStepNames.take(step)) {'step': name, 'editing': false},
];

Future<LocalDraft> seed(FamilyMemory store, int step, {bool editor = false, bool fromSummary = false}) async {
  final d = familySource();
  final s = FamilyDraftSession(d, store);
  await s.initialize();
  final routes = familyStack(fromSummary ? 9 : step);
  if (fromSummary) routes.add({'step': 'members', 'editing': true});
  if (editor) {
    final m = d.members.first.copy();
    d.saveFamilyMemberEdit(m, {'name': '', 'age': '3', 'height': '', 'weight': '75,'}, isNew: false);
    routes.add({'step': 'memberEdit', 'editing': false, 'memberId': m.id, 'isNew': false});
  }
  s.checkpoint(routes, visibleFamily: true, pantryDetour: false);
  expect(await s.flush(), isTrue);
  await s.close();
  d.dispose();
  s.dispose();
  return store.value!;
}

class FamilyHarness {
  FamilyHarness(this.store, this.locale) {
    data = OnboardingData();
    solo = SoloDraftSession(data, SoloMemory(), familyEnabled: true);
    family = FamilyDraftSession(data, store);
    soloObserver = SoloDraftRouteObserver(solo);
    familyObserver = FamilyDraftRouteObserver(family);
  }
  final FamilyMemory store;
  final Locale locale;
  late final OnboardingData data;
  late final SoloDraftSession solo;
  late final FamilyDraftSession family;
  late final SoloDraftRouteObserver soloObserver;
  late final FamilyDraftRouteObserver familyObserver;
  final language = ValueNotifier<Locale?>(null);
  final ready = ValueNotifier(true);
  Future<void> initialize() async {
    language.value = locale;
    await Future.wait([solo.initialize(), family.initialize()]);
  }

  Widget widget() => LocaleScope(
    controller: language,
    child: ValueListenableBuilder<Locale?>(
      valueListenable: language,
      builder: (_, value, _) => MaterialApp(
        theme: AppTheme.light,
        locale: value,
        supportedLocales: AppLanguages.launchLocales,
        localizationsDelegates: L.localizationsDelegates,
        navigatorObservers: [soloObserver, familyObserver],
        builder: (_, child) => OnboardingScope(data: data, soloDraft: solo, familyDraft: family, child: child!),
        home: SoloDraftResumeHost(
          session: solo,
          observer: soloObserver,
          family: family,
          familyObserver: familyObserver,
          startupDone: ready,
          child: const LandingScreen(),
        ),
      ),
    ),
  );
  Future<void> close({bool disposeData = true}) async {
    await Future.wait([solo.close(), family.close()]);
    solo.dispose();
    family.dispose();
    if (disposeData) data.dispose();
    language.dispose();
    ready.dispose();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    for (final entry in {
      'PlusJakartaSans': [
        for (final weight in [400, 500, 600, 700, 800]) 'PlusJakartaSans-$weight.ttf',
      ],
      'Caveat': ['Caveat-600.ttf'],
    }.entries) {
      final loader = FontLoader(entry.key);
      for (final name in entry.value) {
        loader.addFont(Future.value(ByteData.sublistView(File('assets/fonts/$name').readAsBytesSync())));
      }
      await loader.load();
    }
  });
  for (var step = 1; step <= 9; step++) {
    test('Family step $step retains exact accepted sources and raw inputs', () async {
      final store = FamilyMemory();
      final expected = await seed(store, step);
      final s = FamilyDraftSession(OnboardingData()..startMode(AppMode.foyer), store);
      await s.initialize();
      expect(await s.enter(), isTrue);
      expect(s.currentStep, step);
      expect(s.data.exportFamilyAnswers(), expected.answers['acceptedAnswers']);
      expect(s.data.familyInputs, expected.answers['rawInputs']);
      expect(s.data.budgetCurrencyCode, 'CAD');
      expect(s.data.members.first.allergens, contains('arachides'));
      expect(s.data.allAllergens, containsAll(['arachides', 'soja']));
      await s.close();
      s.data.dispose();
      s.dispose();
    });
  }

  test('Member edits remain separate, new IDs survive restart, save commits only valid data', () async {
    final store = FamilyMemory();
    final d = familySource();
    final s = FamilyDraftSession(d, store);
    await s.initialize();
    s.checkpoint(familyStack(2), visibleFamily: true, pantryDetour: false);
    final m = d.newMember(MemberRole.enfant);
    d.saveFamilyMemberEdit(m, {'name': '', 'age': '-', 'height': '1', 'weight': '26,'}, isNew: true);
    s.checkpoint(
      [
        ...familyStack(2),
        {'step': 'memberEdit', 'editing': false, 'memberId': m.id, 'isNew': true},
      ],
      visibleFamily: true,
      pantryDetour: false,
    );
    await s.flush();
    await s.close();
    final r = FamilyDraftSession(OnboardingData()..startMode(AppMode.foyer), store);
    await r.initialize();
    expect(await r.enter(), isTrue);
    expect(r.data.members.length, 4);
    expect(r.data.familyMemberEdits[m.id]!['rawInputs'], {'name': '', 'age': '-', 'height': '1', 'weight': '26,'});
    final next = r.data.newMember(MemberRole.bebe);
    expect(next.id, greaterThan(m.id));
    m.firstName = 'Synthetic added';
    expect(r.data.saveMember(m), isNull);
    expect(r.data.members.length, 5);
    expect(r.data.familyMemberEdits.containsKey(m.id), isFalse);
    await r.close();
    d.dispose();
    s.dispose();
    r.data.dispose();
    r.dispose();
  });

  for (final failure in ['read', 'write', 'format', 'duplicate', 'portions', 'cook']) {
    test('Family $failure error never resets or overwrites a stored draft', () async {
      final store = FamilyMemory();
      await seed(store, 5);
      final original = store.value!;
      if (failure == 'read') store.failRead = true;
      if (failure == 'write') store.failWrite = true;
      if (!['read', 'write'].contains(failure)) {
        final a = original.answers;
        final accepted = Map<String, Object?>.from(a['acceptedAnswers'] as Map);
        if (failure == 'format') a['familyPayloadVersion'] = 999;
        if (failure == 'duplicate') {
          final members = accepted['members'] as List;
          members.add(members.first);
        }
        if (failure == 'portions') accepted['portionRulesVersion'] = 999;
        if (failure == 'cook') accepted['mainCookId'] = 999;
        a['acceptedAnswers'] = accepted;
        store.value = LocalDraft(
          id: original.id,
          journey: original.journey,
          step: original.step,
          management: original.management,
          currency: original.currency,
          updatedAt: original.updatedAt,
          answers: a,
          pantry: original.pantry,
        );
      }
      final before = store.value!.encode();
      final writes = store.writes;
      final s = FamilyDraftSession(OnboardingData()..startMode(AppMode.foyer), store);
      await s.initialize();
      if (failure == 'write') {
        expect(await s.enter(), isTrue);
        s.checkpoint(familyStack(5), visibleFamily: true, pantryDetour: false);
        s.data.setFamilyInput('constraints.food', 'new unfinished');
        expect(await s.flush(), isFalse);
        expect(s.errorStage, 'save');
        expect(s.data.familyInputs['constraints.food'], 'new unfinished');
      } else {
        expect(await s.enter(), isFalse);
        expect(s.errorStage, 'load');
        s.checkpoint(familyStack(1), visibleFamily: true, pantryDetour: false);
      }
      expect(store.value!.encode(), before);
      expect(store.writes, writes);
      if (failure == 'write') {
        store.failWrite = false;
        expect(await s.flush(), isTrue);
        expect(store.value!.answers['rawInputs'], containsPair('constraints.food', 'new unfinished'));
      }
      await s.close();
      s.data.dispose();
      s.dispose();
    });
  }

  test(
    'One encrypted connection preserves Solo bytes and compatible pantry extensions across Family operations',
    () async {
      final dir = await Directory.systemTemp.createTemp('menoo_family_shared_');
      final file = File('${dir.path}/draft.sqlite');
      final keys = FamilyTestKeys();
      var opens = 0;
      final shared = SharedDraftDatabase(() {
        opens++;
        return DraftDatabase.open(file, keys);
      });
      final soloStore = EncryptedSoloDraftRepository(shared.database, ownsConnection: false);
      final familyStore = EncryptedFamilyDraftRepository(shared.database, ownsConnection: false);
      try {
        final soloData = OnboardingData()..initializeBudgetCurrency('EUR');
        final seedSolo = SoloDraftSession(soloData, soloStore, familyEnabled: true);
        await seedSolo.initialize();
        seedSolo.checkpoint(
          [
            {'step': 'goal', 'editing': false},
          ],
          visibleSolo: true,
          pantryDetour: false,
        );
        await seedSolo.flush();
        final db = await shared.database();
        final soloBefore = (await db.load('guest.solo'))!.encode();
        final store = FamilyMemory();
        final familySeed = await seed(store, 8);
        await db.save(
          LocalDraft(
            id: familySeed.id,
            journey: familySeed.journey,
            step: familySeed.step,
            management: familySeed.management,
            currency: familySeed.currency,
            updatedAt: familySeed.updatedAt,
            answers: {...familySeed.answers, 'future_field': 'preserved'},
            // Former opaque fixture replaced by the now-required versioned format.
            // Unrecognized historical contents are tested as refused, never erased.
            pantry: [
              {
                ...familySeed.pantry.single,
                'future_fixture': {'retained': 2},
              },
            ],
          ),
        );
        final family = FamilyDraftSession(soloData, familyStore);
        await Future.wait([soloStore.load(), family.initialize()]);
        soloData.startMode(AppMode.foyer);
        expect(await family.enter(), isTrue);
        family.checkpoint(familyStack(8), visibleFamily: true, pantryDetour: false);
        soloData.update(() => soloData.equipment.add('synthetic_extra'));
        await Future.wait([family.flush(), seedSolo.flush()]);
        expect((await db.load('guest.solo'))!.encode(), soloBefore);
        expect((await db.load('guest.family'))!.pantry.single['future_fixture'], {'retained': 2});
        expect((await db.load('guest.family'))!.answers['future_field'], 'preserved');
        expect(opens, 1);
        final familyBefore = (await db.load('guest.family'))!.encode();
        soloData.startMode(AppMode.solo);
        expect(await seedSolo.enter(), isTrue);
        seedSolo.checkpoint(
          [
            {'step': 'goal', 'editing': false},
          ],
          visibleSolo: true,
          pantryDetour: false,
        );
        await seedSolo.flush();
        await family.flush();
        expect((await db.load('guest.family'))!.encode(), familyBefore);
        await family.close();
        await seedSolo.close();
        family.dispose();
        seedSolo.dispose();
        soloData.dispose();
        await shared.close();
        expect(
          utf8.decode((await file.readAsBytes()).take(16).toList(), allowMalformed: true),
          isNot('SQLite format 3\u0000'),
        );
        final reopened = await DraftDatabase.open(file, keys);
        expect((await reopened.load('guest.family'))!.encode(), familyBefore);
        await reopened.close();
      } finally {
        await shared.close();
        await dir.delete(recursive: true);
      }
    },
  );

  test('Fresh Family defaults never inherit Solo common fields or change Solo-specific sources', () async {
    final d = OnboardingData()..initializeBudgetCurrency('USD');
    d.diets.add('vegan');
    d.budgetEuros = 999;
    d.goal = HealthGoal.priseMasse;
    d.soloInputs['profile.age'] = '3';
    d.startMode(AppMode.foyer);
    final family = FamilyDraftSession(d, FamilyMemory());
    await family.initialize();
    expect(await family.enter(), isTrue);
    expect(d.diets, isEmpty);
    expect(d.budgetCurrencyCode, 'EUR');
    expect(d.goal, HealthGoal.priseMasse);
    expect(d.soloInputs['profile.age'], '3');
    expect(d.needsTarget, isFalse);
    expect(d.exportFamilyAnswers(), isNot(contains('goal')));
    expect(d.exportFamilyAnswers()['portionFactors'], {'adulte': 1.0, 'enfant': 0.65, 'bebe': 0.3});
    await family.close();
    family.dispose();
    d.dispose();
  });

  test('Shared checkpoint order survives a device clock moved backward', () {
    final clock = DraftCheckpointClock(now: () => DateTime.utc(2020));
    final savedSolo = DateTime.utc(2026, 10, 14, 17);
    final savedFamily = savedSolo.add(const Duration(seconds: 1));
    clock.observe(savedSolo);
    clock.observe(savedFamily);
    final soloNext = clock.next();
    final familyNext = clock.next();
    expect(soloNext.isAfter(savedFamily), isTrue);
    expect(familyNext.isAfter(soloNext), isTrue);
  });

  for (var step = 1; step <= 9; step++) {
    test('Native encrypted Family database restores step $step and exact member sources', () async {
      final dir = await Directory.systemTemp.createTemp('menoo_family_native_');
      final file = File('${dir.path}/draft.sqlite');
      final keys = FamilyTestKeys();
      try {
        final memory = FamilyMemory();
        final original = await seed(memory, step);
        final db = await DraftDatabase.open(file, keys);
        await db.save(original);
        await db.close();
        final s = FamilyDraftSession(
          OnboardingData()..startMode(AppMode.foyer),
          EncryptedFamilyDraftRepository(() => DraftDatabase.open(file, keys)),
        );
        await s.initialize();
        expect(await s.enter(), isTrue);
        expect(s.currentStep, step);
        expect(s.data.exportFamilyAnswers(), original.answers['acceptedAnswers']);
        expect(s.data.familyInputs, original.answers['rawInputs']);
        await s.close();
        s.data.dispose();
        s.dispose();
      } finally {
        await dir.delete(recursive: true);
      }
    });
  }

  test('Inherited unknown Family currency stays unknown and every explicit currency keeps its amount', () async {
    for (final currency in [null, ...OnboardingData.budgetCurrencies]) {
      final d = familySource()..restoreBudget(amount: 190, currency: currency);
      final store = FamilyMemory();
      final s = FamilyDraftSession(d, store);
      await s.initialize();
      s.checkpoint(familyStack(4), visibleFamily: true, pantryDetour: false);
      await s.flush();
      await s.close();
      expect(store.value!.currency, currency ?? 'XXX');
      final r = FamilyDraftSession(OnboardingData()..startMode(AppMode.foyer), store);
      await r.initialize();
      expect(await r.enter(), isTrue);
      r.data.initializeBudgetCurrency('EUR');
      expect(r.data.budgetCurrencyCode, currency);
      expect(r.data.budgetEuros, 190);
      expect(r.data.budgetCurrencyUnknown, currency == null);
      await r.close();
      r.data.dispose();
      r.dispose();
      d.dispose();
      s.dispose();
    }
  });

  test('Forced process interruption restores encrypted Family and an incomplete editor offline', () async {
    final dir = await Directory.systemTemp.createTemp('menoo_family_process_');
    final file = File('${dir.path}/draft.sqlite');
    final keys = FamilyTestKeys();
    try {
      final memory = FamilyMemory();
      final snapshot = await seed(memory, 2, editor: true, fromSummary: true);
      final db = await DraftDatabase.open(file, keys);
      await db.save(snapshot);
      await db.close();
      final keyFile = File('${dir.path}/synthetic-key.txt');
      await keyFile.writeAsString(keys.value!);
      final expectedFile = File('${dir.path}/synthetic-expected.json');
      await expectedFile.writeAsString(snapshot.encode());
      final dart = Platform.environment['MENOO_TEST_DART'];
      expect(dart, isNotNull);
      final child = await Process.start(dart!, [
        'run',
        'test/support/family_draft_process_probe.dart',
        file.path,
        keyFile.path,
        'crash',
        expectedFile.path,
      ]);
      final ready = Completer<void>();
      final output = child.stdout.transform(utf8.decoder).transform(const LineSplitter()).listen((line) {
        if (line == 'family-transaction-pending' && !ready.isCompleted) ready.complete();
      });
      final errors = child.stderr.listen((_) {});
      try {
        await ready.future.timeout(const Duration(seconds: 50));
        child.kill();
        await child.exitCode.timeout(const Duration(seconds: 10));
      } finally {
        child.kill();
        await output.cancel();
        await errors.cancel();
      }
      final check = await Process.run(dart, [
        'run',
        'test/support/family_draft_process_probe.dart',
        file.path,
        keyFile.path,
        'restore',
        expectedFile.path,
      ]);
      expect(check.exitCode, 0);
      expect(check.stdout, contains('family-restored-offline'));
      final restored = FamilyDraftSession(
        OnboardingData()..startMode(AppMode.foyer),
        EncryptedFamilyDraftRepository(() => DraftDatabase.open(file, keys)),
      );
      await restored.initialize();
      expect(await restored.enter(), isTrue);
      expect(restored.routeStack.last['step'], 'memberEdit');
      expect(restored.routeStack[9], {'step': 'members', 'editing': true});
      expect(restored.data.familyMemberEdits[1]!['rawInputs'], containsPair('name', ''));
      expect(restored.data.members.first.firstName, 'Synthetic member');
      expect(restored.data.budgetCurrencyCode, 'CAD');
      await restored.close();
      restored.data.dispose();
      restored.dispose();
    } finally {
      await dir.delete(recursive: true);
    }
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('Reserve detour resumes Family management and persists validated products', () async {
    final store = FamilyMemory();
    await seed(store, 6);
    final s = FamilyDraftSession(OnboardingData()..startMode(AppMode.foyer), store);
    await s.initialize();
    expect(await s.enter(), isTrue);
    s.checkpoint(familyStack(6), visibleFamily: false, pantryDetour: true);
    s.data.update(
      () => s.data.pantry.add(
        PantryDraft(
          name: 'Synthetic reserve',
          quantity: 2,
          unitLabel: 'kg',
          location: PantryLocation.fridge,
          source: 'manual',
        ),
      ),
    );
    await s.flush();
    expect(store.value!.step, 6);
    expect(store.value!.answers['resumeRequested'], isTrue);
    expect(PantryDraftSection.read(store.value!).items.single.name, 'Synthetic reserve');
    await s.close();
    s.data.dispose();
    s.dispose();
  });

  for (final locale in AppLanguages.launchLocales) {
    testWidgets(
      '${locale.languageCode} live member input persists, survives language change and commits on Save only',
      (t) async {
        t.view.physicalSize = const Size(390, 844);
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.reset);
        final store = FamilyMemory();
        await seed(store, 2);
        final h = FamilyHarness(store, locale);
        await h.initialize();
        await t.pumpWidget(h.widget());
        await t.pumpAndSettle();
        final context = t.element(find.byType(MemberProfilesScreen));
        unawaited(OnboardingFlow.openMember(context, h.data.members.first.copy()));
        await t.pumpAndSettle();
        final fields = find.byType(TextField);
        await t.enterText(fields.at(0), 'Test');
        await t.enterText(fields.at(1), '');
        await t.enterText(fields.at(2), '182');
        await t.enterText(fields.at(3), '84,');
        await t.pumpAndSettle();
        await h.family.flush();
        expect(h.data.members.first.firstName, 'Synthetic member');
        expect(store.value!.answers['memberEdits'], contains('1'));
        expect(h.family.routeStack.last['step'], 'memberEdit');
        final nextLocale = AppLanguages.launchLocales[(AppLanguages.launchLocales.indexOf(locale) + 1) % 5];
        h.language.value = nextLocale;
        await t.pumpAndSettle();
        expect(t.widget<TextField>(fields.at(1)).controller!.text, '');
        final save = find.text(lookupL(nextLocale).memberSave);
        await t.ensureVisible(save);
        await t.tap(save);
        await t.pumpAndSettle();
        expect(find.byType(MemberEditScreen), findsOneWidget);
        expect(h.data.members.first.firstName, 'Synthetic member');
        await t.enterText(fields.at(1), '38');
        await t.enterText(fields.at(3), '84');
        await t.ensureVisible(save);
        await t.tap(save);
        await t.pumpAndSettle();
        expect(find.byType(MemberProfilesScreen), findsOneWidget);
        expect(h.data.members.first.id, 1);
        expect(h.data.members.first.firstName, 'Test');
        expect(h.data.members.first.age, 38);
        expect(h.data.members.first.allergens, contains('arachides'));
        expect(h.data.familyMemberEdits, isEmpty);
        await h.family.flush();
        expect(t.takeException(), isNull);
        await t.pumpWidget(const SizedBox());
        await h.close();
      },
    );
    for (var step = 1; step <= 9; step++) {
      testWidgets('${locale.languageCode} resumes real Family step $step with exact sources', (t) async {
        t.view.physicalSize = const Size(390, 844);
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.reset);
        final store = FamilyMemory();
        final snapshot = await seed(store, step);
        final h = FamilyHarness(store, locale);
        await h.initialize();
        await t.pumpWidget(h.widget());
        await t.pumpAndSettle();
        expect(h.data.isFoyer, isTrue);
        expect(h.family.currentStep, step);
        expect(find.byType(OnboardingFlow.screenFor(OnboardingFlow.foyer[step - 1]).runtimeType), findsOneWidget);
        expect(h.data.exportFamilyAnswers(), snapshot.answers['acceptedAnswers']);
        expect(h.data.budgetCurrencyCode, 'CAD');
        if (step == 4) expect(find.text('190,'), findsOneWidget);
        if (step == 5) expect(find.text('unfinished food'), findsOneWidget);
        expect(t.takeException(), isNull);
        await t.pumpWidget(const SizedBox());
        await h.close();
      });
    }
    testWidgets('${locale.languageCode} restores incomplete member editor at 320 and summary return', (t) async {
      t.view.physicalSize = const Size(320, 844);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      final store = FamilyMemory();
      await seed(store, 2, editor: true, fromSummary: true);
      final h = FamilyHarness(store, locale);
      await h.initialize();
      await t.pumpWidget(h.widget());
      await t.pumpAndSettle();
      expect(find.byType(MemberEditScreen), findsOneWidget);
      final fields = t.widgetList<TextField>(find.byType(TextField)).map((f) => f.controller!.text);
      expect(fields, containsAll(['', '3', '75,']));
      expect(h.data.members.first.firstName, 'Synthetic member');
      final context = t.element(find.byType(MemberEditScreen));
      Navigator.of(context).pop();
      await t.pumpAndSettle();
      expect(h.family.routeStack.last, {'step': 'members', 'editing': true});
      final parent = t.element(find.byType(MemberProfilesScreen));
      OnboardingFlow.next(parent, OnbStep.members);
      await t.pumpAndSettle();
      expect(h.family.routeStack.last['step'], 'summary');
      expect(t.takeException(), isNull);
      await t.pumpWidget(const SizedBox());
      await h.close();
    });
  }

  testWidgets('Production splash restores most recent Family without mutating Solo record', (t) async {
    t.view.physicalSize = const Size(390, 844);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    final store = FamilyMemory();
    await seed(store, 5);
    final h = FamilyHarness(store, const Locale('fr'));
    await t.pumpWidget(MenooApp(initialLocale: const Locale('fr'), soloDraft: h.solo, familyDraft: h.family));
    await t.pump();
    expect(find.byType(OnboardingFlow.screenFor(OnbStep.constraints).runtimeType), findsNothing);
    for (var i = 0; i < 14 && !h.data.isFoyer; i++) {
      await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
      await t.pump(const Duration(seconds: 1));
    }
    await t.pumpAndSettle();
    expect(h.data.isFoyer, isTrue);
    expect(h.family.currentStep, 5);
    expect(find.byType(OnboardingFlow.screenFor(OnbStep.constraints).runtimeType), findsOneWidget);
    expect((h.solo.repository as SoloMemory).writes, 0);
    expect(t.takeException(), isNull);
    await t.pumpWidget(const SizedBox());
    await h.close(disposeData: false);
  });
}
