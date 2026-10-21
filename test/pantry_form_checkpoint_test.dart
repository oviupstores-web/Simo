import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menoo/l10n/app_languages.dart';
import 'package:menoo/l10n/app_localizations.dart';
import 'package:menoo/local_storage/draft_database.dart';
import 'package:menoo/local_storage/draft_key.dart';
import 'package:menoo/local_storage/local_draft.dart';
import 'package:menoo/local_storage/pantry_form_checkpoint.dart';
import 'package:menoo/local_storage/solo_draft_repository.dart';
import 'package:menoo/local_storage/family_draft_repository.dart';
import 'package:menoo/models/pantry_values.dart';
import 'package:menoo/onboarding/onboarding_data.dart';
import 'package:menoo/onboarding/solo_draft_session.dart';
import 'package:menoo/onboarding/family_draft_session.dart';
import 'package:menoo/onboarding/onboarding_scope.dart';
import 'package:menoo/onboarding/solo_draft_navigation.dart';
import 'package:menoo/onboarding/family_draft_navigation.dart';
import 'package:menoo/screens/entry/landing_screen.dart';
import 'package:menoo/screens/onboarding/management_mode_screen.dart';
import 'package:menoo/screens/pantry/pantry_add_manual_screen.dart';
import 'package:menoo/screens/pantry/pantry_quick_check_screen.dart';
import 'package:menoo/theme/theme.dart';

class _Keys implements DraftKeyStore {
  String? value;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String key) async => value = key;
}

class _SoloStore implements SoloDraftRepository {
  LocalDraft? value;
  @override
  Future<LocalDraft?> load() async => value;
  @override
  Future<void> save(LocalDraft draft) async => value = LocalDraft.decode(draft.encode());
  @override
  Future<void> close() async {}
}

class _FamilyStore implements FamilyDraftRepository {
  LocalDraft? value;
  @override
  Future<LocalDraft?> load() async => value;
  @override
  Future<void> save(LocalDraft draft) async => value = LocalDraft.decode(draft.encode());
  @override
  Future<void> close() async {}
}

Map<String, Object?> _manual({String raw = '500,'}) => {
  'name': 'Saumon',
  'quantity': 500.0,
  'quantityText': raw,
  'quantityEdited': true,
  'unit': 'gram',
  'category': 'viandes',
  'proposedCategory': 'viandes',
  'categoryManual': false,
  'location': 'fridge',
  'proposedLocation': 'fridge',
  'locationManual': true,
  'expiresOn': '2026-10-24',
  'expiresManual': true,
  'expiryOrigin': 'userProvided',
  'fieldContext': 'quantity',
  'futureField': {'kept': true},
};

