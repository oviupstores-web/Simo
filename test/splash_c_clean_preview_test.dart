import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menoo/l10n/app_localizations.dart';
import 'package:menoo/l10n/app_languages.dart';
import 'package:menoo/main.dart';
import 'package:menoo/screens/entry/landing_screen.dart';
import 'package:menoo/screens/entry/path_choice_screen.dart';
import '../reports/splash_c_clean_visual.dart';
import 'package:menoo/theme/theme.dart';

void main() {
  setUpAll(() async {
    for (final family in ['PlusJakartaSans', 'ReadexPro']) {
      final loader = FontLoader(family);
      for (final weight in [400, 500, 700]) {
        loader.addFont(Future.value(ByteData.sublistView(File('assets/fonts/$family-$weight.ttf').readAsBytesSync())));
      }
      await loader.load();
    }
  });

  Widget host(Widget child, {Locale locale = const Locale('fr'), bool reduce = false}) => MaterialApp(
    theme: AppTheme.light,
    locale: locale,
    supportedLocales: AppLanguages.launchLocales,
    localizationsDelegates: L.localizationsDelegates,
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: reduce),
      child: child,
    ),
  );

  Future<void> images(WidgetTester t) async {
    if (find.byType(MaterialApp).evaluate().isNotEmpty) {
      await t.runAsync(() => precacheImage(
        const AssetImage(StartupTokens.logoAsset), t.element(find.byType(MaterialApp)),
      ));
    }
    await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await t.pump();
    await t.pump();
    await t.pump();
  }

  const previewDir = String.fromEnvironment('MENOO_PREVIEW_DIR');
  if (previewDir.isNotEmpty) {
    testWidgets('Capture actual Flutter storyboard for local review', (t) async {
      t.view.physicalSize = const Size(432, 936);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      final bytes = File(StartupTokens.logoAsset).readAsBytesSync();
      final codec = await t.runAsync(() => ui.instantiateImageCodec(bytes));
      final frame = await t.runAsync(() => codec!.getNextFrame());
      addTearDown(() {
        frame!.image.dispose();
        codec!.dispose();
      });
      final directory = Directory(previewDir)..createSync(recursive: true);
      final key = GlobalKey();
      await t.pumpWidget(host(const SizedBox()));
      await images(t);
      for (var i = 0; i < 75; i++) {
        await t.pumpWidget(
          host(
            RepaintBoundary(
              key: key,
              child: MenooStartupCleanVisual(progress: i / 74, logo: frame!.image),
            ),
          ),
        );
        await t.pump();
        final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        await t.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: 2.5);
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          File('${directory.path}/frame_${i.toString().padLeft(3, '0')}.png')
              .writeAsBytesSync(data!.buffer.asUint8List());
          image.dispose();
        });
        expect(t.takeException(), isNull);
      }
    });
  }
}
