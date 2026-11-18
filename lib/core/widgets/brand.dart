import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../theme/tokens.dart';

/// Placeholder mark built from the brief: a charcoal wave over an amber sun disc with
/// "CHI" lettering. Swap for CHI's supplied vector logo.
class Logo extends StatelessWidget {
  const Logo({super.key, this.size = 40, this.lettering = true});
  final double size;
  final bool lettering;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'CHI logo',
    image: true,
    child: CustomPaint(
      size: Size.square(size),
      painter: _LogoPainter(lettering),
    ),
  );
}

class _LogoPainter extends CustomPainter {
  _LogoPainter(this.lettering);
  final bool lettering;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 100);
    final disc = Path()
      ..addOval(Rect.fromCircle(center: const Offset(50, 50), radius: 48));
    canvas.drawPath(disc, Paint()..color = AppColors.amber);
    canvas.save();
    canvas.clipPath(disc);
    final wave = Path()
      ..moveTo(0, 70)
      ..cubicTo(20, 58, 34, 80, 52, 68)
      ..cubicTo(70, 56, 82, 56, 100, 66)
      ..lineTo(100, 100)
      ..lineTo(0, 100)
      ..close();
    canvas.drawPath(wave, Paint()..color = AppColors.ink);
    final crest = Path()
      ..moveTo(0, 80)
      ..cubicTo(18, 72, 34, 90, 54, 80)
      ..cubicTo(74, 70, 84, 70, 100, 78);
    canvas.drawPath(
      crest,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = AppColors.amberSoft.withValues(alpha: 0.7),
    );
    canvas.restore();
    if (lettering) {
      final tp = TextPainter(
        text: const TextSpan(
          text: 'CHI',
          style: TextStyle(
            fontFamily: Fonts.ui,
            fontSize: 26,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
            color: AppColors.ink,
            height: 1,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(50 - tp.width / 2, 54 - tp.height * 0.78));
    }
  }

  @override
  bool shouldRepaint(_LogoPainter old) => old.lettering != lettering;
}

/// Eight-pointed star (two rotated squares), a quiet geometric motif.
class Star extends StatelessWidget {
  const Star({
    super.key,
    this.size = 160,
    this.color = AppColors.amber,
    this.opacity = 0.18,
  });
  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: CustomPaint(
      size: Size.square(size),
      painter: _StarPainter(color.withValues(alpha: opacity)),
    ),
  );
}

class _StarPainter extends CustomPainter {
  _StarPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 100);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = color;
    canvas.drawRect(const Rect.fromLTWH(20, 20, 60, 60), p);
    canvas.drawPath(
      Path()
        ..moveTo(50, 7.6)
        ..lineTo(92.4, 50)
        ..lineTo(50, 92.4)
        ..lineTo(7.6, 50)
        ..close(),
      p,
    );
    canvas.drawCircle(const Offset(50, 50), 18, p);
    canvas.drawCircle(const Offset(50, 50), 44, p..strokeWidth = 0.8);
  }

  @override
  bool shouldRepaint(_StarPainter old) => old.color != color;
}

/// Repeating eight-point-star lattice, the tile work of mosque interiors. Stands in for
/// photography on banners and news art. Fills its parent.
class TilePattern extends StatelessWidget {
  const TilePattern({
    super.key,
    this.tile = 30,
    this.color = AppColors.amber,
    this.opacity = 0.5,
  });
  final double tile;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: CustomPaint(
      painter: _TilePainter(tile, color.withValues(alpha: opacity)),
      child: const SizedBox.expand(),
    ),
  );
}

class _TilePainter extends CustomPainter {
  _TilePainter(this.tile, this.color);
  final double tile;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = color;
    final half = tile * 0.27; // half-side of the square
    final d =
        half *
        math.sqrt2; // the diamond's tips sit on the square's circumcircle
    for (var x = 0.0; x < size.width; x += tile) {
      for (var y = 0.0; y < size.height; y += tile) {
        final c = Offset(x + tile / 2, y + tile / 2);
        canvas.drawRect(
          Rect.fromCenter(center: c, width: half * 2, height: half * 2),
          p,
        );
        canvas.drawPath(
          Path()
            ..moveTo(c.dx, c.dy - d)
            ..lineTo(c.dx + d, c.dy)
            ..lineTo(c.dx, c.dy + d)
            ..lineTo(c.dx - d, c.dy)
            ..close(),
          p,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_TilePainter old) =>
      old.tile != tile || old.color != color;
}
