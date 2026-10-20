import 'draft_database.dart';
import 'local_draft.dart';
import 'pantry_storage_guard.dart';

/// Answers and pantry are one encrypted, atomic checkpoint. Reading and checking
/// the existing row happen inside the same transaction as the replacement.
Future<void> saveOnboardingDraft(DraftDatabase db, LocalDraft draft, String answerVersionKey) async {
  await db.transaction(() async {
    if (draft.answers[answerVersionKey] != 1) throw const DraftStorageException('onboarding_format_unknown');
    PantryStorageGuard.validate(draft);
    final previous = await db.load(draft.id);
    if (previous != null) {
      if (previous.journey != draft.journey || previous.answers[answerVersionKey] != 1) {
        throw const DraftStorageException('onboarding_existing_format_unknown');
      }
      PantryStorageGuard.validate(previous);
      if (previous.answers.containsKey('pantryPayloadVersion') && !draft.answers.containsKey('pantryPayloadVersion')) {
        throw const DraftStorageException('pantry_downgrade_refused');
      }
      if (!draft.updatedAt.isAfter(previous.updatedAt) && draft.encode() != previous.encode()) {
        throw const DraftStorageException('onboarding_stale_checkpoint');
      }
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
        pantry: draft.pantry,
      ),
    );
  });
}
