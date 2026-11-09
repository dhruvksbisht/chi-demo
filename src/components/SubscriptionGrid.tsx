import { StyleSheet, View } from 'react-native';

import { Txt } from '@/components/ui';
import { monthName } from '@/lib/i18n';
import { currentMonthKey, monthStatus, useT, type Month, type MonthStatus } from '@/lib/store';
import { color, font, radius, space } from '@/theme';

const TONE: Record<MonthStatus, { bg: string; fg: string; border: string }> = {
  paid: { bg: color.successSoft, fg: color.success, border: '#BFDDC9' },
  overdue: { bg: color.dangerSoft, fg: color.danger, border: '#EDBDB4' },
  due: { bg: color.amberSoft, fg: color.amberDeep, border: color.amber },
  upcoming: { bg: color.surface, fg: color.muted, border: color.line },
};

/** Twelve-month window: nine months back, the current month, two ahead (FR-021). */
export function SubscriptionGrid({ months }: { months: Month[] }) {
  const { t, lang } = useT();
  const idx = months.findIndex((m) => m.key === currentMonthKey);
  const window = months.slice(Math.max(0, idx - 9), idx + 3);

  return (
    <View style={s.wrap}>
      <View style={s.grid}>
        {window.map((m) => {
          const status = monthStatus(m);
          const tone = TONE[status];
          return (
            <View
              key={m.key}
              style={[s.cell, { backgroundColor: tone.bg, borderColor: tone.border }]}
              accessible
              accessibilityLabel={`${monthName(lang, m.m)} ${m.y}: ${t(status)}`}
            >
              <Txt v="caption" c={tone.fg} style={s.month}>{monthName(lang, m.m, true)}</Txt>
              <Txt v="caption" c={tone.fg} style={s.year}>{String(m.y).slice(2)}</Txt>
            </View>
          );
        })}
      </View>
      <View style={s.legend}>
        {(['paid', 'overdue', 'due', 'upcoming'] as const).map((st) => (
          <View key={st} style={s.legendItem}>
            <View style={[s.swatch, { backgroundColor: TONE[st].bg, borderColor: TONE[st].border }]} />
            <Txt v="caption" c={color.muted}>{t(st)}</Txt>
          </View>
        ))}
      </View>
    </View>
  );
}

const s = StyleSheet.create({
  wrap: { gap: space.md },
  grid: { flexDirection: 'row', flexWrap: 'wrap', gap: space.sm },
  cell: { width: '14.6%', flexGrow: 1, aspectRatio: 0.95, borderRadius: radius.sm, borderWidth: 1, alignItems: 'center', justifyContent: 'center' },
  month: { fontFamily: font.semibold, textTransform: 'capitalize' },
  year: { opacity: 0.75 },
  legend: { flexDirection: 'row', flexWrap: 'wrap', gap: space.lg },
  legendItem: { flexDirection: 'row', alignItems: 'center', gap: 6 },
  swatch: { width: 12, height: 12, borderRadius: 3, borderWidth: 1 },
});
