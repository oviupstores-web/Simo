import 'dart:convert';

/// Provisional UI values live in the owner's encrypted onboarding answers, never
/// in the validated pantry product list. Unknown compatible fields round-trip.
class PantryFormCheckpoint {
  const PantryFormCheckpoint({this.manual, this.quick, this.unknownFields = const {}});

  static const version = 1;
  // Wire values are intentionally plain strings: this codec must also run in
  // the standalone Dart crash probe, where dart:ui is unavailable.
  static const units = {'piece', 'gram', 'kilogram', 'milliliter', 'liter', 'pack'};
  static const categories = {'fruits', 'legumes', 'laitiers', 'viandes', 'epicerie', 'sucre', 'surgeles'};
  static const locations = {'fridge', 'fruitBasket', 'pantry', 'freezer'};
  static const quickCategories = {
    'pastaRice',
    'oilCondiments',
    'eggsDairy',
    'cansSauce',
    'freshVeg',
    'fruit',
    'flourSugar',
    'spicesHerbs',
    'frozenMeatFish',
  };
  final Map<String, Object?>? manual;
  final Map<String, Object?>? quick;
  final Map<String, Object?> unknownFields;

  factory PantryFormCheckpoint.read(Object? raw) {
    if (raw == null) return const PantryFormCheckpoint();
    if (raw is! Map) throw const FormatException('pantry_form_invalid');
    final json = Map<String, Object?>.from(raw);
    if (json['version'] != version) throw const FormatException('pantry_form_version_unknown');
    final manual = _section(json['manual']);
    final quick = _section(json['quick']);
    if (manual != null) _validateManual(manual);
    if (quick != null) _validateQuick(quick);
    return PantryFormCheckpoint(
      manual: manual,
      quick: quick,
      unknownFields: Map.of(json)
        ..remove('version')
        ..remove('manual')
        ..remove('quick'),
    );
  }

  Map<String, Object?> toJson() => Map<String, Object?>.from(
    jsonDecode(
      jsonEncode({
        ...unknownFields,
        'version': version,
        if (manual != null) 'manual': manual,
        if (quick != null) 'quick': quick,
      }),
    ) as Map,
  );

  PantryFormCheckpoint withManual(Map<String, Object?>? value) {
    final merged = value == null ? null : {...?manual, ...value};
    if (merged != null) _validateManual(merged);
    return PantryFormCheckpoint(manual: merged, quick: quick, unknownFields: unknownFields);
  }

  PantryFormCheckpoint withQuick(Map<String, Object?>? value) {
    final merged = value == null ? null : {...?quick, ...value};
    if (merged != null) _validateQuick(merged);
    return PantryFormCheckpoint(manual: manual, quick: merged, unknownFields: unknownFields);
  }

  static Map<String, Object?>? _section(Object? raw) {
    if (raw == null) return null;
    if (raw is! Map) throw const FormatException('pantry_form_section_invalid');
    return Map<String, Object?>.from(raw);
  }

  static void _validateManual(Map<String, Object?> value) {
    if (value['name'] is! String ||
        value['quantityText'] is! String ||
        value['unit'] is! String ||
        value['quantityEdited'] is! bool ||
        value['categoryManual'] is! bool ||
        value['locationManual'] is! bool ||
        value['expiresManual'] is! bool) {
      throw const FormatException('pantry_manual_invalid');
    }
    final quantity = value['quantity'];
    if (quantity is! num || !quantity.isFinite || quantity <= 0) throw const FormatException('pantry_quantity_invalid');
    if (!units.contains(value['unit'])) throw const FormatException('pantry_unit_invalid');
    for (final key in ['category', 'proposedCategory']) {
      if (value[key] != null && !categories.contains(value[key])) {
        throw const FormatException('pantry_category_invalid');
      }
    }
    for (final key in ['location', 'proposedLocation']) {
      if (value[key] != null && !locations.contains(value[key])) {
        throw const FormatException('pantry_location_invalid');
      }
    }
    final date = value['expiresOn'];
    if (date != null && (date is! String || !_validCivilDate(date))) {
      throw const FormatException('pantry_date_invalid');
    }
    if (value['fieldContext'] is! String) throw const FormatException('pantry_field_context_invalid');
    if (!const ['name', 'quantity', 'unit', 'category', 'location', 'expiresOn'].contains(value['fieldContext'])) {
      throw const FormatException('pantry_field_context_invalid');
    }
    final expectedOrigin = date == null
        ? 'unknown'
        : value['expiresManual'] == true
        ? 'userProvided'
        : 'estimated';
    if (value['expiryOrigin'] != expectedOrigin) throw const FormatException('pantry_expiry_origin_invalid');
  }

  static bool _validCivilDate(String value) {
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) return false;
    final date = DateTime.tryParse(value);
    return date != null &&
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}' ==
            value;
  }

  static void _validateQuick(Map<String, Object?> value) {
    for (final entry in value.entries) {
      if (!quickCategories.contains(entry.key) || !const ['none', 'present', 'some'].contains(entry.value)) {
        throw const FormatException('pantry_quick_invalid');
      }
    }
  }
}
