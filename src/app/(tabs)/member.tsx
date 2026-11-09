import { router } from 'expo-router';
import { useEffect, useState } from 'react';
import { Alert, StyleSheet, View } from 'react-native';

import { Logo } from '@/components/Brand';
import { SubscriptionGrid } from '@/components/SubscriptionGrid';
import { Badge, Button, Card, Field, IconButton, Row, Screen, Section, Txt } from '@/components/ui';
import { authenticate, biometricSupport, type BiometricSupport } from '@/lib/biometric';
import { monthName, mur } from '@/lib/i18n';
import { accountSummary, member, useApp, useT } from '@/lib/store';
import { color, space } from '@/theme';

export default function MemberTab() {
  const { state } = useApp();
  const [bio, setBio] = useState<BiometricSupport>({ available: false, label: 'Biometrics' });
  useEffect(() => {
    biometricSupport().then(setBio);
  }, []);
  return state.loggedIn ? <Dashboard bio={bio} /> : <Login bio={bio} />;
}

function Login({ bio }: { bio: BiometricSupport }) {
  const { state, dispatch } = useApp();
  const { t } = useT();
  const [id, setId] = useState(member.number);
  const [password, setPassword] = useState('demo-password');
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string>();

  const logIn = () => {
    setBusy(true);
    setTimeout(() => dispatch({ type: 'login' }), 650); // simulated API round trip
  };

  const unlock = async () => {
    setError(undefined);
    const ok = await authenticate(t('unlockBio'));
    if (ok) dispatch({ type: 'login' });
    else setError(t('bioFailed'));
  };

  return (
    <Screen title={t('memberLogin')} subtitle={t('loginSub')}>
      <View style={s.logo}>
        <Logo size={88} />
      </View>
      {state.biometrics && bio.available && (
        <Card tone="amber" style={s.bioCard}>
          <Txt v="heading">{t('welcomeBack')}</Txt>
          <Button label={`${t('unlockBio')} · ${bio.label}`} icon="unlock" onPress={unlock} />
          {error && <Txt v="caption" c={color.danger}>{error}</Txt>}
        </Card>
      )}
      <Field label={t('emailOrNumber')} value={id} onChangeText={setId} autoCapitalize="characters" autoCorrect={false} />
      <Field label={t('password')} value={password} onChangeText={setPassword} secureTextEntry />
      <Button label={t('logIn')} onPress={logIn} loading={busy} disabled={!id || !password} />
      <Button label={t('forgot')} kind="ghost" onPress={() => Alert.alert(t('forgot'), 'A one-time reset code is sent by email or SMS (FR-016).')} />
      <View style={s.divider}>
        <View style={s.line} />
        <Txt v="caption" c={color.muted}>{t('notMember')}</Txt>
        <View style={s.line} />
      </View>
      <Button label={t('requestAccess')} kind="secondary" icon="user-plus" onPress={() => router.push('/request-access')} />
      <Txt v="caption" c={color.muted} style={s.center}>{t('accessNote')}</Txt>
    </Screen>
  );
}

function Dashboard({ bio }: { bio: BiometricSupport }) {
  const { state, dispatch } = useApp();
  const { t, tr, lang } = useT();
  const { paidUpTo, nextDue, arrearsTotal } = accountSummary(state.months);
  const label = (m?: { m: number; y: number }) => (m ? `${monthName(lang, m.m)} ${m.y}` : '–');

  return (
    <Screen
      title={member.name}
      subtitle={`${t('tabMember')} ${member.number} · ${t('memberSince')} ${member.since}`}
      right={<IconButton icon="settings" label={t('profile')} onPress={() => router.push('/profile')} />}
    >
      <View style={s.badges}>
        <Badge label={t('active')} tone="success" />
        <Badge label={tr(member.category)} tone="neutral" />
      </View>

      <Card tone="night" style={s.status}>
        <View style={s.statusTop}>
          <View style={s.flex}>
            <Txt v="overline" c={color.onNightMuted}>{arrearsTotal > 0 ? t('youOwe') : t('allClear')}</Txt>
            <Txt v="hero" c={arrearsTotal > 0 ? color.amber : color.onNight}>{mur(arrearsTotal)}</Txt>
          </View>
          {arrearsTotal > 0 && <Badge label={t('overdue')} tone="overdue" />}
        </View>
        <View style={s.statusRow}>
          <View style={s.flex}>
            <Txt v="caption" c={color.onNightMuted}>{t('paidUpTo')}</Txt>
            <Txt v="bodyStrong" c={color.onNight}>{label(paidUpTo)}</Txt>
          </View>
          <View style={s.flex}>
            <Txt v="caption" c={color.onNightMuted}>{t('nextDue')}</Txt>
            <Txt v="bodyStrong" c={color.onNight}>
              {label(nextDue)}{nextDue ? ` · ${mur(nextDue.amount)}` : ''}
            </Txt>
          </View>
        </View>
        <Button label={t('payMonths')} icon="credit-card" onPress={() => router.push('/pay')} />
      </Card>

      {bio.available && !state.biometrics && (
        <Card style={s.bioPrompt}>
          <Txt v="label" style={s.flex}>{t('bioPrompt')} ({bio.label})</Txt>
          <Button label={t('enable')} kind="secondary" onPress={() => dispatch({ type: 'biometrics', on: true })} style={s.small} />
        </Card>
      )}

      <Section title={t('subscription')}>
        <Card>
          <SubscriptionGrid months={state.months} />
        </Card>
      </Section>

      <Card style={s.list}>
        <Row icon="file-text" title={t('history')} onPress={() => router.push('/history')} />
        <Row icon="heart" title={t('donate')} onPress={() => router.push('/donate')} />
        <Row icon="folder" title={t('documents')} onPress={() => router.push('/documents')} />
        <Row icon="bar-chart-2" title={t('adminPreview')} onPress={() => router.push('/admin')} last />
      </Card>
    </Screen>
  );
}

const s = StyleSheet.create({
  flex: { flex: 1 },
  center: { textAlign: 'center' },
  logo: { alignItems: 'center', marginVertical: space.sm },
  bioCard: { gap: space.md },
  divider: { flexDirection: 'row', alignItems: 'center', gap: space.md },
  line: { flex: 1, height: StyleSheet.hairlineWidth, backgroundColor: color.line },
  badges: { flexDirection: 'row', gap: space.sm, marginTop: -space.sm },
  status: { padding: space.xl, gap: space.lg },
  statusTop: { flexDirection: 'row', alignItems: 'flex-start' },
  statusRow: { flexDirection: 'row', gap: space.lg, paddingTop: space.md, borderTopWidth: 1, borderTopColor: color.nightLine },
  bioPrompt: { flexDirection: 'row', alignItems: 'center', gap: space.md, paddingVertical: space.md },
  small: { minHeight: 40 },
  list: { padding: 0 },
});
