import * as Haptics from 'expo-haptics';
import { router, useLocalSearchParams } from 'expo-router';
import { useEffect, useRef, useState } from 'react';
import { ActivityIndicator, Platform, StyleSheet, View } from 'react-native';

import { ReceiptView } from '@/components/ReceiptView';
import { Badge, Button, Card, Icon, KV, Screen, Segmented, Txt } from '@/components/ui';
import { funds } from '@/data/content';
import { mur, type StringKey } from '@/lib/i18n';
import { monthsLabel } from '@/lib/receipt';
import { newJuiceRef, newReceiptNo, useApp, useT, type Payment } from '@/lib/store';
import { color, radius, space } from '@/theme';

/**
 * Simulated Juice by MCB checkout (sandbox). It walks through the real sequence:
 * the member authorises in Juice, then the back end confirms the transaction with
 * MCB server-to-server (PAY-03) before any month is marked paid or a receipt issued.
 */
type Stage = 'review' | 'auth' | 'server' | 'receipt' | 'declined';
const STEPS: { stage: Stage; label: StringKey }[] = [
  { stage: 'auth', label: 'stepAuth' },
  { stage: 'server', label: 'stepServer' },
  { stage: 'receipt', label: 'stepReceipt' },
];
const STEP_MS = 1100;

function parseParams(p: Record<string, string | string[] | undefined>) {
  const one = (v: string | string[] | undefined) => (Array.isArray(v) ? v[0] : v) ?? '';
  const amount = Number(one(p.amount));
  const kind = one(p.kind) === 'donation' ? 'donation' : 'subscription';
  const months = one(p.months).split(',').filter((k) => /^\d{4}-\d{2}$/.test(k));
  const fund = funds.find((f) => f.id === one(p.fund));
  const valid = Number.isFinite(amount) && amount > 0 && (kind === 'donation' ? !!fund : months.length > 0);
  return { valid, amount, kind, months, fund } as const;
}

