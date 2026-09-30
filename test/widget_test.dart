import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:menoo/main.dart';

void main() {
  testWidgets('L\'app démarre et affiche Menoo', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('fr', 'FR')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    await tester.pumpWidget(const MenooApp());
    expect(find.text('Menoo'), findsOneWidget);
  });
}
