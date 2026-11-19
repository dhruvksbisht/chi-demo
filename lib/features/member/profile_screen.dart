import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/tokens.dart';
import '../../core/utils/biometric.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/ui.dart';
import '../../data/app_state.dart';
import '../../data/content.dart';
import '../../data/models.dart';
import 'member_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final s = ref.watch(appProvider);
    final app = ref.read(appProvider.notifier);
    final bio = ref.watch(biometricProvider).value ?? BiometricKind.none;

    return AppScreen(
      back: true,
      title: t.profile,
      children: [
        Section(
          title: t.personal,
          children: [
            AppCard(
              child: Column(
                children: [
                  KV(t.fullName, member.name),
                  KV(t.tabMember, member.number),
                  KV(t.category, context.tr(member.category)),
                  KV(t.email, member.email),
                  KV(t.mobile, member.phone),
                ],
              ),
            ),
          ],
        ),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(Space.lg),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.line, width: 0.5),
                  ),
                ),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  runSpacing: Space.sm,
                  children: [
                    Text(t.language, style: AppText.bodyStrong),
                    Segmented<Lang>(
                      options: const [
                        (Lang.en, 'English'),
                        (Lang.fr, 'Français'),
                      ],
                      value: s.lang,
                      onChanged: app.setLang,
                    ),
                  ],
                ),
              ),
              ListRow(
                icon: Icons.notifications_rounded,
                title: t.reminders,
                subtitle: t.remindersSub,
                trailing: Toggle(
                  value: s.reminders,
                  onChanged: app.setReminders,
                  label: t.reminders,
                ),
              ),
              ListRow(
                icon: Icons.fingerprint_rounded,
                title: t.biometrics,
                subtitle: bio == BiometricKind.none
                    ? t.bioUnavailable
                    : bioLabel(t, bio),
                trailing: Toggle(
                  value: s.biometrics && bio != BiometricKind.none,
                  onChanged: bio == BiometricKind.none
                      ? (_) {}
                      : app.setBiometrics,
                  label: t.biometrics,
                ),
                divider: false,
              ),
            ],
          ),
        ),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              ListRow(
                icon: Icons.insights_rounded,
                title: t.adminPreview,
                onTap: () => context.push('/admin'),
              ),
              ListRow(
                icon: Icons.photo_library_rounded,
                title: t.photoCredits,
                onTap: () => context.push('/credits'),
              ),
              // FR-028 / SEC-10: deletion request under the Data Protection Act.
              ListRow(
                icon: Icons.delete_rounded,
                title: t.deleteData,
                subtitle: 'Data Protection Act 2017',
                onTap: () async {
                  final ok = await confirmAction(
                    context,
                    title: t.deleteData,
                    body: t.deleteConfirm,
                    confirmLabel: t.sendRequest,
                  );
                  if (ok && context.mounted) {
                    await showInfo(context, t.deleteData, t.deleteSent);
                  }
                },
                divider: false,
              ),
            ],
          ),
        ),
        AppButton(
          label: t.logOut,
          kind: ButtonKind.danger,
          icon: Icons.logout_rounded,
          onPressed: () {
            app.logOut();
            context.go('/member');
          },
        ),
        Text(
          t.demoBuild,
          textAlign: TextAlign.center,
          style: AppText.caption.copyWith(color: AppColors.muted),
        ),
      ],
    );
  }
}
