import 'dart:math';

abstract interface class DraftKeyStore {
  Future<String?> read();
  Future<void> write(String key);
}

String createDraftKey() {
  final random = Random.secure();
  return List.generate(32, (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
}

bool isValidDraftKey(String value) => RegExp(r'^[0-9a-f]{64}$').hasMatch(value);
