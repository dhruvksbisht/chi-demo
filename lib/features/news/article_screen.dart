import 'package:material_ui/material_ui.dart';

import '../../core/theme/tokens.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/photo.dart';
import '../../core/widgets/ui.dart';
import '../../data/content.dart';
import 'widgets/news_widgets.dart';

class ArticleScreen extends StatelessWidget {
  const ArticleScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final item = news.where((n) => n.id == id).firstOrNull;
    if (item == null) {
      return AppScreen(
        back: true,
        title: t.notFound,
        children: [
          Text(
            t.articleGone,
            style: AppText.body.copyWith(color: AppColors.muted),
          ),
        ],
      );
    }
    return PhotoScreen(
      photo: NewsPhoto(item: item, scrim: Scrims.both),
      eyebrow: KindTag(item.kind),
      title: context.tr(item.title),
      subtitle: ago(t, item.daysAgo),
      children: [
        Text(
          context.tr(item.body),
          style: AppText.body.copyWith(fontSize: 17, height: 27 / 17),
        ),
      ],
    );
  }
}
