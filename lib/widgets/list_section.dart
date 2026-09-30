import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../theme/app_tokens.dart';
import 'surfaces.dart';

/// Carte de section avec en-tête (icône, titre, compteur) et lignes séparées
/// (Réserve par emplacement, rayons de la liste de courses).
class ListSectionCard extends StatelessWidget {
  const ListSectionCard({
    super.key,
    required this.leading,
    required this.title,
    required this.count,
    required this.rows,
  });

  final Widget leading;
  final String title;
  final String count;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(AppSpace.x4, AppSpace.x3, AppSpace.x4, AppSpace.x1),
      child: Column(
        children: [
          Row(
            children: [
              leading,
              const SizedBox(width: AppSpace.x2_5),
              Expanded(child: Text(title, style: AppText.sectionTitle)),
              Text(count, style: AppText.meta),
            ],
          ),
          const SizedBox(height: AppSpace.x1),
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const Divider(height: 1, thickness: 1, color: AppColors.line),
            rows[i],
          ],
        ],
      ),
    );
  }
}

/// Ligne produit : vignette, nom + détail, éléments à droite.
class ItemRow extends StatelessWidget {
  const ItemRow({
    super.key,
    required this.image,
    required this.title,
    required this.subtitle,
    this.leading,
    this.trailing = const [],
    this.small = false,
  });

  final String image;
  final String title;
  final String subtitle;
  final Widget? leading;
  final List<Widget> trailing;

  /// Vignette 40×32 (courses) au lieu de 44×36.
  final bool small;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpace.x2_5),
      child: Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: AppSpace.x3)],
          Image.asset(
            'assets/images/$image',
            width: small ? AppSizes.thumbSmW : AppSizes.thumbW,
            height: small ? AppSizes.thumbSmH : AppSizes.thumbH,
            fit: BoxFit.contain,
            excludeFromSemantics: true,
          ),
          const SizedBox(width: AppSpace.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.rowTitle),
                Text(subtitle, style: AppText.meta, maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          for (final t in trailing) ...[const SizedBox(width: AppSpace.x3), t],
        ],
      ),
    );
  }
}

/// Statut d'un produit en réserve (« Frais » / « À consommer »).
class FreshnessStatus extends StatelessWidget {
  const FreshnessStatus({super.key, required this.urgent});

  final bool urgent;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final color = urgent ? AppColors.warn : AppColors.leaf;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Dot(color),
        const SizedBox(width: AppSpace.x1_5),
        Text(
          urgent ? l.freshnessToUse : l.freshnessFresh,
          style: AppText.of(AppFont.s12, weight: AppFont.semibold, color: color, lineHeight: 16),
        ),
      ],
    );
  }
}
