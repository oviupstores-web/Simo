import 'package:flutter/widgets.dart';

/// Languages enabled for the initial commercial launch.
///
/// Legacy ARB files stay in place so their translations can be reactivated later.
abstract final class AppLanguages {
  static const launchLocales = <Locale>[Locale('fr'), Locale('en'), Locale('de')];

  /// Resolves the chosen translation language while retaining the device region
  /// for locale-sensitive dates, numbers, units and currencies.
  static Locale resolve(Locale? preferred, Locale? device) {
    for (final candidate in [preferred, device]) {
      if (candidate == null || !launchLocales.any((locale) => locale.languageCode == candidate.languageCode)) {
        continue;
      }
      return Locale(candidate.languageCode, candidate.countryCode ?? device?.countryCode);
    }
    return Locale('en', device?.countryCode);
  }
}
