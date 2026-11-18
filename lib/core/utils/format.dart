import 'package:material_ui/material_ui.dart';

import '../../data/models.dart';
import '../l10n/app_localizations.dart';
import 'time.dart';

extension L10nX on BuildContext {
  AppLocalizations get t => AppLocalizations.of(this);
  Lang get lang =>
      Localizations.localeOf(this).languageCode == 'fr' ? Lang.fr : Lang.en;
  String tr(L value) => value.of(lang);
}

const _months = {
  Lang.en: [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ],
  Lang.fr: [
    'janvier',
    'février',
    'mars',
    'avril',
    'mai',
    'juin',
    'juillet',
    'août',
    'septembre',
    'octobre',
    'novembre',
    'décembre',
  ],
};

const _weekdays = {
  Lang.en: [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ],
  Lang.fr: [
    'dimanche',
    'lundi',
    'mardi',
    'mercredi',
    'jeudi',
    'vendredi',
    'samedi',
  ],
};

const _hijriMonths = [
  'Muharram',
  'Safar',
  'Rabi al-Awwal',
  'Rabi al-Thani',
  'Jumada al-Awwal',
  'Jumada al-Thani',
  'Rajab',
  'Shaban',
  'Ramadan',
  'Shawwal',
  'Dhul Qadah',
  'Dhul Hijjah',
];

String monthName(Lang lang, int m, {bool short = false}) {
  final name = _months[lang]![m - 1];
  return short ? name.substring(0, 3) : name;
}

String capitalize(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

String weekdayName(Lang lang, Ymd day) => _weekdays[lang]![weekdayIndex(day)];

String hijriMonthName(int m) => _hijriMonths[m - 1];

/// "9 November 2026" / "9 novembre 2026"
String longDate(Lang lang, Ymd day) =>
    '${day.d} ${monthName(lang, day.m)} ${day.y}';

Ymd ymdOf(DateTime instant) => muToday(instant);

/// "MUR 1,350" with Mauritian grouping.
String mur(int amount) {
  final digits = amount.abs().toString();
  final grouped = digits.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  return 'MUR ${amount < 0 ? '-' : ''}$grouped';
}

/// "October 2026 – January 2027" from month keys like "2026-10".
String monthsLabel(List<String> keys, Lang lang) {
  if (keys.isEmpty) return '–';
  String fmt(String k) {
    final [y, m] = k.split('-').map(int.parse).toList();
    return '${monthName(lang, m)} $y';
  }

  final sorted = [...keys]..sort();
  return sorted.length == 1
      ? fmt(sorted.first)
      : '${fmt(sorted.first)} – ${fmt(sorted.last)}';
}

String ago(AppLocalizations t, int days) => switch (days) {
  0 => t.today,
  1 => t.yesterday,
  _ => t.daysAgo(days),
};

String prayerLabel(AppLocalizations t, PrayerName p) => switch (p) {
  PrayerName.fajr => t.fajr,
  PrayerName.sunrise => t.sunrise,
  PrayerName.dhuhr => t.dhuhr,
  PrayerName.asr => t.asr,
  PrayerName.maghrib => t.maghrib,
  PrayerName.isha => t.isha,
};

String statusLabel(AppLocalizations t, MonthStatus s) => switch (s) {
  MonthStatus.paid => t.paid,
  MonthStatus.overdue => t.overdue,
  MonthStatus.due => t.due,
  MonthStatus.upcoming => t.upcoming,
};

String methodLabel(AppLocalizations t, PayMethod m) => switch (m) {
  PayMethod.juice => t.methodJuice,
  PayMethod.cash => t.methodCash,
  PayMethod.bank => t.methodBank,
};
