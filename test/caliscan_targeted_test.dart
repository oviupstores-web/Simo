import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menoo/l10n/app_localizations.dart';
import 'package:menoo/screens/entry/landing_screen.dart';
import 'package:menoo/theme/theme.dart';

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
  for (final lang in ['fr', 'en', 'de', 'es', 'it', 'ar']) {
    for (final width in [320.0, 390.0]) {
      testWidgets('CaliScan courant $lang $width : cadrage, bordure et hauteur naturelle', (t) async {
        t.view.physicalSize = Size(width, 2200);
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.reset);
        await t.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            locale: Locale(lang),
            supportedLocales: L.supportedLocales,
            localizationsDelegates: L.localizationsDelegates,
            home: const LandingScreen(),
          ),
        );
        await t.runAsync(() => LandingScreen.prepareImages(t.element(find.byType(LandingScreen))));
        await t.pumpAndSettle();
        final cardFinder = find.byKey(const ValueKey('landing_card_meal_scan'));
        final surface = t.widget<Container>(find.ancestor(of: cardFinder, matching: find.byType(Container)).first);
        final decoration = surface.decoration! as BoxDecoration;
        expect((decoration.borderRadius! as BorderRadius).topLeft.x, 12);
        expect(surface.clipBehavior, Clip.antiAlias, reason: 'CaliScan content stays inside rounded corners');
        final photo = find.descendant(of: cardFinder, matching: find.byType(Image));
        expect(photo, findsOneWidget);
        expect((t.widget<Image>(photo).image as AssetImage).assetName, 'assets/images/landing/meal_scan_20261013_1258.png');
        expect(t.widget<Image>(photo).fit, BoxFit.contain);
        expect(t.element(photo).findAncestorWidgetOfExactType<ShaderMask>(), isNull);
        final r = t.getRect(cardFinder);
        final imageRect = t.getRect(photo);
        expect(imageRect.left, greaterThanOrEqualTo(r.left - .01));
        expect(imageRect.right, lessThanOrEqualTo(r.right + .01));
        final cta = t.getRect(find.byKey(const ValueKey('landing_cta_meal_scan')));
        expect(imageRect.top - cta.bottom, closeTo(12, .01));
        final l = L.of(t.element(find.byType(LandingScreen)));
        expect(find.text(l.landingCardMealScanTitle), findsOneWidget);
        expect(find.text(l.landingCardMealScanText), findsOneWidget);
        expect(t.takeException(), isNull);
        await t.pumpWidget(const SizedBox());
      });
    }
  }
}
