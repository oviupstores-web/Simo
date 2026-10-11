import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menoo/l10n/app_localizations.dart';
import 'package:menoo/onboarding/onboarding_data.dart';
import 'package:menoo/onboarding/onboarding_scope.dart';
import 'package:menoo/screens/onboarding/activity_screen.dart';
import 'package:menoo/screens/onboarding/constraints_screen.dart';
import 'package:menoo/screens/onboarding/cover_household_screen.dart';
import 'package:menoo/screens/onboarding/cover_solo_screen.dart';
import 'package:menoo/screens/onboarding/goal_screen.dart';
import 'package:menoo/screens/onboarding/management_mode_screen.dart';
import 'package:menoo/screens/pantry/pantry_hub_onboarding_screen.dart';
import 'package:menoo/theme/theme.dart';
import 'package:menoo/widgets/widgets.dart';

void main() {
  const stage = String.fromEnvironment('HARM_STAGE', defaultValue: 'after');
  const capture = bool.fromEnvironment('HARM_CAPTURE');
  const output = r'C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\harmonisation';
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
  for (final selected in [false, true]) {
    testWidgets('ancienne ToggleChip : padding par défaut conservé, selected=$selected', (t) async {
      await t.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: ToggleChip(label: 'Titre', selected: selected, leading: const SizedBox(width: 20, height: 20)),
          ),
        ),
      );
      final box = t.widget<AnimatedContainer>(find.byType(AnimatedContainer).first);
      expect(box.padding, const EdgeInsetsDirectional.only(start: 6, end: 14));
      expect(t.getSize(find.byType(ToggleChip)).height, AppSizes.chipHeight);
      expect(t.takeException(), isNull);
    });
  }
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
  for (final language in ['fr', 'en', 'de']) {
    for (final width in [320.0, 390.0]) {
      for (final entry in screens.entries) {
        final variants = entry.key == 'activity'
            ? 4
            : entry.key.startsWith('management')
            ? 3
            : entry.key.startsWith('constraints')
            ? 8
            : entry.key.startsWith('pantry')
            ? 2
            : 1;
        for (var variant = 0; variant < variants; variant++) {
          testWidgets('harmonisation $language $width ${entry.key} état $variant', (t) async {
            t.view.physicalSize = Size(width, 1500);
            t.view.devicePixelRatio = 1;
            addTearDown(t.view.reset);
            final data = OnboardingData()
              ..startMode(entry.key.endsWith('foyer') ? AppMode.foyer : AppMode.solo)
              ..goal = HealthGoal.maintien;
            addTearDown(data.dispose);
            if (entry.key == 'activity') data.activity = ActivityLevel.values[variant];
            if (entry.key.startsWith('management')) data.management = ManagementMode.values[variant];
            if (entry.key.startsWith('constraints')) {
              const principal = [null, 'vegetarien', 'vegan', 'pescetarien'];
              data.selectPrincipalDiet(principal[variant % 4]);
              if (variant >= 4) data.diets.addAll(['sans_porc', 'sans_lactose', 'sans_gluten']);
            }
            if (entry.key.startsWith('pantry') && variant == 1) {
              data.pantry.addAll([
                for (var i = 0; i < 9; i++)
                  PantryDraft(
                    name: 'Produit $i',
                    quantity: 2,
                    unitLabel: 'kg',
                    location: PantryLocation.values[i % PantryLocation.values.length],
                  ),
              ]);
            }
            const key = ValueKey('harmonisation-capture');
            await t.pumpWidget(
              RepaintBoundary(
                key: key,
                child: MaterialApp(
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.light,
                  locale: Locale(language),
                  supportedLocales: L.supportedLocales,
                  localizationsDelegates: L.localizationsDelegates,
                  builder: (_, child) => OnboardingScope(data: data, child: child!),
                  home: entry.value,
                ),
              ),
            );
            await t.pumpAndSettle();
            final context = t.element(find.byType(MaterialApp));
            await t.runAsync(() async {
              for (final image in t.widgetList<Image>(find.byType(Image))) {
                await precacheImage(image.image, context);
              }
            });
            await t.pumpAndSettle();
            expect(t.takeException(), isNull);
            final measurements = <Map<String, Object>>[];
            final targetedCards = <Widget>{};
            for (final element in find.byType(Image).evaluate()) {
              final image = element.widget as Image;
              if (image.image is! AssetImage) continue;
              final name = (image.image as AssetImage).assetName;
              if (!name.startsWith('assets/images/new_icons/')) continue;
              final ancestors = <Element>[];
              element.visitAncestorElements((e) {
                ancestors.add(e);
                return true;
              });
              final cardElement = ancestors.firstWhere(
                (e) => e.widget is ChoiceCard || e.widget is AppCard || e.widget is ToggleChip,
              );
              final card = cardElement.widget;
              targetedCards.add(card);
              final tileElement = ancestors.firstWhere(
                (e) =>
                    e.widget is IconTile ||
                    (e.widget is Container &&
                        (e.widget as Container).decoration is BoxDecoration &&
                        ((e.widget as Container).decoration as BoxDecoration).shape == BoxShape.circle),
              );
              final cardFinder = find.byWidget(card);
              final box = t.getRect(cardFinder);
              final tile = t.getRect(find.byWidget(tileElement.widget));
              final imageBox = t.getRect(find.byWidget(image));
              final texts = find.descendant(of: cardFinder, matching: find.byType(Text));
              final firstText = t.widget<Text>(texts.first);
              final text = t.getRect(texts.first);
              final selected = card is ChoiceCard
                  ? card.selected
                  : card is ToggleChip
                  ? card.selected
                  : false;
              EdgeInsets padding;
              EdgeInsets border;
              if (card is AppCard) {
                padding = card.padding.resolve(TextDirection.ltr);
                border = card.border?.dimensions as EdgeInsets? ?? EdgeInsets.zero;
              } else {
                final animated = t.widget<AnimatedContainer>(
                  find.descendant(of: cardFinder, matching: find.byType(AnimatedContainer)).first,
                );
                padding = animated.padding!.resolve(TextDirection.ltr);
                border = (animated.decoration as BoxDecoration).border!.dimensions as EdgeInsets;
              }
              final isFood = name.contains('/diet_');
              final isPantry = name.contains('/pantry_');
              final expectedTile = entry.key == 'goal'
                  ? 70.0
                  : stage == 'before'
                  ? (isFood
                        ? 48.0
                        : isPantry
                        ? 56.0
                        : 64.0)
                  : isFood
                  ? 50.0
                  : 70.0;
              expect(tile.size, Size(expectedTile, expectedTile));
              expect(imageBox.size, Size(expectedTile - 4, expectedTile - 4));
              expect(image.fit, BoxFit.contain);
              expect(text.left - tile.right, isFood ? 8 : 12);
              final right = card is ChoiceCard
                  ? (selected ? 15.0 : 16.0)
                  : card is ToggleChip
                  ? 14.0
                  : name.endsWith('pantry_reserve.png')
                  ? 16.0
                  : 14.0;
              expect(padding.right, right);
              expect(tile.left, greaterThanOrEqualTo(box.left + border.left));
              expect(tile.top, greaterThanOrEqualTo(box.top + border.top));
              expect(tile.bottom, lessThanOrEqualTo(box.bottom - border.bottom));
              expect(tile.right, lessThanOrEqualTo(box.right - border.right));
              if (stage != 'before' && card is ChoiceCard) {
                expect(padding.left, selected ? 7 : 8);
                expect(padding.top, selected ? 7 : 8);
                expect(padding.bottom, selected ? 7 : 8);
              }
              if (stage != 'before' && card is ToggleChip) {
                expect(padding.left, 4);
                expect(box.height, 56);
              }
              measurements.add({
                'asset': name,
                'label': firstText.data ?? '',
                'component': card.runtimeType.toString(),
                'selected': selected,
                'height': box.height,
                'width': box.width,
                'tile': tile.height,
                'image': imageBox.height,
                'padding': [padding.left, padding.top, padding.bottom, padding.right],
                'spaces': [
                  tile.left - box.left - border.left,
                  tile.top - box.top - border.top,
                  box.bottom - border.bottom - tile.bottom,
                ],
                'gap': text.left - tile.right,
                'texts': [
                  for (final e in texts.evaluate())
                    {'text': (e.widget as Text).data ?? '', 'height': t.getSize(find.byWidget(e.widget)).height},
                ],
              });
            }
            expect(measurements, isNotEmpty);
            final legacy = <Map<String, Object>>[];
            for (final card in t.widgetList<AppCard>(find.byType(AppCard))) {
              if (targetedCards.contains(card)) continue;
              final rect = t.getRect(find.byWidget(card));
              legacy.add({'height': rect.height, 'width': rect.width, 'padding': card.padding.toString()});
            }
            if (capture) {
              await t.runAsync(() async {
                final dir = Directory('$output/$stage')..createSync(recursive: true);
                final stem = '${language}_${width.toInt()}_${entry.key}_$variant';
                File('${dir.path}/$stem.json').writeAsStringSync(jsonEncode({'cards': measurements, 'legacy': legacy}));
                if (variant == 0) {
                  final boundary = t.renderObject<RenderRepaintBoundary>(find.byKey(key));
                  final screenshot = await boundary.toImage(pixelRatio: 2);
                  final bytes = await screenshot.toByteData(format: ui.ImageByteFormat.png);
                  File('${dir.path}/$stem.png').writeAsBytesSync(bytes!.buffer.asUint8List());
                  screenshot.dispose();
                }
              });
            }
          });
        }
      }
    }
  }
}
