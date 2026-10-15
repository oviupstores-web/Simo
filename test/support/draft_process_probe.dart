import 'dart:async';
import 'dart:io';

import 'package:menoo/local_storage/draft_database.dart';
import 'package:menoo/local_storage/draft_key.dart';
import 'package:menoo/local_storage/local_draft.dart';

// Synthetic fixture only; production uses Android secure storage exclusively.
class FixtureKey implements DraftKeyStore {
  final String value;
  FixtureKey(this.value);
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String key) async => throw StateError('fixture read only');
}

Future<void> main(List<String> args) async {
  final db = await DraftDatabase.open(File(args[0]), FixtureKey(await File(args[1]).readAsString()));
  if (args[2] == 'crash') {
    await db.transaction(() async {
      await db.save(
        LocalDraft(
          id: 'guest',
          journey: DraftJourney.solo,
          step: 8,
          management: DraftManagement.mixed,
          answers: {'synthetic': true},
          pantry: [],
          updatedAt: DateTime.utc(2026, 10, 14),
        ),
      );
      stdout.writeln('transaction-pending');
      await Completer<void>().future;
    });
  } else {
    final draft = await db.load('guest');
    await db.close();
    if (draft?.step != 4) exit(2);
    stdout.writeln('restored');
  }
}
