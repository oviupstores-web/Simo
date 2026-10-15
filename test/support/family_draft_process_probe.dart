import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:menoo/local_storage/draft_database.dart';
import 'package:menoo/local_storage/draft_key.dart';
import 'package:menoo/local_storage/local_draft.dart';
import 'package:menoo/local_storage/family_draft_repository.dart';

class SyntheticProcessKeys implements DraftKeyStore {
  SyntheticProcessKeys(this.value);
  final String value;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String key) async => throw StateError('synthetic_read_only');
}

Future<void> main(List<String> args) async {
  final db = await DraftDatabase.open(File(args[0]), SyntheticProcessKeys(await File(args[1]).readAsString()));
  final draft = (await db.load(FamilyDraftRepository.id))!;
  if (args[2] == 'crash') {
    await db.transaction(() async {
      final answers = draft.answers;
      answers['rawInputs'] = {
        ...Map<String, Object?>.from(answers['rawInputs'] as Map),
        'constraints.food': 'uncommitted',
      };
      await db.save(
        LocalDraft(
          id: draft.id,
          journey: draft.journey,
          step: draft.step,
          management: draft.management,
          currency: draft.currency,
          updatedAt: draft.updatedAt,
          answers: answers,
          pantry: draft.pantry,
        ),
      );
      stdout.writeln('family-transaction-pending');
      await Completer<void>().future;
    });
  } else {
    final expected = await File(args[3]).readAsString();
    if (jsonEncode(jsonDecode(draft.encode())) != jsonEncode(jsonDecode(expected))) exit(2);
    await db.close();
    stdout.writeln('family-restored-offline');
  }
}
