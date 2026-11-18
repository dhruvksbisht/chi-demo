import 'dart:async';

import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/tokens.dart';
import '../utils/format.dart';

bool reduceMotion(BuildContext context) =>
    MediaQuery.disableAnimationsOf(context);

/// Tappable wrapper: scales to 0.97 while pressed, snaps back with ease-out, ticks a haptic.
/// Hit area is the child's size; callers keep that at 48dp or more.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    required this.onTap,
    this.label,
    this.selected,
    this.haptic = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final String? label;
  final bool? selected;
  final bool haptic;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool v) {
    if (widget.onTap != null && _down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return Semantics(
      button: true,
      enabled: enabled,
      selected: widget.selected,
      label: widget.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _set(true),
        onTapUp: (_) => _set(false),
        onTapCancel: () => _set(false),
        onTap: enabled
            ? () {
                if (widget.haptic) HapticFeedback.selectionClick();
                widget.onTap!();
              }
            : null,
        child: AnimatedScale(
          scale: _down ? 0.97 : 1,
          // Snap in while held, ease back out on release.
          duration: _down || reduceMotion(context)
              ? Duration.zero
              : Motion.press,
          curve: Motion.enter,
          child: widget.child,
        ),
      ),
    );
  }
}

/// Fades and lifts a list row in once, staggered by index (capped so long lists don't wait).
class EnterFade extends StatefulWidget {
  const EnterFade({super.key, required this.index, required this.child});
  final int index;
  final Widget child;

  @override
  State<EnterFade> createState() => _EnterFadeState();
}

class _EnterFadeState extends State<EnterFade>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: Motion.short);
  late final _curve = CurvedAnimation(parent: _c, curve: Motion.enter);
  Timer? _timer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_c.status != AnimationStatus.dismissed || _timer != null) return;
    if (reduceMotion(context)) {
      _c.value = 1;
    } else {
      _timer = Timer(Motion.stagger * widget.index.clamp(0, 8), _c.forward);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _curve,
    child: SlideTransition(
      position: Tween(
        begin: const Offset(0, 0.06),
        end: Offset.zero,
      ).animate(_curve),
      child: widget.child,
    ),
  );
}

/// Standard page: optional back/close, serif title, scrolling body, optional pinned footer.
class AppScreen extends StatelessWidget {
  const AppScreen({
    super.key,
    required this.title,
    required this.children,
    this.subtitle,
    this.back = false,
    this.modal = false,
    this.trailing,
    this.footer,
  });

  final String title;
  final String? subtitle;
  final bool back;
  final bool modal;
  final Widget? trailing;
  final Widget? footer;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final showBar = back || modal || trailing != null;
    return Scaffold(
      body: SafeArea(
        bottom: footer == null,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            Space.lg,
            Space.sm,
            Space.lg,
            Space.xxl,
          ),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            if (showBar)
              Padding(
                padding: const EdgeInsets.only(bottom: Space.md),
                child: Row(
                  children: [
                    if (back || modal)
                      IconBtn(
                        icon: modal
                            ? Icons.close_rounded
                            : Icons.arrow_back_rounded,
                        label: modal ? t.close : t.back,
                        onTap: () =>
                            context.canPop() ? context.pop() : context.go('/'),
                      ),
                    const Spacer(),
                    ?trailing,
                  ],
                ),
              ),
            Text(title, style: AppText.title),
            if (subtitle != null) ...[
              const SizedBox(height: Space.xs),
              Text(
                subtitle!,
                style: AppText.body.copyWith(color: AppColors.muted),
              ),
            ],
            const SizedBox(height: Space.xl),
            ...gap(children, Space.lg),
          ],
        ),
      ),
      bottomNavigationBar: footer == null
          ? null
          : DecoratedBox(
              decoration: const BoxDecoration(
                color: AppColors.bg,
                border: Border(top: BorderSide(color: AppColors.line)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Space.lg,
                    Space.md,
                    Space.lg,
                    Space.md,
                  ),
                  child: footer,
                ),
              ),
            ),
    );
  }
}

