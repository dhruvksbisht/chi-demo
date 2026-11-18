import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../core/utils/format.dart';
import '../features/admin/admin_screen.dart';
import '../features/centenary/centenary_screen.dart';
import '../features/committee/committee_screen.dart';
import '../features/contacts/contacts_screen.dart';
import '../features/documents/documents_screen.dart';
import '../features/donate/donate_screen.dart';
import '../features/duas/duas_screen.dart';
import '../features/events/events_screen.dart';
import '../features/faq/faq_screen.dart';
import '../features/home/home_screen.dart';
import '../features/member/member_screen.dart';
import '../features/member/profile_screen.dart';
import '../features/member/request_access_screen.dart';
import '../features/news/article_screen.dart';
import '../features/news/news_list_screen.dart';
import '../features/notifications/notifications_screen.dart';
import '../features/payments/checkout_screen.dart';
import '../features/payments/history_screen.dart';
import '../features/payments/pay_screen.dart';
import '../features/payments/receipt_screen.dart';
import '../features/prayer/prayer_screen.dart';
import '../features/prayer/qibla_screen.dart';
import '../features/prayer/ramadan_screen.dart';

GoRouter buildRouter() {
  final rootKey = GlobalKey<NavigatorState>();

  GoRoute page(String path, Widget Function(GoRouterState s) build) => GoRoute(
    path: path,
    parentNavigatorKey: rootKey,
    builder: (_, s) => build(s),
  );

  GoRoute modal(String path, Widget Function(GoRouterState s) build) => GoRoute(
    path: path,
    parentNavigatorKey: rootKey,
    pageBuilder: (_, s) =>
        MaterialPage(key: s.pageKey, fullscreenDialog: true, child: build(s)),
  );

  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: '/',
    routes: [
      // Five tabs, each keeping its own stack (section 10: Home, Committee, FAQ, Contacts, Member).
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => _TabShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: '/', builder: (_, _) => const HomeScreen())],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/committee',
                builder: (_, _) => const CommitteeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/faq', builder: (_, _) => const FaqScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/contacts',
                builder: (_, _) => const ContactsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/member', builder: (_, _) => const MemberScreen()),
            ],
          ),
        ],
      ),
      page('/news', (_) => const NewsListScreen()),
      page('/news/:id', (s) => ArticleScreen(id: s.pathParameters['id']!)),
      page('/prayer', (_) => const PrayerScreen()),
      page('/ramadan', (_) => const RamadanScreen()),
      page('/qibla', (_) => const QiblaScreen()),
      page('/events', (_) => const EventsScreen()),
      page('/donate', (_) => const DonateScreen()),
      page('/documents', (_) => const DocumentsScreen()),
      page('/duas', (_) => const DuasScreen()),
      page('/centenary', (_) => const CentenaryScreen()),
      page('/notifications', (_) => const NotificationsScreen()),
      page('/history', (_) => const HistoryScreen()),
      page('/receipt/:id', (s) => ReceiptScreen(id: s.pathParameters['id']!)),
      page('/profile', (_) => const ProfileScreen()),
      page('/admin', (_) => const AdminScreen()),
      page('/pay', (_) => const PayScreen()),
      modal(
        '/checkout',
        (s) => CheckoutScreen(
          request: s.extra is CheckoutRequest
              ? s.extra! as CheckoutRequest
              : null,
        ),
      ),
      modal('/request-access', (_) => const RequestAccessScreen()),
    ],
  );
}

class _TabShell extends StatelessWidget {
  const _TabShell({required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final tabs = [
      (Icons.home_rounded, t.tabHome),
      (Icons.groups_rounded, t.tabCommittee),
      (Icons.help_rounded, t.tabFaq),
      (Icons.place_rounded, t.tabContacts),
      (Icons.person_rounded, t.tabMember),
    ];
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) {
          HapticFeedback.selectionClick();
          // Tapping the current tab again pops it back to its root.
          shell.goBranch(i, initialLocation: i == shell.currentIndex);
        },
        destinations: [
          for (final (icon, label) in tabs)
            NavigationDestination(icon: Icon(icon), label: label),
        ],
      ),
    );
  }
}
