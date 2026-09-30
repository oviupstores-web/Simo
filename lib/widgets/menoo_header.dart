import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_text.dart';
import '../theme/app_tokens.dart';
import 'app_icon.dart';
import 'step_progress.dart';

/// Logo carré arrondi + logotype « Menoo ».
class MenooBrand extends StatelessWidget {
  const MenooBrand({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.logo),
          child: Image.asset(
            'assets/images/logo_96.png',
            width: AppSizes.logo,
            height: AppSizes.logo,
            semanticLabel: 'Menoo',
          ),
        ),
        const SizedBox(width: AppSpace.x2),
        Text('Menoo', style: AppText.logotype),
      ],
    );
  }
}

/// Bouton retour de l'en-tête (36 × 36, chevron 22 px).
class HeaderBackButton extends StatelessWidget {
  const HeaderBackButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Retour',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap ?? () => Navigator.of(context).maybePop(),
        child: Transform.translate(
          offset: const Offset(-AppSpace.x1, 0),
          child: const SizedBox.square(
            dimension: AppSizes.headerIconBox,
            child: Center(child: AppIcon(AppIcons.back, size: 22, strokeWidth: 2.2)),
          ),
        ),
      ),
    );
  }
}

/// Avatar rond de l'en-tête (uniquement une fois le compte créé — SPEC §0.2).
class HeaderAvatar extends StatelessWidget {
  const HeaderAvatar({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipOval(
        child: Image.asset(
          'assets/images/avatar.jpg',
          width: AppSizes.avatar,
          height: AppSizes.avatar,
          fit: BoxFit.cover,
          semanticLabel: 'Profil',
        ),
      ),
    );
  }
}

/// En-tête standard.
/// - [brandLeft] : logo à gauche, action à droite (landing, connexion, accueil).
/// - sinon : retour (ou vide) | logo centré | action (ou vide).
class MenooHeader extends StatelessWidget {
  const MenooHeader({
    super.key,
    this.brandLeft = false,
    this.showBack = true,
    this.onBack,
    this.trailing,
    this.step,
    this.totalSteps,
    this.topPadding = AppSpace.x4,
  });

  final bool brandLeft;
  final bool showBack;
  final VoidCallback? onBack;
  final Widget? trailing;
  final int? step;
  final int? totalSteps;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    final Widget row;
    if (brandLeft) {
      row = Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const MenooBrand(), ?trailing]);
    } else {
      const spacer = SizedBox(width: AppSizes.headerIconBox);
      row = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          showBack ? HeaderBackButton(onTap: onBack) : spacer,
          const MenooBrand(),
          trailing ?? spacer,
        ],
      );
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpace.gutter, topPadding, AppSpace.gutter, 0),
      child: Column(
        children: [
          row,
          if (step != null && totalSteps != null) ...[
            const SizedBox(height: AppSpace.x3),
            StepProgress(step: step!, total: totalSteps!),
          ],
        ],
      ),
    );
  }
}

/// Décor : feuilles de basilic entières accompagnées de grains de poivre
/// noirs et rouges (réf. 02 et 05). Toujours placé à l'intérieur de l'écran.
class BasilDecor extends StatelessWidget {
  const BasilDecor({super.key, required this.leafWidth, this.mirror = false, this.peppers = true, this.opacity = 1});

  /// Largeur de la feuille ; le décor occupe 1,6 × cette largeur au carré.
  final double leafWidth;

  /// Retourne le décor horizontalement (feuilles orientées vers la gauche).
  final bool mirror;
  final bool peppers;
  final double opacity;

  // Grains : position (en multiples de leafWidth), diamètre, rouge ?
  static const _grains = [
    (0.98, 1.22, 6.5, false),
    (1.26, 1.02, 5.5, true),
    (1.12, 1.42, 5.5, false),
    (1.42, 1.30, 6.0, false),
    (0.80, 1.48, 5.0, true),
  ];

  @override
  Widget build(BuildContext context) {
    final w = leafWidth;
    final decor = SizedBox(
      width: w * 1.6,
      height: w * 1.6,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Image.asset('assets/images/leaf_a.png', width: w, excludeFromSemantics: true),
          ),
          if (peppers)
            for (final (x, y, d, red) in _grains)
              Positioned(
                left: x * w,
                top: y * w,
                child: _Peppercorn(diameter: d, red: red),
              ),
        ],
      ),
    );
    return IgnorePointer(
      child: Opacity(
        opacity: opacity,
        child: mirror ? Transform.flip(flipX: true, child: decor) : decor,
      ),
    );
  }
}

class _Peppercorn extends StatelessWidget {
  const _Peppercorn({required this.diameter, required this.red});

  final double diameter;
  final bool red;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.4, -0.4),
          colors: [AppColors.pepperHighlight, red ? AppColors.pepperRed : AppColors.pepperBlack],
          stops: const [0, 0.55],
        ),
      ),
    );
  }
}
