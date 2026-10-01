import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_text.dart';
import '../theme/app_tokens.dart';
import 'app_icon.dart';
import 'pills.dart';
import 'pressable.dart';
import 'surfaces.dart';

/// Indicateur de sélection : rond vert coché, ou carré vide.
class SelectionIndicator extends StatelessWidget {
  const SelectionIndicator({
    super.key,
    required this.selected,
    this.size = AppSizes.checkCircle,
    this.roundWhenOff = false,
  });

  final bool selected;
  final double size;

  /// Rond vide quand non sélectionné (choix du mode) plutôt que carré (objectif).
  final bool roundWhenOff;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppMotion.normal,
      transitionBuilder: (child, a) => ScaleTransition(scale: a, child: child),
      child: selected
          ? Container(
              key: const ValueKey('on'),
              width: size,
              height: size,
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: AppIcon(AppIcons.check, size: size * 0.58, color: AppColors.white, strokeWidth: 3),
            )
          : Container(
              key: const ValueKey('off'),
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: AppColors.card,
                shape: roundWhenOff ? BoxShape.circle : BoxShape.rectangle,
                borderRadius: roundWhenOff ? null : BorderRadius.circular(AppRadius.checkbox),
                border: Border.all(color: AppColors.line, width: 2),
              ),
            ),
    );
  }
}

/// Carte à choix (gabarit de toutes les étapes à choix d'onboarding).
class ChoiceCard extends StatelessWidget {
  const ChoiceCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.selected,
    this.onTap,
    this.badge,
    this.iconBackground = AppColors.mint,
    this.iconForeground = AppColors.primary,
  });

  final String icon;
  final String title;
  final String description;
  final bool selected;
  final VoidCallback? onTap;
  final String? badge;
  final Color iconBackground;
  final Color iconForeground;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: Pressable(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppMotion.normal,
          curve: AppMotion.curve,
          padding: EdgeInsets.all(selected ? AppSpace.x4 - 1 : AppSpace.x4),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: AppRadius.cardR,
            border: Border.all(color: selected ? AppColors.primary : AppColors.line, width: selected ? 2 : 1),
            boxShadow: AppShadows.card,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconTile(icon: icon, size: AppSizes.iconTileLg, background: iconBackground, foreground: iconForeground),
              const SizedBox(width: AppSpace.x3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(child: Text(title, style: AppText.of(AppFont.s16, weight: AppFont.bold, lineHeight: 24))),
                        if (badge != null) ...[
                          const SizedBox(width: AppSpace.x2),
                          PillBadge.orange(
                            badge!,
                            padding: const EdgeInsets.symmetric(horizontal: AppSpace.x2, vertical: AppSpace.x0_5),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpace.x1),
                    Text(description, style: AppText.caption),
                  ],
                ),
              ),
              const SizedBox(width: AppSpace.x3),
              SelectionIndicator(selected: selected),
            ],
          ),
        ),
      ),
    );
  }
}

/// Petite coche verte ronde des listes d'avantages.
class CheckBullet extends StatelessWidget {
  const CheckBullet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.checkBullet,
      height: AppSizes.checkBullet,
      decoration: const BoxDecoration(color: AppColors.leaf, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: const AppIcon(AppIcons.check, size: 11, color: AppColors.white, strokeWidth: 3),
    );
  }
}
