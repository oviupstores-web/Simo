import 'dart:convert';

import 'draft_database.dart';
import 'local_draft.dart';
import 'save_onboarding_draft.dart';

abstract interface class SoloDraftRepository {
  static const soloId = 'guest.solo';
  static const familyId = 'guest.family';
  Future<LocalDraft?> load();
  Future<void> save(LocalDraft draft);
  Future<void> close();
}

class EncryptedSoloDraftRepository implements SoloDraftRepository {
  EncryptedSoloDraftRepository(this._open, {this.ownsConnection = true});
  final bool ownsConnection;
  final Future<DraftDatabase> Function() _open;
  Future<DraftDatabase>? _opening;
  Future<DraftDatabase> _db() => _opening ??= _open();
  @override
  Future<LocalDraft?> load() async => (await _db()).load(SoloDraftRepository.soloId);
  @override
  Future<void> save(LocalDraft draft) async {
    if (draft.id != SoloDraftRepository.soloId || draft.journey != DraftJourney.solo) {
      throw const DraftStorageException('solo_identity_invalid');
    }
    await saveOnboardingDraft(await _db(), draft, 'soloPayloadVersion');
  }

  @override
  Future<void> close() async {
    if (ownsConnection && _opening != null) await (await _opening!).close();
  }
}

/// Stable deep copies for asynchronous writes: never serialize live Family edits.
Map<String, Object?> copySoloJson(Map<String, Object?> value) =>
    Map<String, Object?>.from(jsonDecode(jsonEncode(value)) as Map);
