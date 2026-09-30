import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text.dart';
import 'app_tokens.dart';

abstract final class AppTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.orange,
      surface: AppColors.bg,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.bg,
      fontFamily: AppFont.family,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      textSelectionTheme: const TextSelectionThemeData(cursorColor: AppColors.primary),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {TargetPlatform.android: _FadeSlideTransitionsBuilder()},
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        contentTextStyle: AppText.of(AppFont.s14, weight: AppFont.semibold, color: AppColors.white),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.fieldR),
      ),
      datePickerTheme: const DatePickerThemeData(
        backgroundColor: AppColors.card,
        headerBackgroundColor: AppColors.primary,
        headerForegroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.cardR),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(AppRadius.checkbox))),
        side: const BorderSide(color: AppColors.ink3, width: 1.5),
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? AppColors.primary : AppColors.white,
        ),
      ),
    );
  }
}

/// Transition sobre entre écrans : léger glissement + fondu.
class _FadeSlideTransitionsBuilder extends PageTransitionsBuilder {
  const _FadeSlideTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(parent: animation, curve: AppMotion.curve);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween(begin: const Offset(0.06, 0), end: Offset.zero).animate(curved),
        child: child,
      ),
    );
  }
}
