import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/startup_logo_paths.dart';
import '../../theme/theme.dart';

/// One startup overlay. The existing landing builds underneath, without changing
/// its route or state. Future initialization can be supplied through [ready].
class MenooStartup extends StatefulWidget {
  const MenooStartup({super.key, required this.child, this.ready, this.prepare});

  final Widget child;
  final Future<void>? ready;
  final Future<void> Function(BuildContext)? prepare;

  @override
  State<MenooStartup> createState() => _MenooStartupState();
}

class _MenooStartupState extends State<MenooStartup> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: StartupTokens.sequence)
    ..addStatusListener(_status);
  ImageStream? _stream;
  ImageStreamListener? _listener;
  ui.Image? _logo;
  bool _started = false;
  bool _ready = false;
  bool _dismissed = false;
  bool _exiting = false;
  bool _reducedMotion = false;
  Timer? _exitTimer;
  Timer? _sloganTimer;
  bool _sloganSeen = false;
  bool _showChild = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reducedMotion = MediaQuery.disableAnimationsOf(context) || MediaQuery.accessibleNavigationOf(context);
    if (_started) {
      if (_reducedMotion) {
        _controller.stop();
        if (_ready) _exit();
      }
      return;
    }
    _started = true;
    if (!_reducedMotion) _controller.forward();
    // Decode the existing logo only once; no GIF, video, new asset or package.
    final decoded = Completer<void>();
    _stream = const AssetImage(StartupTokens.logoAsset).resolve(createLocalImageConfiguration(context));
    _listener = ImageStreamListener(
      (image, synchronous) {
        _logo?.dispose();
        _logo = image.image.clone();
        if (!decoded.isCompleted) decoded.complete();
        if (mounted && !synchronous) setState(() {});
      },
      onError: (Object error, StackTrace? stack) {
        // A missing decorative image must never prevent access to the app.
        FlutterError.reportError(FlutterErrorDetails(exception: error, stack: stack));
        if (!decoded.isCompleted) decoded.complete();
      },
    );
    _stream!.addListener(_listener!);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await decoded.future;
      try {
        if (!mounted) return;
        if (widget.prepare != null) await widget.prepare!(context);
        if (widget.ready != null) await widget.ready;
      } catch (error, stack) {
        FlutterError.reportError(FlutterErrorDetails(exception: error, stack: stack));
      }
      if (!mounted) return;
      // The first frame contains only the animation. Build the landing after
      // its images are cached, and keep the overlay until its frame is ready.
      setState(() => _showChild = true);
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;
      _ready = true;
      if (_reducedMotion || (_controller.isCompleted && _sloganSeen)) {
        _exit();
      } else if (_controller.isCompleted) {
        // The final caption is already appearing; its short hold owns the exit.
      } else {
        // Finish the whole storyboard quickly once ready, without imposing the
        // 11 seconds of the mockup, or repeating a loading loop.
        final remaining = Duration(
          milliseconds: math.min(
            StartupTokens.readySequence.inMilliseconds,
            (StartupTokens.sequence.inMilliseconds * (1 - _controller.value)).round(),
          ),
        );
        _controller.animateTo(1, duration: remaining, curve: Curves.linear);
      }
    });
  }

  void _status(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _sloganTimer ??= Timer(StartupTokens.sloganHold, () {
        _sloganSeen = true;
        if (_ready) _exit();
      });
    }
  }

  void _exit() {
    if (!mounted || _exiting) return;
    setState(() => _exiting = true);
    _exitTimer = Timer(_reducedMotion ? Duration.zero : StartupTokens.exit, () {
      if (mounted) setState(() => _dismissed = true);
    });
  }

  @override
  void dispose() {
    _exitTimer?.cancel();
    _sloganTimer?.cancel();
    if (_listener != null) _stream?.removeListener(_listener!);
    _controller.dispose();
    _logo?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      if (_showChild)
        ExcludeSemantics(
          excluding: !_dismissed,
          child: IgnorePointer(ignoring: !_dismissed, child: widget.child),
        ),
      if (!_dismissed)
        AnimatedOpacity(
          opacity: _exiting ? 0 : 1,
          duration: _reducedMotion ? Duration.zero : StartupTokens.exit,
          child: Semantics(
            label: L.of(context).appName,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => AnnotatedRegion<SystemUiOverlayStyle>(
                value:
                    (_reducedMotion || _controller.value > .72 ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light)
                        .copyWith(
                          statusBarColor: AppColors.transparent,
                          systemNavigationBarColor: AppColors.transparent,
                        ),
                child: MenooStartupVisual(progress: _reducedMotion ? 1 : _controller.value, logo: _logo),
              ),
            ),
          ),
        ),
    ],
  );
}

