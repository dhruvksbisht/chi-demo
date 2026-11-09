/**
 * Design tokens. Palette is derived from the CHI logo (amber sun disc, charcoal wave)
 * per section 10 of the requirements. Text colours are checked for WCAG AA on `bg`.
 */
export const color = {
  bg: '#FBF6EE', // warm paper
  surface: '#FFFFFF',
  sunken: '#F4EDE1',
  ink: '#1D1A16', // charcoal, primary text
  inkSoft: '#4A443C',
  muted: '#756C60', // secondary text, 4.7:1 on bg
  line: '#E9E0D2',
  amber: '#E9A23B', // logo sun: fills and accents only, not body text
  amberSoft: '#FBEACB',
  amberDeep: '#9A5B07', // amber that passes AA as text
  night: '#211D18', // hero cards
  nightLine: '#3A342C',
  onNight: '#F7F1E7',
  onNightMuted: '#B9AE9E',
  success: '#2E7D4F',
  successSoft: '#E2F1E7',
  danger: '#B23B2A',
  dangerSoft: '#F8E1DC',
  info: '#2F5F8A',
  infoSoft: '#E1ECF5',
} as const;

export const space = { xs: 4, sm: 8, md: 12, lg: 16, xl: 24, xxl: 32 } as const;

export const radius = { sm: 6, md: 10, lg: 12, pill: 999 } as const;

export const font = {
  display: 'Fraunces_600SemiBold',
  displayItalic: 'Fraunces_400Regular_Italic',
  regular: 'Inter_400Regular',
  medium: 'Inter_500Medium',
  semibold: 'Inter_600SemiBold',
  arabic: 'Amiri_400Regular',
} as const;

export const type = {
  hero: { fontFamily: font.display, fontSize: 34, lineHeight: 40, letterSpacing: -0.6 },
  title: { fontFamily: font.display, fontSize: 28, lineHeight: 34, letterSpacing: -0.4 },
  heading: { fontFamily: font.display, fontSize: 20, lineHeight: 26, letterSpacing: -0.2 },
  body: { fontFamily: font.regular, fontSize: 15, lineHeight: 22 },
  bodyStrong: { fontFamily: font.semibold, fontSize: 15, lineHeight: 22 },
  label: { fontFamily: font.medium, fontSize: 13, lineHeight: 18 },
  caption: { fontFamily: font.regular, fontSize: 12, lineHeight: 16 },
  overline: { fontFamily: font.medium, fontSize: 13, lineHeight: 18 },
  number: { fontFamily: font.semibold, fontSize: 15, fontVariant: ['tabular-nums'] },
} as const;

export type TypeVariant = keyof typeof type;
