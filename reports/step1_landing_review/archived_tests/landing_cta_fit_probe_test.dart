import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menoo/theme/theme.dart';

void main() {
  test('Measure CTA labels without changing their font', () async {
    final loader = FontLoader(AppFont.family);
    loader.addFont(Future.value(ByteData.sublistView(File('assets/fonts/PlusJakartaSans-700.ttf').readAsBytesSync())));
    await loader.load();
    for (final width in [320.0, 390.0]) {
      final zone = 360 * width / LandingTokens.referenceWidth;
      for (final label in width == 320
          ? ['Scanner', 'Analyser', 'Mes menus', 'Ma liste']
          : ['Scanner mon frigo', 'Analyser mon repas', 'Voir mes menus', 'Créer ma liste']) {
        final painter = TextPainter(text: TextSpan(text: label, style: AppText.of(
          LandingCtaTokens.fontSize, weight: AppFont.bold, lineHeight: LandingCtaTokens.lineHeight,
        )), textDirection: TextDirection.ltr)..layout();
        // Keep the existing 18 px icons; only tighten gaps and inner padding.
        final minimum = painter.width + 18 * 2 + 4 * 2 + 4 * 2;
        expect(minimum, lessThanOrEqualTo(zone), reason: '$width: $label');
        print('$width | $label | text=${painter.width.toStringAsFixed(2)} | zone=${zone.toStringAsFixed(2)} | minimum=${minimum.toStringAsFixed(2)}');
      }
    }
  });
}
