import * as Haptics from 'expo-haptics';
import { Platform, StyleSheet, View } from 'react-native';

import { Badge, Button, Card, Screen, Section, Txt } from '@/components/ui';
import { mur } from '@/lib/i18n';
import { monthsLabel } from '@/lib/receipt';
import { accountSummary, currentMonthKey, member, useApp, useT, type AccessRequest } from '@/lib/store';
import { color, space } from '@/theme';

// Society-wide figures are illustrative; the demo member's own activity is live.
const BASE = { activeMembers: 1284, collected: 46_350, arrears: 38_400 };

export default function Admin() {
  const { state, dispatch } = useApp();
  const { t, lang } = useT();
  const pending = state.requests.filter((r) => r.status === 'pending');
  const reviewed = state.requests.filter((r) => r.status !== 'pending');
  const thisMonth = state.payments
    .filter((p) => p.date.slice(0, 7) === currentMonthKey && p.kind === 'subscription')
    .reduce((sum, p) => sum + p.amount, 0);
  const { arrearsTotal } = accountSummary(state.months);

  const review = (r: AccessRequest, status: 'approved' | 'rejected') => {
    if (Platform.OS !== 'web') Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    dispatch({ type: 'requestReviewed', id: r.id, status });
  };

  const stats = [
    { label: t('activeMembers'), value: BASE.activeMembers.toLocaleString('en-US') },
    { label: t('collected'), value: mur(BASE.collected + thisMonth) },
    { label: t('arrears'), value: mur(BASE.arrears + arrearsTotal) },
    { label: t('pendingRequests'), value: String(pending.length) },
  ];

  return (
    <Screen back title={t('adminPreview')} subtitle={t('adminSub')}>
      <View style={s.stats}>
        {stats.map((st, i) => (
          <Card key={st.label} tone={i === 3 && pending.length > 0 ? 'amber' : 'surface'} style={s.stat}>
            <Txt v="caption" c={color.muted}>{st.label}</Txt>
            <Txt v="heading">{st.value}</Txt>
          </Card>
        ))}
      </View>

      <Section title={t('accessRequests')}>
        {pending.length === 0 && <Txt c={color.muted}>{t('nothingPending')}</Txt>}
        {pending.map((r) => (
          <Card key={r.id} style={s.request}>
            <View style={s.head}>
              <View style={s.flex}>
                <Txt v="bodyStrong">{r.name}</Txt>
                <Txt v="caption" c={color.muted}>NIC {r.nic.slice(0, 1)}•••••••••{r.nic.slice(-3)} · {r.mobile}</Txt>
              </View>
              <Badge label={r.matched ? t('matched') : t('noMatch')} tone={r.matched ? 'success' : 'danger'} />
            </View>
            {!r.matched && <Txt v="caption" c={color.inkSoft}>{t('rejectReason')}</Txt>}
            <View style={s.actions}>
              <Button label={t('reject')} kind="secondary" onPress={() => review(r, 'rejected')} style={s.action} />
              <Button label={t('approve')} onPress={() => review(r, 'approved')} style={s.action} />
            </View>
          </Card>
        ))}
        {reviewed.map((r) => (
          <Card key={r.id} tone="sunken" style={s.reviewed}>
            <Txt v="label" style={s.flex}>{r.name}</Txt>
            <Badge label={r.status === 'approved' ? t('approved') : t('rejected')} tone={r.status === 'approved' ? 'success' : 'danger'} />
          </Card>
        ))}
      </Section>

      <Section title={t('recentPayments')}>
        <Card style={s.list}>
          {state.payments.slice(0, 5).map((p, i, all) => (
            <View key={p.id} style={[s.payment, i < all.length - 1 && s.divider]}>
              <View style={s.flex}>
                <Txt v="label">{member.name}</Txt>
                <Txt v="caption" c={color.muted}>
                  {p.kind === 'donation' ? t('donate') : monthsLabel(p.monthKeys, lang)}
                </Txt>
              </View>
              <View style={s.right}>
                <Txt v="number">{mur(p.amount)}</Txt>
                <Badge label={p.method === 'juice' ? 'Juice' : t('manual')} tone={p.method === 'juice' ? 'success' : 'amber'} />
              </View>
            </View>
          ))}
        </Card>
      </Section>
    </Screen>
  );
}

const s = StyleSheet.create({
  flex: { flex: 1 },
  stats: { flexDirection: 'row', flexWrap: 'wrap', gap: space.sm },
  stat: { width: '48.5%', flexGrow: 1, gap: 4, padding: space.md },
  request: { gap: space.md },
  head: { flexDirection: 'row', alignItems: 'flex-start', gap: space.md },
  actions: { flexDirection: 'row', gap: space.sm },
  action: { flex: 1, minHeight: 44 },
  reviewed: { flexDirection: 'row', alignItems: 'center', paddingVertical: space.md },
  list: { padding: 0 },
  payment: { flexDirection: 'row', alignItems: 'center', padding: space.lg, gap: space.md },
  divider: { borderBottomWidth: StyleSheet.hairlineWidth, borderBottomColor: color.line },
  right: { alignItems: 'flex-end', gap: 4 },
});
