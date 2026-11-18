import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/utils/format.dart';
import '../../../core/utils/time.dart';
import '../../../core/widgets/photo.dart';
import '../../../core/widgets/ui.dart';
import '../../../data/content.dart';

String kindLabel(BuildContext context, NewsKind k) => switch (k) {
  NewsKind.news => context.t.kindNews,
  NewsKind.notice => context.t.kindNotice,
  NewsKind.janaza => context.t.kindJanaza,
};

(Color, Color) kindColors(NewsKind k) => switch (k) {
  NewsKind.news => (AppColors.surface, AppColors.ink),
  NewsKind.notice => (AppColors.amber, AppColors.ink),
  NewsKind.janaza => (AppColors.infoSoft, AppColors.info),
};

/// The article photo, carried between list, carousel and article with a Hero on an arc.
class NewsPhoto extends StatelessWidget {
  const NewsPhoto({super.key, required this.item, this.scrim});
  final NewsItem item;
  final Gradient? scrim;

  @override
  Widget build(BuildContext context) => Hero(
    tag: 'news-photo-${item.id}',
    createRectTween: (a, b) => MaterialRectArcTween(begin: a, end: b),
    child: Photo(item.photo, scrim: scrim),
  );
}

class KindTag extends StatelessWidget {
  const KindTag(this.kind, {super.key});
  final NewsKind kind;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = kindColors(kind);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Space.sm, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(Radii.pill),
      ),
      child: Text(
        kindLabel(context, kind),
        style: AppText.caption.copyWith(color: fg, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// Carousel card: full-bleed photo with the headline set on a scrim.
class NewsSlide extends StatelessWidget {
  const NewsSlide({super.key, required this.item});
  final NewsItem item;

  @override
  Widget build(BuildContext context) {
    final day = addDays(muToday(), -item.daysAgo);
    return Pressable(
      onTap: () => context.push('/news/${item.id}'),
      label: context.tr(item.title),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Radii.lg),
        child: Stack(
          fit: StackFit.expand,
          children: [
            NewsPhoto(item: item, scrim: Scrims.bottom),
            Padding(
              padding: const EdgeInsets.all(Space.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  KindTag(item.kind),
                  const Spacer(),
                  Text(
                    context.tr(item.title),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.heading.copyWith(color: AppColors.onNight),
                  ),
                  const SizedBox(height: Space.xs),
                  Text(
                    longDate(context.lang, day),
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
    );
  }
}

/// List row with a photo thumbnail.
class NewsCard extends StatelessWidget {
  const NewsCard({super.key, required this.item});
  final NewsItem item;

  @override
  Widget build(BuildContext context) => AppCard(
    onTap: () => context.push('/news/${item.id}'),
    label: context.tr(item.title),
    padding: const EdgeInsets.all(Space.sm),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Inner radius = card radius (12) − padding (8).
        ClipRRect(
          borderRadius: BorderRadius.circular(Radii.lg - Space.sm),
          child: SizedBox(width: 96, height: 96, child: NewsPhoto(item: item)),
        ),
        const SizedBox(width: Space.md),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Space.xs),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${kindLabel(context, item.kind)} · ${ago(context.t, item.daysAgo)}',
                  style: AppText.caption.copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: 2),
                Text(
                  context.tr(item.title),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.bodyStrong,
                ),
                Text(
                  context.tr(item.summary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.label.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
