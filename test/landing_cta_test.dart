import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menoo/l10n/app_localizations.dart';
import 'package:menoo/screens/entry/landing_badge_cta.dart';
import 'package:menoo/screens/entry/landing_screen.dart';
import 'package:menoo/screens/entry/path_choice_screen.dart';
import 'package:menoo/theme/theme.dart';

class _Routes extends NavigatorObserver {
  int pushes = 0;
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) => pushes++;
}

void main() {
  setUpAll(() async {
    for (final family in ['PlusJakartaSans', 'ReadexPro']) {
      final loader = FontLoader(family);
      for (final weight in [400, 500, 600, 700, 800]) {
        final file = File('assets/fonts/$family-$weight.ttf');
        if (file.existsSync()) loader.addFont(Future.value(ByteData.sublistView(file.readAsBytesSync())));
      }
      await loader.load();
    }
  });

  Future<void> showLanding(WidgetTester t, double width, String lang, _Routes routes) async {
    t.view.physicalSize = Size(width, 900);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: Locale(lang),
        supportedLocales: L.supportedLocales,
        localizationsDelegates: L.localizationsDelegates,
        navigatorObservers: [routes],
        home: const LandingScreen(),
      ),
    );
    await t.runAsync(() => LandingScreen.prepareImages(t.element(find.byType(LandingScreen))));
    await t.pumpAndSettle();
  }

  for (final lang in ['fr', 'en', 'de', 'es', 'it', 'ar']) {
    for (final width in [320.0, 390.0]) {
      testWidgets('Landing provisoire $lang $width : cinq cartes et navigation', (t) async {
        final routes = _Routes();
        await showLanding(t, width, lang, routes);
        expect(find.byType(LandingBadgeCta), findsNothing);
        Rect? previous;
        for (final art in ['scan', 'meal_scan', 'menus', 'shopping', 'tracking']) {
          final card = find.byKey(ValueKey('landing_card_$art'));
          final pill = find.byKey(ValueKey('landing_pill_$art'));
          expect(card, findsOneWidget);
          expect(pill, findsOneWidget);
          final rect = t.getRect(card);
          expect(rect.left, closeTo(20, .01));
          expect(rect.right, closeTo(width - 20, .01));
          if (previous != null) expect(rect.top - previous.bottom, closeTo(16, .01));
          previous = rect;
          final ink = t.element(card).findAncestorWidgetOfExactType<InkWell>()!;
          expect(ink.onTap != null, art == 'menus' || art == 'shopping');
        }
        for (final art in ['scan', 'meal_scan', 'menus', 'shopping', 'tracking']) {
          final image = t.widget<Image>(find.descendant(
            of: find.byKey(ValueKey('landing_card_$art')), matching: find.byType(Image),
          ));
          expect((image.image as AssetImage).assetName, 'assets/images/landing/${art}_20261013_1258.png');
          expect(image.fit, BoxFit.contain);
        }
        await t.pump(const Duration(seconds: 3));
        expect(routes.pushes, 1, reason: 'Aucune navigation automatique');
        expect(t.takeException(), isNull);
        await t.pumpWidget(const SizedBox());
      });
    }
  }

  for (final target in ['scan', 'meal_scan', 'menus', 'shopping', 'tracking', 'start']) {
    testWidgets('Navigation actuelle préservée : $target', (t) async {
      final routes = _Routes();
      await showLanding(t, 1080 / 2.75, 'fr', routes);
      final control = target == 'start' ? find.text('Commencer') : find.byKey(ValueKey('landing_pill_$target'));
      await t.ensureVisible(control);
      await t.pumpAndSettle();
      await t.tap(control);
      await t.pumpAndSettle();
      final active = ['menus', 'shopping', 'start'].contains(target);
      expect(routes.pushes, active ? 2 : 1, reason: 'Une seule route si le bouton était déjà actif');
      expect(find.byType(PathChoiceScreen), active ? findsOneWidget : findsNothing);
      expect(t.takeException(), isNull);
      await t.pumpWidget(const SizedBox());
    });
  }
}
