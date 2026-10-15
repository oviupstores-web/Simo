import 'dart:io';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart' as sql;

import 'draft_key.dart';
import 'local_draft.dart';

/// Intentionally omits native errors, SQL, keys and personal payloads.
class DraftStorageException implements Exception {
  final String code;
  const DraftStorageException(this.code);
  @override
  String toString() => 'DraftStorageException($code)';
}

void requireCipher(sql.Database database) {
  final rows = database.select('PRAGMA cipher');
  if (rows.isEmpty) throw const DraftStorageException('cipherUnavailable');
  database.execute("PRAGMA cipher = 'chacha20'");
  if (database.select('PRAGMA cipher').single.values.single != 'chacha20') {
    throw const DraftStorageException('cipherUnavailable');
  }
}

/// A tiny SQL schema owned explicitly by Drift's migration/transaction engine.
/// No generated mapping or screen model is needed for the versioned JSON envelope.
class DraftDatabase extends GeneratedDatabase {
  DraftDatabase._(super.executor, this._lock, this._path);
  static final Set<String> _openPaths = {};
  final RandomAccessFile _lock;
  final String _path;
  bool _closed = false;

  @override
  int get schemaVersion => 1;
  @override
  Iterable<TableInfo<Table, Object?>> get allTables => const [];
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (_) => customStatement('''
      CREATE TABLE local_drafts (
        id TEXT PRIMARY KEY NOT NULL,
        format_version INTEGER NOT NULL CHECK(format_version = 1),
        payload TEXT NOT NULL
      )
    '''),
    onUpgrade: (_, _, _) => throw const DraftStorageException('unsupportedSchema'),
    beforeOpen: (details) async {
      if (details.versionNow != schemaVersion) {
        throw const DraftStorageException('unsupportedSchema');
      }
    },
  );

  /// The file lock covers key generation and the complete connection lifetime.
  /// Existing files are never deleted, converted or replaced on any open error.
  static Future<DraftDatabase> open(File file, DraftKeyStore keys) async {
    final path = file.absolute.path;
    if (!_openPaths.add(path)) throw const DraftStorageException('alreadyOpen');
    RandomAccessFile? lock;
    sql.Database? raw;
    DraftDatabase? result;
    try {
      final probe = sql.sqlite3.openInMemory();
      try {
        requireCipher(probe);
      } finally {
        probe.close();
      }
      await file.parent.create(recursive: true);
      lock = await File('${file.path}.lock').open(mode: FileMode.append);
      await lock.lock(FileLock.exclusive);
      final existing =
          await file.exists() ||
          await File('${file.path}-wal').exists() ||
          await File('${file.path}-journal').exists() ||
          await File('${file.path}-shm').exists();
      if (existing && !await file.exists()) throw const DraftStorageException('invalidDatabase');
      if (await file.exists()) {
        final reader = await file.open();
        try {
          final header = await reader.read(16);
          if (ascii.decode(header, allowInvalid: true) == 'SQLite format 3\u0000') {
            throw const DraftStorageException('unencryptedDatabase');
          }
          if (header.length < 16) throw const DraftStorageException('invalidDatabase');
        } finally {
          await reader.close();
        }
      }
      var key = await keys.read();
      if (key == null) {
        if (existing) throw const DraftStorageException('missingKey');
        key = createDraftKey();
        await keys.write(key);
        if (await keys.read() != key) throw const DraftStorageException('keyNotPersisted');
      }
      if (!isValidDraftKey(key)) throw const DraftStorageException('invalidKey');
      raw = sql.sqlite3.open(file.path);
      requireCipher(raw);
      // Only a validated, random hexadecimal key can enter this pragma.
      raw.execute("PRAGMA key = '$key'");
      raw.select('SELECT count(*) FROM sqlite_master');
      if (raw.select('PRAGMA user_version').single.values.single != 0 &&
          raw.select('PRAGMA user_version').single.values.single != 1) {
        throw const DraftStorageException('unsupportedSchema');
      }
      raw.execute('PRAGMA temp_store = MEMORY');
      raw.execute('PRAGMA journal_mode = DELETE');
      raw.execute('PRAGMA synchronous = FULL');
      raw.execute('PRAGMA secure_delete = ON');
      raw.execute('PRAGMA busy_timeout = 5000');
      if (raw.select('PRAGMA integrity_check').single.values.single != 'ok') {
        throw const DraftStorageException('invalidDatabase');
      }
      result = DraftDatabase._(NativeDatabase.opened(raw, logStatements: false), lock, path);
      raw = null; // Drift now owns the native connection.
      await result.customSelect('SELECT count(*) AS count FROM local_drafts').getSingle();
      return result;
    } catch (error) {
      if (result != null) {
        await result.close();
      } else {
        raw?.close();
        await lock?.close();
        _openPaths.remove(path);
      }
      if (error is DraftStorageException) rethrow;
      throw const DraftStorageException('openFailed');
    }
  }

  Future<void> save(LocalDraft draft) => saveAll([draft]);

  /// All snapshots commit together, or none do (including encoding failures).
  Future<void> saveAll(Iterable<LocalDraft> drafts) async {
    try {
      await transaction(() async {
        for (final draft in drafts) {
          // Do not overwrite an unreadable or future-version snapshot.
          await load(draft.id);
          await customStatement(
            '''
            INSERT INTO local_drafts (id, format_version, payload) VALUES (?, ?, ?)
            ON CONFLICT(id) DO UPDATE SET format_version=excluded.format_version, payload=excluded.payload
          ''',
            [draft.id, LocalDraft.currentFormat, draft.encode()],
          );
        }
      });
    } catch (_) {
      throw const DraftStorageException('saveFailed');
    }
  }

  Future<LocalDraft?> load(String id) async {
    try {
      final row = await customSelect(
        'SELECT format_version, payload FROM local_drafts WHERE id = ?',
        variables: [Variable<String>(id)],
      ).getSingleOrNull();
      if (row == null) return null;
      if (row.read<int>('format_version') != LocalDraft.currentFormat) {
        throw const DraftStorageException('unsupportedFormat');
      }
      return LocalDraft.decode(row.read<String>('payload'));
    } catch (error) {
      if (error is DraftStorageException) rethrow;
      throw const DraftStorageException('readFailed');
    }
  }

  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    try {
      await super.close();
    } finally {
      try {
        await _lock.close();
      } finally {
        _openPaths.remove(_path);
      }
    }
  }
}
