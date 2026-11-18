import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/tokens.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/brand.dart';
import '../../core/widgets/ui.dart';
import '../../data/content.dart';

class CentenaryScreen extends StatelessWidget {
  const CentenaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return AppScreen(
      back: true,
      title: t.centenary,
      subtitle: t.centenarySub,
      children: [
        AppCard(
          tone: CardTone.night,
          padding: EdgeInsets.zero,
          child: Stack(
            children: [
              const Positioned(
                right: -80,
                top: -60,
                child: Star(size: 260, opacity: 0.2),
              ),
              Padding(
                padding: const EdgeInsets.all(Space.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: gap([
                    const Logo(size: 64),
                    Text(
                      '1927 — 2027',
                      style: AppText.hero
                          .copyWith(color: AppColors.onNight, letterSpacing: 1)
                          .tabular,
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 280),
                      child: Text(
                        t.centenaryTagline,
                        style: AppText.body.copyWith(
                          color: AppColors.onNightMuted,
                        ),
                      ),
                    ),
                  ], Space.md),
                ),
              ),
            ],
          ),
        ),
        Section(
          title: t.programme,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: StatusBadge(t.sample, tone: BadgeTone.info),
            ),
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
          label: t.events,
          icon: Icons.event_rounded,
          kind: ButtonKind.secondary,
          onPressed: () => context.push('/events'),
        ),
        AppButton(
          label: t.donate,
          icon: Icons.volunteer_activism_rounded,
          onPressed: () => context.push('/donate'),
        ),
      ],
    );
  }
}
