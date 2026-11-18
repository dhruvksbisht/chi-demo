import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/tokens.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/ui.dart';
import '../../data/app_state.dart';
import '../../data/content.dart';

IconData _icon(String kind) => switch (kind) {
  'subscription' => Icons.credit_card_rounded,
  'janaza' => Icons.dark_mode_rounded,
  'event' => Icons.event_rounded,
  _ => Icons.notifications_rounded,
};

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Opening the inbox marks it read, after a beat so the unread state is visible.
    _timer = Timer(
      const Duration(milliseconds: 2500),
      () => ref.read(appProvider.notifier).markInboxRead(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final unread = !ref.watch(appProvider.select((s) => s.inboxRead));
    return AppScreen(
      back: true,
      title: t.notifications,
      children: [
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (final (i, n) in inbox.indexed)
                EnterFade(
                  index: i,
                  child: Pressable(
                    onTap: () => context.push(n.route),
                    label: context.tr(n.title),
                    child: Container(
                      padding: const EdgeInsets.all(Space.lg),
                      decoration: BoxDecoration(
                        border: i < inbox.length - 1
                            ? const Border(
                                bottom: BorderSide(
                                  color: AppColors.line,
                                  width: 0.5,
                                ),
                              )
                            : null,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconTile(_icon(n.kind)),
                          const SizedBox(width: Space.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        context.tr(n.title),
                                        style: AppText.bodyStrong,
                                      ),
                                    ),
                                    Text(
                                      ago(t, n.daysAgo),
                                      style: AppText.caption.copyWith(
                                        color: AppColors.muted,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  context.tr(n.body),
                                  style: AppText.label.copyWith(
                                    color: AppColors.inkSoft,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          AnimatedOpacity(
                            opacity: unread && i < 2 ? 1 : 0,
                            duration: reduceMotion(context)
                                ? Duration.zero
                                : Motion.short,
                            child: Container(
                              margin: const EdgeInsets.only(
                                left: Space.sm,
                                top: 6,
                              ),
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.danger,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
