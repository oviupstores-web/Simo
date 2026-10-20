import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menoo/l10n/app_localizations.dart';
import 'package:menoo/local_storage/draft_database.dart';
import 'package:menoo/local_storage/draft_key.dart';
import 'package:menoo/local_storage/local_draft.dart';
import 'package:menoo/local_storage/pantry_codec.dart';
import 'package:menoo/local_storage/pantry_draft_section.dart';
import 'package:menoo/local_storage/pantry_storage_guard.dart';
import 'package:menoo/local_storage/solo_draft_repository.dart';
import 'package:menoo/local_storage/family_draft_repository.dart';
import 'package:menoo/models/pantry_product_record.dart';
import 'package:menoo/models/pantry_values.dart';
import 'package:menoo/onboarding/onboarding_data.dart';
import 'package:menoo/onboarding/solo_draft_session.dart';
import 'package:menoo/onboarding/family_draft_session.dart';

class TestKeys implements DraftKeyStore {
  String? value;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String key) async {
    value = key;
  }
}

class ControlledSoloRepository implements SoloDraftRepository {
  ControlledSoloRepository(this.inner);
  final SoloDraftRepository inner;
  Completer<void>? hold;
  Completer<void>? started;
  bool failNext = false;
  @override
  Future<LocalDraft?> load() => inner.load();
  @override
  Future<void> save(LocalDraft draft) async {
    final gate = hold;
    hold = null;
    started?.complete();
    started = null;
    if (gate != null) await gate.future;
    if (failNext) {
      failNext = false;
      throw const DraftStorageException('synthetic_failure');
    }
    await inner.save(draft);
  }

  @override
  Future<void> close() => inner.close();
}

class Sessions {
  Sessions(this.db) {
    solo = SoloDraftSession(
      data,
      EncryptedSoloDraftRepository(() async => db, ownsConnection: false),
      familyEnabled: true,
    );
    family = FamilyDraftSession(data, EncryptedFamilyDraftRepository(() async => db, ownsConnection: false));
  }
  final DraftDatabase db;
  final data = OnboardingData();
  late final SoloDraftSession solo;
  late final FamilyDraftSession family;
  Future<void> initialize() => Future.wait([solo.initialize(), family.initialize()]);
  Future<void> enter(DraftJourney journey, {bool detour = true}) async {
    data.startMode(journey == DraftJourney.solo ? AppMode.solo : AppMode.foyer);
    if (journey == DraftJourney.solo) {
      expect(await solo.enter(), isTrue);
      solo.checkpoint(
        [
          {'step': 'management', 'editing': false},
        ],
        visibleSolo: !detour,
        pantryDetour: detour,
      );
    } else {
      expect(await family.enter(), isTrue);
      family.checkpoint(
        [
          {'step': 'management', 'editing': false},
        ],
        visibleFamily: !detour,
        pantryDetour: detour,
      );
    }
  }

  Future<void> flush() async {
    expect(await solo.flush(), isTrue);
    expect(await family.flush(), isTrue);
  }

  Future<void> close() async {
    await solo.close();
    await family.close();
    solo.dispose();
    family.dispose();
    data.dispose();
    await db.close();
  }
}

LocalDraft replace(
  LocalDraft d, {
  Map<String, Object?>? answers,
  List<Map<String, Object?>>? pantry,
  DateTime? updatedAt,
}) => LocalDraft(
  id: d.id,
  journey: d.journey,
  step: d.step,
  management: d.management,
  currency: d.currency,
  updatedAt: updatedAt ?? d.updatedAt,
  answers: answers ?? d.answers,
  pantry: pantry ?? d.pantry,
);

