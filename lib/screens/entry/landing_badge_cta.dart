import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Overlay local à la Landing : aucune contrainte ajoutée à la pastille.
class LandingBadgeCta extends StatefulWidget {
  const LandingBadgeCta({
    super.key,
    required this.child,
    required this.label,
    required this.showHand,
    required this.onTap,
    required this.phase,
  });
  final Widget child;
  final String label;
  final bool showHand;
  final VoidCallback? onTap;
  final double phase;

  @override
  State<LandingBadgeCta> createState() => _LandingBadgeCtaState();
}

class _LandingBadgeCtaState extends State<LandingBadgeCta> with SingleTickerProviderStateMixin {
  bool _enabled = false;
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );
  double get _progress => _enabled ? (_controller.value + widget.phase) % 1 : 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final media = MediaQuery.of(context);
    final enabled =
        widget.showHand &&
        !media.disableAnimations &&
        !media.accessibleNavigation &&
        TickerMode.valuesOf(context).enabled;
    if (enabled == _enabled) return;
    _enabled = enabled;
    if (enabled) {
      _controller.repeat();
    } else {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _enabled = false;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final reduced = MediaQuery.of(context).disableAnimations || MediaQuery.of(context).accessibleNavigation;
    final badge = widget.child is Container ? widget.child as Container : null;
    final splitBadge = widget.showHand && badge != null;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (splitBadge)
          ExcludeSemantics(
            child: Container(
              key: badge.key,
              padding: badge.padding,
              decoration: badge.decoration,
              child: Opacity(opacity: 0, child: badge.child),
            ),
          )
        else
          widget.child,
        if (widget.showHand)
          PositionedDirectional(
            end: -48,
            top: -7,
            child: IgnorePointer(
              child: ExcludeSemantics(
                child: RepaintBoundary(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) => Transform.flip(
                      flipX: rtl,
                      child: CustomPaint(
                        size: const Size(64, 76),
                        painter: LandingContactWavesPainter(reduced ? 0 : _progress),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        if (splitBadge) Container(padding: badge.padding, child: badge.child),
        if (widget.onTap != null)
          Positioned(
            left: 0,
            right: -24,
            top: 0,
            height: 48,
            child: Semantics(
              button: true,
              label: widget.label,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.onTap,
                child: const SizedBox.expand(),
              ),
            ),
          ),
        if (widget.showHand)
          PositionedDirectional(
            end: -48,
            top: -7,
            child: IgnorePointer(
              child: ExcludeSemantics(
                child: RepaintBoundary(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      final progress = reduced ? 0.0 : _progress;
                      return Transform.flip(
                        flipX: rtl,
                        child: CustomPaint(size: const Size(64, 76), painter: LandingClickHandPainter(progress)),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Silhouette locale issue de la référence ; contour inclus dans les 40 px.
class LandingClickHandPainter extends CustomPainter {
  const LandingClickHandPainter(this.progress);
  final double progress;
  static const contact = Offset(16, 18);
  static final Matrix4 _rotation = Matrix4.identity()..rotateZ(-7 * math.pi / 180);
  static Path normalizedHand() => referenceHand().shift(const Offset(-575, -344)).transform(_rotation.storage);
  static final double scale = 40 / (normalizedHand().getBounds().height + 26);
  static double pressure(double p) => p < .3
      ? Curves.easeOut.transform(p / .3)
      : p < .5
      ? 1
      : 1 - Curves.easeInOut.transform((p - .5) / .5);
  static Matrix4 transformAt(double p) => Matrix4.identity()
    ..translateByDouble(contact.dx, contact.dy - 3 * (1 - pressure(p)), 0, 1)
    ..scaleByDouble(scale, scale, 1, 1);
  static Path handAt(double p) => normalizedHand().transform(transformAt(p).storage);
  static Path referenceHand() => Path()
    ..moveTo(720, 1050)
    ..lineTo(507, 443)
    ..cubicTo(478, 360, 555, 309, 616, 355)
    ..cubicTo(635, 368, 641, 392, 650, 421)
    ..lineTo(706, 576)
    ..cubicTo(711, 520, 775, 501, 809, 529)
    ..cubicTo(825, 543, 831, 567, 846, 599)
    ..cubicTo(846, 549, 902, 530, 941, 556)
    ..cubicTo(962, 568, 974, 596, 986, 626)
    ..cubicTo(995, 580, 1054, 550, 1085, 588)
    ..cubicTo(1100, 599, 1109, 620, 1127, 648)
    ..lineTo(1175, 783)
    ..cubicTo(1217, 912, 1232, 1062, 1184, 1132)
    ..lineTo(1245, 1309)
    ..lineTo(914, 1424)
    ..lineTo(860, 1283)
    ..cubicTo(759, 1256, 696, 1234, 649, 1184)
    ..cubicTo(593, 1110, 570, 1068, 478, 1002)
    ..cubicTo(404, 950, 456, 856, 523, 864)
    ..cubicTo(584, 870, 672, 986, 720, 1050)
    ..close();
  @override
  void paint(Canvas canvas, Size size) {
    final outline = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 26 * scale
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    final hand = handAt(progress);
    canvas.drawPath(hand, Paint()..color = Colors.white);
    canvas.drawPath(hand, outline);
    final fingers = Path()
      ..moveTo(706, 576)
      ..lineTo(798, 846)
      ..moveTo(846, 599)
      ..lineTo(914, 812)
      ..moveTo(986, 626)
      ..lineTo(1029, 775);
    final normalized = fingers.shift(const Offset(-575, -344)).transform(_rotation.storage);
    canvas.drawPath(normalized.transform(transformAt(progress).storage), outline);
  }

  @override
  bool shouldRepaint(LandingClickHandPainter old) => progress != old.progress;
}

/// Couche indépendante entre le fond de la pastille et la silhouette : trois ondes, jamais un ripple.
class LandingContactWavesPainter extends CustomPainter {
  const LandingContactWavesPainter(this.progress);
  final double progress;
  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < 3; i++) {
      final start = .3 + i * .06;
      if (progress <= start || progress >= 1) continue;
      final wave = (progress - start) / (1 - start);
      final paint = Paint()
        ..color = Colors.black.withValues(alpha: math.sqrt(1 - wave) * .85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = .75;
      canvas.drawCircle(LandingClickHandPainter.contact, [6.0, 10.0, 14.0][i] * (.5 + .5 * wave), paint);
    }
  }

  @override
  bool shouldRepaint(LandingContactWavesPainter old) => progress != old.progress;
}
