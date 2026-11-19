import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/tokens.dart';
import '../../core/utils/connectivity.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/ui.dart';
import '../../data/app_state.dart';
import '../../data/content.dart';
import '../../data/models.dart';
import 'widgets/receipt_view.dart';

/// What the member is about to pay for. Passed to the checkout route as `extra`.
class CheckoutRequest {
  const CheckoutRequest.subscription({
    required this.months,
    required this.amount,
  }) : kind = PaymentKind.subscription,
       fund = null;
  const CheckoutRequest.donation({
    required Fund this.fund,
    required this.amount,
  }) : kind = PaymentKind.donation,
       months = const [];

  final PaymentKind kind;
  final List<String> months;
  final Fund? fund;
  final int amount;

  bool get valid =>
      amount > 0 &&
      (kind == PaymentKind.donation ? fund != null : months.isNotEmpty);
}

/// Simulated Juice by MCB checkout (sandbox). It walks through the real sequence: the member
/// authorises in Juice, then the back end confirms with MCB server-to-server (PAY-03) before any
/// month is marked paid or a receipt issued. Every run ends in success, declined or pending (PAY-02).
enum _Stage { review, auth, server, receipt, declined }

const _stepMs = Duration(milliseconds: 1100);

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key, required this.request});
  final CheckoutRequest? request;

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  bool _approve = true;
  _Stage _stage = _Stage.review;
  Payment? _paid;
  final _timers = <Timer>[];

  @override
  void dispose() {
    for (final t in _timers) {
      t.cancel();
    }
    super.dispose();
  }

  void _after(Duration d, VoidCallback fn) => _timers.add(
    Timer(d, () {
      if (mounted) fn();
    }),
  );

  void _confirm(CheckoutRequest r) {
    setState(() => _stage = _Stage.auth);
    if (!_approve) {
      _after(_stepMs, () {
        HapticFeedback.heavyImpact();
        setState(() => _stage = _Stage.declined);
      });
      return;
    }
    _after(_stepMs, () => setState(() => _stage = _Stage.server));
    _after(_stepMs * 2, () => setState(() => _stage = _Stage.receipt));
    _after(_stepMs * 2 + const Duration(milliseconds: 600), () {
      final payment = Payment(
        id: 'p${DateTime.now().millisecondsSinceEpoch}',
        receiptNo: newReceiptNo(),
        ref: newJuiceRef(),
        kind: r.kind,
        method: PayMethod.juice,
        amount: r.amount,
        monthKeys: r.months,
        fund: r.fund?.id,
        date: DateTime.now().toUtc(),
        anonymous:
            r.kind == PaymentKind.donation && !ref.read(appProvider).loggedIn,
      );
      ref.read(appProvider.notifier).confirmPayment(payment);
      setState(() => _paid = payment); // success shown in place
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final r = widget.request;

    final paid = _paid;
    if (paid != null) {
      return AppScreen(
        title: paid.kind == PaymentKind.donation
            ? t.donationReceived
            : t.paymentSuccessful,
        children: [
          ReceiptView(
            payment: paid,
            onDone: () => context.go(paid.anonymous ? '/' : '/member'),
          ),
        ],
      );
    }
    if (r == null || !r.valid) {
      return AppScreen(
        modal: true,
        title: t.checkout,
        children: [
          Text(
            t.invalidPayment,
            style: AppText.body.copyWith(color: AppColors.danger),
          ),
        ],
      );
    }

    final busy = _stage != _Stage.review && _stage != _Stage.declined;
    final online = ref.isOnline;
    final steps = [
      (_Stage.auth, t.stepAuth),
      (_Stage.server, t.stepServer),
      (_Stage.receipt, t.stepReceipt),
    ];
    final activeIdx = steps.indexWhere((s) => s.$1 == _stage);
    final description = r.kind == PaymentKind.donation
        ? context.tr(r.fund!.label)
        : monthsLabel(r.months, context.lang);

    return PopScope(
      canPop: !busy, // never abandon a payment mid-confirmation
      child: AppScreen(
        modal: !busy,
        title: t.checkout,
        trailing: StatusBadge(t.sandbox, tone: BadgeTone.info),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Space.md,
                    vertical: Space.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.ink,
                    borderRadius: BorderRadius.circular(Radii.sm),
                  ),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Juice ',
                          style: AppText.bodyStrong.copyWith(
                            color: AppColors.surface,
                          ),
                        ),
                        TextSpan(
                          text: 'by MCB',
                          style: AppText.caption.copyWith(
                            color: AppColors.surface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: Space.lg),
                Text(t.amount, style: AppText.overline),
                Text(mur(r.amount), style: AppText.hero.tabular),
                const SizedBox(height: Space.md),
                const Divider(color: AppColors.line, height: 1),
                const SizedBox(height: Space.sm),
                KV(t.merchant, societyName),
                KV(
                  r.kind == PaymentKind.donation ? t.fund : t.months,
                  description,
                ),
              ],
            ),
          ),
          AnimatedSwitcher(
            duration: reduceMotion(context) ? Duration.zero : Motion.short,
            switchInCurve: Motion.enter,
            switchOutCurve: Motion.exit,
            child: switch (_stage) {
              _Stage.review => Column(
                key: const ValueKey('review'),
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: gap([
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          t.outcome,
                          style: AppText.label.copyWith(color: AppColors.muted),
                        ),
                      ),
                      Segmented<bool>(
                        options: [(true, t.approve), (false, t.decline)],
                        value: _approve,
                        onChanged: (v) => setState(() => _approve = v),
                      ),
                    ],
                  ),
                  if (!online) OfflineNote(t.offlinePay),
                  AppButton(
                    label: t.confirmPay,
                    icon: Icons.lock_rounded,
                    onPressed: online ? () => _confirm(r) : null,
                  ),
                  AppButton(
                    label: t.cancel,
                    kind: ButtonKind.ghost,
                    onPressed: () => context.pop(),
                  ),
                ], Space.lg),
              ),
              _Stage.declined => Column(
                key: const ValueKey('declined'),
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: gap([
                  AppCard(
                    tone: CardTone.danger,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.cancel_rounded,
                          color: AppColors.danger,
                        ),
                        const SizedBox(width: Space.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t.declined,
                                style: AppText.bodyStrong.copyWith(
                                  color: AppColors.danger,
                                ),
                              ),
                              Text(
                                t.declinedBody,
                                style: AppText.label.copyWith(
                                  color: AppColors.inkSoft,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppButton(
                    label: t.tryAgain,
                    onPressed: () => setState(() {
                      _approve = true;
                      _stage = _Stage.review;
                    }),
                  ),
                ], Space.lg),
              ),
              _ => AppCard(
                key: const ValueKey('steps'),
                child: Semantics(
                  liveRegion: true,
                  child: Column(
                    children: [
                      for (final (i, (_, label)) in steps.indexed)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: Space.sm,
                          ),
                          child: Row(
                            children: [
                              _StepDot(
                                done: i < activeIdx,
                                active: i == activeIdx,
                              ),
                              const SizedBox(width: Space.md),
                              Expanded(
                                child: Text(
                                  label,
                                  style:
                                      (i == activeIdx
                                              ? AppText.bodyStrong
                                              : AppText.body)
                                          .copyWith(
                                            color: i <= activeIdx
                                                ? AppColors.ink
                                                : AppColors.muted,
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
            },
          ),
        ],
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({required this.done, required this.active});
  final bool done;
  final bool active;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: reduceMotion(context) ? Duration.zero : Motion.short,
    width: 26,
    height: 26,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: done ? AppColors.success : Colors.transparent,
      border: Border.all(
        width: 1.5,
        color: done ? AppColors.success : AppColors.line,
      ),
    ),
    child: AnimatedSwitcher(
      duration: reduceMotion(context) ? Duration.zero : Motion.short,
      child: done
          ? const Icon(
              Icons.check_rounded,
              key: ValueKey('done'),
              size: 16,
              color: AppColors.surface,
            )
          : active
          ? const Padding(
              key: ValueKey('busy'),
              padding: EdgeInsets.all(5),
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const SizedBox.shrink(),
    ),
  );
}
