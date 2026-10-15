import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'draft_database.dart';
import 'draft_key_store.dart';

/// Explicit factory only: never called from startup or onboarding in this milestone.
Future<DraftDatabase> openAndroidDraftStorage() async {
  if (!Platform.isAndroid) throw const DraftStorageException('androidRequired');
  final directory = await getApplicationSupportDirectory();
  return DraftDatabase.open(File('${directory.path}/menoo_local_drafts/drafts.sqlite'), AndroidDraftKeyStore());
}
