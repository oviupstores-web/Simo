import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_languages.dart';

/// Only the language code is stored; the device still supplies the region.
class LocalePreferences {
  LocalePreferences() : _preferences = SharedPreferencesAsync();
  final SharedPreferencesAsync _preferences;
  static const key = 'menoo.language';

  Future<Locale?> load() async {
    final code = await _preferences.getString(key);
    return AppLanguages.launchLocales.any((locale) => locale.languageCode == code) ? Locale(code!) : null;
  }

  Future<void> save(Locale locale) async {
    if (!AppLanguages.launchLocales.contains(Locale(locale.languageCode))) {
      throw ArgumentError.value(locale, 'locale');
    }
    await _preferences.setString(key, locale.languageCode);
  }
}
