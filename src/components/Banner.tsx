import { Pressable, StyleSheet, View } from 'react-native';
import Svg, { Path, Rect } from 'react-native-svg';

import { TilePattern } from '@/components/Brand';
import { Txt, tap } from '@/components/ui';
import { color, radius, space } from '@/theme';

const H = 112;
const CUT = 44;

// Stepped blocks on the right edge, as [x, y, w, h, opacity] in a 56 x H box.
const STEPS = [
  [26, 0, 30, 22, 1],
  [44, 22, 12, 26, 0.5],
  [30, 48, 26, 22, 0.85],
  [12, 70, 44, 16, 0.35],
  [40, 86, 16, 26, 1],
] as const;

type Props = {
  id: string;
  title: string;
  /** One line of real content (next event, funds…), not a label. */
  detail?: string;
  accent: string;
  onPress: () => void;
};

/** Full-width dark banner: tile-pattern panel cut on a diagonal, title, stepped accent edge. */
export function Banner({ id, title, detail, accent, onPress }: Props) {
  return (
    <Pressable
      onPress={() => { tap(); onPress(); }}
      accessibilityRole="button"
      accessibilityLabel={title}
      style={({ pressed }) => [s.banner, pressed && s.pressed]}
    >
      <View style={s.art}>
        <TilePattern id={`banner-${id}`} stroke={accent} opacity={0.6} />
        <Svg width={CUT} height={H} style={s.cut}>
          <Path d={`M${CUT} 0 L${CUT} ${H} L0 ${H} Z`} fill={color.night} />
        </Svg>
      </View>
      <View style={s.text}>
        <Txt v="title" c={color.onNight} numberOfLines={1}>{title}</Txt>
        {detail && <Txt v="label" c={color.onNightMuted} numberOfLines={2}>{detail}</Txt>}
      </View>
      <Svg width={56} height={H} style={s.steps}>
        {STEPS.map(([x, y, w, h, o]) => (
          <Rect key={`${x}-${y}`} x={x} y={y} width={w} height={h} fill={accent} opacity={o} />
        ))}
      </Svg>
    </Pressable>
  );
}

const s = StyleSheet.create({
  banner: { height: H, flexDirection: 'row', backgroundColor: color.night, borderRadius: radius.md, overflow: 'hidden' },
  pressed: { opacity: 0.9, transform: [{ scale: 0.99 }] },
  art: { width: '32%', backgroundColor: '#2B261F' },
  cut: { position: 'absolute', right: 0, top: 0 },
  text: { flex: 1, justifyContent: 'center', paddingLeft: space.md, paddingRight: 60, gap: 2 },
  steps: { position: 'absolute', right: 0, top: 0 },
});
