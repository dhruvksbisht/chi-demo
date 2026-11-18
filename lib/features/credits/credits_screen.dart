import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/tokens.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/photo.dart';
import '../../core/widgets/ui.dart';

/// Attribution for bundled photography (required by CC BY / CC BY-SA).
class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  @override
  Widget build(BuildContext context) => AppScreen(
    back: true,
    title: context.t.photoCredits,
    subtitle: context.t.photoCreditsSub,
    children: [
      AppCard(
        padding: const EdgeInsets.all(Space.sm),
        child: Column(
          children: [
            for (final p in Photos.values)
              Pressable(
                onTap: () => launchUrl(
                  Uri.parse(p.sourceUrl),
                  mode: LaunchMode.externalApplication,
                ),
                label: p.caption,
                child: Padding(
                  padding: const EdgeInsets.all(Space.sm),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(Radii.sm),
                        child: SizedBox.square(dimension: 56, child: Photo(p)),
                      ),
                      const SizedBox(width: Space.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.caption,
                              style: AppText.label.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${p.author} · ${p.license}',
                              style: AppText.caption.copyWith(
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.open_in_new_rounded,
                        size: 18,
                        color: AppColors.muted,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    ],
  );
}
