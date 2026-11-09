import { NewsCard } from '@/components/NewsCard';
import { Screen } from '@/components/ui';
import { news } from '@/data/content';
import { useT } from '@/lib/store';

export default function NewsIndex() {
  const { t } = useT();
  return (
    <Screen back title={t('latestNews')}>
      {news.map((item) => <NewsCard key={item.id} item={item} />)}
    </Screen>
  );
}
