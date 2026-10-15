import 'draft_database.dart';
import 'local_draft.dart';
import 'solo_draft_repository.dart';

abstract interface class FamilyDraftRepository {
  static const id = SoloDraftRepository.familyId;
  Future<LocalDraft?> load();
  Future<void> save(LocalDraft draft);
  Future<void> close();
}

class EncryptedFamilyDraftRepository implements FamilyDraftRepository {
  EncryptedFamilyDraftRepository(this._open, {this.ownsConnection = true});
  final Future<DraftDatabase> Function() _open;
  final bool ownsConnection;
  Future<DraftDatabase>? _opening;
  Future<DraftDatabase> _db() => _opening ??= _open();

  @override
  Future<LocalDraft?> load() async => (await _db()).load(FamilyDraftRepository.id);

  @override
  Future<void> save(LocalDraft draft) async {
    if (draft.id != FamilyDraftRepository.id || draft.journey != DraftJourney.family) {
      throw const DraftStorageException('family_identity_invalid');
    }
    final db = await _db();
    await db.transaction(() async {
      final previous = await db.load(FamilyDraftRepository.id);
      if (previous != null &&
          (previous.journey != DraftJourney.family || previous.answers['familyPayloadVersion'] != 1)) {
        throw const DraftStorageException('family_existing_format_unknown');
      }
      await db.save(
        LocalDraft(
          id: draft.id,
          journey: draft.journey,
          step: draft.step,
          management: draft.management,
          currency: draft.currency,
          updatedAt: draft.updatedAt,
          answers: {...?previous?.answers, ...draft.answers},
          pantry: previous?.pantry ?? draft.pantry,
        ),
      );
    });
  }

  @override
  Future<void> close() async {
    if (ownsConnection && _opening != null) await (await _opening!).close();
  }
}
