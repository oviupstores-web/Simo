import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'l10n/app_localizations.dart';
import 'l10n/locale_scope.dart';
import 'onboarding/onboarding_data.dart';
import 'onboarding/onboarding_scope.dart';
import 'screens/entry/landing_screen.dart';
import 'theme/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: AppColors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const MenooApp());
}

class MenooApp extends StatefulWidget {
  const MenooApp({super.key});

  @override
  State<MenooApp> createState() => _MenooAppState();
}

class _MenooAppState extends State<MenooApp> {
  /// Réponses de l'onboarding, partagées par tous les écrans du parcours.
  final _onboarding = OnboardingData();

  /// Langue choisie ; `null` = celle du téléphone. Provisoire jusqu'à l'écran Réglages (jalon 12).
  final _locale = ValueNotifier<Locale?>(null);

  @override
  void dispose() {
    _onboarding.dispose();
    _locale.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LocaleScope(
      controller: _locale,
      child: ValueListenableBuilder<Locale?>(
        valueListenable: _locale,
        builder: (context, locale, _) => MaterialApp(
          title: 'Menoo',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          locale: locale,
          supportedLocales: L.supportedLocales,
          localizationsDelegates: L.localizationsDelegates,
          builder: (context, child) => OnboardingScope(data: _onboarding, child: child!),
          home: const LandingScreen(),
        ),
      ),
    );
  }
}
