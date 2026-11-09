import { Linking, StyleSheet, View } from 'react-native';

import { Card, IconButton, Screen, Txt } from '@/components/ui';
import { committee } from '@/data/content';
import { useT } from '@/lib/store';
import { color, font, radius, space } from '@/theme';

const initials = (name: string) =>
  name.replace(/^Haji\s+/, '').split(' ').map((p) => p[0]).slice(0, 2).join('');

export default function Committee() {
  const { t, tr } = useT();
  const [lead, ...rest] = committee;
  return (
    <Screen title={t('tabCommittee')} subtitle={t('committeeSub')}>
      <Card tone="amber" style={s.lead}>
        <View style={[s.avatar, s.avatarLarge]}>
          <Txt v="heading" c={color.amberDeep}>{initials(lead.name)}</Txt>
        </View>
        <View style={s.info}>
          <Txt v="overline" c={color.amberDeep}>{tr(lead.role)}</Txt>
          <Txt v="heading">{lead.name}</Txt>
        </View>
        <Contact phone={lead.phone} email={lead.email} />
      </Card>

      <Card style={s.list}>
        {rest.map((m, i) => (
          <View key={m.name} style={[s.row, i < rest.length - 1 && s.divider]}>
            <View style={s.avatar}>
              <Txt v="label" c={color.amberDeep} style={s.initials}>{initials(m.name)}</Txt>
            </View>
            <View style={s.info}>
              <Txt v="bodyStrong">{m.name}</Txt>
              <Txt v="label" c={color.muted}>{tr(m.role)}</Txt>
            </View>
            <Contact phone={m.phone} email={m.email} />
          </View>
        ))}
      </Card>
      <Txt v="caption" c={color.muted} style={s.note}>
        Contact details shown only where the committee member has consented (FR-005).
      </Txt>
    </Screen>
  );
}

function Contact({ phone, email }: { phone?: string; email?: string }) {
  const { t } = useT();
  return (
    <View style={s.actions}>
      {phone && <IconButton icon="phone" label={t('call')} onPress={() => Linking.openURL(`tel:${phone}`)} />}
      {email && <IconButton icon="mail" label={t('email')} onPress={() => Linking.openURL(`mailto:${email}`)} />}
    </View>
  );
}

const s = StyleSheet.create({
  lead: { flexDirection: 'row', alignItems: 'center', gap: space.md },
  list: { padding: 0 },
  row: { flexDirection: 'row', alignItems: 'center', gap: space.md, padding: space.lg },
  divider: { borderBottomWidth: StyleSheet.hairlineWidth, borderBottomColor: color.line },
  avatar: { width: 44, height: 44, borderRadius: radius.pill, backgroundColor: color.amberSoft, alignItems: 'center', justifyContent: 'center' },
  avatarLarge: { width: 60, height: 60, backgroundColor: color.surface },
  initials: { fontFamily: font.semibold },
  info: { flex: 1, gap: 2 },
  actions: { flexDirection: 'row', gap: space.sm },
  note: { textAlign: 'center' },
});
