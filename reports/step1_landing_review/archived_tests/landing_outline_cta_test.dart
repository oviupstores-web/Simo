import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menoo/l10n/app_localizations.dart';
import 'package:menoo/screens/entry/landing_screen.dart';
import 'package:menoo/screens/entry/path_choice_screen.dart';
import 'package:menoo/screens/entry/landing_badge_cta.dart';
import 'package:menoo/theme/theme.dart';
import 'package:menoo/widgets/widgets.dart';

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

  Future<void> show(WidgetTester t, double width, String language, {GlobalKey? capture}) async {
    t.view.physicalSize = Size(width, 4000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      RepaintBoundary(
        key: capture,
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
  }

  for (final language in ['fr', 'en', 'de', 'es', 'it', 'ar']) {
    for (final width in [320.0, 390.0]) {
      testWidgets('Four outlined CTAs, no overflow: $language $width', (t) async {
        final key = GlobalKey();
        await show(t, width, language, capture: key);
        expect(find.byType(LandingBadgeCta), findsNothing);
        for (final art in ['scan', 'meal_scan', 'menus', 'shopping']) {
          final cta = find.byKey(ValueKey('landing_cta_$art'));
          expect(cta, findsOneWidget);
          final rect = t.getRect(cta);
          final card = t.getRect(find.byKey(ValueKey('landing_card_$art')));
          final l = L.of(t.element(find.byType(LandingScreen)));
          final body = switch (art) {
            'scan' => l.landingCardScanText,
            'meal_scan' => l.landingCardMealScanText,
            'menus' => l.landingCardMenusText,
            _ => l.landingCardShoppingText,
          };
          final description = find.text(body);
          final textRect = t.getRect(description);
          expect(rect.width, lessThanOrEqualTo(textRect.width + .001));
          if (language == 'ar') {
            expect(rect.left, greaterThanOrEqualTo(card.center.dx - .001));
          } else {
            expect(rect.right, lessThanOrEqualTo(card.center.dx + .001));
          }
          final label = t.widget<Text>(find.descendant(of: cta, matching: find.byType(Text)));
          expect(label.maxLines, 1);
          expect(label.style!.fontSize, LandingCtaTokens.fontSize);
          final paragraph = t.renderObject<RenderParagraph>(find.descendant(of: cta, matching: find.byType(Text)));
          final painter = TextPainter(
            text: TextSpan(text: label.data, style: label.style),
            textDirection: language == 'ar' ? TextDirection.rtl : TextDirection.ltr,
          )..layout();
          expect(
            painter.width,
            lessThanOrEqualTo(paragraph.size.width + .001),
            reason: '$language $width $art label must fit',
          );
          if (language == 'fr') {
            final expected = width == 320
                ? {'scan': 'Scanner', 'meal_scan': 'Analyser', 'menus': 'Mes menus', 'shopping': 'Ma liste'}
                : {
                    'scan': 'Scanner mon frigo',
                    'meal_scan': 'Analyser mon repas',
                    'menus': 'Voir mes menus',
                    'shopping': 'Créer ma liste',
                  };
            expect(label.data, expected[art]);
          }
          expect(rect.left, greaterThanOrEqualTo(card.left));
          expect(rect.right, lessThanOrEqualTo(card.right));
          expect(rect.bottom, lessThanOrEqualTo(card.bottom));
          final inks = find.descendant(of: cta, matching: find.byType(InkWell));
          expect(t.widget<InkWell>(inks).onTap != null, art == 'menus' || art == 'shopping');
        }
        expect(find.byKey(const ValueKey('landing_cta_tracking')), findsNothing);
        final cards = [for (final art in ['scan', 'meal_scan', 'menus', 'shopping', 'tracking'])
          t.getRect(find.byKey(ValueKey('landing_card_$art')))];
        for (var i = 1; i < cards.length; i++) {
          expect(cards[i].top - cards[i - 1].bottom, closeTo(LandingTokens.cardGap, .001));
        }
        final start = t.getRect(find.byType(PrimaryButton));
        expect(start.top - cards.last.bottom, closeTo(LandingTokens.cardGap, .001));
        for (final art in ['scan', 'meal_scan', 'menus', 'shopping', 'tracking']) {
          final card = find.byKey(ValueKey('landing_card_$art'));
          final image = t.widget<Image>(find.descendant(of: card, matching: find.byType(Image)));
          expect(image.fit, BoxFit.contain);
          expect((image.image as AssetImage).assetName, contains('/validated_'));
        }

        expect(t.takeException(), isNull);
        const output = String.fromEnvironment('LANDING_CTA_CAPTURE_DIR');
        if (language == 'fr' && output.isNotEmpty) {
          final scroll = t.widget<SingleChildScrollView>(find.byType(SingleChildScrollView));
          final height = t.getSize(find.byWidget(scroll.child!)).height.ceilToDouble();
          t.view.physicalSize = Size(width, height);
          await t.pump();
          final boundary = t.renderObject<RenderRepaintBoundary>(find.byKey(key));
          await t.runAsync(() async {
            final image = await boundary.toImage(pixelRatio: 1);
            final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
            Directory(output).createSync(recursive: true);
            File('$output/landing_${width.toInt()}.png').writeAsBytesSync(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
        await t.pumpWidget(const SizedBox());
      });
    }
  }

  for (final art in ['scan', 'meal_scan', 'menus', 'shopping']) {
    testWidgets('Existing navigation only: $art', (t) async {
      await show(t, 390, 'fr');
      await t.tap(find.byKey(ValueKey('landing_cta_$art')));
      await t.pumpAndSettle();
      expect(find.byType(PathChoiceScreen), art == 'menus' || art == 'shopping' ? findsOneWidget : findsNothing);
      expect(t.takeException(), isNull);
    });
  }
}
