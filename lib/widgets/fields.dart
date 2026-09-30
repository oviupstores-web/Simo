import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_text.dart';
import '../theme/app_tokens.dart';
import 'app_icon.dart';
import 'pressable.dart';

/// Contour de champ : bordure `line`, `primary` au focus.
class _FieldFrame extends StatefulWidget {
  const _FieldFrame({required this.height, required this.builder});

  final double height;
  final Widget Function(FocusNode focus, bool focused) builder;

  @override
  State<_FieldFrame> createState() => _FieldFrameState();
}

class _FieldFrameState extends State<_FieldFrame> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppMotion.fast,
      height: widget.height,
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.x4),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.fieldR,
        border: Border.all(color: _focus.hasFocus ? AppColors.primary : AppColors.line),
      ),
      child: widget.builder(_focus, _focus.hasFocus),
    );
  }
}

InputDecoration _bare(String? hint, TextStyle hintStyle) =>
    InputDecoration(isCollapsed: true, border: InputBorder.none, hintText: hint, hintStyle: hintStyle);

/// Champ avec icône (connexion, inscription).
class IconTextField extends StatefulWidget {
  const IconTextField({
    super.key,
    required this.icon,
    required this.hint,
    this.obscure = false,
    this.trailingIcon,
    this.keyboardType,
    this.controller,
    this.inputFormatters,
    this.suffix,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
    this.onTrailingTap,
  });

  /// Action de l'icône de droite (sinon : afficher/masquer le mot de passe).
  final VoidCallback? onTrailingTap;

  final List<TextInputFormatter>? inputFormatters;

  /// Texte fixe à droite (unité).
  final String? suffix;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;
  final String icon;
  final String hint;
  final bool obscure;
  final String? trailingIcon;
  final TextInputType? keyboardType;
  final TextEditingController? controller;

  @override
  State<IconTextField> createState() => _IconTextFieldState();
}

class _IconTextFieldState extends State<IconTextField> {
  late bool _hidden = widget.obscure;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(AppFont.s15, lineHeight: 20);
    return _FieldFrame(
      height: AppSizes.fieldHeight,
      builder: (focus, _) => Row(
        children: [
          AppIcon(widget.icon, size: 20, color: AppColors.ink3),
          const SizedBox(width: AppSpace.x3),
          Expanded(
            child: TextField(
              focusNode: focus,
              controller: widget.controller,
              obscureText: _hidden,
              keyboardType: widget.keyboardType,
              inputFormatters: widget.inputFormatters,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              textInputAction: widget.textInputAction,
              style: text,
              decoration: _bare(widget.hint, text.copyWith(color: AppColors.ink3)),
            ),
          ),
          if (widget.suffix != null) ...[
            const SizedBox(width: AppSpace.x2),
            Text(widget.suffix!, style: AppText.of(AppFont.s14, color: AppColors.ink3)),
          ],
          if (widget.trailingIcon != null) ...[
            const SizedBox(width: AppSpace.x3),
            GestureDetector(
              onTap: widget.onTrailingTap ?? (widget.obscure ? () => setState(() => _hidden = !_hidden) : null),
              child: AppIcon(widget.trailingIcon!, size: 20, color: AppColors.ink3),
            ),
          ],
        ],
      ),
    );
  }
}

/// Ligne « libellé + champ avec unité » (formulaire : âge, taille, poids).
class UnitFieldRow extends StatelessWidget {
  const UnitFieldRow({super.key, required this.label, required this.unit, this.controller, this.initialValue});

  final String label;
  final String unit;
  final TextEditingController? controller;
  final String? initialValue;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppText.of(AppFont.s15, weight: AppFont.semibold, lineHeight: 22)),
          SizedBox(
            width: c.maxWidth * 0.58,
            child: _FieldFrame(
              height: AppSizes.inputHeight,
              builder: (focus, _) => Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      focusNode: focus,
                      controller: controller,
                      initialValue: controller == null ? initialValue : null,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: AppText.of(AppFont.s16, lineHeight: 22),
                      decoration: _bare(null, AppText.of(AppFont.s16)),
                    ),
                  ),
                  Text(unit, style: AppText.of(AppFont.s14, color: AppColors.ink3, lineHeight: 20)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bouton de choix binaire (Homme / Femme).
class SegmentButton extends StatelessWidget {
  const SegmentButton({super.key, required this.label, required this.icon, required this.selected, this.onTap});

  final String label;
  final String icon;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppColors.white : AppColors.ink;
    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.normal,
        curve: AppMotion.curve,
        height: AppSizes.inputHeight,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.card,
          borderRadius: AppRadius.fieldR,
          border: Border.all(color: selected ? AppColors.primary : AppColors.line),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIcon(icon, size: 19, color: fg),
            const SizedBox(width: AppSpace.x2),
            Text(
              label,
              style: AppText.of(
                AppFont.s16,
                weight: selected ? AppFont.bold : AppFont.semibold,
                color: fg,
                lineHeight: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Case à cocher carrée 20 px (liste de courses).
class SquareCheck extends StatelessWidget {
  const SquareCheck({super.key, required this.checked, this.onChanged});

  final bool checked;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: checked,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onChanged == null ? null : () => onChanged!(!checked),
        child: AnimatedContainer(
          duration: AppMotion.fast,
          width: AppSizes.checkbox,
          height: AppSizes.checkbox,
          decoration: BoxDecoration(
            color: checked ? AppColors.primary : AppColors.card,
            borderRadius: BorderRadius.circular(AppRadius.checkbox),
            border: Border.all(color: checked ? AppColors.primary : AppColors.ink3, width: 1.5),
          ),
          alignment: Alignment.center,
          child: checked ? const AppIcon(AppIcons.check, size: 13, color: AppColors.white, strokeWidth: 3) : null,
        ),
      ),
    );
  }
}

/// Message d'erreur de saisie, apparaît en douceur sous les champs.
class FormError extends StatelessWidget {
  const FormError({super.key, required this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: AppMotion.normal,
      curve: AppMotion.curve,
      child: message == null
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: const EdgeInsets.only(top: AppSpace.x3),
              child: Row(
                children: [
                  const AppIcon(AppIcons.info, size: 18, color: AppColors.warn),
                  const SizedBox(width: AppSpace.x2),
                  Expanded(
                    child: Text(
                      message!,
                      style: AppText.of(AppFont.s13, weight: AppFont.semibold, color: AppColors.warn),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
