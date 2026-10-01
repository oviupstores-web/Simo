import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../navigation.dart';
import '../../onboarding/onboarding_data.dart';
import '../../onboarding/onboarding_scope.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import '../onboarding/cover_household_screen.dart';
import '../onboarding/cover_solo_screen.dart';
import 'improv_coming_soon_screen.dart';

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
    final l = L.of(context);
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
                    Text(l.pathChoiceTitle, textAlign: TextAlign.center, style: AppText.h1),
                    const SizedBox(height: AppSpace.x2),
                    Text(
                      l.pathChoiceSubtitle,
                      textAlign: TextAlign.center,
                      style: AppText.lead,
                    ),
                    const SizedBox(height: AppSpace.x6),
                    _ModeCard(
                      image: 'mode_solo.jpg',
                      title: l.pathChoiceSoloTitle,
                      description: l.pathChoiceSoloDescription,
                      bullets: [l.pathChoiceSoloBullet1, l.pathChoiceSoloBullet2, l.pathChoiceSoloBullet3, l.pathChoiceSoloBullet4],
                      selected: _mode == AppMode.solo,
                      onTap: () => setState(() => _mode = AppMode.solo),
                    ),
                    const SizedBox(height: AppSpace.x3),
                    _ModeCard(
                      image: 'mode_famille.jpg',
                      title: l.pathChoiceHouseholdTitle,
                      description: l.pathChoiceHouseholdDescription,
                      bullets: [
                        l.pathChoiceHouseholdBullet1,
                        l.pathChoiceHouseholdBullet2,
                        l.pathChoiceHouseholdBullet3,
                        l.pathChoiceHouseholdBullet4,
                      ],
                      selected: _mode == AppMode.foyer,
                      onTap: () => setState(() => _mode = AppMode.foyer),
                    ),
                    const SizedBox(height: AppSpace.x4),
                    InfoBanner(
                      icon: AppIcons.bulb,
                      title: l.pathChoiceInfoTitle,
                      text: l.pathChoiceInfoText,
                    ),
                    const SizedBox(height: AppSpace.x6),
                    PrimaryButton(
                      label: l.commonContinue,
                      onPressed: () {
                        OnboardingScope.read(context).startMode(_mode);
                        push(
                          context,
                          _mode == AppMode.solo ? const CoverSoloScreen() : const CoverHouseholdScreen(),
                        );
                      },
                    ),
                    const SizedBox(height: AppSpace.x4),
                    Center(
                      child: TextLink(
                        l.landingImprovLine,
                        weight: AppFont.bold,
                        onTap: () => push(context, const ImprovComingSoonScreen()),
                      ),
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
                          PositionedDirectional(
                            top: AppSpace.x2_5,
                            start: AppSpace.x2_5,
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
