import { useLocalSearchParams } from 'expo-router';

import { ReceiptView } from '@/components/ReceiptView';
import { Screen, Txt } from '@/components/ui';
import { useApp, useT } from '@/lib/store';
import { color } from '@/theme';

export default function Receipt() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const { state } = useApp();
  const { t } = useT();
  const p = state.payments.find((x) => x.id === id);

  return (
    <Screen back title={p ? `${t('receiptNo')} ${p.receiptNo}` : t('receiptNo')}>
      {p ? <ReceiptView payment={p} /> : <Txt c={color.muted}>Receipt not found.</Txt>}
    </Screen>
  );
}