void main() {
  late Directory temp;
  late File file;
  late TestKeys keys;
  setUp(() async {
    temp = await Directory.systemTemp.createTemp('menoo-pantry-fixture-');
    file = File('${temp.path}/test.sqlite');
    keys = TestKeys();
  });
  tearDown(() async {
    await temp.delete(recursive: true);
  });

  test('storage wire codes stay identical to codec enum codes', () {
    expect(PantryStorageGuard.units, PantryUnit.values.map((v) => v.id).toSet());
    expect(PantryStorageGuard.locations, PantryLocation.values.map((v) => v.dbValue).toSet());
    expect(PantryStorageGuard.categories, QuickCategory.values.map((v) => v.id).toSet());
  });

  test('queued mutations and failed save keep latest deletion and accepted answers', () async {
    final db = await DraftDatabase.open(file, keys);
    final store = ControlledSoloRepository(EncryptedSoloDraftRepository(() async => db, ownsConnection: false));
    final data = OnboardingData();
    final session = SoloDraftSession(data, store);
    await session.initialize();
    session.checkpoint(
      [
        {'step': 'management', 'editing': false},
      ],
      visibleSolo: true,
      pantryDetour: false,
    );
    expect(await session.flush(), isTrue);
    final previous = (await db.load('guest.solo'))!.encode();
    final gate = Completer<void>();
    final started = Completer<void>();
    store.hold = gate;
    store.started = started;
    store.failNext = true;
    data.update(() => data.pantry.add(PantryDraft(name: 'first fixture', location: PantryLocation.fridge)));
    await started.future;
    data.update(() {
      data.pantry.clear();
      data.age = 42;
    });
    data.update(() => data.pantry.add(PantryDraft(name: 'latest fixture', location: PantryLocation.pantry)));
    gate.complete();
    expect(await session.flush(), isFalse);
    expect(session.errorStage, 'save');
    expect((await db.load('guest.solo'))!.encode(), previous);
    expect(data.pantry.single.name, 'latest fixture');
    expect(await session.flush(), isTrue);
    final saved = (await db.load('guest.solo'))!;
    expect(PantryDraftSection.read(saved).items.single.name, 'latest fixture');
    expect((saved.answers['acceptedAnswers'] as Map)['age'], 42);
    await session.close();
    session.dispose();
    data.dispose();
    await db.close();
  });

  for (final unit in PantryUnit.values) {
    test('SQLite round-trip $unit keeps exact quantity, foodId and declared date', () async {
      var s = Sessions(await DraftDatabase.open(file, keys));
      await s.initialize();
      await s.enter(DraftJourney.solo);
      final quantity = unit == PantryUnit.piece ? 9007199254740993 : 0.000000123456789;
      s.data.update(
        () => s.data.pantry.add(
          PantryDraft(
            name: 'unit fixture',
            quantity: quantity,
            unit: unit,
            unitLabel: 'original label',
            foodId: 'existing_food_id',
            location: PantryLocation.fridge,
            expiresOn: DateTime.utc(2028, 3, 26),
            expiryOrigin: ExpiryOrigin.userProvided,
          ),
        ),
      );
      await s.flush();
      final id = s.data.pantry.single.id;
      await s.close();
      s = Sessions(await DraftDatabase.open(file, keys));
      await s.initialize();
      await s.enter(DraftJourney.solo);
      final restored = s.data.pantry.single;
      expect(restored.id, id);
      expect(restored.quantity, quantity);
      expect(restored.quantity.runtimeType, quantity.runtimeType);
      expect(restored.unit, unit);
      expect(restored.unitLabel, 'original label');
      expect(restored.foodId, 'existing_food_id');
      expect(restored.toProductRecord().expiresOn, '2028-03-26');
      expect(restored.expiryOrigin, ExpiryOrigin.userProvided);
      await s.close();
    });
  }

  for (final journey in DraftJourney.values) {
    test('$journey: add, quick update, two identical lots, delete and reopen offline', () async {
      var s = Sessions(await DraftDatabase.open(file, keys));
      await s.initialize();
      await s.enter(journey);
      s.data.update(() {
        s.data.budgetEuros = 123;
        s.data.soloInputs['partial_fixture'] = '1,';
        s.data.pantry.addAll([
          PantryDraft(
            name: 'Synthetic rice',
            quantity: 0.125,
            unit: PantryUnit.kilogram,
            location: PantryLocation.pantry,
            foodId: 'rice_existing',
            expiresOn: DateTime(2028, 3, 26),
            expiryOrigin: ExpiryOrigin.userProvided,
          ),
          PantryDraft(
            name: 'Synthetic rice',
            quantity: null,
            unitLabel: 'original unit',
            location: PantryLocation.freezer,
            expiresOn: DateTime(2028, 10, 29),
            expiryOrigin: ExpiryOrigin.estimated,
          ),
        ]);
      });
      final ids = s.data.pantry.map((p) => p.id).toList();
      final l = lookupL(const Locale('fr'));
      s.data.declareQuickStock(QuickCategory.fruit, PantryLocation.fruitBasket, QuickStock.some, l);
      final quickId = s.data.pantry.last.id;
      s.data.declareQuickStock(QuickCategory.fruit, PantryLocation.fruitBasket, QuickStock.present, l);
      expect(s.data.pantry.last.id, quickId);
      await s.flush();
      final before = PantryDraftSection.read(
        (await s.db.load(journey == DraftJourney.solo ? 'guest.solo' : 'guest.family'))!,
      );
      await s.close();
      s = Sessions(await DraftDatabase.open(file, keys));
      await s.initialize();
      await s.enter(journey);
      expect(s.data.budgetEuros, 123);
      expect(s.data.pantry.map((p) => p.id), [...ids, quickId]);
      expect(
        PantryCodec.toMap(
          PantryPayload(journey: journey, items: s.data.pantry.map((p) => p.toProductRecord()).toList()),
        ),
        PantryCodec.toMap(before),
      );
      expect(s.data.pantry.last.quickStock, QuickStock.present);
      s.data.update(() => s.data.pantry.removeAt(0));
      await s.flush();
      await s.close();
      s = Sessions(await DraftDatabase.open(file, keys));
      await s.initialize();
      await s.enter(journey);
      expect(s.data.pantry.map((p) => p.id), [ids[1], quickId]);
      s.data.update(() => s.data.pantry.clear());
      await s.flush();
      await s.close();
      s = Sessions(await DraftDatabase.open(file, keys));
      await s.initialize();
      await s.enter(journey);
      expect(s.data.pantry, isEmpty);
      await s.close();
    });
  }

  test('repeated journey changes never mix pantry or onboarding answers', () async {
    var s = Sessions(await DraftDatabase.open(file, keys));
    await s.initialize();
    await s.enter(DraftJourney.solo);
    s.data.update(() {
      s.data.age = 46;
      s.data.pantry.add(PantryDraft(name: 'Solo fixture', location: PantryLocation.fridge));
    });
    await s.flush();
    await s.enter(DraftJourney.family);
    expect(s.data.pantry, isEmpty);
    s.data.update(() => s.data.pantry.add(PantryDraft(name: 'Family fixture', location: PantryLocation.pantry)));
    for (var i = 0; i < 8; i++) {
      await s.enter(DraftJourney.solo);
      expect(s.data.age, 46);
      expect(s.data.pantry.single.name, 'Solo fixture');
      await s.enter(DraftJourney.family);
      expect(s.data.pantry.single.name, 'Family fixture');
    }
    await s.flush();
    await s.close();
    s = Sessions(await DraftDatabase.open(file, keys));
    await s.initialize();
    await s.enter(DraftJourney.solo);
    expect(s.data.pantry.single.name, 'Solo fixture');
    await s.enter(DraftJourney.family);
    expect(s.data.pantry.single.name, 'Family fixture');
    await s.close();
  });

  test('record adapter keeps integer precision, null unit and unknown fields exactly', () {
    final record = PantryProductRecord(
      id: 'stable-fixture',
      name: 'Synthetic',
      quantity: 9007199254740993,
      unit: null,
      unitLabel: 'kg',
      location: PantryLocation.pantry,
      expiresOn: null,
      expiryOrigin: ExpiryOrigin.unknown,
      source: 'manual',
      foodId: 'legacy_food',
      declaredCategory: null,
      declaredStock: null,
      unknownFields: {
        'future': [
          1,
          {'nested': true},
        ],
      },
    );
    final restored = PantryDraft.fromProductRecord(record).toProductRecord();
    expect(restored.quantity, record.quantity);
    expect(restored.quantity, isA<int>());
    expect(restored.unit, isNull);
    expect(restored.unknownFields, record.unknownFields);
    final quick = PantryDraft.fromProductRecord(record).withQuickStock(QuickCategory.fruit, QuickStock.some);
    expect(quick.unit, isNull);
    expect(quick.quantity, record.quantity);
    expect(quick.unknownFields, record.unknownFields);
  });

  for (final fault in ['legacy', 'future', 'corrupt', 'owner']) {
    test('$fault payload blocks restoration and writes without erasing anything', () async {
      var s = Sessions(await DraftDatabase.open(file, keys));
      await s.initialize();
      await s.enter(DraftJourney.solo);
      await s.flush();
      final valid = (await s.db.load('guest.solo'))!;
      final answers = valid.answers;
      List<Map<String, Object?>> pantry;
      if (fault == 'legacy') {
        answers.remove('pantryPayloadVersion');
        pantry = [
          {'name': 'unrecognized fixture'},
        ];
      } else {
        final envelope = valid.pantry.single;
        if (fault == 'future') envelope['pantryVersion'] = 999;
        if (fault == 'corrupt') {
          envelope['items'] = [
            {'id': 'invalid'},
          ];
        }
        if (fault == 'owner') envelope['draftId'] = 'guest.family';
        pantry = [envelope];
      }
      final invalid = replace(valid, answers: answers, pantry: pantry);
      await s.close();
      final db = await DraftDatabase.open(file, keys);
      await db.save(invalid);
      final bytes = (await db.load('guest.solo'))!.encode();
      s = Sessions(db);
      s.data.pantry.add(PantryDraft(name: 'live fixture untouched', location: PantryLocation.fridge));
      final originalAnswers = s.data.exportSoloAnswers();
      await s.initialize();
      expect(s.solo.errorStage, 'load');
      expect(await s.solo.enter(), isFalse);
      expect(s.data.exportSoloAnswers(), originalAnswers);
      expect(s.data.pantry.single.name, 'live fixture untouched');
      expect(await s.solo.flush(), isFalse);
      final repo = EncryptedSoloDraftRepository(() async => db, ownsConnection: false);
      await expectLater(
        repo.save(replace(valid, updatedAt: valid.updatedAt.add(const Duration(days: 1)))),
        throwsA(anything),
      );
      expect((await db.load('guest.solo'))!.encode(), bytes);
      await s.close();
    });
  }

  test('stale checkpoint rejected; latest deletion cannot be resurrected', () async {
    final s = Sessions(await DraftDatabase.open(file, keys));
    await s.initialize();
    await s.enter(DraftJourney.solo);
    s.data.update(() => s.data.pantry.add(PantryDraft(name: 'fixture', location: PantryLocation.fridge)));
    await s.flush();
    final old = (await s.db.load('guest.solo'))!;
    s.data.update(() => s.data.pantry.clear());
    await s.flush();
    final latest = (await s.db.load('guest.solo'))!.encode();
    final repo = EncryptedSoloDraftRepository(() async => s.db, ownsConnection: false);
    await expectLater(repo.save(old), throwsA(isA<DraftStorageException>()));
    expect((await s.db.load('guest.solo'))!.encode(), latest);
    await s.close();
  });

  test('unknown Family section preserves both rows and all in-memory answers', () async {
    var s = Sessions(await DraftDatabase.open(file, keys));
    await s.initialize();
    await s.enter(DraftJourney.solo);
    s.data.update(() => s.data.pantry.add(PantryDraft(name: 'Solo fixture', location: PantryLocation.pantry)));
    await s.flush();
    await s.enter(DraftJourney.family);
    await s.flush();
    final family = (await s.db.load('guest.family'))!;
    final solo = (await s.db.load('guest.solo'))!.encode();
    await s.close();
    final db = await DraftDatabase.open(file, keys);
    final invalid = replace(
      family,
      pantry: [
        {...family.pantry.single, 'pantryVersion': 999},
      ],
    );
    await db.save(invalid);
    s = Sessions(db);
    await s.initialize();
    s.data.startMode(AppMode.foyer);
    final before = s.data.exportFamilyAnswers();
    expect(await s.family.enter(), isFalse);
    expect(s.family.errorStage, 'load');
    expect(s.data.exportFamilyAnswers(), before);
    expect(await s.family.flush(), isFalse);
    expect((await db.load('guest.family'))!.encode(), invalid.encode());
    expect((await db.load('guest.solo'))!.encode(), solo);
    await s.close();
  });

  test('invalid live duplicate IDs block save without resetting live or committed products', () async {
    final s = Sessions(await DraftDatabase.open(file, keys));
    await s.initialize();
    await s.enter(DraftJourney.family);
    final product = PantryDraft(name: 'fixture', location: PantryLocation.fridge);
    s.data.update(() => s.data.pantry.add(product));
    await s.flush();
    final committed = (await s.db.load('guest.family'))!.encode();
    s.data.update(() => s.data.pantry.add(product));
    expect(s.family.errorStage, 'save');
    expect(await s.family.flush(), isFalse);
    expect(s.data.pantry.length, 2);
    expect((await s.db.load('guest.family'))!.encode(), committed);
    s.data.update(() => s.data.pantry.removeLast());
    await s.flush();
    await s.close();
  });

  test('future envelope and product extensions survive stock updates and saves', () async {
    var s = Sessions(await DraftDatabase.open(file, keys));
    await s.initialize();
    await s.enter(DraftJourney.family);
    s.data.declareQuickStock(
      QuickCategory.fruit,
      PantryLocation.fruitBasket,
      QuickStock.some,
      lookupL(const Locale('fr')),
    );
    await s.flush();
    final draft = (await s.db.load('guest.family'))!;
    await s.close();
    final map = draft.pantry.single;
    map['futureEnvelope'] = {
      'nested': [42],
    };
    (map['items'] as List).single['futureItem'] = ['retained'];
    final db = await DraftDatabase.open(file, keys);
    await db.save(
      replace(
        draft,
        pantry: [map],
        answers: {
          ...draft.answers,
          'futureAnswer': {'retained': true},
          'acceptedAnswers': {
            ...draft.answers['acceptedAnswers'] as Map,
            'futureAcceptedAnswer': [42],
          },
        },
      ),
    );
    s = Sessions(db);
    await s.initialize();
    await s.enter(DraftJourney.family);
    s.data.declareQuickStock(
      QuickCategory.fruit,
      PantryLocation.fruitBasket,
      QuickStock.present,
      lookupL(const Locale('de')),
    );
    await s.flush();
    final saved = (await db.load('guest.family'))!.pantry.single;
    expect(saved['futureEnvelope'], {
      'nested': [42],
    });
    expect((saved['items'] as List).single['futureItem'], ['retained']);
    final answers = (await db.load('guest.family'))!.answers;
    expect(answers['futureAnswer'], {'retained': true});
    expect((answers['acceptedAnswers'] as Map)['futureAcceptedAnswer'], [42]);
    await s.close();
  });

  test('forced termination during pantry+answers transaction restores committed snapshot offline', () async {
    final s = Sessions(await DraftDatabase.open(file, keys));
    await s.initialize();
    await s.enter(DraftJourney.solo);
    s.data.update(
      () => s.data.pantry.add(
        PantryDraft(
          name: 'committed fixture',
          quantity: 0.625,
          unit: PantryUnit.liter,
          location: PantryLocation.fridge,
        ),
      ),
    );
    await s.flush();
    final before = (await s.db.load('guest.solo'))!.encode();
    await s.close();
    final keyFile = File('${temp.path}/fixture-key');
    await keyFile.writeAsString(keys.value!);
    final dart = Platform.environment['MENOO_TEST_DART'];
    expect(dart, isNotNull);
    final child = await Process.start(dart!, [
      'run',
      'test/support/pantry_process_probe.dart',
      file.path,
      keyFile.path,
      'crash',
    ]);
    final ready = Completer<void>();
    final out = child.stdout.transform(utf8.decoder).transform(const LineSplitter()).listen((line) {
      if (line == 'transaction-pending' && !ready.isCompleted) ready.complete();
    });
    final err = child.stderr.drain<void>();
    try {
      await ready.future.timeout(const Duration(seconds: 50));
    } finally {
      child.kill();
      await child.exitCode;
      await out.cancel();
      await err;
    }
    final restored = await Process.run(dart, [
      'run',
      'test/support/pantry_process_probe.dart',
      file.path,
      keyFile.path,
      'read',
    ]);
    expect(restored.exitCode, 0, reason: restored.stderr.toString());
    expect(jsonDecode(restored.stdout.toString()), jsonDecode(before));
    final db = await DraftDatabase.open(file, keys);
    expect((await db.load('guest.solo'))!.encode(), before);
    await db.close();
  }, timeout: const Timeout(Duration(minutes: 2)));
}
