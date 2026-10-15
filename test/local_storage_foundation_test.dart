import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:menoo/local_storage/draft_database.dart';
import 'package:menoo/local_storage/draft_key_store.dart';
import 'package:menoo/local_storage/local_draft.dart';
import 'package:sqlite3/sqlite3.dart';

class MemoryKeys implements DraftKeyStore {
  String? value;
  bool failWrite = false;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String key) async {
    if (!failWrite) value = key;
  }
}

class NoCipherDatabase implements Database {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #select) return ResultSet([], null, []);
    throw StateError('No writes permitted without a cipher');
  }
}

LocalDraft sample({String id = 'guest', int step = 4, DraftJourney journey = DraftJourney.solo}) => LocalDraft(
  id: id,
  journey: journey,
  step: step,
  management: DraftManagement.mixed,
  updatedAt: DateTime.utc(2026, 10, 14),
  answers: {
    'allergies': ['peanut'],
    'budget': 65,
    'weight': 75.2,
    'futureField': 'keep',
  },
  pantry: [
    {
      'product': 'lentils',
      'quantity': 2.5,
      'unit': 'kg',
      'location': 'cupboard',
      'date': '2026-11-02',
      'dateSource': 'manual',
    },
  ],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory temporary;
  late File file;
  late MemoryKeys keys;
  setUp(() async {
    temporary = await Directory.systemTemp.createTemp('menoo_cipher_test_');
    file = File('${temporary.path}/draft.sqlite');
    keys = MemoryKeys();
  });
  tearDown(() async {
    await temporary.delete(recursive: true);
  });

  test('engine with no encryption capability is refused before any write', () {
    expect(() => requireCipher(NoCipherDatabase()), throwsA(isA<DraftStorageException>()));
  });

  test('Android secure storage namespace and reset policy passed to plugin', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return call.method == 'read' ? 'synthetic' : null;
    });
    try {
      final androidKeys = AndroidDraftKeyStore();
      expect(await androidKeys.read(), 'synthetic');
      await androidKeys.write('synthetic');
      expect(calls.map((c) => c.method), ['read', 'write']);
      for (final call in calls) {
        final options = (call.arguments as Map)['options'] as Map;
        expect(options['storageNamespace'], 'menoo_draft_keys');
        expect(options['resetOnError'], 'false');
        expect(options['migrateWithBackup'], 'false');
      }
    } finally {
      debugDefaultTargetPlatformOverride = null;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
    }
  });

  test('duplicate opens and orphan journals fail without discarding anything', () async {
    final db = await DraftDatabase.open(file, keys);
    try {
      await expectLater(DraftDatabase.open(file, keys), throwsA(isA<DraftStorageException>()));
    } finally {
      await db.close();
    }
    final orphan = File('${temporary.path}/orphan.sqlite-journal');
    await orphan.writeAsString('synthetic interrupted journal');
    await expectLater(
      DraftDatabase.open(File('${temporary.path}/orphan.sqlite'), keys),
      throwsA(isA<DraftStorageException>()),
    );
    expect(await orphan.readAsString(), 'synthetic interrupted journal');
  });

  test('encrypted disk, no plaintext or key, restored with same key', () async {
    final db = await DraftDatabase.open(file, keys);
    final draft = sample();
    await db.save(draft);
    await db.close();
    final bytes = await file.readAsBytes();
    expect(ascii.decode(bytes.take(16).toList(), allowInvalid: true), isNot('SQLite format 3\u0000'));
    final disk = latin1.decode(bytes);
    expect(disk.contains('peanut'), isFalse);
    expect(disk.contains(keys.value!), isFalse);
    final withoutKey = sqlite3.open(file.path, mode: OpenMode.readOnly);
    try {
      expect(() => withoutKey.select('SELECT * FROM sqlite_master'), throwsA(isA<SqliteException>()));
    } finally {
      withoutKey.close();
    }
    final reopened = await DraftDatabase.open(file, keys);
    try {
      expect((await reopened.load('guest'))!.encode(), draft.encode());
    } finally {
      await reopened.close();
    }
  });

  test('wrong key blocks and preserves original file', () async {
    final db = await DraftDatabase.open(file, keys);
    await db.save(sample());
    await db.close();
    final original = await file.readAsBytes();
    final goodKey = keys.value;
    keys.value = createDraftKey();
    await expectLater(DraftDatabase.open(file, keys), throwsA(isA<DraftStorageException>()));
    expect(await file.readAsBytes(), original);
    keys.value = goodKey;
    final reopened = await DraftDatabase.open(file, keys);
    try {
      expect(await reopened.load('guest'), isNotNull);
    } finally {
      await reopened.close();
    }
  });

  test('missing key never regenerates for existing database', () async {
    final db = await DraftDatabase.open(file, keys);
    await db.save(sample());
    await db.close();
    keys.value = null;
    await expectLater(DraftDatabase.open(file, keys), throwsA(isA<DraftStorageException>()));
    expect(keys.value, isNull);
  });

  test('plaintext database is rejected without conversion or deletion', () async {
    final plain = sqlite3.open(file.path);
    plain.execute('CREATE TABLE legacy (id INTEGER)');
    plain.close();
    final original = await file.readAsBytes();
    await expectLater(DraftDatabase.open(file, keys), throwsA(isA<DraftStorageException>()));
    expect(await file.readAsBytes(), original);
    expect(keys.value, isNull);
  });

  test('failed key persistence creates no database', () async {
    keys.failWrite = true;
    await expectLater(DraftDatabase.open(file, keys), throwsA(isA<DraftStorageException>()));
    expect(await file.exists(), isFalse);
  });

  test('transaction rollback preserves previous snapshot', () async {
    final db = await DraftDatabase.open(file, keys);
    try {
      await db.save(sample());
      Iterable<LocalDraft> interrupted() sync* {
        yield sample(step: 5);
        throw StateError('simulated interruption');
      }

      await expectLater(db.saveAll(interrupted()), throwsA(isA<DraftStorageException>()));
      expect((await db.load('guest'))!.step, 4);
      await db.saveAll([sample(step: 6), sample(id: 'family', journey: DraftJourney.family)]);
      expect((await db.load('guest'))!.step, 6);
      expect((await db.load('family'))!.journey, DraftJourney.family);
    } finally {
      await db.close();
    }
  });

  test('future schema is rejected and preserved', () async {
    final db = await DraftDatabase.open(file, keys);
    await db.customStatement('PRAGMA user_version = 99');
    await db.close();
    final original = await file.readAsBytes();
    await expectLater(DraftDatabase.open(file, keys), throwsA(isA<DraftStorageException>()));
    expect(await file.readAsBytes(), original);
  });

  test('future payload refuses read without overwrite', () async {
    final db = await DraftDatabase.open(file, keys);
    try {
      await db.save(sample());
      final future = jsonDecode(sample().encode()) as Map<String, dynamic>;
      future['formatVersion'] = 99;
      await db.customStatement('UPDATE local_drafts SET payload = ?', [jsonEncode(future)]);
      await expectLater(db.load('guest'), throwsA(isA<DraftStorageException>()));
      await expectLater(db.save(sample()), throwsA(isA<DraftStorageException>()));
      final raw = await db.customSelect('SELECT payload FROM local_drafts').getSingle();
      expect(raw.read<String>('payload'), jsonEncode(future));
    } finally {
      await db.close();
    }
  });

  test('forced process termination rolls back and fresh process restores offline', () async {
    final db = await DraftDatabase.open(file, keys);
    await db.save(sample());
    await db.close();
    final fixtureKey = File('${temporary.path}/synthetic-key.txt');
    await fixtureKey.writeAsString(keys.value!);
    final dart = Platform.environment['MENOO_TEST_DART'];
    expect(dart, isNotNull, reason: 'Explicit Dart SDK required for process recovery test');
    final child = await Process.start(dart!, [
      'run',
      'test/support/draft_process_probe.dart',
      file.path,
      fixtureKey.path,
      'crash',
    ], workingDirectory: Directory.current.path);
    final ready = Completer<void>();
    final errorOutput = StringBuffer();
    final out = child.stdout.transform(utf8.decoder).transform(const LineSplitter()).listen((line) {
      if (line == 'transaction-pending' && !ready.isCompleted) ready.complete();
    });
    final err = child.stderr.transform(utf8.decoder).listen(errorOutput.write);
    try {
      await ready.future.timeout(const Duration(seconds: 50));
      child.kill();
      await child.exitCode.timeout(const Duration(seconds: 10));
    } finally {
      child.kill();
      await out.cancel();
      await err.cancel();
    }
    final restored = await Process.run(dart, [
      'run',
      'test/support/draft_process_probe.dart',
      file.path,
      fixtureKey.path,
      'restore',
    ], workingDirectory: Directory.current.path);
    expect(restored.exitCode, 0, reason: 'Fresh process recovery failed');
    expect(restored.stdout.toString(), contains('restored'));
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('invalid envelope and nonfinite sources rejected, returned JSON is isolated', () {
    expect(() => sample(step: 10, journey: DraftJourney.family), throwsFormatException);
    expect(
      () => LocalDraft(
        id: 'guest',
        journey: DraftJourney.solo,
        step: 1,
        management: DraftManagement.shopping,
        answers: {'weight': double.nan},
        pantry: [],
        updatedAt: DateTime.now(),
      ),
      throwsA(isA<JsonUnsupportedObjectError>()),
    );
    final draft = sample();
    final answers = draft.answers;
    answers['budget'] = 0;
    expect(draft.answers['budget'], 65);
    expect(draft.currency, 'EUR');
    expect(createDraftKey(), matches(RegExp(r'^[0-9a-f]{64}$')));
  });
}
