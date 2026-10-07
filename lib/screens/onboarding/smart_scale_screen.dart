import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../onboarding/onboarding_scope.dart';
import '../../onboarding/onboarding_flow.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

/// onboarding_smartscale (Solo, étape 4/12, optionnelle) — balance via Health Connect.
/// Les appareils « détectés » de l'écran Stitch étaient fictifs : pas de faux appareils ici.
/// La demande d'autorisation Health Connect se fait après la création du compte (jalon 11).
class SmartScaleScreen extends StatelessWidget {
  const SmartScaleScreen({super.key});

  static List<String> _benefits(L l) => [l.scaleBenefit1, l.scaleBenefit2, l.scaleBenefit3];

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final d = OnboardingScope.of(context);
    void choose(bool scale) {
      d.update(() => d.wantsScale = scale);
      OnboardingFlow.next(context, OnbStep.scale);
    }

    return OnboardingStepScaffold(
      horizontalPadding: SmartScaleTokens.gutter,
      subtitleColor: SmartScaleTokens.bodyInk,
      step: OnboardingFlow.number(context, OnbStep.scale),
      totalSteps: OnboardingFlow.total(context),
      eyebrow: l.scaleEyebrow,
      eyebrowIcon: AppIcons.heartPulse,
      title: l.scaleTitle,
      subtitle: l.scaleSubtitle,
      continueLabel: l.scaleConnect,
      showArrow: false,
      onContinue: () => choose(true),
      below: Center(
        child: TextLink(l.scaleSkip, weight: AppFont.bold, onTap: () => choose(false)),
      ),
      children: [
        AppCard(
          padding: const EdgeInsets.all(AppSpace.x5),
          child: Column(
            children: [
              Image.asset('assets/images/balance_connectee.jpg', height: AppSizes.scaleHero, excludeFromSemantics: true),
              const SizedBox(height: AppSpace.x4),
              for (final (i, b) in _benefits(l).indexed) ...[
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
        InfoBanner(
          icon: AppIcons.info,
          text: l.scaleInfoText,
          textColor: SmartScaleTokens.bodyInk,
          background: AppColors.neutralSoft,
        ),
      ],
    );
  }
}
