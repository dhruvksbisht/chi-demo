import { router } from 'expo-router';
import { Alert } from 'react-native';

import { Card, Icon, Row, Screen, Txt } from '@/components/ui';
import { documents } from '@/data/content';
import { useApp, useT } from '@/lib/store';
import { color } from '@/theme';

export default function Documents() {
  const { state } = useApp();
  const { t, tr } = useT();

  const open = (title: string, membersOnly: boolean) => {
    if (membersOnly && !state.loggedIn) {
      router.dismissTo('/member');
      return;
    }
    Alert.alert(title, t('docPreview'));
  };

  return (
    <Screen back title={t('documents')}>
      <Card style={{ padding: 0 }}>
        {documents.map((d, i) => {
          const locked = d.membersOnly && !state.loggedIn;
          return (
            <Row
              key={d.id}
              icon={locked ? 'lock' : 'file-text'}
              title={tr(d.title)}
              subtitle={d.membersOnly ? `${d.meta} · ${t('membersOnly')}` : d.meta}
              right={locked ? undefined : <Icon name="download" size={18} c={color.muted} />}
              chevron={locked}
              onPress={() => open(tr(d.title), d.membersOnly)}
              last={i === documents.length - 1}
            />
          );
        })}
      </Card>
      {!state.loggedIn && <Txt v="caption" c={color.muted}>{t('loginToView')}</Txt>}
    </Screen>
  );
}
