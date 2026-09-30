import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import 'pantry_add_manual_screen.dart';

/// pantry_scanbarcode — le scanner (caméra + Open Food Facts via Edge Function) arrive au jalon 10.
/// En attendant : écran honnête, sans faux produit détecté, avec repli sur l'ajout manuel.
class PantryScanScreen extends StatelessWidget {
  const PantryScanScreen({super.key});

  @override
  Widget build(BuildContext context) => const _ComingSoon(
    icon: AppIcons.barcode,
    title: 'Scanner un code-barres',
    text:
        'Visez le code-barres d\'un produit : Menoo le reconnaît grâce à Open Food Facts et propose son emplacement. '
        'Cette fonction arrive avec l\'onglet Réserve.',
  );
}

/// pantry_photoai_1 — la reconnaissance par photo (IA via Edge Function) arrive au jalon 10.
class PantryPhotoAiScreen extends StatelessWidget {
  const PantryPhotoAiScreen({super.key});

  @override
  Widget build(BuildContext context) => const _ComingSoon(
    icon: AppIcons.camera,
    title: 'Photo de votre frigo',
    text:
        'Photographiez votre frigo ou votre ticket de caisse : l\'IA détecte les aliments et vous les vérifiez avant l\'ajout. '
        'Cette fonction arrive avec l\'onglet Réserve.',
  );
}

class _ComingSoon extends StatelessWidget {
  const _ComingSoon({required this.icon, required this.title, required this.text});

  final String icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return OnboardingStepScaffold(
      eyebrow: 'BIENTÔT DISPONIBLE',
      eyebrowIcon: AppIcons.sparkles,
      title: title,
      subtitle: text,
      continueLabel: 'Ajouter manuellement',
      showArrow: false,
      onContinue: () =>
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const PantryAddManualScreen())),
      below: Center(
        child: TextLink('Revenir à ma réserve', weight: AppFont.bold, onTap: () => Navigator.of(context).pop()),
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
