import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menoo/l10n/app_localizations.dart';
import 'package:menoo/l10n/app_languages.dart';
import 'package:menoo/onboarding/onboarding_data.dart';
import 'package:menoo/onboarding/onboarding_scope.dart';
import 'package:menoo/screens/entry/improv_coming_soon_screen.dart';
import 'package:menoo/screens/entry/landing_screen.dart';
import 'package:menoo/screens/entry/login_screen.dart';
import 'package:menoo/screens/entry/path_choice_screen.dart';
import 'package:menoo/screens/entry/signup_screen.dart';
import 'package:menoo/screens/home/home_screen.dart';
import 'package:menoo/screens/menus/recipe_sheet_screen.dart';
import 'package:menoo/screens/onboarding/activity_screen.dart';
import 'package:menoo/screens/onboarding/budget_screen.dart';
import 'package:menoo/screens/onboarding/constraints_screen.dart';
import 'package:menoo/screens/onboarding/cover_household_screen.dart';
import 'package:menoo/screens/onboarding/cover_solo_screen.dart';
import 'package:menoo/screens/onboarding/goal_screen.dart';
import 'package:menoo/screens/onboarding/household_size_screen.dart';
import 'package:menoo/screens/onboarding/kitchen_screen.dart';
import 'package:menoo/screens/onboarding/management_mode_screen.dart';
import 'package:menoo/screens/onboarding/member_profiles_screen.dart';
import 'package:menoo/screens/onboarding/onboarding_cuisines_screen.dart';
import 'package:menoo/screens/onboarding/profile_screen.dart';

import 'package:menoo/screens/onboarding/smart_scale_screen.dart';
import 'package:menoo/screens/onboarding/summary_screen.dart';
import 'package:menoo/screens/onboarding/weekly_grid_screen.dart';
import 'package:menoo/screens/pantry/pantry_add_manual_screen.dart';
import 'package:menoo/screens/pantry/pantry_home_screen.dart';
import 'package:menoo/screens/pantry/pantry_hub_onboarding_screen.dart';
import 'package:menoo/screens/pantry/pantry_quick_check_screen.dart';
import 'package:menoo/screens/pantry/pantry_scan_screens.dart';
import 'package:menoo/screens/shopping/shopping_list_screen.dart';
import 'package:menoo/theme/theme.dart';

/// Balaye tous les écrans dans les 3 langues du lancement et signale tout débordement de mise en page
/// (« A RenderFlex overflowed »). Les textes plus longs qu'en français (allemand, espagnol…)
/// sont la cause la plus fréquente : c'est ce test qui doit les attraper, pas l'œil.
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

  /// Chaque écran qui a besoin de OnboardingScope le reçoit d'un jeu de données par défaut
  /// (famille Martin / Karim, déjà utilisé par les autres tests). Les écrans qui prennent des
  /// paramètres reçoivent les valeurs les plus chargées en texte pour maximiser les chances
  /// de révéler un débordement.
  Map<String, Widget Function()> screens() => {
    'landing': () => const LandingScreen(),
    'improv_coming_soon': () => const ImprovComingSoonScreen(),
    'login': () => const LoginScreen(),
    'signup': () => const SignupScreen(),
    'path_choice': () => const PathChoiceScreen(),
    'cover_solo': () => const CoverSoloScreen(),
    'cover_household': () => const CoverHouseholdScreen(),
    'goal': () => const GoalScreen(),
    'activity': () => const ActivityScreen(),
    'management_mode': () => const ManagementModeScreen(),
    'household_size': () => const HouseholdSizeScreen(),
    'member_profiles': () => const MemberProfilesScreen(),
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
    'profile': () => const ProfileScreen(),
    'smart_scale': () => const SmartScaleScreen(),
    'weekly_grid': () => const WeeklyGridScreen(),
    'budget': () => const BudgetScreen(),
    'constraints': () => const ConstraintsScreen(),
    'onboarding_cuisines': () => const OnboardingCuisinesScreen(),
    'kitchen': () => const KitchenScreen(),
    'summary': () => const SummaryScreen(),
    'home': () => const HomeScreen(),
    'recipe_sheet': () => const RecipeSheetScreen(),
    'shopping_list': () => const ShoppingListScreen(),
    'pantry_add_manual': () => const PantryAddManualScreen(),
    'pantry_home': () => const PantryHomeScreen(),
    'pantry_hub_onboarding': () => PantryHubOnboardingScreen(onFinish: (_) {}),
    'pantry_quick_check': () => const PantryQuickCheckScreen(),
    'pantry_scan_barcode': () => const PantryScanScreen(),
    'pantry_scan_photo': () => const PantryPhotoAiScreen(),
  };

  const widths = [390.0];
  final locales = AppLanguages.launchLocales;

  final failures = <String>[];

  for (final locale in locales) {
    for (final width in widths) {
      for (final entry in screens().entries) {
        testWidgets('${locale.languageCode} · ${entry.key} à ${width.toInt()} px : pas de débordement', (tester) async {
          tester.view.physicalSize = Size(width * 2.75, 2400);
          tester.view.devicePixelRatio = 2.75;
          addTearDown(tester.view.reset);

          final overflow = <String>[];
          final originalOnError = FlutterError.onError;
          FlutterError.onError = (details) {
            final text = details.exception.toString();
            if (text.contains('overflowed')) {
              overflow.add(text.split('\n').first);
            } else {
              originalOnError?.call(details);
            }
          };

          final data = OnboardingData();
          // Foyer nécessaire pour les écrans qui en dépendent (household_size, member_*, weekly_grid…) ;
          // ça ne change rien pour les écrans Solo, qui ignorent isFoyer.
          data.startMode(AppMode.foyer);
          // reassurance_weight a besoin d'un poids visé cohérent (sinon weeksToTarget()/targetDate() sont nuls).
          data.targetWeightKg = 70;
          addTearDown(data.dispose);

          try {
            await tester.pumpWidget(
              MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light,
                locale: locale,
                supportedLocales: AppLanguages.launchLocales,
                localizationsDelegates: L.localizationsDelegates,
                home: OnboardingScope(data: data, child: entry.value()),
              ),
            );
            await tester.pump(const Duration(milliseconds: 300));
          } finally {
            FlutterError.onError = originalOnError;
          }

          if (overflow.isNotEmpty) {
            failures.add('${locale.languageCode} · ${entry.key} : ${overflow.join(' | ')}');
          }
          expect(overflow, isEmpty, reason: overflow.join('\n'));
        });
      }
    }
  }

  tearDownAll(() {
    if (failures.isNotEmpty) {
      // Résumé lisible d'un coup d'œil en plus des échecs individuels ci-dessus.
      // ignore: avoid_print
      print('\n=== Débordements trouvés (${failures.length}) ===\n${failures.join('\n')}');
    }
  });
}
