import 'package:flutter/material.dart';

import '../../onboarding/onboarding_scope.dart';
import '../../onboarding/onboarding_flow.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

/// onboarding_smartscale (Solo, étape 4/12, optionnelle) — balance via Health Connect.
/// Les appareils « détectés » de l'écran Stitch étaient fictifs : pas de faux appareils ici.
/// La demande d'autorisation Health Connect se fait après la création du compte (jalon 11).
class SmartScaleScreen extends StatelessWidget {
  const SmartScaleScreen({super.key});

  static const _benefits = [
    'Pesées synchronisées automatiquement',
    'Courbe de poids dans l\'onglet Suivi',
    'Portions réajustées selon votre progression',
  ];

  @override
  Widget build(BuildContext context) {
    final d = OnboardingScope.of(context);
    void choose(bool scale) {
      d.update(() => d.wantsScale = scale);
      OnboardingFlow.next(context, OnbStep.scale);
    }

    return OnboardingStepScaffold(
      step: OnboardingFlow.number(context, OnbStep.scale),
      totalSteps: OnboardingFlow.total(context),
      eyebrow: 'OPTIONNEL',
      eyebrowIcon: AppIcons.heartPulse,
      title: 'Connectez votre balance',
      subtitle: 'Menoo récupère votre poids depuis Health Connect, l\'application santé d\'Android, compatible avec la plupart des balances connectées.',
      continueLabel: 'Associer via Health Connect',
      showArrow: false,
      onContinue: () => choose(true),
      below: Center(
        child: TextLink('Passer cette étape', weight: AppFont.bold, onTap: () => choose(false)),
      ),
      children: [
        AppCard(
          padding: const EdgeInsets.all(AppSpace.x5),
          child: Column(
            children: [
              Image.asset('assets/images/balance_connectee.jpg', height: AppSizes.scaleHero, excludeFromSemantics: true),
              const SizedBox(height: AppSpace.x4),
              for (final (i, b) in _benefits.indexed) ...[
                if (i > 0) const SizedBox(height: AppSpace.x2_5),
                Row(
                  children: [
                    const CheckBullet(),
                    const SizedBox(width: AppSpace.x2_5),
                    Expanded(child: Text(b, style: AppText.of(AppFont.s14, lineHeight: 20))),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpace.x4),
        const InfoBanner(
          icon: AppIcons.info,
          text: 'L\'autorisation vous sera demandée après la création de votre compte. Sans balance, vous pourrez saisir votre poids à la main.',
          background: AppColors.neutralSoft,
        ),
      ],
    );
  }
}
