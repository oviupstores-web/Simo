import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menoo/l10n/app_localizations.dart';
import 'package:menoo/onboarding/onboarding_data.dart';
import 'package:menoo/onboarding/onboarding_scope.dart';
import 'package:menoo/screens/onboarding/goal_screen.dart';
import 'package:menoo/screens/onboarding/activity_screen.dart';
import 'package:menoo/screens/onboarding/management_mode_screen.dart';
import 'package:menoo/screens/onboarding/cover_solo_screen.dart';
import 'package:menoo/screens/onboarding/cover_household_screen.dart';
import 'package:menoo/screens/onboarding/constraints_screen.dart';
import 'package:menoo/screens/pantry/pantry_hub_onboarding_screen.dart';
import 'package:menoo/theme/theme.dart';
import 'package:menoo/widgets/surfaces.dart';
import 'package:menoo/widgets/selectable_card.dart';

void main() {
  setUpAll(() async {
    for (final family in ['PlusJakartaSans', 'ReadexPro']) {
      final l = FontLoader(family);
      for (final w in [400, 500, 600, 700, 800]) {
        final f = File('assets/fonts/$family-$w.ttf');
        if (f.existsSync()) l.addFont(Future.value(ByteData.sublistView(f.readAsBytesSync())));
      }
      await l.load();
    }
  });
  final screens = <String, Widget>{
    'goal': const GoalScreen(),
    'activity': const ActivityScreen(),
    'management_solo': const ManagementModeScreen(),
    'management_foyer': const ManagementModeScreen(),
    'cover_solo': const CoverSoloScreen(),
    'cover_foyer': const CoverHouseholdScreen(),
    'constraints_solo': const ConstraintsScreen(),
    'constraints_foyer': const ConstraintsScreen(),
    'pantry_solo': PantryHubOnboardingScreen(onFinish: (_) {}),
    'pantry_foyer': PantryHubOnboardingScreen(onFinish: (_) {}),
  };
  for (final lang in ['fr', 'en', 'de', 'es', 'it', 'ar']) {
    for (final width in (['fr', 'en', 'de'].contains(lang) ? [320.0, 390.0] : [390.0])) {
      for (final entry in screens.entries) {
        testWidgets('icônes $lang $width ${entry.key}: rendu et assets complets', (t) async {
          t.view.physicalSize = Size(width, 1500);
          t.view.devicePixelRatio = 1;
          addTearDown(t.view.reset);
          final d = OnboardingData()
            ..startMode(entry.key.endsWith('foyer') ? AppMode.foyer : AppMode.solo)
            ..goal = HealthGoal.maintien;
          addTearDown(d.dispose);
          const key = ValueKey('icon_capture');
          await t.pumpWidget(
            RepaintBoundary(
              key: key,
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light,
                locale: Locale(lang),
                supportedLocales: L.supportedLocales,
                localizationsDelegates: L.localizationsDelegates,
                builder: (_, child) => OnboardingScope(data: d, child: child!),
                home: entry.value,
              ),
            ),
          );
          await t.pumpAndSettle();
          final context = t.element(find.byType(MaterialApp));
          await t.runAsync(() async {
            for (final im in t.widgetList<Image>(find.byType(Image))) {
              await precacheImage(im.image, context);
            }
          });
          await t.pumpAndSettle();
          expect(t.takeException(), isNull);
          final expected = switch (entry.key) {
            'goal' => ['goal_loss', 'goal_gain', 'goal_definition', 'goal_balance'],
            'activity' => ['activity_desk', 'activity_walk', 'activity_run', 'activity_training'],
            'management_solo' || 'management_foyer' => ['management_shopping', 'management_pantry', 'management_mixed'],
            'cover_solo' => ['solo_nutrition', 'solo_time', 'solo_waste'],
            'cover_foyer' => ['solo_waste'],
            'constraints_solo' || 'constraints_foyer' => [
              'diet_omnivore',
              'diet_vegetarian',
              'diet_vegan',
              'diet_pescatarian',
              'diet_no_pork',
              'diet_no_lactose',
              'diet_no_gluten',
            ],
            _ => ['pantry_reserve', 'pantry_quick_check'],
          };
          final newImages = t
              .widgetList<Image>(find.byType(Image))
              .where(
                (im) =>
                    im.image is AssetImage && (im.image as AssetImage).assetName.startsWith('assets/images/new_icons/'),
              )
              .toList();
          expect(
            newImages.map((im) => (im.image as AssetImage).assetName).toSet(),
            expected.map((n) => 'assets/images/new_icons/$n.png').toSet(),
          );
          for (final im in newImages) {
            final size = entry.key.startsWith('constraints')
                ? 44.0
                : entry.key.startsWith('pantry')
                ? 52.0
                : 60.0;
            expect(t.getSize(find.byWidgetPredicate((w) => identical(w, im))), Size(size, size));
            expect(im.fit, BoxFit.contain);
            final imageFinder = find.byWidgetPredicate((w) => identical(w, im));
            if (entry.key.startsWith('constraints')) {
              final circle = find.ancestor(
                of: imageFinder,
                matching: find.byWidgetPredicate((w) => w is Container &&
                    w.constraints?.maxWidth == 48 && w.constraints?.maxHeight == 48),
              );
              expect(circle, findsOneWidget);
              expect(t.getSize(circle), const Size(48, 48));
            } else {
              final tile = find.ancestor(of: imageFinder, matching: find.byType(IconTile));
              final tileSize = entry.key.startsWith('pantry') ? 56.0 : 64.0;
              expect(t.getSize(tile), Size(tileSize, tileSize));
            }
          }
          if (const bool.fromEnvironment('ICON_PREVIEW') && lang == 'fr') {
            const stage = String.fromEnvironment('ICON_STAGE', defaultValue: 'after');
            final dir = Directory(
              r'C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\icons_integration\' +
                  stage,
            )..createSync(recursive: true);
            final b = t.renderObject<RenderRepaintBoundary>(find.byKey(key));
            await t.runAsync(() async {
              final im = await b.toImage(pixelRatio: 2);
              final bytes = await im.toByteData(format: ui.ImageByteFormat.png);
              File('${dir.path}/${entry.key}${width == 320 ? '_320' : ''}.png').writeAsBytesSync(bytes!.buffer.asUint8List());
              im.dispose();
            });
          }
        });
      }
    }
  }
  testWidgets('ancienne ChoiceCard : pastille par défaut inchangée à 56 px', (t) async {
    await t.pumpWidget(MaterialApp(theme: AppTheme.light, home: const Scaffold(
      body: ChoiceCard(icon: AppIcons.leaf, title: 'Titre', description: 'Description', selected: false),
    )));
    expect(t.getSize(find.byType(IconTile)), const Size(56, 56));
    expect(t.takeException(), isNull);
  });
  const assets = [
    'goal_loss',
    'goal_gain',
    'goal_definition',
    'goal_balance',
    'activity_desk',
    'activity_walk',
    'activity_run',
    'activity_training',
    'management_shopping',
    'management_pantry',
    'management_mixed',
    'solo_time',
    'solo_nutrition',
    'solo_waste',
    'diet_omnivore',
    'diet_vegetarian',
    'diet_vegan',
    'diet_pescatarian',
    'diet_no_pork',
    'diet_no_lactose',
    'diet_no_gluten',
    'pantry_reserve',
    'pantry_quick_check',
  ];
  for (final name in assets) {
    test('copie PNG optimisée $name : 256 px RGBA et référence réelle', () async {
      final file = File('assets/images/new_icons/$name.png');
      expect(file.existsSync(), isTrue);
      final bytes = file.readAsBytesSync();
      expect(bytes.take(8).toList(), [137, 80, 78, 71, 13, 10, 26, 10]);
      final data = ByteData.sublistView(bytes);
      expect((data.getUint32(16), data.getUint32(20)), (256, 256));
      expect(bytes[25], 6); // RGBA.
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final pixels = (await frame.image.toByteData(format: ui.ImageByteFormat.rawRgba))!.buffer.asUint8List();
      final alphas = [for (var i = 3; i < pixels.length; i += 4) pixels[i]];
      expect(alphas.first, 0);
      expect(alphas[255], 0);
      expect(alphas[255 * 256], 0);
      expect(alphas.last, 0);
      expect(alphas, contains(255));
      expect(alphas.any((a) => a > 0 && a < 255), isTrue);
      frame.image.dispose();
      codec.dispose();
      final refs = Directory('lib/screens')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .map((f) => f.readAsStringSync())
          .join();
      expect(refs, contains('assets/images/new_icons/$name.png'));
    });
  }
}
