import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_text.dart';
import '../theme/app_tokens.dart';
import 'app_icon.dart';

enum MenooTab { accueil, menus, courses, reserve, suivi }

/// Barre de navigation unique (5 onglets, mêmes icônes partout — SPEC §0.3).
class MenooNavBar extends StatelessWidget {
  const MenooNavBar({super.key, required this.current, this.onSelect});

  final MenooTab current;
  final ValueChanged<MenooTab>? onSelect;

  static List<(MenooTab, String, String)> _items(L l) => [
    (MenooTab.accueil, l.navHome, AppIcons.home),
    (MenooTab.menus, l.navMenus, AppIcons.week),
    (MenooTab.courses, l.navShopping, AppIcons.cart),
    (MenooTab.reserve, l.navPantry, AppIcons.fridge),
    (MenooTab.suivi, l.navTracking, AppIcons.bars),
  ];

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Container(
      padding: EdgeInsets.only(bottom: bottom),
      decoration: const BoxDecoration(
        color: AppColors.navBg,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: SizedBox(
        height: AppSizes.navHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (final (tab, label, icon) in _items(L.of(context)))
              _NavItem(label: label, icon: icon, active: tab == current, onTap: () => onSelect?.call(tab)),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.label, required this.icon, required this.active, this.onTap});

  final String label;
  final String icon;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primary : AppColors.ink2;
    return Semantics(
      selected: active,
      button: true,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: AppSizes.navItemW,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppIcon(icon, size: 23, color: color, strokeWidth: active ? 2.1 : 1.8),
              const SizedBox(height: AppSpace.x0_5),
              Text(
                label,
                style: AppText.of(
                  AppFont.s11,
                  weight: active ? AppFont.bold : AppFont.medium,
                  color: color,
                  lineHeight: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
