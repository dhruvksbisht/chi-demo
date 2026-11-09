import { router } from 'expo-router';
import { StyleSheet, View } from 'react-native';

import { Card, Icon, Row, Screen, Toggle, Txt } from '@/components/ui';
import { hijriMonthName, longDate } from '@/lib/i18n';
import { useApp, useT } from '@/lib/store';
import { formatTime, muToday, nextPrayer, prayerTimesFor, toHijri } from '@/lib/time';
import { useNow } from '@/lib/useNow';
import { color, radius, space } from '@/theme';

export default function Prayer() {
  const { state, dispatch } = useApp();
  const { t, lang } = useT();
  const now = useNow(30_000);
  const today = muToday(now);
  const hijri = toHijri(today);
  const next = nextPrayer(now);

  return (
    <Screen back title={t('prayerTimes')} subtitle={`${longDate(lang, today.y, today.m, today.d)} · ${hijri.d} ${hijriMonthName(hijri.m)} ${hijri.y}`}>
      <Card style={s.list}>
        {prayerTimesFor(today).map((p, i, all) => {
          const on = p.name === next.name && p.time.getDate() === next.time.getDate();
          const isPrayer = p.name !== 'sunrise';
          return (
            <View key={p.name} style={[s.row, i < all.length - 1 && s.divider, on && s.rowOn]}>
              <View style={s.name}>
                <Txt v={on ? 'bodyStrong' : 'body'} c={isPrayer ? color.ink : color.muted}>{t(p.name)}</Txt>
                {on && <Txt v="caption" c={color.amberDeep}>{t('nextPrayer')}</Txt>}
              </View>
              <Txt v="heading" c={isPrayer ? color.ink : color.muted}>{formatTime(p.time)}</Txt>
              {isPrayer ? (
                <Toggle value={state.adhan[p.name]} onChange={() => dispatch({ type: 'adhan', prayer: p.name })} label={`${t('adhanAlert')} ${t(p.name)}`} />
              ) : (
                <View style={s.spacer}><Icon name="sunrise" size={18} c={color.muted} /></View>
              )}
            </View>
          );
        })}
      </Card>
      <Txt v="caption" c={color.muted} style={s.center}>
        {t('adhanAlert')} · {t('prayerMethod')}
      </Txt>
      <Card style={s.links}>
        <Row icon="moon" title={t('ramadan')} onPress={() => router.push('/ramadan')} />
        <Row icon="compass" title={t('qibla')} onPress={() => router.push('/qibla')} last />
      </Card>
    </Screen>
  );
}

const s = StyleSheet.create({
  center: { textAlign: 'center' },
  list: { padding: space.xs },
  row: { flexDirection: 'row', alignItems: 'center', gap: space.md, paddingHorizontal: space.md, paddingVertical: space.md, borderRadius: radius.md },
  rowOn: { backgroundColor: color.amberSoft },
  divider: { borderBottomWidth: StyleSheet.hairlineWidth, borderBottomColor: color.line },
  name: { flex: 1 },
  spacer: { width: 51, alignItems: 'center' },
  links: { padding: 0 },
});
