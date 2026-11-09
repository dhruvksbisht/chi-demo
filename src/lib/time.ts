import { CalculationMethod, Coordinates, Madhab, PrayerTimes, Qibla } from 'adhan';

/**
 * All dates are reckoned in Mauritius time. Mauritius is UTC+4 with no DST,
 * so a fixed offset is exact and avoids depending on device time zone or Intl data.
 */
const MU_OFFSET_MS = 4 * 60 * 60 * 1000;
const DAY_MS = 86_400_000;

/** CHI, Port Louis. Swap for the society's exact coordinates. */
export const CHI_COORDS = new Coordinates(-20.1619, 57.4989);

export const PRAYERS = ['fajr', 'sunrise', 'dhuhr', 'asr', 'maghrib', 'isha'] as const;
export type PrayerName = (typeof PRAYERS)[number];
export type PrayerTime = { name: PrayerName; time: Date };

export type YMD = { y: number; m: number; d: number }; // m is 1-12

export function muToday(now = new Date()): YMD {
  const t = new Date(now.getTime() + MU_OFFSET_MS);
  return { y: t.getUTCFullYear(), m: t.getUTCMonth() + 1, d: t.getUTCDate() };
}

export function addDays(day: YMD, n: number): YMD {
  const t = new Date(Date.UTC(day.y, day.m - 1, day.d) + n * DAY_MS);
  return { y: t.getUTCFullYear(), m: t.getUTCMonth() + 1, d: t.getUTCDate() };
}

/** "05:12" in Mauritius time. */
export function formatTime(date: Date): string {
  const t = new Date(date.getTime() + MU_OFFSET_MS);
  return `${pad(t.getUTCHours())}:${pad(t.getUTCMinutes())}`;
}

export function formatCountdown(ms: number): string {
  const total = Math.max(0, Math.floor(ms / 1000));
  const h = Math.floor(total / 3600);
  const m = Math.floor((total % 3600) / 60);
  const s = total % 60;
  return h > 0 ? `${h}h ${pad(m)}m` : `${m}m ${pad(s)}s`;
}

const pad = (n: number) => String(n).padStart(2, '0');

// Muslim World League angles with Hanafi Asr: the common reckoning in Mauritius.
// The final method is agreed with CHI and becomes an admin setting (ADM-13).
function params() {
  const p = CalculationMethod.MuslimWorldLeague();
  p.madhab = Madhab.Hanafi;
  return p;
}

export function prayerTimesFor(day: YMD): PrayerTime[] {
  // adhan reads the calendar date from local fields, so build it in local time.
  const pt = new PrayerTimes(CHI_COORDS, new Date(day.y, day.m - 1, day.d), params());
  return PRAYERS.map((name) => ({ name, time: pt[name] }));
}

/** The next obligatory prayer from now (sunrise is not a prayer), rolling into tomorrow. */
export function nextPrayer(now = new Date()): PrayerTime {
  const today = muToday(now);
  const upcoming = prayerTimesFor(today).find((p) => p.name !== 'sunrise' && p.time > now);
  return upcoming ?? prayerTimesFor(addDays(today, 1))[0];
}

export const qiblaBearing = (): number => Qibla(CHI_COORDS);

// ---- Hijri (tabular Islamic calendar) -------------------------------------
// Arithmetic calendar; can differ by a day from moon sighting, which is why the
// production app exposes a +/- day adjustment in admin settings.

function gregorianToJdn({ y, m, d }: YMD): number {
  const a = Math.floor((14 - m) / 12);
  const yy = y + 4800 - a;
  const mm = m + 12 * a - 3;
  return d + Math.floor((153 * mm + 2) / 5) + 365 * yy + Math.floor(yy / 4) - Math.floor(yy / 100) + Math.floor(yy / 400) - 32045;
}

function jdnToGregorian(jdn: number): YMD {
  const a = jdn + 32044;
  const b = Math.floor((4 * a + 3) / 146097);
  const c = a - Math.floor((146097 * b) / 4);
  const d = Math.floor((4 * c + 3) / 1461);
  const e = c - Math.floor((1461 * d) / 4);
  const m = Math.floor((5 * e + 2) / 153);
  return {
    d: e - Math.floor((153 * m + 2) / 5) + 1,
    m: m + 3 - 12 * Math.floor(m / 10),
    y: 100 * b + d - 4800 + Math.floor(m / 10),
  };
}

export function toHijri(day: YMD): YMD {
  let l = gregorianToJdn(day) - 1948440 + 10632;
  const n = Math.floor((l - 1) / 10631);
  l = l - 10631 * n + 354;
  const j =
    Math.floor((10985 - l) / 5316) * Math.floor((50 * l) / 17719) +
    Math.floor(l / 5670) * Math.floor((43 * l) / 15238);
  l = l - Math.floor((30 - j) / 15) * Math.floor((17719 * j) / 50) - Math.floor(j / 16) * Math.floor((15238 * j) / 43) + 29;
  const m = Math.floor((24 * l) / 709);
  return { y: 30 * n + j - 30, m, d: l - Math.floor((709 * m) / 24) };
}

export function fromHijri({ y, m, d }: YMD): YMD {
  const jdn = Math.floor((11 * y + 3) / 30) + 354 * y + 30 * m - Math.floor((m - 1) / 2) + d + 1948440 - 385;
  return jdnToGregorian(jdn);
}

export function daysBetween(a: YMD, b: YMD): number {
  return gregorianToJdn(b) - gregorianToJdn(a);
}

export const RAMADAN = 9;

/** Today's Ramadan day number (1-30), or null outside Ramadan. */
export function ramadanDay(today: YMD): number | null {
  const h = toHijri(today);
  return h.m === RAMADAN ? h.d : null;
}

/** First day of the current or next Ramadan, in Gregorian. */
export function nextRamadanStart(today: YMD): { start: YMD; hijriYear: number } {
  const h = toHijri(today);
  const hijriYear = h.m > RAMADAN ? h.y + 1 : h.y;
  return { start: fromHijri({ y: hijriYear, m: RAMADAN, d: 1 }), hijriYear };
}
