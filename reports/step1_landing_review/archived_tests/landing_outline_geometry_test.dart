import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menoo/l10n/app_localizations.dart';
import 'package:menoo/screens/entry/landing_screen.dart';
import 'package:menoo/theme/theme.dart';

import '../reports/landing_outline_cta/baseline_landing.dart';

void main() {
  setUpAll(() async {
    final loader = FontLoader('PlusJakartaSans');
    for (final weight in [400, 500, 600, 700, 800]) {
      final f = File('assets/fonts/PlusJakartaSans-$weight.ttf');
      if (f.existsSync()) loader.addFont(Future.value(ByteData.sublistView(f.readAsBytesSync())));
    }
    await loader.load();
  });
  for (final width in [320.0, 390.0]) {
    testWidgets('Original artwork and text geometry preserved at $width', (t) async {
      t.view.physicalSize = Size(width, 4000);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      Future<Map<String, dynamic>> measure(Widget page) async {
        await t.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            locale: const Locale('fr'),
            supportedLocales: L.supportedLocales,
            localizationsDelegates: L.localizationsDelegates,
            home: page,
          ),
        );
        await t.runAsync(() => LandingScreen.prepareImages(t.element(find.byType(Scaffold).first)));
        await t.pumpAndSettle();
        final results = <String, dynamic>{};
        for (final art in ['scan', 'meal_scan', 'menus', 'shopping', 'tracking']) {
          final card = find.byKey(ValueKey('landing_card_$art'));
          final origin = t.getRect(card).topLeft;
          List<double> localRect(Finder f) {
            final r = t.getRect(f);
            return [
              r.left - origin.dx,
              r.top - origin.dy,
              r.width,
              r.height,
            ].map((value) => (value * 1000000).round() / 1000000).toList();
          }

          final image = find.descendant(of: card, matching: find.byType(Image));
          final texts = find.descendant(of: card, matching: find.byType(Text));
          results[art] = {
            'image': localRect(image),
            'asset': (t.widget<Image>(image).image as AssetImage).assetName,
            'fit': t.widget<Image>(image).fit.toString(),
            'text': [for (var i = 0; i < 3; i++) localRect(texts.at(i))],
            'content': [for (var i = 0; i < 3; i++) t.widget<Text>(texts.at(i)).data],
            'height': t.getRect(card).height,
          };
        }
        results['startSize'] = [t.getSize(find.text('Commencer')).width, t.getSize(find.text('Commencer')).height];
        await t.pumpWidget(const SizedBox());
        return results;
      }

      final before = await measure(const BaselineLandingScreen());
      final after = await measure(const LandingScreen());
      for (final art in ['scan', 'meal_scan', 'menus', 'shopping', 'tracking']) {
        final b = Map<String, dynamic>.from(before[art]);
        final a = Map<String, dynamic>.from(after[art]);
        final bh = b.remove('height') as double;
        final ah = a.remove('height') as double;
        expect(a, b, reason: 'Art, crop and original texts must stay identical: $art');
        expect(ah - bh, closeTo(art == 'tracking' ? 0 : 56, .001));
      }
      expect(after['startSize'], before['startSize']);
      File('reports/landing_outline_cta/geometry_${width.toInt()}.json')
          .writeAsStringSync(const JsonEncoder.withIndent('  ').convert({'before': before, 'after': after}));
      expect(t.takeException(), isNull);
    });
  }
}
