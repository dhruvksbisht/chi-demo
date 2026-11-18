import 'package:material_ui/material_ui.dart';

import '../../core/theme/tokens.dart';
import '../../core/utils/format.dart';
import '../../core/utils/time.dart';
import '../../core/widgets/brand.dart';
import '../../core/widgets/ui.dart';

const _days = 30;

class RamadanScreen extends StatelessWidget {
  const RamadanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final lang = context.lang;
    final today = muToday();
    final current = ramadanDay(today);
    final (:start, :hijriYear) = nextRamadanStart(today);
    final first = current != null ? addDays(today, 1 - current) : start;
    final countdown = daysBetween(today, start);
    final timetable = [
      for (var i = 0; i < _days; i++)
        () {
          final day = addDays(first, i);
          final times = prayerTimesFor(day);
          String at(PrayerName n) =>
              formatTime(times.firstWhere((p) => p.name == n).time);
          return (
            i: i + 1,
            day: day,
            suhoor: at(PrayerName.fajr),
            iftar: at(PrayerName.maghrib),
          );
        }(),
    ];
    final head = AppText.overline.copyWith(color: AppColors.muted);

    return AppScreen(
      back: true,
      title: '${t.ramadan} $hijriYear',
      subtitle: t.sightingNote,
      children: [
        AppCard(
          tone: CardTone.night,
          padding: EdgeInsets.zero,
          child: Stack(
            children: [
              const Positioned(
                right: -60,
                bottom: -70,
                child: Star(size: 200, opacity: 0.22),
              ),
              Padding(
                padding: const EdgeInsets.all(Space.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: current != null
                      ? [
                          Text(
                            t.dayOf,
                            style: AppText.overline.copyWith(
                              color: AppColors.onNightMuted,
                            ),
                          ),
                          Text(
                            '$current / $_days',
                            style: AppText.hero
                                .copyWith(color: AppColors.amber)
                                .tabular,
                          ),
                          Text(
                            '${t.iftar} ${timetable[current - 1].iftar}',
                            style: AppText.label.copyWith(
                              color: AppColors.onNightMuted,
                            ),
                          ),
                        ]
                      : [
                          Text(
                            t.ramadanBegins,
                            style: AppText.overline.copyWith(
                              color: AppColors.onNightMuted,
                            ),
                          ),
                          Wrap(
                            spacing: Space.sm,
                            crossAxisAlignment: WrapCrossAlignment.end,
                            children: [
                              Text(
                                '$countdown',
                                style: AppText.hero
                                    .copyWith(
                                      fontSize: 56,
                                      height: 62 / 56,
                                      color: AppColors.amber,
                                    )
                                    .tabular,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Text(
                                  t.days,
                                  style: AppText.heading.copyWith(
                                    color: AppColors.onNight,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '≈ ${capitalize(weekdayName(lang, start))} ${longDate(lang, start)}',
                            style: AppText.label.copyWith(
                              color: AppColors.onNightMuted,
                            ),
                          ),
                        ],
                ),
              ),
            ],
          ),
        ),
        Section(
          title: t.timetable,
          children: [
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _Row(
                    cells: [
                      Text('#', style: head),
                      Text(t.date, style: head),
                      Text(t.suhoor, style: head, textAlign: TextAlign.right),
                      Text(t.iftar, style: head, textAlign: TextAlign.right),
                    ],
                    header: true,
                  ),
                  for (final r in timetable)
                    _Row(
                      color: r.i == current
                          ? AppColors.amberSoft
                          : (r.i.isEven ? const Color(0xFFFDFAF5) : null),
                      cells: [
                        Text(
                          '${r.i}',
                          style: AppText.label
                              .copyWith(color: AppColors.muted)
                              .tabular,
                        ),
                        Text(
                          '${r.day.d} ${monthName(lang, r.day.m, short: true)}',
                          style: AppText.label,
                        ),
                        Text(
                          r.suhoor,
                          style: AppText.number,
                          textAlign: TextAlign.right,
                        ),
                        Text(
                          r.iftar,
                          style: AppText.number.copyWith(
                            color: AppColors.amberDeep,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ],
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

class _Row extends StatelessWidget {
  const _Row({required this.cells, this.color, this.header = false});
  final List<Widget> cells;
  final Color? color;
  final bool header;

  @override
  Widget build(BuildContext context) => Container(
    color: color,
    padding: const EdgeInsets.symmetric(horizontal: Space.lg, vertical: 10),
    decoration: header
        ? const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.line)),
          )
        : null,
    child: Row(
      children: [
        SizedBox(width: 32, child: cells[0]),
        Expanded(child: cells[1]),
        SizedBox(width: 86, child: cells[2]),
        SizedBox(width: 86, child: cells[3]),
      ],
    ),
  );
}
