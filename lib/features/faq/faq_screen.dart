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
    final visible = [
      for (final (i, f) in faqs.indexed)
        if ((_category == null || f.category == _category) &&
            (q.isEmpty ||
                '${context.tr(f.q)} ${context.tr(f.a)}'.toLowerCase().contains(
                  q,
                )))
          (i, f),
    ];
    final chips = <(FaqCategory?, String)>[
      (null, t.all),
      for (final c in FaqCategory.values) (c, context.tr(c.label)),
    ];

    return AppScreen(
      title: t.tabFaq,
      subtitle: t.faqSub,
      children: [
        AppField(
          label: t.searchQuestions,
          controller: _query,
          hint: t.searchHint,
          textInputAction: TextInputAction.search,
          onChanged: (_) => setState(() {}),
        ),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: gap(
              [
                for (final (c, label) in chips)
                  Pressable(
                    onTap: () => setState(() => _category = c),
                    selected: c == _category,
                    label: label,
                    child: AnimatedContainer(
                      duration: reduceMotion(context)
                          ? Duration.zero
                          : Motion.short,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: Space.lg),
                      decoration: BoxDecoration(
                        color: c == _category
                            ? AppColors.amberSoft
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(Radii.pill),
                        border: Border.all(
                          color: c == _category
                              ? AppColors.amber
                              : AppColors.line,
                        ),
                      ),
                      child: Text(
                        label,
                        style: AppText.label.copyWith(
                          color: c == _category
                              ? AppColors.ink
                              : AppColors.inkSoft,
                        ),
                      ),
                    ),
                  ),
              ],
              Space.sm,
              axis: Axis.horizontal,
            ),
          ),
        ),
        if (visible.isEmpty)
          Text(
            t.noResults,
            style: AppText.body.copyWith(color: AppColors.muted),
          ),
        Column(
          children: gap([
            for (final (i, f) in visible)
              _FaqItem(
                question: context.tr(f.q),
                answer: context.tr(f.a),
                expanded: _open == i,
                onTap: () => setState(() => _open = _open == i ? null : i),
              ),
          ], Space.sm),
        ),
      ],
    );
  }
}

class _FaqItem extends StatelessWidget {
  const _FaqItem({
    required this.question,
    required this.answer,
    required this.expanded,
    required this.onTap,
  });
  final String question;
  final String answer;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final duration = reduceMotion(context) ? Duration.zero : Motion.short;
    return AnimatedContainer(
      duration: duration,
      curve: Motion.move,
      decoration: BoxDecoration(
        color: expanded ? AppColors.amberSoft : AppColors.surface,
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(
          color: expanded ? AppColors.amberLine : AppColors.line,
        ),
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
                padding: const EdgeInsets.all(Space.lg),
                child: Row(
                  children: [
                    Expanded(child: Text(question, style: AppText.bodyStrong)),
                    const SizedBox(width: Space.md),
                    AnimatedRotation(
                      turns: expanded ? 0.125 : 0,
                      duration: duration,
                      curve: Motion.move,
                      child: const Icon(
                        Icons.add_rounded,
                        size: 22,
                        color: AppColors.amberDeep,
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
                      Space.lg,
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
