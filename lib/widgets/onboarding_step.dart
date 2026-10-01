import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/theme.dart';
import 'buttons.dart';
import 'menoo_header.dart';
import 'pills.dart';
import 'thumbs.dart';

/// Gabarit commun des étapes d'onboarding (maîtres « objectif » et « formulaire ») :
/// en-tête + progression, étiquette, titre, sous-titre, contenu, bouton Continuer.
class OnboardingStepScaffold extends StatelessWidget {
  const OnboardingStepScaffold({
    super.key,
    required this.title,
    required this.children,
    this.step,
    this.totalSteps,
    this.subtitle,
    this.eyebrow,
    this.eyebrowIcon,
    this.onContinue,
    this.continueLabel,
    this.showArrow = true,
    this.below,
    this.decor = const [],
    this.textRightInset = 0,
  });

  /// Marge à droite du titre et du sous-titre (place laissée à un décor).
  final double textRightInset;

  final int? step;
  final int? totalSteps;
  final String title;
  final String? subtitle;
  final String? eyebrow;
  final String? eyebrowIcon;
  final List<Widget> children;
  final VoidCallback? onContinue;
  final String? continueLabel;
  final bool showArrow;

  /// Contenu sous le bouton (lien « Passer », mention discrète…).
  final Widget? below;

  /// Décors positionnés (basilic…), placés derrière le contenu.
  final List<Widget> decor;

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
              MenooHeader(step: step, totalSteps: totalSteps),
              Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  ...decor,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpace.gutter),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: AppSpace.x5),
                        if (eyebrow != null) ...[
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: EyebrowTag(label: eyebrow!, icon: eyebrowIcon ?? AppIcons.target),
                          ),
                          const SizedBox(height: AppSpace.x3),
                        ],
                        Padding(
                          padding: EdgeInsetsDirectional.only(end: textRightInset),
                          child: Text(AppText.noBreakHyphens(title), style: AppText.h1),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: AppSpace.x2),
                          Padding(
                            padding: EdgeInsetsDirectional.only(end: textRightInset),
                            child: Text(
                              subtitle!,
                              style: AppText.of(AppFont.s14_5, color: AppColors.ink2, lineHeight: 21),
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpace.x5),
                        ...children,
                        const SizedBox(height: AppSpace.x6),
                        PrimaryButton(label: continueLabel ?? l.commonContinue, showArrow: showArrow, onPressed: onContinue),
                        if (below != null) ...[const SizedBox(height: AppSpace.x3), below!],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Titre de section à l'intérieur d'une étape (« Régimes alimentaires », « Choix multiple »…).
class StepSectionTitle extends StatelessWidget {
  const StepSectionTitle(this.title, {super.key, this.hint, this.icon, this.tint = Tint.mint});

  final Tint tint;

  final String title;
  final String? hint;
  final String? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.x2_5),
      child: Row(
        children: [
          if (icon != null) ...[
            TintBadge(icon: icon!, tint: tint, size: AppSizes.iconTile),
            const SizedBox(width: AppSpace.x2_5),
          ],
          Expanded(
            child: Text(title, style: AppText.of(AppFont.s16, weight: AppFont.extrabold, lineHeight: 22)),
          ),
          if (hint != null)
            Text(
              hint!,
              style: AppText.of(AppFont.s12, weight: AppFont.semibold, color: AppColors.ink3),
            ),
        ],
      ),
    );
  }
}