/// Interleaves [items] with fixed gaps.
List<Widget> gap(
  List<Widget> items,
  double size, {
  Axis axis = Axis.vertical,
}) => [
  for (var i = 0; i < items.length; i++) ...[
    if (i > 0)
      axis == Axis.vertical ? SizedBox(height: size) : SizedBox(width: size),
    items[i],
  ],
];

enum CardTone { surface, amber, night, sunken, danger }

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.tone = CardTone.surface,
    this.padding = const EdgeInsets.all(Space.lg),
    this.onTap,
    this.label,
  });

  final Widget child;
  final CardTone tone;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final String? label;

  static const _bg = {
    CardTone.surface: (AppColors.surface, AppColors.line),
    CardTone.amber: (AppColors.amberSoft, AppColors.amberLine),
    CardTone.night: (AppColors.night, AppColors.night),
    CardTone.sunken: (AppColors.sunken, AppColors.sunken),
    CardTone.danger: (AppColors.dangerSoft, AppColors.dangerLine),
  };

  @override
  Widget build(BuildContext context) {
    final (bg, border) = _bg[tone]!;
    final box = Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(color: border),
      ),
      padding: padding,
      child: child,
    );
    return onTap == null
        ? box
        : Pressable(onTap: onTap, label: label, child: box);
  }
}

