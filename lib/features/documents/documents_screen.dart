import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/tokens.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/ui.dart';
import '../../data/app_state.dart';
import '../../data/content.dart';

class DocumentsScreen extends ConsumerWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final loggedIn = ref.watch(appProvider.select((s) => s.loggedIn));
    return AppScreen(
      back: true,
      title: t.documents,
      children: [
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (final (i, d) in documents.indexed)
                () {
                  final locked = d.membersOnly && !loggedIn;
                  return ListRow(
                    icon: locked
                        ? Icons.lock_rounded
                        : Icons.description_rounded,
                    title: context.tr(d.title),
                    subtitle: d.membersOnly
                        ? '${d.meta} · ${t.membersOnly}'
                        : d.meta,
                    trailing: locked
                        ? null
                        : const Icon(
                            Icons.download_rounded,
                            size: 20,
                            color: AppColors.muted,
                          ),
                    chevron: locked,
                    divider: i < documents.length - 1,
                    onTap: () => locked
                        ? context.go('/member')
                        : showInfo(context, context.tr(d.title), t.docPreview),
                  );
                }(),
            ],
          ),
        ),
        if (!loggedIn)
          Text(
            t.loginToView,
            style: AppText.caption.copyWith(color: AppColors.muted),
          ),
      ],
    );
  }
}
