import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/ui.dart';
import '../../../data/app_state.dart';
import '../../../data/models.dart';

const _tone = {
  MonthStatus.paid: (
    AppColors.successSoft,
    AppColors.success,
    AppColors.successLine,
  ),
  MonthStatus.overdue: (
    AppColors.dangerSoft,
    AppColors.danger,
    AppColors.dangerLine,
  ),
  MonthStatus.due: (AppColors.amberSoft, AppColors.amberDeep, AppColors.amber),
  MonthStatus.upcoming: (AppColors.surface, AppColors.muted, AppColors.line),
};

/// Twelve-month window: nine months back, the current month, two ahead (FR-021).
class SubscriptionGrid extends ConsumerWidget {
  const SubscriptionGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appProvider);
    final t = context.t;
    final lang = context.lang;
    final idx = s.months.indexWhere((m) => m.key == s.currentMonthKey);
    final window = s.months.sublist(
      (idx - 9).clamp(0, s.months.length),
      (idx + 3).clamp(0, s.months.length),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.count(
          crossAxisCount: 6,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: Space.sm,
          crossAxisSpacing: Space.sm,
          childAspectRatio: 0.95,
          children: [
            for (final m in window)
              () {
                final status = s.statusOf(m);
                final (bg, fg, border) = _tone[status]!;
                return Semantics(
                  label:
                      '${monthName(lang, m.m)} ${m.y}: ${statusLabel(t, status)}',
                  child: ExcludeSemantics(
                    child: Container(
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(Radii.sm),
                        border: Border.all(color: border),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              capitalize(monthName(lang, m.m, short: true)),
                              style: AppText.caption.copyWith(
                                color: fg,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${m.y % 100}',
                              style: AppText.caption
                                  .copyWith(color: fg.withValues(alpha: 0.8))
                                  .tabular,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }(),
          ],
        ),
        const SizedBox(height: Space.md),
        Wrap(
          spacing: Space.lg,
          runSpacing: Space.xs,
          children: [
            for (final st in MonthStatus.values)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _tone[st]!.$1,
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(color: _tone[st]!.$3),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    statusLabel(t, st),
                    style: AppText.caption.copyWith(color: AppColors.muted),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

/// Badge tone for a month status.
BadgeTone monthTone(MonthStatus s) => switch (s) {
  MonthStatus.paid => BadgeTone.success,
  MonthStatus.overdue => BadgeTone.danger,
  MonthStatus.due => BadgeTone.amber,
  MonthStatus.upcoming => BadgeTone.muted,
};
