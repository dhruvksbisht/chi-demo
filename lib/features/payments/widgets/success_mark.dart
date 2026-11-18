import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/widgets/ui.dart';

/// Confirms success with one short pulse (scale 0 → 1.06 → 1) and a haptic.
class SuccessMark extends StatefulWidget {
  const SuccessMark({super.key, this.icon = Icons.check_rounded});
  final IconData icon;

  @override
  State<SuccessMark> createState() => _SuccessMarkState();
}

class _SuccessMarkState extends State<SuccessMark>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 360),
  );
  late final _scale = TweenSequence([
    TweenSequenceItem(
      tween: Tween(
        begin: 0.6,
        end: 1.06,
      ).chain(CurveTween(curve: Motion.enter)),
      weight: 70,
    ),
    TweenSequenceItem(
      tween: Tween(begin: 1.06, end: 1.0).chain(CurveTween(curve: Motion.move)),
      weight: 30,
    ),
  ]).animate(_c);

  @override
  void initState() {
    super.initState();
    HapticFeedback.mediumImpact();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (reduceMotion(context)) {
      _c.value = 1;
    } else if (_c.status == AnimationStatus.dismissed) {
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: CurvedAnimation(parent: _c, curve: const Interval(0, 0.4)),
    child: ScaleTransition(
      scale: _scale,
      child: Container(
        width: 84,
        height: 84,
        decoration: BoxDecoration(
          color: AppColors.successSoft,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.successLine, width: 2),
        ),
        child: Icon(widget.icon, size: 40, color: AppColors.success),
      ),
    ),
  );
}
