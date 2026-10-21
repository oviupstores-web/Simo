import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menoo/theme/app_colors.dart';
import 'package:menoo/theme/app_icons.dart';
import 'package:menoo/theme/premium_icons.dart';
import 'package:menoo/theme/app_tints.dart';
import 'package:menoo/widgets/thumbs.dart';
import 'package:menoo/widgets/app_icon.dart';
import 'package:menoo/widgets/pills.dart';
import 'package:menoo/widgets/surfaces.dart';
import 'package:menoo/widgets/toggles.dart';

class _UnavailablePremiumBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) {
    if (key.startsWith(PremiumIcons.directory)) {
      throw FlutterError('Premium test asset unavailable');
    }
    return rootBundle.load(key);
  }
}

Widget _host(Widget child, {AssetBundle? bundle}) => MaterialApp(
  home: Scaffold(
    body: Center(
      child: bundle == null ? child : DefaultAssetBundle(bundle: bundle, child: child),
    ),
  ),
);

void main() {
  test('50 unique premium PNG assets exist', () {
    expect(PremiumIcons.assets.length, 50);
    expect(PremiumIcons.assets.values.toSet().length, 50);
    for (final path in PremiumIcons.assets.values) {
      final file = File(path);
      expect(file.existsSync(), isTrue, reason: path);
      expect(file.lengthSync(), greaterThan(0), reason: path);
    }
  });

  for (final entry in PremiumIcons.assets.entries) {
    testWidgets('premium 32px ${entry.value.split('/').last}', (t) async {
      await t.pumpWidget(_host(AppIcon(entry.key, size: 28, premiumAsset: entry.value)));
      await t.pumpAndSettle();
      final image = t.widget<Image>(find.byType(Image));
      expect(image.fit, BoxFit.contain);
      expect(image.color, isNull);
      expect(t.getSize(find.byType(Image)), const Size(32, 32));
      expect(t.takeException(), isNull);
    });
  }

  for (final entry in PremiumIcons.secondaryAssets.entries) {
    testWidgets('secondary SVG resolves to final PNG ${entry.value}', (t) async {
      await t.pumpWidget(_host(AppIcon(entry.key, size: 18)));
      await t.pumpAndSettle();
      final image = t.widget<Image>(find.byType(Image));
      expect((image.image as AssetImage).assetName, entry.value);
      expect(t.getSize(find.byType(Image)), const Size(32, 32));
      expect(find.byType(SvgPicture), findsNothing);
      expect(t.takeException(), isNull);
    });
  }

  testWidgets('ambiguous shield stays SVG while protection uses PNG', (t) async {
    await t.pumpWidget(_host(const AppIcon(AppIcons.shield, size: 15, preserveSvg: true)));
    expect(find.byType(SvgPicture), findsOneWidget);
    expect(find.byType(Image), findsNothing);
    expect(t.getSize(find.byType(SvgPicture)), const Size(15, 15));
    await t.pumpWidget(_host(const AppIcon(AppIcons.shield, color: AppColors.white)));
    await t.pumpAndSettle();
    expect(t.widget<Image>(find.byType(Image)).color, AppColors.white);
    expect(t.getSize(find.byType(Image)), const Size(32, 32));
  });

  testWidgets('navigation uses final PNG without enlarging its footprint', (t) async {
    await t.pumpWidget(_host(const AppIcon(AppIcons.fridge, size: 26, compactNavigation: true)));
    await t.pumpAndSettle();
    expect(t.getSize(find.byType(Image)), const Size(26, 26));
    expect(find.byType(SvgPicture), findsNothing);
  });

  testWidgets('decorative premium badges use uniform mint and real 36px drawing', (t) async {
    for (final tint in [Tint.peach, Tint.lavender, Tint.mint]) {
      await t.pumpWidget(_host(TintBadge(icon: AppIcons.child, tint: tint, size: 56)));
      await t.pumpAndSettle();
      final box = t.widget<Container>(
        find.descendant(of: find.byType(TintBadge), matching: find.byType(Container)).first,
      );
      expect((box.decoration as BoxDecoration).color, const Color(0xFFEAF6EB));
      expect(t.getSize(find.byType(Image)), const Size(36, 36));
    }
  });

  testWidgets('functional badge and existing PNG keep their original color and footprint', (t) async {
    await t.pumpWidget(_host(const TintBadge(icon: AppIcons.check, tint: Tint.peach, size: 44)));
    final box = t.widget<Container>(
      find.descendant(of: find.byType(TintBadge), matching: find.byType(Container)).first,
    );
    expect((box.decoration as BoxDecoration).color, Tint.peach.soft);
    expect(t.getSize(find.byType(SvgPicture)), const Size(22, 22));
    await t.pumpWidget(
      _host(
        const IconTile(
          icon: AppIcons.pantryReserve,
          illustrationAsset: 'assets/images/new_icons/pantry_reserve.png',
          size: 70,
          illustrationSize: 66,
          background: AppColors.freezerSoft,
        ),
      ),
    );
    await t.pumpAndSettle();
    final tile = t.widget<Container>(
      find.descendant(of: find.byType(IconTile), matching: find.byType(Container)).first,
    );
    expect((tile.decoration as BoxDecoration).color, AppColors.freezerSoft);
    expect(t.getSize(find.byType(Image)), const Size(66, 66));
  });

  testWidgets('selected green tile keeps its background and light icon', (t) async {
    await t.pumpWidget(
      _host(
        const IconTile(icon: AppIcons.wallet, size: 56, background: AppColors.primary, foreground: AppColors.white),
      ),
    );
    await t.pumpAndSettle();
    final tile = t.widget<Container>(
      find.descendant(of: find.byType(IconTile), matching: find.byType(Container)).first,
    );
    expect((tile.decoration as BoxDecoration).color, AppColors.primary);
    expect(t.widget<Image>(find.byType(Image)).color, AppColors.white);
    expect(t.getSize(find.byType(Image)), const Size(36, 36));
  });

  testWidgets('missing final PNG reports an error without rendering old SVG', (t) async {
    await t.pumpWidget(_host(const AppIcon(AppIcons.calendar, size: 28), bundle: _UnavailablePremiumBundle()));
    await t.pumpAndSettle();
    expect(find.byType(SvgPicture), findsNothing);
    expect(t.takeException(), isNotNull);
  });

  testWidgets('compact white and shared pantry contexts use final PNG at 32 minimum', (t) async {
    for (final icon in [
      const AppIcon(AppIcons.calendar, size: 18),
      const AppIcon(AppIcons.calendar, size: 28, color: AppColors.white),
      const AppIcon(AppIcons.managementPantry, size: 36),
    ]) {
      await t.pumpWidget(_host(icon));
      await t.pumpAndSettle();
      expect(find.byType(SvgPicture), findsNothing);
      expect(find.byType(Image), findsOneWidget);
      expect(t.getSize(find.byType(Image)).width, greaterThanOrEqualTo(32));
      expect(t.takeException(), isNull);
    }
    await t.pumpWidget(_host(const AppIcon(AppIcons.back, size: 18)));
    expect(find.byType(SvgPicture), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('existing PNG illustration remains unchanged despite registered SVG equivalent', (t) async {
    await t.pumpWidget(
      _host(
        const IconTile(
          icon: AppIcons.pantryReserve,
          illustrationAsset: 'assets/images/new_icons/pantry_reserve.png',
          size: 70,
          illustrationSize: 66,
        ),
      ),
    );
    await t.pumpAndSettle();
    final image = t.widget<Image>(find.byType(Image));
    expect((image.image as AssetImage).assetName, 'assets/images/new_icons/pantry_reserve.png');
    expect(t.getSize(find.byType(Image)), const Size(66, 66));
    expect(t.takeException(), isNull);
  });

  testWidgets('selected dark background tints final PNG white without extra backdrop', (t) async {
    await t.pumpWidget(_host(const AppIcon(AppIcons.male, color: AppColors.white, size: 28)));
    await t.pumpAndSettle();
    final image = t.widget<Image>(find.byType(Image));
    expect(image.color, AppColors.white);
    expect(image.colorBlendMode, BlendMode.srcIn);
    expect(find.descendant(of: find.byType(AppIcon), matching: find.byType(DecoratedBox)), findsNothing);
    expect(find.byType(SvgPicture), findsNothing);
  });

  testWidgets('selected and unselected recipe chips retain original PNG colors', (t) async {
    for (final selected in [false, true]) {
      await t.pumpWidget(_host(InfoChip(label: '25 min', icon: AppIcons.clock, highlighted: selected)));
      await t.pumpAndSettle();
      final image = t.widget<Image>(find.byType(Image));
      expect(image.color, isNull);
      expect(t.getSize(find.byType(Image)), const Size(32, 32));
      expect(t.takeException(), isNull);
    }
  });

  testWidgets('allergen selection keeps PNG and functional check distinct', (t) async {
    for (final selected in [false, true]) {
      await t.pumpWidget(_host(ToggleChip(label: 'Poisson', selected: selected, icon: AppIcons.fish)));
      await t.pumpAndSettle();
      final image = t.widget<Image>(find.byType(Image));
      expect(image.color, isNull);
      expect(t.getSize(find.byType(Image)), const Size(32, 32));
      expect(
        find.byWidgetPredicate((w) => w is AppIcon && w.svg == AppIcons.check),
        selected ? findsOneWidget : findsNothing,
      );
      expect(t.takeException(), isNull);
    }
  });

  testWidgets('compact colored pantry filters use final PNG in both states', (t) async {
    for (final selected in [false, true]) {
      await t.pumpWidget(_host(FilterPill(label: 'Placard', selected: selected, icon: AppIcons.cupboard)));
      await t.pumpAndSettle();
      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(SvgPicture), findsNothing);
      expect(t.takeException(), isNull);
    }
  });
}
