import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menoo/l10n/app_localizations.dart';
import 'package:menoo/onboarding/onboarding_data.dart';
import 'package:menoo/onboarding/onboarding_scope.dart';
import 'package:menoo/screens/pantry/pantry_home_screen.dart';
import 'package:menoo/theme/theme.dart';

/// Capture de l'écran Réserve (boutons Manuel / Scan / Photo IA) dans 3 langues,
/// pour vérifier la correction du débordement de texte.
/// Régénérer avec : flutter test test/golden_pantry_test.dart --update-goldens
void main() {
  setUpAll(() async {
    Future<void> load(String family, List<String> files) async {
      final loader = FontLoader(family);
      for (final f in files) {
        loader.addFont(Future.value(ByteData.sublistView(File('assets/fonts/$f').readAsBytesSync())));
      }
      await loader.load();
    }

    await load('PlusJakartaSans', [for (final w in [400, 500, 600, 700, 800]) 'PlusJakartaSans-$w.ttf']);
    await load('Caveat', ['Caveat-600.ttf']);
    await load('ReadexPro', [for (final w in [400, 500, 600, 700]) 'ReadexPro-$w.ttf']);
  });

  for (final locale in [const Locale('fr'), const Locale('de'), const Locale('ar')]) {
    testWidgets('${locale.languageCode} · pantry_home', (t) async {
      t.view.physicalSize = const Size(1080, 2400);
      t.view.devicePixelRatio = 2.75;
      addTearDown(t.view.reset);

      final data = OnboardingData();
      addTearDown(data.dispose);

      await t.runAsync(() async {
        for (final path in const [
          'assets/images/p_poulet.jpg',
          'assets/images/p_yaourt.jpg',
          'assets/images/p_lait.jpg',
          'assets/images/p_carotte.jpg',
          'assets/images/i_citron.jpg',
          'assets/images/i_tomates.jpg',
          'assets/images/i_quinoa.jpg',
          'assets/images/i_huile.jpg',
          'assets/images/i_brocoli.jpg',
          'assets/images/logo_96.png',
        ]) {
          await precacheImage(AssetImage(path), t.binding.rootElement!);
        }
      });

      await t.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          locale: locale,
          supportedLocales: L.supportedLocales,
          localizationsDelegates: L.localizationsDelegates,
          home: OnboardingScope(data: data, child: const PantryHomeScreen()),
        ),
      );
      await t.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/${locale.languageCode}_pantry_home.png'),
      );
    });
  }
}
