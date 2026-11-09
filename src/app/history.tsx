import { router } from 'expo-router';
import { Pressable, StyleSheet, View } from 'react-native';

import { Badge, Card, Icon, Screen, Txt, styles as ui } from '@/components/ui';
import { funds } from '@/data/content';
import { monthName, mur } from '@/lib/i18n';
import { monthsLabel } from '@/lib/receipt';
import { useApp, useT } from '@/lib/store';
import { color, space } from '@/theme';

export default function History() {
  const { state } = useApp();
  const { t, tr, lang } = useT();
  return (
    <Screen back title={t('history')}>
      <Card style={s.list}>
        {state.payments.map((p, i) => {
          const d = new Date(p.date);
          const fund = funds.find((f) => f.id === p.fund);
          return (
            <Pressable
              key={p.id}
              onPress={() => router.push(`/receipt/${p.id}`)}
              accessibilityRole="button"
              style={({ pressed }) => [s.row, i < state.payments.length - 1 && s.divider, pressed && ui.pressed]}
            >
              <View style={s.date}>
                <Txt v="heading">{d.getDate()}</Txt>
                <Txt v="caption" c={color.muted}>{monthName(lang, d.getMonth() + 1, true)} {String(d.getFullYear()).slice(2)}</Txt>
              </View>
              <View style={ui.flex}>
                <Txt v="bodyStrong" numberOfLines={1}>
                  {p.kind === 'donation' ? `${t('donate')} · ${fund ? tr(fund.label) : ''}` : monthsLabel(p.monthKeys, lang)}
                </Txt>
                <View style={s.meta}>
                  <Badge label={p.method === 'juice' ? 'Juice' : `${t('manual')} · ${p.method}`} tone={p.method === 'juice' ? 'success' : 'amber'} />
                  <Txt v="caption" c={color.muted}>{p.receiptNo}</Txt>
                </View>
              </View>
              <Txt v="number">{mur(p.amount)}</Txt>
              <Icon name="chevron-right" size={16} c={color.muted} />
            </Pressable>
          );
        })}
      </Card>
    </Screen>
  );
}

const s = StyleSheet.create({
  list: { padding: 0 },
  row: { flexDirection: 'row', alignItems: 'center', gap: space.md, padding: space.lg },
  divider: { borderBottomWidth: StyleSheet.hairlineWidth, borderBottomColor: color.line },
  date: { width: 44, alignItems: 'center' },
  meta: { flexDirection: 'row', alignItems: 'center', gap: space.sm, marginTop: 4 },
});
