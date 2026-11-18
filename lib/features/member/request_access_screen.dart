import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/tokens.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/ui.dart';
import '../../data/app_state.dart';
import '../../data/models.dart';
import '../../data/validation.dart';
import '../payments/widgets/success_mark.dart';

class RequestAccessScreen extends ConsumerStatefulWidget {
  const RequestAccessScreen({super.key});

  @override
  ConsumerState<RequestAccessScreen> createState() =>
      _RequestAccessScreenState();
}

class _RequestAccessScreenState extends ConsumerState<RequestAccessScreen> {
  final _name = TextEditingController();
  final _nic = TextEditingController();
  final _mobile = TextEditingController();
  final _email = TextEditingController();
  final _memberNo = TextEditingController();
  bool _consent = false;
  Set<FieldError> _errors = {};
  bool _busy = false;
  bool _sent = false;

  @override
  void dispose() {
    for (final c in [_name, _nic, _mobile, _email, _memberNo]) {
      c.dispose();
    }
    super.dispose();
  }

  void _clear(FieldError e) {
    if (_errors.contains(e)) setState(() => _errors = {..._errors}..remove(e));
  }

  Future<void> _submit() async {
    final errors = validateRequest(
      name: _name.text,
      nic: _nic.text,
      mobile: _mobile.text,
      email: _email.text,
      consent: _consent,
    );
    setState(() => _errors = errors);
    if (errors.isNotEmpty) {
      HapticFeedback.heavyImpact();
      return;
    }
    setState(() => _busy = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    ref
        .read(appProvider.notifier)
        .submitRequest(
          AccessRequest(
            id: 'r${DateTime.now().millisecondsSinceEpoch}',
            name: _name.text.trim(),
            nic: normaliseNic(_nic.text),
            mobile: normaliseMobile(_mobile.text),
            email: _email.text.trim(),
            // Demo rule: a member number counts as a match. Production matches server-side
            // against the register by NIC and member number (FR-012).
            matched: _memberNo.text.trim().isNotEmpty,
            submitted: DateTime.now(),
          ),
        );
    HapticFeedback.mediumImpact();
    setState(() => _sent = true);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    if (_sent) {
      return AppScreen(
        modal: true,
        title: t.requestSent,
        children: [
          const Center(child: SuccessMark(icon: Icons.send_rounded)),
          Text(
            t.requestSentBody,
            textAlign: TextAlign.center,
            style: AppText.body.copyWith(color: AppColors.inkSoft),
          ),
          AppButton(label: t.done, onPressed: () => context.pop()),
          AppButton(
            label: t.adminPreview,
            kind: ButtonKind.ghost,
            icon: Icons.insights_rounded,
            onPressed: () => context.pushReplacement('/admin'),
          ),
        ],
      );
    }

    String? err(FieldError e, String msg) => _errors.contains(e) ? msg : null;
    return AppScreen(
      modal: true,
      title: t.requestAccess,
      subtitle: t.requestSub,
      children: [
        AppField(
          label: t.fullName,
          controller: _name,
          capitalization: TextCapitalization.words,
          autofill: const [AutofillHints.name],
          textInputAction: TextInputAction.next,
          error: err(FieldError.name, t.errName),
          onChanged: (_) => _clear(FieldError.name),
        ),
        AppField(
          label: t.nic,
          controller: _nic,
          hint: 'B1234567890123',
          capitalization: TextCapitalization.characters,
          textInputAction: TextInputAction.next,
          error: err(FieldError.nic, t.errNic),
          onChanged: (_) => _clear(FieldError.nic),
        ),
        AppField(
          label: t.mobile,
          controller: _mobile,
          hint: '5xxx xxxx',
          keyboardType: TextInputType.phone,
          autofill: const [AutofillHints.telephoneNumber],
          textInputAction: TextInputAction.next,
          error: err(FieldError.mobile, t.errMobile),
          onChanged: (_) => _clear(FieldError.mobile),
        ),
        AppField(
          label: t.email,
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          autofill: const [AutofillHints.email],
          textInputAction: TextInputAction.next,
          error: err(FieldError.email, t.errEmail),
          onChanged: (_) => _clear(FieldError.email),
        ),
        AppField(
          label: t.memberNo,
          controller: _memberNo,
          capitalization: TextCapitalization.characters,
          textInputAction: TextInputAction.done,
        ),
        Semantics(
          checked: _consent,
          child: Pressable(
            onTap: () {
              setState(() => _consent = !_consent);
              _clear(FieldError.consent);
            },
            label: t.consent,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: Space.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CheckBox(
                    checked: _consent,
                    error: _errors.contains(FieldError.consent),
                  ),
                  const SizedBox(width: Space.md),
                  Expanded(
                    child: Text(
                      t.consent,
                      style: AppText.label.copyWith(color: AppColors.inkSoft),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_errors.contains(FieldError.consent))
          Text(
            t.errConsent,
            style: AppText.caption.copyWith(color: AppColors.danger),
          ),
        AppButton(label: t.submit, loading: _busy, onPressed: _submit),
        AppCard(
          tone: CardTone.sunken,
          padding: const EdgeInsets.symmetric(
            horizontal: Space.lg,
            vertical: Space.md,
          ),
          child: Row(
            children: [
              const Icon(
                Icons.shield_rounded,
                size: 18,
                color: AppColors.muted,
              ),
              const SizedBox(width: Space.sm),
              Expanded(
                child: Text(
                  t.nicNote,
                  style: AppText.caption.copyWith(color: AppColors.muted),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
