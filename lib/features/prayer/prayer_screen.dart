import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/tokens.dart';
import '../../core/utils/format.dart';
import '../../core/utils/time.dart';
import '../../core/widgets/ui.dart';
import '../../data/app_state.dart';

class PrayerScreen extends ConsumerWidget {
  const PrayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final adhan = ref.watch(appProvider.select((s) => s.adhan));
    return NowBuilder(
      interval: const Duration(seconds: 30),
      builder: (context, now) {
        final today = muToday(now);
        final hijri = toHijri(today);
        final next = nextPrayer(now);
        final times = prayerTimesFor(today);
        return AppScreen(
          back: true,
          title: t.prayerTimes,
          subtitle:
              '${longDate(context.lang, today)} · ${hijri.d} ${hijriMonthName(hijri.m)} ${hijri.y}',
          children: [
            AppCard(
              padding: const EdgeInsets.all(Space.xs),
              child: Column(
                children: [
                  for (final (i, p) in times.indexed)
                    () {
                      final on = p.name == next.name && p.time == next.time;
                      final isPrayer = p.name != PrayerName.sunrise;
                      final fg = isPrayer ? AppColors.ink : AppColors.muted;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Space.md,
                          vertical: Space.sm,
                        ),
                        decoration: BoxDecoration(
                          color: on ? AppColors.amberSoft : null,
                          // Inner radius = card radius (12) − padding (4).
                          borderRadius: BorderRadius.circular(
                            Radii.lg - Space.xs,
                          ),
                          border: !on && i < times.length - 1
                              ? const Border(
                                  bottom: BorderSide(
                                    color: AppColors.line,
                                    width: 0.5,
                                  ),
                                )
                              : null,
                        ),
                        constraints: const BoxConstraints(minHeight: 60),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    prayerLabel(t, p.name),
                                    style:
                                        (on ? AppText.bodyStrong : AppText.body)
                                            .copyWith(color: fg),
                                  ),
                                  if (on)
                                    Text(
                                      t.nextPrayer,
                                      style: AppText.caption.copyWith(
                                        color: AppColors.amberDeep,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Text(
                              formatTime(p.time),
                              style: AppText.heading
                                  .copyWith(color: fg)
                                  .tabular,
                            ),
                            const SizedBox(width: Space.md),
                            SizedBox(
                              width: 60,
                              child: isPrayer
                                  ? Toggle(
                                      value: adhan[p.name] ?? false,
                                      onChanged: (_) => ref
                                          .read(appProvider.notifier)
                                          .toggleAdhan(p.name),
                                      label:
                                          '${t.adhanAlert} ${prayerLabel(t, p.name)}',
                                    )
                                  : const Icon(
                                      Icons.wb_twilight_rounded,
                                      size: 20,
                                      color: AppColors.muted,
                                    ),
                            ),
                          ],
                        ),
                      );
                    }(),
                ],
              ),
            ),
            Text(
              '${t.adhanAlert} · ${t.prayerMethod}',
              textAlign: TextAlign.center,
              style: AppText.caption.copyWith(color: AppColors.muted),
            ),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListRow(
                    icon: Icons.dark_mode_rounded,
                    title: t.ramadan,
                    onTap: () => context.push('/ramadan'),
                  ),
                  ListRow(
                    icon: Icons.explore_rounded,
                    title: t.qibla,
                    onTap: () => context.push('/qibla'),
                    divider: false,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
