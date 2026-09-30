import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menoo/l10n/app_localizations.dart';
import 'package:menoo/screens/entry/landing_screen.dart';
import 'package:menoo/screens/entry/login_screen.dart';
import 'package:menoo/screens/entry/path_choice_screen.dart';
import 'package:menoo/screens/entry/signup_screen.dart';
import 'package:menoo/screens/onboarding/cover_household_screen.dart';
import 'package:menoo/screens/onboarding/cover_solo_screen.dart';
import 'package:menoo/onboarding/onboarding_data.dart';
import 'package:menoo/onboarding/onboarding_scope.dart';
import 'package:menoo/theme/theme.dart';

/// Captures des écrans, pour vérifier la mise en forme dans une langue donnée.
/// Régénérer avec : flutter test test/golden_ar_test.dart --update-goldens
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

  final screens = <String, Widget>{
    '1_landing': const LandingScreen(),
    '2_path_choice': const PathChoiceScreen(),
    '3_cover_solo': const CoverSoloScreen(),
    '4_cover_household': const CoverHouseholdScreen(),
    '5_login': const LoginScreen(),
    '6_signup': const SignupScreen(),
  };

  for (final locale in [const Locale('ar'), const Locale('fr')]) {
    for (final entry in screens.entries) {
      testWidgets('${locale.languageCode} · ${entry.key}', (t) async {
        t.view.physicalSize = const Size(1080, 2400);
        t.view.devicePixelRatio = 2.75;
        addTearDown(t.view.reset);

        final data = OnboardingData();
        addTearDown(data.dispose);

        // Sans cela, les photos restent vides dans les captures : leur décodage est asynchrone.
        await t.runAsync(() async {
          for (final path in const [
            'assets/images/bowl_landing.jpg',
            'assets/images/cover_individual.jpg',
            'assets/images/cover_household.jpg',
            'assets/images/mode_solo.jpg',
            'assets/images/mode_famille.jpg',
            'assets/images/logo_96.png',
            'assets/images/leaf_a.png',
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
            home: OnboardingScope(data: data, child: entry.value),
          ),
        );
        await t.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/${locale.languageCode}_${entry.key}.png'),
        );
      });
    }
  }
}
