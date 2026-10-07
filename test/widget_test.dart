import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:menoo/main.dart';
import 'package:menoo/screens/entry/startup_screen.dart';
import 'package:menoo/screens/entry/landing_screen.dart';

void main() {
  testWidgets('L\'app démarre et affiche Menoo', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('fr', 'FR')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    await tester.pumpWidget(const MenooApp());
    expect(find.byType(MenooStartupVisual), findsOneWidget);
    expect(find.byType(LandingScreen), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });
}
