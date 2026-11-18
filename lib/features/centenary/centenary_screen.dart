import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/tokens.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/photo.dart';
import '../../core/widgets/ui.dart';
import '../../data/content.dart';

const _gallery = [
  Photos.jummah1970s,
  Photos.market1960s,
  Photos.doorway,
  Photos.jummahCourtyard,
  Photos.jummahFront,
];

/// FR-040: history, timeline, gallery and event programme.
class CentenaryScreen extends StatelessWidget {
  const CentenaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return PhotoScreen(
      photo: const Photo(Photos.jummah1970s, scrim: Scrims.both),
      height: 380,
      eyebrow: StatusBadge(t.sample, tone: BadgeTone.info),
      title: '1927 — 2027',
      subtitle: t.centenarySub,
      footer: AppButton(
        label: t.donate,
        icon: Icons.volunteer_activism_rounded,
        onPressed: () => context.push('/donate'),
      ),
      children: [
        Text(t.centenaryTagline, style: AppText.heading),
        Section(
          title: t.gallery,
          children: [
            SizedBox(
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                itemCount: _gallery.length,
                separatorBuilder: (_, _) => const SizedBox(width: Space.md),
                itemBuilder: (context, i) => _GalleryTile(_gallery[i]),
              ),
            ),
          ],
        ),
        Section(
          title: t.history,
          children: [
            for (final (i, (year, text)) in timeline.indexed)
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: 14,
                      child: Column(
                        children: [
                          const SizedBox(height: 6),
                          Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: i == timeline.length - 1
                                  ? AppColors.amber
                                  : AppColors.bg,
                              border: Border.all(
                                color: AppColors.amber,
                                width: 3,
                              ),
                            ),
                          ),
                          if (i < timeline.length - 1)
                            Expanded(
                              child: Container(
                                width: 2,
                                margin: const EdgeInsets.only(top: 2),
                                color: AppColors.line,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: Space.lg),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: Space.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              year,
                              style: AppText.heading.copyWith(
                                color: AppColors.amberDeep,
                              ),
                            ),
                            Text(
                              context.tr(text),
                              style: AppText.body.copyWith(
                                color: AppColors.inkSoft,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        AppButton(
          label: t.programme,
          icon: Icons.event_rounded,
          kind: ButtonKind.secondary,
          onPressed: () => context.push('/events'),
        ),
      ],
    );
  }
}

class _GalleryTile extends StatelessWidget {
  const _GalleryTile(this.photo);
  final Photos photo;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 220,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Radii.lg),
            child: Photo(photo),
          ),
        ),
        const SizedBox(height: Space.sm),
        Text(
          photo.caption,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppText.caption.copyWith(color: AppColors.muted),
        ),
      ],
    ),
  );
}
