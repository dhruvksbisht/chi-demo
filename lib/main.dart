import 'package:cupertino_ui/cupertino_ui.dart'
    show GlobalCupertinoLocalizations;
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'app/router.dart';
import 'core/l10n/app_localizations.dart';
import 'core/theme/theme.dart';
import 'core/theme/tokens.dart';
import 'data/app_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const ProviderScope(child: ChiApp()));
}

class ChiApp extends ConsumerStatefulWidget {
  const ChiApp({super.key});

  @override
  ConsumerState<ChiApp> createState() => _ChiAppState();
}

class _ChiAppState extends ConsumerState<ChiApp> {
  final _router = buildRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(langProvider);
    return MaterialApp.router(
      title: 'CHI',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      locale: Locale(lang.name),
      supportedLocales: AppLocalizations.supportedLocales,
      // Material/Cupertino localizations now live in material_ui / cupertino_ui; the generated
      // AppLocalizations.localizationsDelegates still points at the deprecated framework copies.
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      routerConfig: _router,
      // Tablets get the phone layout with a readable max width (NFR-05).
      builder: (context, child) => ColoredBox(
        color: AppColors.sunken,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: child,
          ),
        ),
      ),
    );
  }
}
