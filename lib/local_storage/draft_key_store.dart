import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'draft_key.dart';
export 'draft_key.dart';

/// Separate namespace, no automatic reset of encrypted preferences on error.
final class AndroidDraftKeyStore implements DraftKeyStore {
  static const namespace = 'menoo_draft_keys';
  static const _keyId = 'draft_database_key_v1';
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(storageNamespace: namespace, resetOnError: false, migrateWithBackup: false),
  );

  @override
  Future<String?> read() => _storage.read(key: _keyId);
  @override
  Future<void> write(String key) => _storage.write(key: _keyId, value: key);
}
