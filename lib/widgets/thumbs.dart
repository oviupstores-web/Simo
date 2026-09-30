import 'package:flutter/material.dart';

import '../theme/theme.dart';
import 'app_icon.dart';

/// Pastille pastel avec icône teintée (principe des écrans maîtres).
class TintBadge extends StatelessWidget {
  const TintBadge({
    super.key,
    required this.icon,
    this.tint = Tint.mint,
    this.size = AppSizes.iconTile,
    this.circle = false,
  });

  final String icon;
  final Tint tint;
  final double size;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tint.soft,
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : AppRadius.tileR,
      ),
      alignment: Alignment.center,
      child: AppIcon(icon, size: size * 0.5, color: tint.ink),
    );
  }
}

/// Vignette d'aliment : photo si elle existe, sinon icône sur pastille.
class FoodThumb extends StatelessWidget {
  const FoodThumb({
    super.key,
    required this.photo,
    required this.icon,
    this.tint = Tint.mint,
    this.size = AppSizes.iconTile,
    this.circle = false,
  });

  /// Chemin d'asset (null → icône sur pastille).
  final String? photo;
  final String icon;
  final Tint tint;
  final double size;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    if (photo == null) return TintBadge(icon: icon, tint: tint, size: size, circle: circle);
    final image = Image.asset(photo!, width: size, height: size, fit: BoxFit.cover, excludeFromSemantics: true);
    return circle ? ClipOval(child: image) : ClipRRect(borderRadius: AppRadius.tileR, child: image);
  }
}