enum ButtonKind { primary, secondary, ghost, danger }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.kind = ButtonKind.primary,
    this.icon,
    this.loading = false,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final ButtonKind kind;
  final IconData? icon;
  final bool loading;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final fg = kind == ButtonKind.danger ? AppColors.danger : AppColors.ink;
    final (bg, border) = switch (kind) {
      ButtonKind.primary => (AppColors.amber, AppColors.amber),
      ButtonKind.secondary => (AppColors.surface, AppColors.line),
      ButtonKind.ghost => (Colors.transparent, Colors.transparent),
      ButtonKind.danger => (AppColors.dangerSoft, AppColors.dangerSoft),
    };
    final inactive = onPressed == null || loading;
    return Semantics(
      enabled: !inactive,
      liveRegion: loading,
      child: Opacity(
        opacity: onPressed == null ? 0.45 : 1,
        child: Pressable(
          onTap: inactive ? null : onPressed,
          label: label,
          child: Container(
            constraints: BoxConstraints(minHeight: compact ? 44 : 52),
            padding: const EdgeInsets.symmetric(horizontal: Space.lg),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(Radii.md),
              border: Border.all(color: border),
            ),
            // Centre without Container.alignment, which would expand to fill a loose parent.
            child: Center(
              heightFactor: 1,
              child: AnimatedSwitcher(
                duration: Motion.short,
                child: loading
                    ? SizedBox(
                        key: const ValueKey('busy'),
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: fg,
                        ),
                      )
                    : Row(
                        key: const ValueKey('idle'),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (icon != null) ...[
                            Icon(icon, size: 20, color: fg),
                            const SizedBox(width: Space.sm),
                          ],
                          Flexible(
                            child: Text(
                              label,
                              style: AppText.bodyStrong.copyWith(color: fg),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Round 40dp icon button with a 48dp hit area.
class IconBtn extends StatelessWidget {
  const IconBtn({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge = false,
    this.onPhoto = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool badge;

  /// Translucent dark variant for use over photography.
  final bool onPhoto;

  @override
  Widget build(BuildContext context) => Pressable(
    onTap: onTap,
    label: label,
    child: SizedBox.square(
      dimension: 48,
      child: Center(
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: onPhoto ? const Color(0x59000000) : AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(
              color: onPhoto ? const Color(0x33FFFFFF) : AppColors.line,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: onPhoto ? AppColors.onNight : AppColors.ink,
              ),
              if (badge)
                Positioned(
                  top: 8,
                  right: 9,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: AppColors.danger,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surface, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Square amber tile holding a row icon.
class IconTile extends StatelessWidget {
  const IconTile(
    this.icon, {
    super.key,
    this.bg = AppColors.amberSoft,
    this.fg = AppColors.amberDeep,
    this.size = 36,
  });
  final IconData icon;
  final Color bg;
  final Color fg;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(Radii.sm),
    ),
    child: Icon(icon, size: size / 2, color: fg),
  );
}

/// A list row; stack several inside a zero-padding [AppCard] for a grouped list.
class ListRow extends StatelessWidget {
  const ListRow({
    super.key,
    required this.title,
    this.icon,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.divider = true,
    bool? chevron,
  }) : chevron = chevron ?? onTap != null;

  final String title;
  final IconData? icon;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool divider;
  final bool chevron;

  @override
  Widget build(BuildContext context) {
    final row = Container(
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsets.symmetric(horizontal: Space.lg, vertical: 14),
      decoration: BoxDecoration(
        border: divider
            ? const Border(
                bottom: BorderSide(color: AppColors.line, width: 0.5),
              )
            : null,
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            IconTile(icon!),
            const SizedBox(width: Space.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.bodyStrong),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: AppText.label.copyWith(color: AppColors.muted),
                  ),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: Space.md), trailing!],
          if (chevron) ...[
            const SizedBox(width: Space.sm),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.muted,
            ),
          ],
        ],
      ),
    );
    return onTap == null
        ? row
        : Pressable(onTap: onTap, label: title, child: row);
  }
}

class Section extends StatelessWidget {
  const Section({
    super.key,
    required this.title,
    required this.children,
    this.action,
    this.onAction,
  });
  final String title;
  final String? action;
  final VoidCallback? onAction;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: Space.xs),
        child: Row(
          children: [
            Expanded(child: Text(title, style: AppText.heading)),
            if (action != null && onAction != null)
              Pressable(
                onTap: onAction,
                label: action,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: Space.md,
                    horizontal: Space.xs,
                  ),
                  child: Text(
                    action!,
                    style: AppText.label.copyWith(color: AppColors.amberDeep),
                  ),
                ),
              ),
          ],
        ),
      ),
      const SizedBox(height: Space.sm),
      ...gap(children, Space.sm),
    ],
  );
}

enum BadgeTone { success, danger, amber, neutral, muted, info }

/// State-carrying pill (Active, Paid, Overdue, Manual). Never decorative.
class StatusBadge extends StatelessWidget {
  const StatusBadge(this.label, {super.key, this.tone = BadgeTone.neutral});
  final String label;
  final BadgeTone tone;

  static (Color, Color) colors(BadgeTone tone) => switch (tone) {
    BadgeTone.success => (AppColors.successSoft, AppColors.success),
    BadgeTone.danger => (AppColors.dangerSoft, AppColors.danger),
    BadgeTone.amber => (AppColors.amberSoft, AppColors.amberDeep),
    BadgeTone.neutral => (AppColors.sunken, AppColors.inkSoft),
    BadgeTone.muted => (AppColors.sunken, AppColors.muted),
    BadgeTone.info => (AppColors.infoSoft, AppColors.info),
  };

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = colors(tone);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Space.sm, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(Radii.pill),
      ),
      child: Text(
        label,
        style: AppText.caption.copyWith(color: fg, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class Segmented<T> extends StatelessWidget {
  const Segmented({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
  });
  final List<(T, String)> options;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(
      color: AppColors.sunken,
      borderRadius: BorderRadius.circular(Radii.md),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (v, label) in options)
          Pressable(
            onTap: () => onChanged(v),
            selected: v == value,
            label: label,
            child: AnimatedContainer(
              duration: reduceMotion(context) ? Duration.zero : Motion.short,
              curve: Motion.move,
              constraints: const BoxConstraints(minWidth: 44, minHeight: 36),
              padding: const EdgeInsets.symmetric(horizontal: Space.md),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                // Inner radius = outer radius (10) − padding (3).
                borderRadius: BorderRadius.circular(Radii.md - 3),
                color: v == value ? AppColors.surface : Colors.transparent,
                boxShadow: v == value
                    ? const [
                        BoxShadow(
                          color: Color(0x0F000000),
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                label,
                style: AppText.label.copyWith(
                  color: v == value ? AppColors.ink : AppColors.muted,
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

class AppField extends StatelessWidget {
  const AppField({
    super.key,
    required this.label,
    required this.controller,
    this.error,
    this.hint,
    this.keyboardType,
    this.obscure = false,
    this.capitalization = TextCapitalization.none,
    this.formatters,
    this.autofill,
    this.onChanged,
    this.textInputAction,
  });

  final String label;
  final TextEditingController controller;
  final String? error;
  final String? hint;
  final TextInputType? keyboardType;
  final bool obscure;
  final TextCapitalization capitalization;
  final List<TextInputFormatter>? formatters;
  final Iterable<String>? autofill;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color c) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(Radii.md),
      borderSide: BorderSide(color: c),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.label.copyWith(color: AppColors.inkSoft)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          textCapitalization: capitalization,
          inputFormatters: formatters,
          autofillHints: autofill,
          autocorrect: false,
          onChanged: onChanged,
          textInputAction: textInputAction,
          style: AppText.body,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppText.body.copyWith(color: AppColors.muted),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: Space.md,
              vertical: 14,
            ),
            enabledBorder: border(
              error != null ? AppColors.danger : AppColors.line,
            ),
            focusedBorder: border(
              error != null ? AppColors.danger : AppColors.amber,
            ),
            errorText: error,
            errorStyle: AppText.caption.copyWith(color: AppColors.danger),
            errorBorder: border(AppColors.danger),
            focusedErrorBorder: border(AppColors.danger),
          ),
        ),
      ],
    );
  }
}

/// Label/value line used in receipts and summaries.
class KV extends StatelessWidget {
  const KV(this.k, this.v, {super.key});
  final String k;
  final String v;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(k, style: AppText.label.copyWith(color: AppColors.muted)),
        const SizedBox(width: Space.lg),
        Expanded(
          child: Text(
            v,
            textAlign: TextAlign.right,
            style: AppText.label.copyWith(fontWeight: FontWeight.w600).tabular,
          ),
        ),
      ],
    ),
  );
}

