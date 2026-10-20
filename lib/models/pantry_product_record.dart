import 'dart:math';

import 'pantry_location.dart';
import 'pantry_values.dart';

/// Allocate only when creating a new lot. Decoding never allocates an identity.
String createPantryProductId() {
  final random = Random.secure();
  return 'pr_${List.generate(16, (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0')).join()}';
}

/// An immutable JSON copy; mutable inputs and returned children cannot alter it.
Object? freezePantryJson(Object? value) {
  if (value == null || value is String || value is bool || value is int) return value;
  if (value is double && value.isFinite) return value;
  if (value is List) return List<Object?>.unmodifiable(value.map(freezePantryJson));
  if (value is Map && value.keys.every((key) => key is String)) {
    return Map<String, Object?>.unmodifiable({
      for (final entry in value.entries) entry.key as String: freezePantryJson(entry.value),
    });
  }
  throw const FormatException('pantry_json_invalid');
}

Map<String, Object?> freezePantryFields(Map<String, Object?> fields) =>
    freezePantryJson(fields) as Map<String, Object?>;

/// Exact calendar date, without UTC conversion, normalization or a guessed date.
bool isPantryCivilDate(String value) {
  if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) return false;
  final year = int.parse(value.substring(0, 4));
  final month = int.parse(value.substring(5, 7));
  final day = int.parse(value.substring(8, 10));
  if (year < 1 || month < 1 || month > 12 || day < 1) return false;
  final date = DateTime.utc(year, month, day);
  return date.year == year && date.month == month && date.day == day;
}

/// Standalone storage model: deliberately not connected to PantryDraft or widgets.
/// Quantity retains its numeric representation; no scaling or unit inference.
class PantryProductRecord {
  PantryProductRecord({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.unitLabel,
    required this.location,
    required this.expiresOn,
    required this.expiryOrigin,
    required this.source,
    required this.foodId,
    required this.declaredCategory,
    required this.declaredStock,
    Map<String, Object?> unknownFields = const {},
  }) : unknownFields = freezePantryFields(unknownFields) {
    if (!RegExp(r'^[A-Za-z0-9][A-Za-z0-9._:-]{0,127}$').hasMatch(id) ||
        name.trim().isEmpty ||
        source.trim().isEmpty ||
        (foodId != null && foodId!.trim().isEmpty) ||
        (quantity != null && (!quantity!.isFinite || quantity! < 0)) ||
        (expiresOn != null && !isPantryCivilDate(expiresOn!)) ||
        (expiresOn == null && expiryOrigin != ExpiryOrigin.unknown)) {
      throw const FormatException('pantry_product_invalid');
    }
  }

  final String id;
  final String name;
  final num? quantity;
  final PantryUnit? unit;
  final String unitLabel;
  final PantryLocation location;
  final String? expiresOn;
  final ExpiryOrigin expiryOrigin;
  final String source;
  final String? foodId;
  final QuickCategory? declaredCategory;
  final QuickStock? declaredStock;
  final Map<String, Object?> unknownFields;
}
