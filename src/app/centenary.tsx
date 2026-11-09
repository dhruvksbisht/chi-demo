import { router } from 'expo-router';
import { StyleSheet, View } from 'react-native';

import { Logo, Star } from '@/components/Brand';
import { Badge, Button, Card, Screen, Section, Txt } from '@/components/ui';
import { timeline } from '@/data/content';
import { useT } from '@/lib/store';
import { color, font, space } from '@/theme';

export default function Centenary() {
  const { t, tr } = useT();
  return (
    <Screen back title={t('centenary')} subtitle={t('centenarySub')}>
      <Card tone="night" style={s.hero}>
        <View style={s.star}><Star size={260} opacity={0.2} /></View>
        <Logo size={64} />
        <Txt v="hero" c={color.onNight} style={s.years}>1927 — 2027</Txt>
        <Txt c={color.onNightMuted} style={s.tagline}>One hundred years of faith, learning and service in Port Louis.</Txt>
      </Card>

      <Section title={t('centenary')}>
        <Badge label={t('sample')} tone="info" />
        <View style={s.timeline}>
          {timeline.map((item, i) => (
            <View key={item.year} style={s.item}>
              <View style={s.rail}>
                <View style={[s.dot, i === timeline.length - 1 && s.dotNow]} />
                {i < timeline.length - 1 && <View style={s.line} />}
              </View>
              <View style={s.itemBody}>
                <Txt v="heading" c={color.amberDeep}>{item.year}</Txt>
                <Txt c={color.inkSoft}>{tr(item.text)}</Txt>
              </View>
            </View>
          ))}
        </View>
      </Section>

      <Button label={t('programme')} icon="calendar" kind="secondary" onPress={() => router.push('/events')} />
      <Button label={t('donate')} icon="heart" onPress={() => router.push('/donate')} />
    </Screen>
  );
}

const s = StyleSheet.create({
  hero: { padding: space.xl, overflow: 'hidden', gap: space.md },
  star: { position: 'absolute', right: -80, top: -60 },
  years: { fontFamily: font.display, letterSpacing: 1 },
  tagline: { maxWidth: 260 },
  timeline: { marginTop: space.sm },
  item: { flexDirection: 'row', gap: space.lg },
  rail: { alignItems: 'center', width: 14 },
  dot: { width: 14, height: 14, borderRadius: 7, borderWidth: 3, borderColor: color.amber, backgroundColor: color.bg, marginTop: 6 },
  dotNow: { backgroundColor: color.amber },
  line: { flex: 1, width: 2, backgroundColor: color.line, marginVertical: 2 },
  itemBody: { flex: 1, paddingBottom: space.xl, gap: 2 },
});
