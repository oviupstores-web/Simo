import 'local_draft.dart';

/// Flutter-free storage boundary. The session also decodes with PantryCodec
/// before changing live data. Keep wire codes aligned through the parity tests.
abstract final class PantryStorageGuard {
  static const units = {'piece', 'gram', 'kilogram', 'milliliter', 'liter', 'pack'};
  static const locations = {'fridge', 'fruit_basket', 'pantry', 'freezer'};
  static const categories = {
    'pasta_rice_starches',
    'oil_condiments',
    'eggs_dairy',
    'canned_sauce',
    'fresh_vegetables',
    'fruits',
    'flour_sugar',
    'spices_herbs',
    'frozen_meat_fish',
  };
  static void validate(LocalDraft draft) {
    final owner = draft.journey == DraftJourney.solo ? 'guest.solo' : 'guest.family';
    if (draft.id != owner) _invalid();
    final list = draft.pantry;
    final answers = draft.answers;
    if (!answers.containsKey('pantryPayloadVersion')) {
      if (list.isNotEmpty) _invalid();
      return;
    }
    if (answers['pantryPayloadVersion'] is! int || answers['pantryPayloadVersion'] != 1 || list.length != 1) _invalid();
    final payload = list.single;
    if (payload['pantryVersion'] is! int ||
        payload['pantryVersion'] != 1 ||
        payload['journey'] != draft.journey.name ||
        payload['draftId'] != owner ||
        payload['items'] is! List) {
      _invalid();
    }
    final ids = <String>{};
    for (final raw in payload['items'] as List) {
      if (raw is! Map) _invalid();
      final item = raw;
      final id = item['id'];
      if (id is! String || !RegExp(r'^[A-Za-z0-9][A-Za-z0-9._:-]{0,127}$').hasMatch(id) || !ids.add(id)) _invalid();
      for (final key in ['name', 'source']) {
        if (item[key] is! String || (item[key] as String).trim().isEmpty) _invalid();
      }
      if (item['unitLabel'] is! String) _invalid();
      final q = item['quantity'];
      if (q != null && (q is! num || !q.isFinite || q < 0)) _invalid();
      if (item['unit'] != null && !units.contains(item['unit'])) _invalid();
      if (!locations.contains(item['location'])) _invalid();
      if (item['foodId'] != null && (item['foodId'] is! String || (item['foodId'] as String).trim().isEmpty)) {
        _invalid();
      }
      if (item['declaredCategory'] != null && !categories.contains(item['declaredCategory'])) _invalid();
      if (item['declaredStock'] != null && !{'some', 'present'}.contains(item['declaredStock'])) _invalid();
      if (!{'unknown', 'estimated', 'userProvided'}.contains(item['expiryOrigin'])) _invalid();
      final date = item['expiresOn'];
      if (date == null) {
        if (item['expiryOrigin'] != 'unknown') _invalid();
      } else {
        if (date is! String || !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(date)) _invalid();
        final parsed = DateTime.tryParse(date);
        if (parsed == null ||
            parsed.year < 1 ||
            parsed.year != int.parse(date.substring(0, 4)) ||
            parsed.month != int.parse(date.substring(5, 7)) ||
            parsed.day != int.parse(date.substring(8, 10))) {
          _invalid();
        }
      }
    }
  }

  static Never _invalid() => throw const FormatException('pantry_storage_invalid');
}
