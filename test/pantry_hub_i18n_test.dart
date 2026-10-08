import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menoo/l10n/app_localizations.dart';
import 'package:menoo/l10n/app_languages.dart';
import 'package:menoo/l10n/formats.dart';
import 'package:menoo/onboarding/onboarding_data.dart';
import 'package:menoo/onboarding/onboarding_scope.dart';
import 'package:menoo/screens/pantry/pantry_hub_onboarding_screen.dart';
import 'package:menoo/theme/theme.dart';

void main() {
  setUpAll(() async {
    Future<void> load(String family, List<String> files) async {
      final loader = FontLoader(family);
      for (final fileName in files) {
        final file = File('assets/fonts/$fileName');
        loader.addFont(Future.value(ByteData.sublistView(file.readAsBytesSync())));
      }
      await loader.load();
    }

    await load('PlusJakartaSans', [
      for (final weight in [400, 500, 600, 700, 800]) 'PlusJakartaSans-$weight.ttf',
    ]);
    await load('Caveat', ['Caveat-600.ttf']);
    await load('ReadexPro', [
      for (final weight in [400, 500, 600, 700]) 'ReadexPro-$weight.ttf',
    ]);
  });

  final locales = AppLanguages.launchLocales;
  const widths = [320.0, 390.0];

  testWidgets('précharge le logo utilisé par les captures', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: Image.asset('assets/images/logo_96.png'))));
    await tester.pumpAndSettle();
  });

  for (final locale in locales) {
    for (final width in widths) {
      for (final filled in [false, true]) {
        testWidgets(
          '${locale.languageCode} · Pantry ${filled ? 'remplie' : 'vide'} à ${width.toInt()} px sans débordement',
          (tester) async {
            tester.view.physicalSize = Size(width, 1200);
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.reset);

            final errors = <FlutterErrorDetails>[];
            final previousOnError = FlutterError.onError;
            FlutterError.onError = errors.add;
            addTearDown(() => FlutterError.onError = previousOnError);

            final data = OnboardingData();
            if (filled) {
              data.pantry.addAll([
                PantryDraft(
                  name: 'Yaourt',
                  quantity: 1.5,
                  unitLabel: 'kg',
                  location: PantryLocation.fridge,
                  expiresOn: DateTime.now().add(const Duration(days: 1)),
                ),
                PantryDraft(name: 'Quinoa', quantity: 2, unitLabel: 'kg', location: PantryLocation.pantry),
              ]);
            }
            addTearDown(data.dispose);
            final screenshotKey = GlobalKey();

            await tester.pumpWidget(
              RepaintBoundary(
                key: screenshotKey,
                child: MaterialApp(
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.light,
                  locale: locale,
                  supportedLocales: AppLanguages.launchLocales,
                  localizationsDelegates: L.localizationsDelegates,
                  home: OnboardingScope(
                    data: data,
                    child: PantryHubOnboardingScreen(onFinish: (_) {}),
                  ),
                ),
              ),
            );
            await tester.pumpAndSettle();
            FlutterError.onError = previousOnError;

            expect(
              Directionality.of(tester.element(find.byType(PantryHubOnboardingScreen))),
              locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
            );
            expect(errors, isEmpty, reason: errors.map((error) => error.exceptionAsString()).join('\n'));
            if (filled) {
              expect(find.text('${Formats(locale).number(1.5, decimals: 2)} kg'), findsOneWidget);
            }

            final outputDirectory = Platform.environment['PANTRY_SCREENSHOTS_DIR'];
            if (outputDirectory != null) {
              await tester.runAsync(() async {
                final boundary = screenshotKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
                final image = await boundary.toImage(pixelRatio: 2);
                final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
                final suffix = filled ? '_filled' : '';
                final output = File('$outputDirectory/pantry_${locale.languageCode}_${width.toInt()}$suffix.png');
                output.parent.createSync(recursive: true);
                output.writeAsBytesSync(bytes!.buffer.asUint8List());
              });
            }
          },
        );
      }
    }
  }
}
