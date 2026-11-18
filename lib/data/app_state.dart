import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/time.dart';
import 'content.dart';
import 'models.dart';

/// Whole-app state for the demo. In production the ledger lives on the server and the
/// app shows the last-synced copy (NFR-04); here the notifier stands in for the back end.
class AppState {
  const AppState({
    required this.lang,
    required this.loggedIn,
    required this.biometrics,
    required this.reminders,
    required this.months,
    required this.payments,
    required this.requests,
    required this.rsvps,
    required this.adhan,
    required this.inboxRead,
    required this.currentMonthKey,
  });

  final Lang lang;
  final bool loggedIn;
  final bool biometrics;
  final bool reminders;
  final List<Month> months;
  final List<Payment> payments; // newest first
  final List<AccessRequest> requests;
  final Set<String> rsvps;
  final Map<PrayerName, bool> adhan;
  final bool inboxRead;
  final String currentMonthKey;

  AppState copyWith({
    Lang? lang,
    bool? loggedIn,
    bool? biometrics,
    bool? reminders,
    List<Month>? months,
    List<Payment>? payments,
    List<AccessRequest>? requests,
    Set<String>? rsvps,
    Map<PrayerName, bool>? adhan,
    bool? inboxRead,
  }) => AppState(
    lang: lang ?? this.lang,
    loggedIn: loggedIn ?? this.loggedIn,
    biometrics: biometrics ?? this.biometrics,
    reminders: reminders ?? this.reminders,
    months: months ?? this.months,
    payments: payments ?? this.payments,
    requests: requests ?? this.requests,
    rsvps: rsvps ?? this.rsvps,
    adhan: adhan ?? this.adhan,
    inboxRead: inboxRead ?? this.inboxRead,
    currentMonthKey: currentMonthKey,
  );

  MonthStatus statusOf(Month mo) {
    if (mo.isPaid) return MonthStatus.paid;
    final c = mo.key.compareTo(currentMonthKey);
    return c < 0
        ? MonthStatus.overdue
        : (c == 0 ? MonthStatus.due : MonthStatus.upcoming);
  }

  Month? get paidUpTo => months.where((m) => m.isPaid).lastOrNull;
  Month? get nextDue => months.where((m) => !m.isPaid).firstOrNull;
  List<Month> get arrears =>
      months.where((m) => statusOf(m) == MonthStatus.overdue).toList();
  int get arrearsTotal => arrears.fold(0, (sum, m) => sum + m.amount);
}

({int y, int m}) _shift(int y, int m, int by) {
  final idx = y * 12 + (m - 1) + by;
  return (y: idx ~/ 12, m: idx % 12 + 1);
}

/// Months from 14 back to 6 ahead of today; everything up to two months ago is paid.
AppState seedState([DateTime? now]) {
  now ??= DateTime.now();
  final today = muToday(now);
  final months = [
    for (var i = -14; i <= 6; i++)
      () {
        final s = _shift(today.y, today.m, i);
        return Month(y: s.y, m: s.m, amount: member.rate);
      }(),
  ];
  const groups = [
    (from: -14, to: -12, method: PayMethod.juice, ref: 'JC4827301956'),
    (from: -11, to: -6, method: PayMethod.cash, ref: 'Office receipt 2291'),
    (from: -5, to: -2, method: PayMethod.juice, ref: 'JC5093318842'),
  ];
  final payments = <Payment>[];
  for (final (i, g) in groups.indexed) {
    final keys = months
        .sublist(g.from + 14, g.to + 15)
        .map((m) => m.key)
        .toList();
    final paidOn = _shift(today.y, today.m, g.to);
    payments.add(
      Payment(
        id: 'p${i + 1}',
        receiptNo: 'R-${(1180 + i * 37).toString().padLeft(5, '0')}',
        ref: g.ref,
        kind: PaymentKind.subscription,
        method: g.method,
        amount: keys.length * member.rate,
        monthKeys: keys,
        date: DateTime.utc(paidOn.y, paidOn.m, 4, 6),
      ),
    );
  }
  final paidBy = {
    for (final p in payments)
      for (final k in p.monthKeys) k: p.id,
  };

  return AppState(
    lang: Lang.en,
    loggedIn: false,
    biometrics: false,
    reminders: true,
    months: [
      for (final m in months)
        paidBy[m.key] == null ? m : m.paidBy(paidBy[m.key]!),
    ],
    payments: payments.reversed.toList(),
    requests: [
      AccessRequest(
        id: 'r1',
        name: 'Aisha Nuckchady',
        nic: 'N1503921402233',
        mobile: '57120934',
        email: 'aisha.n@example.mu',
        matched: true,
        submitted: now.subtract(const Duration(hours: 5)),
      ),
      AccessRequest(
        id: 'r2',
        name: 'Kevin Ramsamy',
        nic: 'R0207880117745',
        mobile: '59884410',
        email: 'k.ramsamy@example.mu',
        matched: false,
        submitted: now.subtract(const Duration(days: 1)),
      ),
    ],
    rsvps: const {},
    // Adhan audio is off by default (section 10, content rules).
    adhan: {for (final p in PrayerName.values) p: false},
    inboxRead: false,
    currentMonthKey: monthKey(today.y, today.m),
  );
}

class AppNotifier extends Notifier<AppState> {
  @override
  AppState build() => seedState();

  void setLang(Lang lang) => state = state.copyWith(lang: lang);
  void logIn() => state = state.copyWith(loggedIn: true);
  void logOut() => state = state.copyWith(loggedIn: false);
  void setBiometrics(bool on) => state = state.copyWith(biometrics: on);
  void setReminders(bool on) => state = state.copyWith(reminders: on);
  void markInboxRead() => state = state.copyWith(inboxRead: true);

  /// Idempotent (PAY-05): a replayed confirmation for a known reference is a no-op,
  /// and a month that is already paid is never credited twice.
  void confirmPayment(Payment p) {
    if (state.payments.any((x) => x.ref == p.ref)) return;
    final unpaid = {
      for (final m in state.months)
        if (!m.isPaid) m.key,
    };
    final credit = p.monthKeys.where(unpaid.contains).toSet();
    state = state.copyWith(
      payments: [p.withMonths(credit.toList()), ...state.payments],
      months: [
        for (final m in state.months)
          credit.contains(m.key) ? m.paidBy(p.id) : m,
      ],
    );
  }

  void submitRequest(AccessRequest r) =>
      state = state.copyWith(requests: [r, ...state.requests]);

  void reviewRequest(String id, RequestStatus status) => state = state.copyWith(
    requests: [
      for (final r in state.requests) r.id == id ? r.withStatus(status) : r,
    ],
  );

  void toggleRsvp(String id) {
    final next = {...state.rsvps};
    if (!next.remove(id)) next.add(id);
    state = state.copyWith(rsvps: next);
  }

  void toggleAdhan(PrayerName p) => state = state.copyWith(
    adhan: {...state.adhan, p: !(state.adhan[p] ?? false)},
  );
}

final appProvider = NotifierProvider<AppNotifier, AppState>(AppNotifier.new);

/// Language on its own so widgets that only need labels don't rebuild on every store change.
final langProvider = Provider<Lang>(
  (ref) => ref.watch(appProvider.select((s) => s.lang)),
);

final _rand = Random();
var _receiptSeq = 1300;
String newReceiptNo() => 'R-${(++_receiptSeq).toString().padLeft(5, '0')}';
String newJuiceRef() =>
    'JC${1000000000 + _rand.nextInt(900000000) * 10 + _rand.nextInt(10)}';
