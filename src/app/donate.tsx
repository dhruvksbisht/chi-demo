import { router } from 'expo-router';
import { useState } from 'react';
import { Pressable, StyleSheet, View } from 'react-native';

import { Button, Field, Screen, Section, Txt, tap } from '@/components/ui';
import { funds } from '@/data/content';
import { mur } from '@/lib/i18n';
import { useT } from '@/lib/store';
import { color, radius, space } from '@/theme';

const PRESETS = [250, 500, 1000, 2500];
const MAX = 500_000;

export default function Donate() {
  const { t, tr } = useT();
  const [fund, setFund] = useState(funds[0].id);
  const [amount, setAmount] = useState('500');
  const value = Number(amount);
  const valid = Number.isInteger(value) && value >= 50 && value <= MAX;

  return (
    <Screen
      back
      title={t('donate')}
      subtitle={t('donateSub')}
      footer={
        <Button
          label={valid ? `${t('donateNow')} · ${mur(value)}` : t('donateNow')}
          icon="heart"
          disabled={!valid}
          onPress={() => router.push({ pathname: '/checkout', params: { kind: 'donation', fund, amount: String(value) } })}
        />
      }
    >
      <Section title={t('fund')}>
        <View style={s.grid}>
          {funds.map((f) => (
            <Choice key={f.id} label={tr(f.label)} on={f.id === fund} onPress={() => setFund(f.id)} />
          ))}
        </View>
      </Section>
      <Section title={t('amount')}>
        <View style={s.grid}>
          {PRESETS.map((p) => (
            <Choice key={p} label={mur(p)} on={value === p} onPress={() => setAmount(String(p))} />
          ))}
        </View>
        <Field label="MUR" value={amount} onChangeText={(v) => setAmount(v.replace(/\D/g, ''))} keyboardType="number-pad" error={!valid && amount ? 'MUR 50 – 500,000' : undefined} />
      </Section>
    </Screen>
  );
}

function Choice({ label, on, onPress }: { label: string; on: boolean; onPress: () => void }) {
  return (
    <Pressable
      onPress={() => { tap(); onPress(); }}
      accessibilityRole="radio"
      accessibilityState={{ selected: on }}
      style={[s.choice, on && s.choiceOn]}
    >
      <Txt v="bodyStrong" c={on ? color.ink : color.inkSoft}>{label}</Txt>
    </Pressable>
  );
}

const s = StyleSheet.create({
  grid: { flexDirection: 'row', flexWrap: 'wrap', gap: space.sm },
  choice: { width: '48.5%', flexGrow: 1, minHeight: 56, borderRadius: radius.md, borderWidth: 1.5, borderColor: color.line, backgroundColor: color.surface, alignItems: 'center', justifyContent: 'center' },
  choiceOn: { borderColor: color.amber, backgroundColor: color.amberSoft },
});
