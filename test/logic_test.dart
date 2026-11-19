import 'package:chi/core/utils/format.dart';
import 'package:chi/core/utils/time.dart';
import 'package:chi/data/app_state.dart';
import 'package:chi/data/models.dart';
import 'package:chi/data/validation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Payment _juice(String ref, List<String> keys) => Payment(
  id: 'x-$ref',
  receiptNo: 'R-9',
  ref: ref,
  kind: PaymentKind.subscription,
  method: PayMethod.juice,
  amount: keys.length * 150,
  monthKeys: keys,
  date: DateTime.utc(2026, 11, 18),
);

void main() {
  group('ledger', () {
    test('seed: one overdue month, current month due', () {
      final s = seedState(DateTime.utc(2026, 11, 18, 8));
      expect(s.currentMonthKey, '2026-11');
      expect(s.arrears.map((m) => m.key), ['2026-10']);
      expect(s.arrearsTotal, 150);
      expect(
        s.statusOf(s.months.firstWhere((m) => m.key == '2026-11')),
        MonthStatus.due,
      );
      expect(s.paidUpTo?.key, '2026-09');
    });

    test(
      'confirmPayment is idempotent and never credits a month twice (PAY-05)',
      () {
        final c = ProviderContainer();
        addTearDown(c.dispose);
        final app = c.read(appProvider.notifier);
        final s0 = c.read(appProvider);
        final keys = s0.arrears.map((m) => m.key).toList();

        app.confirmPayment(_juice('JC1', keys));
        final s1 = c.read(appProvider);
        expect(s1.arrearsTotal, 0);
        expect(s1.payments.length, s0.payments.length + 1);

        app.confirmPayment(_juice('JC1', keys)); // replayed callback
        expect(c.read(appProvider).payments.length, s1.payments.length);

        app.confirmPayment(_juice('JC2', keys)); // different ref, same months
        expect(c.read(appProvider).payments.first.monthKeys, isEmpty);
      },
    );
  });

  group('time', () {
    test('Mauritius day boundary is UTC+4', () {
      expect(muToday(DateTime.utc(2026, 11, 18, 19, 59)), (
        y: 2026,
        m: 11,
        d: 18,
      ));
      expect(muToday(DateTime.utc(2026, 11, 18, 20, 0)), (
        y: 2026,
        m: 11,
        d: 19,
      ));
    });

    test('prayer times are in order and plausible for Port Louis', () {
      final times = prayerTimesFor((y: 2026, m: 11, d: 18));
      for (var i = 1; i < times.length; i++) {
        expect(times[i].time.isAfter(times[i - 1].time), isTrue);
      }
      final fajr = formatTime(times.first.time);
      expect(
        fajr.compareTo('03:30') > 0 && fajr.compareTo('05:00') < 0,
        isTrue,
        reason: fajr,
      );
    });

    test('Hijri round-trips', () {
      const day = (y: 2026, m: 11, d: 18);
      expect(fromHijri(toHijri(day)), day);
    });

    test('qibla bearing from Port Louis points north-north-west', () {
      expect(qiblaBearing, inInclusiveRange(325, 345));
    });

    test('countdown formatting', () {
      expect(formatCountdown(const Duration(hours: 1, minutes: 5)), '1h 05m');
      expect(
        formatCountdown(const Duration(minutes: 12, seconds: 9)),
        '12m 09s',
      );
      expect(formatCountdown(const Duration(seconds: -5)), '0m 00s');
    });
  });

  group('format', () {
    test('mur groups thousands', () {
      // Non-breaking space: an amount never splits across lines.
      expect(mur(150), 'MUR 150');
      expect(mur(46350), 'MUR 46,350');
      expect(mur(1234567), 'MUR 1,234,567');
    });

    test('monthsLabel spans a range', () {
      expect(
        monthsLabel(['2026-12', '2026-10'], Lang.en),
        'October 2026 – December 2026',
      );
      expect(monthsLabel(['2026-10'], Lang.fr), 'octobre 2026');
    });
  });

  group('access request validation (FR-011)', () {
    Set<FieldError> v({
      String name = 'Aisha Nuckchady',
      String nic = 'N1503921402233',
      String mobile = '57120934',
      String email = 'a@b.mu',
      bool consent = true,
    }) => validateRequest(
      name: name,
      nic: nic,
      mobile: mobile,
      email: email,
      consent: consent,
    );

    test('valid input passes', () => expect(v(), isEmpty));

    test('accepts liberal input (Postel)', () {
      expect(v(nic: 'n150392 1402233', mobile: '+230 5712-0934'), isEmpty);
    });

    test('rejects bad fields', () {
      expect(
        v(
          name: 'Aisha',
          nic: '1234',
          mobile: '42120934',
          email: 'nope',
          consent: false,
        ),
        FieldError.values.toSet(),
      );
    });
  });
}
