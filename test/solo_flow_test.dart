import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:menoo/l10n/app_localizations.dart';
import 'package:menoo/main.dart';
import 'package:menoo/screens/entry/landing_screen.dart';
import 'package:menoo/screens/entry/startup_screen.dart';

/// Parcours complet : landing → choix du mode → couverture → 11 étapes Solo,
/// avec le détour Réserve (mode Mixte) et un ajout manuel, jusqu'au récapitulatif.
void main() {
  // Vraies polices (sinon la police de test, très large, crée de faux débordements)
  setUpAll(() async {
    final jakarta = FontLoader('PlusJakartaSans');
    for (final w in [400, 500, 600, 700, 800]) {
      jakarta.addFont(
        Future.value(ByteData.sublistView(File('assets/fonts/PlusJakartaSans-$w.ttf').readAsBytesSync())),
      );
    }
    await jakarta.load();
    final caveat = FontLoader('Caveat')
      ..addFont(Future.value(ByteData.sublistView(File('assets/fonts/Caveat-600.ttf').readAsBytesSync())));
    await caveat.load();
  });

  Future<void> tapText(WidgetTester t, String text) async {
    final f = find.text(text).last;
    await t.ensureVisible(f);
    await t.pumpAndSettle();
    await t.tap(f);
    await t.pumpAndSettle();
  }

  Future<void> tapLandingStart(WidgetTester t) async {
    // Wait for the cold image cache, then advance the startup overlay until it
    // releases pointer events to the landing page.
    for (var i = 0; i < 12 && find.byType(LandingScreen).evaluate().isEmpty; i++) {
      await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 500)));
      await t.pump(const Duration(milliseconds: 500));
    }
    for (var i = 0; i < 8 && find.byType(MenooStartupVisual).evaluate().isNotEmpty; i++) {
      await t.pump(const Duration(seconds: 1));
    }
    await t.pumpAndSettle();
    final context = t.element(find.byType(MenooStartup));
    await tapText(t, L.of(context).landingStart);
  }

  Future<void> expectStep(WidgetTester t, int n, {int total = 11}) async {
    expect(find.text('ÉTAPE $n SUR $total'), findsOneWidget, reason: 'étape $n');
  }

  testWidgets('onboarding Solo complet avec détour Réserve', (t) async {
    // L'app suit la langue du système ; les tests visent les textes français.
    t.platformDispatcher.localesTestValue = const [Locale('fr', 'FR')];
    addTearDown(t.platformDispatcher.clearLocalesTestValue);
    t.view.physicalSize = const Size(1080, 2400);
    t.view.devicePixelRatio = 2.75;
    addTearDown(t.view.reset);

    await t.pumpWidget(const MenooApp());
    await t.pumpAndSettle();

    await tapLandingStart(t);
    expect(find.text('Quel est votre mode ?'), findsOneWidget);
    await tapText(t, 'Continuer');
    await tapText(t, 'Commencer mon profil');

    await expectStep(t, 1);
    await tapText(t, 'Prise de masse');
    await tapText(t, 'Continuer');

    await expectStep(t, 2);
    // Prise de masse : poids visé obligatoire (75 → 80 kg à 0,5 kg/semaine = 10 semaines)
    await t.enterText(find.byType(TextField).at(3), '80');
    await t.pumpAndSettle();
    expect(find.textContaining('Environ 10 semaines', findRichText: true), findsOneWidget);
    await tapText(t, 'Continuer');

    await expectStep(t, 3);
    await tapText(t, 'Continuer');

    await expectStep(t, 4);
    await tapText(t, 'Passer cette étape');

    await expectStep(t, 5);
    expect(find.textContaining('14 repas', findRichText: true), findsOneWidget);
    await tapText(t, 'Continuer');

    await expectStep(t, 6);
    expect(find.text('65'), findsOneWidget);
    await tapText(t, 'Continuer');

    await expectStep(t, 7);
    // Mixte par défaut → détour Réserve
    await tapText(t, 'Continuer');
    expect(find.text('Remplissez votre réserve'), findsOneWidget);
    expect(find.textContaining('ÉTAPE'), findsNothing, reason: 'pas de compteur dans le détour');

    await tapText(t, 'Manuel');
    await t.enterText(find.byType(TextField).first, 'Yaourt nature');
    await t.pumpAndSettle();
    await tapText(t, 'Ajouter à ma réserve');
    expect(find.text('Yaourt nature'), findsOneWidget);
    expect(find.text('Réfrigérateur'), findsWidgets, reason: 'yaourt rangé au réfrigérateur');

    await tapText(t, 'Terminer et continuer');
    await expectStep(t, 8);
    await tapText(t, 'Végétarien');
    await tapText(t, 'Continuer');

    await expectStep(t, 9);
    expect(find.textContaining('Quelles cuisines aimez'), findsOneWidget);
    await tapText(t, 'Italienne');
    await tapText(t, 'Continuer');

    await expectStep(t, 10);
    await tapText(t, 'Continuer');

    await expectStep(t, 11);
    expect(find.text('Votre profil est prêt !'), findsOneWidget);
    expect(find.text('Prise de masse'), findsOneWidget);
    expect(find.textContaining('Objectif : 80 kg'), findsOneWidget);
    expect(find.textContaining('1 produit en réserve'), findsOneWidget);
    expect(find.textContaining('Végétarien'), findsOneWidget);
    expect(find.textContaining('Cuisines : Italienne'), findsOneWidget);
    expect(find.text('Ma cuisine'), findsOneWidget);

    // « Éditer » ramène au récapitulatif après modification
    await t.ensureVisible(find.text('Éditer').first);
    await t.pumpAndSettle();
    await t.tap(find.text('Éditer').first);
    await t.pumpAndSettle();
    await expectStep(t, 1);
    await tapText(t, 'Maintien & Équilibre');
    await tapText(t, 'Continuer');
    await expectStep(t, 11);
    expect(find.text('Maintien & Équilibre'), findsOneWidget);
  });

  testWidgets('garde-fous du poids visé', (t) async {
    // L'app suit la langue du système ; les tests visent les textes français.
    t.platformDispatcher.localesTestValue = const [Locale('fr', 'FR')];
    addTearDown(t.platformDispatcher.clearLocalesTestValue);
    t.view.physicalSize = const Size(1080, 2400);
    t.view.devicePixelRatio = 2.75;
    addTearDown(t.view.reset);
    await t.pumpWidget(const MenooApp());
    await t.pumpAndSettle();
    await tapLandingStart(t);
    await tapText(t, 'Continuer');
    await tapText(t, 'Commencer mon profil');
    // Perte de poids (par défaut) → étape 2
    await tapText(t, 'Continuer');
    final target = find.byType(TextField).at(3);

    // Poids visé au-dessus du poids actuel : refusé
    await t.enterText(target, '80');
    await tapText(t, 'Continuer');
    expect(find.textContaining('inférieur à votre poids actuel'), findsOneWidget);
    await expectStep(t, 2);

    // IMC < 18,5 (180 cm, 55 kg) : refusé avec explication
    await t.enterText(target, '55');
    await tapText(t, 'Continuer');
    expect(find.textContaining('IMC de 17'), findsOneWidget);
    expect(find.textContaining('au moins 60 kg'), findsOneWidget);
    await expectStep(t, 2);

    // 70 kg à 0,75 kg/semaine : 7 semaines, accepté
    await t.enterText(target, '70');
    await tapText(t, '0,75 kg');
    expect(find.textContaining('Environ 7 semaines', findRichText: true), findsOneWidget);
    await tapText(t, 'Continuer');
    await expectStep(t, 3);
  });

  testWidgets('onboarding Foyer complet avec détour Réserve', (t) async {
    // L'app suit la langue du système ; les tests visent les textes français.
    t.platformDispatcher.localesTestValue = const [Locale('fr', 'FR')];
    addTearDown(t.platformDispatcher.clearLocalesTestValue);
    t.view.physicalSize = const Size(1080, 2400);
    t.view.devicePixelRatio = 2.75;
    addTearDown(t.view.reset);
    Future<void> step(int n) => expectStep(t, n, total: 9);

    await t.pumpWidget(const MenooApp());
    await t.pumpAndSettle();
    await tapLandingStart(t);
    await tapText(t, 'Pour la famille');
    await tapText(t, 'Continuer');
    expect(find.textContaining('10 étapes rapides'), findsOneWidget);
    await tapText(t, 'Commencer la configuration');

    // 1. Composition : famille Martin (2 adultes, 2 enfants) par défaut
    await step(1);
    expect(find.textContaining('4 personnes à table', findRichText: true), findsOneWidget);
    await tapText(t, 'Continuer');

    // 2. Profils : Emma est allergique aux fruits à coque ; sa fiche s'ouvre et s'enregistre
    await step(2);
    expect(find.text('Thomas'), findsOneWidget);
    expect(find.text('Allergie : Fruits à coque'), findsOneWidget);
    await tapText(t, 'Emma');
    expect(find.text('Profil de Emma'), findsOneWidget);
    await tapText(t, 'Enregistrer');
    await step(2);
    await tapText(t, 'Continuer');

    // 3. Repas : soirs + week-end = 9 repas, 36 portions
    await step(3);
    expect(find.textContaining('9 repas', findRichText: true), findsOneWidget);
    await tapText(t, 'Continuer');

    // 4. Budget conseillé : 30 × 2 + 20 × 2 = 100 €
    await step(4);
    expect(find.text('100'), findsOneWidget);
    expect(find.textContaining('36 portions'), findsOneWidget);
    await tapText(t, 'Continuer');

    // 5. Contraintes partagées : l'allergie d'Emma est rappelée
    await step(5);
    expect(find.textContaining('Fruits à coque (Emma)'), findsOneWidget);
    await tapText(t, 'Sans porc');
    await tapText(t, 'Continuer');

    // 6. Mode Mixte → détour Réserve → retour aux types de cuisine
    await step(6);
    await tapText(t, 'Continuer');
    expect(find.text('Remplissez votre réserve'), findsOneWidget);
    await tapText(t, 'Terminer et continuer');

    await step(7);
    expect(find.textContaining('font l'), findsOneWidget);
    await tapText(t, 'Maghrébine');
    await tapText(t, 'Continuer');

    // 8. Ma cuisine + « Qui cuisine le plus souvent ? »
    await step(8);
    await tapText(t, 'À tour de rôle');
    await tapText(t, 'Continuer');

    // 9. Récapitulatif Foyer
    await step(9);
    expect(find.text('Composition du foyer'), findsOneWidget);
    expect(find.textContaining('4 personnes : 2 adultes, 2 enfants'), findsOneWidget);
    expect(find.textContaining('Fruits à coque (Emma)'), findsOneWidget);
    expect(find.textContaining('Sans porc'), findsOneWidget);
    expect(find.textContaining('Cuisines : Maghrébine'), findsOneWidget);
    expect(find.text('Cuisine : à tour de rôle'), findsOneWidget);
    expect(find.text('Générer notre menu'), findsOneWidget);
    expect(find.textContaining('kcal'), findsNothing, reason: 'pas de cible Solo en Foyer');
  });
}
