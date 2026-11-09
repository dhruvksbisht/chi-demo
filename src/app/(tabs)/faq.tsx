import { useState } from 'react';
import { LayoutAnimation, Pressable, ScrollView, StyleSheet, View } from 'react-native';

import { Card, Field, Icon, Screen, Txt, tap } from '@/components/ui';
import { faqCategories, faqs, type FaqCategory } from '@/data/content';
import { useT } from '@/lib/store';
import { color, radius, space } from '@/theme';

export default function Faq() {
  const { t, tr } = useT();
  const [query, setQuery] = useState('');
  const [category, setCategory] = useState<FaqCategory | 'all'>('all');
  const [open, setOpen] = useState<number | null>(0);

  const q = query.trim().toLowerCase();
  const visible = faqs
    .map((f, i) => ({ ...f, i }))
    .filter((f) => category === 'all' || f.category === category)
    .filter((f) => !q || `${tr(f.q)} ${tr(f.a)}`.toLowerCase().includes(q));

  const toggle = (i: number) => {
    tap();
    LayoutAnimation.configureNext(LayoutAnimation.Presets.easeInEaseOut);
    setOpen(open === i ? null : i);
  };

  const chips = [{ id: 'all' as const, label: { en: t('all'), fr: t('all') } }, ...faqCategories];

  return (
    <Screen title={t('tabFaq')} subtitle={t('faqSub')}>
      <Field label={t('searchQuestions')} value={query} onChangeText={setQuery} placeholder="e.g. receipt" returnKeyType="search" />
      <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={s.chips}>
        {chips.map((c) => {
          const on = c.id === category;
          return (
            <Pressable
              key={c.id}
              onPress={() => { tap(); setCategory(c.id); }}
              accessibilityRole="button"
              accessibilityState={{ selected: on }}
              style={[s.chip, on && s.chipOn]}
            >
              <Txt v="label" c={on ? color.ink : color.inkSoft}>{tr(c.label)}</Txt>
            </Pressable>
          );
        })}
      </ScrollView>

      {visible.length === 0 && <Txt c={color.muted}>{t('noResults')}</Txt>}
      <View style={s.list}>
        {visible.map((f) => {
          const expanded = open === f.i;
          return (
            <Card key={f.i} tone={expanded ? 'amber' : 'surface'} style={s.item}>
              <Pressable
                onPress={() => toggle(f.i)}
                accessibilityRole="button"
                accessibilityState={{ expanded }}
                style={s.question}
              >
                <Txt v="bodyStrong" style={s.flex}>{tr(f.q)}</Txt>
                <Icon name={expanded ? 'minus' : 'plus'} size={18} c={color.amberDeep} />
              </Pressable>
              {expanded && <Txt c={color.inkSoft} style={s.answer}>{tr(f.a)}</Txt>}
            </Card>
          );
        })}
      </View>
    </Screen>
  );
}

const s = StyleSheet.create({
  flex: { flex: 1 },
  chips: { gap: space.sm },
  chip: { paddingHorizontal: space.lg, paddingVertical: space.sm, borderRadius: radius.pill, borderWidth: 1, borderColor: color.line, backgroundColor: color.surface },
  chipOn: { backgroundColor: color.amberSoft, borderColor: color.amber },
  list: { gap: space.sm },
  item: { padding: 0 },
  question: { flexDirection: 'row', alignItems: 'center', gap: space.md, padding: space.lg },
  answer: { paddingHorizontal: space.lg, paddingBottom: space.lg, marginTop: -space.xs },
});
