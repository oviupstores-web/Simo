import 'dart:convert';

import '../models/pantry_location.dart';
import '../models/pantry_product_record.dart';
import '../models/pantry_values.dart';
import 'local_draft.dart';

/// A section version independent from the unchanged LocalDraft/SQLite versions.
class PantryPayload {
  PantryPayload({
    required this.journey,
    required List<PantryProductRecord> items,
    Map<String, Object?> unknownFields = const {},
  }) : items = List.unmodifiable(items),
       unknownFields = freezePantryFields(unknownFields) {
    if (items.map((item) => item.id).toSet().length != items.length) {
      throw const FormatException('pantry_duplicate_id');
    }
  }
  final DraftJourney journey;
  final List<PantryProductRecord> items;
  final Map<String, Object?> unknownFields;
  String get draftId => journey == DraftJourney.solo ? 'guest.solo' : 'guest.family';
}

/// No I/O, mutations of LocalDraft, random IDs during reads or legacy guesses.
abstract final class PantryCodec {
  static const version = 1;
  static const _envelopeKeys = {'pantryVersion', 'journey', 'draftId', 'items'};
  static const _itemKeys = {
    'id',
    'name',
    'quantity',
    'unit',
    'unitLabel',
    'location',
    'expiresOn',
    'expiryOrigin',
    'source',
    'foodId',
    'declaredCategory',
    'declaredStock',
  };

  static String encode(PantryPayload payload) => jsonEncode(toMap(payload));

  static Map<String, Object?> toMap(PantryPayload payload) {
    _noConflicts(payload.unknownFields, _envelopeKeys);
    return {
      ...payload.unknownFields,
      'pantryVersion': version,
      'journey': payload.journey.name,
      'draftId': payload.draftId,
      'items': [for (final item in payload.items) _encodeItem(item)],
    };
  }

  static PantryPayload decode(String json, {required DraftJourney expectedJourney}) {
    Object? raw;
    try {
      raw = jsonDecode(json);
    } on FormatException {
      // jsonDecode otherwise includes fragments of personal input in errors.
      throw const FormatException('pantry_json_invalid');
    }
    return fromMap(_map(raw), expectedJourney: expectedJourney);
  }

  static PantryPayload fromMap(Map<String, Object?> value, {required DraftJourney expectedJourney}) {
    if (value['pantryVersion'] is! int || value['pantryVersion'] != version) {
      throw const FormatException('pantry_version_unsupported');
    }
    final expectedId = expectedJourney == DraftJourney.solo ? 'guest.solo' : 'guest.family';
    if (value['journey'] != expectedJourney.name || value['draftId'] != expectedId) {
      throw const FormatException('pantry_owner_mismatch');
    }
    final raw = value['items'];
    if (raw is! List) throw const FormatException('pantry_items_invalid');
    // Finish validating every item before exposing any result to the caller.
    final items = [for (final item in raw) _decodeItem(_map(item))];
    return PantryPayload(journey: expectedJourney, items: items, unknownFields: _unknown(value, _envelopeKeys));
  }

  /// Old production code has no product serialization contract. Only an empty
  /// legacy field is unambiguous. Nonempty unversioned data stays unreadable,
  /// never converted, merged or silently replaced with an empty list.
  static PantryPayload readLegacyDraft(LocalDraft draft, {required DraftJourney expectedJourney}) {
    final expectedId = expectedJourney == DraftJourney.solo ? 'guest.solo' : 'guest.family';
    if (draft.journey != expectedJourney || draft.id != expectedId) {
      throw const FormatException('pantry_owner_mismatch');
    }
    if (draft.answers.containsKey('pantryPayloadVersion')) {
      throw const FormatException('pantry_legacy_versioned');
    }
    if (draft.pantry.isNotEmpty) throw const FormatException('pantry_legacy_unrecognized');
    return PantryPayload(journey: expectedJourney, items: const []);
  }

  static Map<String, Object?> _encodeItem(PantryProductRecord item) {
    _noConflicts(item.unknownFields, _itemKeys);
    return {
      ...item.unknownFields,
      'id': item.id,
      'name': item.name,
      'quantity': item.quantity,
      'unit': item.unit?.id,
      'unitLabel': item.unitLabel,
      'location': item.location.dbValue,
      'expiresOn': item.expiresOn,
      'expiryOrigin': item.expiryOrigin.name,
      'source': item.source,
      'foodId': item.foodId,
      'declaredCategory': item.declaredCategory?.id,
      'declaredStock': item.declaredStock?.name,
    };
  }

  static PantryProductRecord _decodeItem(Map<String, Object?> item) {
    if (!_itemKeys.every(item.containsKey)) throw const FormatException('pantry_field_missing');
    final quantity = item['quantity'];
    if (quantity != null && quantity is! num) throw const FormatException('pantry_quantity_invalid');
    return PantryProductRecord(
      id: _string(item['id']),
      name: _string(item['name']),
      quantity: quantity as num?,
      unit: item['unit'] == null ? null : _enum<PantryUnit>(item['unit'], PantryUnit.values, (v) => v.id),
      unitLabel: _string(item['unitLabel']),
      location: _enum<PantryLocation>(item['location'], PantryLocation.values, (v) => v.dbValue),
      expiresOn: _nullableString(item['expiresOn']),
      expiryOrigin: _enum<ExpiryOrigin>(item['expiryOrigin'], ExpiryOrigin.values, (v) => v.name),
      source: _string(item['source']),
      foodId: _nullableString(item['foodId']),
      declaredCategory: item['declaredCategory'] == null
          ? null
          : _enum<QuickCategory>(item['declaredCategory'], QuickCategory.values, (v) => v.id),
      declaredStock: item['declaredStock'] == null
          ? null
          : _enum<QuickStock>(item['declaredStock'], QuickStock.values, (v) => v.name),
      unknownFields: _unknown(item, _itemKeys),
    );
  }

  static Map<String, Object?> _map(Object? raw) {
    if (raw is! Map || raw.keys.any((key) => key is! String)) throw const FormatException('pantry_object_invalid');
    return Map<String, Object?>.from(raw);
  }

  static String _string(Object? value) {
    if (value is! String) throw const FormatException('pantry_string_invalid');
    return value;
  }

  static String? _nullableString(Object? value) => value == null ? null : _string(value);
  static T _enum<T>(Object? raw, List<T> values, String Function(T) code) {
    for (final value in values) {
      if (code(value) == raw) return value;
    }
    throw const FormatException('pantry_code_unknown');
  }

  static Map<String, Object?> _unknown(Map<String, Object?> raw, Set<String> keys) => {
    for (final entry in raw.entries)
      if (!keys.contains(entry.key)) entry.key: entry.value,
  };
  static void _noConflicts(Map<String, Object?> raw, Set<String> keys) {
    if (raw.keys.any(keys.contains)) throw const FormatException('pantry_reserved_field');
  }
}