/// Public static storyboard view, also used for local Flutter render checks.
class MenooStartupVisual extends StatelessWidget {
  const MenooStartupVisual({super.key, required this.progress, this.logo});
  final double progress;
  final ui.Image? logo;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = math.min(
          constraints.maxWidth / StartupTokens.artboard.width,
          constraints.maxHeight / StartupTokens.artboard.height,
        );
        final originY = (constraints.maxHeight - StartupTokens.artboard.height * scale) / 2;
        final width = StartupTokens.sloganWidth * scale;
        return Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(
              painter: _StartupPainter(
                progress: progress.clamp(0, 1),
                logo: logo,
                name: l.appName,
                listTitle: l.landingCardShoppingLabel,
                items: [l.pantryDemoCarrots, l.pantryDemoYogurt, l.pantryDemoChicken],
                direction: Directionality.of(context),
              ),
              child: const SizedBox.expand(),
            ),
            Positioned(
              left: (constraints.maxWidth - width) / 2,
              top: originY + (StartupTokens.tile.bottom + StartupTokens.sloganGap) * scale,
              width: width,
              child: Opacity(
                opacity: _phase(progress.clamp(0, 1) * 9.3, 8.65, 9.2),
                child: Text(
                  l.startupSlogan,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppFont.family,
                    fontFamilyFallback: AppFont.fallback,
                    fontSize: StartupTokens.sloganSize * scale,
                    fontWeight: AppFont.medium,
                    decoration: TextDecoration.none,
                    height: 1.4,
                    color: StartupTokens.green,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

double _phase(double t, double a, double b) {
  final v = ((t - a) / (b - a)).clamp(0.0, 1.0);
  return v * v * (3 - 2 * v);
}

Path _outline(List<Offset> points) => Path()..addPolygon(points, true);

Path _morph(List<Offset> a, List<Offset> b, double t) =>
    _outline([for (var i = 0; i < a.length; i++) Offset.lerp(a[i], b[i], t)!]);

/// Corresponding corners prevent the M stems folding during the font morph.
Path _fontMorph(double t) {
  Offset at(double x, double y, double tx, double ty) => Offset.lerp(Offset(x, y), Offset(tx, ty), t)!;
  final p = Path();
  void line(double x, double y, double tx, double ty) {
    final v = at(x, y, tx, ty);
    p.lineTo(v.dx, v.dy);
  }

  void quad(double x, double y, double ex, double ey, double tx, double ty, double tex, double tey) {
    final a = at(x, y, tx, ty);
    final b = at(ex, ey, tex, tey);
    p.quadraticBezierTo(a.dx, a.dy, b.dx, b.dy);
  }

  final start = at(150.3, 383.7, 124, 384);
  p.moveTo(start.dx, start.dy);
  quad(150.3, 383.7, 173.3, 383.7, 124, 370, 136, 378);
  line(216.7, 443, 212, 434);
  quad(216.7, 443, 216.7, 443, 216, 438, 220, 434);
  line(259.3, 383.7, 296, 378);
  quad(282.3, 383.7, 282.3, 383.7, 308, 370, 308, 384);
  line(282.3, 515, 308, 510);
  quad(282.3, 515, 258.3, 515, 308, 521, 297, 521);
  line(258.3, 515, 251, 521);
  quad(258.3, 515, 258.3, 515, 239, 521, 239, 509);
  line(258.3, 426, 239, 455);
  line(218.3, 479.3, 223, 472);
  quad(216.7, 479.7, 214.7, 479.7, 216, 480, 209, 472);
  line(174.7, 424.3, 193, 455);
  line(174.3, 515, 193, 509);
  quad(174.3, 515, 150.3, 515, 193, 521, 181, 521);
  line(150.3, 515, 135, 521);
  quad(150.3, 515, 150.3, 515, 124, 521, 124, 510);
  return p..close();
}

class _StartupPainter extends CustomPainter {
  _StartupPainter({
    required this.progress,
    required this.logo,
    required this.name,
    required this.listTitle,
    required this.items,
    required this.direction,
  });

  final double progress;
  final ui.Image? logo;
  final String name;
  final String listTitle;
  final List<String> items;
  final TextDirection direction;
  static final _plain = _outline(StartupLogoPaths.plain.single);
  static final _clean = _outline(StartupLogoPaths.clean.single);
  static final _assembled = _outline(StartupLogoPaths.assembled.single);
  static final _marks = StartupLogoPaths.marks.map(_outline).toList();
  static final _fork = StartupLogoPaths.fork.map(_outline).toList();
  static final _holes = StartupLogoPaths.holes.map(_outline).toList();
  static final _leaves = StartupIngredientPaths.leaves;
  static final _carrot = StartupIngredientPaths.carrot;

  void _paths(Canvas c, List<Path> paths, Color color, [double opacity = 1]) {
    if (opacity <= 0) return;
    final paint = Paint()..color = color.withValues(alpha: opacity.clamp(0, 1));
    for (final path in paths) {
      c.drawPath(path, paint);
    }
  }

  void _text(
    Canvas c,
    String text,
    Offset position,
    double size, {
    double opacity = 1,
    double width = double.infinity,
    bool bold = false,
    TextDirection? textDirection,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: AppFont.family,
          fontFamilyFallback: AppFont.fallback,
          fontSize: size,
          height: 1.15,
          fontWeight: bold ? AppFont.bold : AppFont.regular,
          color: StartupTokens.cream.withValues(alpha: opacity.clamp(0, 1)),
        ),
      ),
      textDirection: textDirection ?? direction,
    )..layout(maxWidth: width);
    painter.paint(c, position);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress * 9.3;
    final shrink = _phase(t, 6.65, 7.9);
    canvas.drawColor(shrink > 0 ? StartupTokens.background : StartupTokens.green, BlendMode.src);
    final scale = math.min(size.width / StartupTokens.artboard.width, size.height / StartupTokens.artboard.height);
    final origin = Offset((size.width - 432 * scale) / 2, (size.height - 936 * scale) / 2);
    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.scale(scale);
    final full = Rect.fromLTWH(-origin.dx / scale, -origin.dy / scale, size.width / scale, size.height / scale);
    if (shrink > 0) {
      final rect = Rect.lerp(full, StartupTokens.tile, shrink)!;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(64 * shrink)),
        Paint()..color = StartupTokens.green,
      );
    }
    canvas.save();
    if (shrink > 0) {
      canvas.translate(StartupTokens.tileTranslation.dx * shrink, StartupTokens.tileTranslation.dy * shrink);
      canvas.scale(1 + (StartupTokens.tileScale.dx - 1) * shrink, 1 + (StartupTokens.tileScale.dy - 1) * shrink);
    }
    final grow = _phase(t, .8, 1.8);
    if (t < 1.8) {
      final word = TextPainter(
        text: TextSpan(
          text: name,
          style: const TextStyle(
            fontFamily: AppFont.family,
            fontSize: StartupTokens.titleSize,
            fontWeight: AppFont.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final letter = TextPainter(
        text: const TextSpan(
          text: 'M',
          style: TextStyle(fontFamily: AppFont.family, fontSize: StartupTokens.titleSize, fontWeight: AppFont.bold),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final left = (432 - word.width) / 2;
      final start = left + letter.width / 2;
      final x = start + (216 - start) * grow;
      final ratio = (StartupTokens.titleSize + 110 * grow) / StartupTokens.largeMSize;
      canvas.save();
      canvas.translate(x, 449.28);
      canvas.scale(ratio);
      canvas.translate(-216, -449.28);
      _paths(canvas, [_plain], StartupTokens.cream);
      canvas.restore();
      if (grow < 1) {
        _text(
          canvas,
          name.substring(1),
          Offset(left + letter.width, 409),
          StartupTokens.titleSize,
          opacity: 1 - grow,
          bold: true,
          textDirection: TextDirection.ltr,
        );
      }
    } else {
      final shape = t < 2.6
          ? _fontMorph(_phase(t, 1.8, 2.6))
          : t < 5.8
          ? _clean
          : t < 6.3
          ? _morph(StartupLogoPaths.clean.single, StartupLogoPaths.assembled.single, _phase(t, 5.8, 6.3))
          : _assembled;
      _paths(canvas, [shape], StartupTokens.cream);
      final details = _phase(t, 5.8, 6.3);
      _paths(canvas, _marks, StartupTokens.green, _phase(t, 3, 3.65) * (1 - details));
      _paths(canvas, _fork, StartupTokens.green, _phase(t, 4.15, 4.65) * (1 - details));
      _paths(canvas, _holes, StartupTokens.green, details);
    }
    _paths(canvas, _leaves, StartupTokens.leaf, _phase(t, 5.2, 5.85));
    _paths(canvas, _carrot, StartupTokens.carrot, _phase(t, 5.2, 5.85));
    canvas.restore();
    if (2.6 < t && t < 3.65) _list(canvas, t);
    if (3.65 < t && t < 4.65) {
      final arrive = _phase(t, 3.65, 4.3);
      final merge = _phase(t, 4.2, 4.65);
      final bounds = _fork.first.getBounds();
      canvas.save();
      canvas.translate(450 - 178 * arrive, 447);
      canvas.rotate(-14 * (1 - arrive) * math.pi / 180);
      canvas.translate(-bounds.center.dx, -bounds.center.dy);
      _paths(canvas, _fork, StartupTokens.cream, 1 - merge);
      canvas.restore();
    }
    if (4.6 < t && t < 5.85) _bunches(canvas, t);
    final threeD = _phase(t, 7.95, 8.9);
    if (threeD > 0 && logo != null) {
      canvas.drawImageRect(
        logo!,
        Rect.fromLTWH(0, 0, logo!.width.toDouble(), logo!.height.toDouble()),
        StartupTokens.tile,
        Paint()
          ..color = AppColors.white.withValues(alpha: threeD)
          ..filterQuality = FilterQuality.high,
      );
    }
    canvas.restore();
  }

  void _list(Canvas c, double t) {
    final arrive = _phase(t, 2.6, 3.35);
    final merge = _phase(t, 3.25, 3.65);
    c.save();
    c.translate(-105 + 242 * arrive, 383 + 47 * merge);
    c.scale(1 - merge * .55, 1 - merge * .60);
    c.saveLayer(const Rect.fromLTWH(0, 0, 98, 180), Paint()..color = AppColors.white.withValues(alpha: 1 - merge));
    c.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(0, 0, 98, 160), const Radius.circular(9)),
      Paint()..color = StartupTokens.cream,
    );
    // Localized native Flutter glyphs, never words baked into image frames.
    final title = TextPainter(
      text: TextSpan(
        text: listTitle,
        style: const TextStyle(
          fontFamily: AppFont.family,
          fontFamilyFallback: AppFont.fallback,
          fontSize: StartupTokens.listTitleSize,
          fontWeight: AppFont.bold,
          color: StartupTokens.green,
        ),
      ),
      textDirection: direction,
    )..layout(maxWidth: 76);
    title.paint(c, const Offset(11, 11));
    var y = math.max(47.0, title.height + 22);
    for (final item in items) {
      c.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(direction == TextDirection.rtl ? 77 : 11, y, 9, 9),
          const Radius.circular(2),
        ),
        Paint()
          ..color = StartupTokens.green
          ..style = PaintingStyle.stroke,
      );
      final line = TextPainter(
        text: TextSpan(
          text: item,
          style: const TextStyle(
            fontFamily: AppFont.family,
            fontFamilyFallback: AppFont.fallback,
            fontSize: StartupTokens.listTextSize,
            color: StartupTokens.green,
          ),
        ),
        textDirection: direction,
      )..layout(maxWidth: 59);
      line.paint(c, Offset(direction == TextDirection.rtl ? 11 : 27, y - 3));
      y += math.max(26.0, line.height + 9);
    }
    c.restore();
    c.restore();
  }

  void _bunches(Canvas c, double t) {
    final arrive = _phase(t, 4.6, 5.15);
    final merge = _phase(t, 5.2, 5.85);
    final opacity = arrive * (1 - merge);
    final scale = 1 - .55 * merge;
    // Flat bouquets arrive together, then merge into the approved single carrot
    // and two leaves. All ingredient silhouettes remain vector paths.
    for (var i = 0; i < 5; i++) {
      final leaf = _leaves[i % _leaves.length];
      final b = leaf.getBounds();
      c.save();
      c.translate(134 + (i % 3) * 25.0, 294 - 230 * (1 - arrive) + 45 * merge);
      c.rotate((i - 2) * .38);
      c.scale(.7 * scale);
      c.translate(-b.center.dx, -b.bottom);
      _paths(c, [leaf], StartupTokens.leaf, opacity);
      c.restore();
    }
    final carrot = _carrot.first;
    final b = carrot.getBounds();
    for (var i = 0; i < 3; i++) {
      c.save();
      c.translate(271 + i * 21.0, 301 - 230 * (1 - arrive) + 45 * merge);
      c.rotate(-.65 + (i - 1) * .16);
      c.scale(.78 * scale);
      c.translate(-b.center.dx, -b.center.dy);
      _paths(c, [carrot], StartupTokens.carrot, opacity);
      final leaf = _leaves.first;
      final lb = leaf.getBounds();
      c.save();
      c.translate(b.right, b.top);
      c.scale(.45);
      c.translate(-lb.center.dx, -lb.bottom);
      _paths(c, [leaf], StartupTokens.leaf, opacity);
      c.restore();
      c.restore();
    }
  }

  @override
  bool shouldRepaint(_StartupPainter old) =>
      progress != old.progress ||
      logo != old.logo ||
      name != old.name ||
      listTitle != old.listTitle ||
      direction != old.direction ||
      !listEquals(items, old.items);
}
