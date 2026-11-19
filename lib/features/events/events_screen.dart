import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/tokens.dart';
import '../../core/utils/format.dart';
import '../../core/utils/time.dart';
import '../../core/widgets/photo.dart';
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
    final loggedIn = ref.watch(appProvider.select((s) => s.loggedIn));
    final today = muToday();
    final sorted = upcomingEvents(today);
    final meta = AppText.label.copyWith(color: AppColors.muted);

    return AppScreen(
      back: true,
      title: t.events,
      subtitle: t.eventsSub,
      children: [
        for (final (i, e) in sorted.indexed)
          EnterFade(
            index: i,
            child: () {
              final day = e.dayFrom(today);
              final going = rsvps.contains(e.id);
              return Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(Radii.lg),
                  border: Border.all(color: AppColors.line),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 150,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Photo(e.photo),
                          Positioned(
                            left: Space.md,
                            top: Space.md,
                            child: Container(
                              width: 52,
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(Radii.md),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    capitalize(
                                      monthName(lang, day.m, short: true),
                                    ),
                                    style: AppText.caption.copyWith(
                                      color: AppColors.amberDeep,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '${day.d}',
                                    style: AppText.heading.tabular,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (e.membersOnly)
                            Positioned(
                              right: Space.md,
                              top: Space.md,
                              child: StatusBadge(
                                t.membersOnly,
                                tone: BadgeTone.amber,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(Space.lg),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.tr(e.title),
                                  style: AppText.heading,
                                ),
                                const SizedBox(height: Space.xs),
                                Text(
                                  '${capitalize(weekdayName(lang, day))} · ${e.time} · ${e.place}',
                                  style: meta.tabular,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: Space.md),
                          AppButton(
                            label: going ? t.going : t.rsvp,
                            icon: going
                                ? Icons.check_rounded
                                : Icons.add_rounded,
                            kind: going
                                ? ButtonKind.primary
                                : ButtonKind.secondary,
                            compact: true,
                            // Members-only events: visitors are sent to log in first.
                            onPressed: e.membersOnly && !loggedIn
                                ? () => context.go('/member')
                                : () => ref
                                      .read(appProvider.notifier)
                                      .toggleRsvp(e.id),
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
