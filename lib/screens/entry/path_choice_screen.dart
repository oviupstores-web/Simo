import 'package:flutter/material.dart';

import '../../navigation.dart';
import '../../onboarding/onboarding_data.dart';
import '../../onboarding/onboarding_scope.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import '../onboarding/cover_household_screen.dart';
import '../onboarding/cover_individual_screen.dart';

/// path_choice — maître : design/masters/master_path_choice.html (réf. 03_path_choice.png).
/// SPEC §1 : écran hors compteur d'étapes.
class PathChoiceScreen extends StatefulWidget {
  const PathChoiceScreen({super.key});

  @override
  State<PathChoiceScreen> createState() => _PathChoiceScreenState();
}

class _PathChoiceScreenState extends State<PathChoiceScreen> {
  AppMode _mode = AppMode.solo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: AppSpace.x8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const MenooHeader(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpace.gutter),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpace.x6),
                    Text('Quel est votre mode ?', textAlign: TextAlign.center, style: AppText.h1),
                    const SizedBox(height: AppSpace.x2),
                    Text(
                      'Choisissez le mode qui correspond à votre situation. Vous pourrez le modifier plus tard.',
                      textAlign: TextAlign.center,
                      style: AppText.lead,
                    ),
                    const SizedBox(height: AppSpace.x6),
                    _ModeCard(
                      image: 'mode_solo.jpg',
                      title: 'Pour moi',
                      description: 'Des menus adaptés à mes objectifs personnels.',
                      bullets: const ['Perte de poids', 'Prise de masse', 'Maintien', 'Mode de vie sain'],
                      selected: _mode == AppMode.solo,
                      onTap: () => setState(() => _mode = AppMode.solo),
                    ),
                    const SizedBox(height: AppSpace.x3),
                    _ModeCard(
                      image: 'mode_famille.jpg',
                      title: 'Pour la famille',
                      description: 'Des menus adaptés à tous les membres du foyer.',
                      bullets: const [
                        'Adultes, enfants, bébés',
                        'Goûts et régimes différents',
                        'Budget global',
                        'Organisation simplifiée',
                      ],
                      selected: _mode == AppMode.foyer,
                      onTap: () => setState(() => _mode = AppMode.foyer),
                    ),
                    const SizedBox(height: AppSpace.x4),
                    const InfoBanner(
                      icon: AppIcons.bulb,
                      title: 'Un seul compte, deux modes',
                      text: 'Vous pourrez passer du mode Solo au mode Foyer à tout moment dans les réglages.',
                    ),
                    const SizedBox(height: AppSpace.x6),
                    PrimaryButton(
                      label: 'Continuer',
                      onPressed: () {
                        OnboardingScope.read(context).startMode(_mode);
                        push(
                          context,
                          _mode == AppMode.solo ? const CoverIndividualScreen() : const CoverHouseholdScreen(),
                        );
                      },
                    ),
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

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.image,
    required this.title,
    required this.description,
    required this.bullets,
    required this.selected,
    required this.onTap,
  });

  final String image;
  final String title;
  final String description;
  final List<String> bullets;
  final bool selected;
  final VoidCallback onTap;

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
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: selected ? AppColors.mintTint : AppColors.card,
            borderRadius: AppRadius.cardR,
            boxShadow: AppShadows.card,
          ),
          // Bordure dessinée par-dessus : la photo va jusqu'au bord de la carte, sans bande.
          foregroundDecoration: BoxDecoration(
            borderRadius: AppRadius.cardR,
            border: Border.all(color: selected ? AppColors.primary : AppColors.line, width: selected ? 2 : 1),
          ),
          child: Builder(
            builder: (context) => ConstrainedBox(
              constraints: const BoxConstraints(minHeight: AppSizes.photoCardMinH),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Photo = exactement la moitié de la carte, sur toute sa hauteur.
                    Expanded(
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.asset('assets/images/$image', fit: BoxFit.cover, excludeFromSemantics: true),
                          ),
                          // Indicateur posé sur la photo : le titre garde toute la largeur.
                          Positioned(
                            top: AppSpace.x2_5,
                            left: AppSpace.x2_5,
                            child: DecoratedBox(
                              decoration: const BoxDecoration(shape: BoxShape.circle, boxShadow: AppShadows.card),
                              child: SelectionIndicator(
                                selected: selected,
                                size: AppSizes.checkCircleLg,
                                roundWhenOff: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpace.x3_5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: AppText.of(AppFont.s18, weight: AppFont.extrabold, lineHeight: 28)),
                            const SizedBox(height: AppSpace.x1),
                            Text(description, style: AppText.of(AppFont.s12_5, color: AppColors.ink2, lineHeight: 17)),
                            const SizedBox(height: AppSpace.x2_5),
                            for (final (i, b) in bullets.indexed) ...[
                              if (i > 0) const SizedBox(height: AppSpace.x1_5),
                              Row(
                                children: [
                                  const CheckBullet(),
                                  const SizedBox(width: AppSpace.x2),
                                  Expanded(
                                    child: Text(
                                      b,
                                      style: AppText.of(AppFont.s13, color: AppColors.ink2, lineHeight: 19),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
