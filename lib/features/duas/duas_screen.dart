import 'package:material_ui/material_ui.dart';

import '../../core/theme/tokens.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/ui.dart';
import '../../data/content.dart';

class DuasScreen extends StatelessWidget {
  const DuasScreen({super.key});

  @override
  Widget build(BuildContext context) => AppScreen(
    back: true,
    title: context.t.duas,
    children: [
      for (final d in duas)
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: gap([
              Text(
                context.tr(d.title),
                style: AppText.overline.copyWith(color: AppColors.amberDeep),
              ),
              Text(
                d.arabic,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: AppText.arabic,
              ),
              // Italic only for transliteration.
              Text(
                d.translit,
                style: AppText.label.copyWith(
                  fontFamily: Fonts.display,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w400,
                  color: AppColors.inkSoft,
                ),
              ),
              Text(context.tr(d.meaning), style: AppText.body),
              Text(
                d.source,
                style: AppText.caption.copyWith(color: AppColors.muted),
              ),
            ], Space.sm),
          ),
        ),
    ],
  );
}
