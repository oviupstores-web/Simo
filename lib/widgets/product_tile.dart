import 'package:flutter/material.dart';

import '../theme/theme.dart';
import 'app_icon.dart';
import 'pressable.dart';

/// Photo produit détourée sur fond blanc (équipements, niveaux de cuisine, types de cuisine).
/// Tant que l'image n'est pas fournie (voir design/stitch_images/A_FOURNIR.md), un cadre sobre
/// avec une icône au trait gris clair la remplace — jamais de pastille colorée.
class ProductPhoto extends StatelessWidget {
  const ProductPhoto({super.key, required this.asset, required this.fallbackIcon, this.cover = false});

  final String asset;
  final String fallbackIcon;

  /// Photo « scène » plein cadre (types de cuisine) plutôt que produit détouré.
  final bool cover;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      fit: cover ? BoxFit.cover : BoxFit.contain,
      excludeFromSemantics: true,
      errorBuilder: (_, _, _) => Container(
        decoration: const BoxDecoration(color: AppColors.neutralSoft, borderRadius: AppRadius.tileR),
        alignment: Alignment.center,
        child: AppIcon(fallbackIcon, size: AppSizes.productFallbackIcon, color: AppColors.ink3, strokeWidth: 1.6),
      ),
    );
  }
}

/// Tuile « produit » : grande photo, nom dessous, case à cocher verte en haut à droite,
/// bordure verte quand l'élément est sélectionné (modèle fourni par Simo).
class ProductTile extends StatelessWidget {
  const ProductTile({
    super.key,
    required this.label,
    required this.asset,
    required this.fallbackIcon,
    required this.selected,
    this.subtitle,
    this.onTap,
    this.radio = false,
    this.cover = false,
  });

  final String label;
  final String? subtitle;
  final String asset;
  final String fallbackIcon;
  final bool selected;
  final VoidCallback? onTap;

  /// Choix unique : rond plutôt que case carrée.
  final bool radio;
  final bool cover;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      label: label,
      child: Pressable(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppMotion.normal,
          curve: AppMotion.curve,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: AppRadius.cardR,
            border: Border.all(color: selected ? AppColors.primary : AppColors.line, width: selected ? 2 : 1),
            boxShadow: AppShadows.card,
          ),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.all(cover ? 0 : AppSpace.x2_5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: cover ? BorderRadius.zero : AppRadius.tileR,
                        child: ProductPhoto(asset: asset, fallbackIcon: fallbackIcon, cover: cover),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        cover ? AppSpace.x2 : 0,
                        AppSpace.x2,
                        cover ? AppSpace.x2 : 0,
                        cover ? AppSpace.x2_5 : 0,
                      ),
                      child: Column(
                        children: [
                          Text(
                            label,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.of(
                              AppFont.s14,
                              weight: selected ? AppFont.bold : AppFont.semibold,
                              color: selected ? AppColors.primaryDark : AppColors.ink,
                              lineHeight: 19,
                            ),
                          ),
                          if (subtitle != null)
                            Text(
                              subtitle!,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              style: AppText.of(AppFont.s11, color: AppColors.ink2, lineHeight: 14),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              PositionedDirectional(
                top: AppSpace.x2,
                end: AppSpace.x2,
                child: _Check(selected: selected, radio: radio),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Check extends StatelessWidget {
  const _Check({required this.selected, required this.radio});

  final bool selected;
  final bool radio;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppMotion.fast,
      width: AppSizes.checkCircle,
      height: AppSizes.checkCircle,
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : AppColors.card,
        shape: radio ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: radio ? null : BorderRadius.circular(AppRadius.checkbox),
        border: Border.all(color: selected ? AppColors.primary : AppColors.ink3, width: 1.5),
      ),
      alignment: Alignment.center,
      child: selected ? const AppIcon(AppIcons.check, size: 14, color: AppColors.white, strokeWidth: 3) : null,
    );
  }
}
