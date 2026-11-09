import { router } from 'expo-router';
import { Pressable, StyleSheet, View } from 'react-native';

import { Logo, TilePattern } from '@/components/Brand';
import { Txt, tap } from '@/components/ui';
import type { NewsItem } from '@/data/content';
import { longDate } from '@/lib/i18n';
import { useT } from '@/lib/store';
import { addDays, muToday } from '@/lib/time';
import { color, radius, space } from '@/theme';

const KIND: Record<NewsItem['kind'], { accent: string; label: { en: string; fr: string } }> = {
  news: { accent: color.amber, label: { en: 'News', fr: 'Actualité' } },
  notice: { accent: '#F0B55E', label: { en: 'Notice', fr: 'Avis' } },
  janaza: { accent: '#8FB3D6', label: { en: 'Janaza', fr: 'Janaza' } },
};

/** Tall carousel card for the home screen: patterned art panel over a dark caption. */
export function NewsSlide({ item, width }: { item: NewsItem; width: number }) {
  const { tr, lang } = useT();
  const kind = KIND[item.kind];
  const day = addDays(muToday(), -item.daysAgo);

  return (
    <Pressable
      onPress={() => { tap(); router.push(`/news/${item.id}`); }}
      accessibilityRole="button"
      accessibilityLabel={tr(item.title)}
      style={({ pressed }) => [s.card, { width }, pressed && s.pressed]}
    >
      <View style={s.art}>
        <TilePattern id={`news-${item.id}`} stroke={kind.accent} opacity={0.45} tile={36} />
        <View style={[s.tag, { backgroundColor: kind.accent }]}>
          <Txt v="overline" c={color.night}>{kind.label[lang]}</Txt>
        </View>
      </View>
      <View style={s.body}>
        <Txt v="heading" c={color.onNight} numberOfLines={2} style={s.title}>{tr(item.title)}</Txt>
        <View style={s.foot}>
          <Txt v="label" c={color.onNightMuted}>{longDate(lang, day.y, day.m, day.d)}</Txt>
          <Logo size={24} lettering={false} />
        </View>
      </View>
    </Pressable>
  );
}

const s = StyleSheet.create({
  card: { backgroundColor: color.night, borderRadius: radius.md, overflow: 'hidden' },
  pressed: { opacity: 0.92 },
  art: { height: 132, backgroundColor: '#2B261F' },
  tag: { position: 'absolute', left: 0, bottom: 0, paddingHorizontal: space.md, paddingVertical: 4 },
  body: { padding: space.lg, gap: space.lg },
  title: { minHeight: 48 },
  foot: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' },
});
