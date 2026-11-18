import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/tokens.dart';
import '../../core/utils/format.dart';
import '../../core/utils/time.dart';
import '../../core/widgets/brand.dart';
import '../../core/widgets/photo.dart';
import '../../core/widgets/ui.dart';
import '../../data/app_state.dart';
import '../../data/content.dart';
import '../../data/models.dart';
import '../news/widgets/news_widgets.dart';

const _heroHeight = 340.0;

/// After Maghrib and before Fajr the hero shows Port Louis at night.
bool _isNight(DateTime now) {
  final times = prayerTimesFor(muToday(now));
  final fajr = times.first.time;
  final maghrib = times.firstWhere((p) => p.name == PrayerName.maghrib).time;
  return now.isBefore(fajr) || now.isAfter(maghrib);
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final lang = context.lang;
    final inboxRead = ref.watch(appProvider.select((s) => s.inboxRead));
    final today = muToday();
    final hijri = toHijri(today);
    final top = MediaQuery.paddingOf(context).top;
    final notice = news.where((n) => n.kind == NewsKind.notice).firstOrNull;
    final upcoming = [...events]..sort((a, b) => a.inDays.compareTo(b.inDays));
    final next = upcoming.first;
    final nextDay = addDays(today, next.inDays);
    final nextWhen =
        '${capitalize(weekdayName(lang, nextDay).substring(0, 3))} ${nextDay.d} ${monthName(lang, nextDay.m, short: true)}';

    final features = [
      (
        route: '/events',
        title: t.events,
        detail: '${context.tr(next.title)} · $nextWhen',
        photo: next.photo,
      ),
      (
        route: '/donate',
        title: t.donate,
        detail: t.donateDetail,
        photo: Photos.jummahCourtyard,
      ),
      (
        route: '/centenary',
        title: t.centenary,
        detail: t.centenaryDetail,
        photo: Photos.jummah1970s,
      ),
    ];
    final quick = [
      (Icons.schedule_rounded, t.prayerTimes, '/prayer'),
      (Icons.dark_mode_rounded, t.ramadan, '/ramadan'),
      (Icons.explore_rounded, t.qibla, '/qibla'),
      (Icons.description_rounded, t.documents, '/documents'),
      (Icons.menu_book_rounded, t.duas, '/duas'),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            // ---- Photo hero with greeting; the prayer card overlaps its bottom edge.
            Stack(
              clipBehavior: Clip.none,
              children: [
                SizedBox(
                  height: _heroHeight + top,
                  width: double.infinity,
                  child: NowBuilder(
                    interval: const Duration(minutes: 1),
                    builder: (context, now) => AnimatedSwitcher(
                      duration: reduceMotion(context)
                          ? Duration.zero
                          : const Duration(milliseconds: 600),
                      child: Photo(
                        _isNight(now)
                            ? Photos.portLouisNight
                            : Photos.jummahStreet,
                        key: ValueKey(_isNight(now)),
                        alignment: const Alignment(0, -0.2),
                        scrim: Scrims.both,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    Space.lg,
                    top + Space.sm,
                    Space.lg,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Logo(size: 44),
                          const Spacer(),
                          _LangSwitch(
                            value: ref.watch(langProvider),
                            onChanged: ref.read(appProvider.notifier).setLang,
                          ),
                          const SizedBox(width: Space.xs),
                          IconBtn(
                            icon: Icons.notifications_rounded,
                            label: t.notifications,
                            badge: !inboxRead,
                            onPhoto: true,
                            onTap: () => context.push('/notifications'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 96),
                      Text(
                        '${capitalize(weekdayName(lang, today))} ${longDate(lang, today)}',
                        style: AppText.label.copyWith(
                          color: AppColors.onNightMuted,
                        ),
                      ),
                      const SizedBox(height: Space.xs),
                      Text(
                        t.assalamu,
                        style: AppText.hero.copyWith(color: AppColors.onNight),
                      ),
                      const SizedBox(height: Space.xs),
                      Text(
                        '${hijri.d} ${hijriMonthName(hijri.m)} ${hijri.y} AH',
                        style: AppText.label.copyWith(color: AppColors.amber),
                      ),
                      const SizedBox(height: Space.lg),
                      const _PrayerCard(),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Space.lg,
                Space.xl,
                Space.lg,
                Space.xxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: gap([
                  // ---- Quick tools: one row of chips (Hick's law: few, clear choices).
                  SizedBox(
                    height: 48,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      children: gap(
                        [
                          for (final (icon, label, route) in quick)
                            Pressable(
                              onTap: () => context.push(route),
                              label: label,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: Space.md,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(
                                    Radii.pill,
                                  ),
                                  border: Border.all(color: AppColors.line),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      icon,
                                      size: 18,
                                      color: AppColors.amberDeep,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(label, style: AppText.label),
                                  ],
                                ),
                              ),
                            ),
                        ],
                        Space.sm,
                        axis: Axis.horizontal,
                      ),
                    ),
                  ),
                  if (notice != null)
                    AppCard(
                      tone: CardTone.amber,
                      onTap: () => context.push('/news/${notice.id}'),
                      label: context.tr(notice.title),
                      padding: const EdgeInsets.symmetric(
                        horizontal: Space.lg,
                        vertical: Space.md,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.campaign_rounded,
                            color: AppColors.amberDeep,
                          ),
                          const SizedBox(width: Space.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t.urgent,
                                  style: AppText.overline.copyWith(
                                    color: AppColors.amberDeep,
                                  ),
                                ),
                                Text(
                                  context.tr(notice.title),
                                  style: AppText.bodyStrong,
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.amberDeep,
                          ),
                        ],
                      ),
                    ),
                  Section(
                    title: t.latestNews,
                    action: t.seeAll,
                    onAction: () => context.push('/news'),
                    children: [
                      SizedBox(
                        height: 280,
                        child: PageView(
                          controller: PageController(viewportFraction: 0.84),
                          padEnds: false,
                          clipBehavior: Clip.none,
                          children: [
                            for (final item in news)
                              Padding(
                                padding: const EdgeInsets.only(right: Space.md),
                                child: NewsSlide(item: item),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Section(
                    title: t.explore,
                    children: [
                      for (final f in features)
                        _FeatureCard(
                          title: f.title,
                          detail: f.detail,
                          photo: f.photo,
                          onTap: () => context.push(f.route),
                        ),
                    ],
                  ),
                ], Space.xl),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LangSwitch extends StatelessWidget {
  const _LangSwitch({required this.value, required this.onChanged});
  final Lang value;
  final ValueChanged<Lang> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(
      color: const Color(0x59000000),
      borderRadius: BorderRadius.circular(Radii.pill),
      border: Border.all(color: const Color(0x33FFFFFF)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (l, label) in const [(Lang.en, 'EN'), (Lang.fr, 'FR')])
          Pressable(
            onTap: () => onChanged(l),
            selected: l == value,
            label: label,
            child: AnimatedContainer(
              duration: reduceMotion(context) ? Duration.zero : Motion.short,
              curve: Motion.move,
              constraints: const BoxConstraints(minWidth: 44, minHeight: 34),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: l == value ? AppColors.onNight : Colors.transparent,
                borderRadius: BorderRadius.circular(Radii.pill),
              ),
              child: Text(
                label,
                style: AppText.label.copyWith(
                  color: l == value ? AppColors.ink : AppColors.onNight,
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

/// The day's anchor: next prayer with a live countdown, then all five times.
class _PrayerCard extends StatelessWidget {
  const _PrayerCard();

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return NowBuilder(
      builder: (context, now) {
        final next = nextPrayer(now);
        final times = prayerTimesFor(muToday(now))
            .where((p) => p.name != PrayerName.sunrise);
        return Pressable(
          onTap: () => context.push('/prayer'),
          label:
              '${t.nextPrayer}: ${prayerLabel(t, next.name)} ${formatTime(next.time)}',
          child: Container(
            padding: const EdgeInsets.all(Space.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(Radii.lg + 4),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x26211D18),
                  blurRadius: 24,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.nextPrayer, style: AppText.overline),
                          Text(prayerLabel(t, next.name), style: AppText.title),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          formatTime(next.time),
                          style: AppText.title
                              .copyWith(color: AppColors.amberDeep)
                              .tabular,
                        ),
                        Text(
                          '${t.inTime} ${formatCountdown(next.time.difference(now))}',
                          style: AppText.label
                              .copyWith(color: AppColors.muted)
                              .tabular,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: Space.md),
                Row(
                  children: [
                    for (final p in times)
                      Expanded(
                        child: AnimatedContainer(
                          duration: reduceMotion(context)
                              ? Duration.zero
                              : Motion.short,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          padding: const EdgeInsets.symmetric(
                            vertical: Space.sm,
                          ),
                          decoration: BoxDecoration(
                            color: p.name == next.name
                                ? AppColors.amber
                                : AppColors.sunken,
                            borderRadius: BorderRadius.circular(Radii.md),
                          ),
                          child: Column(
                            children: [
                              FittedBox(
                                child: Text(
                                  prayerLabel(t, p.name),
                                  style: AppText.caption.copyWith(
                                    color: p.name == next.name
                                        ? AppColors.ink
                                        : AppColors.muted,
                                  ),
                                ),
                              ),
                              Text(
                                formatTime(p.time),
                                style: AppText.number.copyWith(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Photo card for a secondary area (events, donate, centenary).
class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.title,
    required this.detail,
    required this.photo,
    required this.onTap,
  });
  final String title;
  final String detail;
  final Photos photo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Pressable(
    onTap: onTap,
    label: title,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(Radii.lg),
      child: ConstrainedBox(
        // Grows with longer French text or large system font sizes.
        constraints: const BoxConstraints(minHeight: 132),
        child: Stack(
          children: [
            Positioned.fill(child: Photo(photo, scrim: Scrims.left)),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Space.lg,
                48,
                Space.lg,
                Space.lg,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppText.title.copyWith(
                            color: AppColors.onNight,
                          ),
                        ),
                        Text(
                          detail,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.label.copyWith(
                            color: AppColors.onNightMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.onNight,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
