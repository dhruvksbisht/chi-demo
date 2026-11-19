import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/tokens.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/ui.dart';
import '../../data/app_state.dart';
import '../../data/content.dart';
import '../../data/models.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final lang = context.lang;
    // Visitor donations are not the member's; they stay out of this list.
    final payments = ref
        .watch(appProvider.select((s) => s.payments))
        .where((p) => !p.anonymous)
        .toList();
    return AppScreen(
      back: true,
      title: t.paymentHistory,
      children: [
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (final (i, p) in payments.indexed)
                EnterFade(
                  index: i,
                  child: () {
                    final d = ymdOf(p.date);
                    final fund = fundById(p.fund);
                    final juice = p.method == PayMethod.juice;
                    final title = p.kind == PaymentKind.donation
                        ? '${t.donate} · ${fund == null ? '' : context.tr(fund.label)}'
                        : monthsLabel(p.monthKeys, lang);
                    return Pressable(
                      onTap: () => context.push('/receipt/${p.id}'),
                      label: title,
                      child: Container(
                        padding: const EdgeInsets.all(Space.lg),
                        decoration: BoxDecoration(
                          border: i < payments.length - 1
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
                            SizedBox(
                              width: 44,
                              child: Column(
                                children: [
                                  Text(
                                    '${d.d}',
                                    style: AppText.heading.tabular,
                                  ),
                                  Text(
                                    '${monthName(lang, d.m, short: true)} ${d.y % 100}',
                                    style: AppText.caption.copyWith(
                                      color: AppColors.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: Space.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppText.bodyStrong,
                                  ),
                                  const SizedBox(height: Space.xs),
                                  Wrap(
                                    spacing: Space.sm,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      StatusBadge(
                                        juice
                                            ? 'Juice'
                                            : t.manualMethod(p.method.name),
                                        tone: juice
                                            ? BadgeTone.success
                                            : BadgeTone.amber,
                                      ),
                                      Text(
                                        p.receiptNo,
                                        style: AppText.caption.copyWith(
                                          color: AppColors.muted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Text(mur(p.amount), style: AppText.number),
                            const Icon(
                              Icons.chevron_right_rounded,
                              size: 20,
                              color: AppColors.muted,
                            ),
                          ],
                        ),
                      ),
                    );
                  }(),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
