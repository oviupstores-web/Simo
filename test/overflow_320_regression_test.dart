import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menoo/l10n/app_localizations.dart';
import 'package:menoo/onboarding/onboarding_data.dart';
import 'package:menoo/onboarding/onboarding_scope.dart';
import 'package:menoo/screens/entry/signup_screen.dart';
import 'package:menoo/screens/home/home_screen.dart';
import 'package:menoo/screens/menus/recipe_sheet_screen.dart';
import 'package:menoo/screens/onboarding/member_profiles_screen.dart';
import 'package:menoo/screens/onboarding/summary_screen.dart';
import 'package:menoo/screens/onboarding/weekly_grid_screen.dart';
import 'package:menoo/screens/pantry/pantry_add_manual_screen.dart';
import 'package:menoo/theme/theme.dart';

void main() {
  setUpAll(() async {
    Future<void> load(String family, List<String> files) async {
      final loader = FontLoader(family);
      for (final f in files) {
        final file = File('assets/fonts/$f');
        if (file.existsSync()) loader.addFont(Future.value(ByteData.sublistView(file.readAsBytesSync())));
      }
      await loader.load();
    }

    await load('PlusJakartaSans', [
      for (final w in [400, 500, 600, 700, 800]) 'PlusJakartaSans-$w.ttf',
    ]);
    await load('Caveat', ['Caveat-600.ttf']);
    await load('ReadexPro', [
      for (final w in [400, 500, 600, 700]) 'ReadexPro-$w.ttf',
    ]);
  });

  final screens = <String, Widget Function()>{
    'member_edit': () => MemberEditScreen(
      member: MemberDraft(
        id: 99,
        role: MemberRole.adulte,
        firstName: 'Test',
        age: 40,
        heightCm: 175,
        weightKg: 80,
        allergens: {'gluten', 'arachides'},
      ),
    ),
    'summary': () => const SummaryScreen(),
    'home': () => const HomeScreen(),
    'signup': () => const SignupScreen(),
    'recipe_sheet': () => const RecipeSheetScreen(),
    'weekly_grid': () => const WeeklyGridScreen(),
    'pantry_add_manual': () => const PantryAddManualScreen(),
  };

  for (final locale in [const Locale('fr'), const Locale('en'), const Locale('de')]) {
    for (final width in [320.0, 390.0]) {
      for (final entry in screens.entries) {
        testWidgets('${locale.languageCode} · ${entry.key} à ${width.toInt()} px sans overflow', (tester) async {
          tester.view.physicalSize = Size(width * 2.75, 2400);
          tester.view.devicePixelRatio = 2.75;
          addTearDown(tester.view.reset);

          final overflow = <String>[];
          final previousOnError = FlutterError.onError;
          FlutterError.onError = (details) {
            final message = details.exception.toString();
            if (message.contains('overflowed')) {
              overflow.add(details.toString());
            } else {
              previousOnError?.call(details);
            }
          };

          final data = OnboardingData();
          if (!['goal', 'profile', 'activity', 'smart_scale', 'cover_solo'].contains(entry.key)) {
            data.startMode(AppMode.foyer);
          }
          data.targetWeightKg = 70;
          addTearDown(data.dispose);
          try {
            await tester.pumpWidget(
              MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light,
                locale: locale,
                supportedLocales: L.supportedLocales,
                localizationsDelegates: L.localizationsDelegates,
                home: OnboardingScope(data: data, child: entry.value()),
              ),
            );
            await tester.pump(const Duration(milliseconds: 300));
          } finally {
            FlutterError.onError = previousOnError;
          }
          expect(overflow, isEmpty, reason: overflow.join('\n'));
        });
      }
    }
  }
}
