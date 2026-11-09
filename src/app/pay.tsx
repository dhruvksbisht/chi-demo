import { router } from 'expo-router';
import { useState } from 'react';
import { Pressable, StyleSheet, View } from 'react-native';

import { Badge, Button, Card, Icon, Screen, Txt, tap } from '@/components/ui';
import { monthName, mur } from '@/lib/i18n';
import { monthStatus, useApp, useT } from '@/lib/store';
import { color, space } from '@/theme';

const MAX_AHEAD = 8;

export default function Pay() {
  const { state } = useApp();
  const { t, lang } = useT();
  const unpaid = state.months.filter((m) => !m.paymentId).slice(0, MAX_AHEAD);
  const arrearsCount = unpaid.filter((m) => monthStatus(m) === 'overdue').length;

  // Months are paid in order: selecting a month selects every earlier unpaid month,
  // and arrears can never be deselected.
  const [count, setCount] = useState(Math.min(unpaid.length, arrearsCount + 1));
  const selected = unpaid.slice(0, count);
  const total = selected.reduce((sum, m) => sum + m.amount, 0);

  const toggle = (i: number) => {
    tap();
    setCount(Math.max(arrearsCount, i + 1 === count ? i : i + 1));
  };

  const checkout = () =>
    router.push({
      pathname: '/checkout',
      params: { kind: 'subscription', months: selected.map((m) => m.key).join(','), amount: String(total) },
    });

  return (
    <Screen
      back
      title={t('payMonths')}
      subtitle={t('paySub')}
      footer={
        <View style={s.footer}>
          <View style={s.totalRow}>
            <View>
              <Txt v="overline" c={color.muted}>{t('total')}</Txt>
              <Txt v="caption" c={color.muted}>{count} {t('monthsSelected')}</Txt>
            </View>
            <Txt v="title">{mur(total)}</Txt>
          </View>
          <Button label={t('payWithJuice')} icon="lock" onPress={checkout} disabled={count === 0} />
          <Txt v="caption" c={color.muted} style={s.center}>{t('redirectNote')}</Txt>
        </View>
      }
    >
      <Card style={s.list}>
        {unpaid.map((m, i) => {
          const on = i < count;
          const status = monthStatus(m);
          const locked = status === 'overdue';
          return (
            <Pressable
              key={m.key}
              onPress={() => toggle(i)}
              disabled={locked}
              accessibilityRole="checkbox"
              accessibilityState={{ checked: on, disabled: locked }}
              style={[s.row, i < unpaid.length - 1 && s.divider, on && s.rowOn]}
            >
              <View style={[s.check, on && s.checkOn]}>{on && <Icon name="check" size={14} c={color.ink} />}</View>
              <View style={s.flex}>
                <Txt v="bodyStrong" style={s.cap}>{monthName(lang, m.m)} {m.y}</Txt>
                {status !== 'upcoming' && <Badge label={t(status)} tone={status} />}
              </View>
              <Txt v="number">{mur(m.amount)}</Txt>
            </Pressable>
          );
        })}
      </Card>
    </Screen>
  );
}

const s = StyleSheet.create({
  flex: { flex: 1, gap: 4 },
  cap: { textTransform: 'capitalize' },
  center: { textAlign: 'center' },
  list: { padding: 0, overflow: 'hidden' },
  row: { flexDirection: 'row', alignItems: 'center', gap: space.md, padding: space.lg },
  rowOn: { backgroundColor: '#FFFBF3' },
  divider: { borderBottomWidth: StyleSheet.hairlineWidth, borderBottomColor: color.line },
  check: { width: 24, height: 24, borderRadius: 7, borderWidth: 1.5, borderColor: color.line, alignItems: 'center', justifyContent: 'center' },
  checkOn: { backgroundColor: color.amber, borderColor: color.amber },
  footer: { gap: space.md },
  totalRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
});
