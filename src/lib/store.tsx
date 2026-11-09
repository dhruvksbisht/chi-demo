import { createContext, useContext, useMemo, useReducer, type Dispatch, type ReactNode } from 'react';

import { strings, type Lang, type Localized, type StringKey } from './i18n';
import { muToday, type PrayerName } from './time';

// ---- Domain types (mirror the data model in section 9) ---------------------

export type MonthStatus = 'paid' | 'overdue' | 'due' | 'upcoming';
export type PayMethod = 'juice' | 'cash' | 'bank';

export interface Month {
  key: string; // "2026-11"
  y: number;
  m: number;
  amount: number;
  paymentId?: string;
}

export interface Payment {
  id: string;
  receiptNo: string;
  ref: string; // Juice transaction reference, or manual reference
  kind: 'subscription' | 'donation';
  method: PayMethod;
  amount: number;
  monthKeys: string[];
  fund?: string;
  date: string; // ISO
}

export interface AccessRequest {
  id: string;
  name: string;
  nic: string;
  mobile: string;
  email: string;
  matched: boolean;
  status: 'pending' | 'approved' | 'rejected';
  submitted: string; // ISO
}

export const member = {
  name: 'Yusuf Rahim Bhugeloo',
  number: 'CHI-01427',
  email: 'yusuf.bhugeloo@example.mu',
  phone: '+230 5712 4480',
  category: { en: 'Ordinary member', fr: 'Membre ordinaire' } as Localized,
  since: 2011,
  rate: 150,
};

// ---- Seed data ------------------------------------------------------------

const keyOf = (y: number, m: number) => `${y}-${String(m).padStart(2, '0')}`;

function shiftMonth(y: number, m: number, by: number) {
  const idx = y * 12 + (m - 1) + by;
  return { y: Math.floor(idx / 12), m: (idx % 12) + 1 };
}

const today = muToday();
export const currentMonthKey = keyOf(today.y, today.m);

/** Months from 14 back to 6 ahead of today; everything up to two months ago is paid. */
function seed() {
  const months: Month[] = [];
  for (let i = -14; i <= 6; i++) {
    const { y, m } = shiftMonth(today.y, today.m, i);
    months.push({ key: keyOf(y, m), y, m, amount: member.rate });
  }
  const groups: { offsets: [number, number]; method: PayMethod; ref: string }[] = [
    { offsets: [-14, -12], method: 'juice', ref: 'JC4827301956' },
    { offsets: [-11, -6], method: 'cash', ref: 'Office receipt 2291' },
    { offsets: [-5, -2], method: 'juice', ref: 'JC5093318842' },
  ];
  const payments: Payment[] = groups.map((g, i) => {
    const keys = months.slice(g.offsets[0] + 14, g.offsets[1] + 15).map((mo) => mo.key);
    const paidOn = shiftMonth(today.y, today.m, g.offsets[1]);
    return {
      id: `p${i + 1}`,
      receiptNo: `R-${String(1180 + i * 37).padStart(5, '0')}`,
      ref: g.ref,
      kind: 'subscription',
      method: g.method,
      amount: keys.length * member.rate,
      monthKeys: keys,
      date: new Date(Date.UTC(paidOn.y, paidOn.m - 1, 4, 6)).toISOString(),
    };
  });
  const paidBy = new Map(payments.flatMap((p) => p.monthKeys.map((k) => [k, p.id] as const)));
  return {
    months: months.map((mo) => ({ ...mo, paymentId: paidBy.get(mo.key) })),
    payments: payments.reverse(),
  };
}

const daysAgoIso = (d: number) => new Date(Date.now() - d * 86_400_000).toISOString();

export interface State {
  lang: Lang;
  loggedIn: boolean;
  biometrics: boolean;
  reminders: boolean;
  months: Month[];
  payments: Payment[];
  requests: AccessRequest[];
  rsvps: string[];
  adhan: Record<PrayerName, boolean>;
  inboxRead: boolean;
}

const initialState: State = {
  lang: 'en',
  loggedIn: false,
  biometrics: false,
  reminders: true,
  ...seed(),
  requests: [
    { id: 'r1', name: 'Aisha Nuckchady', nic: 'N1503921402233', mobile: '57120934', email: 'aisha.n@example.mu', matched: true, status: 'pending', submitted: daysAgoIso(0.2) },
    { id: 'r2', name: 'Kevin Ramsamy', nic: 'R0207880117745', mobile: '59884410', email: 'k.ramsamy@example.mu', matched: false, status: 'pending', submitted: daysAgoIso(1) },
  ],
  rsvps: [],
  // Adhan audio is off by default (section 10, content rules).
  adhan: { fajr: false, sunrise: false, dhuhr: false, asr: false, maghrib: false, isha: false },
  inboxRead: false,
};

