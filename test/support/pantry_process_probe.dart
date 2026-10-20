import 'dart:async';
import 'dart:io';

import 'package:menoo/local_storage/draft_database.dart';
import 'package:menoo/local_storage/draft_key.dart';
import 'package:menoo/local_storage/local_draft.dart';
import 'package:menoo/local_storage/pantry_storage_guard.dart';
import 'package:menoo/local_storage/solo_draft_repository.dart';

class FixtureKeys implements DraftKeyStore {
  FixtureKeys(this.value);
  final String value;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String key) async => throw StateError('fixture read only');
}

Future<void> main(List<String> args) async {
  final db = await DraftDatabase.open(File(args[0]), FixtureKeys(await File(args[1]).readAsString()));
  final old = (await db.load('guest.solo'))!;
  if (args[2] == 'crash') {
    final repo = EncryptedSoloDraftRepository(() async => db, ownsConnection: false);
    await db.transaction(() async {
      await repo.save(
        LocalDraft(
          id: old.id,
          journey: old.journey,
          step: old.step,
          management: old.management,
          currency: old.currency,
          updatedAt: old.updatedAt.add(const Duration(days: 1)),
          answers: {...old.answers, 'synthetic_uncommitted': true},
          pantry: [
            {...old.pantry.single, 'items': []},
          ],
        ),
      );
      stdout.writeln('transaction-pending');
      await Completer<void>().future;
    });
  } else {
    PantryStorageGuard.validate(old);
    stdout.writeln(old.encode());
    await db.close();
  }
}
