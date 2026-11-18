import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/tokens.dart';
import '../../core/utils/format.dart';
import '../../core/utils/time.dart';
import '../../core/widgets/ui.dart';
import '../../data/app_state.dart';
import '../../data/content.dart';

class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final lang = context.lang;
    final rsvps = ref.watch(appProvider.select((s) => s.rsvps));
    final today = muToday();
    final sorted = [...events]..sort((a, b) => a.inDays.compareTo(b.inDays));
    final meta = AppText.caption.copyWith(color: AppColors.muted);

    return AppScreen(
      back: true,
      title: t.events,
      children: [
        for (final (i, e) in sorted.indexed)
          EnterFade(
            index: i,
            child: () {
              final day = addDays(today, e.inDays);
              final going = rsvps.contains(e.id);
              return AppCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.amberSoft,
                        borderRadius: BorderRadius.circular(Radii.md),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            capitalize(monthName(lang, day.m, short: true)),
                            style: AppText.overline.copyWith(
                              color: AppColors.amberDeep,
                            ),
                          ),
                          Text('${day.d}', style: AppText.title.tabular),
                        ],
                      ),
                    ),
                    const SizedBox(width: Space.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (e.membersOnly) ...[
                            StatusBadge(t.membersOnly, tone: BadgeTone.amber),
                            const SizedBox(height: 6),
                          ],
                          Text(context.tr(e.title), style: AppText.bodyStrong),
                          const SizedBox(height: Space.xs),
                          Wrap(
                            spacing: Space.md,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.schedule_rounded,
                                    size: 14,
                                    color: AppColors.muted,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(e.time, style: meta.tabular),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.place_rounded,
                                    size: 14,
                                    color: AppColors.muted,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(e.place, style: meta),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: Space.md),
                          AppButton(
                            label: going ? t.going : t.rsvp,
                            icon: going
                                ? Icons.check_rounded
                                : Icons.add_rounded,
                            kind: going
                                ? ButtonKind.primary
                                : ButtonKind.secondary,
                            compact: true,
                            onPressed: () =>
                                ref.read(appProvider.notifier).toggleRsvp(e.id),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }(),
          ),
      ],
    );
  }
}
