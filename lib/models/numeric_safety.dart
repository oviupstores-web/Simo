/// Garde-fous techniques ; aucune règle nutritionnelle.
abstract final class NumericSafety {
  /// Dernier entier exactement représentable par un double.
  static const maxExactInteger = 9007199254740991;

  static int? round(double value) => value.isFinite && value.abs() <= maxExactInteger ? value.round() : null;
}
