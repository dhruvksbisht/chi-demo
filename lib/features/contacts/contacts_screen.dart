import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/tokens.dart';
import '../../core/utils/format.dart';
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
                height: 160,
                child: CustomPaint(painter: _MapPainter()),
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
      ],
    );
  }
}

/// Stylised, offline-safe map; the button hands off to the device's maps app.
class _MapPainter extends CustomPainter {
  const _MapPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Scale a 340 x 170 drawing to cover the box.
    final s = (size.width / 340) > (size.height / 170)
        ? size.width / 340
        : size.height / 170;
    canvas.drawRect(Offset.zero & size, Paint()..color = AppColors.sunken);
    canvas.translate((size.width - 340 * s) / 2, (size.height - 170 * s) / 2);
    canvas.scale(s);
    canvas.drawPath(
      Path()
        ..moveTo(0, 120)
        ..cubicTo(60, 100, 90, 150, 160, 130)
        ..cubicTo(230, 110, 270, 90, 340, 110)
        ..lineTo(340, 170)
        ..lineTo(0, 170)
        ..close(),
      Paint()..color = const Color(0xFFDCE9F0),
    );
    final road = Paint()
      ..color = AppColors.surface
      ..strokeWidth = 7;
    canvas.drawLine(const Offset(20, 0), const Offset(120, 170), road);
    canvas.drawLine(const Offset(0, 60), const Offset(340, 40), road);
    canvas.drawLine(const Offset(200, 0), const Offset(240, 170), road);
    canvas.drawLine(const Offset(290, 0), const Offset(260, 170), road);
    canvas.drawLine(
      const Offset(0, 90),
      const Offset(340, 75),
      road..strokeWidth = 11,
    );
    canvas.drawCircle(
      const Offset(175, 78),
      22,
      Paint()..color = AppColors.amber.withValues(alpha: 0.25),
    );
    canvas.drawCircle(
      const Offset(175, 78),
      9,
      Paint()..color = AppColors.amber,
    );
    canvas.drawCircle(
      const Offset(175, 78),
      9,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = AppColors.ink,
    );
  }

  @override
  bool shouldRepaint(_MapPainter old) => false;
}
