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

/// One list, the president first and set larger. Initials stand in for portraits until CHI
/// supplies them; colour stays neutral so roles, not decoration, carry the hierarchy.
class CommitteeScreen extends StatelessWidget {
  const CommitteeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return AppScreen(
      title: t.tabCommittee,
      subtitle: t.committeeSub(committee.length),
      children: [
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (final (i, m) in committee.indexed)
                _MemberRow(
                  member: m,
                  lead: i == 0,
                  divider: i < committee.length - 1,
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Space.xs),
          child: Text(
            t.committeeConsent,
            style: AppText.caption.copyWith(color: AppColors.muted),
          ),
        ),
      ],
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({
    required this.member,
    required this.lead,
    required this.divider,
  });
  final CommitteeMember member;
  final bool lead;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    final role = context.tr(member.role);
    return Container(
      padding: EdgeInsets.fromLTRB(
        Space.lg,
        lead ? Space.lg : Space.md,
        Space.sm,
        lead ? Space.lg : Space.md,
      ),
      decoration: BoxDecoration(
        border: divider
            ? const Border(
                bottom: BorderSide(color: AppColors.line, width: 0.5),
              )
            : null,
      ),
      child: Row(
        children: [
          _Avatar(member.name, size: lead ? 56 : 40),
          const SizedBox(width: Space.lg),
          Expanded(
            child: lead
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(role, style: AppText.overline),
                      Text(member.name, style: AppText.heading),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(member.name, style: AppText.bodyMedium),
                      Text(
                        role,
                        style: AppText.label.copyWith(
                          color: AppColors.muted,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
          ),
          if (member.phone case final phone?)
            IconBtn(
              bare: true,
              icon: Icons.call_rounded,
              label: '${context.t.call} ${member.name}',
              onTap: () => launchUrl(Uri.parse('tel:$phone')),
            ),
          if (member.email case final email?)
            IconBtn(
              bare: true,
              icon: Icons.mail_rounded,
              label: '${context.t.email} ${member.name}',
              onTap: () => launchUrl(Uri.parse('mailto:$email')),
            ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar(this.name, {required this.size});
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.sunken,
        shape: BoxShape.circle,
      ),
      child: Text(
        _initials(name),
        style: (size > 48 ? AppText.heading : AppText.bodyStrong).copyWith(
          fontFamily: Fonts.display,
          color: AppColors.inkSoft,
        ),
      ),
    ),
  );
}
