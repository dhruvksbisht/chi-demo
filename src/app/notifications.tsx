import { router, type Href } from 'expo-router';
import { useEffect } from 'react';
import { Pressable, StyleSheet, View } from 'react-native';

import { ago } from '@/components/NewsCard';
import { Card, Icon, Screen, Txt, styles as ui, type IconName } from '@/components/ui';
import type { Localized } from '@/lib/i18n';
import { useApp, useT } from '@/lib/store';
import { color, radius, space } from '@/theme';

const INBOX: { icon: IconName; daysAgo: number; title: Localized; body: Localized; href: Href }[] = [
  {
    icon: 'credit-card', daysAgo: 0, href: '/member',
    title: { en: 'Subscription due', fr: 'Cotisation à payer' },
    body: { en: 'Your subscription for this month is due. You also have one overdue month.', fr: 'Votre cotisation du mois est due. Un mois est également en retard.' },
  },
  {
    icon: 'bell', daysAgo: 1, href: '/news/agm-2026',
    title: { en: 'AGM on 29 November', fr: 'AGA le 29 novembre' },
    body: { en: 'Agenda and proxy forms are now available.', fr: 'Ordre du jour et procurations disponibles.' },
  },
  {
    icon: 'moon', daysAgo: 2, href: '/news/janaza-1',
    title: { en: 'Janaza announcement', fr: 'Annonce de janaza' },
    body: { en: 'Janaza salah after Dhuhr at the society mosque.', fr: 'Salat al-janaza après Dhuhr à la mosquée.' },
  },
  {
    icon: 'calendar', daysAgo: 4, href: '/events',
    title: { en: 'Seerah lecture this week', fr: 'Conférence sur la Sîra cette semaine' },
    body: { en: 'After Isha in the society mosque. RSVP in the app.', fr: 'Après Isha à la mosquée. Inscription dans l’application.' },
  },
];

export default function Notifications() {
  const { state, dispatch } = useApp();
  const { t, tr, lang } = useT();
  const unread = !state.inboxRead;

  // Opening the inbox marks it read, after a beat so the unread state is visible.
  useEffect(() => {
    const id = setTimeout(() => dispatch({ type: 'inboxRead' }), 2500);
    return () => clearTimeout(id);
  }, [dispatch]);

  return (
    <Screen back title={t('notifications')}>
      <Card style={s.list}>
        {INBOX.map((n, i) => (
          <Pressable
            key={i}
            onPress={() => router.push(n.href)}
            accessibilityRole="button"
            style={({ pressed }) => [s.row, i < INBOX.length - 1 && s.divider, pressed && ui.pressed]}
          >
            <View style={s.icon}>
              <Icon name={n.icon} size={18} c={color.amberDeep} />
            </View>
            <View style={ui.flex}>
              <View style={s.head}>
                <Txt v="bodyStrong" style={ui.flex}>{tr(n.title)}</Txt>
                <Txt v="caption" c={color.muted}>{ago(lang, n.daysAgo)}</Txt>
              </View>
              <Txt v="label" c={color.inkSoft}>{tr(n.body)}</Txt>
            </View>
            {unread && i < 2 && <View style={s.dot} />}
          </Pressable>
        ))}
      </Card>
    </Screen>
  );
}

const s = StyleSheet.create({
  list: { padding: 0 },
  row: { flexDirection: 'row', gap: space.md, padding: space.lg, alignItems: 'flex-start' },
  divider: { borderBottomWidth: StyleSheet.hairlineWidth, borderBottomColor: color.line },
  icon: { width: 36, height: 36, borderRadius: radius.sm, backgroundColor: color.amberSoft, alignItems: 'center', justifyContent: 'center' },
  head: { flexDirection: 'row', gap: space.sm, alignItems: 'center' },
  dot: { width: 8, height: 8, borderRadius: 4, backgroundColor: color.danger, marginTop: 6 },
});
