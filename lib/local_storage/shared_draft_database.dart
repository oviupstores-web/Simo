import 'dart:async';

import 'draft_database.dart';

/// One native connection and one file lock for both local journeys.
class SharedDraftDatabase {
  SharedDraftDatabase(this._open);
  final Future<DraftDatabase> Function() _open;
  Future<DraftDatabase>? _opening;
  bool _closed = false;

  Future<DraftDatabase> database() {
    if (_closed) throw const DraftStorageException('storage_closed');
    return _opening ??= _open();
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    if (_opening != null) {
      try {
        await (await _opening!).close();
      } catch (_) {
        // An unsuccessful open has already released its lock.
      }
    }
  }
}
