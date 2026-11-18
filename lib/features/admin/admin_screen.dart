import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/tokens.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/ui.dart';
import '../../data/app_state.dart';
import '../../data/content.dart';
import '../../data/models.dart';

// Society-wide figures are illustrative; the demo member's own activity is live.
const _baseActive = 1284;
const _baseCollected = 46350;
const _baseArrears = 38400;

/// Mobile preview of the web admin dashboard (ADM-04, ADM-06).
class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final lang = context.lang;
    final s = ref.watch(appProvider);
    final pending = s.requests
        .where((r) => r.status == RequestStatus.pending)
        .toList();
    final reviewed = s.requests
        .where((r) => r.status != RequestStatus.pending)
        .toList();
    final thisMonth = s.payments
        .where(
          (p) =>
              p.kind == PaymentKind.subscription &&
              monthKey(ymdOf(p.date).y, ymdOf(p.date).m) == s.currentMonthKey,
        )
        .fold(0, (sum, p) => sum + p.amount);

    void review(AccessRequest r, RequestStatus status) {
      HapticFeedback.mediumImpact();
      ref.read(appProvider.notifier).reviewRequest(r.id, status);
    }

    final stats = [
      (t.activeMembers, mur(_baseActive).substring(4)),
      (t.collected, mur(_baseCollected + thisMonth)),
      (t.arrears, mur(_baseArrears + s.arrearsTotal)),
      (t.pendingRequests, '${pending.length}'),
    ];

    return AppScreen(
      back: true,
      title: t.adminPreview,
      subtitle: t.adminSub,
      children: [
        LayoutBuilder(
          builder: (context, c) {
            final w = (c.maxWidth - Space.sm) / 2;
            return Wrap(
              spacing: Space.sm,
              runSpacing: Space.sm,
              children: [
                for (final (i, (label, value)) in stats.indexed)
                  SizedBox(
                    width: w,
                    child: AppCard(
                      tone: i == 3 && pending.isNotEmpty
                          ? CardTone.amber
                          : CardTone.surface,
                      padding: const EdgeInsets.all(Space.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.caption.copyWith(
                              color: AppColors.muted,
                            ),
                          ),
                          const SizedBox(height: Space.xs),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(value, style: AppText.heading.tabular),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        Section(
          title: t.accessRequests,
          children: [
            if (pending.isEmpty)
              Text(
                t.nothingPending,
                style: AppText.body.copyWith(color: AppColors.muted),
              ),
            for (final r in pending)
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: gap([
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(r.name, style: AppText.bodyStrong),
                              // NIC masked outside the secretary's own view (SEC-02).
                              Text(
                                'NIC ${r.nic[0]}•••••••••${r.nic.substring(r.nic.length - 3)} · ${r.mobile}',
                                style: AppText.caption
                                    .copyWith(color: AppColors.muted)
                                    .tabular,
                              ),
                            ],
                          ),
                        ),
                        StatusBadge(
                          r.matched ? t.matched : t.noMatch,
                          tone: r.matched
                              ? BadgeTone.success
                              : BadgeTone.danger,
                        ),
                      ],
                    ),
                    if (!r.matched)
                      Text(
                        t.rejectReason,
                        style: AppText.caption.copyWith(
                          color: AppColors.inkSoft,
                        ),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            label: t.reject,
                            kind: ButtonKind.secondary,
                            compact: true,
                            onPressed: () => review(r, RequestStatus.rejected),
                          ),
                        ),
                        const SizedBox(width: Space.sm),
                        Expanded(
                          child: AppButton(
                            label: t.approve,
                            compact: true,
                            onPressed: () => review(r, RequestStatus.approved),
                          ),
                        ),
                      ],
                    ),
                  ], Space.md),
                ),
              ),
            for (final r in reviewed)
              AppCard(
                tone: CardTone.sunken,
                padding: const EdgeInsets.symmetric(
                  horizontal: Space.lg,
                  vertical: Space.md,
                ),
                child: Row(
                  children: [
                    Expanded(child: Text(r.name, style: AppText.label)),
                    StatusBadge(
                      r.status == RequestStatus.approved
                          ? t.approved
                          : t.rejected,
                      tone: r.status == RequestStatus.approved
                          ? BadgeTone.success
                          : BadgeTone.danger,
                    ),
                  ],
                ),
              ),
          ],
        ),
        Section(
          title: t.recentPayments,
          children: [
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (final (i, p) in s.payments.take(5).indexed)
                    Container(
                      padding: const EdgeInsets.all(Space.lg),
                      decoration: BoxDecoration(
                        border: i < 4
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(member.name, style: AppText.label),
                                Text(
                                  p.kind == PaymentKind.donation
                                      ? t.donate
                                      : monthsLabel(p.monthKeys, lang),
                                  style: AppText.caption.copyWith(
                                    color: AppColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(mur(p.amount), style: AppText.number),
                              const SizedBox(height: Space.xs),
                              StatusBadge(
                                p.method == PayMethod.juice
                                    ? 'Juice'
                                    : t.manual,
                                tone: p.method == PayMethod.juice
                                    ? BadgeTone.success
                                    : BadgeTone.amber,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
