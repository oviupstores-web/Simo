import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import 'pantry_add_manual_screen.dart';

/// pantry_scanbarcode — le scanner (caméra + Open Food Facts via Edge Function) arrive au jalon 10.
/// En attendant : écran honnête, sans faux produit détecté, avec repli sur l'ajout manuel.
class PantryScanScreen extends StatelessWidget {
  const PantryScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return _ComingSoon(icon: AppIcons.barcode, title: l.scanBarcodeTitle, text: l.scanBarcodeText);
  }
}

/// pantry_photoai — Premium (SPEC §0.8/§4) : la reconnaissance par photo est réservée aux
/// abonnés (la fonction elle-même arrive au jalon 10) ; cet écran affiche un cadenas et renvoie
/// vers la saisie manuelle ou le code-barres, gratuits.
class PantryPhotoAiScreen extends StatelessWidget {
  const PantryPhotoAiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return OnboardingStepScaffold(
      eyebrow: l.pantryPhotoAiBadge,
      eyebrowIcon: AppIcons.lock,
      title: l.pantryPhotoAiLockedTitle,
      subtitle: l.pantryPhotoAiLockedText,
      continueLabel: l.scanAddManually,
      showArrow: false,
      onContinue: () =>
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const PantryAddManualScreen())),
      below: Center(
        child: TextLink(
          l.pantryPhotoAiUseBarcode,
          weight: AppFont.bold,
          onTap: () =>
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const PantryScanScreen())),
        ),
      ),
      children: [
        Container(
          height: AppSizes.scanPreviewH,
          decoration: const BoxDecoration(color: AppColors.ink, borderRadius: AppRadius.cardR),
          alignment: Alignment.center,
          child: Container(
            width: AppSizes.lockCircle,
            height: AppSizes.lockCircle,
            decoration: const BoxDecoration(color: AppColors.warn, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: const AppIcon(AppIcons.lock, size: 28, color: AppColors.white),
          ),
        ),
      ],
    );
  }
}

class _ComingSoon extends StatelessWidget {
  const _ComingSoon({required this.icon, required this.title, required this.text});

  final String icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return OnboardingStepScaffold(
      eyebrow: L.of(context).scanComingSoon,
      eyebrowIcon: AppIcons.sparkles,
      title: title,
      subtitle: text,
      continueLabel: L.of(context).scanAddManually,
      showArrow: false,
      onContinue: () =>
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const PantryAddManualScreen())),
      below: Center(
        child: TextLink(L.of(context).scanBackToPantry, weight: AppFont.bold, onTap: () => Navigator.of(context).pop()),
      ),
      children: [
        Container(
          height: AppSizes.scanPreviewH,
          decoration: const BoxDecoration(color: AppColors.ink, borderRadius: AppRadius.cardR),
          alignment: Alignment.center,
          child: Container(
            width: AppSizes.scanFrame,
            height: AppSizes.scanFrame * 0.62,
            decoration: BoxDecoration(
              borderRadius: AppRadius.fieldR,
              border: Border.all(color: AppColors.mint2, width: 2),
            ),
            alignment: Alignment.center,
            child: AppIcon(icon, size: 40, color: AppColors.mint2),
          ),
        ),
      ],
    );
  }
}