class Toggle extends StatelessWidget {
  const Toggle({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
  });
  final bool value;
  final ValueChanged<bool> onChanged;
  final String label;

  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    child: Switch.adaptive(
      value: value,
      activeTrackColor: AppColors.amber,
      onChanged: (v) {
        HapticFeedback.selectionClick();
        onChanged(v);
      },
    ),
  );
}

/// Square check used for month selection and consent.
class CheckBox extends StatelessWidget {
  const CheckBox({super.key, required this.checked, this.error = false});
  final bool checked;
  final bool error;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: reduceMotion(context) ? Duration.zero : Motion.press,
    width: 24,
    height: 24,
    decoration: BoxDecoration(
      color: checked ? AppColors.amber : AppColors.surface,
      borderRadius: BorderRadius.circular(7),
      border: Border.all(
        width: 1.5,
        color: error
            ? AppColors.danger
            : (checked ? AppColors.amber : AppColors.line),
      ),
    ),
    child: checked
        ? const Icon(Icons.check_rounded, size: 16, color: AppColors.ink)
        : null,
  );
}

/// Rebuilds every [interval]; drives countdowns.
class NowBuilder extends StatefulWidget {
  const NowBuilder({
    super.key,
    required this.builder,
    this.interval = const Duration(seconds: 1),
  });
  final Widget Function(BuildContext context, DateTime now) builder;
  final Duration interval;

  @override
  State<NowBuilder> createState() => _NowBuilderState();
}

class _NowBuilderState extends State<NowBuilder> {
  late final Timer _timer = Timer.periodic(
    widget.interval,
    (_) => setState(() {}),
  );

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, DateTime.now());
}

Future<void> showInfo(BuildContext context, String title, String body) =>
    showAdaptiveDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog.adaptive(
        title: Text(title),
        content: Text(body),
        actions: [
          adaptiveAction(
            ctx,
            label: 'OK',
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );

Widget adaptiveAction(
  BuildContext context, {
  required String label,
  required VoidCallback onPressed,
}) => TextButton(
  onPressed: onPressed,
  child: Text(
    label,
    style: AppText.bodyStrong.copyWith(color: AppColors.amberDeep),
  ),
);
