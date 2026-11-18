import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/biometric.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/brand.dart';
import '../../core/widgets/photo.dart';
import '../../core/widgets/ui.dart';
import '../../data/app_state.dart';
import '../../data/content.dart';
import '../../data/models.dart';
import 'widgets/subscription_grid.dart';

String bioLabel(AppLocalizations t, BiometricKind k) => switch (k) {
  BiometricKind.face => t.faceId,
  BiometricKind.fingerprint => t.fingerprint,
  BiometricKind.none => t.biometricsGeneric,
};

class MemberScreen extends ConsumerWidget {
  const MemberScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loggedIn = ref.watch(appProvider.select((s) => s.loggedIn));
    return AnimatedSwitcher(
      duration: reduceMotion(context) ? Duration.zero : Motion.page,
      switchInCurve: Motion.enter,
      switchOutCurve: Motion.exit,
      child: loggedIn
          ? const _Dashboard(key: ValueKey('dash'))
          : const _Login(key: ValueKey('login')),
    );
  }
}

class _Login extends ConsumerStatefulWidget {
  const _Login({super.key});

  @override
  ConsumerState<_Login> createState() => _LoginState();
}

class _LoginState extends ConsumerState<_Login> {
  // Demo login is prefilled.
  final _id = TextEditingController(text: member.number);
  final _password = TextEditingController(text: 'demo-password');
  bool _busy = false;
  String? _bioError;

