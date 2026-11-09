import { router } from 'expo-router';
import { useEffect, useState } from 'react';
import { Alert, StyleSheet, View } from 'react-native';

import { Button, Card, KV, Row, Screen, Section, Segmented, Toggle, Txt } from '@/components/ui';
import { biometricSupport } from '@/lib/biometric';
import type { Lang } from '@/lib/i18n';
import { member, useApp, useT } from '@/lib/store';
import { color, space } from '@/theme';

export default function Profile() {
  const { state, dispatch } = useApp();
  const { t, tr } = useT();
  const [bioLabel, setBioLabel] = useState<string>();
  useEffect(() => {
    biometricSupport().then((b) => setBioLabel(b.available ? b.label : undefined));
  }, []);

  const logOut = () => {
    dispatch({ type: 'logout' });
    router.dismissTo('/member');
  };

  return (
    <Screen back title={t('profile')}>
      <Section title={t('personal')}>
        <Card>
          <KV k={t('fullName')} v={member.name} />
          <KV k={t('tabMember')} v={member.number} />
          <KV k={t('category')} v={tr(member.category)} />
          <KV k={t('email')} v={member.email} />
          <KV k={t('mobile')} v={member.phone} />
        </Card>
      </Section>

      <Card style={s.list}>
        <View style={s.setting}>
          <Txt v="bodyStrong" style={s.flex}>{t('language')}</Txt>
          <Segmented
            options={[{ value: 'en', label: 'English' }, { value: 'fr', label: 'Français' }]}
            value={state.lang}
            onChange={(l: Lang) => dispatch({ type: 'lang', lang: l })}
          />
        </View>
        <Row
          icon="bell"
          title={t('reminders')}
          subtitle={t('remindersSub')}
          right={<Toggle value={state.reminders} onChange={(on) => dispatch({ type: 'reminders', on })} label={t('reminders')} />}
        />
        <Row
          icon="unlock"
          title={t('biometrics')}
          subtitle={bioLabel ?? 'Not available on this device'}
          right={<Toggle value={state.biometrics && !!bioLabel} onChange={(on) => dispatch({ type: 'biometrics', on })} label={t('biometrics')} />}
          last
        />
      </Card>

      <Card style={s.list}>
        <Row icon="bar-chart-2" title={t('adminPreview')} onPress={() => router.push('/admin')} />
        <Row icon="trash-2" title={t('deleteData')} subtitle="Data Protection Act 2017" onPress={() => Alert.alert(t('deleteData'), t('deleteSent'))} last />
      </Card>

      <Button label={t('logOut')} kind="danger" icon="log-out" onPress={logOut} />
      <Txt v="caption" c={color.muted} style={s.center}>CHI app · demo build 0.1</Txt>
    </Screen>
  );
}

const s = StyleSheet.create({
  flex: { flex: 1 },
  center: { textAlign: 'center' },
  list: { padding: 0 },
  setting: { flexDirection: 'row', alignItems: 'center', padding: space.lg, borderBottomWidth: StyleSheet.hairlineWidth, borderBottomColor: color.line },
});
