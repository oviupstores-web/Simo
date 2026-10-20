import '../onboarding/onboarding_data.dart';
import 'local_draft.dart';
import 'pantry_codec.dart';

/// The single versioned pantry envelope is stored in LocalDraft's existing list.
/// No SQLite schema change, guesses about historical rows or unit conversions.
abstract final class PantryDraftSection {
  static PantryPayload read(LocalDraft draft) {
    final answers = draft.answers;
    if (!answers.containsKey('pantryPayloadVersion')) {
      return PantryCodec.readLegacyDraft(draft, expectedJourney: draft.journey);
    }
    if (answers['pantryPayloadVersion'] is! int || answers['pantryPayloadVersion'] != PantryCodec.version) {
      throw const FormatException('pantry_version_unsupported');
    }
    final section = draft.pantry;
    if (section.length != 1) throw const FormatException('pantry_section_invalid');
    return PantryCodec.fromMap(section.single, expectedJourney: draft.journey);
  }

  static PantryPayload capture(DraftJourney journey, List<PantryDraft> items, LocalDraft? previous) {
    final old = previous == null ? null : read(previous);
    if (old != null && old.journey != journey) throw const FormatException('pantry_owner_mismatch');
    return PantryPayload(
      journey: journey,
      items: [for (final item in items) item.toProductRecord()],
      unknownFields: old?.unknownFields ?? const {},
    );
  }

  static List<PantryDraft> restore(PantryPayload payload) => [
    for (final item in payload.items) PantryDraft.fromProductRecord(item),
  ];
}
