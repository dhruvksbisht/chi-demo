import 'package:material_ui/material_ui.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/utils/format.dart';
import '../../../core/utils/receipt.dart';
import '../../../core/widgets/ui.dart';
import '../../../data/content.dart';
import '../../../data/models.dart';
import 'success_mark.dart';

/// Receipt details plus PDF download; shared by checkout success and payment history.
class ReceiptView extends StatefulWidget {
  const ReceiptView({super.key, required this.payment, this.onDone});
  final Payment payment;

  /// Set when the payment was just made: shows the success mark, email note and a way back.
  final VoidCallback? onDone;

  @override
  State<ReceiptView> createState() => _ReceiptViewState();
}

class _ReceiptViewState extends State<ReceiptView> {
  bool _busy = false;
  bool _error = false;

  Future<void> _download() async {
    setState(() {
      _busy = true;
      _error = false;
    });
    try {
      await shareReceipt(widget.payment);
    } catch (_) {
      if (mounted) setState(() => _error = true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final p = widget.payment;
    final fund = fundById(p.fund);
    final juice = p.method == PayMethod.juice;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: gap([
        if (widget.onDone != null) const Center(child: SuccessMark()),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${t.receiptNo} ${p.receiptNo}',
                      style: AppText.overline,
                    ),
                  ),
                  StatusBadge(
                    juice ? 'Juice' : t.manual,
                    tone: juice ? BadgeTone.success : BadgeTone.amber,
                  ),
                ],
              ),
              const SizedBox(height: Space.sm),
              Text(mur(p.amount), style: AppText.title.tabular),
              const SizedBox(height: Space.sm),
              p.kind == PaymentKind.subscription
                  ? KV(t.months, monthsLabel(p.monthKeys, context.lang))
                  : KV(t.fund, fund == null ? '–' : context.tr(fund.label)),
              KV(t.date, longDate(context.lang, ymdOf(p.date))),
              KV(t.method, methodLabel(t, p.method)),
              KV(t.reference, p.ref),
              if (!p.anonymous) KV(t.tabMember, member.number),
            ],
          ),
        ),
        AppButton(
          label: t.downloadReceipt,
          kind: ButtonKind.secondary,
          icon: Icons.download_rounded,
          loading: _busy,
          onPressed: _download,
        ),
        if (_error)
          Text(
            t.pdfError,
            style: AppText.caption.copyWith(color: AppColors.danger),
          ),
        if (widget.onDone != null) ...[
          AppButton(
            label: p.anonymous ? t.done : t.backToAccount,
            onPressed: widget.onDone,
          ),
          if (!p.anonymous)
            Text(
              '${t.emailCopy} ${member.email}',
              textAlign: TextAlign.center,
              style: AppText.caption.copyWith(color: AppColors.muted),
            ),
        ],
      ], Space.lg),
    );
  }
}
