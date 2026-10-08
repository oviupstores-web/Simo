import 'package:flutter/material.dart';

import '../theme/theme.dart';
import '../widgets/widgets.dart';
import 'app_languages.dart';
import 'app_localizations.dart';

/// Langue choisie, partagée par toute l'app. `null` = celle du téléphone.
///
/// Provisoire : tant que l'écran Réglages n'existe pas (jalon 12), on change de langue
/// par un appui long sur le logo Menoo, en haut de n'importe quel écran.
class LocaleScope extends InheritedNotifier<ValueNotifier<Locale?>> {
  const LocaleScope({super.key, required ValueNotifier<Locale?> controller, required super.child})
    : super(notifier: controller);

  static ValueNotifier<Locale?> of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<LocaleScope>()!.notifier!;

  /// Ouvre le choix de langue (appui long sur le logo).
  static void pick(BuildContext context) {
    final controller = of(context);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.card))),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpace.x4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpace.gutter, 0, AppSpace.gutter, AppSpace.x3),
                child: Text(L.of(context).languagePickerTitle, style: AppText.h2),
              ),
              for (final locale in AppLanguages.launchLocales)
                _LanguageRow(
                  locale: locale,
                  selected: controller.value?.languageCode == locale.languageCode,
                  onTap: () {
                    controller.value = locale;
                    Navigator.of(sheetContext).pop();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({required this.locale, required this.selected, required this.onTap});

  final Locale locale;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Le nom de chaque langue est écrit dans cette langue : on le lit sans comprendre les autres.
    final name = lookupL(locale).languageName;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.gutter, vertical: AppSpace.x3),
        child: Row(
          children: [
            Expanded(
              child: Text(
                name,
                textDirection: TextDirection.ltr,
                style: AppText.of(
                  AppFont.s15,
                  weight: selected ? AppFont.bold : AppFont.regular,
                  color: selected ? AppColors.primary : AppColors.ink,
                ),
              ),
            ),
            if (selected) const AppIcon(AppIcons.check, size: 20, color: AppColors.primary, strokeWidth: 3),
          ],
        ),
      ),
    );
  }
}