void main() {
  test('versioned provisional codec preserves raw text, dates and compatible extensions', () {
    expect(PantryFormCheckpoint.units, PantryUnit.values.map((e) => e.name).toSet());
    expect(PantryFormCheckpoint.categories, FoodCategory.values.map((e) => e.name).toSet());
    expect(PantryFormCheckpoint.locations, PantryLocation.values.map((e) => e.name).toSet());
    expect(PantryFormCheckpoint.quickCategories, QuickCategory.values.map((e) => e.name).toSet());
    final checkpoint = PantryFormCheckpoint.read({
      'version': 1,
      'manual': _manual(),
      'quick': {'fruit': 'some'},
      'futureEnvelope': [42],
    });
    final changed = checkpoint.withManual({..._manual(), 'quantityText': '500,2'});
    expect(changed.toJson()['futureEnvelope'], [42]);
    expect(changed.manual!['futureField'], {'kept': true});
    expect(changed.manual!['quantityText'], '500,2');
    expect(changed.manual!['expiresOn'], '2026-10-24');
    expect(changed.manual!['expiryOrigin'], 'userProvided');
    expect(() => PantryFormCheckpoint.read({'version': 2}), throwsFormatException);
    expect(
      () => PantryFormCheckpoint.read({
        'version': 1,
        'manual': {..._manual(), 'expiresOn': '2026-02-30'},
      }),
      throwsFormatException,
    );
  });

  test('one quick batch is coherent, keeps manual products and never duplicates', () {
    final d = OnboardingData();
    addTearDown(d.dispose);
    final l = lookupL(const Locale('fr'));
    d.update(() => d.pantry.add(PantryDraft(name: 'Existing', location: PantryLocation.fridge)));
    var notifications = 0;
    d.addListener(() => notifications++);
    expect(
      d.declareQuickStockBatch({QuickCategory.fruit: QuickStock.present, QuickCategory.pastaRice: QuickStock.some}, l),
      isTrue,
    );
    expect(notifications, 1);
    expect(d.pantry.length, 3);
    expect(
      d.declareQuickStockBatch({QuickCategory.fruit: QuickStock.present, QuickCategory.pastaRice: QuickStock.some}, l),
      isTrue,
    );
    expect(d.pantry.length, 3);
    expect(d.pantry.first.name, 'Existing');
  });

  test('encrypted restart restores independent Solo and Family provisional screens, not stock', () async {
    final temp = await Directory.systemTemp.createTemp('menoo-forms-');
    addTearDown(() => temp.delete(recursive: true));
    final file = File('${temp.path}/drafts.sqlite');
    final keys = _Keys();
    var db = await DraftDatabase.open(file, keys);
    var data = OnboardingData();
    var solo = SoloDraftSession(
      data,
      EncryptedSoloDraftRepository(() async => db, ownsConnection: false),
      familyEnabled: true,
    );
    var family = FamilyDraftSession(data, EncryptedFamilyDraftRepository(() async => db, ownsConnection: false));
    await Future.wait([solo.initialize(), family.initialize()]);
    data.startMode(AppMode.solo);
    expect(await solo.enter(), isTrue);
    solo.checkpoint(
      [
        {'step': 'management', 'editing': false},
      ],
      visibleSolo: false,
      pantryDetour: true,
      pantrySubscreen: 'manual',
    );
    solo.setManualForm(_manual());
    expect(await solo.flush(), isTrue);
    data.startMode(AppMode.foyer);
    expect(await family.enter(), isTrue);
    family.checkpoint(
      [
        {'step': 'management', 'editing': false},
      ],
      visibleFamily: false,
      pantryDetour: true,
      pantrySubscreen: 'quick',
    );
    family.setQuickForm({'fruit': 'present', 'pastaRice': 'some'});
    expect(await family.flush(), isTrue);
    expect(data.pantry, isEmpty);
    await solo.close();
    await family.close();
    solo.dispose();
    family.dispose();
    data.dispose();
    await db.close();

    db = await DraftDatabase.open(file, keys);
    data = OnboardingData();
    solo = SoloDraftSession(
      data,
      EncryptedSoloDraftRepository(() async => db, ownsConnection: false),
      familyEnabled: true,
    );
    family = FamilyDraftSession(data, EncryptedFamilyDraftRepository(() async => db, ownsConnection: false));
    await Future.wait([solo.initialize(), family.initialize()]);
    expect((solo.pantryScreen, solo.pantryForms.manual!['quantityText']), ('manual', '500,'));
    expect((family.pantryScreen, family.pantryForms.quick!['fruit']), ('quick', 'present'));
    expect(solo.pantryForms.quick, isNull);
    expect(family.pantryForms.manual, isNull);
    expect(await solo.enter(), isTrue);
    expect(data.pantry, isEmpty);
    await solo.close();
    await family.close();
    solo.dispose();
    family.dispose();
    data.dispose();
    await db.close();
  });

  test('future provisional version blocks restoration without replacing encrypted bytes', () async {
    final temp = await Directory.systemTemp.createTemp('menoo-forms-version-');
    addTearDown(() => temp.delete(recursive: true));
    final db = await DraftDatabase.open(File('${temp.path}/drafts.sqlite'), _Keys());
    final data = OnboardingData();
    final session = SoloDraftSession(data, EncryptedSoloDraftRepository(() async => db, ownsConnection: false));
    await session.initialize();
    session.checkpoint(
      [
        {'step': 'management', 'editing': false},
      ],
      visibleSolo: true,
      pantryDetour: false,
    );
    expect(await session.flush(), isTrue);
    final old = (await db.load('guest.solo'))!;
    final bad = LocalDraft(
      id: old.id,
      journey: old.journey,
      step: old.step,
      management: old.management,
      currency: old.currency,
      updatedAt: old.updatedAt,
      answers: {
        ...old.answers,
        'pantryForms': {'version': 99},
      },
      pantry: old.pantry,
    );
    await db.save(bad);
    await session.close();
    session.dispose();
    data.dispose();
    final newData = OnboardingData();
    final restored = SoloDraftSession(newData, EncryptedSoloDraftRepository(() async => db, ownsConnection: false));
    await restored.initialize();
    expect(restored.errorStage, 'load');
    expect(await restored.enter(), isFalse);
    expect((await db.load('guest.solo'))!.encode(), bad.encode());
    await restored.close();
    restored.dispose();
    newData.dispose();
    await db.close();
  });

  testWidgets('an inactive newer Family checkpoint cannot send active Solo back to Landing', (t) async {
    final soloStore = _SoloStore();
    final familyStore = _FamilyStore();
    var data = OnboardingData();
    var solo = SoloDraftSession(data, soloStore, familyEnabled: true);
    var family = FamilyDraftSession(data, familyStore);
    await Future.wait([solo.initialize(), family.initialize()]);
    data.startMode(AppMode.solo);
    await solo.enter();
    solo.checkpoint(
      [
        {'step': 'management', 'editing': false},
      ],
      visibleSolo: true,
      pantryDetour: false,
    );
    await solo.flush();
    data.startMode(AppMode.foyer);
    await family.enter();
    family.checkpoint(
      [
        {'step': 'management', 'editing': false},
      ],
      visibleFamily: true,
      pantryDetour: false,
    );
    await family.flush();
    family.checkpoint(
      [
        {'step': 'management', 'editing': false},
      ],
      visibleFamily: false,
      pantryDetour: false,
    );
    await family.flush();
    expect(family.updatedAt!.isAfter(solo.updatedAt!), isTrue);
    expect(family.resumeRequested, isFalse);
    await solo.close();
    await family.close();
    solo.dispose();
    family.dispose();
    data.dispose();
    data = OnboardingData();
    solo = SoloDraftSession(data, soloStore, familyEnabled: true);
    family = FamilyDraftSession(data, familyStore);
    await Future.wait([solo.initialize(), family.initialize()]);
    final soloObserver = SoloDraftRouteObserver(solo);
    final familyObserver = FamilyDraftRouteObserver(family);
    final ready = ValueNotifier(true);
    await t.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('fr'),
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
    );
    await t.pump();
    await t.pump(const Duration(milliseconds: 500));
    await t.pump();
    expect(data.isFoyer, isFalse);
    expect(find.byType(ManagementModeScreen), findsOneWidget);
    await t.pumpWidget(const SizedBox());
    ready.dispose();
    await solo.close();
    await family.close();
    solo.dispose();
    family.dispose();
    data.dispose();
  });

  for (final language in ['fr', 'en', 'es', 'it', 'de']) {
    for (final width in [320.0, 390.0]) {
      testWidgets('$language $width restores the manual pantry subpage without overflow', (t) async {
        t.view.physicalSize = Size(width, 1400);
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.reset);
        final data = OnboardingData();
        final store = _SoloStore();
        final solo = SoloDraftSession(data, store);
        await solo.initialize();
        solo.checkpoint(
          [
            {'step': 'management', 'editing': false},
          ],
          visibleSolo: false,
          pantryDetour: true,
          pantrySubscreen: 'manual',
        );
        solo.setManualForm(_manual());
        expect(await solo.flush(), isTrue);
        final observer = SoloDraftRouteObserver(solo);
        late BuildContext entry;
        await t.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            locale: Locale(language),
            supportedLocales: AppLanguages.launchLocales,
            localizationsDelegates: L.localizationsDelegates,
            navigatorObservers: [observer],
            builder: (_, child) => OnboardingScope(data: data, soloDraft: solo, child: child!),
            home: Builder(
              builder: (context) {
                entry = context;
                return const Scaffold(body: SizedBox());
              },
            ),
          ),
        );
        resumeSoloRoutes(entry, solo, observer, includeEntry: false);
        await t.pumpAndSettle();
        expect(find.byType(PantryAddManualScreen), findsOneWidget);
        expect(find.text('Saumon'), findsOneWidget);
        expect(t.widget<TextField>(find.byType(TextField).last).controller!.text, '500,');
        expect(t.takeException(), isNull);
        if (language == 'fr' && width == 390) {
          final submit = find.text(lookupL(const Locale('fr')).pantryAddSubmit).last;
          await t.ensureVisible(submit);
          await t.tap(submit);
          await t.pumpAndSettle();
          expect(data.pantry, isEmpty);
          expect(solo.pantryForms.manual!['quantityText'], '500,');
          expect(find.byType(PantryAddManualScreen), findsOneWidget);
          await t.enterText(find.byType(TextField).last, '500');
          await t.ensureVisible(submit);
          await t.tap(submit);
          await t.pumpAndSettle();
          expect(data.pantry.length, 1);
          expect(solo.pantryForms.manual, isNull);
          expect(solo.pantryScreen, 'hub');
          expect(await solo.flush(), isTrue);
        }
        await t.pumpWidget(const SizedBox());
        await solo.close();
        solo.dispose();
        data.dispose();
        if (language == 'fr' && width == 390) {
          for (var restart = 0; restart < 2; restart++) {
            final reopenedData = OnboardingData();
            final reopened = SoloDraftSession(reopenedData, store);
            await reopened.initialize();
            expect(await reopened.enter(), isTrue);
            expect(reopenedData.pantry.length, 1);
            expect(reopened.pantryForms.manual, isNull);
            await reopened.close();
            reopened.dispose();
            reopenedData.dispose();
          }
        }
      });
    }
  }

  for (final language in ['fr', 'en', 'es', 'it', 'de']) {
    for (final width in [320.0, 390.0]) {
      testWidgets('$language $width restores uncommitted Family quick choices without overflow', (t) async {
        t.view.physicalSize = Size(width, 1400);
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.reset);
        final data = OnboardingData()..startMode(AppMode.foyer);
        final family = FamilyDraftSession(data, _FamilyStore());
        await family.initialize();
        expect(await family.enter(), isTrue);
        family.checkpoint(
          [
            {'step': 'management', 'editing': false},
          ],
          visibleFamily: false,
          pantryDetour: true,
          pantrySubscreen: 'quick',
        );
        family.setQuickForm({'fruit': 'present', 'pastaRice': 'some'});
        expect(await family.flush(), isTrue);
        final observer = FamilyDraftRouteObserver(family);
        late BuildContext entry;
        await t.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            locale: Locale(language),
            supportedLocales: AppLanguages.launchLocales,
            localizationsDelegates: L.localizationsDelegates,
            navigatorObservers: [observer],
            builder: (_, child) => OnboardingScope(data: data, familyDraft: family, child: child!),
            home: Builder(
              builder: (context) {
                entry = context;
                return const Scaffold(body: SizedBox());
              },
            ),
          ),
        );
        resumeFamilyRoutes(entry, family, observer, includeEntry: false);
        await t.pumpAndSettle();
        expect(find.byType(PantryQuickCheckScreen), findsOneWidget);
        expect(find.text(lookupL(Locale(language)).quickCheckPresent), findsWidgets);
        expect(data.pantry, isEmpty);
        expect(t.takeException(), isNull);
        await t.pumpWidget(const SizedBox());
        await family.close();
        family.dispose();
        data.dispose();
      });
    }
  }
}
