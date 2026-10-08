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
import 'package:menoo/screens/entry/startup_screen.dart';
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
    await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 80)));
    await t.pump();
    await t.pump();
    await t.pump();
  }

  testWidgets('First frame defers landing and overlay waits for image preparation', (t) async {
    final prepared = Completer<void>();
    var started = false;
    await t.pumpWidget(
      host(
        MenooStartup(
          prepare: (_) {
            started = true;
            return prepared.future;
          },
          child: const Text('prepared content'),
        ),
      ),
    );
    expect(find.byType(MenooStartupVisual), findsOneWidget);
    expect(find.text('prepared content'), findsNothing);
    await images(t);
    expect(started, isTrue);
    await t.pump(const Duration(seconds: 6));
    expect(find.byType(MenooStartupVisual), findsOneWidget);
    expect(find.text('prepared content'), findsNothing);
    prepared.complete();
    await t.pump();
    await t.pump();
    await t.pump(StartupTokens.sloganHold + const Duration(milliseconds: 10));
    await t.pump(StartupTokens.exit + const Duration(milliseconds: 10));
    expect(find.text('prepared content'), findsOneWidget);
    expect(find.byType(MenooStartupVisual), findsNothing);
    expect(t.takeException(), isNull);
  });

  testWidgets('Waits for readiness and releases landing without repeating', (t) async {
    final ready = Completer<void>();
    var taps = 0;
    await t.pumpWidget(
      host(
        MenooStartup(
          ready: ready.future,
          child: GestureDetector(
            onTap: () => taps++,
            child: const ColoredBox(color: AppColors.white),
          ),
        ),
      ),
    );
    await images(t);
    await t.pump(const Duration(seconds: 5));
    expect(find.byType(MenooStartupVisual), findsOneWidget);
    await t.tapAt(const Offset(200, 200));
    expect(taps, 0);
    ready.complete();
    await t.pump();
    await t.pump(StartupTokens.sloganHold + const Duration(milliseconds: 10));
    await t.pump(StartupTokens.exit + const Duration(milliseconds: 10));
    expect(find.byType(MenooStartupVisual), findsNothing);
    await t.tapAt(const Offset(200, 200));
    expect(taps, 1);
    await t.pump(const Duration(seconds: 12));
    expect(find.byType(MenooStartupVisual), findsNothing);
    expect(t.takeException(), isNull);
  });

  testWidgets('Ready app does not wait for the full storyboard', (t) async {
    await t.pumpWidget(host(const MenooStartup(child: ColoredBox(color: AppColors.white))));
    await images(t);
    await t.pump(StartupTokens.readySequence + const Duration(milliseconds: 50));
    await t.pump(StartupTokens.sloganHold + const Duration(milliseconds: 10));
    await t.pump(StartupTokens.exit + const Duration(milliseconds: 10));
    expect(find.byType(MenooStartupVisual), findsNothing);
    expect(t.takeException(), isNull);
  });

  testWidgets('Reduced motion uses a still logo and exits when ready', (t) async {
    final ready = Completer<void>();
    await t.pumpWidget(
      host(
        MenooStartup(
          ready: ready.future,
          child: const ColoredBox(color: AppColors.white),
        ),
        reduce: true,
      ),
    );
    await images(t);
    final visual = t.widget<MenooStartupVisual>(find.byType(MenooStartupVisual));
    expect(visual.progress, 1);
    ready.complete();
    await t.pump();
    await t.pump();
    await t.pump(const Duration(milliseconds: 1));
    expect(find.byType(MenooStartupVisual), findsNothing);
    expect(t.takeException(), isNull);
  });

  testWidgets('Disposing while loading leaves no active timer or callback', (t) async {
    final ready = Completer<void>();
    await t.pumpWidget(
      host(
        MenooStartup(
          ready: ready.future,
          child: const ColoredBox(color: AppColors.white),
        ),
      ),
    );
    await t.pumpWidget(const SizedBox());
    ready.complete();
    await images(t);
    expect(t.takeException(), isNull);
  });

  testWidgets('All launch locales render each phase on a small screen', (t) async {
    t.view.physicalSize = const Size(320, 640);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    for (final locale in AppLanguages.launchLocales) {
      for (final phase in [0.0, .2, .34, .46, .55, .7, .86, 1.0]) {
        await t.pumpWidget(host(MenooStartupVisual(progress: phase), locale: locale));
        await t.pump();
        expect(t.takeException(), isNull, reason: '${locale.languageCode}: $phase');
      }
    }
  });

  testWidgets('Startup preserves the landing CTA and its original route', (t) async {
    t.platformDispatcher.localesTestValue = const [Locale('fr')];
    addTearDown(t.platformDispatcher.clearLocalesTestValue);
    t.view.physicalSize = const Size(432, 936);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(const MenooApp());
    await images(t);
    await t.pumpAndSettle();
    await t.pump(StartupTokens.sloganHold + const Duration(milliseconds: 10));
    await t.pumpAndSettle();
    expect(find.byType(MenooStartupVisual), findsNothing);
    final context = t.element(find.byType(LandingScreen));
    final button = find.text(L.of(context).landingStart);
    await t.ensureVisible(button);
    await t.tap(button);
    await t.pumpAndSettle();
    expect(find.byType(PathChoiceScreen), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('Slogan appears only at the end, localized and readable at large text scale', (t) async {
    t.view.physicalSize = const Size(320, 640);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    for (final locale in AppLanguages.launchLocales) {
      Widget visual(double progress) => host(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: MenooStartupVisual(progress: progress),
        ),
        locale: locale,
      );
      await t.pumpWidget(visual(.9));
      final context = t.element(find.byType(MenooStartupVisual));
      final caption = find.text(L.of(context).startupSlogan);
      final fade = find.ancestor(of: caption, matching: find.byType(Opacity));
      expect(t.widget<Opacity>(fade).opacity, 0);
      await t.pumpWidget(visual(1));
      expect(t.widget<Opacity>(fade).opacity, 1);
      expect(t.getRect(caption).bottom, lessThanOrEqualTo(640));
      expect(t.takeException(), isNull);
    }
  });

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
      for (var i = 0; i < 75; i++) {
        await t.pumpWidget(
          host(
            RepaintBoundary(
              key: key,
              child: MenooStartupVisual(progress: i / 74, logo: frame!.image),
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