export default function Checkout() {
  const { dispatch } = useApp();
  const { t, tr, lang } = useT();
  const params = parseParams(useLocalSearchParams());
  const [outcome, setOutcome] = useState<'approve' | 'decline'>('approve');
  const [stage, setStage] = useState<Stage>('review');
  const [paid, setPaid] = useState<Payment>();
  const timers = useRef<ReturnType<typeof setTimeout>[]>([]);

  useEffect(() => () => timers.current.forEach(clearTimeout), []);

  if (paid) {
    const title = paid.kind === 'donation' ? t('donationReceived') : t('paymentSuccessful');
    return (
      <Screen title={title}>
        <ReceiptView payment={paid} onDone={() => router.dismissTo('/member')} />
      </Screen>
    );
  }

  if (!params.valid) {
    return (
      <Screen modal title={t('checkout')}>
        <Txt c={color.danger}>Invalid payment request.</Txt>
      </Screen>
    );
  }

  const after = (ms: number, fn: () => void) => timers.current.push(setTimeout(fn, ms));
  const haptic = (type: Haptics.NotificationFeedbackType) => {
    if (Platform.OS !== 'web') Haptics.notificationAsync(type);
  };

  const confirm = () => {
    setStage('auth');
    if (outcome === 'decline') {
      after(STEP_MS, () => {
        setStage('declined');
        haptic(Haptics.NotificationFeedbackType.Error);
      });
      return;
    }
    after(STEP_MS, () => setStage('server'));
    after(STEP_MS * 2, () => setStage('receipt'));
    after(STEP_MS * 2 + 600, () => {
      const payment: Payment = {
        id: `p${Date.now()}`,
        receiptNo: newReceiptNo(),
        ref: newJuiceRef(),
        kind: params.kind,
        method: 'juice',
        amount: params.amount,
        monthKeys: params.months,
        fund: params.fund?.id,
        date: new Date().toISOString(),
      };
      dispatch({ type: 'paymentConfirmed', payment });
      haptic(Haptics.NotificationFeedbackType.Success);
      setPaid(payment); // success is shown in place; no navigation out of the modal
    });
  };

  const busy = stage !== 'review' && stage !== 'declined';
  const activeIdx = STEPS.findIndex((st) => st.stage === stage);
  const description = params.kind === 'donation' ? tr(params.fund!.label) : monthsLabel(params.months, lang);

  return (
    <Screen modal title={t('checkout')} right={<Badge label={t('sandbox')} tone="info" />}>
      <Card style={s.merchant}>
        <View style={s.juice}>
          <Txt v="bodyStrong" c={color.surface}>Juice</Txt>
          <Txt v="caption" c={color.surface}>by MCB</Txt>
        </View>
        <Txt v="overline" c={color.muted}>{t('amount')}</Txt>
        <Txt v="hero">{mur(params.amount)}</Txt>
        <View style={s.kvs}>
          <KV k={t('merchant')} v="Cockney Hudayetool Islam Society" />
          <KV k={params.kind === 'donation' ? t('fund') : t('months')} v={description} />
        </View>
      </Card>

      {stage === 'review' && (
        <>
          <View style={s.outcome}>
            <Txt v="label" c={color.muted}>{t('outcome')}</Txt>
            <Segmented
              options={[{ value: 'approve', label: t('approve') }, { value: 'decline', label: t('decline') }]}
              value={outcome}
              onChange={setOutcome}
            />
          </View>
          <Button label={t('confirmPay')} icon="lock" onPress={confirm} />
          <Button label={t('cancel')} kind="ghost" onPress={() => router.back()} />
        </>
      )}

      {busy && (
        <Card>
          {STEPS.map((st, i) => {
            const done = i < activeIdx;
            const active = i === activeIdx;
            return (
              <View key={st.stage} style={s.step}>
                <View style={[s.stepIcon, done && s.stepDone]}>
                  {done ? <Icon name="check" size={14} c={color.surface} /> : active ? <ActivityIndicator size="small" color={color.amberDeep} /> : null}
                </View>
                <Txt v={active ? 'bodyStrong' : 'body'} c={done || active ? color.ink : color.muted}>{t(st.label)}</Txt>
              </View>
            );
          })}
        </Card>
      )}

      {stage === 'declined' && (
        <Card style={s.declined}>
          <Icon name="x-circle" size={22} c={color.danger} />
          <View style={s.flex}>
            <Txt v="bodyStrong" c={color.danger}>{t('declined')}</Txt>
            <Txt v="label" c={color.inkSoft}>{t('declinedBody')}</Txt>
          </View>
        </Card>
      )}
      {stage === 'declined' && <Button label={t('tryAgain')} onPress={() => { setOutcome('approve'); setStage('review'); }} />}
    </Screen>
  );
}

const s = StyleSheet.create({
  flex: { flex: 1, gap: 2 },
  merchant: { gap: space.xs, alignItems: 'flex-start' },
  juice: { backgroundColor: color.ink, borderRadius: radius.sm, paddingHorizontal: space.md, paddingVertical: space.sm, marginBottom: space.md, flexDirection: 'row', alignItems: 'baseline', gap: 6 },
  kvs: { alignSelf: 'stretch', marginTop: space.md, borderTopWidth: StyleSheet.hairlineWidth, borderTopColor: color.line, paddingTop: space.sm },
  outcome: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' },
  step: { flexDirection: 'row', alignItems: 'center', gap: space.md, paddingVertical: space.sm },
  stepIcon: { width: 26, height: 26, borderRadius: 13, borderWidth: 1.5, borderColor: color.line, alignItems: 'center', justifyContent: 'center' },
  stepDone: { backgroundColor: color.success, borderColor: color.success },
  declined: { flexDirection: 'row', gap: space.md, backgroundColor: color.dangerSoft, borderColor: '#EDBDB4' },
});
