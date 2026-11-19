import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/format.dart';
import '../../core/utils/time.dart';
import '../../core/widgets/photo.dart';
import '../../core/widgets/ui.dart';
import '../../data/content.dart';
import '../../data/models.dart';

void _open(String url) =>
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

String get _directionsUrl =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS
    ? 'https://maps.apple.com/?daddr=${Contacts.lat},${Contacts.lng}'
    : 'https://www.google.com/maps/dir/?api=1&destination=${Contacts.lat},${Contacts.lng}';

/// Office open Monday–Friday, [_opens]–[_closes] Mauritius time.
const _opens = 9;
const _closes = 16;

/// "Open now · until 16:00" or "Closed · opens Mon 09:00", in Mauritius time.
String officeStatus(AppLocalizations t, Lang lang, DateTime now) {
  final mu = now.toUtc().add(muOffset);
  bool workday(int weekday) => weekday <= DateTime.friday;
  final open = workday(mu.weekday) && mu.hour >= _opens && mu.hour < _closes;
  if (open) return t.openUntil('$_closes:00');

  final opensToday = workday(mu.weekday) && mu.hour < _opens;
  if (opensToday) return t.opensAt('0$_opens:00');
  var day = muToday(now);
  do {
    day = addDays(day, 1);
  } while (!workday(DateTime.utc(day.y, day.m, day.d).weekday));
  final weekday = capitalize(weekdayName(lang, day).substring(0, 3));
  return t.opensAt('$weekday 0$_opens:00');
}

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final phoneDigits = Contacts.phone.replaceAll(' ', '');
    return AppScreen(
      title: t.tabContacts,
      subtitle: Contacts.address,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(Radii.lg),
          child: const SizedBox(
            height: 200,
            child: Photo(Photos.jummahFront, alignment: Alignment(0, -0.3)),
          ),
        ),
        AppButton(
          label: t.directions,
          icon: Icons.directions_rounded,
          onPressed: () => _open(_directionsUrl),
        ),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              ListRow(
                icon: Icons.call_rounded,
                title: Contacts.phone,
                subtitle: t.callOrWhatsapp,
                chevron: false,
                onTap: () => _open('tel:$phoneDigits'),
                trailing: IconBtn(
                  bare: true,
                  icon: Icons.chat_rounded,
                  label: t.whatsapp,
                  onTap: () => _open('https://wa.me/${Contacts.whatsapp}'),
                ),
              ),
              ListRow(
                icon: Icons.mail_rounded,
                title: Contacts.email,
                subtitle: t.email,
                onTap: () => _open('mailto:${Contacts.email}'),
              ),
              NowBuilder(
                interval: const Duration(minutes: 1),
                builder: (context, now) => ListRow(
                  icon: Icons.schedule_rounded,
                  title: officeStatus(t, context.lang, now),
                  subtitle: context.tr(Contacts.hours),
                  divider: false,
                ),
              ),
            ],
          ),
        ),
        Section(
          title: t.followUs,
          children: [
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (final (i, (label, url)) in Contacts.social.indexed)
                    ListRow(
                      title: label,
                      chevron: false,
                      divider: i < Contacts.social.length - 1,
                      trailing: const Icon(
                        Icons.north_east_rounded,
                        size: 18,
                        color: AppColors.muted,
                      ),
                      onTap: () => _open(url),
                    ),
                ],
              ),
            ),
          ],
        ),
        Center(
          child: AppButton(
            label: t.photoCredits,
            kind: ButtonKind.ghost,
            compact: true,
            onPressed: () => context.push('/credits'),
          ),
        ),
      ],
    );
  }
}
