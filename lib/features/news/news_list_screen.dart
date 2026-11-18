import 'package:material_ui/material_ui.dart';

import '../../core/utils/format.dart';
import '../../core/widgets/ui.dart';
import '../../data/content.dart';
import 'widgets/news_widgets.dart';

class NewsListScreen extends StatelessWidget {
  const NewsListScreen({super.key});

  @override
  Widget build(BuildContext context) => AppScreen(
    back: true,
    title: context.t.latestNews,
    children: [
      for (final (i, item) in news.indexed)
        EnterFade(
          index: i,
          child: NewsCard(item: item),
        ),
    ],
  );
}
