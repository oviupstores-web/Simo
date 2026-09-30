import 'package:flutter/material.dart';

/// Couleurs Menoo — source : design/DESIGN_V2.md et design/masters/*.html.
/// Aucune couleur ne doit être codée en dur ailleurs dans l'app.
abstract final class AppColors {
  // Jetons DESIGN_V2
  static const primary = Color(0xFF0B6B43);
  static const primaryDark = Color(0xFF06502F);
  static const mint = Color(0xFFEAF6EB);
  static const mint2 = Color(0xFFDCEFE0);
  static const leaf = Color(0xFF3F8F5F);
  static const orange = Color(0xFFF58A1F);
  static const orangeSoft = Color(0xFFFFEBD6);
  static const warn = Color(0xFFE67A12);
  static const bg = Color(0xFFFAFBF8);
  static const card = Color(0xFFFFFFFF);
  static const line = Color(0xFFE7ECE8);
  static const ink = Color(0xFF17231C);
  static const ink2 = Color(0xFF5B6660);
  static const ink3 = Color(0xFF8D9690);
  static const white = Color(0xFFFFFFFF);
  static const transparent = Color(0x00000000);

  // Compléments relevés dans les écrans maîtres
  /// Texte des alertes sur fond orange-soft.
  static const alertInk = Color(0xFF8A4A10);

  /// Encart neutre (« Algorithme adaptatif »).
  static const neutralSoft = Color(0xFFF3F6F2);

  /// Lipides (pastille jaune).
  static const fat = Color(0xFFF2C94C);

  /// Emplacement Placard.
  static const pantrySoft = Color(0xFFFFF3E3);
  static const pantryInk = Color(0xFFB86A12);

  /// Emplacement Congélateur.
  static const freezerSoft = Color(0xFFE8F2FB);
  static const freezerInk = Color(0xFF2F6FA3);

  /// Pastilles pastel (familles d'icônes) — retours jalon 4 : doux, jamais criard.
  static const leafySoft = Color(0xFFEEF5E3);
  static const leafyInk = Color(0xFF5A8A2F);
  static const lavenderSoft = Color(0xFFF0ECF8);
  static const lavenderInk = Color(0xFF6E5CA8);

  /// Grains de poivre du décor basilic (réf. 02 et 05).
  static const pepperBlack = Color(0xFF2B2420);
  static const pepperRed = Color(0xFFB4412F);
  static const pepperHighlight = Color(0x33FFFFFF);

  /// Carte sélectionnée du choix du mode (mint à 40 % sur blanc).
  static const mintTint = Color(0xFFF7FBF7);

  /// Fond de la barre de navigation (blanc 95 %).
  static const navBg = Color(0xF2FFFFFF);

  /// Carte « Débloquez » posée sur le flou (blanc 95 %).
  static const overlayCard = Color(0xF2FFFFFF);

  /// Barre d action en bas de la fiche recette (fond 95 %).
  static const bottomBarBg = Color(0xF2FAFBF8);

  // Ombres
  static const shadowCard = Color(0x0D10281C); // rgba(16,40,28,.05)
  static const shadowBtn = Color(0x380B6B43); // rgba(11,107,67,.22)
}
