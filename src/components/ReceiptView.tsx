import { useState } from 'react';
import { StyleSheet, View } from 'react-native';

import { Badge, Button, Card, Icon, KV, Txt } from '@/components/ui';
import { funds } from '@/data/content';
import { longDate, mur } from '@/lib/i18n';
import { methodLabel, monthsLabel, shareReceipt } from '@/lib/receipt';
import { member, useT, type Payment } from '@/lib/store';
import { color, space } from '@/theme';

type Props = {
  payment: Payment;
  /** Just paid: show the success mark, email note and a way back. */
  onDone?: () => void;
};

/** Receipt details plus PDF download; shared by checkout success and payment history. */
export function ReceiptView({ payment: p, onDone }: Props) {
  const { t, tr, lang } = useT();
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string>();
  const fund = funds.find((f) => f.id === p.fund);
  const d = new Date(p.date);

  const download = async () => {
    setBusy(true);
    setError(undefined);
    try {
      await shareReceipt(p, fund?.label.en);
    } catch {
      setError('Could not create the PDF. Please try again.');
    } finally {
      setBusy(false);
    }
  };

  return (
    <>
      {onDone && (
        <View style={s.hero}>
          <View style={s.check}>
            <Icon name="check" size={40} c={color.success} />
          </View>
        </View>
      )}
      <Card>
        <View style={s.head}>
          <Txt v="overline" c={color.muted}>{t('receiptNo')} {p.receiptNo}</Txt>
          <Badge label={p.method === 'juice' ? 'Juice' : t('manual')} tone={p.method === 'juice' ? 'success' : 'amber'} />
        </View>
        <Txt v="title" style={s.amount}>{mur(p.amount)}</Txt>
        {p.kind === 'subscription' ? (
          <KV k={t('months')} v={monthsLabel(p.monthKeys, lang)} />
        ) : (
          <KV k={t('fund')} v={fund ? tr(fund.label) : '–'} />
        )}
        <KV k={t('date')} v={longDate(lang, d.getFullYear(), d.getMonth() + 1, d.getDate())} />
        <KV k={t('method')} v={methodLabel(p)} />
        <KV k={t('reference')} v={p.ref} />
        <KV k={t('tabMember')} v={member.number} />
      </Card>

      <Button label={t('downloadReceipt')} kind="secondary" icon="download" onPress={download} loading={busy} />
      {error && <Txt v="caption" c={color.danger}>{error}</Txt>}
      {onDone && <Button label={t('backToAccount')} onPress={onDone} />}
      {onDone && (
        <Txt v="caption" c={color.muted} style={s.center}>
          {t('emailCopy')} {member.email}
        </Txt>
      )}
    </>
  );
}

const s = StyleSheet.create({
  center: { textAlign: 'center' },
  hero: { alignItems: 'center', marginTop: -space.sm },
  check: { width: 84, height: 84, borderRadius: 42, backgroundColor: color.successSoft, alignItems: 'center', justifyContent: 'center', borderWidth: 2, borderColor: '#BFDDC9' },
  head: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  amount: { marginTop: space.sm, marginBottom: space.sm },
});
