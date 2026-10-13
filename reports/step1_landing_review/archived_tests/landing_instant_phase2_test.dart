import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menoo/l10n/app_localizations.dart';
import 'package:menoo/screens/entry/landing_screen.dart';
import 'package:menoo/screens/entry/path_choice_screen.dart';
import 'package:menoo/theme/theme.dart';

void main() {
  setUpAll(() async {
    final loader = FontLoader('PlusJakartaSans');
    for (final weight in [400, 500, 600, 700, 800]) {
      loader.addFont(
        Future.value(ByteData.sublistView(File('assets/fonts/PlusJakartaSans-$weight.ttf').readAsBytesSync())),
      );
    }
    await loader.load();
  });
  for (final language in ['fr', 'de']) {
  for (final width in [320.0, 390.0]) {
    testWidgets('Single-container original artwork capture $language $width', (t) async {
      t.view.physicalSize = Size(width, 3000);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      final key = GlobalKey();
      await t.pumpWidget(
        RepaintBoundary(
          key: key,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            locale: Locale(language),
            supportedLocales: L.supportedLocales,
            localizationsDelegates: L.localizationsDelegates,
            home: const LandingScreen(),
          ),
        ),
      );
      await t.runAsync(() => LandingScreen.prepareImages(t.element(find.byType(LandingScreen))));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      final scroll = t.widget<SingleChildScrollView>(find.byType(SingleChildScrollView));
      final height = t.getSize(find.byWidget(scroll.child!)).height.ceilToDouble();
      t.view.physicalSize = Size(width, height);
      await t.pump();
      final geometry = <String, dynamic>{};
      for (final art in ['scan', 'meal_scan', 'menus', 'shopping', 'tracking']) {
        final card = find.byKey(ValueKey('landing_card_$art'));
        final r = t.getRect(card);
        geometry[art] = {'card': [r.left, r.top, r.width, r.height]};
      }
      if (const String.fromEnvironment('stage', defaultValue: 'narrow_cta') == 'narrow_cta') {
        final card = find.byKey(const ValueKey('landing_card_scan'));
        final rect = t.getRect(card);
        final picture = find.descendant(of: card, matching: find.byType(Image));
        final imageRect = t.getRect(picture);
        final image = t.widget<Image>(picture);
        expect(image.fit, BoxFit.contain);
        expect((image.image as AssetImage).assetName, 'assets/images/landing/instant_recipe_validated.png');
        expect(imageRect.width, closeTo((rect.width - 20) * .75, .01));
        expect(imageRect.right, lessThanOrEqualTo(rect.right - 10 + .01));
        expect(imageRect.bottom, closeTo(rect.bottom, .01));
        final texts = find.descendant(of: card, matching: find.byType(Text));
        final description = t.getRect(texts.at(2));
        expect(description.width, closeTo(rect.width - 20, .01));
        final cta = t.getRect(find.byKey(const ValueKey('landing_cta_scan')));
        expect(cta.right, lessThanOrEqualTo(description.right + .01));
        expect(cta.width, closeTo(description.width * .85, .01));
        expect(cta.center.dx, closeTo(rect.center.dx, .01));
        expect(cta.top - description.bottom, closeTo(24, .01));
        expect(imageRect.top - cta.bottom, closeTo(12, .01));
      }
      await t.runAsync(() async {
        final boundary = t.renderObject<RenderRepaintBoundary>(find.byKey(key));
        final image = await boundary.toImage(pixelRatio: 1);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        File('reports/landing_instant_phase2/${const String.fromEnvironment('stage', defaultValue: 'narrow_cta')}_${language}_${width.toInt()}.png').writeAsBytesSync(bytes!.buffer.asUint8List());
        File('reports/landing_instant_phase2/${const String.fromEnvironment('stage', defaultValue: 'narrow_cta')}_${language}_${width.toInt()}.json').writeAsStringSync(jsonEncode(geometry));
        image.dispose();
      });
      await t.tap(find.byKey(const ValueKey('landing_cta_scan')));
      await t.pumpAndSettle();
      expect(find.byType(LandingScreen), findsOneWidget);
      expect(find.byType(PathChoiceScreen), findsNothing);
      expect(t.takeException(), isNull);
      await t.pumpWidget(const SizedBox());
    });
  }
}
}