  @override
  void dispose() {
    _id.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _logIn() async {
    setState(() => _busy = true);
    await Future<void>.delayed(
      const Duration(milliseconds: 650),
    ); // simulated API round trip
    if (mounted) ref.read(appProvider.notifier).logIn();
  }

  Future<void> _unlock() async {
    setState(() => _bioError = null);
    final ok = await authenticate(context.t.unlockBio);
    if (!mounted) return;
    if (ok) {
      ref.read(appProvider.notifier).logIn();
    } else {
      setState(() => _bioError = context.t.bioFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final bio = ref.watch(biometricProvider).value ?? BiometricKind.none;
    final bioOn = ref.watch(appProvider.select((s) => s.biometrics));
    return AppScreen(
      title: t.memberLogin,
      subtitle: t.loginSub,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(Radii.lg),
          child: SizedBox(
            height: 180,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const Photo(
                  Photos.jummahCourtyard,
                  alignment: Alignment(0, -0.4),
                  scrim: Scrims.bottom,
                ),
                Positioned(
                  left: Space.lg,
                  bottom: Space.lg,
                  right: Space.lg,
                  child: Row(
                    children: [
                      const Logo(size: 52),
                      const SizedBox(width: Space.md),
                      Expanded(
                        child: Text(
                          societyName,
                          style: AppText.bodyStrong.copyWith(
                            color: AppColors.onNight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (bioOn && bio != BiometricKind.none)
          AppCard(
            tone: CardTone.amber,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(t.welcomeBack, style: AppText.heading),
                const SizedBox(height: Space.md),
                AppButton(
                  label: '${t.unlockBio} · ${bioLabel(t, bio)}',
                  icon: Icons.fingerprint_rounded,
                  onPressed: _unlock,
                ),
                if (_bioError != null) ...[
                  const SizedBox(height: Space.sm),
                  Text(
                    _bioError!,
                    style: AppText.caption.copyWith(color: AppColors.danger),
                  ),
                ],
              ],
            ),
          ),
        AutofillGroup(
          child: Column(
            children: [
              AppField(
                label: t.emailOrNumber,
                controller: _id,
                autofill: const [AutofillHints.username],
                textInputAction: TextInputAction.next,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: Space.lg),
              AppField(
                label: t.password,
                controller: _password,
                obscure: true,
                autofill: const [AutofillHints.password],
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
        ),
        AppButton(
          label: t.logIn,
          loading: _busy,
          onPressed: _id.text.isEmpty || _password.text.isEmpty ? null : _logIn,
        ),
        AppButton(
          label: t.forgot,
          kind: ButtonKind.ghost,
          onPressed: () => showInfo(context, t.forgot, t.forgotBody),
        ),
        Row(
          children: [
            const Expanded(child: Divider(color: AppColors.line)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Space.md),
              child: Text(
                t.notMember,
                style: AppText.caption.copyWith(color: AppColors.muted),
              ),
            ),
            const Expanded(child: Divider(color: AppColors.line)),
          ],
        ),
        AppButton(
          label: t.requestAccess,
          kind: ButtonKind.secondary,
          icon: Icons.person_add_rounded,
          onPressed: () => context.push('/request-access'),
        ),
        Text(
          t.accessNote,
          textAlign: TextAlign.center,
          style: AppText.caption.copyWith(color: AppColors.muted),
        ),
      ],
    );
  }
}

class _Dashboard extends ConsumerWidget {
  const _Dashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final lang = context.lang;
    final s = ref.watch(appProvider);
    final bio = ref.watch(biometricProvider).value ?? BiometricKind.none;
    final owed = s.arrearsTotal;
    final active = member.status == MemberStatus.active; // FR-018
    String label(Month? m) =>
        m == null ? '–' : '${capitalize(monthName(lang, m.m))} ${m.y}';
    final next = s.nextDue;

    return AppScreen(
      title: member.name,
      subtitle:
          '${t.tabMember} ${member.number} · ${t.memberSince} ${member.since}',
      trailing: IconBtn(
        icon: Icons.settings_rounded,
        label: t.profile,
        onTap: () => context.push('/profile'),
      ),
      children: [
        Wrap(
          spacing: Space.sm,
          children: [
            StatusBadge(
              active ? t.active : t.inactive,
              tone: active ? BadgeTone.success : BadgeTone.danger,
            ),
            StatusBadge(context.tr(member.category)),
          ],
        ),
        AppCard(
          tone: CardTone.night,
          padding: const EdgeInsets.all(Space.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          owed > 0 ? t.youOwe : t.allClear,
                          style: AppText.overline.copyWith(
                            color: AppColors.onNightMuted,
                          ),
                        ),
                        Text(
                          mur(owed),
                          style: AppText.hero
                              .copyWith(
                                color: owed > 0
                                    ? AppColors.amber
                                    : AppColors.onNight,
                              )
                              .tabular,
                        ),
                      ],
                    ),
                  ),
                  if (owed > 0) StatusBadge(t.overdue, tone: BadgeTone.danger),
                ],
              ),
              const SizedBox(height: Space.lg),
              const Divider(color: AppColors.nightLine, height: 1),
              const SizedBox(height: Space.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _Stat(t.paidUpTo, label(s.paidUpTo))),
                  const SizedBox(width: Space.lg),
                  Expanded(
                    child: _Stat(
                      t.nextDue,
                      next == null
                          ? '–'
                          : '${label(next)} · ${mur(next.amount)}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Space.lg),
              if (active)
                AppButton(
                  label: t.payMonths,
                  icon: Icons.credit_card_rounded,
                  onPressed: () => context.push('/pay'),
                )
              else
                Text(
                  t.inactiveNote,
                  style: AppText.label.copyWith(color: AppColors.onNight),
                ),
            ],
          ),
        ),
        if (bio != BiometricKind.none && !s.biometrics)
          AppCard(
            padding: const EdgeInsets.symmetric(
              horizontal: Space.lg,
              vertical: Space.md,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${t.bioPrompt} (${bioLabel(t, bio)})',
                    style: AppText.label,
                  ),
                ),
                const SizedBox(width: Space.md),
                AppButton(
                  label: t.enable,
                  kind: ButtonKind.secondary,
                  compact: true,
                  onPressed: () =>
                      ref.read(appProvider.notifier).setBiometrics(true),
                ),
              ],
            ),
          ),
        Section(
          title: t.subscription,
          children: const [AppCard(child: SubscriptionGrid())],
        ),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              ListRow(
                icon: Icons.receipt_long_rounded,
                title: t.history,
                onTap: () => context.push('/history'),
              ),
              ListRow(
                icon: Icons.volunteer_activism_rounded,
                title: t.donate,
                onTap: () => context.push('/donate'),
              ),
              ListRow(
                icon: Icons.folder_rounded,
                title: t.documents,
                onTap: () => context.push('/documents'),
              ),
              ListRow(
                icon: Icons.insights_rounded,
                title: t.adminPreview,
                onTap: () => context.push('/admin'),
                divider: false,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: AppText.caption.copyWith(color: AppColors.onNightMuted),
      ),
      Text(
        value,
        style: AppText.bodyStrong.copyWith(color: AppColors.onNight).tabular,
      ),
    ],
  );
}
