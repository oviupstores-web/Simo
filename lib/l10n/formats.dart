import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'app_localizations.dart';
import '../models/numeric_safety.dart';

/// Système d'unités. SPEC §10 : métrique par défaut, impérial aux États-Unis.
enum UnitSystem { metric, imperial }

/// Unités, devises et dates selon le pays. Le pays vient de la langue du téléphone
/// tant que l'écran Réglages n'existe pas (jalon 12), où il deviendra un choix explicite.
class Formats {
  Formats(this.locale, {UnitSystem? units, String? currency})
    : units = units ?? _defaultUnits(locale),
      currency = currency ?? _defaultCurrency(locale);

  final Locale locale;
  final UnitSystem units;

  /// Code ISO de la devise (EUR, USD…).
  final String currency;

  static Formats of(BuildContext context) => Formats(Localizations.localeOf(context));

  /// Seuls les États-Unis utilisent les unités impériales.
  static UnitSystem _defaultUnits(Locale locale) =>
      locale.countryCode == 'US' ? UnitSystem.imperial : UnitSystem.metric;

  static const _currencies = {
    'US': 'USD',
    'GB': 'GBP',
    'CH': 'CHF',
    'CA': 'CAD',
    'AU': 'AUD',
    'FR': 'EUR',
    'DE': 'EUR',
    'BE': 'EUR',
    'MA': 'MAD',
    'TN': 'TND',
    'DZ': 'DZD',
  };

  static String _defaultCurrency(Locale locale) => _currencies[locale.countryCode] ?? 'EUR';

  String get _tag => locale.toLanguageTag();

  /// Les dollars restent identifiables lorsque la région ne correspond pas à leur devise.
  String get currencySymbol {
    const home = {'USD': 'US', 'CAD': 'CA', 'AUD': 'AU'};
    if (home.containsKey(currency) && home[currency] != locale.countryCode) return currency;
    return NumberFormat.simpleCurrency(locale: _tag, name: currency).currencySymbol;
  }

  String wholeNumber(int amount) => amount.abs() > NumericSafety.maxExactInteger ? amount.toString() : number(amount);

  String priceWhole(int amount) => amount.abs() > NumericSafety.maxExactInteger
      ? '$amount $currency'
      : NumberFormat.currency(locale: _tag, name: currency, symbol: currencySymbol, decimalDigits: 0).format(amount);

  /// Prix depuis des centimes (la base stocke des centimes, décision du 2026-09-23).
  String price(int cents) =>
      NumberFormat.currency(locale: _tag, name: currency, symbol: currencySymbol).format(cents / 100);

  /// Prix sans les centimes, pour les gros montants (« 65 € »).
  String priceRounded(int cents) =>
      NumberFormat.currency(locale: _tag, name: currency, symbol: currencySymbol, decimalDigits: 0).format(cents / 100);

  /// Arrondit à [decimals] chiffres, puis enlève les zéros inutiles à droite
  /// (75 kg, jamais 75,0 kg ; 0,75 kg/semaine mais 0,5, jamais 0,50 — comme les anciens
  /// `OnboardingData.formatKg` et `formatRate`).
  String number(num value, {int decimals = 0}) {
    if (!value.isFinite || value.abs() > NumericSafety.maxExactInteger || decimals < 0 || decimals > 20) return '—';
    var effectiveDecimals = decimals;
    var rounded = num.parse(value.toStringAsFixed(decimals));
    while (effectiveDecimals > 0) {
      final lower = double.parse(rounded.toStringAsFixed(effectiveDecimals - 1));
      if (lower != rounded) break;
      effectiveDecimals--;
      rounded = lower;
    }
    return NumberFormat.decimalPatternDigits(locale: _tag, decimalDigits: effectiveDecimals).format(rounded);
  }

  /// « 14 septembre 2026 » en français, « September 14, 2026 » en anglais.
  String date(DateTime d) => DateFormat.yMMMMd(_tag).format(d);

  /// « 14 sept. » — format court des listes et des alertes.
  String dateShort(DateTime d) => DateFormat.MMMd(_tag).format(d);

  String weekday(DateTime d) => DateFormat.E(_tag).format(d);

  /// Nom du jour de la semaine, 1 = lundi. Traduit par intl, donc rien à écrire dans les ARB.
  String weekdayName(int weekday) => DateFormat.EEEE(_tag).format(DateTime(2024, 1, weekday));

  /// Poids : kilogrammes, ou livres aux États-Unis.
  String weight(L l, double kg) {
    final value = units == UnitSystem.metric ? kg : kg * 2.20462;
    if (!value.isFinite || value < 0 || value > NumericSafety.maxExactInteger) return l.numericValueUnavailable;
    return units == UnitSystem.metric
        ? l.unitKilograms(number(value, decimals: 1))
        : l.unitPounds(number(value, decimals: 1));
  }

  /// Rythme de poids par semaine (paliers de 0,25 kg) : plus de précision que [weight],
  /// pour distinguer 0,25 / 0,5 / 0,75.
  String rate(L l, double kgPerWeek) {
    final value = units == UnitSystem.metric ? kgPerWeek : kgPerWeek * 2.20462;
    if (!value.isFinite || value < 0 || value > NumericSafety.maxExactInteger) return l.numericValueUnavailable;
    return units == UnitSystem.metric
        ? l.unitKilograms(number(value, decimals: 2))
        : l.unitPounds(number(value, decimals: 2));
  }

  /// Taille : centimètres, ou pieds et pouces aux États-Unis.
  String height(L l, double cm) {
    if (!cm.isFinite || cm <= 0 || cm > NumericSafety.maxExactInteger) return l.numericValueUnavailable;
    if (units == UnitSystem.metric) return l.unitCentimeters(number(cm));
    final totalInches = cm / 2.54;
    final roundedInches = NumericSafety.round(totalInches);
    if (roundedInches == null) return l.numericValueUnavailable;
    return l.unitFeetInches(roundedInches ~/ 12, roundedInches % 12);
  }

  /// Masse d'un ingrédient : grammes, ou onces aux États-Unis.
  String mass(L l, double grams) =>
      units == UnitSystem.metric ? l.unitGrams(number(grams)) : l.unitOunces(number(grams / 28.3495, decimals: 1));

  /// Volume : millilitres, ou onces liquides aux États-Unis.
  String volume(L l, double ml) =>
      units == UnitSystem.metric ? l.unitMilliliters(number(ml)) : l.unitFluidOunces(number(ml / 29.5735, decimals: 1));
}
