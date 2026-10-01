import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

/// Écran temporaire pour la ligne « Juste une idée pour ce soir ? » de `landing` et `path_choice`
/// (SPEC §1/§8). L'improvisation elle-même (scan, condiments, équipement, cuisine, recette) est
/// un jalon à part (6b) ; en attendant, ce lien reste honnête plutôt que mort.
class ImprovComingSoonScreen extends StatelessWidget {
  const ImprovComingSoonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return OnboardingStepScaffold(
      eyebrow: l.scanComingSoon,
      eyebrowIcon: AppIcons.sparkles,
      title: l.improvComingSoonTitle,
      subtitle: l.improvComingSoonText,
      continueLabel: l.commonBack,
      showArrow: false,
      onContinue: () => Navigator.of(context).pop(),
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
            child: const AppIcon(AppIcons.camera, size: 40, color: AppColors.mint2),
          ),
        ),
      ],
    );
  }
}
