import 'package:material_ui/material_ui.dart';

import 'tokens.dart';

ThemeData buildTheme() {
  final scheme =
      ColorScheme.fromSeed(
        seedColor: AppColors.amber,
        brightness: Brightness.light,
      ).copyWith(
        primary: AppColors.amber,
        onPrimary: AppColors.ink,
        secondary: AppColors.amberDeep,
        surface: AppColors.surface,
        onSurface: AppColors.ink,
        error: AppColors.danger,
        outline: AppColors.line,
      );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.bg,
    fontFamily: Fonts.ui,
    splashFactory: NoSplash.splashFactory, // press feedback is scale, not ink
    textTheme: const TextTheme(
      displaySmall: AppText.hero,
      headlineMedium: AppText.title,
      titleLarge: AppText.heading,
      bodyLarge: AppText.body,
      bodyMedium: AppText.body,
      labelLarge: AppText.bodyStrong,
      labelMedium: AppText.label,
      bodySmall: AppText.caption,
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.amberDeep,
      selectionHandleColor: AppColors.amber,
    ),
    switchTheme: SwitchThemeData(
      trackColor: WidgetStateProperty.resolveWith(
        (s) =>
            s.contains(WidgetState.selected) ? AppColors.amber : AppColors.line,
      ),
      thumbColor: const WidgetStatePropertyAll(AppColors.surface),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.night,
      indicatorColor: AppColors.amber,
      surfaceTintColor: Colors.transparent,
      height: 68,
      iconTheme: WidgetStateProperty.resolveWith(
        (s) => IconThemeData(
          size: 24,
          color: s.contains(WidgetState.selected)
              ? AppColors.night
              : AppColors.onNightMuted,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (s) => AppText.caption.copyWith(
          fontWeight: FontWeight.w500,
          color: s.contains(WidgetState.selected)
              ? AppColors.amber
              : AppColors.onNightMuted,
        ),
      ),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.amberDeep,
    ),
  );
}
