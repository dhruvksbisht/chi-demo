import { router, type Href } from 'expo-router';
import { Pressable, ScrollView, StyleSheet, useWindowDimensions, View } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

import { Logo } from '@/components/Brand';
import { Banner } from '@/components/Banner';
import { NewsSlide } from '@/components/NewsSlide';
import { Card, Icon, IconButton, Section, Segmented, Txt, styles as ui, tap, type IconName } from '@/components/ui';
import { events, news } from '@/data/content';
import { hijriMonthName, longDate, monthName, weekday, type Lang, type Localized, type StringKey } from '@/lib/i18n';
import { useApp, useT } from '@/lib/store';
import { addDays, formatCountdown, formatTime, muToday, nextPrayer, prayerTimesFor, toHijri } from '@/lib/time';
import { useNow } from '@/lib/useNow';
import { color, radius, space } from '@/theme';

const QUICK: { icon: IconName; label: StringKey; href: Href }[] = [
  { icon: 'clock', label: 'prayerTimes', href: '/prayer' },
  { icon: 'moon', label: 'ramadan', href: '/ramadan' },
  { icon: 'compass', label: 'qibla', href: '/qibla' },
  { icon: 'file-text', label: 'documents', href: '/documents' },
  { icon: 'book-open', label: 'duas', href: '/duas' },
];

const BANNERS: { id: string; label: StringKey; detail?: Localized; accent: string; href: Href }[] = [
  { id: 'events', label: 'events', accent: color.amber, href: '/events' },
  { id: 'donate', label: 'donate', detail: { en: 'Zakat, sadaqah and the mosque fund', fr: 'Zakat, sadaqa et fonds de la mosquée' }, accent: '#7FB89A', href: '/donate' },
  { id: 'centenary', label: 'centenary', detail: { en: 'A hundred years in 2027', fr: 'Cent ans en 2027' }, accent: '#8FB3D6', href: '/centenary' },
];

export default function Home() {
  const insets = useSafeAreaInsets();
  const { width } = useWindowDimensions();
  const slideW = Math.min(width * 0.78, 320);
  const { state, dispatch } = useApp();
  const { t, tr, lang } = useT();
  const today = muToday();
  const hijri = toHijri(today);
  const notice = news.find((n) => n.kind === 'notice');
  const upcoming = [...events].sort((a, b) => a.inDays - b.inDays)[0];
  const upDay = addDays(today, upcoming.inDays);
  const upWhen = `${weekday(lang, upDay.y, upDay.m, upDay.d).slice(0, 3)} ${upDay.d} ${monthName(lang, upDay.m, true)}`;
  const detailFor = (b: (typeof BANNERS)[number]) => (b.detail ? tr(b.detail) : `${tr(upcoming.title)}, ${upWhen}`);

  return (
    <ScrollView style={ui.screen} contentContainerStyle={[s.content, { paddingTop: insets.top + space.sm }]}>
      <View style={s.header}>
        <Logo size={42} />
        <View style={s.headerRight}>
          <Segmented
            options={[{ value: 'en', label: 'EN' }, { value: 'fr', label: 'FR' }]}
            value={state.lang}
            onChange={(l: Lang) => dispatch({ type: 'lang', lang: l })}
          />
          <IconButton icon="bell" label={t('notifications')} badge={!state.inboxRead} onPress={() => router.push('/notifications')} />
        </View>
      </View>

      <View style={s.greeting}>
        <Txt v="label" c={color.muted}>
          {weekday(lang, today.y, today.m, today.d)} {longDate(lang, today.y, today.m, today.d)}
        </Txt>
        <Txt v="hero">{t('assalamu')}</Txt>
        <Txt v="label" c={color.amberDeep}>
          {hijri.d} {hijriMonthName(hijri.m)} {hijri.y} AH
        </Txt>
      </View>

      <PrayerHero />

      {notice && (
        <Card tone="amber" onPress={() => router.push(`/news/${notice.id}`)} style={s.notice}>
          <View style={ui.flex}>
            <Txt v="overline" c={color.amberDeep}>{t('urgent')}</Txt>
            <Txt v="bodyStrong">{tr(notice.title)}</Txt>
          </View>
          <Icon name="chevron-right" size={18} c={color.amberDeep} />
        </Card>
      )}

      <View style={s.banners}>
        {BANNERS.map((b) => (
          <Banner key={b.id} id={b.id} title={t(b.label)} detail={detailFor(b)} accent={b.accent} onPress={() => router.push(b.href)} />
        ))}
      </View>

      <ScrollView horizontal showsHorizontalScrollIndicator={false} style={s.bleed} contentContainerStyle={s.quick}>
        {QUICK.map((item) => (
          <Pressable
            key={item.label}
            onPress={() => { tap(); router.push(item.href); }}
            accessibilityRole="button"
            style={({ pressed }) => [s.quickItem, pressed && ui.pressed]}
          >
            <Icon name={item.icon} size={16} c={color.amberDeep} />
            <Txt v="label" c={color.ink}>{t(item.label)}</Txt>
          </Pressable>
        ))}
      </ScrollView>

      <Section title={t('latestNews')} action={t('seeAll')} onAction={() => router.push('/news')}>
        <ScrollView
          horizontal
          showsHorizontalScrollIndicator={false}
          snapToInterval={slideW + space.md}
          decelerationRate="fast"
          style={s.bleed}
          contentContainerStyle={s.slides}
        >
          {news.map((item) => <NewsSlide key={item.id} item={item} width={slideW} />)}
        </ScrollView>
      </Section>
    </ScrollView>
  );
}

