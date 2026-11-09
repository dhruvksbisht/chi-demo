import * as Haptics from 'expo-haptics';
import * as Location from 'expo-location';
import { useEffect, useMemo, useRef, useState } from 'react';
import { Animated, Easing, Platform, StyleSheet, View } from 'react-native';
import Svg, { Circle, G, Line, Path, Rect, Text as SvgText } from 'react-native-svg';

import { Card, Icon, Screen, Txt } from '@/components/ui';
import { useT } from '@/lib/store';
import { qiblaBearing } from '@/lib/time';
import { color, font, space } from '@/theme';

const SIZE = 290;
const R = SIZE / 2;
const ALIGNED_DEG = 5;
const QIBLA = qiblaBearing();

/** Live device heading in degrees from true north, or null when there is no compass. */
function useHeading(): number | null | undefined {
  // undefined = still starting, null = no compass on this device.
  const [heading, setHeading] = useState<number | null | undefined>(Platform.OS === 'web' ? null : undefined);
  useEffect(() => {
    if (Platform.OS === 'web') return;
    let sub: Location.LocationSubscription | undefined;
    let cancelled = false;
    (async () => {
      try {
        await Location.requestForegroundPermissionsAsync(); // only needed for true (not magnetic) north
        const s = await Location.watchHeadingAsync((h) => setHeading(h.trueHeading >= 0 ? h.trueHeading : h.magHeading));
        if (cancelled) s.remove();
        else sub = s;
      } catch {
        setHeading(null);
      }
    })();
    return () => {
      cancelled = true;
      sub?.remove();
    };
  }, []);
  return heading;
}

/** Signed shortest angle from b to a, in (-180, 180]. */
const delta = (a: number, b: number) => ((((a - b) % 360) + 540) % 360) - 180;

export default function Qibla() {
  const { t } = useT();
  const heading = useHeading();
  const [rotation] = useState(() => new Animated.Value(0));
  const spin = useMemo(
    () => rotation.interpolate({ inputRange: [-360, 360], outputRange: ['-360deg', '360deg'], extrapolate: 'extend' }),
    [rotation],
  );
  const unwrapped = useRef(0);
  const wasAligned = useRef(false);

  const hasCompass = typeof heading === 'number';
  const offset = hasCompass ? delta(QIBLA, heading) : null;
  const aligned = offset !== null && Math.abs(offset) <= ALIGNED_DEG;

  useEffect(() => {
    if (!hasCompass) return;
    // Rotate the dial the short way round so 359° → 1° never spins a full turn.
    unwrapped.current += delta(-heading, unwrapped.current);
    Animated.timing(rotation, {
      toValue: unwrapped.current,
      duration: 160,
      easing: Easing.out(Easing.quad),
      useNativeDriver: Platform.OS !== 'web',
    }).start();
  }, [heading, hasCompass, rotation]);

  useEffect(() => {
    if (aligned && !wasAligned.current && Platform.OS !== 'web') Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    wasAligned.current = aligned;
  }, [aligned]);

  return (
    <Screen back title={t('qibla')} subtitle={hasCompass ? t('qiblaHint') : heading === null ? t('qiblaNoSensor') : ' '}>
      <View style={s.stage}>
        <View style={[s.pointer, aligned && s.pointerOn]} />
        <View style={[s.ring, aligned && s.ringOn]}>
          <Animated.View style={{ transform: [{ rotate: spin }] }}>
            <Dial />
          </Animated.View>
        </View>
      </View>

      <Card tone={aligned ? 'amber' : 'surface'} style={s.readout}>
        <Icon name={aligned ? 'check-circle' : 'navigation'} size={22} c={aligned ? color.success : color.amberDeep} />
        <View style={s.flex}>
          <Txt v="bodyStrong">{aligned ? t('qiblaAligned') : `${t('qiblaBearing')}`}</Txt>
          <Txt v="label" c={color.muted}>
            {QIBLA.toFixed(1)}° {offset !== null && !aligned ? `· ${offset > 0 ? '→' : '←'} ${Math.abs(Math.round(offset))}°` : ''}
          </Txt>
        </View>
      </Card>
    </Screen>
  );
}

/** Compass card drawn in SVG; north at top, the Qibla marker sits at its bearing. */
function Dial() {
  const ticks = Array.from({ length: 72 }, (_, i) => i * 5);
  const rad = ((QIBLA - 90) * Math.PI) / 180;
  const qx = R + Math.cos(rad) * (R - 46);
  const qy = R + Math.sin(rad) * (R - 46);
  return (
    <Svg width={SIZE} height={SIZE}>
      <Circle cx={R} cy={R} r={R - 2} fill={color.surface} />
      <Circle cx={R} cy={R} r={R - 40} fill={color.bg} stroke={color.line} />
      {ticks.map((deg) => {
        const major = deg % 30 === 0;
        return (
          <Line
            key={deg}
            x1={R} y1={10} x2={R} y2={major ? 24 : 17}
            stroke={major ? color.ink : color.muted}
            strokeWidth={major ? 2 : 1}
            transform={`rotate(${deg} ${R} ${R})`}
          />
        );
      })}
      {(['N', 'E', 'S', 'W'] as const).map((l, i) => (
        <G key={l} transform={`rotate(${i * 90} ${R} ${R})`}>
          <SvgText x={R} y={44} fontSize={15} fontFamily={font.semibold} fill={l === 'N' ? color.danger : color.ink} textAnchor="middle">{l}</SvgText>
        </G>
      ))}
      <Line x1={R} y1={R} x2={qx} y2={qy} stroke={color.amber} strokeWidth={3} strokeLinecap="round" />
      <Circle cx={R} cy={R} r={6} fill={color.ink} />
      <G transform={`translate(${qx - 12} ${qy - 12})`}>
        <Rect width={24} height={24} rx={4} fill={color.ink} />
        <Path d="M0 8 H24" stroke={color.amber} strokeWidth={2.5} />
      </G>
    </Svg>
  );
}

const s = StyleSheet.create({
  flex: { flex: 1 },
  stage: { alignItems: 'center', marginTop: space.md },
  pointer: { width: 0, height: 0, borderLeftWidth: 11, borderRightWidth: 11, borderBottomWidth: 16, borderLeftColor: 'transparent', borderRightColor: 'transparent', borderBottomColor: color.muted, marginBottom: space.sm },
  pointerOn: { borderBottomColor: color.success },
  ring: { borderRadius: SIZE, borderWidth: 3, borderColor: color.line, padding: 4, backgroundColor: color.surface },
  ringOn: { borderColor: color.success },
  readout: { flexDirection: 'row', alignItems: 'center', gap: space.md },
});
