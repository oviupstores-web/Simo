import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menoo/theme/theme.dart';

/// Spécimen : comment chaque police arabe s'accorde avec Plus Jakarta Sans
/// sur une même ligne. Régénérer avec :
///   flutter test test/font_specimen_test.dart --update-goldens
void main() {
  const alt = 'C:/Users/simos/AppData/Local/Temp/altfonts';

  /// Nom affiché → fichiers (400, 700). Le premier est celui embarqué aujourd'hui.
  const candidates = {
    'Noto Sans Arabic': ['assets/fonts/NotoSansArabic-400.ttf', 'assets/fonts/NotoSansArabic-700.ttf'],
    'IBM Plex Sans Arabic': ['$alt/IBMPlexSansArabic-400.ttf', '$alt/IBMPlexSansArabic-700.ttf'],
    'Cairo': ['$alt/Cairo-400.ttf', '$alt/Cairo-700.ttf'],
    'Readex Pro': ['$alt/ReadexPro-400.ttf', '$alt/ReadexPro-700.ttf'],
  };

  setUpAll(() async {
    final jakarta = FontLoader('PlusJakartaSans');
    for (final w in [400, 500, 600, 700, 800]) {
      jakarta.addFont(
        Future.value(ByteData.sublistView(File('assets/fonts/PlusJakartaSans-$w.ttf').readAsBytesSync())),
      );
    }
    await jakarta.load();

    for (final entry in candidates.entries) {
      final loader = FontLoader(entry.key);
      for (final path in entry.value) {
        final file = File(path);
        if (file.existsSync()) loader.addFont(Future.value(ByteData.sublistView(file.readAsBytesSync())));
      }
      await loader.load();
    }
  });

  /// Hauteur d'une ligne réellement occupée à l'écran, en pixels.
  double lineHeight(String text, String fallback, double size) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontFamily: 'PlusJakartaSans', fontFamilyFallback: [fallback], fontSize: size, height: 1.5),
      ),
      textDirection: TextDirection.rtl,
    )..layout();
    return painter.height;
  }

  testWidgets('specimen', (t) async {
    t.view.physicalSize = const Size(1240, 1900);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.reset);

    const mixed = 'Menoo 2026 · قوائم متوازنة';
    const arabic = 'قوائم متوازنة تناسب ذوقك وميزانيتك وأسلوب حياتك.';
    const latin = 'Des menus équilibrés, adaptés à vos goûts.';

    await t.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Directionality(
          textDirection: TextDirection.ltr,
          child: ColoredBox(
            color: AppColors.bg,
            child: Padding(
              padding: const EdgeInsets.all(AppSpace.x6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Plus Jakarta Sans + chaque police arabe, sur une même ligne',
                    style: AppText.of(AppFont.s18, weight: AppFont.extrabold),
                  ),
                  const SizedBox(height: AppSpace.x2),
                  Text(
                    'La ligne verte marque la ligne de base. En dessous : la hauteur de ligne occupée, en pixels, pour un texte de 15 px.',
                    style: AppText.caption,
                  ),
                  const SizedBox(height: AppSpace.x5),
                  for (final name in candidates.keys) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: AppSpace.x4),
                      padding: const EdgeInsets.all(AppSpace.x4),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: AppRadius.cardR,
                        border: Border.all(
                          color: name == 'Noto Sans Arabic' ? AppColors.primary : AppColors.line,
                          width: name == 'Noto Sans Arabic' ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(name, style: AppText.of(AppFont.s14, weight: AppFont.extrabold)),
                              if (name == 'Noto Sans Arabic')
                                Padding(
                                  padding: const EdgeInsets.only(left: AppSpace.x2),
                                  child: Text(
                                    'EMBARQUÉE AUJOURD\'HUI',
                                    style: AppText.of(AppFont.s11, weight: AppFont.bold, color: AppColors.primary),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: AppSpace.x3),
                          _Baseline(
                            child: Text(
                              mixed,
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                fontFamily: AppFont.family,
                                fontFamilyFallback: [name],
                                fontSize: 26,
                                fontWeight: AppFont.extrabold,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpace.x2),
                          _Baseline(
                            child: Text(
                              mixed,
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                fontFamily: AppFont.family,
                                fontFamilyFallback: [name],
                                fontSize: 15,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpace.x2_5),
                          Text(
                            arabic,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontFamily: AppFont.family,
                              fontFamilyFallback: [name],
                              fontSize: 15,
                              height: 1.5,
                              color: AppColors.ink2,
                            ),
                          ),
                          const SizedBox(height: AppSpace.x2),
                          Text(
                            'hauteur de ligne : arabe ${lineHeight(arabic.split(' ').first, name, 15).toStringAsFixed(1)} px · '
                            'latin ${lineHeight(latin.split(' ').first, name, 15).toStringAsFixed(1)} px',
                            style: AppText.of(AppFont.s12, weight: AppFont.semibold, color: AppColors.warn),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await t.pumpAndSettle();

    await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/polices_arabes.png'));
  });
}

/// Trace une ligne de base verte sous le texte, pour voir si les deux écritures s'y posent.
class _Baseline extends StatelessWidget {
  const _Baseline({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(height: 1, color: AppColors.leaf),
          ),
        ),
        child,
      ],
    );
  }
}
