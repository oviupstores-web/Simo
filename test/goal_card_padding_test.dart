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
import 'package:menoo/screens/onboarding/goal_screen.dart';
import 'package:menoo/theme/theme.dart';
import 'package:menoo/widgets/selectable_card.dart';
import 'package:menoo/widgets/surfaces.dart';

void main() {
  const stage = String.fromEnvironment('GOAL_STAGE', defaultValue: 'after');
  const capture = bool.fromEnvironment('GOAL_CAPTURE');
  const output = r'C:\Users\simos\.codex\visualizations\2026\10\09\01a12009-4207-7b53-b4c3-391375738980\goal_padding';
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
    testWidgets('autres ChoiceCard : padding historique conservé, selected=$selected', (t) async {
      await t.pumpWidget(MaterialApp(theme: AppTheme.light, home: Scaffold(body: ChoiceCard(
        icon: AppIcons.leaf, title: 'Titre', description: 'Description', selected: selected,
      ))));
      final container = t.widget<AnimatedContainer>(find.byType(AnimatedContainer).first);
      expect(container.padding, EdgeInsets.all(selected ? 15 : 16));
      expect(t.takeException(), isNull);
    });
  }
  for (final language in ['fr', 'en', 'de']) {
    for (final width in [320.0, 390.0]) {
      for (final goal in HealthGoal.values) {
        testWidgets('$language $width : padding Objectif avec ${goal.name} sélectionné', (t) async {
          t.view.physicalSize = Size(width, 1500);
          t.view.devicePixelRatio = 1;
          addTearDown(t.view.reset);
          final data = OnboardingData()..startMode(AppMode.solo)..goal = goal;
          addTearDown(data.dispose);
          const boundaryKey = ValueKey('goal-padding-capture');
          await t.pumpWidget(RepaintBoundary(key: boundaryKey, child: MaterialApp(
            theme: AppTheme.light,
            debugShowCheckedModeBanner: false,
            locale: Locale(language),
            supportedLocales: L.supportedLocales,
            localizationsDelegates: L.localizationsDelegates,
            builder: (_, child) => OnboardingScope(data: data, child: child!),
            home: const GoalScreen(),
          )));
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
          for (final element in find.byType(ChoiceCard).evaluate()) {
            final card = element.widget as ChoiceCard;
            final finder = find.byWidget(card);
            final box = t.getRect(finder);
            final tile = t.getRect(find.descendant(of: finder, matching: find.byType(IconTile)));
            final title = t.getRect(find.descendant(of: finder, matching: find.text(card.title)));
            final description = t.getRect(find.descendant(of: finder, matching: find.text(card.description)));
            final image = t.getRect(find.descendant(of: finder, matching: find.byType(Image)));
            final border = card.selected ? 2.0 : 1.0;
            final left = tile.left - box.left - border;
            final top = tile.top - box.top - border;
            final bottom = box.bottom - border - tile.bottom;
            final expectedPadding = stage == 'before' ? (card.selected ? 15.0 : 16.0) : (card.selected ? 7.0 : 8.0);
            expect(left, expectedPadding);
            expect(top, closeTo(bottom, 0.001));
            expect(top, greaterThanOrEqualTo(expectedPadding));
            expect(tile.size, const Size(70, 70));
            expect(image.size, const Size(66, 66));
            if (language == 'de' && width == 320 && card.badge != null) {
              expect(title.height, 24, reason: 'Abnehmen doit rester entier à 320 px');
            }
            expect(title.left - tile.right, 12);
            expect(description.left, title.left);
            expect(description.right, lessThanOrEqualTo(box.right - border));
            final animated = t.widget<AnimatedContainer>(find.descendant(of: finder, matching: find.byType(AnimatedContainer)).first);
            final padding = animated.padding!.resolve(TextDirection.ltr);
            expect(padding.right, card.selected ? 15 : 16);
            expect(padding.left, expectedPadding);
            expect(padding.top, expectedPadding);
            expect(padding.bottom, expectedPadding);
            measurements.add({'language': language, 'width': width, 'goal': goal.name,
              'card': card.title, 'selected': card.selected, 'height': box.height,
              'left': left, 'top': top, 'bottom': bottom, 'gap': title.left - tile.right,
              'title_height': title.height, 'description_height': description.height});
          }
          expect(measurements.length, 4);
          if (capture) {
            await t.runAsync(() async {
              final directory = Directory('$output/$stage')..createSync(recursive: true);
              File('${directory.path}/${language}_${width.toInt()}_${goal.name}.json')
                  .writeAsStringSync(jsonEncode(measurements));
              if (goal == HealthGoal.maintien) {
                final boundary = t.renderObject<RenderRepaintBoundary>(find.byKey(boundaryKey));
                final image = await boundary.toImage(pixelRatio: 2);
                final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
                File('${directory.path}/${language}_${width.toInt()}.png').writeAsBytesSync(bytes!.buffer.asUint8List());
                image.dispose();
              }
            });
          }
        });
      }
    }
  }
}
