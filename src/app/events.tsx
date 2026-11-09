import { StyleSheet, View } from 'react-native';

import { Badge, Button, Card, Icon, Screen, Txt } from '@/components/ui';
import { events } from '@/data/content';
import { monthName } from '@/lib/i18n';
import { useApp, useT } from '@/lib/store';
import { addDays, muToday } from '@/lib/time';
import { color, radius, space } from '@/theme';

export default function Events() {
  const { state, dispatch } = useApp();
  const { t, tr, lang } = useT();
  const today = muToday();
  const sorted = [...events].sort((a, b) => a.inDays - b.inDays);

  return (
    <Screen back title={t('events')}>
      {sorted.map((e) => {
        const day = addDays(today, e.inDays);
        const going = state.rsvps.includes(e.id);
        return (
          <Card key={e.id} style={s.card}>
            <View style={s.date}>
              <Txt v="overline" c={color.amberDeep}>{monthName(lang, day.m, true)}</Txt>
              <Txt v="title">{day.d}</Txt>
            </View>
            <View style={s.body}>
              {e.membersOnly && <Badge label={t('membersOnly')} tone="amber" />}
              <Txt v="bodyStrong">{tr(e.title)}</Txt>
              <View style={s.meta}>
                <Icon name="clock" size={13} c={color.muted} />
                <Txt v="caption" c={color.muted}>{e.time}</Txt>
                <Icon name="map-pin" size={13} c={color.muted} />
                <Txt v="caption" c={color.muted}>{e.place}</Txt>
              </View>
              <Button
                label={going ? t('going') : t('rsvp')}
                icon={going ? 'check' : 'plus'}
                kind={going ? 'primary' : 'secondary'}
                onPress={() => dispatch({ type: 'rsvp', id: e.id })}
                style={s.rsvp}
              />
            </View>
          </Card>
        );
      })}
    </Screen>
  );
}

const s = StyleSheet.create({
  card: { flexDirection: 'row', gap: space.lg },
  date: { width: 56, height: 64, borderRadius: radius.md, backgroundColor: color.amberSoft, alignItems: 'center', justifyContent: 'center' },
  body: { flex: 1, gap: 6 },
  meta: { flexDirection: 'row', alignItems: 'center', gap: 5 },
  rsvp: { alignSelf: 'flex-start', minHeight: 38, marginTop: space.xs },
});
