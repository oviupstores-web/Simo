import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'l10n/app_localizations.dart';
import 'l10n/app_languages.dart';
import 'l10n/formats.dart';
import 'l10n/locale_scope.dart';
import 'l10n/locale_preferences.dart';
import 'onboarding/onboarding_data.dart';
import 'onboarding/onboarding_scope.dart';
import 'onboarding/solo_draft_session.dart';
import 'onboarding/solo_draft_navigation.dart';
import 'local_storage/android_draft_storage.dart';
import 'local_storage/solo_draft_repository.dart';
import 'local_storage/shared_draft_database.dart';
import 'local_storage/draft_checkpoint_clock.dart';
import 'local_storage/family_draft_repository.dart';
import 'onboarding/family_draft_session.dart';
import 'onboarding/family_draft_navigation.dart';
import 'screens/entry/landing_screen.dart';
import 'screens/entry/startup_screen.dart';
import 'theme/theme.dart';

Future<void> main() async {
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
  final preferences = LocalePreferences();
  Locale? initialLocale;
  try {
    initialLocale = await preferences.load();
  } catch (error) {
    debugPrint(error.toString());
  }
  final storage = Platform.isAndroid ? SharedDraftDatabase(openAndroidDraftStorage) : null;
  final data = OnboardingData();
  final clock = DraftCheckpointClock();
  final solo = storage != null
      ? SoloDraftSession(
          data,
          EncryptedSoloDraftRepository(storage.database, ownsConnection: false),
          familyEnabled: true,
          clock: clock,
        )
      : null;
  final family = storage != null
      ? FamilyDraftSession(data, EncryptedFamilyDraftRepository(storage.database, ownsConnection: false), clock: clock)
      : null;
  runApp(
    MenooApp(
      initialLocale: initialLocale,
      localePreferences: preferences,
      soloDraft: solo,
      familyDraft: family,
      draftStorage: storage,
    ),
  );
}

class MenooApp extends StatefulWidget {
  const MenooApp({
    super.key,
    this.initialLocale,
    this.localePreferences,
    this.soloDraft,
    this.familyDraft,
    this.draftStorage,
  });
  final Locale? initialLocale;
  final LocalePreferences? localePreferences;
  final SoloDraftSession? soloDraft;
  final FamilyDraftSession? familyDraft;
  final SharedDraftDatabase? draftStorage;

  @override
  State<MenooApp> createState() => _MenooAppState();
}

class _MenooAppState extends State<MenooApp> with WidgetsBindingObserver {
  /// Réponses de l'onboarding, partagées par tous les écrans du parcours.
  late final OnboardingData _onboarding;
  SoloDraftRouteObserver? _soloObserver;
  FamilyDraftRouteObserver? _familyObserver;
  Future<void>? _soloReady;
  final _startupDone = ValueNotifier(false);

  /// Langue choisie ; `null` = celle du téléphone. Provisoire jusqu'à l'écran Réglages (jalon 12).
  final _locale = ValueNotifier<Locale?>(null);

  @override
  void initState() {
    super.initState();
    _onboarding = widget.soloDraft?.data ?? widget.familyDraft?.data ?? OnboardingData();
    assert(widget.familyDraft == null || identical(widget.familyDraft!.data, _onboarding));
    if (widget.soloDraft != null) {
      _soloObserver = SoloDraftRouteObserver(widget.soloDraft!);
      _soloReady = Future.wait([
        widget.soloDraft!.initialize(),
        if (widget.familyDraft != null) widget.familyDraft!.initialize(),
      ]);
      if (widget.familyDraft != null) _familyObserver = FamilyDraftRouteObserver(widget.familyDraft!);
      WidgetsBinding.instance.addObserver(this);
    }
    _locale.value = widget.initialLocale;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_closeDrafts());
    _startupDone.dispose();
    _onboarding.dispose();
    _locale.dispose();
    super.dispose();
  }

  Future<void> _closeDrafts() async {
    await Future.wait([
      if (widget.soloDraft != null) widget.soloDraft!.close(),
      if (widget.familyDraft != null) widget.familyDraft!.close(),
    ]);
    await widget.draftStorage?.close();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed && widget.soloDraft != null) {
      unawaited(widget.soloDraft!.flush());
      if (widget.familyDraft != null) unawaited(widget.familyDraft!.flush());
    }
  }

  @override
  Widget build(BuildContext context) {
    return LocaleScope(
      controller: _locale,
      saveLocale: widget.localePreferences?.save,
      child: ValueListenableBuilder<Locale?>(
        valueListenable: _locale,
        builder: (context, locale, _) => MaterialApp(
          title: 'Menoo',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          locale: locale,
          supportedLocales: AppLanguages.launchLocales,
          localizationsDelegates: L.localizationsDelegates,
          navigatorObservers: [?_soloObserver, ?_familyObserver],
          // Une langue que nous ne proposons pas (japonais, polonais…) retombe sur
          // l'anglais, jamais sur le français : SPEC §10.
          localeResolutionCallback: (_, _) =>
              AppLanguages.resolve(locale, WidgetsBinding.instance.platformDispatcher.locales.firstOrNull),
          builder: (context, child) {
            _onboarding.initializeBudgetCurrency(Formats.of(context).currency);
            return OnboardingScope(
              data: _onboarding,
              soloDraft: widget.soloDraft,
              familyDraft: widget.familyDraft,
              child: child!,
            );
          },
          home: MenooStartup(
            prepare: LandingScreen.prepareImages,
            ready: _soloReady,
            onDismissed: widget.soloDraft == null ? null : () => _startupDone.value = true,
            child: widget.soloDraft == null
                ? const LandingScreen()
                : SoloDraftResumeHost(
                    session: widget.soloDraft!,
                    observer: _soloObserver!,
                    family: widget.familyDraft,
                    familyObserver: _familyObserver,
                    startupDone: _startupDone,
                    child: const LandingScreen(),
                  ),
          ),
        ),
      ),
    );
  }
}
