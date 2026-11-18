import 'package:adhan/adhan.dart' as adhan;

/// A calendar day. `m` is 1-12.
typedef Ymd = ({int y, int m, int d});

/// All dates are reckoned in Mauritius time. Mauritius is UTC+4 with no DST, so a
/// fixed offset is exact and never depends on the device time zone.
const muOffset = Duration(hours: 4);

/// CHI, Port Louis. Swap for the society's exact coordinates.
final chiCoords = adhan.Coordinates(-20.1619, 57.4989);

enum PrayerName { fajr, sunrise, dhuhr, asr, maghrib, isha }

typedef PrayerTime = ({PrayerName name, DateTime time});

DateTime _mu(DateTime instant) => instant.toUtc().add(muOffset);

Ymd muToday([DateTime? now]) {
  final t = _mu(now ?? DateTime.now());
  return (y: t.year, m: t.month, d: t.day);
}

Ymd addDays(Ymd day, int n) {
  final t = DateTime.utc(day.y, day.m, day.d + n);
  return (y: t.year, m: t.month, d: t.day);
}

int weekdayIndex(Ymd day) =>
    DateTime.utc(day.y, day.m, day.d).weekday % 7; // 0 = Sunday

String _pad(int n) => n.toString().padLeft(2, '0');

/// "05:12" in Mauritius time.
String formatTime(DateTime instant) {
  final t = _mu(instant);
  return '${_pad(t.hour)}:${_pad(t.minute)}';
}

/// "1h 05m" above an hour, "12m 09s" below.
String formatCountdown(Duration left) {
  final total = left.isNegative ? 0 : left.inSeconds;
  final h = total ~/ 3600, m = (total % 3600) ~/ 60, s = total % 60;
  return h > 0 ? '${h}h ${_pad(m)}m' : '${m}m ${_pad(s)}s';
}

// Muslim World League angles with Hanafi Asr: the common reckoning in Mauritius.
// The final method is agreed with CHI and becomes an admin setting (ADM-13).
adhan.CalculationParameters _params() {
  final p = adhan.CalculationMethod.muslim_world_league.getParameters();
  p.madhab = adhan.Madhab.hanafi;
  return p;
}

/// Prayer times for a Mauritian calendar day, as UTC instants.
List<PrayerTime> prayerTimesFor(Ymd day) {
  final pt = adhan.PrayerTimes(
    chiCoords,
    adhan.DateComponents(day.y, day.m, day.d),
    _params(),
  );
  return [
    (name: PrayerName.fajr, time: pt.fajr),
    (name: PrayerName.sunrise, time: pt.sunrise),
    (name: PrayerName.dhuhr, time: pt.dhuhr),
    (name: PrayerName.asr, time: pt.asr),
    (name: PrayerName.maghrib, time: pt.maghrib),
    (name: PrayerName.isha, time: pt.isha),
  ];
}

/// The next obligatory prayer from now (sunrise is not a prayer), rolling into tomorrow.
PrayerTime nextPrayer([DateTime? now]) {
  now ??= DateTime.now();
  final today = muToday(now);
  for (final p in prayerTimesFor(today)) {
    if (p.name != PrayerName.sunrise && p.time.isAfter(now)) return p;
  }
  return prayerTimesFor(addDays(today, 1)).first;
}

final double qiblaBearing = adhan.Qibla(chiCoords).direction;

// ---- Hijri (tabular Islamic calendar) -------------------------------------
// Arithmetic calendar; can differ by a day from moon sighting, which is why the
// production app exposes a +/- day adjustment in admin settings.

int _gregorianToJdn(Ymd g) {
  final a = (14 - g.m) ~/ 12;
  final yy = g.y + 4800 - a;
  final mm = g.m + 12 * a - 3;
  return g.d +
      (153 * mm + 2) ~/ 5 +
      365 * yy +
      yy ~/ 4 -
      yy ~/ 100 +
      yy ~/ 400 -
      32045;
}

Ymd _jdnToGregorian(int jdn) {
  final a = jdn + 32044;
  final b = (4 * a + 3) ~/ 146097;
  final c = a - (146097 * b) ~/ 4;
  final d = (4 * c + 3) ~/ 1461;
  final e = c - (1461 * d) ~/ 4;
  final m = (5 * e + 2) ~/ 153;
  return (
    d: e - (153 * m + 2) ~/ 5 + 1,
    m: m + 3 - 12 * (m ~/ 10),
    y: 100 * b + d - 4800 + m ~/ 10,
  );
}

Ymd toHijri(Ymd day) {
  var l = _gregorianToJdn(day) - 1948440 + 10632;
  final n = (l - 1) ~/ 10631;
  l = l - 10631 * n + 354;
  final j =
      ((10985 - l) ~/ 5316) * ((50 * l) ~/ 17719) +
      (l ~/ 5670) * ((43 * l) ~/ 15238);
  l =
      l -
      ((30 - j) ~/ 15) * ((17719 * j) ~/ 50) -
      (j ~/ 16) * ((15238 * j) ~/ 43) +
      29;
  final m = (24 * l) ~/ 709;
  return (y: 30 * n + j - 30, m: m, d: l - (709 * m) ~/ 24);
}

Ymd fromHijri(Ymd h) {
  final jdn =
      (11 * h.y + 3) ~/ 30 +
      354 * h.y +
      30 * h.m -
      (h.m - 1) ~/ 2 +
      h.d +
      1948440 -
      385;
  return _jdnToGregorian(jdn);
}

int daysBetween(Ymd a, Ymd b) => _gregorianToJdn(b) - _gregorianToJdn(a);

const ramadanMonth = 9;

/// Today's Ramadan day number (1-30), or null outside Ramadan.
int? ramadanDay(Ymd today) {
  final h = toHijri(today);
  return h.m == ramadanMonth ? h.d : null;
}

/// First day of the current or next Ramadan, in Gregorian.
({Ymd start, int hijriYear}) nextRamadanStart(Ymd today) {
  final h = toHijri(today);
  final year = h.m > ramadanMonth ? h.y + 1 : h.y;
  return (start: fromHijri((y: year, m: ramadanMonth, d: 1)), hijriYear: year);
}
