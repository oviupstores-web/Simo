import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menoo/l10n/app_languages.dart';
import 'package:menoo/l10n/app_localizations.dart';
import 'package:menoo/l10n/locale_scope.dart';
import 'package:menoo/theme/theme.dart';

void main() {
  setUpAll(() async {
    final loader = FontLoader('PlusJakartaSans');
    for (final weight in [400, 500, 600, 700, 800]) {
      final bytes = File('assets/fonts/PlusJakartaSans-$weight.ttf').readAsBytesSync();
      loader.addFont(Future<ByteData>.value(ByteData.sublistView(bytes)));
    }
    await loader.load();
  });

  for (final locale in AppLanguages.launchLocales) {
    for (final width in [320.0, 390.0]) {
      testWidgets('${locale.languageCode} · sélecteur limité aux 3 langues à ${width.toInt()} px', (tester) async {
        tester.view.physicalSize = Size(width, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        final controller = ValueNotifier<Locale?>(null);
        addTearDown(controller.dispose);
        final captureKey = GlobalKey();

        await tester.pumpWidget(
          RepaintBoundary(
            key: captureKey,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              locale: locale,
              supportedLocales: AppLanguages.launchLocales,
              localizationsDelegates: L.localizationsDelegates,
              home: LocaleScope(
                controller: controller,
                child: Scaffold(
                  body: Builder(
                    builder: (context) => Center(
                      child: ElevatedButton(onPressed: () => LocaleScope.pick(context), child: const Text('Ouvrir')),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Ouvrir'));
        await tester.pumpAndSettle();

        final titleByLocale = {'fr': 'Langue', 'en': 'Language', 'de': 'Sprache'};
        expect(find.text(titleByLocale[locale.languageCode]!), findsOneWidget);
        expect(find.text('Français'), findsOneWidget);
        expect(find.text('English'), findsOneWidget);
        expect(find.text('Deutsch'), findsOneWidget);
        expect(find.text('Español'), findsNothing);
        expect(find.text('Italiano'), findsNothing);
        expect(find.text('العربية'), findsNothing);
        expect(tester.takeException(), isNull);

        final outputDirectory = locale.languageCode == 'fr' && width == 390.0
            ? Platform.environment['MENOO_LANGUAGE_SCREENSHOT_DIR']
            : null;
        if (outputDirectory != null) {
          await tester.runAsync(() async {
            final boundary = captureKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
            final image = await boundary.toImage(pixelRatio: 1);
            final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
            final output = File('$outputDirectory/language-picker-fr-en-de.png');
            output.parent.createSync(recursive: true);
            output.writeAsBytesSync(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
      });
    }
  }
}
