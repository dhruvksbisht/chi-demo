import { router } from 'expo-router';
import { StyleSheet, View } from 'react-native';

import { Badge, Card, Icon, Txt } from '@/components/ui';
import type { NewsItem } from '@/data/content';
import type { Lang } from '@/lib/i18n';
import { useT } from '@/lib/store';
import { color, radius, space } from '@/theme';

const KIND = {
  news: { icon: 'file-text', tone: 'neutral', label: { en: 'News', fr: 'Actualité' } },
  notice: { icon: 'bell', tone: 'amber', label: { en: 'Notice', fr: 'Avis' } },
  janaza: { icon: 'moon', tone: 'info', label: { en: 'Janaza', fr: 'Janaza' } },
} as const;

export const ago = (lang: Lang, days: number): string => {
  if (days === 0) return lang === 'fr' ? 'Aujourd’hui' : 'Today';
  if (days === 1) return lang === 'fr' ? 'Hier' : 'Yesterday';
  return lang === 'fr' ? `Il y a ${days} jours` : `${days} days ago`;
};

export function NewsCard({ item }: { item: NewsItem }) {
  const { tr, lang } = useT();
  const kind = KIND[item.kind];
  return (
    <Card onPress={() => router.push(`/news/${item.id}`)} style={s.card}>
      <View style={[s.thumb, item.kind === 'janaza' && s.thumbJanaza]}>
        <Icon name={kind.icon} size={22} c={item.kind === 'janaza' ? color.info : color.amberDeep} />
      </View>
      <View style={s.text}>
        <View style={s.meta}>
          <Badge label={kind.label[lang]} tone={kind.tone} />
          <Txt v="caption" c={color.muted}>{ago(lang, item.daysAgo)}</Txt>
        </View>
        <Txt v="bodyStrong" numberOfLines={2}>{tr(item.title)}</Txt>
        <Txt v="label" c={color.muted} numberOfLines={2}>{tr(item.summary)}</Txt>
      </View>
    </Card>
  );
}

const s = StyleSheet.create({
  card: { flexDirection: 'row', gap: space.md, padding: space.md },
  thumb: { width: 64, height: 64, borderRadius: radius.md, backgroundColor: color.amberSoft, alignItems: 'center', justifyContent: 'center' },
  thumbJanaza: { backgroundColor: color.infoSoft },
  text: { flex: 1, gap: 4 },
  meta: { flexDirection: 'row', alignItems: 'center', gap: space.sm },
});
