import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/tokens.dart';
import '../../core/utils/format.dart';
import '../../core/utils/time.dart';
import '../../core/widgets/brand.dart';
import '../../core/widgets/ui.dart';
import '../../data/app_state.dart';
import '../../data/content.dart';
import '../../data/models.dart';
import '../news/widgets/news_widgets.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final lang = context.lang;
    final inboxRead = ref.watch(appProvider.select((s) => s.inboxRead));
    final today = muToday();
    final hijri = toHijri(today);
    final notice = news.where((n) => n.kind == NewsKind.notice).firstOrNull;
    final upcoming = [...events]..sort((a, b) => a.inDays.compareTo(b.inDays));
    final next = upcoming.first;
    final nextDay = addDays(today, next.inDays);
    final nextWhen =
        '${capitalize(weekdayName(lang, nextDay).substring(0, 3))} ${nextDay.d} ${monthName(lang, nextDay.m, short: true)}';

    final banners = [
      (
        route: '/events',
        title: t.events,
        detail: '${context.tr(next.title)}, $nextWhen',
        accent: AppColors.amber,
      ),
      (
        route: '/donate',
        title: t.donate,
        detail: t.donateDetail,
        accent: AppColors.sage,
      ),
      (
        route: '/centenary',
        title: t.centenary,
        detail: t.centenaryDetail,
        accent: AppColors.sky,
      ),
    ];
    final quick = [
      (Icons.schedule_rounded, t.prayerTimes, '/prayer'),
      (Icons.dark_mode_rounded, t.ramadan, '/ramadan'),
      (Icons.explore_rounded, t.qibla, '/qibla'),
      (Icons.description_rounded, t.documents, '/documents'),
      (Icons.menu_book_rounded, t.duas, '/duas'),
    ];

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            Space.lg,
            Space.sm,
            Space.lg,
            Space.xxl,
          ),
          children: gap([
            Row(
              children: [
                const Logo(size: 42),
                const Spacer(),
                Segmented<Lang>(
                  options: const [(Lang.en, 'EN'), (Lang.fr, 'FR')],
                  value: ref.watch(langProvider),
                  onChanged: ref.read(appProvider.notifier).setLang,
                ),
                const SizedBox(width: Space.xs),
                IconBtn(
                  icon: Icons.notifications_rounded,
                  label: t.notifications,
                  badge: !inboxRead,
                  onTap: () => context.push('/notifications'),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${capitalize(weekdayName(lang, today))} ${longDate(lang, today)}',
                  style: AppText.label.copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: Space.xs),
                Text(t.assalamu, style: AppText.hero),
                const SizedBox(height: Space.xs),
                Text(
                  '${hijri.d} ${hijriMonthName(hijri.m)} ${hijri.y} AH',
                  style: AppText.label.copyWith(color: AppColors.amberDeep),
                ),
              ],
            ),
            const _PrayerHero(),
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
            Column(
              children: gap([
                for (final b in banners)
                  _Banner(
                    title: b.title,
                    detail: b.detail,
                    accent: b.accent,
                    onTap: () => context.push(b.route),
                  ),
              ], Space.md),
            ),
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
                            borderRadius: BorderRadius.circular(Radii.pill),
                            border: Border.all(color: AppColors.line),
                          ),
                          child: Row(
                            children: [
                              Icon(icon, size: 18, color: AppColors.amberDeep),
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
            Section(
              title: t.latestNews,
              action: t.seeAll,
              onAction: () => context.push('/news'),
              children: [
                SizedBox(
                  height: 252,
                  child: PageView(
                    controller: PageController(viewportFraction: 0.82),
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
          ], Space.xl),
        ),
      ),
    );
  }
}

