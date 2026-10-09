import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menoo/l10n/app_localizations.dart';
import 'package:menoo/onboarding/onboarding_data.dart';
import 'package:menoo/onboarding/onboarding_scope.dart';
import 'package:menoo/screens/onboarding/constraints_screen.dart';
import 'package:menoo/screens/onboarding/household_size_screen.dart';
import 'package:menoo/screens/onboarding/kitchen_screen.dart';
import 'package:menoo/screens/onboarding/member_profiles_screen.dart';
import 'package:menoo/screens/onboarding/summary_screen.dart';
import 'package:menoo/theme/theme.dart';
import 'package:menoo/widgets/widgets.dart';

void main() {
  setUpAll(() async {
    for (final entry in {
      'PlusJakartaSans': [
        for (final w in [400, 500, 600, 700, 800]) 'PlusJakartaSans-$w.ttf',
      ],
      'Caveat': ['Caveat-600.ttf'],
    }.entries) {
      final loader = FontLoader(entry.key);
      for (final path in entry.value) {
        loader.addFont(Future.value(ByteData.sublistView(File('assets/fonts/$path').readAsBytesSync())));
      }
      await loader.load();
    }
  });

  for (final language in ['fr', 'en', 'de']) {
    for (final width in [320.0, 390.0]) {
      final locale = Locale(language);
      final l = lookupL(locale);

      Future<void> pump(WidgetTester t, OnboardingData data, Widget screen) async {
        t.view.physicalSize = Size(width, 1200);
        t.view.devicePixelRatio = 1;
        await t.pumpWidget(
          MaterialApp(
            key: UniqueKey(),
            theme: AppTheme.light,
            locale: locale,
            supportedLocales: L.supportedLocales,
            localizationsDelegates: L.localizationsDelegates,
            builder: (_, child) => OnboardingScope(data: data, child: child!),
            home: screen,
          ),
        );
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);
      }

      testWidgets('B02 $language $width: fiche, Ma cuisine et récapitulatif à tour de rôle', (t) async {
        final data = OnboardingData()..startMode(AppMode.foyer);
        addTearDown(data.dispose);
        addTearDown(t.view.reset);
        await pump(t, data, const MemberProfilesScreen());
        await t.tap(find.text('Thomas'));
        await t.pumpAndSettle();
        await t.ensureVisible(find.widgetWithText(OptionTile, l.roleChild));
        await t.tap(find.widgetWithText(OptionTile, l.roleChild));
        await t.pumpAndSettle();
        await t.ensureVisible(find.text(l.memberSave));
        await t.tap(find.text(l.memberSave));
        await t.pumpAndSettle();
        expect(data.mainCookId, isNull);
        expect(data.members.singleWhere((m) => m.id == 1).role, MemberRole.enfant);
        await pump(t, data, const KitchenScreen());
        expect(
          find.byWidgetPredicate((w) => w is ToggleChip && w.label == l.kitchenCookTakingTurns && w.selected),
          findsOneWidget,
        );
        await pump(t, data, const SummaryScreen());
        expect(find.text(l.summaryCookRotating), findsOneWidget);
        expect(t.takeException(), isNull);
      });

      testWidgets('B01 $language $width: noms et rappel des allergies sans débordement', (t) async {
        final data = OnboardingData()..startMode(AppMode.foyer);
        addTearDown(data.dispose);
        addTearDown(t.view.reset);
        data.setCount(MemberRole.adulte, 3);
        data.members.lastWhere((m) => m.role == MemberRole.adulte).allergens.add('soja');
        await pump(t, data, const MemberProfilesScreen());
        expect(find.text('${l.roleAdult} 3'), findsOneWidget);
        await pump(t, data, const ConstraintsScreen());
        expect(find.textContaining('${l.roleAdult} 3'), findsOneWidget);
        await pump(t, data, const SummaryScreen());
        expect(find.textContaining('${l.roleAdult} 3'), findsWidgets);
        expect(data.allAllergens, {'soja', 'fruits_a_coque'});
      });

      testWidgets('B03 $language $width: message pour rôle complet, données conservées', (t) async {
        final data = OnboardingData()..startMode(AppMode.foyer);
        addTearDown(data.dispose);
        addTearDown(t.view.reset);
        data.setCount(MemberRole.enfant, 8);
        final before = [...data.members];
        await pump(t, data, MemberEditScreen(member: data.members.first.copy()));
        await t.ensureVisible(find.widgetWithText(OptionTile, l.roleChild));
        await t.tap(find.widgetWithText(OptionTile, l.roleChild));
        await t.pumpAndSettle();
        expect(find.text(l.householdRoleLimitError(8, l.roleChild)), findsOneWidget);
        expect(data.members, orderedEquals(before));
        expect(t.takeException(), isNull);
      });

      testWidgets('B03 $language $width: ajout propose un rôle disponible au maximum adulte', (t) async {
        final data = OnboardingData()..startMode(AppMode.foyer);
        addTearDown(data.dispose);
        addTearDown(t.view.reset);
        data.setCount(MemberRole.adulte, 8);
        final before = [...data.members];
        await pump(t, data, const MemberProfilesScreen());
        await t.ensureVisible(find.text(l.membersAdd));
        await t.tap(find.text(l.membersAdd));
        await t.pumpAndSettle();
        expect(find.byType(MemberEditScreen), findsOneWidget);
        expect(find.byWidgetPredicate((w) => w is OptionTile && w.label == l.roleChild && w.selected), findsOneWidget);
        expect(data.members, orderedEquals(before));
        await t.tap(find.byType(HeaderBackButton));
        await t.pumpAndSettle();
        expect(data.members, orderedEquals(before));
        expect(t.takeException(), isNull);
      });

      testWidgets('B03 $language $width: ajout refusé lorsque tous les rôles sont complets', (t) async {
        final data = OnboardingData()..startMode(AppMode.foyer);
        addTearDown(data.dispose);
        addTearDown(t.view.reset);
        for (final role in MemberRole.values) {
          data.setCount(role, OnboardingData.maxPerRole[role]!);
        }
        final before = [...data.members];
        await pump(t, data, const MemberProfilesScreen());
        await t.ensureVisible(find.text(l.membersAdd));
        await t.tap(find.text(l.membersAdd));
        await t.pumpAndSettle();
        expect(find.byType(MemberEditScreen), findsNothing);
        expect(find.text(l.householdRoleLimitError(8, l.roleAdult)), findsOneWidget);
        expect(data.members, orderedEquals(before));
        expect(t.takeException(), isNull);
      });

      testWidgets('B03 $language $width: message pour dernier adulte dans la fiche et compteur', (t) async {
        final data = OnboardingData()..startMode(AppMode.foyer);
        addTearDown(data.dispose);
        addTearDown(t.view.reset);
        data.setCount(MemberRole.adulte, 1);
        await pump(t, data, MemberEditScreen(member: data.members.first.copy()));
        await t.ensureVisible(find.widgetWithText(OptionTile, l.roleBaby));
        await t.tap(find.widgetWithText(OptionTile, l.roleBaby));
        await t.pumpAndSettle();
        expect(find.text(l.householdLastAdultError), findsOneWidget);
        await pump(t, data, const HouseholdSizeScreen());
        final stepper = t.widget<QuantityStepper>(find.byType(QuantityStepper).first);
        stepper.onMinus();
        await t.pumpAndSettle();
        expect(find.text(l.householdLastAdultError), findsOneWidget);
        expect(data.count(MemberRole.adulte), 1);
        expect(t.takeException(), isNull);
      });
    }
  }
}
