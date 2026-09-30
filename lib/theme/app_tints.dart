import 'package:flutter/widgets.dart';

import 'app_colors.dart';

/// Familles de pastilles pastel : fond doux + icône de la même teinte, plus soutenue.
/// Le vert reste dominant (menthe) ; les autres teintes servent à distinguer les familles.
enum Tint {
  mint(AppColors.mint, AppColors.primary),
  peach(AppColors.orangeSoft, AppColors.warn),
  leafy(AppColors.leafySoft, AppColors.leafyInk),
  sky(AppColors.freezerSoft, AppColors.freezerInk),
  lavender(AppColors.lavenderSoft, AppColors.lavenderInk),
  sand(AppColors.pantrySoft, AppColors.pantryInk);

  const Tint(this.soft, this.ink);

  final Color soft;
  final Color ink;
}
