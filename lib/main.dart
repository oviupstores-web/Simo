import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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

  @override
  void dispose() {
    _onboarding.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Menoo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: const Locale('fr', 'FR'),
      supportedLocales: const [Locale('fr', 'FR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      builder: (context, child) => OnboardingScope(data: _onboarding, child: child!),
      home: const LandingScreen(),
    );
  }
}
