import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menoo/l10n/app_localizations.dart';
import 'package:menoo/l10n/app_languages.dart';
import 'package:menoo/l10n/locale_preferences.dart';
import 'package:menoo/main.dart';
import 'package:flutter/material.dart';
// The platform adapter is a transitive dependency of shared_preferences.
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
  });
  for (final locale in AppLanguages.launchLocales) {
    testWidgets('restarted Menoo receives saved ${locale.languageCode} before its first frame', (tester) async {
      await LocalePreferences().save(locale);
      final restored = await LocalePreferences().load();
      await tester.pumpWidget(MenooApp(initialLocale: restored));
      expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).locale, locale);
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    });
    test('language ${locale.languageCode} survives a new preference instance', () async {
      final firstLaunch = LocalePreferences();
      expect(await firstLaunch.load(), isNull);
      await firstLaunch.save(locale);
      final restartedApp = LocalePreferences();
      expect(await restartedApp.load(), locale);
      final translations = await L.delegate.load(locale);
      expect(translations.localeName, locale.languageCode);
      expect(translations.languageName, lookupL(locale).languageName);
      expect(translations.landingStart, isNotEmpty);
    });
  }
  test('unsupported historical language is not restored or selectable', () async {
    SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.withData({LocalePreferences.key: 'ar'});
    expect(await LocalePreferences().load(), isNull);
    expect(() => LocalePreferences().save(const Locale('ar')), throwsArgumentError);
  });
}
