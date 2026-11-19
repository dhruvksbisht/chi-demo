import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/tokens.dart';
import '../../core/utils/connectivity.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/photo.dart';
import '../../core/widgets/ui.dart';
import '../../data/content.dart';
import '../../data/validation.dart';
import '../payments/checkout_screen.dart';

const _presets = [250, 500, 1000, 2500];
const _min = 50;
const _max = 500000;

class DonateScreen extends ConsumerStatefulWidget {
  const DonateScreen({super.key});

  @override
  ConsumerState<DonateScreen> createState() => _DonateScreenState();
}

class _DonateScreenState extends ConsumerState<DonateScreen> {
  Fund _fund = funds.first;
  final _amount = TextEditingController(text: '500');

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final value = parseRupees(_amount.text) ?? 0;
    final valid = value >= _min && value <= _max;
    final online = ref.isOnline;

    Widget choice(String label, bool on, VoidCallback onTap) => Pressable(
      onTap: onTap,
      selected: on,
      label: label,
      child: AnimatedContainer(
        duration: reduceMotion(context) ? Duration.zero : Motion.press,
        constraints: const BoxConstraints(minHeight: 56),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: Space.sm),
        decoration: BoxDecoration(
          color: on ? AppColors.amberSoft : AppColors.surface,
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(
            width: 1.5,
            color: on ? AppColors.amber : AppColors.line,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppText.bodyStrong
              .copyWith(color: on ? AppColors.ink : AppColors.inkSoft)
              .tabular,
        ),
      ),
    );

    Widget grid(List<Widget> items) => LayoutBuilder(
      builder: (context, c) {
        final w = (c.maxWidth - Space.sm) / 2;
        return Wrap(
          spacing: Space.sm,
          runSpacing: Space.sm,
          children: [for (final i in items) SizedBox(width: w, child: i)],
        );
      },
    );

    return PhotoScreen(
      photo: const Photo(
        Photos.jummahCourtyard,
        alignment: Alignment(0, -0.3),
        scrim: Scrims.both,
      ),
      height: 260,
      title: t.donate,
      subtitle: t.donateSub,
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!online) ...[
            OfflineNote(t.offlinePay),
            const SizedBox(height: Space.sm),
          ],
          AppButton(
            label: valid ? '${t.donateNow} · ${mur(value)}' : t.donateNow,
            icon: Icons.volunteer_activism_rounded,
            onPressed: valid && online
                ? () => context.push(
                    '/checkout',
                    extra: CheckoutRequest.donation(fund: _fund, amount: value),
                  )
                : null,
          ),
        ],
      ),
      children: [
        Section(
          title: t.fund,
          children: [
            grid([
              for (final f in funds)
                choice(
                  context.tr(f.label),
                  f.id == _fund.id,
                  () => setState(() => _fund = f),
                ),
            ]),
          ],
        ),
        Section(
          title: t.amount,
          children: [
            grid([
              for (final p in _presets)
                choice(
                  mur(p),
                  value == p,
                  () => setState(() => _amount.text = '$p'),
                ),
            ]),
            AppField(
              label: 'MUR',
              controller: _amount,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              formatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d., ]')),
              ],
              error: valid || _amount.text.isEmpty
                  ? null
                  : hasCents(_amount.text)
                  ? t.wholeRupees
                  : '${mur(_min)} – ${mur(_max)}',
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ],
    );
  }
}
