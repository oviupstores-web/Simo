import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';

/// Icône au trait (contenu SVG de `AppIcons`), rendue à l'identique des écrans maîtres.
class AppIcon extends StatelessWidget {
  const AppIcon(this.svg, {super.key, this.size = 24, this.color = AppColors.ink, this.strokeWidth = 2});

  final String svg;
  final double size;
  final Color color;
  final double strokeWidth;

  static String hex(Color c) => '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

  @override
  Widget build(BuildContext context) {
    final opacity = c255(color) < 255 ? ' stroke-opacity="${(c255(color) / 255).toStringAsFixed(3)}"' : '';
    return SvgPicture.string(
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" '
      'stroke="${hex(color)}"$opacity stroke-width="$strokeWidth" '
      'stroke-linecap="round" stroke-linejoin="round">$svg</svg>',
      width: size,
      height: size,
    );
  }

  static int c255(Color c) => (c.toARGB32() >> 24) & 0xFF;
}

/// Logos pleins (Google, Apple) du maître de connexion.
abstract final class BrandLogos {
  static const google =
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48"><path fill="#FFC107" d="M43.6 20.5H42V20H24v8h11.3C33.7 32.7 29.2 36 24 36c-6.6 0-12-5.4-12-12s5.4-12 12-12c3.1 0 5.8 1.2 7.9 3.1l5.7-5.7C34 6.1 29.3 4 24 4 12.9 4 4 12.9 4 24s8.9 20 20 20 20-8.9 20-20c0-1.3-.1-2.4-.4-3.5z"/><path fill="#FF3D00" d="m6.3 14.7 6.6 4.8C14.7 15.1 19 12 24 12c3.1 0 5.8 1.2 7.9 3.1l5.7-5.7C34 6.1 29.3 4 24 4 16.3 4 9.7 8.3 6.3 14.7z"/><path fill="#4CAF50" d="M24 44c5.2 0 9.9-2 13.4-5.2l-6.2-5.2C29.2 35.1 26.7 36 24 36c-5.2 0-9.6-3.3-11.3-8l-6.5 5C9.5 39.6 16.2 44 24 44z"/><path fill="#1976D2" d="M43.6 20.5H42V20H24v8h11.3c-.8 2.2-2.2 4.2-4.1 5.6l6.2 5.2C37 39.2 44 34 44 24c0-1.3-.1-2.4-.4-3.5z"/></svg>';
  static const apple =
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path fill="#111111" d="M16.4 12.6c0-2.7 2.2-4 2.3-4.1-1.3-1.8-3.2-2.1-3.9-2.1-1.7-.2-3.2 1-4.1 1s-2.1-.9-3.5-.9c-1.8 0-3.5 1.1-4.4 2.7-1.9 3.3-.5 8.2 1.4 10.9.9 1.3 2 2.8 3.4 2.8s1.9-.9 3.5-.9 2.1.9 3.5.9 2.4-1.3 3.3-2.6c1-1.5 1.4-3 1.5-3.1-.1 0-2.9-1.1-3-4.6zM13.7 4.6c.7-.9 1.3-2.2 1.1-3.5-1.1.1-2.4.7-3.2 1.6-.7.8-1.3 2.1-1.1 3.4 1.2.1 2.4-.6 3.2-1.5z"/></svg>';
}
