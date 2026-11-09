import { Tabs } from 'expo-router';
import { useMemo } from 'react';
import type { ColorValue } from 'react-native';

import { Icon, tap, type IconName } from '@/components/ui';
import type { StringKey } from '@/lib/i18n';
import { useT } from '@/lib/store';
import { color, font } from '@/theme';

const TABS: { name: string; label: StringKey; icon: IconName }[] = [
  { name: 'index', label: 'tabHome', icon: 'home' },
  { name: 'committee', label: 'tabCommittee', icon: 'users' },
  { name: 'faq', label: 'tabFaq', icon: 'help-circle' },
  { name: 'contacts', label: 'tabContacts', icon: 'map-pin' },
  { name: 'member', label: 'tabMember', icon: 'user' },
];

// Navigator config must keep a stable identity across renders. This layout re-renders on
// every store update, and fresh option objects each time make the router re-apply them,
// which loops while a stacked screen sits above the tabs.
const SCREEN_OPTIONS = {
  headerShown: false,
  tabBarActiveTintColor: color.amber,
  tabBarInactiveTintColor: color.onNightMuted,
  tabBarLabelStyle: { fontFamily: font.medium, fontSize: 11 },
  tabBarStyle: { backgroundColor: color.night, borderTopColor: color.night },
  sceneStyle: { backgroundColor: color.bg },
} as const;
const LISTENERS = { tabPress: tap };

export default function TabLayout() {
  const { t } = useT();
  const screens = useMemo(
    () =>
      TABS.map((tab) => ({
        name: tab.name,
        options: {
          title: t(tab.label),
          tabBarIcon: ({ color: c }: { color: ColorValue }) => <Icon name={tab.icon} size={22} c={String(c)} />,
        },
      })),
    [t],
  );

  return (
    <Tabs screenOptions={SCREEN_OPTIONS} screenListeners={LISTENERS}>
      {screens.map((sc) => (
        <Tabs.Screen key={sc.name} name={sc.name} options={sc.options} />
      ))}
    </Tabs>
  );
}
