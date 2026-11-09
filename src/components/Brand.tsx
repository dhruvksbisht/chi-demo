import Svg, { Circle, ClipPath, Defs, G, Path, Pattern, Rect, Text as SvgText } from 'react-native-svg';

import { color } from '@/theme';

/**
 * Placeholder mark built from the brief: a charcoal wave over an amber sun disc
 * with "CHI" lettering. Swap for CHI's supplied vector logo.
 */
export function Logo({ size = 40, lettering = true }: { size?: number; lettering?: boolean }) {
  return (
    <Svg width={size} height={size} viewBox="0 0 100 100" accessibilityLabel="CHI logo">
      <Defs>
        <ClipPath id="disc">
          <Circle cx="50" cy="50" r="48" />
        </ClipPath>
      </Defs>
      <Circle cx="50" cy="50" r="48" fill={color.amber} />
      <G clipPath="url(#disc)">
        <Path d="M0 70 C 20 58, 34 80, 52 68 S 82 56, 100 66 V 100 H 0 Z" fill={color.ink} />
        <Path d="M0 80 C 18 72, 34 90, 54 80 S 84 70, 100 78" stroke={color.amberSoft} strokeWidth="2.5" fill="none" opacity={0.7} />
      </G>
      {lettering && (
        <SvgText x="50" y="54" fontSize="26" fontWeight="700" fill={color.ink} textAnchor="middle" letterSpacing="1">
          CHI
        </SvgText>
      )}
    </Svg>
  );
}

/** Eight-pointed star (two rotated squares), used as a quiet geometric motif. */
export function Star({ size = 160, stroke = color.amber, opacity = 0.18 }: { size?: number; stroke?: string; opacity?: number }) {
  return (
    <Svg width={size} height={size} viewBox="0 0 100 100" opacity={opacity}>
      <Rect x="20" y="20" width="60" height="60" stroke={stroke} strokeWidth="1.2" fill="none" />
      <Path d="M50 7.6 L92.4 50 L50 92.4 L7.6 50 Z" stroke={stroke} strokeWidth="1.2" fill="none" />
      <Circle cx="50" cy="50" r="18" stroke={stroke} strokeWidth="1.2" fill="none" />
      <Circle cx="50" cy="50" r="44" stroke={stroke} strokeWidth="0.8" fill="none" />
    </Svg>
  );
}

type TileProps = { id: string; tile?: number; stroke?: string; opacity?: number };

/**
 * Repeating eight-point-star lattice, the tile work of mosque interiors. Stands in for
 * photography on banners and news cards. `id` must be unique per instance (it names an SVG pattern).
 */
export function TilePattern({ id, tile = 30, stroke = color.amber, opacity = 0.5 }: TileProps) {
  const c = tile / 2;
  const half = tile * 0.27; // half-side of the square
  const d = half * Math.SQRT2; // the diamond's tips sit on the square's circumcircle
  return (
    <Svg width="100%" height="100%" style={{ position: 'absolute' }}>
      <Defs>
        <Pattern id={id} patternUnits="userSpaceOnUse" width={tile} height={tile}>
          <Rect x={c - half} y={c - half} width={half * 2} height={half * 2} stroke={stroke} strokeWidth={1} fill="none" />
          <Path d={`M${c} ${c - d} L${c + d} ${c} L${c} ${c + d} L${c - d} ${c} Z`} stroke={stroke} strokeWidth={1} fill="none" />
        </Pattern>
      </Defs>
      <Rect width="100%" height="100%" fill={`url(#${id})`} opacity={opacity} />
    </Svg>
  );
}
