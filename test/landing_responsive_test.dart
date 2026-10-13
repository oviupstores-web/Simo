import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menoo/l10n/app_localizations.dart';
import 'package:menoo/screens/entry/landing_screen.dart';
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
      for (final scale in [1.3, 2.0]) {
        testWidgets('Landing accessibility $language $width textScale=$scale', (t) async {
          t.view.physicalSize = Size(width, 900);
          t.view.devicePixelRatio = 1;
          addTearDown(t.view.reset);
          await t.pumpWidget(
            MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              locale: Locale(language),
              supportedLocales: L.supportedLocales,
              localizationsDelegates: L.localizationsDelegates,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
                child: child!,
              ),
              home: const LandingScreen(),
            ),
          );
          await t.runAsync(() => LandingScreen.prepareImages(t.element(find.byType(LandingScreen))));
          await t.pumpAndSettle();
          expect(
            t.takeException(),
            isNull,
            reason: 'Layout errors must be reported, never auto-fixed by changing the app',
          );
          for (final art in ['scan', 'meal_scan', 'menus', 'shopping']) {
            final card = t.getRect(find.byKey(ValueKey('landing_card_$art')));
            final cta = t.getRect(find.byKey(ValueKey('landing_cta_$art')));
            expect(cta.left, greaterThanOrEqualTo(card.left));
            expect(cta.right, lessThanOrEqualTo(card.right));
            final imageSlot = t.getRect(find.byKey(ValueKey('landing_art_slot_$art')));
            expect(imageSlot.top - cta.bottom, closeTo(12, .01));
          }
          await t.pumpWidget(const SizedBox());
        });
      }
    }
  }
}
