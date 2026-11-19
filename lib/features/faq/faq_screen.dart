import 'package:material_ui/material_ui.dart';

import '../../core/theme/tokens.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/ui.dart';
import '../../data/content.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  final _query = TextEditingController();
  FaqCategory? _category; // null = all
  int? _open = 0;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final q = _query.text.trim().toLowerCase();
    bool matches(Faq f) =>
        (_category == null || f.category == _category) &&
        (q.isEmpty ||
            '${context.tr(f.q)} ${context.tr(f.a)}'.toLowerCase().contains(q));

    // Grouped by category (Miller's law): short lists under a quiet heading.
    final groups = [
      for (final c in FaqCategory.values)
        (
          category: c,
          items: [
            for (final (i, f) in faqs.indexed)
              if (f.category == c && matches(f)) (i, f),
          ],
        ),
    ].where((g) => g.items.isNotEmpty).toList();

    return AppScreen(
      title: t.tabFaq,
      children: [
        _SearchField(
          controller: _query,
          label: t.searchQuestions,
          hint: t.searchHint,
          onChanged: () => setState(() {}),
        ),
        _Chips<FaqCategory?>(
          options: [
            (null, t.all),
            for (final c in FaqCategory.values) (c, context.tr(c.label)),
          ],
          value: _category,
          onChanged: (c) => setState(() => _category = c),
        ),
        if (groups.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Space.xl),
            child: Text(
              t.noResults,
              textAlign: TextAlign.center,
              style: AppText.body.copyWith(color: AppColors.muted),
            ),
          ),
        for (final g in groups)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Space.xs,
                  Space.sm,
                  Space.xs,
                  Space.sm,
                ),
                child: Text(
                  context.tr(g.category.label),
                  style: AppText.overline,
                ),
              ),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (final (n, (i, f)) in g.items.indexed)
                      _FaqItem(
                        question: context.tr(f.q),
                        answer: context.tr(f.a),
                        expanded: _open == i,
                        divider: n < g.items.length - 1,
                        onTap: () =>
                            setState(() => _open = _open == i ? null : i),
                      ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.onChanged,
  });
  final TextEditingController controller;
  final String label;
  final String hint;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    const border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(Radii.md)),
      borderSide: BorderSide.none,
    );
    return Semantics(
      label: label,
      textField: true,
      child: TextField(
        controller: controller,
        onChanged: (_) => onChanged(),
        textInputAction: TextInputAction.search,
        style: AppText.body,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppText.body.copyWith(color: AppColors.muted),
          prefixIcon: const Icon(
            Icons.search_rounded,
            size: 20,
            color: AppColors.muted,
          ),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  tooltip: context.t.close,
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: AppColors.muted,
                  ),
                  onPressed: () {
                    controller.clear();
                    onChanged();
                  },
                ),
          filled: true,
          fillColor: AppColors.sunken,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: border,
          enabledBorder: border,
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(Radii.md)),
            borderSide: BorderSide(color: AppColors.amber, width: 1.5),
          ),
        ),
      ),
    );
  }
}

/// Category filter. Unselected chips are quiet; the current one is the amber state.
class _Chips<T> extends StatelessWidget {
  const _Chips({
    required this.options,
    required this.value,
    required this.onChanged,
  });
  final List<(T, String)> options;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 48,
    child: ListView(
      scrollDirection: Axis.horizontal,
      // Chips scroll out to the screen edge instead of being cut at the page margin.
      clipBehavior: Clip.none,
      children: gap(
        [
          for (final (v, label) in options)
            Pressable(
              onTap: () => onChanged(v),
              selected: v == value,
              label: label,
              child: Center(
                child: AnimatedContainer(
                  duration: reduceMotion(context)
                      ? Duration.zero
                      : Motion.short,
                  height: 36,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: Space.lg),
                  decoration: BoxDecoration(
                    color: v == value ? AppColors.amber : Colors.transparent,
                    borderRadius: BorderRadius.circular(Radii.pill),
                    border: Border.all(
                      color: v == value ? AppColors.amber : AppColors.line,
                    ),
                  ),
                  child: Text(
                    label,
                    style: AppText.label.copyWith(
                      color: v == value ? AppColors.ink : AppColors.inkSoft,
                      fontWeight: v == value
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
        ],
        Space.sm,
        axis: Axis.horizontal,
      ),
    ),
  );
}

class _FaqItem extends StatelessWidget {
  const _FaqItem({
    required this.question,
    required this.answer,
    required this.expanded,
    required this.divider,
    required this.onTap,
  });
  final String question;
  final String answer;
  final bool expanded;
  final bool divider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final duration = reduceMotion(context) ? Duration.zero : Motion.short;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: divider
            ? const Border(
                bottom: BorderSide(color: AppColors.line, width: 0.5),
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            expanded: expanded,
            child: Pressable(
              onTap: onTap,
              label: question,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  Space.lg,
                  Space.lg,
                  Space.md,
                  Space.lg,
                ),
                child: Row(
                  children: [
                    Expanded(child: Text(question, style: AppText.bodyMedium)),
                    const SizedBox(width: Space.md),
                    AnimatedRotation(
                      turns: expanded ? 0.5 : 0,
                      duration: duration,
                      curve: Motion.move,
                      child: const Icon(
                        Icons.expand_more_rounded,
                        size: 22,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Reveal by clipping the answer's height rather than sliding it in.
          AnimatedSize(
            duration: duration,
            curve: Motion.move,
            alignment: Alignment.topCenter,
            child: expanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(
                      Space.lg,
                      0,
                      Space.xxl,
                      Space.lg,
                    ),
                    child: Text(
                      answer,
                      style: AppText.body.copyWith(color: AppColors.inkSoft),
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}
