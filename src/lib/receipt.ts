import * as Print from 'expo-print';
import * as Sharing from 'expo-sharing';
import { Platform } from 'react-native';

import { monthName, mur, type Lang } from './i18n';
import { member, type Payment } from './store';

/** "October 2026 – January 2027" from month keys like "2026-10". */
export function monthsLabel(keys: string[], lang: Lang): string {
  if (keys.length === 0) return '–';
  const fmt = (k: string) => {
    const [y, m] = k.split('-').map(Number);
    return `${monthName(lang, m)} ${y}`;
  };
  const sorted = [...keys].sort();
  return sorted.length === 1 ? fmt(sorted[0]) : `${fmt(sorted[0])} – ${fmt(sorted[sorted.length - 1])}`;
}

export const methodLabel = (p: Payment): string =>
  p.method === 'juice' ? 'Juice by MCB' : p.method === 'cash' ? 'Cash (manual entry)' : 'Bank transfer (manual entry)';

const esc = (s: string) => s.replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' })[c] ?? c);

function receiptHtml(p: Payment, fundLabel?: string): string {
  const date = new Date(p.date).toLocaleDateString('en-GB', { day: 'numeric', month: 'long', year: 'numeric' });
  const rows: [string, string][] = [
    ['Receipt no.', p.receiptNo],
    ['Member', `${member.name} (${member.number})`],
    p.kind === 'subscription' ? ['Months', monthsLabel(p.monthKeys, 'en')] : ['Fund', fundLabel ?? 'General'],
    ['Payment method', methodLabel(p)],
    [p.method === 'juice' ? 'Juice reference' : 'Reference', p.ref],
    ['Date', date],
  ];
  return `<!doctype html><html><head><meta charset="utf-8"><style>
    body{font-family:-apple-system,Roboto,Helvetica,Arial,sans-serif;color:#1D1A16;padding:48px;}
    .head{display:flex;align-items:center;gap:16px;border-bottom:3px solid #E9A23B;padding-bottom:20px}
    .disc{width:56px;height:56px;border-radius:50%;background:#E9A23B;display:flex;align-items:center;justify-content:center;font-weight:800;letter-spacing:1px}
    h1{font-size:20px;margin:0} .sub{color:#756C60;font-size:13px;margin-top:2px}
    h2{font-size:28px;margin:36px 0 4px} .tag{color:#2E7D4F;font-weight:600}
    table{width:100%;border-collapse:collapse;margin-top:24px;font-size:14px}
    td{padding:12px 0;border-bottom:1px solid #E9E0D2} td:last-child{text-align:right;font-weight:600}
    .total td{font-size:18px;border-bottom:none;padding-top:20px}
    .foot{margin-top:48px;color:#756C60;font-size:11px;line-height:1.6}
  </style></head><body>
    <div class="head"><div class="disc">CHI</div><div>
      <h1>Cockney Hudayetool Islam Society</h1><div class="sub">Port Louis, Mauritius · info@chi.mu</div></div></div>
    <h2>${p.kind === 'donation' ? 'Donation receipt' : 'Subscription receipt'}</h2>
    <div class="tag">Paid · confirmed by server</div>
    <table>${rows.map(([k, v]) => `<tr><td>${esc(k)}</td><td>${esc(v)}</td></tr>`).join('')}
      <tr class="total"><td>Amount paid</td><td>${mur(p.amount)}</td></tr></table>
    <div class="foot">This receipt was issued automatically after the payment was confirmed server-side with MCB.
      Keep it as proof of payment. Demo document, not a valid tax receipt.</div>
  </body></html>`;
}

/** Renders the receipt to PDF and opens the share sheet (download, email, WhatsApp). */
export async function shareReceipt(p: Payment, fundLabel?: string): Promise<void> {
  const html = receiptHtml(p, fundLabel);
  if (Platform.OS === 'web') {
    await Print.printAsync({ html });
    return;
  }
  const { uri } = await Print.printToFileAsync({ html });
  await Sharing.shareAsync(uri, { UTI: '.pdf', mimeType: 'application/pdf', dialogTitle: p.receiptNo });
}