/** Dark hero with the next prayer, a live countdown and today's five times. */
function PrayerHero() {
  const { t } = useT();
  const now = useNow();
  const next = nextPrayer(now);
  const times = prayerTimesFor(muToday(now)).filter((p) => p.name !== 'sunrise');

  return (
    <Card tone="night" onPress={() => router.push('/prayer')} style={s.hero}>
      <Txt v="overline" c={color.onNightMuted}>{t('nextPrayer')}</Txt>
      <View style={s.heroMain}>
        <Txt v="hero" c={color.onNight}>{t(next.name)}</Txt>
        <Txt v="hero" c={color.amber}>{formatTime(next.time)}</Txt>
      </View>
      <Txt v="label" c={color.onNightMuted}>
        {t('inTime')} {formatCountdown(next.time.getTime() - now.getTime())}
      </Txt>
      <View style={s.heroTimes}>
        {times.map((p) => {
          const on = p.name === next.name;
          return (
            <View key={p.name} style={[s.heroTime, on && s.heroTimeOn]}>
              <Txt v="caption" c={on ? color.night : color.onNightMuted}>{t(p.name)}</Txt>
              <Txt v="number" c={on ? color.night : color.onNight}>{formatTime(p.time)}</Txt>
            </View>
          );
        })}
      </View>
    </Card>
  );
}

const s = StyleSheet.create({
  content: { paddingHorizontal: space.lg, paddingBottom: space.xxl, gap: space.xl },
  header: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' },
  headerRight: { flexDirection: 'row', alignItems: 'center', gap: space.sm },
  greeting: { gap: space.xs },
  hero: { overflow: 'hidden', padding: space.xl, gap: space.xs },
  heroMain: { flexDirection: 'row', alignItems: 'baseline', gap: space.md, marginTop: space.xs },
  heroTimes: { flexDirection: 'row', gap: space.xs, marginTop: space.lg },
  heroTime: { flex: 1, alignItems: 'center', paddingVertical: space.sm, borderRadius: radius.sm, gap: 2 },
  heroTimeOn: { backgroundColor: color.amber, borderColor: color.amber },
  notice: { flexDirection: 'row', alignItems: 'center', gap: space.md, paddingVertical: space.md },
  banners: { gap: space.md },
  bleed: { marginHorizontal: -space.lg },
  quick: { paddingHorizontal: space.lg, gap: space.sm },
  quickItem: { flexDirection: 'row', alignItems: 'center', gap: 6, paddingHorizontal: space.md, paddingVertical: space.sm, borderRadius: 999, backgroundColor: color.surface, borderWidth: 1, borderColor: color.line },
  slides: { paddingHorizontal: space.lg, gap: space.md },
});
