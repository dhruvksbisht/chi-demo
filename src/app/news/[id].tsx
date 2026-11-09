import { useLocalSearchParams } from 'expo-router';
import { StyleSheet, View } from 'react-native';

import { Star } from '@/components/Brand';
import { ago } from '@/components/NewsCard';
import { Icon, Screen, Txt } from '@/components/ui';
import { news } from '@/data/content';
import { useT } from '@/lib/store';
import { color, radius } from '@/theme';

export default function Article() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const { tr, lang } = useT();
  const item = news.find((n) => n.id === id);

  if (!item) {
    return (
      <Screen back title="Not found">
        <Txt c={color.muted}>This article is no longer available.</Txt>
      </Screen>
    );
  }

  const janaza = item.kind === 'janaza';
  return (
    <Screen back title={tr(item.title)} subtitle={ago(lang, item.daysAgo)}>
      <View style={[s.cover, janaza && s.coverJanaza]}>
        <View style={s.star}><Star size={220} stroke={janaza ? color.info : color.amber} opacity={0.35} /></View>
        <Icon name={janaza ? 'moon' : item.kind === 'notice' ? 'bell' : 'file-text'} size={36} c={janaza ? color.info : color.amberDeep} />
      </View>
      <Txt style={s.body}>{tr(item.body)}</Txt>
    </Screen>
  );
}

const s = StyleSheet.create({
  cover: { height: 170, borderRadius: radius.lg, backgroundColor: color.amberSoft, alignItems: 'center', justifyContent: 'center', overflow: 'hidden' },
  coverJanaza: { backgroundColor: color.infoSoft },
  star: { position: 'absolute' },
  body: { fontSize: 17, lineHeight: 27 },
});
