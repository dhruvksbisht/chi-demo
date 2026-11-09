import Feather from '@expo/vector-icons/Feather';
import * as Haptics from 'expo-haptics';
import { router } from 'expo-router';
import type { ComponentProps, ReactNode } from 'react';
import {
  ActivityIndicator,
  Platform,
  Pressable,
  ScrollView,
  StyleSheet,
  Switch,
  Text,
  TextInput,
  View,
  type StyleProp,
  type TextInputProps,
  type TextStyle,
  type ViewStyle,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

import { color, font, radius, space, type, type TypeVariant } from '@/theme';

export type IconName = ComponentProps<typeof Feather>['name'];

export const tap = () => {
  if (Platform.OS !== 'web') Haptics.selectionAsync();
};

const pressed = ({ pressed: p }: { pressed: boolean }) => p && styles.pressed;

// ---- Text -----------------------------------------------------------------

type TxtProps = {
  v?: TypeVariant;
  c?: string;
  style?: StyleProp<TextStyle>;
  children: ReactNode;
  numberOfLines?: number;
};

export function Txt({ v = 'body', c = color.ink, style, children, numberOfLines }: TxtProps) {
  return (
    <Text style={[type[v] as TextStyle, { color: c }, style]} numberOfLines={numberOfLines}>
      {children}
    </Text>
  );
}

export const Icon = ({ name, size = 20, c = color.ink }: { name: IconName; size?: number; c?: string }) => (
  <Feather name={name} size={size} color={c} />
);

// ---- Screen ---------------------------------------------------------------

type ScreenProps = {
  title: string;
  subtitle?: string;
  back?: boolean;
  modal?: boolean;
  right?: ReactNode;
  children: ReactNode;
  footer?: ReactNode;
};

/** Standard page: serif title, optional back/close, scrolling body, optional pinned footer. */
export function Screen({ title, subtitle, back, modal, right, children, footer }: ScreenProps) {
  const insets = useSafeAreaInsets();
  const top = modal ? space.lg : insets.top + space.sm;
  return (
    <View style={styles.screen}>
      <ScrollView
        contentContainerStyle={[styles.scroll, { paddingTop: top, paddingBottom: footer ? space.xl : insets.bottom + space.xxl }]}
        keyboardShouldPersistTaps="handled"
      >
        {(back || modal || right) && (
          <View style={styles.topBar}>
            {back || modal ? (
              <IconButton icon={modal ? 'x' : 'chevron-left'} label={modal ? 'Close' : 'Back'} onPress={() => router.back()} />
            ) : (
              <View />
            )}
            {right}
          </View>
        )}
        <Txt v="title">{title}</Txt>
        {subtitle && <Txt v="body" c={color.muted} style={styles.subtitle}>{subtitle}</Txt>}
        <View style={styles.body}>{children}</View>
      </ScrollView>
      {footer && <View style={[styles.footer, { paddingBottom: insets.bottom + space.md }]}>{footer}</View>}
    </View>
  );
}

// ---- Building blocks ------------------------------------------------------

export function Card({ children, style, onPress, tone = 'surface' }: {
  children: ReactNode;
  style?: StyleProp<ViewStyle>;
  onPress?: () => void;
  tone?: 'surface' | 'amber' | 'night' | 'sunken';
}) {
  const toneStyle = tones[tone];
  if (!onPress) return <View style={[styles.card, toneStyle, style]}>{children}</View>;
  return (
    <Pressable onPress={() => { tap(); onPress(); }} style={(s) => [styles.card, toneStyle, style, pressed(s)]} accessibilityRole="button">
      {children}
    </Pressable>
  );
}

const tones = StyleSheet.create({
  surface: {},
  amber: { backgroundColor: color.amberSoft, borderColor: '#F1D39C' },
  night: { backgroundColor: color.night, borderColor: color.night },
  sunken: { backgroundColor: color.sunken, borderColor: color.sunken },
});

type ButtonProps = {
  label: string;
  onPress: () => void;
  kind?: 'primary' | 'secondary' | 'ghost' | 'danger';
  icon?: IconName;
  loading?: boolean;
  disabled?: boolean;
  style?: StyleProp<ViewStyle>;
};

export function Button({ label, onPress, kind = 'primary', icon, loading, disabled, style }: ButtonProps) {
  const fg = kind === 'primary' ? color.ink : kind === 'danger' ? color.danger : color.ink;
  const inactive = disabled || loading;
  return (
    <Pressable
      onPress={() => { tap(); onPress(); }}
      disabled={inactive}
      accessibilityRole="button"
      accessibilityState={{ disabled: !!inactive, busy: !!loading }}
      style={(s) => [styles.button, buttonKinds[kind], inactive && styles.disabled, style, pressed(s)]}
    >
      {loading ? (
        <ActivityIndicator color={fg} />
      ) : (
        <>
          {icon && <Icon name={icon} size={18} c={fg} />}
          <Txt v="bodyStrong" c={fg}>{label}</Txt>
        </>
      )}
    </Pressable>
  );
}

const buttonKinds = StyleSheet.create({
  primary: { backgroundColor: color.amber },
  secondary: { backgroundColor: color.surface, borderWidth: 1, borderColor: color.line },
  ghost: { backgroundColor: 'transparent' },
  danger: { backgroundColor: color.dangerSoft },
});

export function IconButton({ icon, label, onPress, badge }: { icon: IconName; label: string; onPress: () => void; badge?: boolean }) {
  return (
    <Pressable
      onPress={() => { tap(); onPress(); }}
      accessibilityRole="button"
      accessibilityLabel={label}
      hitSlop={8}
      style={(s) => [styles.iconButton, pressed(s)]}
    >
      <Icon name={icon} size={20} />
      {badge && <View style={styles.badgeDot} />}
    </Pressable>
  );
}

type RowProps = {
  icon?: IconName;
  title: string;
  subtitle?: string;
  right?: ReactNode;
  onPress?: () => void;
  last?: boolean;
  chevron?: boolean;
};

/** A list row; place several inside a <Card style={{padding: 0}}> for grouped lists. */
export function Row({ icon, title, subtitle, right, onPress, last, chevron = !!onPress }: RowProps) {
  const content = (
    <>
      {icon && (
        <View style={styles.rowIcon}>
          <Icon name={icon} size={18} c={color.amberDeep} />
        </View>
      )}
      <View style={styles.flex}>
        <Txt v="bodyStrong">{title}</Txt>
        {subtitle && <Txt v="label" c={color.muted}>{subtitle}</Txt>}
      </View>
      {right}
      {chevron && <Icon name="chevron-right" size={18} c={color.muted} />}
    </>
  );
  const rowStyle = [styles.row, !last && styles.rowDivider];
  if (!onPress) return <View style={rowStyle}>{content}</View>;
  return (
    <Pressable onPress={() => { tap(); onPress(); }} accessibilityRole="button" style={(s) => [...rowStyle, pressed(s)]}>
      {content}
    </Pressable>
  );
}

export function Section({ title, action, onAction, children }: { title: string; action?: string; onAction?: () => void; children: ReactNode }) {
  return (
    <View style={styles.section}>
      <View style={styles.sectionHead}>
        <Txt v="heading">{title}</Txt>
        {action && onAction && (
          <Pressable onPress={onAction} hitSlop={10} accessibilityRole="button">
            <Txt v="label" c={color.amberDeep}>{action}</Txt>
          </Pressable>
        )}
      </View>
      {children}
    </View>
  );
}

const badgeTones = {
  paid: [color.successSoft, color.success],
  success: [color.successSoft, color.success],
  overdue: [color.dangerSoft, color.danger],
  danger: [color.dangerSoft, color.danger],
  due: [color.amberSoft, color.amberDeep],
  amber: [color.amberSoft, color.amberDeep],
  upcoming: [color.sunken, color.muted],
  neutral: [color.sunken, color.inkSoft],
  info: [color.infoSoft, color.info],
} as const;

export function Badge({ label, tone = 'neutral' }: { label: string; tone?: keyof typeof badgeTones }) {
  const [bg, fg] = badgeTones[tone];
  return (
    <View style={[styles.badge, { backgroundColor: bg }]}>
      <Txt v="caption" c={fg} style={styles.badgeText}>{label}</Txt>
    </View>
  );
}

export function Segmented<T extends string>({ options, value, onChange }: {
  options: { value: T; label: string }[];
  value: T;
  onChange: (v: T) => void;
}) {
  return (
    <View style={styles.segmented} accessibilityRole="tablist">
      {options.map((o) => {
        const on = o.value === value;
        return (
          <Pressable
            key={o.value}
            onPress={() => { tap(); onChange(o.value); }}
            accessibilityRole="tab"
            accessibilityState={{ selected: on }}
            style={[styles.segment, on && styles.segmentOn]}
          >
            <Txt v="label" c={on ? color.ink : color.muted}>{o.label}</Txt>
          </Pressable>
        );
      })}
    </View>
  );
}

export const Toggle = ({ value, onChange, label }: { value: boolean; onChange: (v: boolean) => void; label: string }) => (
  <Switch
    value={value}
    onValueChange={(v) => { tap(); onChange(v); }}
    accessibilityLabel={label}
    trackColor={{ true: color.amber, false: color.line }}
    thumbColor={color.surface}
    ios_backgroundColor={color.line}
  />
);

export function Field({ label, error, ...input }: TextInputProps & { label: string; error?: string }) {
  return (
    <View style={styles.field}>
      <Txt v="label" c={color.inkSoft}>{label}</Txt>
      <TextInput
        placeholderTextColor={color.muted}
        style={[styles.input, !!error && styles.inputError]}
        accessibilityLabel={label}
        {...input}
      />
      {error && <Txt v="caption" c={color.danger}>{error}</Txt>}
    </View>
  );
}

/** A label/value line used in receipts and summaries. */
export const KV = ({ k, v }: { k: string; v: string }) => (
  <View style={styles.kv}>
    <Txt v="label" c={color.muted}>{k}</Txt>
    <Txt v="label" style={styles.kvValue}>{v}</Txt>
  </View>
);

export const Gap = ({ h = space.md }: { h?: number }) => <View style={{ height: h }} />;

export const styles = StyleSheet.create({
  flex: { flex: 1 },
  pressed: { opacity: 0.72, transform: [{ scale: 0.985 }] },
  screen: { flex: 1, backgroundColor: color.bg },
  scroll: { paddingHorizontal: space.lg },
  topBar: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: space.md, minHeight: 40 },
  subtitle: { marginTop: space.xs },
  body: { marginTop: space.xl, gap: space.lg },
  footer: { paddingHorizontal: space.lg, paddingTop: space.md, backgroundColor: color.bg, borderTopWidth: 1, borderTopColor: color.line },
  card: { backgroundColor: color.surface, borderRadius: radius.lg, borderWidth: 1, borderColor: color.line, padding: space.lg },
  button: { minHeight: 52, borderRadius: radius.md, flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: space.sm, paddingHorizontal: space.lg },
  disabled: { opacity: 0.45 },
  iconButton: { width: 40, height: 40, borderRadius: radius.pill, backgroundColor: color.surface, borderWidth: 1, borderColor: color.line, alignItems: 'center', justifyContent: 'center' },
  badgeDot: { position: 'absolute', top: 8, right: 9, width: 8, height: 8, borderRadius: 4, backgroundColor: color.danger, borderWidth: 1.5, borderColor: color.surface },
  row: { flexDirection: 'row', alignItems: 'center', gap: space.md, paddingVertical: 14, paddingHorizontal: space.lg, minHeight: 56 },
  rowDivider: { borderBottomWidth: StyleSheet.hairlineWidth, borderBottomColor: color.line },
  rowIcon: { width: 36, height: 36, borderRadius: radius.sm, backgroundColor: color.amberSoft, alignItems: 'center', justifyContent: 'center' },
  section: { gap: space.sm },
  sectionHead: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', paddingHorizontal: space.xs },
  badge: { alignSelf: 'flex-start', paddingHorizontal: space.sm, paddingVertical: 3, borderRadius: radius.pill },
  badgeText: { fontFamily: font.semibold },
  segmented: { flexDirection: 'row', backgroundColor: color.sunken, borderRadius: radius.md, padding: 3 },
  segment: { paddingHorizontal: space.md, paddingVertical: 6, borderRadius: radius.sm, minWidth: 44, alignItems: 'center' },
  segmentOn: { backgroundColor: color.surface, shadowColor: '#000', shadowOpacity: 0.06, shadowRadius: 4, shadowOffset: { width: 0, height: 1 }, elevation: 1 },
  field: { gap: 6 },
  input: { ...type.body, color: color.ink, backgroundColor: color.surface, borderWidth: 1, borderColor: color.line, borderRadius: radius.md, paddingHorizontal: space.md, minHeight: 50 },
  inputError: { borderColor: color.danger },
  kv: { flexDirection: 'row', justifyContent: 'space-between', gap: space.lg, paddingVertical: 6 },
  kvValue: { fontFamily: font.semibold, flexShrink: 1, textAlign: 'right' },
});
