import { Linking, Platform, StyleSheet, View } from 'react-native';
import Svg, { Circle, Path, Rect } from 'react-native-svg';

import { Button, Card, IconButton, Row, Screen, Section, Txt } from '@/components/ui';
import { contacts } from '@/data/content';
import { useT } from '@/lib/store';
import { color, space } from '@/theme';

const { lat, lng } = contacts.coords;
const directionsUrl = Platform.select({
  ios: `http://maps.apple.com/?daddr=${lat},${lng}`,
  default: `https://www.google.com/maps/dir/?api=1&destination=${lat},${lng}`,
});

export default function Contacts() {
  const { t, tr } = useT();
  return (
    <Screen title={t('tabContacts')} subtitle={t('contactsSub')}>
      <Card style={s.mapCard}>
        <MapArt />
        <View style={s.mapFooter}>
          <View style={s.flex}>
            <Txt v="bodyStrong">Cockney Hudayetool Islam Society</Txt>
            <Txt v="label" c={color.muted}>{contacts.address}</Txt>
          </View>
        </View>
        <Button label={t('directions')} icon="navigation" onPress={() => Linking.openURL(directionsUrl)} style={s.directions} />
      </Card>

      <Card style={s.list}>
        <Row icon="phone" title={t('call')} subtitle={contacts.phone} onPress={() => Linking.openURL(`tel:${contacts.phone.replace(/\s/g, '')}`)} />
        <Row icon="message-circle" title={t('whatsapp')} subtitle={contacts.phone} onPress={() => Linking.openURL(`https://wa.me/${contacts.whatsapp}`)} />
        <Row icon="mail" title={t('email')} subtitle={contacts.email} onPress={() => Linking.openURL(`mailto:${contacts.email}`)} />
        <Row icon="clock" title={t('officeHours')} subtitle={tr(contacts.hours)} last />
      </Card>

      <Section title={t('followUs')}>
        <View style={s.social}>
          {contacts.social.map((so) => (
            <IconButton key={so.label} icon={so.icon} label={so.label} onPress={() => Linking.openURL(so.url)} />
          ))}
        </View>
      </Section>
    </Screen>
  );
}

/** Stylised, offline-safe map illustration; the button hands off to the device's maps app. */
function MapArt() {
  return (
    <View style={s.map}>
      <Svg width="100%" height="100%" viewBox="0 0 340 170" preserveAspectRatio="xMidYMid slice">
        <Rect width="340" height="170" fill={color.sunken} />
        <Path d="M0 120 C 60 100, 90 150, 160 130 S 270 90, 340 110 V170 H0Z" fill="#DCE9F0" />
        <Path d="M20 0 L 120 170 M 0 60 L 340 40 M 200 0 L 240 170 M 290 0 L 260 170" stroke={color.surface} strokeWidth="7" />
        <Path d="M0 90 L 340 75" stroke={color.surface} strokeWidth="11" />
        <Circle cx="175" cy="78" r="22" fill={color.amber} opacity={0.25} />
        <Circle cx="175" cy="78" r="9" fill={color.amber} stroke={color.ink} strokeWidth="2.5" />
      </Svg>
    </View>
  );
}

const s = StyleSheet.create({
  flex: { flex: 1 },
  mapCard: { padding: 0, overflow: 'hidden' },
  map: { height: 160, backgroundColor: color.sunken },
  mapFooter: { flexDirection: 'row', padding: space.lg, paddingBottom: space.md },
  directions: { marginHorizontal: space.lg, marginBottom: space.lg },
  list: { padding: 0 },
  social: { flexDirection: 'row', gap: space.md },
});
