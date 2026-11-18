import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/utils/format.dart';
import '../../../core/utils/time.dart';
import '../../../core/widgets/brand.dart';
import '../../../core/widgets/ui.dart';
import '../../../data/content.dart';

Color kindAccent(NewsKind k) => switch (k) {
  NewsKind.news => AppColors.amber,
  NewsKind.notice => AppColors.amberLight,
  NewsKind.janaza => AppColors.sky,
};

String kindLabel(BuildContext context, NewsKind k) => switch (k) {
  NewsKind.news => context.t.kindNews,
  NewsKind.notice => context.t.kindNotice,
  NewsKind.janaza => context.t.kindJanaza,
};

/// Patterned art standing in for news photography. Shared by the carousel, the list
/// thumbnail and the article cover, and carried between them with a Hero.
class NewsArt extends StatelessWidget {
  const NewsArt({
    super.key,
    required this.item,
    this.tag = true,
    this.tile = 36,
  });
  final NewsItem item;
  final bool tag;
  final double tile;

  @override
  Widget build(BuildContext context) => Hero(
    tag: 'news-art-${item.id}',
    createRectTween: (a, b) => MaterialRectArcTween(begin: a, end: b),
    child: Container(
      color: AppColors.nightRaised,
      child: Stack(
        children: [
          TilePattern(tile: tile, color: kindAccent(item.kind), opacity: 0.45),
          if (tag)
            Positioned(
              left: 0,
              bottom: 0,
              child: Container(
                color: kindAccent(item.kind),
                padding: const EdgeInsets.symmetric(
                  horizontal: Space.md,
                  vertical: Space.xs,
                ),
                child: Text(
                  kindLabel(context, item.kind),
                  style: AppText.overline.copyWith(color: AppColors.night),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

/// Tall carousel card for the home screen: art panel over a dark caption.
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
        borderRadius: BorderRadius.circular(Radii.md),
        child: ColoredBox(
          color: AppColors.night,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 132, child: NewsArt(item: item)),
              Padding(
                padding: const EdgeInsets.all(Space.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 52,
                      child: Text(
                        context.tr(item.title),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.heading.copyWith(
                          color: AppColors.onNight,
                        ),
                      ),
                    ),
                    const SizedBox(height: Space.md),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            longDate(context.lang, day),
                            style: AppText.label.copyWith(
                              color: AppColors.onNightMuted,
                            ),
                          ),
                        ),
                        const Logo(size: 24, lettering: false),
                      ],
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
}

/// List row with a small art thumbnail.
class NewsCard extends StatelessWidget {
  const NewsCard({super.key, required this.item});
  final NewsItem item;

  @override
  Widget build(BuildContext context) => AppCard(
    onTap: () => context.push('/news/${item.id}'),
    label: context.tr(item.title),
    padding: const EdgeInsets.all(Space.md),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Inner radius = card radius (12) − padding (12) → square-ish; keep a small 4 for softness.
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox.square(
            dimension: 72,
            child: NewsArt(item: item, tag: false, tile: 24),
          ),
        ),
        const SizedBox(width: Space.md),
        Expanded(
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
      ],
    ),
  );
}