// ---- Reducer ----------------------------------------------------------------

export type Action =
  | { type: 'lang'; lang: Lang }
  | { type: 'login' }
  | { type: 'logout' }
  | { type: 'biometrics'; on: boolean }
  | { type: 'reminders'; on: boolean }
  | { type: 'paymentConfirmed'; payment: Payment }
  | { type: 'requestSubmitted'; request: AccessRequest }
  | { type: 'requestReviewed'; id: string; status: 'approved' | 'rejected' }
  | { type: 'rsvp'; id: string }
  | { type: 'adhan'; prayer: PrayerName }
  | { type: 'inboxRead' };

function reducer(state: State, action: Action): State {
  switch (action.type) {
    case 'lang':
      return { ...state, lang: action.lang };
    case 'login':
      return { ...state, loggedIn: true };
    case 'logout':
      return { ...state, loggedIn: false };
    case 'biometrics':
      return { ...state, biometrics: action.on };
    case 'reminders':
      return { ...state, reminders: action.on };
    case 'paymentConfirmed': {
      // Idempotent (PAY-05): a replayed confirmation for a known reference is a no-op,
      // and a month that is already paid is never credited twice.
      const p = action.payment;
      if (state.payments.some((x) => x.ref === p.ref)) return state;
      const credit = new Set(p.monthKeys.filter((k) => state.months.some((mo) => mo.key === k && !mo.paymentId)));
      return {
        ...state,
        payments: [{ ...p, monthKeys: [...credit] }, ...state.payments],
        months: state.months.map((mo) => (credit.has(mo.key) ? { ...mo, paymentId: p.id } : mo)),
      };
    }
    case 'requestSubmitted':
      return { ...state, requests: [action.request, ...state.requests] };
    case 'requestReviewed':
      return { ...state, requests: state.requests.map((r) => (r.id === action.id ? { ...r, status: action.status } : r)) };
    case 'rsvp':
      return {
        ...state,
        rsvps: state.rsvps.includes(action.id) ? state.rsvps.filter((id) => id !== action.id) : [...state.rsvps, action.id],
      };
    case 'adhan':
      return { ...state, adhan: { ...state.adhan, [action.prayer]: !state.adhan[action.prayer] } };
    case 'inboxRead':
      return { ...state, inboxRead: true };
  }
}

// ---- Selectors ----------------------------------------------------------------

export function monthStatus(mo: Month): MonthStatus {
  if (mo.paymentId) return 'paid';
  if (mo.key < currentMonthKey) return 'overdue';
  return mo.key === currentMonthKey ? 'due' : 'upcoming';
}

export function accountSummary(months: Month[]) {
  const paid = months.filter((mo) => mo.paymentId);
  const unpaid = months.filter((mo) => !mo.paymentId);
  const arrears = unpaid.filter((mo) => mo.key < currentMonthKey);
  return {
    paidUpTo: paid[paid.length - 1],
    nextDue: unpaid[0],
    arrears,
    arrearsTotal: arrears.reduce((sum, mo) => sum + mo.amount, 0),
  };
}

// ---- Context ----------------------------------------------------------------

const Ctx = createContext<{ state: State; dispatch: Dispatch<Action> } | null>(null);
// Language lives in its own context so navigators (which only need labels) re-render on a
// language switch, not on every store update. Re-rendering the tab navigator while a stacked
// screen is in front of it hangs expo-router on web.
const LangCtx = createContext<Lang>('en');

export function AppProvider({ children }: { children: ReactNode }) {
  const [state, dispatch] = useReducer(reducer, initialState);
  const value = useMemo(() => ({ state, dispatch }), [state]);
  return (
    <LangCtx.Provider value={state.lang}>
      <Ctx.Provider value={value}>{children}</Ctx.Provider>
    </LangCtx.Provider>
  );
}

export function useApp() {
  const ctx = useContext(Ctx);
  if (!ctx) throw new Error('useApp must be used inside AppProvider');
  return ctx;
}

/** Translation helpers bound to the current language. */
export function useT() {
  const lang = useContext(LangCtx);
  return useMemo(
    () => ({
      lang,
      t: (key: StringKey) => strings[lang][key],
      tr: (value: Localized) => value[lang],
    }),
    [lang],
  );
}

let seq = 1300;
export const newReceiptNo = () => `R-${String(++seq).padStart(5, '0')}`;
export const newJuiceRef = () => `JC${Math.floor(1e9 + Math.random() * 9e9)}`;
