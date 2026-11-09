import { StyleSheet } from 'react-native';

import { Card, Screen, Txt } from '@/components/ui';
import { duas } from '@/data/content';
import { useT } from '@/lib/store';
import { color, font, space } from '@/theme';

export default function Duas() {
  const { t, tr } = useT();
  return (
    <Screen back title={t('duas')}>
      {duas.map((d) => (
        <Card key={d.id} style={s.card}>
          <Txt v="overline" c={color.amberDeep}>{tr(d.title)}</Txt>
          <Txt style={s.arabic}>{d.arabic}</Txt>
          <Txt v="label" c={color.inkSoft} style={s.translit}>{d.translit}</Txt>
          <Txt c={color.ink}>{tr(d.meaning)}</Txt>
          <Txt v="caption" c={color.muted}>{d.source}</Txt>
        </Card>
      ))}
    </Screen>
  );
}

const s = StyleSheet.create({
  card: { gap: space.sm },
  arabic: { fontFamily: font.arabic, fontSize: 26, lineHeight: 50, textAlign: 'right', writingDirection: 'rtl', color: color.ink },
  translit: { fontFamily: font.displayItalic },
});
