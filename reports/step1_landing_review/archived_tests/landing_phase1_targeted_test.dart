import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menoo/l10n/app_localizations.dart';
import 'package:menoo/screens/entry/landing_screen.dart';
import 'package:menoo/screens/entry/path_choice_screen.dart';
import 'package:menoo/theme/theme.dart';

void main() {
  setUpAll(() async {
    final loader = FontLoader('PlusJakartaSans');
    for (final weight in [400,500,600,700,800]) {
      loader.addFont(Future.value(ByteData.sublistView(File('assets/fonts/PlusJakartaSans-$weight.ttf').readAsBytesSync())));
    }
    await loader.load();
  });
  for (final width in [320.0,390.0]) {
    testWidgets('Targeted correction full French capture and existing routes $width', (t) async {
      t.view.physicalSize = Size(width,3000);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      final key = GlobalKey();
      await t.pumpWidget(RepaintBoundary(key:key,child:MaterialApp(
        debugShowCheckedModeBanner:false,theme:AppTheme.light,locale:const Locale('fr'),
        supportedLocales:L.supportedLocales,localizationsDelegates:L.localizationsDelegates,
        home:const LandingScreen(),
      )));
      await t.runAsync(() => LandingScreen.prepareImages(t.element(find.byType(LandingScreen))));
      await t.pumpAndSettle();
      expect(t.takeException(),isNull);
      final scroll=t.widget<SingleChildScrollView>(find.byType(SingleChildScrollView));
      final height=t.getSize(find.byWidget(scroll.child!)).height.ceilToDouble();
      t.view.physicalSize=Size(width,height);
      await t.pump();
      final geometry=<String,dynamic>{};
      for (final art in ['scan','meal_scan','menus','shopping','tracking']) {
        final card=find.byKey(ValueKey('landing_card_$art'));
        final r=t.getRect(card);
        final picture=find.descendant(of:card,matching:find.byType(Image));
        final ir=t.getRect(picture);
        if (art != 'tracking') {
          final cta = find.byKey(ValueKey('landing_cta_$art'));
          final texts = find.descendant(of:card,matching:find.byType(Text));
          final descriptionRect = t.getRect(texts.at(2));
          final ctaRect = t.getRect(cta);
          expect(ctaRect.top-descriptionRect.bottom,greaterThanOrEqualTo(16));
          expect(ctaRect.left,closeTo(descriptionRect.left,.001));
          expect(ctaRect.height,28);
          geometry['${art}_cta']={'gap':ctaRect.top-descriptionRect.bottom,'size':[ctaRect.width,ctaRect.height],'label':t.widget<Text>(find.descendant(of:cta,matching:find.byType(Text))).data};
        }
        geometry[art]={'card':[r.left,r.top,r.width,r.height], 'image':[ir.left,ir.top,ir.width,ir.height]};
      }
      await t.runAsync(() async {
        final boundary=t.renderObject<RenderRepaintBoundary>(find.byKey(key));
        final image=await boundary.toImage(pixelRatio:1);
        final bytes=await image.toByteData(format:ui.ImageByteFormat.png);
        File('reports/landing_phase1_targeted/flutter_${width.toInt()}.png').writeAsBytesSync(bytes!.buffer.asUint8List());
        File('reports/landing_phase1_targeted/geometry_${width.toInt()}.json').writeAsStringSync(jsonEncode(geometry));
        image.dispose();
      });
      for (final art in ['scan','meal_scan']) {
        await t.tap(find.byKey(ValueKey('landing_cta_$art')));
        await t.pumpAndSettle();
        expect(find.byType(LandingScreen),findsOneWidget);
        expect(find.byType(PathChoiceScreen),findsNothing);
      }
      await t.tap(find.byKey(const ValueKey('landing_cta_menus')));
      await t.pumpAndSettle();
      expect(find.byType(PathChoiceScreen),findsOneWidget);
      Navigator.of(t.element(find.byType(PathChoiceScreen))).pop();
      await t.pumpAndSettle();
      await t.tap(find.byKey(const ValueKey('landing_cta_shopping')));
      await t.pumpAndSettle();
      expect(find.byType(PathChoiceScreen),findsOneWidget);
      Navigator.of(t.element(find.byType(PathChoiceScreen))).pop();
      await t.pumpAndSettle();
      await t.tap(find.text('Commencer'));
      await t.pumpAndSettle();
      expect(find.byType(PathChoiceScreen),findsOneWidget);
      expect(t.takeException(),isNull);
      await t.pumpWidget(const SizedBox());
    });
  }
}
