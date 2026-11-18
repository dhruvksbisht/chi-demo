import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/tokens.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/photo.dart';
import '../../core/widgets/ui.dart';
import '../../data/content.dart';

void _open(String url) =>
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

String get _directionsUrl =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS
    ? 'https://maps.apple.com/?daddr=${Contacts.lat},${Contacts.lng}'
    : 'https://www.google.com/maps/dir/?api=1&destination=${Contacts.lat},${Contacts.lng}';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return AppScreen(
      title: t.tabContacts,
      subtitle: t.contactsSub,
      children: [
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(
                height: 200,
                child: Photo(Photos.jummahFront, alignment: Alignment(0, -0.3)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Space.lg,
                  Space.lg,
                  Space.lg,
                  Space.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(societyName, style: AppText.bodyStrong),
                    Text(
                      Contacts.address,
                      style: AppText.label.copyWith(color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Space.lg,
                  0,
                  Space.lg,
                  Space.lg,
                ),
                child: AppButton(
                  label: t.directions,
                  icon: Icons.directions_rounded,
                  onPressed: () => _open(_directionsUrl),
                ),
              ),
            ],
          ),
        ),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              ListRow(
                icon: Icons.call_rounded,
                title: t.call,
                subtitle: Contacts.phone,
                onTap: () => _open('tel:${Contacts.phone.replaceAll(' ', '')}'),
              ),
              ListRow(
                icon: Icons.chat_rounded,
                title: t.whatsapp,
                subtitle: Contacts.phone,
                onTap: () => _open('https://wa.me/${Contacts.whatsapp}'),
              ),
              ListRow(
                icon: Icons.mail_rounded,
                title: t.email,
                subtitle: Contacts.email,
                onTap: () => _open('mailto:${Contacts.email}'),
              ),
              ListRow(
                icon: Icons.schedule_rounded,
                title: t.officeHours,
                subtitle: context.tr(Contacts.hours),
                divider: false,
              ),
            ],
          ),
        ),
        Section(
          title: t.followUs,
          children: [
            Wrap(
              spacing: Space.sm,
              runSpacing: Space.sm,
              children: [
                for (final (label, url) in Contacts.social)
                  AppButton(
                    label: label,
                    kind: ButtonKind.secondary,
                    compact: true,
                    icon: Icons.open_in_new_rounded,
                    onPressed: () => _open(url),
                  ),
              ],
            ),
          ],
        ),
        AppButton(
          label: t.photoCredits,
          kind: ButtonKind.ghost,
          icon: Icons.photo_library_rounded,
          onPressed: () => context.push('/credits'),
        ),
      ],
    );
  }
}
