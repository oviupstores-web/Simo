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
      testWidgets('CaliScan historique $lang $width : cadrage, bordure et hauteur naturelle', (t) async {
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
        final card = t.widget<Container>(cardFinder);
        expect(card.constraints!.minHeight, closeTo(276 * width / LandingTokens.referenceWidth, .01));
        final decoration = card.decoration! as BoxDecoration;
        expect((decoration.border! as Border).top.color, LandingTokens.mealScanBorder);
        final photo = find.byWidgetPredicate(
          (w) =>
              w is Image && w.image is AssetImage && (w.image as AssetImage).assetName == LandingTokens.mealScanAsset,
        );
        expect(photo, findsOneWidget);
        expect(t.widget<Image>(photo).fit, BoxFit.cover);
        expect(t.element(photo).findAncestorWidgetOfExactType<ShaderMask>(), isNotNull);
        final borderThickness = 3 * width / LandingTokens.referenceWidth;
        expect(t.getSize(photo).height, closeTo(t.getSize(cardFinder).height - 2 * borderThickness, .01));
        if (lang == 'fr') expect(t.getSize(cardFinder).height, lessThan(240));
        final l = L.of(t.element(find.byType(LandingScreen)));
        expect(find.text(l.landingCardMealScanTitle), findsOneWidget);
        expect(find.text(l.landingCardMealScanText), findsOneWidget);
        expect(t.takeException(), isNull);
        await t.pumpWidget(const SizedBox());
      });
    }
  }
}
