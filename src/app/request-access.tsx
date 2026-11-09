import { router } from 'expo-router';
import { useState } from 'react';
import { Pressable, StyleSheet, View } from 'react-native';

import { Button, Card, Field, Icon, Screen, Txt, tap } from '@/components/ui';
import type { StringKey } from '@/lib/i18n';
import { useApp, useT } from '@/lib/store';
import { color, space } from '@/theme';

type Form = { name: string; nic: string; mobile: string; email: string; memberNo: string; consent: boolean };
type Errors = Partial<Record<keyof Form, StringKey>>;

// Mauritian NIC: surname initial + 13 alphanumerics. Mobiles: 8 digits starting with 5.
const NIC = /^[A-Z]\d{12}[A-Z0-9]$/;
const MOBILE = /^5\d{7}$/;
const EMAIL = /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/;

function validate(f: Form): Errors {
  const e: Errors = {};
  if (f.name.trim().split(/\s+/).length < 2) e.name = 'errName';
  if (!NIC.test(f.nic)) e.nic = 'errNic';
  if (!MOBILE.test(f.mobile.replace(/^\+?230/, ''))) e.mobile = 'errMobile';
  if (!EMAIL.test(f.email.trim())) e.email = 'errEmail';
  if (!f.consent) e.consent = 'errConsent';
  return e;
}

export default function RequestAccess() {
  const { dispatch } = useApp();
  const { t } = useT();
  const [form, setForm] = useState<Form>({ name: '', nic: '', mobile: '', email: '', memberNo: '', consent: false });
  const [errors, setErrors] = useState<Errors>({});
  const [busy, setBusy] = useState(false);
  const [sent, setSent] = useState(false);

  const set = <K extends keyof Form>(key: K) => (value: Form[K]) => {
    setForm((f) => ({ ...f, [key]: value }));
    if (errors[key]) setErrors((e) => ({ ...e, [key]: undefined }));
  };

  const submit = () => {
    const e = validate(form);
    setErrors(e);
    if (Object.keys(e).length) return;
    setBusy(true);
    setTimeout(() => {
      dispatch({
        type: 'requestSubmitted',
        request: {
          id: `r${Date.now()}`,
          name: form.name.trim(),
          nic: form.nic,
          mobile: form.mobile,
          email: form.email.trim(),
          // Demo rule: a member number counts as a match. Production matches server-side
          // against the register by NIC and member number (FR-012).
          matched: form.memberNo.trim().length > 0,
          status: 'pending',
          submitted: new Date().toISOString(),
        },
      });
      setSent(true);
    }, 700);
  };

  if (sent) {
    return (
      <Screen modal title={t('requestSent')}>
        <View style={s.done}>
          <View style={s.doneIcon}><Icon name="send" size={34} c={color.success} /></View>
          <Txt c={color.inkSoft} style={s.center}>{t('requestSentBody')}</Txt>
        </View>
        <Button label={t('done')} onPress={() => router.back()} />
        <Button label={t('adminPreview')} kind="ghost" icon="bar-chart-2" onPress={() => router.replace('/admin')} />
      </Screen>
    );
  }

  return (
    <Screen modal title={t('requestAccess')} subtitle={t('requestSub')}>
      <Field label={t('fullName')} value={form.name} onChangeText={set('name')} autoComplete="name" error={errors.name && t(errors.name)} />
      <Field
        label={t('nic')}
        value={form.nic}
        onChangeText={(v) => set('nic')(v.toUpperCase().replace(/\s/g, '').slice(0, 14))}
        placeholder="B1234567890123"
        autoCapitalize="characters"
        autoCorrect={false}
        error={errors.nic && t(errors.nic)}
      />
      <Field label={t('mobile')} value={form.mobile} onChangeText={set('mobile')} placeholder="5xxx xxxx" keyboardType="phone-pad" error={errors.mobile && t(errors.mobile)} />
      <Field label={t('email')} value={form.email} onChangeText={set('email')} keyboardType="email-address" autoCapitalize="none" error={errors.email && t(errors.email)} />
      <Field label={t('memberNo')} value={form.memberNo} onChangeText={set('memberNo')} autoCapitalize="characters" />

      <Pressable
        onPress={() => { tap(); set('consent')(!form.consent); }}
        accessibilityRole="checkbox"
        accessibilityState={{ checked: form.consent }}
        style={s.consent}
      >
        <View style={[s.box, form.consent && s.boxOn, !!errors.consent && s.boxError]}>
          {form.consent && <Icon name="check" size={14} c={color.ink} />}
        </View>
        <Txt v="label" c={color.inkSoft} style={s.flex}>{t('consent')}</Txt>
      </Pressable>
      {errors.consent && <Txt v="caption" c={color.danger}>{t(errors.consent)}</Txt>}

      <Button label={t('submit')} onPress={submit} loading={busy} />
      <Card tone="sunken" style={s.note}>
        <Icon name="shield" size={16} c={color.muted} />
        <Txt v="caption" c={color.muted} style={s.flex}>
          NIC numbers are encrypted at rest and only visible to the secretary (SEC-02).
        </Txt>
      </Card>
    </Screen>
  );
}

const s = StyleSheet.create({
  flex: { flex: 1 },
  center: { textAlign: 'center' },
  consent: { flexDirection: 'row', gap: space.md, alignItems: 'flex-start' },
  box: { width: 24, height: 24, borderRadius: 7, borderWidth: 1.5, borderColor: color.line, backgroundColor: color.surface, alignItems: 'center', justifyContent: 'center' },
  boxOn: { backgroundColor: color.amber, borderColor: color.amber },
  boxError: { borderColor: color.danger },
  note: { flexDirection: 'row', gap: space.sm, alignItems: 'center', paddingVertical: space.md },
  done: { alignItems: 'center', gap: space.lg, marginVertical: space.lg },
  doneIcon: { width: 84, height: 84, borderRadius: 42, backgroundColor: color.successSoft, alignItems: 'center', justifyContent: 'center' },
});
