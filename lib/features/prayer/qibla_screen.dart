import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/tokens.dart';
import '../../core/utils/format.dart';
import '../../core/utils/time.dart';
import '../../core/widgets/ui.dart';

const _size = 290.0;
const _alignedDeg = 5.0;

/// Signed shortest angle from b to a, in (-180, 180].
double _delta(double a, double b) => ((a - b) % 360 + 540) % 360 - 180;

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  StreamSubscription<CompassEvent>? _sub;
  bool _starting = true;
  double? _heading; // null = no compass on this device
  double _unwrapped = 0; // dial rotation in degrees, unwrapped so 359° → 1° never spins a full turn
  bool _wasAligned = false;

  @override
  void initState() {
    super.initState();
    final events = kIsWeb ? null : FlutterCompass.events;
    if (events == null) {
      _starting = false;
      return;
    }
    _sub = events.listen(
      (e) {
        final h = e.heading;
        setState(() {
          _starting = false;
          _heading = h;
          if (h != null) _unwrapped += _delta(-h, _unwrapped);
        });
        final aligned =
            h != null && _delta(qiblaBearing, h).abs() <= _alignedDeg;
        if (aligned && !_wasAligned) HapticFeedback.mediumImpact();
        _wasAligned = aligned;
      },
      onError: (_) => setState(() {
        _starting = false;
        _heading = null;
      }),
    );
    // Devices without a magnetometer never emit; fall back after a moment.
    Timer(const Duration(seconds: 2), () {
      if (mounted && _starting) setState(() => _starting = false);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final h = _heading;
    final offset = h == null ? null : _delta(qiblaBearing, h);
    final aligned = offset != null && offset.abs() <= _alignedDeg;
    final ok = aligned ? AppColors.success : AppColors.muted;
    final duration = reduceMotion(context) ? Duration.zero : Motion.short;

    return AppScreen(
      back: true,
      title: t.qibla,
      subtitle: h != null ? t.qiblaHint : (_starting ? ' ' : t.qiblaNoSensor),
      children: [
        Center(
          child: Column(
            children: [
              Icon(Icons.arrow_drop_up_rounded, size: 40, color: ok),
              AnimatedContainer(
                duration: duration,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface,
                  border: Border.all(
                    color: aligned ? AppColors.success : AppColors.line,
                    width: 3,
                  ),
                ),
                child: AnimatedRotation(
                  turns: _unwrapped / 360,
                  duration: const Duration(milliseconds: 160),
                  curve: Curves.easeOutQuad,
                  child: Semantics(
                    label:
                        '${t.qiblaBearing} ${qiblaBearing.toStringAsFixed(0)}°',
                    child: const CustomPaint(
                      size: Size.square(_size),
                      painter: _DialPainter(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        AnimatedContainer(
          duration: duration,
          padding: const EdgeInsets.all(Space.lg),
          decoration: BoxDecoration(
            color: aligned ? AppColors.amberSoft : AppColors.surface,
            borderRadius: BorderRadius.circular(Radii.lg),
            border: Border.all(
              color: aligned ? AppColors.amberLine : AppColors.line,
            ),
          ),
          child: Row(
            children: [
              AnimatedSwitcher(
                duration: duration,
                child: Icon(
                  aligned
                      ? Icons.check_circle_rounded
                      : Icons.navigation_rounded,
                  key: ValueKey(aligned),
                  color: aligned ? AppColors.success : AppColors.amberDeep,
                ),
              ),
              const SizedBox(width: Space.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      aligned ? t.qiblaAligned : t.qiblaBearing,
                      style: AppText.bodyStrong,
                    ),
                    Text(
                      '${qiblaBearing.toStringAsFixed(1)}°${offset != null && !aligned ? ' · ${offset > 0 ? '→' : '←'} ${offset.abs().round()}°' : ''}',
                      style: AppText.label
                          .copyWith(color: AppColors.muted)
                          .tabular,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Compass card; north at top, the Kaaba marker at the Qibla bearing.
class _DialPainter extends CustomPainter {
  const _DialPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final c = Offset(r, r);
    canvas.drawCircle(c, r - 2, Paint()..color = AppColors.surface);
    canvas.drawCircle(c, r - 40, Paint()..color = AppColors.bg);
    canvas.drawCircle(
      c,
      r - 40,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = AppColors.line,
    );

    for (var deg = 0; deg < 360; deg += 5) {
      final major = deg % 30 == 0;
      canvas.save();
      canvas.translate(r, r);
      canvas.rotate(deg * math.pi / 180);
      canvas.drawLine(
        Offset(0, -r + 10),
        Offset(0, -r + (major ? 24 : 17)),
        Paint()
          ..color = major ? AppColors.ink : AppColors.muted
          ..strokeWidth = major ? 2 : 1,
      );
      canvas.restore();
    }

    for (final (i, l) in ['N', 'E', 'S', 'W'].indexed) {
      canvas.save();
      canvas.translate(r, r);
      canvas.rotate(i * math.pi / 2);
      final tp = TextPainter(
        text: TextSpan(
          text: l,
          style: AppText.bodyStrong.copyWith(
            color: l == 'N' ? AppColors.danger : AppColors.ink,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(-tp.width / 2, -r + 30));
      canvas.restore();
    }

    final rad = (qiblaBearing - 90) * math.pi / 180;
    final q = c + Offset(math.cos(rad), math.sin(rad)) * (r - 46);
    canvas.drawLine(
      c,
      q,
      Paint()
        ..color = AppColors.amber
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(c, 6, Paint()..color = AppColors.ink);
    final kaaba = RRect.fromRectAndRadius(
      Rect.fromCenter(center: q, width: 24, height: 24),
      const Radius.circular(4),
    );
    canvas.drawRRect(kaaba, Paint()..color = AppColors.ink);
    canvas.drawLine(
      q + const Offset(-12, -4),
      q + const Offset(12, -4),
      Paint()
        ..color = AppColors.amber
        ..strokeWidth = 2.5,
    );
  }

  @override
  bool shouldRepaint(_DialPainter old) => false;
}
