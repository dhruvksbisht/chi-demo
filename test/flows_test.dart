import 'package:chi/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Future<void> _pumpApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const ProviderScope(child: ChiApp()));
  await tester.pump(const Duration(milliseconds: 500));
}

/// The home screen ticks every second, so settle with bounded pumps rather than pumpAndSettle.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  testWidgets('every tab renders', (tester) async {
    await _pumpApp(tester);
    expect(find.text('Assalamu alaykum'), findsOneWidget);
    for (final (tab, marker) in [
      ('Committee', 'Management committee 2025–2027'),
      ('FAQ', 'Answers to common questions'),
      ('Contacts', 'Get directions'),
      ('Member', 'Member login'),
    ]) {
      await tester.tap(find.text(tab).last);
      await _settle(tester);
      expect(find.text(marker), findsOneWidget, reason: tab);
    }
  });

  testWidgets('switching to French relabels the tabs', (tester) async {
    await _pumpApp(tester);
    await tester.tap(find.text('FR'));
    await _settle(tester);
    expect(find.text('Accueil'), findsOneWidget);
    expect(find.text('Comité'), findsOneWidget);
  });

  testWidgets('log in, pay arrears through Juice sandbox, get a receipt', (
    tester,
  ) async {
    await _pumpApp(tester);
    await tester.tap(find.text('Member').last);
    await _settle(tester);
    await tester.tap(find.text('Log in'));
    await tester.pump(const Duration(milliseconds: 700));
    await _settle(tester);
    expect(find.text('Outstanding'), findsOneWidget);

    await tester.tap(find.text('Pay upcoming months'));
    await _settle(tester);
    expect(find.text('MUR 300'), findsOneWidget); // one overdue + current month

    await tester.tap(find.text('Pay with Juice'));
    await _settle(tester);
    await tester.tap(find.text('Confirm payment'));
    await tester.pump(const Duration(seconds: 3));
    await _settle(tester);
    expect(find.text('Payment successful'), findsOneWidget);

    await tester.tap(find.text('Back to my account'));
    await _settle(tester);
    expect(find.text('All paid up'), findsOneWidget);
  });

  testWidgets('access request validates before submitting', (tester) async {
    await _pumpApp(tester);
    await tester.tap(find.text('Member').last);
    await _settle(tester);
    await tester.tap(find.text('Request access'));
    await _settle(tester);
    await tester.ensureVisible(find.text('Submit request'));
    await tester.tap(find.text('Submit request'));
    await _settle(tester);
    expect(find.text('Enter your full name'), findsOneWidget);
    expect(find.text('Consent is required'), findsOneWidget);
  });

  testWidgets('French at 200% text size: no overflow on the main screens', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _pumpApp(tester);
    await tester.tap(find.text('FR'));
    await _settle(tester);
    for (final tab in ['Comité', 'FAQ', 'Contacts', 'Membre']) {
      await tester.tap(find.text(tab).last);
      await _settle(tester);
    }
    // Any RenderFlex overflow fails the test via the framework's error reporting.
  });
}
