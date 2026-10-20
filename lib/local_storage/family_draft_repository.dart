import 'draft_database.dart';
import 'local_draft.dart';
import 'save_onboarding_draft.dart';
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
    await saveOnboardingDraft(await _db(), draft, 'familyPayloadVersion');
  }

  @override
  Future<void> close() async {
    if (ownsConnection && _opening != null) await (await _opening!).close();
  }
}
