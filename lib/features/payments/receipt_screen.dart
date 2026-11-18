import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/tokens.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/ui.dart';
import '../../data/app_state.dart';
import 'widgets/receipt_view.dart';

class ReceiptScreen extends ConsumerWidget {
  const ReceiptScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final p = ref.watch(
      appProvider.select(
        (s) => s.payments.where((x) => x.id == id).firstOrNull,
      ),
    );
    return AppScreen(
      back: true,
      title: p == null ? t.receiptNo : '${t.receiptNo} ${p.receiptNo}',
      children: [
        p == null
            ? Text(
                t.receiptNotFound,
                style: AppText.body.copyWith(color: AppColors.muted),
              )
            : ReceiptView(payment: p),
      ],
    );
  }
}
