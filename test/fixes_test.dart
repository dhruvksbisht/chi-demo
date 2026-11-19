// Regression tests for the 2026-11-19 emulator audit fixes.
import 'package:chi/core/utils/connectivity.dart';
import 'package:chi/core/utils/format.dart';
import 'package:chi/core/utils/time.dart';
import 'package:chi/core/widgets/ui.dart';
import 'package:chi/data/app_state.dart';
import 'package:chi/data/content.dart';
import 'package:chi/data/models.dart';
import 'package:chi/data/validation.dart';
import 'package:chi/main.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

Future<void> _pumpApp(WidgetTester tester, {bool online = true}) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [onlineProvider.overrideWith((ref) => Stream.value(online))],
      child: const ChiApp(),
    ),
  );
  await tester.pump(const Duration(milliseconds: 500));
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _logInAndOpenPay(WidgetTester tester) async {
  await tester.tap(find.text('Member').last);
  await _settle(tester);
  await tester.tap(find.text('Log in'));
  await tester.pump(const Duration(milliseconds: 700));
  await _settle(tester);
  await tester.tap(find.text('Pay upcoming months'));
  await _settle(tester);
}

void main() {
  group('logic', () {
    test(
      'donation amounts are whole rupees; cents are rejected, not dropped',
      () {
        expect(parseRupees('1250'), 1250);
        expect(parseRupees('1,250'), 1250);
        expect(parseRupees('1 250.00'), 1250);
        expect(parseRupees('1234.50'), isNull);
        expect(parseRupees(''), isNull);
        expect(hasCents('1234.50'), isTrue);
        expect(hasCents('1234.00'), isFalse);
      },
    );

    test('French short months are all distinct (juin vs juil.)', () {
      final short = [
        for (var m = 1; m <= 12; m++) monthName(Lang.fr, m, short: true),
      ];
      expect(short.toSet(), hasLength(12));
      expect(short[5], 'juin');
      expect(short[6], 'juil.');
      expect(monthName(Lang.en, 7, short: true), 'Jul');
    });

    test('AGM falls on a Sunday and news text uses the same date', () {
      const today = (y: 2026, m: 11, d: 19);
      final agm = events.firstWhere((e) => e.id == 'agm').dayFrom(today);
      expect(weekdayIndex(agm), 0);
      expect(agm, (y: 2026, m: 11, d: 29));
      expect(fillDates('AGM on {agm}', Lang.en, today), 'AGM on 29 November');
      expect(
        fillDates('le {agmDay}', Lang.fr, today),
        'le dimanche 29 novembre',
      );
      // A week later it moves forward to stay upcoming, and still agrees.
      const later = (y: 2026, m: 11, d: 26);
      expect(events.firstWhere((e) => e.id == 'agm').dayFrom(later), (
        y: 2026,
        m: 12,
        d: 6,
      ));
      expect(fillDates('{agm}', Lang.en, later), '6 December');
    });

    test('rejecting an access request keeps the reason (FR-013)', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final app = c.read(appProvider.notifier);
      final id = c.read(appProvider).requests.first.id;
      app.reviewRequest(id, RequestStatus.rejected, reason: ' Not a member ');
      final r = c.read(appProvider).requests.firstWhere((r) => r.id == id);
      expect(r.status, RequestStatus.rejected);
      expect(r.reason, 'Not a member');
    });

    test('anonymous donations stay anonymous through the ledger', () {
      final p = Payment(
        id: 'd1',
        receiptNo: 'R-1',
        ref: 'JCE-1',
        kind: PaymentKind.donation,
        method: PayMethod.juice,
        amount: 500,
        monthKeys: const [],
        date: DateTime.utc(2026, 11, 19),
        fund: funds.first.id,
        anonymous: true,
      );
      expect(p.withMonths(const []).anonymous, isTrue);
    });
  });

  group('widgets', () {
    testWidgets('NowBuilder rebuilds every interval', (tester) async {
      var builds = 0;
      await tester.pumpWidget(
        NowBuilder(
          builder: (_, _) {
            builds++;
            return const SizedBox();
          },
        ),
      );
      for (var i = 0; i < 3; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
      expect(builds, 4); // first build + one per second
    });

    testWidgets('payment history keeps its own title', (tester) async {
      await _pumpApp(tester);
      await _logInAndOpenPay(tester);
      await tester.binding.handlePopRoute();
      await _settle(tester);
      await tester.scrollUntilVisible(
        find.text('Payment history & receipts'),
        200,
        scrollable: find.byType(Scrollable).hitTestable().first,
      );
      expect(find.text('Our history'), findsNothing);
    });

    testWidgets('after paying, going back does not pre-select future months', (
      tester,
    ) async {
      await _pumpApp(tester);
      await _logInAndOpenPay(tester);
      // Select one more month than the default, so the stale choice would be 3.
      await tester.tap(find.textContaining('December 2026'));
      await _settle(tester);
      expect(find.text(mur(450)), findsOneWidget);

      await tester.tap(find.text('Pay with Juice'));
      await _settle(tester);
      await tester.tap(find.text('Confirm payment'));
      await tester.pump(const Duration(seconds: 3));
      await _settle(tester);
      expect(find.text('Payment successful'), findsOneWidget);

      await tester.binding.handlePopRoute(); // Android back
      await _settle(tester);
      // Only the next due month is offered by default, not three future months.
      expect(find.text(mur(150)), findsWidgets);
      expect(find.text(mur(450)), findsNothing);
    });

    testWidgets('offline: pay button is disabled with a message (NFR-04)', (
      tester,
    ) async {
      await _pumpApp(tester, online: false);
      await _logInAndOpenPay(tester);
      expect(find.textContaining('You’re offline'), findsOneWidget);
      final button = find.ancestor(
        of: find.text('Pay with Juice'),
        matching: find.byType(AppButton),
      );
      expect(tester.widget<AppButton>(button).onPressed, isNull);
    });

    testWidgets('a visitor donation is not credited to a member', (
      tester,
    ) async {
      await _pumpApp(tester);
      // Open Donate the way the Home card does; the card can sit under the tab bar here.
      GoRouter.of(tester.element(find.byType(Scaffold).first)).push('/donate');
      await _settle(tester);
      await tester.tap(find.textContaining('Donate with Juice'));
      await _settle(tester);
      await tester.tap(find.text('Confirm payment'));
      await tester.pump(const Duration(seconds: 3));
      await _settle(tester);
      expect(find.text('Donation received'), findsOneWidget);
      expect(find.text(member.number), findsNothing);
      expect(find.textContaining(member.email), findsNothing);
      expect(find.text('Back to my account'), findsNothing);
      expect(find.text('Done'), findsOneWidget);
    });

    testWidgets('prayer times stay on one line at 200% text', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await _pumpApp(tester);
      final time = RegExp(r'^\d\d:\d\d$');
      final paragraphs = tester
          .renderObjectList<RenderParagraph>(find.byType(RichText))
          .where((p) => time.hasMatch(p.text.toPlainText()))
          .toList();
      expect(paragraphs, isNotEmpty);
      for (final p in paragraphs) {
        expect(
          p.getMaxIntrinsicWidth(double.infinity) <= p.size.width + 0.5,
          isTrue,
          reason: '${p.text.toPlainText()} wraps',
        );
      }
    });
  });
}
