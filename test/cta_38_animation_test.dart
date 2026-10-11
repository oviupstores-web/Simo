// Regression: the restored Landing must not reintroduce animated hands or rings.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menoo/l10n/app_localizations.dart';
import 'package:menoo/screens/entry/landing_badge_cta.dart';
import 'package:menoo/screens/entry/landing_screen.dart';
import 'package:menoo/theme/theme.dart';

class _ShadowBinding extends AutomatedTestWidgetsFlutterBinding {
  @override
  bool get disableShadows => false;
}

void main() {
  _ShadowBinding();
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

  for (final width in [320.0, 390.0, 1080 / 2.75]) {
    testWidgets('Landing $width : rendu statique sans mains ni ondes', (t) async {
      final xiaomi = width == 1080 / 2.75;
      final ratio = xiaomi ? 2.75 : 1.0;
      t.view.physicalSize = xiaomi ? const Size(1080, 2400) : Size(width, 900);
      t.view.devicePixelRatio = ratio;
      if (xiaomi) t.view.padding = FakeViewPadding(top: 93, bottom: 132);
      addTearDown(t.view.reset);
      await t.pumpWidget(
        RepaintBoundary(
          key: const ValueKey('landing_capture'),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            locale: const Locale('fr'),
            supportedLocales: L.supportedLocales,
            localizationsDelegates: L.localizationsDelegates,
            home: const LandingScreen(),
          ),
        ),
      );
      await t.runAsync(() => LandingScreen.prepareImages(t.element(find.byType(LandingScreen))));
      await t.pumpAndSettle();
      expect(find.byType(LandingBadgeCta), findsNothing);
      expect(
        find.byWidgetPredicate(
          (w) => w is CustomPaint && (w.painter is LandingClickHandPainter || w.painter is LandingContactWavesPainter),
        ),
        findsNothing,
      );
      final scroll = t.state<ScrollableState>(find.byType(Scrollable).first).position;

      Future<List<int>> pixels({String? saveAs}) async {
        return (await t.runAsync(() async {
          final boundary = t.renderObject<RenderRepaintBoundary>(find.byKey(const ValueKey('landing_capture')));
          final image = await boundary.toImage(pixelRatio: ratio);
          final raw = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
          const output = String.fromEnvironment('LANDING_CAPTURE_DIR');
          if (xiaomi && output.isNotEmpty && saveAs != null) {
            final png = await image.toByteData(format: ui.ImageByteFormat.png);
            Directory(output).createSync(recursive: true);
            File('$output/$saveAs.png').writeAsBytesSync(png!.buffer.asUint8List());
          }
          image.dispose();
          return raw!.buffer.asUint8List();
        }))!;
      }

      for (final position in ['top', 'bottom']) {
        if (position == 'bottom') scroll.jumpTo(scroll.maxScrollExtent);
        await t.pumpAndSettle();
        final before = await pixels(saveAs: 'restored_$position');
        await t.pump(const Duration(milliseconds: 173));
        await t.pump(const Duration(seconds: 2));
        final after = await pixels();
        expect(listEquals(after, before), isTrue, reason: 'Aucune animation persistante sur la Landing');
        expect(t.binding.hasScheduledFrame, isFalse);
      }
      expect(find.text('Commencer'), findsOneWidget);
      expect(t.takeException(), isNull);
      await t.pumpWidget(const SizedBox());
    });
  }
}