/// Dark hero: the next prayer, a live countdown and today's five times.
class _PrayerHero extends StatelessWidget {
  const _PrayerHero();

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return NowBuilder(
      builder: (context, now) {
        final next = nextPrayer(now);
        final times = prayerTimesFor(muToday(now))
            .where((p) => p.name != PrayerName.sunrise);
        return AppCard(
          tone: CardTone.night,
          onTap: () => context.push('/prayer'),
          label:
              '${t.nextPrayer}: ${prayerLabel(t, next.name)} ${formatTime(next.time)}',
          padding: const EdgeInsets.all(Space.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.nextPrayer,
                style: AppText.overline.copyWith(color: AppColors.onNightMuted),
              ),
              const SizedBox(height: Space.xs),
              Wrap(
                spacing: Space.md,
                crossAxisAlignment: WrapCrossAlignment.end,
                children: [
                  Text(
                    prayerLabel(t, next.name),
                    style: AppText.hero.copyWith(color: AppColors.onNight),
                  ),
                  Text(
                    formatTime(next.time),
                    style: AppText.hero
                        .copyWith(color: AppColors.amber)
                        .tabular,
                  ),
                ],
              ),
              Text(
                '${t.inTime} ${formatCountdown(next.time.difference(now))}',
                style: AppText.label
                    .copyWith(color: AppColors.onNightMuted)
                    .tabular,
              ),
              const SizedBox(height: Space.lg),
              Row(
                children: [
                  for (final p in times)
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        padding: const EdgeInsets.symmetric(vertical: Space.sm),
                        decoration: BoxDecoration(
                          color: p.name == next.name
                              ? AppColors.amber
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(Radii.sm),
                        ),
                        child: Column(
                          children: [
                            FittedBox(
                              child: Text(
                                prayerLabel(t, p.name),
                                style: AppText.caption.copyWith(
                                  color: p.name == next.name
                                      ? AppColors.night
                                      : AppColors.onNightMuted,
                                ),
                              ),
                            ),
                            Text(
                              formatTime(p.time),
                              style: AppText.number.copyWith(
                                color: p.name == next.name
                                    ? AppColors.night
                                    : AppColors.onNight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Full-width dark banner: tile-pattern panel cut on a diagonal, title, stepped accent edge.
class _Banner extends StatelessWidget {
  const _Banner({
    required this.title,
    required this.detail,
    required this.accent,
    required this.onTap,
  });
  final String title;
  final String detail;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Pressable(
    onTap: onTap,
    label: title,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(Radii.md),
      child: ColoredBox(
        color: AppColors.night,
        child: LayoutBuilder(
          builder: (context, c) {
            final artW = c.maxWidth * 0.3;
            return Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: artW,
                  child: ColoredBox(
                    color: AppColors.nightRaised,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        TilePattern(color: accent, opacity: 0.6),
                        const CustomPaint(painter: _CutPainter()),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: 56,
                  child: CustomPaint(painter: _StepsPainter(accent)),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 112),
                  child: Center(
                    heightFactor: 1,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        artW + Space.md,
                        Space.md,
                        64,
                        Space.md,
                      ),
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
                  ),
                ),
              ],
            );
          },
        ),
      ),
    ),
  );
}

class _CutPainter extends CustomPainter {
  const _CutPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const cut = 44.0;
    canvas.drawPath(
      Path()
        ..moveTo(size.width, 0)
        ..lineTo(size.width, size.height)
        ..lineTo(size.width - cut, size.height)
        ..close(),
      Paint()..color = AppColors.night,
    );
  }

  @override
  bool shouldRepaint(_CutPainter old) => false;
}

/// Stepped blocks on the right edge, laid out on a 56 x 112 grid and stretched to fit.
class _StepsPainter extends CustomPainter {
  const _StepsPainter(this.color);
  final Color color;

  static const _steps = [
    (26.0, 0.0, 30.0, 22.0, 1.0),
    (44.0, 22.0, 12.0, 26.0, 0.5),
    (30.0, 48.0, 26.0, 22.0, 0.85),
    (12.0, 70.0, 44.0, 16.0, 0.35),
    (40.0, 86.0, 16.0, 26.0, 1.0),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 56, size.height / 112);
    for (final (x, y, w, h, o) in _steps) {
      canvas.drawRect(
        Rect.fromLTWH(x, y, w, h),
        Paint()..color = color.withValues(alpha: o),
      );
    }
  }

  @override
  bool shouldRepaint(_StepsPainter old) => old.color != color;
}
