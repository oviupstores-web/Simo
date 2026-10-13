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
  for (final language in ['fr', 'en', 'es', 'it', 'de']) {
    for (final width in [320.0, 390.0]) {
      testWidgets('Provisional Landing contract $language $width', (t) async {
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
          geometry[art] = {
            'card': [r.left, r.top, r.width, r.height],
          };
          expect(r.left, closeTo(20, .01));
          expect(width - r.right, closeTo(20, .01));
        }
        for (final art in ['scan', 'meal_scan', 'menus', 'shopping', 'tracking']) {
          final card = find.byKey(ValueKey('landing_card_$art'));
          final rect = t.getRect(card);
          final picture = find.descendant(of: card, matching: find.byType(Image));
          final imageRect = t.getRect(picture);
          final image = t.widget<Image>(picture);
          expect(image.fit, BoxFit.contain);
          final surface = t.widget<Container>(find.ancestor(of: card, matching: find.byType(Container)).first);
          final decoration = surface.decoration! as BoxDecoration;
          expect((decoration.borderRadius! as BorderRadius).topLeft.x, 12);
          expect(surface.clipBehavior, art == 'meal_scan' ? Clip.antiAlias : Clip.none);

          if (art == 'scan') expect(imageRect.left + imageRect.width * 819 / 1448, closeTo(rect.center.dx, .01));
          expect((image.image as AssetImage).assetName, 'assets/images/landing/${art}_20261013_1258.png');
          if (art == 'meal_scan') {
            expect(imageRect.left + imageRect.width * 727 / 1448, closeTo(rect.center.dx, .01));
            expect(imageRect.left, greaterThanOrEqualTo(rect.left));
            expect(imageRect.right, lessThanOrEqualTo(rect.right));
            expect(imageRect.width, greaterThan((rect.width - 40) * .75));
          } else if (art == 'scan') {
            expect(imageRect.width, closeTo((rect.width - 40) * 1.20, .01));
          } else {
            final center = {'menus': 729.5, 'shopping': 724.5, 'tracking': 730.0}[art]!;
            expect(imageRect.left + imageRect.width * center / 1448, closeTo(rect.center.dx, .01));
            expect(imageRect.left, greaterThanOrEqualTo(rect.left));
            expect(imageRect.right, lessThanOrEqualTo(rect.right));
            expect(imageRect.width, greaterThan((rect.width - 40) * .75));
          }
          final slot = t.getRect(find.byKey(ValueKey('landing_art_slot_$art')));
          expect(slot.bottom, closeTo(rect.bottom, .01));
          final texts = find.descendant(of: card, matching: find.byType(Text));
          final description = t.getRect(texts.at(2));
          expect(description.width, closeTo(rect.width - 40, .01));
          if (art != 'tracking') {
            final descriptionText = t.widget<Text>(texts.at(2));
            final painter = TextPainter(
              text: TextSpan(text: descriptionText.data, style: descriptionText.style),
              textDirection: TextDirection.ltr,
            )..layout(maxWidth: description.width);
            expect(descriptionText.data!.contains('\n'), isFalse);
            if (language == 'fr' && width == 390)
              expect(painter.computeLineMetrics().length, 3, reason: '$language $width $art description');
            painter.dispose();
          }
          if (art != 'tracking') {
            final cta = t.getRect(find.byKey(ValueKey('landing_cta_$art')));
            expect(cta.width, closeTo(description.width * .85, .01));
            expect(cta.height, greaterThanOrEqualTo(38 - .01));
            expect(cta.center.dx, closeTo(rect.center.dx, .01));
            expect(cta.top - description.bottom, closeTo(24, .01));
            expect(imageRect.top - cta.bottom, closeTo(12, .01));
          } else {
            expect(find.byKey(const ValueKey('landing_cta_tracking')), findsNothing);
            expect(slot.top - description.bottom, closeTo(6, .01));
            expect(imageRect.top + imageRect.width * 235 / 1448, closeTo(slot.top, .01));
          }
        }
        final banana = t.getRect(find.byKey(const ValueKey('landing_banana')));
        final firstCard = t.getRect(find.byKey(const ValueKey('landing_card_scan')));
        expect(firstCard.top - banana.bottom, greaterThanOrEqualTo(8 - .01));
        final arts = ['scan', 'meal_scan', 'menus', 'shopping', 'tracking'];
        for (var i = 1; i < arts.length; i++) {
          final previous = t.getRect(find.byKey(ValueKey('landing_card_${arts[i - 1]}')));
          final next = t.getRect(find.byKey(ValueKey('landing_card_${arts[i]}')));
          expect(next.top - previous.bottom, closeTo(16, .01));
        }
        // Provisional snapshots apply only to this frozen Landing, not other screens.
        await expectLater(
          find.byKey(key),
          matchesGoldenFile('goldens/landing_provisional/full_${language}_${width.toInt()}.png'),
        );
        if (const bool.fromEnvironment('capture')) {
          await t.runAsync(() async {
            final boundary = t.renderObject<RenderRepaintBoundary>(find.byKey(key));
            final image = await boundary.toImage(pixelRatio: 1);
            final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
            final output = Directory(
              const String.fromEnvironment('captureDir', defaultValue: 'reports/step1_landing_review/captures'),
            )..createSync(recursive: true);
            File('${output.path}/full_${language}_${width.toInt()}.png').writeAsBytesSync(bytes!.buffer.asUint8List());
            File('${output.path}/geometry_${language}_${width.toInt()}.json').writeAsStringSync(jsonEncode(geometry));
            image.dispose();
          });
        }
        for (final art in ['scan', 'meal_scan']) {
          await t.tap(find.byKey(ValueKey('landing_cta_$art')));
          await t.pumpAndSettle();
          expect(find.byType(LandingScreen), findsOneWidget);
          expect(find.byType(PathChoiceScreen), findsNothing);
        }
        for (final art in ['menus', 'shopping']) {
          await t.tap(find.byKey(ValueKey('landing_cta_$art')));
          await t.pumpAndSettle();
          expect(find.byType(PathChoiceScreen), findsOneWidget);
          Navigator.of(t.element(find.byType(PathChoiceScreen))).pop();
          await t.pumpAndSettle();
        }
        expect(t.takeException(), isNull);
        await t.pumpWidget(const SizedBox());
      });
    }
  }
}
