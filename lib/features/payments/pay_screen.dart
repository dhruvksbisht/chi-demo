import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/tokens.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/ui.dart';
import '../../data/app_state.dart';
import '../../data/models.dart';
import '../member/widgets/subscription_grid.dart';
import 'checkout_screen.dart';

const _maxAhead = 8;

class PayScreen extends ConsumerStatefulWidget {
  const PayScreen({super.key});

  @override
  ConsumerState<PayScreen> createState() => _PayScreenState();
}

class _PayScreenState extends ConsumerState<PayScreen> {
  int? _count;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final lang = context.lang;
    final s = ref.watch(appProvider);
    final unpaid = s.months.where((m) => !m.isPaid).take(_maxAhead).toList();
    final arrearsCount = unpaid
        .where((m) => s.statusOf(m) == MonthStatus.overdue)
        .length;

    // Months are paid in order: selecting a month selects every earlier unpaid month,
    // and arrears can never be deselected (PAY-01, US-05).
    final count = (_count ?? arrearsCount + 1).clamp(0, unpaid.length);
    final selected = unpaid.take(count).toList();
    final total = selected.fold(0, (sum, m) => sum + m.amount);

    void toggle(int i) => setState(
      () => _count = (i + 1 == count ? i : i + 1).clamp(
        arrearsCount,
        unpaid.length,
      ),
    );

    return AppScreen(
      back: true,
      title: t.payMonths,
      subtitle: t.paySub,
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.total, style: AppText.overline),
                    Text(
                      '$count ${t.monthsSelected}',
                      style: AppText.caption.copyWith(color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              Text(mur(total), style: AppText.title.tabular),
            ],
          ),
          const SizedBox(height: Space.md),
          AppButton(
            label: t.payWithJuice,
            icon: Icons.lock_rounded,
            onPressed: count == 0
                ? null
                : () => context.push(
                    '/checkout',
                    extra: CheckoutRequest.subscription(
                      months: [for (final m in selected) m.key],
                      amount: total,
                    ),
                  ),
          ),
          const SizedBox(height: Space.sm),
          Text(
            t.redirectNote,
            textAlign: TextAlign.center,
            style: AppText.caption.copyWith(color: AppColors.muted),
          ),
        ],
      ),
      children: [
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (final (i, m) in unpaid.indexed)
                () {
                  final on = i < count;
                  final status = s.statusOf(m);
                  final locked = status == MonthStatus.overdue;
                  return Semantics(
                    checked: on,
                    child: Pressable(
                      onTap: locked ? null : () => toggle(i),
                      label: '${monthName(lang, m.m)} ${m.y}',
                      child: AnimatedContainer(
                        duration: reduceMotion(context)
                            ? Duration.zero
                            : Motion.press,
                        padding: const EdgeInsets.all(Space.lg),
                        decoration: BoxDecoration(
                          color: on
                              ? const Color(0xFFFFFBF3)
                              : AppColors.surface,
                          border: i < unpaid.length - 1
                              ? const Border(
                                  bottom: BorderSide(
                                    color: AppColors.line,
                                    width: 0.5,
                                  ),
                                )
                              : null,
                        ),
                        child: Row(
                          children: [
                            CheckBox(checked: on),
                            const SizedBox(width: Space.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${capitalize(monthName(lang, m.m))} ${m.y}',
                                    style: AppText.bodyStrong,
                                  ),
                                  if (status != MonthStatus.upcoming) ...[
                                    const SizedBox(height: Space.xs),
                                    StatusBadge(
                                      statusLabel(t, status),
                                      tone: monthTone(status),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Text(mur(m.amount), style: AppText.number),
                          ],
                        ),
                      ),
                    ),
                  );
                }(),
            ],
          ),
        ),
      ],
    );
  }
}
