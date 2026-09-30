import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../navigation.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import 'login_screen.dart';
import 'path_choice_screen.dart';

/// `landing` — **page déroulante d'avant le compte** : la promesse, ses avantages, les cartes de
/// fonctions et le bouton « Commencer ». À ne jamais confondre avec `home`, l'onglet 1 de
/// l'app après connexion (SPEC §0.13). Maître : design/masters/master_landing.html (réf. 01_landing.png).
/// SPEC §1 : sans note, nombre d'utilisateurs ni économies promises.
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  static List<(String, String, bool)> _features(L l) => [
    (AppIcons.cutlery, l.landingFeatureMeals, true),
    (AppIcons.wallet, l.landingFeatureBudget, false),
    (AppIcons.cart, l.landingFeatureShopping, true),
    (AppIcons.bars, l.landingFeatureTracking, false),
  ];

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    void toPathChoice() => push(context, const PathChoiceScreen());
    const side = EdgeInsets.symmetric(horizontal: AppSpace.gutter);
    return Scaffold(
      body: SafeArea(
        // La page peut défiler : priorité à la photo pleine largeur.
        // « Commencer gratuitement » reste visible sans défiler (liste d'avantages compacte).
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: AppSpace.x6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MenooHeader(
                brandLeft: true,
                topPadding: AppSpace.x4,
                trailing: GestureDetector(
                  onTap: toPathChoice,
                  child: Text(
                    l.commonSkip,
                    style: AppText.of(AppFont.s14, weight: AppFont.medium, color: AppColors.ink2),
                  ),
                ),
              ),
              Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  const Positioned(
                    right: AppSpace.x2,
                    top: AppSpace.x2,
                    child: BasilDecor(leafWidth: 40, mirror: true, peppers: false),
                  ),
                  Padding(
                    padding: side,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: AppSpace.x4),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(text: '${l.landingTitleLine1}\n'),
                              TextSpan(
                                text: l.landingTitleLine2,
                                style: AppText.display.copyWith(color: AppColors.primary),
                              ),
                            ],
                          ),
                          style: AppText.display,
                        ),
                        const SizedBox(height: AppSpace.x2),
                        Text(
                          l.landingSubtitle,
                          style: AppText.of(AppFont.s15, color: AppColors.ink2, lineHeight: 22),
                        ),
                        const SizedBox(height: AppSpace.x3),
                        // Liste d'avantages compacte (pastilles 34 px)
                        for (final (i, f) in _features(l).indexed) ...[
                          if (i > 0) const SizedBox(height: AppSpace.x1_5),
                          Row(
                            children: [
                              IconTile(
                                icon: f.$1,
                                size: AppSizes.iconTileSm,
                                iconSize: 18,
                                background: f.$3 ? AppColors.orangeSoft : AppColors.mint,
                                foreground: f.$3 ? AppColors.warn : AppColors.primary,
                              ),
                              const SizedBox(width: AppSpace.x3),
                              Expanded(child: Text(f.$2, style: AppText.of(AppFont.s14, lineHeight: 20))),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.x3),
              // Photo au format 5:4, pleine largeur, bord à bord, non rognée
              // (image source déjà au format 5:4), phrase manuscrite sur son coin haut gauche.
              AspectRatio(
                aspectRatio: AppSizes.landingHeroRatio,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/bowl_landing.jpg',
                      fit: BoxFit.cover,
                      semanticLabel: l.landingHeroAlt,
                    ),
                    Positioned(
                      left: AppSpace.x5,
                      top: AppSpace.x3,
                      child: Transform.rotate(
                        angle: AppSizes.handTilt,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          l.landingHandwritten,
                          style: AppText.hand(AppFont.s23, lineHeight: 24),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: side,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpace.x3),
                    PrimaryButton(
                      label: l.landingStart,
                      trailing: const OrangeArrowBadge(),
                      onPressed: toPathChoice,
                    ),
                    const SizedBox(height: AppSpace.x3),
                    SecondaryButton(label: l.landingHaveAccount, onPressed: () => push(context, const LoginScreen())),
                    const SizedBox(height: AppSpace.x5),
                    const _PageDots(count: 4, active: 0),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.active});

  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) const SizedBox(width: AppSpace.x2),
          Dot(i == active ? AppColors.primary : AppColors.line),
        ],
      ],
    );
  }
}
