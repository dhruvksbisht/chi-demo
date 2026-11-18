import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/tokens.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/ui.dart';
import '../../data/content.dart';

String _initials(String name) => name
    .replaceFirst(RegExp(r'^Haji\s+'), '')
    .split(' ')
    .take(2)
    .map((p) => p[0])
    .join();

class CommitteeScreen extends StatelessWidget {
  const CommitteeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final lead = committee.first;
    final rest = committee.skip(1).toList();
    return AppScreen(
      title: t.tabCommittee,
      subtitle: t.committeeSub,
      children: [
        AppCard(
          tone: CardTone.amber,
          child: Row(
            children: [
              _Avatar(lead.name, size: 60, bg: AppColors.surface),
              const SizedBox(width: Space.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr(lead.role),
                      style: AppText.overline.copyWith(
                        color: AppColors.amberDeep,
                      ),
                    ),
                    Text(lead.name, style: AppText.heading),
                  ],
                ),
              ),
              _Contact(phone: lead.phone, email: lead.email),
            ],
          ),
        ),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (final (i, m) in rest.indexed)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Space.lg,
                    vertical: Space.md,
                  ),
                  decoration: BoxDecoration(
                    border: i < rest.length - 1
                        ? const Border(
                            bottom: BorderSide(
                              color: AppColors.line,
                              width: 0.5,
                            ),
                          )
                        : null,
                  ),
                  child: Row(
                    children: [
                      _Avatar(m.name),
                      const SizedBox(width: Space.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(m.name, style: AppText.bodyStrong),
                            Text(
                              context.tr(m.role),
                              style: AppText.label.copyWith(
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _Contact(phone: m.phone, email: m.email),
                    ],
                  ),
                ),
            ],
          ),
        ),
        Text(
          t.committeeConsent,
          textAlign: TextAlign.center,
          style: AppText.caption.copyWith(color: AppColors.muted),
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar(this.name, {this.size = 44, this.bg = AppColors.amberSoft});
  final String name;
  final double size;
  final Color bg;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Text(
        _initials(name),
        style:
            (size > 50
                    ? AppText.heading
                    : AppText.label.copyWith(fontWeight: FontWeight.w600))
                .copyWith(color: AppColors.amberDeep),
      ),
    ),
  );
}

class _Contact extends StatelessWidget {
  const _Contact({this.phone, this.email});
  final String? phone;
  final String? email;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (phone != null)
        IconBtn(
          icon: Icons.call_rounded,
          label: context.t.call,
          onTap: () => launchUrl(Uri.parse('tel:$phone')),
        ),
      if (email != null)
        IconBtn(
          icon: Icons.mail_rounded,
          label: context.t.email,
          onTap: () => launchUrl(Uri.parse('mailto:$email')),
        ),
    ],
  );
}
