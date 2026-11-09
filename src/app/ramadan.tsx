import { StyleSheet, View } from 'react-native';

import { Star } from '@/components/Brand';
import { Card, Screen, Section, Txt } from '@/components/ui';
import { monthName, weekday } from '@/lib/i18n';
import { useT } from '@/lib/store';
import { addDays, daysBetween, formatTime, muToday, nextRamadanStart, prayerTimesFor, ramadanDay } from '@/lib/time';
import { color, space } from '@/theme';

const DAYS = 30;

export default function Ramadan() {
  const { t, lang } = useT();
  const today = muToday();
  const current = ramadanDay(today);
  const { start, hijriYear } = nextRamadanStart(today);
  const first = current ? addDays(today, 1 - current) : start;
  const countdown = daysBetween(today, start);

  const timetable = Array.from({ length: DAYS }, (_, i) => {
    const day = addDays(first, i);
    const times = prayerTimesFor(day);
    const at = (n: string) => formatTime(times.find((p) => p.name === n)!.time);
    return { i: i + 1, day, suhoor: at('fajr'), iftar: at('maghrib') };
  });

  return (
    <Screen back title={`${t('ramadan')} ${hijriYear}`} subtitle={t('sightingNote')}>
      <Card tone="night" style={s.hero}>
        <View style={s.star}><Star size={200} opacity={0.22} /></View>
        {current ? (
          <>
            <Txt v="overline" c={color.onNightMuted}>{t('dayOf')}</Txt>
            <Txt v="hero" c={color.amber}>{current} / {DAYS}</Txt>
            <Txt v="label" c={color.onNightMuted}>{t('iftar')} {timetable[current - 1].iftar}</Txt>
          </>
        ) : (
          <>
            <Txt v="overline" c={color.onNightMuted}>{t('ramadanBegins')}</Txt>
            <View style={s.big}>
              <Txt v="hero" c={color.amber} style={s.count}>{countdown}</Txt>
              <Txt v="heading" c={color.onNight}>{t('days')}</Txt>
            </View>
            <Txt v="label" c={color.onNightMuted}>
              ≈ {weekday(lang, start.y, start.m, start.d)} {start.d} {monthName(lang, start.m)} {start.y}
            </Txt>
          </>
        )}
      </Card>

      <Section title={t('timetable')}>
        <Card style={s.table}>
          <View style={[s.tr, s.th]}>
            <Txt v="overline" c={color.muted} style={s.c1}>#</Txt>
            <Txt v="overline" c={color.muted} style={s.c2}>{t('date')}</Txt>
            <Txt v="overline" c={color.muted} style={s.c3}>{t('suhoor')}</Txt>
            <Txt v="overline" c={color.muted} style={s.c3}>{t('iftar')}</Txt>
          </View>
          {timetable.map((r) => {
            const on = r.i === current;
            return (
              <View key={r.i} style={[s.tr, on && s.trOn, r.i % 2 === 0 && s.zebra]}>
                <Txt v="label" c={color.muted} style={s.c1}>{r.i}</Txt>
                <Txt v="label" style={s.c2}>{r.day.d} {monthName(lang, r.day.m, true)}</Txt>
                <Txt v="number" style={s.c3}>{r.suhoor}</Txt>
                <Txt v="number" c={color.amberDeep} style={s.c3}>{r.iftar}</Txt>
              </View>
            );
          })}
        </Card>
      </Section>
    </Screen>
  );
}

const s = StyleSheet.create({
  hero: { padding: space.xl, overflow: 'hidden', gap: space.xs },
  star: { position: 'absolute', right: -60, bottom: -70 },
  big: { flexDirection: 'row', alignItems: 'baseline', gap: space.sm },
  count: { fontSize: 56, lineHeight: 62 },
  table: { padding: 0, overflow: 'hidden' },
  tr: { flexDirection: 'row', alignItems: 'center', paddingVertical: 10, paddingHorizontal: space.lg },
  th: { borderBottomWidth: 1, borderBottomColor: color.line },
  trOn: { backgroundColor: color.amberSoft },
  zebra: { backgroundColor: '#FDFAF5' },
  c1: { width: 28 },
  c2: { flex: 1, textTransform: 'capitalize' },
  c3: { width: 86, textAlign: 'right' },
});
